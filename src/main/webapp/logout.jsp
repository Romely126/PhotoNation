<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    // 세션 무효화
    session.invalidate();
%>
<script>
    alert("로그아웃 되었습니다.");
    location.href = "main.jsp";
</script> 