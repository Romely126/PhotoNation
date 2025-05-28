<%@ page contentType="application/json; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="org.json.JSONObject" %>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    String currentUserId = (String) session.getAttribute("userId");
    String commentIdParam = request.getParameter("commentId");
    
    JSONObject jsonResponse = new JSONObject();
    
    if (currentUserId == null) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "로그인이 필요합니다.");
        out.print(jsonResponse.toString());
        return;
    }
    
    if (commentIdParam == null) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "잘못된 요청입니다.");
        out.print(jsonResponse.toString());
        return;
    }
    
    int commentId = Integer.parseInt(commentIdParam);
    
    String dbURL = "jdbc:mysql://localhost:3306/photonation?characterEncoding=utf8&serverTimezone=Asia/Seoul";
    String dbUser = "root";
    String dbPassword = "1234";
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
        
        // 댓글 작성자 확인
        String checkQuery = "SELECT userId FROM comments WHERE commentId = ?";
        pstmt = conn.prepareStatement(checkQuery);
        pstmt.setInt(1, commentId);
        rs = pstmt.executeQuery();
        
        String commentUserId = null;
        if (rs.next()) {
            commentUserId = rs.getString("userId");
        }
        rs.close();
        pstmt.close();
        
        if (commentUserId == null) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "존재하지 않는 댓글입니다.");
            out.print(jsonResponse.toString());
            return;
        }
        
        if (!currentUserId.equals(commentUserId)) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "댓글을 삭제할 권한이 없습니다.");
            out.print(jsonResponse.toString());
            return;
        }
        
        // 댓글 삭제
        String deleteQuery = "DELETE FROM comments WHERE commentId = ?";
        pstmt = conn.prepareStatement(deleteQuery);
        pstmt.setInt(1, commentId);
        
        int result = pstmt.executeUpdate();
        pstmt.close();
        
        if (result > 0) {
            jsonResponse.put("success", true);
            jsonResponse.put("message", "댓글이 삭제되었습니다.");
        } else {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "댓글 삭제에 실패했습니다.");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        jsonResponse.put("success", false);
        jsonResponse.put("message", "서버 오류가 발생했습니다.");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
    
    out.print(jsonResponse.toString());
%>