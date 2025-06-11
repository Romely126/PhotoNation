<%@ page import="java.sql.*, java.util.*" contentType="text/html;charset=UTF-8" %>
<%
// 파라미터 받기
String userName = request.getParameter("userName");
String userEmail = request.getParameter("userEmail");

// 파라미터 누락 시 처리
if (userName == null || userEmail == null) {
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

    // 해당 이메일이 인증되었는지 확인
    String verifySQL = "SELECT is_verified FROM email_verifications WHERE email = ? AND is_verified = true ORDER BY created_at DESC LIMIT 1";
    pstmt = conn.prepareStatement(verifySQL);
    pstmt.setString(1, userEmail);
    rs = pstmt.executeQuery();

    if (!rs.next() || !rs.getBoolean("is_verified")) {
        response.getWriter().write("email_not_verified");
        return;
    }

    // 리소스 정리
    if (rs != null) rs.close();
    if (pstmt != null) pstmt.close();

    // 사용자 아이디 조회
    String sql = "SELECT id, nickname FROM user_info WHERE name = ? AND email = ?";
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, userName);
    pstmt.setString(2, userEmail);
    rs = pstmt.executeQuery();

    if (rs.next()) {
        String foundId = rs.getString("id");
        String nickname = rs.getString("nickname");

        // 이메일 전송 부분 삭제 — 바로 성공 결과 반환
        response.getWriter().write("success:" + foundId);

    } else {
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
