import React, { useEffect, useState } from 'react';
import { LOG } from '../utils/constants';
import { getOriginalServerUrl, sendAPIRequest } from '../utils/restfulAPI';

export function useUser(register, email, username, password) {
    const [userId, setUserId] = useState(0);
    const [success, setSuccess] = useState(false);
    const [message, setMessage] = useState('');

    const user = {
        register : register,
        email : email,
        username : username,
        password : password,
        userId : userId,
        success : success,
        message : message
    }

    const userActions = {
        setSuccess : setSuccess,
        setMessage : setMessage,
        setUserId : setUserId
    }
}
