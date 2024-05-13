<%@ page import="java.sql.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Partly</title>
</head>
<body>

<%
    String db = "team9";
    String admin = "root";
    String adminPassword = "cs157a@zaza";
    String fName = request.getParameter("fName");
    String lName = request.getParameter("lName");
    String email = request.getParameter("email");
    String cartID = request.getParameter("CartID");
    String user = (String) session.getAttribute("user");
    PreparedStatement psBecomes = null;
    String adr = "";
    String city = "";
    String state = "";
    String zip = "";

    String checkboxValue = request.getParameter("same_adr");
    boolean notChecked = (checkboxValue == null);
    ResultSet rs_generatedKeys = null;

    if(notChecked){
        adr = request.getParameter("ship_adr");
        city = request.getParameter("ship_city");
        state = request.getParameter("ship_state");
        zip  = request.getParameter("ship_zip");
    } else {
        adr = request.getParameter("adr");
        city = request.getParameter("city");
        state = request.getParameter("state");
        zip  = request.getParameter("zip");
    }

    PreparedStatement psOrder = null;
    PreparedStatement psView = null;
    PreparedStatement psOrderHistory = null;
    PreparedStatement psCartItems = null;
    Connection con = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/" + db + "?autoReconnect=true&useSSL=false", admin, adminPassword);

        String queryOrder = "INSERT INTO `order` (`Contact Info`, `Shipping Address`, CustomerID) VALUES (?,?,?)";
        psOrder = con.prepareStatement(queryOrder, Statement.RETURN_GENERATED_KEYS);
        psOrder.setString(1, email);
        String shipAdr = adr + ", " + city + ", " + state + " " + zip;
        psOrder.setString(2, shipAdr);
        psOrder.setString(3, user);

        int affectedRows = psOrder.executeUpdate();

        if (affectedRows > 0) {
            rs_generatedKeys = psOrder.getGeneratedKeys();
            if (rs_generatedKeys.next()) {
                int generatedKey = rs_generatedKeys.getInt(1);

                String queryBecomes = "INSERT INTO becomes(CartID, OrderID, Order_Date) VALUES(?, ?, ?)";
                LocalDate currentDate = LocalDate.now();
                String currentDateStr = currentDate.toString();

                psBecomes = con.prepareStatement(queryBecomes);
                psBecomes.setString(1, cartID);
                psBecomes.setInt(2, generatedKey);
                psBecomes.setString(3, currentDateStr);

                psBecomes.execute();

                String queryView = "INSERT INTO `view`(Username,OrderID) VALUES(?,?)";
                psView = con.prepareStatement(queryView);
                psView.setString(1, user);
                psView.setInt(2, generatedKey);

                psView.execute();

                // Retrieve items from the cart
                String queryCartItems = "SELECT ad.PartID, ad.QTY, p.`Sell Price`, p.URL FROM `Added To` ad " +
                        "INNER JOIN Part p ON ad.PartID = p.PartID WHERE ad.CartID = ?";
                psCartItems = con.prepareStatement(queryCartItems);
                psCartItems.setString(1, cartID);
                ResultSet rsCartItems = psCartItems.executeQuery();

                while (rsCartItems.next()) {
                    int partID = rsCartItems.getInt("PartID");
                    int qty = rsCartItems.getInt("QTY");
                    double price = rsCartItems.getDouble("Sell Price");
                    String url = rsCartItems.getString("URL");

                    // Insert into order_history
                    String queryOrderHistory = "INSERT INTO order_history (username, order_id, part_id, qty, price, shipping_address, order_date, url) " +
                            "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                    psOrderHistory = con.prepareStatement(queryOrderHistory);
                    psOrderHistory.setString(1, user);
                    psOrderHistory.setInt(2, generatedKey);
                    psOrderHistory.setInt(3, partID);
                    psOrderHistory.setInt(4, qty);
                    psOrderHistory.setDouble(5, price);
                    psOrderHistory.setString(6, shipAdr);
                    psOrderHistory.setString(7, currentDateStr);
                    psOrderHistory.setString(8, url);

                    psOrderHistory.executeUpdate();
                }

                psView.close();
                psBecomes.close();
                rs_generatedKeys.close();
            }

            String queryAccess = "UPDATE Access SET currentCart = 0 WHERE CartID = ? AND Username = ?";
            PreparedStatement psAccess = con.prepareStatement(queryAccess);
            psAccess.setString(1, cartID);
            psAccess.setString(2, user);

            psAccess.execute();
            psAccess.close();

            String queryClearCart = "DELETE FROM `Added To` WHERE CartID = ?";
            PreparedStatement psClearCart = con.prepareStatement(queryClearCart);
            psClearCart.setString(1, cartID);

            psClearCart.execute();
            psClearCart.close();
        }

    } catch (ClassNotFoundException | SQLException e) {
        System.out.println("error in Checkout: " + e);
    } finally {
        try { if (psView != null) psView.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (rs_generatedKeys != null) rs_generatedKeys.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (psOrder != null) psOrder.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (psOrderHistory != null) psOrderHistory.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (psCartItems != null) psCartItems.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (con != null) con.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>
</body>
<script>
    alert("Thanks for shopping with Partly!");
    alert("Redirecting user back to Catalog page.");
    window.location.href = "http://localhost:8080/user/Catalog.jsp";
</script>
</html>
