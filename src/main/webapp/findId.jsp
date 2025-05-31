<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>아이디 찾기</title>
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
            background-color: rgba(255, 255, 255, 0.9);
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 0 15px rgba(0, 0, 0, 0.3);
            max-width: 500px;
            width: 100%;
        }

        .form-control {
            margin-bottom: 10px;
        }
        
        .step {
            display: none;
        }
        
        .step.active {
            display: block;
        }
        
        .step-indicator {
            display: flex;
            justify-content: center;
            margin-bottom: 30px;
        }
        
        .step-item {
            padding: 8px 16px;
            margin: 0 5px;
            border-radius: 20px;
            background-color: #e9ecef;
            color: #6c757d;
            font-size: 14px;
        }
        
        .step-item.active {
            background-color: #007bff;
            color: white;
        }
        
        .step-item.completed {
            background-color: #28a745;
            color: white;
        }

        .success-message {
            background-color: #d4edda;
            border: 1px solid #c3e6cb;
            color: #155724;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
        }

        .found-id {
            font-size: 1.2em;
            font-weight: bold;
            color: #007bff;
            margin: 10px 0;
        }
    </style>
</head>
<body>
<div class="container">
    <h2 class="mb-4 text-center">아이디 찾기</h2>
    
    <!-- 단계 표시기 -->
    <div class="step-indicator">
        <div class="step-item active" id="step1-indicator">1. 사용자 정보 입력</div>
        <div class="step-item" id="step2-indicator">2. 이메일 인증</div>
        <div class="step-item" id="step3-indicator">3. 아이디 확인</div>
    </div>

    <!-- 1단계: 사용자 정보 입력 -->
    <div class="step active" id="step1">
        <div class="alert alert-info">
            <i class="fas fa-info-circle"></i> 가입 시 등록한 이름과 이메일을 입력해주세요.
        </div>
        <form id="userInfoForm">
            <div class="mb-3">
                <label for="userName" class="form-label">이름</label>
                <input type="text" class="form-control" id="userName" name="userName" required>
            </div>
            <div class="mb-3">
                <label for="userEmail" class="form-label">이메일</label>
                <input type="email" class="form-control" id="userEmail" name="userEmail" required>
            </div>
            <div class="d-flex justify-content-between">
                <a href="login.jsp" class="btn btn-secondary">로그인으로 돌아가기</a>
                <button type="submit" class="btn btn-primary">다음 단계</button>
            </div>
        </form>
    </div>

    <!-- 2단계: 이메일 인증 -->
    <div class="step" id="step2">
        <div class="alert alert-success">
            <strong id="verifyEmail"></strong>로 인증 코드를 발송했습니다.
        </div>
        <form id="emailVerifyForm">
            <div class="mb-3">
                <label class="form-label">이메일 인증</label>
                <div class="input-group mb-2">
                    <input type="text" class="form-control" id="emailCodeInput" placeholder="인증코드 입력" required>
                    <button type="button" class="btn btn-outline-primary" onclick="verifyEmailCode()">인증 확인</button>
                </div>
                <button type="button" class="btn btn-secondary btn-sm" onclick="resendEmailCode()">인증 코드 재발송</button>
                <div id="emailStatus" class="form-text mt-1"></div>
            </div>
            <div class="d-flex justify-content-between">
                <button type="button" class="btn btn-secondary" onclick="goToStep(1)">이전</button>
                <button type="submit" class="btn btn-primary" disabled id="nextToStep3">아이디 찾기</button>
            </div>
        </form>
    </div>

    <!-- 3단계: 아이디 확인 -->
    <div class="step" id="step3">
        <div class="success-message">
            <h4>아이디를 찾았습니다!</h4>
            <div class="found-id" id="foundId"></div>
            <div class="d-flex justify-content-center gap-2 mt-4">
                <a href="login.jsp" class="btn btn-primary">로그인하기</a>
                <a href="forgetPassword.jsp" class="btn btn-outline-secondary">비밀번호 변경</a>
            </div>
        </div>
    </div>
</div>

<script>
let currentStep = 1;
let verifiedEmail = '';
let verifiedName = '';
let isEmailVerified = false;

// 단계 이동 함수
function goToStep(step) {
    // 현재 단계 숨기기
    $('.step').removeClass('active');
    $('.step-item').removeClass('active');
    
    // 새 단계 보이기
    $('#step' + step).addClass('active');
    $('#step' + step + '-indicator').addClass('active');
    
    // 완료된 단계 표시
    for(let i = 1; i < step; i++) {
        $('#step' + i + '-indicator').addClass('completed');
    }
    
    currentStep = step;
}

// 1단계: 사용자 정보 확인
$('#userInfoForm').on('submit', function(e) {
    e.preventDefault();
    
    const userName = $('#userName').val().trim();
    const userEmail = $('#userEmail').val().trim();
    
    if(userName === '' || userEmail === '') {
        alert('이름과 이메일을 모두 입력해주세요.');
        return;
    }
    
    // 사용자 확인 AJAX
    $.ajax({
        type: "POST",
        url: "verifyUserForId.jsp",
        data: { userName: userName, userEmail: userEmail },
        success: function(response) {
            if(response.trim() === "success") {
                verifiedEmail = userEmail;
                verifiedName = userName;
                $('#verifyEmail').text(userEmail);
                
                // 이메일 인증 코드 자동 발송
                sendEmailVerificationForId();
                goToStep(2);
            } else if(response.trim() === "not_found") {
                alert('입력하신 이름과 이메일이 일치하는 회원 정보가 없습니다.');
            } else {
                alert('사용자 확인 중 오류가 발생했습니다.');
            }
        },
        error: function() {
            alert('서버 오류가 발생했습니다.');
        }
    });
});

// 2단계: 이메일 인증 코드 발송
function sendEmailVerificationForId() {
    $.ajax({
        type: "POST",
        url: "sendVerificationEmail.jsp",
        data: { email: verifiedEmail },
        success: function(response) {
            if (response.trim() === "success") {
                $('#emailStatus').text("인증 코드가 이메일로 발송되었습니다.").css("color", "green");
            } else {
                $('#emailStatus').text("이메일 발송에 실패했습니다. 다시 시도해 주세요.").css("color", "red");
            }
        },
        error: function() {
            $('#emailStatus').text("서버 오류로 인해 이메일 발송에 실패했습니다.").css("color", "red");
        }
    });
}

// 인증 코드 재발송
function resendEmailCode() {
    sendEmailVerificationForId();
}

// 이메일 인증 코드 확인
function verifyEmailCode() {
    const emailCode = $('#emailCodeInput').val().trim();
    
    if (emailCode === "") {
        alert("인증 코드를 입력해 주세요.");
        return;
    }

    $.ajax({
        type: "POST",
        url: "verifyEmailCode.jsp",
        data: { email: verifiedEmail, emailCode: emailCode },
        success: function(response) {
            if (response.trim() === "success") {
                alert("인증이 완료되었습니다.");
                isEmailVerified = true;
                $('#nextToStep3').prop('disabled', false);
                $('#emailStatus').text("이메일 인증이 완료되었습니다.").css("color", "green");
            } else if (response.trim() === "expired") {
                alert("인증 코드가 만료되었습니다. 다시 시도해 주세요.");
            } else if (response.trim() === "verified") {
                alert("이미 인증된 이메일입니다.");
                isEmailVerified = true;
                $('#nextToStep3').prop('disabled', false);
            } else if (response.trim() === "invalid") {
                alert("잘못된 인증 코드입니다. 다시 시도해 주세요.");
            } else if (response.trim() === "not_found") {
                alert("해당 이메일에 대한 인증 정보가 없습니다.");
            } else {
                alert("알 수 없는 오류가 발생했습니다.");
            }
        },
        error: function() {
            alert("서버 오류로 인증을 확인할 수 없습니다.");
        }
    });
}

// 2단계 폼 제출 - 아이디 찾기
$('#emailVerifyForm').on('submit', function(e) {
    e.preventDefault();
    if(isEmailVerified) {
        findUserIdProcess();
    } else {
        alert('이메일 인증을 완료해주세요.');
    }
});

// 아이디 찾기 처리
function findUserIdProcess() {
    $.ajax({
        type: "POST",
        url: "findIdProcess.jsp",
        data: { 
            userName: verifiedName, 
            userEmail: verifiedEmail 
        },
        success: function(response) {
            const result = response.trim();
            if(result.startsWith("success:")) {
                const foundUserId = result.split(":")[1];
                $('#foundId').text(foundUserId);
                goToStep(3);
            } else if(result === "not_found") {
                alert('일치하는 회원 정보를 찾을 수 없습니다.');
            } else {
                alert('아이디 찾기 처리 중 오류가 발생했습니다.');
            }
        },
        error: function() {
            alert('서버 오류가 발생했습니다.');
        }
    });
}
</script>
</body>
</html>