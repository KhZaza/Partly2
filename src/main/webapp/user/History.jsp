<%@ page import="java.sql.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Partly</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
    <style>
        .navbar {
            border-radius: 0;
            margin-bottom: 0;
        }
        .navbar .container-fluid {
            padding-left: 0;
            padding-right: 0;
        }
    </style>
</head>
<body>

<nav class="navbar navbar-inverse">
    <div class="container-fluid">
        <div class="navbar-header">
            <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#myNavbar">
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>
            <a class="navbar-brand" style="margin-left: 2px" href="Catalog.jsp">Partly</a>
        </div>
        <div class="collapse navbar-collapse" id="myNavbar">
            <ul class="nav navbar-nav navbar-right">
                <li><a href="Home.html"><span class="glyphicon glyphicon-user"></span> Your Account</a></li>
                <li><a href="Cart.jsp"><span class="glyphicon glyphicon-shopping-cart"></span> Cart</a></li>
            </ul>
        </div>
    </div>
</nav>
<%

    String db = "team9";
    String admin = "root";
    String adminPassword = "cs157a@zaza";

    PreparedStatement psAll = null;
    Connection con = null;
    ResultSet rsData = null;
    String user = (String)session.getAttribute("user");
    List<Integer> partIDList = new ArrayList<>();
    List<Integer> qtyList = new ArrayList<>();
    List<Integer> orderIDList = new ArrayList<>();
    List<String> shippingList = new ArrayList<>();
    List<Double> priceList = new ArrayList<>();
    List<String> urlList = new ArrayList<>();
    List<String> dateList = new ArrayList<>();
    int countRows = 0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/" + db + "?autoReconnect=true&useSSL=false", admin, adminPassword);

        String queryData = "SELECT * FROM order_history WHERE username = ? ORDER BY order_id DESC";

        psAll = con.prepareStatement(queryData);
        psAll.setString(1, user);
        rsData = psAll.executeQuery();
        while(rsData.next()){
            partIDList.add(rsData.getInt("part_id"));
            qtyList.add(rsData.getInt("qty"));
            orderIDList.add(rsData.getInt("order_id"));
            shippingList.add(rsData.getString("shipping_address"));
            priceList.add(rsData.getDouble("price"));
            urlList.add(rsData.getString("url"));
            dateList.add(rsData.getString("order_date"));
            countRows++;
        }

        if(countRows == 0){
            out.println("<div class=\"container\">\n" +
                    "    <h1 class=\"my-3\">No history available</h1>\n" +
                    "</div>");
        } else {
            out.println("<div class=\"container\">\n" +
                    "    <h1 class=\"my-3\">Complete Order History</h1>");
            for(int i = 0; i < countRows; i++){
                out.println("<div class=\"card mb-3\">\n" +
                        "    <div class=\"card-header bg-primary text-white\">\n" +
                        "        Order " + orderIDList.get(i) + " - " +
                        "Shipping Address: " + shippingList.get(i) + " - " +
                        "Ordered Date: " + dateList.get(i) + "\n" +
                        "    </div>\n" +
                        "    <ul class=\"list-group list-group-flush\">\n" +
                        "        <li class=\"list-group-item\">\n" +
                        "            <img src=\"" + urlList.get(i) + "\" alt=\"Item\" style=\"width:100px;\">\n" +
                        "            Item " + partIDList.get(i) + " - $" + priceList.get(i) + " - QTY: " + qtyList.get(i) +
                        "        </li>\n" +
                        "    </ul>\n" +
                        "</div>");
            }
            out.println("</div>");
        }

    } catch (ClassNotFoundException | SQLException e) {
        System.out.println("error in History Stock: " + e);
    } finally {
        try { if (rsData != null) rsData.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (psAll != null) psAll.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (con != null) con.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>

</body>
</html>
