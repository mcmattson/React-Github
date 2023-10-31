import React, { useState } from 'react';
import Login from './Login';
import { getOriginalServerUrl, sendAPIRequest } from "../../utils/restfulAPI";
import { LOG } from '../../utils/constants';

export default function Register() {
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
    const handleRegisterDataChange = (e) => {
        setErrorMessage('');
        setRegisterData({ ...registerData, [e.target.name]: e.target.value });
    };

    const toggleOpenCreateAccount = () => {
        setErrorMessage('');
        setIsOpenCreateAccountOpen(!isOpenCreateAccountOpen);
        setIsDivVisible(false);
    };

    const handleRegisterSubmit = async (e) => {
        e.preventDefault();
        try {
            const response = await sendAPIRequest({
                requestType: "user",
                register: true,
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
                LOG.info('Registration Request Successful', serverUrl, response.response)
            }
        } catch (e) {
            LOG.info('Registration Request Error!', e)
        }
    };

    return (
        <div className='registerPage'>
            {isDivVisible && (
                <div className='div-top'>
                    <header>
                        <h4 className="header-001 text-align-center">Sign Up</h4>
                        <p className="text-align-center"><span>Enter the Following Information</span></p>
                    </header>
                    <form name='newAccountInfo' onSubmit={handleRegisterSubmit}>
                        <label className="label-100">  Username</label>
                        <input type="text" name="username" placeholder="Username" value={registerData.username} onChange={handleRegisterDataChange} />
                        {errorMessage && <div className='error-message'>{errorMessage}</div>}
                        <label className="label-100"> Email</label>
                        <input type="email" name="email" placeholder="name@email.com" value={registerData.email} onChange={handleRegisterDataChange} />
                        <label className="label-100"> Password</label>
                        <input type="password" name="password" placeholder="Enter Your Password" value={registerData.password} onChange={handleRegisterDataChange} />
                        <button className='button-100 margin-top-20' type='submit'>Create Account</button>
                    </form>
                    <div className='div-line'>
                        <div className='orLine-100'></div>
                        <div className='div-or'>or</div>
                        <div className='orLine-100'></div>
                    </div>
                    <button className='button-100' onClick={toggleOpenCreateAccount}>Login</button>
                </div>
            )}

            {isOpenCreateAccountOpen && <Login />}
        </div>
    );
}