<%@ page import="java.sql.*, java.util.*" contentType="text/html;charset=UTF-8" %>
<%
// 파라미터 받기
String email = request.getParameter("email");
String emailCode = request.getParameter("emailCode");

// 파라미터 누락 시 처리
if (email == null || emailCode == null) {
    response.getWriter().write("missing_parameters");  // 파라미터가 누락된 경우
    return;
}

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    // DB 연결
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/photonation", "root", "1234");

    // 인증 코드 확인
    String sql = "SELECT verification_code, is_verified, expired_at FROM email_verifications WHERE email = ? ORDER BY created_at DESC LIMIT 1";
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, email);
    rs = pstmt.executeQuery();

    if (rs.next()) {
        String storedCode = rs.getString("verification_code");
        boolean isVerified = rs.getBoolean("is_verified");
        Timestamp expiredAt = rs.getTimestamp("expired_at");

        // 만료 시간 확인
        if (expiredAt.before(new Timestamp(System.currentTimeMillis()))) {
            response.getWriter().write("expired");
        } else if (isVerified) {
            response.getWriter().write("verified");
        } else if (storedCode != null && storedCode.trim().equals(emailCode.trim())) {
            // 인증 코드가 일치하면 인증 처리
            String updateSQL = "UPDATE email_verifications SET is_verified = true WHERE email = ? AND verification_code = ?";
            // 기존 pstmt 객체 닫기 (리소스 누수 방지)
            if (pstmt != null) {
                pstmt.close();
            }

            pstmt = conn.prepareStatement(updateSQL);
            pstmt.setString(1, email);
            pstmt.setString(2, emailCode);  // `storedCode`가 아닌 `emailCode`로 일치 여부 확인
            pstmt.executeUpdate();
            response.getWriter().write("success");
        } else {
            response.getWriter().write("invalid");
        }
    } else {
        // 이메일이 데이터베이스에 존재하지 않는 경우
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
