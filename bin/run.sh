# #!/bin/bash

check_error() {
  if [ "$1" -ne 0 ]; then
    echo "Failed at step: ${FUNCNAME[1]}"
    exit "$1"
  fi
}

realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}";
}

function usage {
  echo "usage: $0 [OPTIONS]";
  echo "Options:"
  echo "    -h, --help     :  Display this menu";
  echo "    -e, --env      :  Specify environment, possible choices: [dev,prod], (default, dev)";
  echo ""
}

function get_repo_root_dir {
  dir="$(realpath $1)";
  while [[ ! -d "$dir/.git" ]];
  do
    dir=`echo $dir | sed 's~\(.*\)/.*~\1~'`;
  done;

  export REPO_ROOT=$dir;
}

function get_nfs_mounted {
  OS=$(uname);
  if [[ "$OS" == "Darwin" ]]; then
    return;
  fi

  file_system="$(stat -f -L -c %T ${REPO_ROOT})";
  if [[ "$file_system" == "nfs" ]]; then
    export NFS_MOUNTED=1;
  fi
}

function get_default_prefix {
  if [[ -n "$NFS_MOUNTED" ]]; then
    export BUILD_DIRECTORY_PREFIX="/my-app/"
  else
    export BUILD_DIRECTORY_PREFIX="${REPO_ROOT}"
  fi
}

get_repo_root_dir $0;
get_nfs_mounted;
get_default_prefix;

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
rm -rf ${BUILD_DIRECTORY_PREFIX}/target

if [[ -n "${NFS_MOUNTED}" ]]; then
  mkdir -p ${BUILD_DIRECTORY_PREFIX}/target
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