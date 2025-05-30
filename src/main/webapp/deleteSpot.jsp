<%@ page import="java.sql.*" %>
<%@ page contentType="text/plain;charset=UTF-8" %>
<%
request.setCharacterEncoding("UTF-8");
response.setContentType("text/plain");
response.setCharacterEncoding("UTF-8");

String userId = (String) session.getAttribute("userId");
String spotIdStr = request.getParameter("spotId");

if(userId == null) {
    out.print("unauthorized");
    return;
}

if(spotIdStr == null || spotIdStr.trim().isEmpty()) {
    out.print("missing_spot_id");
    return;
}

try {
    int spotId = Integer.parseInt(spotIdStr);
    
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/PhotoNation", "root", "1234");
    
    // 본인이 작성한 출사지만 삭제할 수 있도록 체크
    String sql = "DELETE FROM photo_spots WHERE id = ? AND user_id = ?";
    PreparedStatement pstmt = conn.prepareStatement(sql);
    pstmt.setInt(1, spotId);
    pstmt.setString(2, userId);
    
    int result = pstmt.executeUpdate();
    
    pstmt.close();
    conn.close();
    
    out.print(result > 0 ? "success" : "not_found_or_unauthorized");
    
} catch(Exception e) {
    out.print("error: " + e.getMessage());
    e.printStackTrace();
}
%>