<%@ page import="java.sql.*"%>
<%
// 세션에서 사용자 ID 확인
String sessionUserId = (String) session.getAttribute("userId");

if (sessionUserId != null) {
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        // DB 연결
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/photonation", "root", "1234");
        
        // 현재 세션 사용자의 actived 상태 확인
        String checkSQL = "SELECT actived FROM user_info WHERE id = ?";
        pstmt = conn.prepareStatement(checkSQL);
        pstmt.setString(1, sessionUserId);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            int actived = rs.getInt("actived");
            
            if (actived == 0) {
                // 계정이 비활성화된 경우 세션 무효화
                session.invalidate();
%>
<script>
	//이 부분 유니코드 이스케이프 시퀀스로 작성 -> 타 jsp에 해당 페이지를 import해서 사용하는데 화면 상단에 encodeType 명시 시 참조하는 jsp파일과 타입 명시가 중복됨.
	alert("\uC811\uADFC\uC774 \uC81C\uD55C\uB41C \uACC4\uC815\uC785\uB2C8\uB2E4. \uAD00\uB9AC\uC790\uC5D0\uAC8C \uBB38\uC758 \uBD80\uD0C1\uB4DC\uB9BD\uB2C8\uB2E4.");
    location.href = "login.jsp";
</script>
<%
                return;
            }
        } else {
            // 사용자가 DB에서 삭제된 경우 세션 무효화
            session.invalidate();
%>
<script>
    alert("유효하지 않은 계정입니다.");
    location.href = "login.jsp";
</script>
<%
            return;
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        // DB 연결 오류 시에도 세션 유지
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }
}
%>