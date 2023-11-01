package com.tco.requests;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

public class TestUserRequest {

    private UserRequest user;

    @BeforeEach
    public void setUpUserRequests() {
        user = new UserRequest("nickyak", "1234", "nickyak@colostate.edu", false);
        user.buildResponse();
    }

    @Test
    @DisplayName("nickyak: Test a typical user login request.")
    public void testValidUserLoginRequest() {
        String username = "nickyak";
        String email = "nickyak@colostate.edu";
        String password = "1234";
        boolean register = false;
        UserRequest userTest = new UserRequest(username, email, password, register);
        userTest.buildResponse();
        assertEquals(1, userTest.userId());
    }

    @Test
    @DisplayName("nickyak: Test a failed user login request.")
    public void testFailedUserLoginRequest() {
        String username = "nobody";
        String email = "nobody@colostate.edu";
        String password = "4321";
        boolean register = false;
        UserRequest userTest = new UserRequest(username, email, password, register);
        userTest.buildResponse();
        assertEquals(0, userTest.userId());
    }

    @Test
    @DisplayName("nickyak: Test a failed user register request.")
    public void testFailedUserRegisterRequest() {
        String username = "nickyak";
        String email = "nobody@colostate.edu";
        String password = "4321";
        boolean register = true;
        UserRequest userTest = new UserRequest(username, email, password, register);
        userTest.buildResponse();
        assertEquals(0, userTest.userId());
    }

}
