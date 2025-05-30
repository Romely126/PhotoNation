<%@ page import="java.sql.*, java.util.*, org.json.*" %>
<%@ page contentType="application/json;charset=UTF-8" %>
<%
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");

JSONArray spots = new JSONArray();

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/PhotoNation", "root", "1234");
    
    String sql = "SELECT id, title, description, latitude, longitude FROM photo_spots ORDER BY id DESC";
    PreparedStatement pstmt = conn.prepareStatement(sql);
    ResultSet rs = pstmt.executeQuery();
    
    while(rs.next()) {
        JSONObject spot = new JSONObject();
        spot.put("id", rs.getInt("id"));
        spot.put("title", rs.getString("title"));
        spot.put("description", rs.getString("description"));
        spot.put("latitude", rs.getDouble("latitude"));
        spot.put("longitude", rs.getDouble("longitude"));
        spots.put(spot);
    }
    
    rs.close();
    pstmt.close();
    conn.close();
} catch(Exception e) {
    e.printStackTrace();
    // 에러 발생 시 빈 배열 반환
    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
}

out.print(spots.toString());
%>