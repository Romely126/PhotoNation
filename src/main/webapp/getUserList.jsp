<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="com.google.gson.JsonObject" %>
<%@ page import="com.google.gson.JsonArray" %>

<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    JsonArray userArray = new JsonArray();
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/photonation", "root", "1234");
        
        String query = "SELECT id, nickname, name, sex, joinDate, actived FROM user_info ORDER BY joinDate DESC";
        pstmt = conn.prepareStatement(query);
        rs = pstmt.executeQuery();
        
        while (rs.next()) {
            JsonObject user = new JsonObject();
            user.addProperty("id", rs.getString("id"));
            user.addProperty("nickname", rs.getString("nickname"));
            user.addProperty("name", rs.getString("name"));
            user.addProperty("sex", rs.getString("sex"));
            user.addProperty("joinDate", rs.getDate("joinDate").toString());
            user.addProperty("actived", rs.getInt("actived"));
            userArray.add(user);
        }
        
        out.print(new Gson().toJson(userArray));
        
    } catch (Exception e) {
        JsonArray errorArray = new JsonArray();
        JsonObject error = new JsonObject();
        error.addProperty("error", "데이터 로드 중 오류가 발생했습니다: " + e.getMessage());
        errorArray.add(error);
        out.print(new Gson().toJson(errorArray));
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>