# #!/bin/bash
umask 077;

export SERVER_PORT=$((0+${CS314_SERVER_BASE:-41300}+${CS314_TEAM:-0}))
export CLIENT_PORT=$((0+${CS314_CLIENT_BASE:-43100}+${CS314_TEAM:-0}))
echo Using client/server ports: $CLIENT_PORT / $SERVER_PORT

check_error() {
  if [ "$1" -ne 0 ]; then
    echo "Failed at step: ${FUNCNAME[1]}"
    exit "$1"
  fi
}

realpath() {
    echo made it!
    if command -v realpath &> /dev/null; then
        realpath "$1"
    elif command -v readlink &> /dev/null; then
        readlink -f "$1"
    else
        echo "Error: realpath or readlink not found" >&2
        return 1
    fi
}

function usage {
  echo "usage: $0 [OPTIONS]";
  echo "Options:"
  echo "    -h, --help     :  Display this menu";
  echo "    -e, --env      :  Specify environment, possible choices: [dev,prod], (default, dev)";
  echo ""
}

function get_repo_root_dir {
  if [[ ! -e "$1" ]]; then
    echo "Error: $1 does not exist." >&2
    return 1
  fi

  # If input is a file, get the directory containing the file
  if [[ -f "$1" ]]; then
    input_dir="$(dirname "$1")"
  else
    input_dir="$1"
  fi

  dir="$(realpath "$input_dir")"
  while [[ ! -d "$dir/.git" ]]; do
    if [[ "$dir" == "/" ]]; then
      echo "Error: Reached root directory without finding .git. Are you sure this is a git repository?" >&2
      return 1
    fi
    dir="$(dirname "$dir")"
  done

  export REPO_ROOT="$dir"
}

function get_nfs_mounted {
  if [[ -z "${REPO_ROOT}" ]]; then
    echo "Error: REPO_ROOT is not set" >&2
    return 1
  fi

  OS=$(uname)
  if [[ "$OS" == "Darwin" ]]; then
    NFS_MOUNTED=0
    export NFS_MOUNTED
    return
  fi

  file_system="$(stat -f -L -c %T "${REPO_ROOT}")"
  if [[ "$file_system" == "nfs" ]]; then
    NFS_MOUNTED=1
  else
    NFS_MOUNTED=0
  fi
  export NFS_MOUNTED
}

function get_default_prefix {
  if [[ -n "$NFS_MOUNTED" ]]; then
    export BUILD_DIRECTORY_PREFIX="/my-app/"
  elif [[ -n "$REPO_ROOT" ]]; then
    export BUILD_DIRECTORY_PREFIX="$REPO_ROOT"
  else
    echo "Error: REPO_ROOT is not set" >&2
    return 1
  fi
}

get_repo_root_dir $0;
get_nfs_mounted;
get_default_prefix;

install_client_dependencies() {
  pushd "${REPO_ROOT}" > /dev/null

  if [[ -n "${NFS_MOUNTED}" ]]; then
    if [[ ! -e node_modules ]]; then
      if [[ -z "${BUILD_DIRECTORY_PREFIX}" ]]; then
        echo "Error: BUILD_DIRECTORY_PREFIX is not set" >&2
        return 1
      fi
      
      mkdir -p "${BUILD_DIRECTORY_PREFIX}"
      cp package.json "${BUILD_DIRECTORY_PREFIX}"
      npm install --prefix "${BUILD_DIRECTORY_PREFIX}"

      [[ -e node_modules ]] || ln -sf "${BUILD_DIRECTORY_PREFIX}/node_modules" node_modules
    fi
  elif [[ ! -d node_modules ]]; then
    npm install --prefix "${REPO_ROOT}"
  fi
  
  check_error $?
  popd > /dev/null
}

function run_client_tests {
  npm test -- --coverage --watchAll=false
  check_error $?
}

function run_server_and_hotloader {
  npm start --prefix ${REPO_ROOT}/
  check_error $?
}

while (( "$#" )); do
  case "$1" in
    -h|--help)
      usage;
      exit 0;
      ;;
    -e|--env)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        if [[ "$2" != "dev" && "$2" != "prod" ]]; then
          echo "\"$2\" is not a valid environment choice";
          usage;
          exit;
        fi
        CS314_ENV=$2
        shift 2
      else
        echo "argument missing for -- $1" >&2
        exit 1
      fi
      ;;
    -*|--*=) # unsupported flags
      echo "unrecognized option -- $(echo $1 | sed 's~^-*~~')" >&2
      usage;
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

eval set -- "$PARAMS";

if [[ -z "$CS314_ENV" ]]; then
  CS314_ENV=dev;
fi;

echo "Building and Starting the Application in $([[ "$CS314_ENV" == "dev" ]] && echo 'DEVELOPMENT' || echo 'PRODUCTION' ) Mode."

# Remove target to avoid huge Maven shade warnings
sudo rm -rf ${BUILD_DIRECTORY_PREFIX}/target

if [[ -n "${NFS_MOUNTED}" ]]; then
  sudo mkdir -p ${BUILD_DIRECTORY_PREFIX}/target
  if [[ ! -L "${REPO_ROOT}/target" && -d "${REPO_ROOT}/target" ]]; then
    echo "Cleaning NFS mounted target"
    rm -rf ${REPO_ROOT}/target
  fi
  ln -sf ${BUILD_DIRECTORY_PREFIX}/target ${REPO_ROOT}/target
  if [[ ! "$CS314_ENV" == "dev" ]]; then
    mkdir -p ${BUILD_DIRECTORY_PREFIX}/client/dist
    if [[ ! -L "${REPO_ROOT}/client/dist" && -d "${REPO_ROOT}/client/dist" ]]; then
      echo "Cleaning NFS mounted client/dist"
      rm -rf ${REPO_ROOT}/client/dist
    fi
    ln -sf ${BUILD_DIRECTORY_PREFIX}/client/dist ${REPO_ROOT}/client/dist
  fi
fi

# install dependencies
install_client_dependencies
# install_server_dependencies

# test client
run_client_tests

if [[ "$CS314_ENV" == "dev" ]]; then
#   build_server
#   postman_tests
  run_server_and_hotloader
else
  bundle_client
  build_server
  postman_tests
  run_server
fi