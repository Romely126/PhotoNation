<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>로그인</title>
    <link rel="icon" href="img/favicon.ico">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <style>
        body {
            background-image: url('img/login_bg.jpg');
            background-size: cover;
            background-repeat: no-repeat;
            background-position: center;
            height: 100vh;
            margin: 0;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .container {
            background-color: rgba(255, 255, 255, 0.85); /* 배경 반투명 적용, 가독성 향상 */
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 0 15px rgba(0, 0, 0, 0.3);
            max-width: 450px;
            width: 100%;
        }

        .form-control {
            margin-bottom: 10px;
        }
        
        .error-message {
            color: #dc3545;
            margin-bottom: 15px;
            text-align: center;
        }
        
        .link-section {
            display: flex;
            justify-content: center;
            gap: 15px;
            margin-top: 20px;
        }
        
        .link-section a {
            color: #007bff;
            text-decoration: none;
            font-size: 14px;
        }
        
        .link-section a:hover {
            text-decoration: underline;
        }
        
        .divider {
            color: #6c757d;
            margin: 0 5px;
        }
    </style>
</head>
<body>
<div class="container mt-5">
    <h2 class="mb-4 text-center">Welcome to PhotoNation!</h2>
    <h2 class="mb-4 text-center">입국을 환영합니다.</h2>
    
    <% if(request.getParameter("error") != null) { %>
        <div class="error-message">
            <% if(request.getParameter("error").equals("1")) { %>
                아이디 또는 비밀번호가 일치하지 않습니다.
            <% } else { %>
                로그인 처리 중 오류가 발생했습니다.
            <% } %>
        </div>
    <% } %>
    
    <form action="loginProcess.jsp" method="post" id="loginForm">
        <!-- 아이디 -->
        <div class="mb-3">
            <label for="id" class="form-label">아이디</label>
            <input type="text" class="form-control" id="id" name="id" required>
        </div>

        <!-- 비밀번호 -->
        <div class="mb-3">
            <label for="password" class="form-label">비밀번호</label>
            <input type="password" class="form-control" id="password" name="password" required>
        </div>

        <!-- 로그인 버튼 -->
        <div class="d-flex justify-content-end mt-4">
            <button type="submit" class="btn btn-primary w-100">로그인</button>
        </div>

        <!-- 링크 섹션 -->
        <div class="link-section">
            <a href="signup.jsp">회원가입</a>
            <span class="divider">|</span>
            <a href="findId.jsp">아이디 찾기</a>
            <span class="divider">|</span>
            <a href="forgetPassword.jsp">비밀번호 변경</a>
        </div>
    </form>
</div>

<script>
    // 폼 제출 전 기본적인 유효성 검사
    $('#loginForm').on('submit', function(e) {
        const id = $('#id').val().trim();
        const pw = $('#password').val().trim();
        
        if(id === '' || pw === '') {
            e.preventDefault();
            alert('아이디와 비밀번호를 모두 입력해주세요.');
            return false;
        }
    });
</script>
</body>
</html>