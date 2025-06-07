<%@ page import="java.sql.*, java.security.MessageDigest" contentType="text/html;charset=UTF-8" %>
<%
// 파라미터 받기
String userId = request.getParameter("id");
String password = request.getParameter("password");

// 파라미터 누락 시 처리
if (userId == null || password == null || userId.trim().isEmpty() || password.trim().isEmpty()) {
    response.sendRedirect("login.jsp?error=2");
    return;
}

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    // 입력받은 비밀번호를 MD5로 해시화
    MessageDigest md = MessageDigest.getInstance("MD5");
    md.update(password.getBytes());
    byte[] digest = md.digest();
    StringBuilder sb = new StringBuilder();
    for (byte b : digest) {
        sb.append(String.format("%02x", b));
    }
    String hashedPassword = sb.toString();

    // DB 연결
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/photonation", "root", "1234");

    // 사용자 인증 (해시화된 비밀번호로 비교) + actived 상태 확인
    String loginSQL = "SELECT id, name, nickname, email, actived FROM user_info WHERE id = ? AND password = ?";
    pstmt = conn.prepareStatement(loginSQL);
    pstmt.setString(1, userId);
    pstmt.setString(2, hashedPassword);
    rs = pstmt.executeQuery();

    if (rs.next()) {
        // 계정 활성화 상태 확인
        int actived = rs.getInt("actived");
        
        if (actived == 0) {
            // 계정이 비활성화된 경우
%>
<script>
    alert("접근이 제한된 계정입니다. 관리자에게 문의 부탁드립니다.");
    location.href = "login.jsp";
</script>
<%
            return;
        }
        
        // 로그인 성공 - 세션에 사용자 정보 저장
        session.setAttribute("userId", rs.getString("id"));
        session.setAttribute("userName", rs.getString("name"));
        session.setAttribute("userNickname", rs.getString("nickname")); // 실제 닉네임 사용
        session.setAttribute("userEmail", rs.getString("email"));
        
        // 메인 페이지로 리다이렉트 (또는 원하는 페이지로)
        response.sendRedirect("main.jsp"); // 또는 index.jsp, dashboard.jsp 등
    } else {
        // 로그인 실패
        response.sendRedirect("login.jsp?error=1");
    }

} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("login.jsp?error=2");
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