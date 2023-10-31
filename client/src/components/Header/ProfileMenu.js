import React from 'react';
import {
    DropdownItem,
    Dropdown,
    DropdownMenu,
    DropdownToggle,
} from 'reactstrap';
import { GiHamburgerMenu } from 'react-icons/gi';
import { FaPlus, FaFolderOpen } from 'react-icons/fa';
import { BsPersonVcardFill, BsFillEnvelopeOpenFill, BsBarChartFill, BsXSquareFill } from 'react-icons/bs';
import { useToggle } from '../../hooks/useToggle';

export default function ProfileMenu(props) {
    const [profileMenuOpen, toggleProfileMenu] = useToggle(false);
    const menuButtons = buildMenuButtons(props);

    return (
        <Dropdown isOpen={profileMenuOpen} toggle={toggleProfileMenu}>
            <DropdownToggle color='primary' data-testid='menu-toggle'>
                <GiHamburgerMenu size={22} />
            </DropdownToggle>
            <DropdownMenu data-testid='menu-button-container' end>
                <MenuItems menuButtons={menuButtons} />
            </DropdownMenu>
        </Dropdown>
    );
}

function MenuItems(props) {
    return (
        <>
            {props.menuButtons.map((menuButtonProps) => (
                <MenuButton key={menuButtonProps.dataTestId} {...menuButtonProps} />
            ))}
        </>
    );
}

class MenuButtonProps {
    constructor(
        dataTestId,
        buttonAction,
        buttonIcon,
        buttonText,
        disabled = false
    ) {
        this.dataTestId = dataTestId;
        this.buttonAction = buttonAction;
        this.buttonIcon = buttonIcon;
        this.buttonText = buttonText;
        this.disabled = disabled;
    }
}

function buildMenuButtons(props) {
    return [
        new MenuButtonProps('profile-button', props.toggleProfile, <BsPersonVcardFill />, 'Profile'),
        new MenuButtonProps('match-history-button', props.toggleMatchHistory, <BsBarChartFill />, 'Match History'),
        new MenuButtonProps('invite-game-button', props.toggleInvite, <BsFillEnvelopeOpenFill />, 'Invite'),
        new MenuButtonProps('new-game-button', props.toggleNewGame, <FaPlus />, 'New Game'),
        new MenuButtonProps('load-game-button', props.toggleLoadMatch, <FaFolderOpen />, 'Load Match'),
        new MenuButtonProps('logout-button', props.toggleLogOut, <BsXSquareFill />, 'Logout'),
    ];
}

function MenuButton({
    dataTestId,
    buttonAction,
    buttonIcon,
    buttonText,
    disabled,
}) {
    return (
        <DropdownItem
            data-testid={dataTestId}
            disabled={disabled}
            onClick={() => buttonAction()}
        >
            <div className='menu-item'>
                {buttonIcon}
                &nbsp;&nbsp; {buttonText}
            </div>
        </DropdownItem>
    );
}

