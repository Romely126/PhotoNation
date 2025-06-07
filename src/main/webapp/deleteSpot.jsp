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
    
    // 관리자 권한 체크
    boolean isAdmin = "admin".equals(userId);
    
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/PhotoNation", "root", "1234");
    
    String sql;
    PreparedStatement pstmt;
    
    if (isAdmin) {
        // 관리자인 경우 모든 출사지 삭제 가능
        sql = "DELETE FROM photo_spots WHERE id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, spotId);
    } else {
        // 일반 사용자인 경우 본인이 작성한 출사지만 삭제 가능
        sql = "DELETE FROM photo_spots WHERE id = ? AND user_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, spotId);
        pstmt.setString(2, userId);
    }
    
    int result = pstmt.executeUpdate();
    
    pstmt.close();
    conn.close();
    
    if (result > 0) {
        if (isAdmin) {
            out.print("admin_delete_success");
        } else {
            out.print("success");
        }
    } else {
        out.print("not_found_or_unauthorized");
    }
    
} catch(Exception e) {
    out.print("error: " + e.getMessage());
    e.printStackTrace();
}
%>