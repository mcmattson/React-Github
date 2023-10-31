import React from 'react';
import { Container, Button } from 'reactstrap';
import { CLIENT_TEAM_NAME } from '../../utils/constants';
import Menu from './Menu';
import ProfileMenu from './ProfileMenu';
import { IoMdClose } from 'react-icons/io';
import { useToggle } from '../../hooks/useToggle';

export default function Header(props) {
	const [showServerSettings, toggleServerSettings] = useToggle(false);
	return (
		<React.Fragment>
			<HeaderContents
				toggleMenu={props.toggleMenu}
				showMenu={props.showMenu}
				showProfileMenu={props.showProfileMenu}
			/>
		</React.Fragment>
	);
}

function HeaderContents(props) {
	return (
		<div className='full-width header vertical-center'>
			<Container>
				<div className='header-container'>
					<h1 style={{ display: 'flex', justifyContent: 'center', height: '100', color: 'white', textTransform: "uppercase", fontSize: '30px' }}>
						{CLIENT_TEAM_NAME}
					</h1>
					<div style={{ display: 'flex', justifyContent: 'flex-end' }}>
						<LoginButton {...props} />
						<HeaderButton {...props} />
					</div>
				</div>
			</Container>
		</div>
	);
}

function LoginButton(props) {
	return props.showLogin ? (
		<Button
			data-testid='close-Login-button'
			color='primary'
			onClick={() => props.toggleLogin()}
		>
			<IoMdClose size={32} />
		</Button>
	) : (
		<Menu
			toggleLogin={props.toggleLogin}
		/>
	);
}

function HeaderButton(props) {
	return props.showAbout ? (
		<IoMdClose size={24} />
	) : (
		<ProfileMenu
			toggleMenu={props.toggleMenu}
		/>
	);
}