<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.google.gson.JsonObject" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="javax.naming.Context" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.sql.DataSource" %>

<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
    
    String userId = request.getParameter("userId");
    String withdrawDate = request.getParameter("withdrawDate");
    
    JsonObject result = new JsonObject();
    
    if (userId == null || withdrawDate == null || userId.trim().isEmpty() || withdrawDate.trim().isEmpty()) {
        result.addProperty("success", false);
        result.addProperty("message", "필수 파라미터가 누락되었습니다.");
        out.print(new Gson().toJson(result));
        return;
    }
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    
    try {
        // DB 연결
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/photonation?useSSL=false&serverTimezone=UTC", "root", "1234");
        
        if (conn == null) {
            result.addProperty("success", false);
            result.addProperty("message", "데이터베이스 연결에 실패했습니다.");
            out.print(new Gson().toJson(result));
            return;
        }
        
        conn.setAutoCommit(false); // 트랜잭션 시작
        
        // 1. 먼저 해당 사용자가 존재하는지 확인
        String checkQuery = "SELECT COUNT(*) FROM lost_user WHERE id = ? AND withdrawDate = ?";
        pstmt = conn.prepareStatement(checkQuery);
        pstmt.setString(1, userId.trim());
        pstmt.setString(2, withdrawDate.trim());
        ResultSet checkRs = pstmt.executeQuery();
        
        boolean userExists = false;
        if (checkRs.next()) {
            userExists = checkRs.getInt(1) > 0;
        }
        checkRs.close();
        pstmt.close();
        
        if (!userExists) {
            conn.rollback();
            result.addProperty("success", false);
            result.addProperty("message", "해당 탈퇴 회원을 찾을 수 없습니다.");
            out.print(new Gson().toJson(result));
            return;
        }
        
        // 2. lost_user_profiles에서 먼저 삭제, 외래키 제약 조건에 의함
        String deleteProfileQuery = "DELETE FROM lost_user_profiles WHERE id = ? AND withdrawDate = ?";
        pstmt = conn.prepareStatement(deleteProfileQuery);
        pstmt.setString(1, userId.trim());
        pstmt.setString(2, withdrawDate.trim());
        int profileDeleteCount = pstmt.executeUpdate();
        pstmt.close();
        
        // 3. lost_user에서 삭제
        String deleteUserQuery = "DELETE FROM lost_user WHERE id = ? AND withdrawDate = ?";
        pstmt = conn.prepareStatement(deleteUserQuery);
        pstmt.setString(1, userId.trim());
        pstmt.setString(2, withdrawDate.trim());
        
        int rowsAffected = pstmt.executeUpdate();
        
        if (rowsAffected > 0) {
            conn.commit(); // 트랜잭션 커밋
            result.addProperty("success", true);
            result.addProperty("message", "데이터가 성공적으로 삭제되었습니다.");
            result.addProperty("deletedProfiles", profileDeleteCount);
        } else {
            conn.rollback();
            result.addProperty("success", false);
            result.addProperty("message", "데이터 삭제에 실패했습니다.");
        }
        
    } catch (ClassNotFoundException e) {
        try {
            if (conn != null) conn.rollback();
        } catch (SQLException se) {
            se.printStackTrace();
        }
        result.addProperty("success", false);
        result.addProperty("message", "데이터베이스 드라이버를 찾을 수 없습니다.");
        e.printStackTrace();
    } catch (SQLException e) {
        try {
            if (conn != null) conn.rollback();
        } catch (SQLException se) {
            se.printStackTrace();
        }
        result.addProperty("success", false);
        result.addProperty("message", "데이터베이스 오류가 발생했습니다: " + e.getMessage());
        e.printStackTrace();
    } catch (Exception e) {
        try {
            if (conn != null) conn.rollback();
        } catch (SQLException se) {
            se.printStackTrace();
        }
        result.addProperty("success", false);
        result.addProperty("message", "서버 오류가 발생했습니다: " + e.getMessage());
        e.printStackTrace();
    } finally {
        try {
            if (pstmt != null) pstmt.close();
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    out.print(new Gson().toJson(result));
%>