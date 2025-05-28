<%@ page import="java.sql.*, java.security.MessageDigest" contentType="text/html;charset=UTF-8" %>
<%
// 파라미터 받기
String userId = request.getParameter("userId");
String email = request.getParameter("email");
String newPassword = request.getParameter("newPassword");

// 파라미터 누락 시 처리
if (userId == null || email == null || newPassword == null) {
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

    // 먼저 해당 이메일이 인증되었는지 확인
    String verifySQL = "SELECT is_verified FROM email_verifications WHERE email = ? AND is_verified = true ORDER BY created_at DESC LIMIT 1";
    pstmt = conn.prepareStatement(verifySQL);
    pstmt.setString(1, email);
    rs = pstmt.executeQuery();

    if (!rs.next() || !rs.getBoolean("is_verified")) {
        response.getWriter().write("email_not_verified");
        return;
    }

    // 리소스 정리
    if (rs != null) rs.close();
    if (pstmt != null) pstmt.close();

    // 비밀번호 해시화 (MD5 사용 - 실제 운영에서는 더 안전한 방식 권장)
    MessageDigest md = MessageDigest.getInstance("MD5");
    md.update(newPassword.getBytes());
    byte[] digest = md.digest();
    StringBuilder sb = new StringBuilder();
    for (byte b : digest) {
        sb.append(String.format("%02x", b));
    }
    String hashedPassword = sb.toString();

    // 비밀번호 업데이트
    String updateSQL = "UPDATE user_info SET password = ? WHERE id = ? AND email = ?";
    pstmt = conn.prepareStatement(updateSQL);
    pstmt.setString(1, hashedPassword);
    pstmt.setString(2, userId);
    pstmt.setString(3, email);
    
    int result = pstmt.executeUpdate();
    
    if (result > 0) {
        // 비밀번호 변경 성공 시 해당 이메일의 인증 상태를 초기화 (보안을 위해)
        if (pstmt != null) pstmt.close();
        
        String resetVerificationSQL = "UPDATE email_verifications SET is_verified = false WHERE email = ?";
        pstmt = conn.prepareStatement(resetVerificationSQL);
        pstmt.setString(1, email);
        pstmt.executeUpdate();
        
        response.getWriter().write("success");
    } else {
        response.getWriter().write("update_failed");
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