package com.example;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/DeleteFromCartServlet")
public class DeleteFromCartServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String partID = request.getParameter("partID");
        String cartID = request.getParameter("cartID");

        String db = "team9";
        String admin = "root";
        String adminPassword = "cs157a@zaza";

        Connection con = null;
        PreparedStatement psDelete = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/" + db + "?autoReconnect=true&useSSL=false",
                    admin, adminPassword);

            String queryDelete = "DELETE FROM `Added To` WHERE CartID = ? AND PartID = ?";
            psDelete = con.prepareStatement(queryDelete);
            psDelete.setString(1, cartID);
            psDelete.setString(2, partID);

            psDelete.executeUpdate();

        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        } finally {
            try { if (psDelete != null) psDelete.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (con != null) con.close(); } catch (SQLException e) { e.printStackTrace(); }
        }

        response.sendRedirect("/user/Cart.jsp");
    }
}
