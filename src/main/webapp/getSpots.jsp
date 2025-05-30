<%@ page contentType="application/json; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="org.json.*" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
    
    String userId = (String) session.getAttribute("userId");
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        String url = "jdbc:mysql://localhost:3306/photonation?useUnicode=true&characterEncoding=utf8";
        String dbUser = "root";
        String dbPassword = "1234";
        
        conn = DriverManager.getConnection(url, dbUser, dbPassword);
        
        // 좋아요 수 기준으로 순위를 매기고, 사용자의 좋아요 상태도 함께 가져오기
        String sql =
    "SELECT s.*, " +
    "       RANK() OVER (ORDER BY s.like_count DESC, s.created_at ASC) as ranking, " +
    "       CASE WHEN l.user_id IS NOT NULL THEN 1 ELSE 0 END as user_liked " +
    "FROM photo_spots s " +
    "LEFT JOIN photo_spot_likes l ON s.id = l.spot_id AND l.user_id = ? " +
    "ORDER BY s.like_count DESC, s.created_at ASC";

        
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userId != null ? userId : "");
        rs = pstmt.executeQuery();
        
        JSONArray jsonArray = new JSONArray();
        
        while (rs.next()) {
            JSONObject spot = new JSONObject();
            spot.put("id", rs.getInt("id"));
            spot.put("title", rs.getString("title"));
            spot.put("description", rs.getString("description"));
            spot.put("latitude", rs.getDouble("latitude"));
            spot.put("longitude", rs.getDouble("longitude"));
            spot.put("user_id", rs.getString("user_id"));
            spot.put("like_count", rs.getInt("like_count"));
            spot.put("ranking", rs.getInt("ranking"));
            spot.put("user_liked", rs.getInt("user_liked") == 1);
            spot.put("created_at", rs.getTimestamp("created_at").toString());
            
            jsonArray.put(spot);
        }
        
        out.print(jsonArray.toString());
        
    } catch (Exception e) {
        e.printStackTrace();
        JSONObject error = new JSONObject();
        error.put("error", "데이터 로드 실패: " + e.getMessage());
        out.print(error.toString());
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