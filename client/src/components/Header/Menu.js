import React from 'react';
import {
	Dropdown,
	DropdownMenu,
	DropdownToggle,
} from 'reactstrap';
import { useToggle } from '../../hooks/useToggle';
import Login from '../Login/Login'

export default function Menu(props) {
	const [menuOpen, toggleMenu] = useToggle(false);

	return (
		<Dropdown isOpen={menuOpen} toggle={toggleMenu} >
			<DropdownToggle color='primary' data-testid='menu-toggle' style={{ paddingTop: '9px', display: 'flex', justifyContent: 'center', color: 'white', textTransform: "uppercase", fontSize: '16px' }} >
				Login {/* This can/should be changed to a variable that when logged in will display the profile name */}
			</DropdownToggle>
			<DropdownMenu data-testid='menu-button-container' end>
				<Login />
			</DropdownMenu>
		</Dropdown>
	);
}