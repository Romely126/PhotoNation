<%@ page contentType="text/plain; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
    
    String userId = (String) session.getAttribute("userId");
    String spotIdStr = request.getParameter("spotId");
    
    // 로그인 확인
    if (userId == null || userId.trim().isEmpty()) {
        out.print("unauthorized");
        return;
    }
    
    // spotId 유효성 검사
    if (spotIdStr == null || spotIdStr.trim().isEmpty()) {
        out.print("error:잘못된 출사지 ID");
        return;
    }
    
    int spotId;
    try {
        spotId = Integer.parseInt(spotIdStr.trim());
    } catch (NumberFormatException e) {
        out.print("error:잘못된 출사지 ID 형식");
        return;
    }
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        // 데이터베이스 연결
        String url = "jdbc:mysql://localhost:3306/PhotoNation?useUnicode=true&characterEncoding=utf8";
        String dbUser = "root";
        String dbPassword = "1234";
        
        conn = DriverManager.getConnection(url, dbUser, dbPassword);
        conn.setAutoCommit(false);
        
        // 현재 좋아요 상태 확인
        String checkSql = "SELECT id FROM photo_spot_likes WHERE spot_id = ? AND user_id = ?";
        pstmt = conn.prepareStatement(checkSql);
        pstmt.setInt(1, spotId);
        pstmt.setString(2, userId);
        rs = pstmt.executeQuery();
        
        boolean isLiked = rs.next();
        
        if (pstmt != null) pstmt.close();
        if (rs != null) rs.close();
        
        if (isLiked) {
            // 좋아요 취소
            String deleteSql = "DELETE FROM photo_spot_likes WHERE spot_id = ? AND user_id = ?";
            pstmt = conn.prepareStatement(deleteSql);
            pstmt.setInt(1, spotId);
            pstmt.setString(2, userId);
            pstmt.executeUpdate();
        } else {
            // 좋아요 추가
            String insertSql = "INSERT INTO photo_spot_likes (spot_id, user_id) VALUES (?, ?)";
            pstmt = conn.prepareStatement(insertSql);
            pstmt.setInt(1, spotId);
            pstmt.setString(2, userId);
            pstmt.executeUpdate();
        }
        
        if (pstmt != null) pstmt.close();
        
        // 업데이트된 좋아요 수 가져오기
        String countSql = "SELECT like_count FROM photo_spots WHERE id = ?";
        pstmt = conn.prepareStatement(countSql);
        pstmt.setInt(1, spotId);
        rs = pstmt.executeQuery();
        
        int likeCount = 0;
        if (rs.next()) {
            likeCount = rs.getInt("like_count");
        }
        
        // 수동으로 좋아요 수 업데이트 (트리거가 없는 경우를 대비)
        if (pstmt != null) pstmt.close();
        if (rs != null) rs.close();
        
        String updateCountSql = "UPDATE photo_spots SET like_count = (SELECT COUNT(*) FROM photo_spot_likes WHERE spot_id = ?) WHERE id = ?";
        pstmt = conn.prepareStatement(updateCountSql);
        pstmt.setInt(1, spotId);
        pstmt.setInt(2, spotId);
        pstmt.executeUpdate();
        
        // 업데이트된 좋아요 수 다시 가져오기
        if (pstmt != null) pstmt.close();
        
        String finalCountSql = "SELECT like_count FROM photo_spots WHERE id = ?";
        pstmt = conn.prepareStatement(finalCountSql);
        pstmt.setInt(1, spotId);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            likeCount = rs.getInt("like_count");
        }
        
        conn.commit();
        
        // JSON 형태로 결과 반환
        out.print("{\"success\":true,\"liked\":" + (!isLiked) + ",\"likeCount\":" + likeCount + "}");
        
    } catch (SQLException e) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        e.printStackTrace();
        out.print("error:데이터베이스 오류 - " + e.getMessage());
    } catch (Exception e) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        e.printStackTrace();
        out.print("error:시스템 오류 - " + e.getMessage());
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>