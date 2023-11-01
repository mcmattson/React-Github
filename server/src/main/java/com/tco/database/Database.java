package com.tco.database;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.SQLException;


public class Database {
    private static Logger log = LoggerFactory.getLogger(Database.class);
    private static Database database = null;

    public Connection conn;

    private Connection connect() throws SQLException {
        log.info("Connection to database: {} {} {}", Credential.url(), Credential.USER, Credential.PASSWORD);

        return DriverManager.getConnection(Credential.url(), Credential.USER, Credential.PASSWORD);
    }

    private Database() {
        try {
            this.conn = connect();
        } catch (Exception e) {
            this.conn = null;
        }
    }

    public static synchronized Database getInstance() {
        if (database == null)
            database = new Database();

        return database;
    }

    public Connection getConnection() throws SQLException {
        if (conn == null || conn.isClosed())
            this.conn = connect();

        return this.conn;
    }
}
