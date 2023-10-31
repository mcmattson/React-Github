import React, { useEffect, useState } from 'react';
import { Collapse } from 'reactstrap';
import Login from './Login/Login.js'
import Header from './Header/Header';
import { useToggle } from '../hooks/useToggle';
import { Container } from 'reactstrap';
import { LOG } from '../utils/constants';
import { getOriginalServerUrl, sendAPIRequest } from '../utils/restfulAPI';


export default function Page(props) {
	const [serverSettings, processServerConfigSuccess] = useServerSettings(props.showMessage);
	const [showLogin] = useToggle(false);

	return (
		<>
			<Header
				showLogin={showLogin}
				serverSettings={serverSettings}
				processServerConfigSuccess={processServerConfigSuccess}
			/>
			<Container>
				<MainContentArea
					showLogin={showLogin}
				/> 
			</Container>

		</>
	);
}
function MainContentArea(props) {
	return (
		<div className='body'>
			<Collapse isOpen={!props.showLogin} data-testid='planner-collapse' >
			</Collapse>
		</div>
	);
}

function useServerSettings(showMessage) {
	const [serverUrl, setServerUrl] = useState(getOriginalServerUrl());
	const [serverConfig, setServerConfig] = useState(null);

	useEffect(() => {
		sendConfigRequest();
	}, []);

	function processServerConfigSuccess(config, url) {
		LOG.info('Switching to Server:', url);
		setServerConfig(config);
		setServerUrl(url);
	}

	async function sendConfigRequest() {
		const configResponse = await sendAPIRequest({ requestType: 'config' }, serverUrl);
		if (configResponse) {
			processServerConfigSuccess(configResponse, serverUrl);
		} else {
			setServerConfig(null);
			showMessage(`Config request to ${serverUrl} failed. Check the log for more details.`, 'error');
		}
	}

	return [{ serverUrl: serverUrl, serverConfig: serverConfig }, processServerConfigSuccess,];
}