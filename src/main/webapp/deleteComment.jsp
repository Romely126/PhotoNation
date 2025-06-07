<%@ page contentType="application/json; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="org.json.JSONObject" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");
    
    String commentIdStr = request.getParameter("commentId");
    String currentUserId = (String) session.getAttribute("userId");
    
    JSONObject result = new JSONObject();
    
    // 필수 파라미터 검증
    if (commentIdStr == null || currentUserId == null) {
        result.put("success", false);
        result.put("message", "잘못된 요청입니다.");
        out.print(result.toString());
        return;
    }
    
    int commentId = 0;
    try {
        commentId = Integer.parseInt(commentIdStr);
    } catch (NumberFormatException e) {
        result.put("success", false);
        result.put("message", "잘못된 댓글 ID입니다.");
        out.print(result.toString());
        return;
    }
    
    // 데이터베이스 연결 정보
    String jdbcUrl = "jdbc:mysql://localhost:3306/photonation?characterEncoding=utf8&serverTimezone=Asia/Seoul";
    String dbUser = "root";
    String dbPassword = "1234";
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);
        
        // 먼저 댓글 작성자 확인
        String checkSql = "SELECT userId FROM comments WHERE commentId = ?";
        pstmt = conn.prepareStatement(checkSql);
        pstmt.setInt(1, commentId);
        rs = pstmt.executeQuery();
        
        if (!rs.next()) {
            result.put("success", false);
            result.put("message", "댓글을 찾을 수 없습니다.");
            out.print(result.toString());
            return;
        }
        
        String commentUserId = rs.getString("userId");
        
        // 삭제 권한 확인 (댓글 작성자 본인 또는 관리자)
        if (!currentUserId.equals(commentUserId) && !"admin".equals(currentUserId)) {
            result.put("success", false);
            result.put("message", "댓글을 삭제할 권한이 없습니다.");
            out.print(result.toString());
            return;
        }
        
        // 리소스 정리 후 삭제 쿼리 실행
        rs.close();
        pstmt.close();
        
        // 댓글 삭제
        String deleteSql = "DELETE FROM comments WHERE commentId = ?";
        pstmt = conn.prepareStatement(deleteSql);
        pstmt.setInt(1, commentId);
        
        int deletedRows = pstmt.executeUpdate();
        
        if (deletedRows > 0) {
            result.put("success", true);
            result.put("message", "댓글이 삭제되었습니다.");
        } else {
            result.put("success", false);
            result.put("message", "댓글 삭제에 실패했습니다.");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        result.put("success", false);
        result.put("message", "댓글 삭제 중 오류가 발생했습니다: " + e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
    
    out.print(result.toString());
%>