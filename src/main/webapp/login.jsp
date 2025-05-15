<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>로그인</title>
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
    </style>
</head>
<body>
<div class="container mt-5">
    <h2 class="mb-4 text-center">Welcome to PhotoNation!</h2>
    <h2 class="mb-4 text-center">입국을 환영합니다.</h2>
    <form id="loginForm">
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

        <!-- 회원가입/비밀번호 찾기 링크 -->
        <div class="text-center mt-3">
            <a href="signup.jsp">회원가입</a> | <a href="forgotPassword.jsp">비밀번호 변경</a>
        </div>
    </form>
</div>

<script>
    // 간단한 클라이언트 측 검증 (아이디/비밀번호가 미리 정해진 값일 경우에만 통과)
    $('#loginForm').on('submit', function(e) {
        e.preventDefault(); // 기본 제출 막기

        const id = $('#id').val();
        const pw = $('#password').val();

        // 예시: 정해진 테스트 계정 (실제 서버 검증은 loginProcess.jsp에서 수행 예정)
        const validId = "testuser";
        const validPw = "1234";

        if (id === validId && pw === validPw) {
            this.submit(); // 조건 만족 시 폼 제출
        } else {
            alert("아이디가 존재하지 않거나 비밀번호가 틀립니다.");
        }
    });
</script>
</body>
</html>
