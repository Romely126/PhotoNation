<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.google.gson.JsonObject" %>
<%@ page import="com.google.gson.Gson" %>

<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    String userId = request.getParameter("userId");
    String statusParam = request.getParameter("status");
    
    JsonObject result = new JsonObject();
    
    if (userId == null || statusParam == null) {
        result.addProperty("success", false);
        result.addProperty("message", "필수 파라미터가 누락되었습니다.");
        out.print(new Gson().toJson(result));
        return;
    }
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    
    try {
        int status = Integer.parseInt(statusParam);
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/photonation", "root", "1234");
        
        String query = "UPDATE user_info SET actived = ? WHERE id = ?";
        pstmt = conn.prepareStatement(query);
        pstmt.setInt(1, status);
        pstmt.setString(2, userId);
        
        int rowsAffected = pstmt.executeUpdate();
        
        if (rowsAffected > 0) {
            result.addProperty("success", true);
            result.addProperty("message", "회원 상태가 성공적으로 변경되었습니다.");
        } else {
            result.addProperty("success", false);
            result.addProperty("message", "해당 회원을 찾을 수 없습니다.");
        }
        
    } catch (NumberFormatException e) {
        result.addProperty("success", false);
        result.addProperty("message", "잘못된 상태 값입니다.");
    } catch (Exception e) {
        result.addProperty("success", false);
        result.addProperty("message", "서버 오류가 발생했습니다: " + e.getMessage());
    } finally {
        try {
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    out.print(new Gson().toJson(result));
%>