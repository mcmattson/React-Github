package com.tco.requests;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.tco.database.Database;

public class UserRequest extends Request {
    private static final transient Logger log = LoggerFactory.getLogger(ConfigRequest.class);
    private transient Database database;
    private transient Connection connection;
    private transient Statement statement;
    private transient ResultSet result;
    private boolean register;
    private int userId;
    private String username;
    private String email;
    private String password;
    private boolean success;
    private String message;

    @Override
    public void buildResponse() {
        try {
            buildQueryList();
        } catch (Exception e) {
            log.error("[\u001B[31mBuild Error\u001B[0m] - {} \n", e);
        }
        log.trace("buildResponse -> {}", this);
    }

    private void buildQueryList() throws Exception {
        try {
            database = Database.getInstance();
            connection = database.getConnection();
            statement = connection.createStatement();

            if (this.register) {
                Register();
            } else {
                Login();
            }

        } catch (Exception e) {
            throw(e);
        }
    }

    public void Login() throws Exception {
        try {
            ResultSet rsusername = statement.executeQuery("SELECT username FROM users WHERE (username = '" + this.username + "' OR email = '" + this.email + "')");
            if (!rsusername.next()) {
                log.error("Username or Email does not exists.");
                this.success = false;
                this.message = "Username or Email does not exists.";
                return;
            }
            ResultSet rspass = statement.executeQuery("SELECT password FROM users WHERE (password = '" + this.password + "')");
            if (!rspass.next()) {
                log.error("Password is Incorrect. Try Again!");
                this.success = false;
                this.message = "Password is Incorrect. Try Again!";
                return;
            }
            result = statement.executeQuery("SELECT user_id FROM users WHERE (username = '" + this.username + "' OR email = '" + this.email + "') AND password = '" + this.password + "' LIMIT 1;");
            if (result.next()) {
                this.userId = result.getInt("user_id");
            }
        } catch (Exception e) {
            log.error("An unexpected error occurred.");
            this.success = false;
            this.message = "An unexpected error occurred.";
            return;
        }
        log.info("Login successful!");
        this.success = true;
        this.message = "Login successful!";
        return;
    }

    public void Register() throws Exception {
        try {
            statement.executeUpdate("INSERT INTO users (username, email, password) VALUES ('" + this.username + "','" + this.email + "','" + this.password + "')", Statement.RETURN_GENERATED_KEYS);
            result = statement.getGeneratedKeys();
            if (result.next()) {
                this.userId = result.getInt("user_id");
            }
        } catch (Exception e) {
            log.error("Username already exists.");
            this.success = false;
            this.message = "Username already exists.";
            return;
        }
        log.info("Registration successful!");
        this.success = true;
        this.message = "Registration successful!";
        return;
    }


    public UserRequest(String username, String email, String password, boolean register) {
        this.requestType = "user";
        this.register = register;
        this.username = username;
        this.email = email;
        this.password = password;
    }

    public int userId() {return this.userId;}

}
