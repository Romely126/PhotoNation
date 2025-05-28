<%@ page import="java.sql.*, java.util.*" contentType="text/html;charset=UTF-8" %>
<%
// 파라미터 받기
String userId = request.getParameter("userId");
String userEmail = request.getParameter("userEmail");

// 파라미터 누락 시 처리
if (userId == null || userEmail == null) {
    response.getWriter().write("missing_parameters");
    return;
}

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    // DB 연결
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/photonation", "root", "1234");

    // 사용자 확인 - 아이디와 이메일이 일치하는지 확인
    String sql = "SELECT id FROM user_info WHERE id = ? AND email = ?";
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, userId);
    pstmt.setString(2, userEmail);
    rs = pstmt.executeQuery();

    if (rs.next()) {
        // 사용자가 존재하면 성공
        response.getWriter().write("success");
    } else {
        // 사용자가 존재하지 않거나 정보가 일치하지 않음
        response.getWriter().write("not_found");
    }

} catch (Exception e) {
    e.printStackTrace();
    response.getWriter().write("error");
} finally {
    // 리소스 정리
    try {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    } catch (SQLException ex) {
        ex.printStackTrace();
    }
}
%>