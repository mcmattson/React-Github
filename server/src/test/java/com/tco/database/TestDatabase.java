package com.tco.database;

import java.sql.Connection;
import java.sql.SQLException;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;

import static org.junit.jupiter.api.Assertions.*;

public class TestDatabase {
    private Database database;

    @BeforeEach
    public void createConfigurationForTestCases() {
        database = Database.getInstance();
    }

    @Test
    @DisplayName("base: test that connection is valid")
    public void testConnects() throws SQLException {
        Connection conn = database.getConnection();

        assertNotNull(conn);
        assertFalse(conn.isClosed());
    }
}
