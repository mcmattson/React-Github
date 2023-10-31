import React, { useState } from 'react';
import Register from './Register';

import { getOriginalServerUrl, sendAPIRequest } from "../../utils/restfulAPI";
import { LOG } from '../../utils/constants';

export default function Login() {

    const [isOpenCreateAccountOpen, setIsOpenCreateAccountOpen] = useState(false);
    const [isDivVisible, setIsDivVisible] = useState(true);
    const [errorMessage, setErrorMessage] = useState('');
    const [registerData, setRegisterData] = useState({
        username: '',
        email: '',
        password: '',
    });
    const [responseTime, setResponseTime] = useState(0);
    const [serverUrl, setServerUrl] = useState(getOriginalServerUrl());

    const toggleOpenCreateAccount = () => {
        setIsOpenCreateAccountOpen(!isOpenCreateAccountOpen);
        setIsDivVisible(false);
    }

    const handleLoginDataChange = (e) => {
        const { name, value } = e.target;
        setErrorMessage('');
        setRegisterData({ ...registerData, [e.target.name]: e.target.value });
        if (name == 'username') {
            if (isValidEmail(value)) {
                setRegisterData(prevState => ({ ...prevState, email: value, username: '' }));
            } else {
                setRegisterData(prevState => ({ ...prevState, username: value, email: '' }));
            }
        } else {
            setRegisterData(prevState => ({ ...prevState, [name]: value }));
        }
    };

    const handleLoginSubmit = async (e) => {
        e.preventDefault();
        try {
            const response = await sendAPIRequest({
                requestType: "user",
                register: false,
                userId: 1,
                username: registerData.username,
                password: registerData.password,
                email: registerData.email
            }, serverUrl)

            LOG.info('Response', response)
            if (!response.success) {
                setErrorMessage(response.message);
            } else {
                setErrorMessage('');
                setResponseTime(response.response);
                LOG.info('Login Request Successful', serverUrl, response.response)
            }
        } catch (e) {
            LOG.info('Login Request Error!', e)
        }
    };

    const isValidEmail = (email) => {
        const regex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;
        return regex.test(email);
    };
    
    return (

        <div className='homePage'>
            {isDivVisible && (
                <div className='div-top'>
                    <header>
                        <h4 className="header-001">Welcome Back</h4>
                    </header>
                    <form name='loginAccount' onSubmit={handleLoginSubmit}>
                        <label className="label-100">Username/Email</label>
                        <input type="text" name="username" placeholder="Username or Email" value={registerData.username || registerData.email} onChange={handleLoginDataChange} />
                        <label className="label-100">Password</label>
                        <input type="password" name="password" placeholder="Enter Your Password" value={registerData.password} onChange={handleLoginDataChange} />
                        <button className='button-100 margin-top-20' type='submit'>Login</button>
                        {errorMessage && <div className='error-message'>{errorMessage}</div>}
                    </form>
                    <div className='div-line'>
                        <div className='orLine-100'></div>
                        <div className='div-or'>or</div>
                        <div className='orLine-100'></div>
                    </div>
                    <button className='button-100' onClick={toggleOpenCreateAccount}>Create Account</button>
                </div>
            )}

            {isOpenCreateAccountOpen && <Register />}
        </div>
    );


}