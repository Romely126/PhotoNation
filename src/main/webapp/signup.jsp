<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>회원가입</title>
    <link rel="icon" href="img/favicon.ico">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <style>
        #confirmPassword:invalid {
            border-color: red;
        }
        #confirmPassword.valid {
            border-color: green !important;
        }
        #confirmPassword.invalid {
            border-color: red !important;
        }

        /* 폼 전체 너비를 제한 */
        .container {
            max-width: 600px;
        }

        /* 전화번호 입력 칸 조정 */
        .phone-group select,
        .phone-group input {
            max-width: 120px; /* 최대 너비 설정 */
        }

        /* 폼 요소 간의 여백 추가 */
        .form-control {
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
<div class="container mt-5">
    <h2 class="mb-4">PhotoNation 입국신청서</h2>
    <form action="signupProcess.jsp" method="post" enctype="multipart/form-data" id="signupForm">
        <!-- 아이디 -->
        <div class="mb-3">
            <label for="id" class="form-label">아이디</label>
            <div class="input-group">
                <input type="text" class="form-control" id="id" name="id" required>
                <button type="button" class="btn btn-secondary" onclick="checkDuplicate()" style="height: 38px;">중복 확인</button>
            </div>
            <div id="idCheckResult" class="form-text"></div>
        </div>

        <!-- 비밀번호 -->
<div class="mb-3">
    <label for="password" class="form-label">비밀번호</label>
    <input type="password" class="form-control" id="password" name="password" required>
    <!-- 강도 게이지 -->
    <div id="password-strength" class="progress mt-2" style="height: 8px;">
        <div id="password-strength-bar" class="progress-bar" role="progressbar"
             style="width: 0%;" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"></div>
    </div>
    <!-- 텍스트 표시 -->
    <div id="password-strength-text" class="mt-1 small"></div>
</div>
<!-- 비밀번호 확인 -->
<div class="mb-3">
    <label for="confirmPassword" class="form-label">비밀번호 확인</label>
    <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
</div>

        
<!-- 닉네임 -->
<div class="mb-3">
            <label for="nickname" class="form-label">닉네임</label>
            <div class="input-group">
                <input type="text" class="form-control" id="nickname" name="nickname" required>
                <button type="button" class="btn btn-secondary" onclick="checkNickname()" style="height: 38px;">중복 확인</button>
            </div>
            <div id="nicknameCheckResult" class="form-text"></div>
        </div>

        <!-- 이름 -->
        <div class="mb-3">
            <label for="name" class="form-label">이름</label>
            <input type="text" class="form-control" id="name" name="name" required>
        </div>

        <!-- 성별 -->
        <div class="mb-3">
            <label class="form-label">성별</label><br>
            <div class="form-check form-check-inline">
                <input class="form-check-input" type="radio" name="gender" id="male" value="남성" required>
                <label class="form-check-label" for="male">남성</label>
            </div>
            <div class="form-check form-check-inline">
                <input class="form-check-input" type="radio" name="gender" id="female" value="여성">
                <label class="form-check-label" for="female">여성</label>
            </div>
        </div>

        <!-- 생년월일 -->
        <div class="mb-3">
            <label for="birth" class="form-label">생년월일</label>
            <input type="date" class="form-control" id="birth" name="birth" required>
        </div>

<!-- 전화번호 -->
<div class="mb-3">
    <label for="phone" class="form-label">전화번호</label>
    <div class="d-flex">
        <select class="form-select" id="phonePrefix" name="phonePrefix" style="width: 100px; height: 38px; margin-right: 10px; -webkit-appearance: none; -moz-appearance: none; appearance: none; padding-right: 25px;">
            <option value="010">010</option>
            <option value="011">011</option>
            <option value="019">019</option>
            <option value="012">012</option>
        </select>
        <input type="text" class="form-control" id="phoneMid" name="phoneMid" maxlength="4" style="width: 100px; height: 38px; margin-right: 10px;" required>
        <input type="text" class="form-control" id="phoneEnd" name="phoneEnd" maxlength="4" style="width: 100px; height: 38px;" required>
    </div>
</div>



        <!-- 이메일 -->
<div class="mb-3">
    <label for="email" class="form-label">이메일</label>
    <div class="d-flex align-items-center">
        <input type="text" class="form-control me-1" id="emailId" name="emailId" placeholder="이메일 아이디" required style="width: 150px; height: 38px;">
        <span class="me-1" style="margin-top: 2px;">@</span>
        <input type="text" class="form-control me-1" id="emailDomain" name="emailDomain" placeholder="도메인" required style="width: 130px; height: 38px;">
        <select class="form-select" id="emailSelect" style="width: 170px; height: 38px;">
            <option value="">직접 입력</option>
            <option value="gmail.com">gmail.com</option>
            <option value="naver.com">naver.com</option>
            <option value="daum.net">daum.net</option>
            <option value="hanmail.net">hanmail.net</option>
            <option value="outlook.com">outlook.com</option>
        </select>
    </div>
</div>
			<!-- 이메일 인증 -->
        <div class="mb-3">
            <label class="form-label">이메일 인증</label>
            <div class="input-group mb-2">
                <input type="text" class="form-control" id="emailCodeInput" placeholder="인증코드 입력" style="width: 50%;">
                <button type="button" class="btn btn-outline-primary" onclick="verifyEmailCode()">인증 확인</button>
            </div>
            <button type="button" class="btn btn-secondary" onclick="sendEmailVerificationAJAX()" style="margin-top: 5px;">인증 코드 발송</button>
            <div id="emailStatus" class="form-text mt-1"></div>
            <input type="hidden" id="isEmailVerified" name="isEmailVerified" value="false">
        </div>

        <!-- 주소 -->
        <div class="mb-3">
            <label for="post" class="form-label">우편번호</label>
            <div class="input-group mb-2">
                <input type="text" class="form-control" id="post" name="post" readonly>
                <button type="button" class="btn btn-outline-secondary" onclick="execDaumPostcode()" style="height: 38px;">주소 찾기</button>
            </div>
            <input type="text" class="form-control mb-2" id="address" name="address" placeholder="기본주소" readonly>
            <input type="text" class="form-control" id="detailAddress" name="detailAddress" placeholder="상세주소" required>
        </div>

        <!-- 프로필 사진 업로드 -->
        <div class="mb-3">
            <label for="profileImg" class="form-label">프로필 사진</label>
            <div class="text-center mb-2">
                <img id="profilePreview" src="img/default_profile.jpg" alt="프로필 미리보기" 
                     style="width: 150px; height: 150px; border-radius: 50%; object-fit: cover;">
            </div>
            <input type="file" class="form-control" id="profileImg" name="profileImg" 
                   accept="image/*" onchange="previewImage(this)">
        </div>

        <!-- 회원가입 버튼 영역 -->
<div class="d-flex justify-content-end mt-4">
  <button type="submit" class="btn btn-primary">회원가입</button>
</div>

    </form>
</div>

<script>
    // 아이디 중복 확인 AJAX
    function checkDuplicate() {
        const id = $('#id').val();
        if (id.trim() === '') {
            $('#idCheckResult').text("아이디를 입력하세요.").css("color", "red");
            return;
        }

        $.post("checkDuplicate.jsp", { id: id }, function(response) {
            if (response.trim() === "ok") {
                $('#idCheckResult').text("사용 가능한 아이디입니다.").css("color", "green");
            } else {
                $('#idCheckResult').text("이미 사용 중인 아이디입니다.").css("color", "red");
            }
        });
    }

    //닉네임 중복 확인 AJAX
    function checkNickname() {
    const nickname = $('#nickname').val();
    if (nickname.trim() === '') {
        $('#nicknameCheckResult').text("닉네임을 입력하세요.").css("color", "red");
        return;
    }

    $.post("checkNickname.jsp", { nickname: nickname }, function(response) {
        if (response.trim() === "ok") {
            $('#nicknameCheckResult').text("사용 가능한 닉네임입니다.").css("color", "green");
        } else {
            $('#nicknameCheckResult').text("이미 사용 중인 닉네임입니다.").css("color", "red");
        }
    });
}
	
    // 비밀번호 강도 체크
$('#password').on('input', function () {
    const password = $('#password').val();
    const bar = $('#password-strength-bar');
    const text = $('#password-strength-text');

    let strength = 0;

    if (password.length >= 6) strength++;
    if (/[!@#$%^&*(),.?":{}|<>]/.test(password)) strength++; // 특수문자 포함
    if (password.length >= 8 && /[A-Za-z]/.test(password) && /\d/.test(password)) strength++; // 복합 조건

    // 초기화
    bar.removeClass().addClass('progress-bar');

    if (strength === 0 || strength === 1) {
        bar.css({ width: '33%', backgroundColor: '#dc3545' }); // 빨강
        text.text('비밀번호 강도: 약함').css('color', '#dc3545');
    } else if (strength === 2) {
        bar.css({ width: '66%', backgroundColor: '#198754' }); // 초록
        text.text('비밀번호 강도: 보통').css('color', '#198754');
    } else if (strength === 3) {
        bar.css({ width: '100%', backgroundColor: '#6f42c1' }); // 보라색
        text.text('비밀번호 강도: 강함').css('color', '#6f42c1');
    } else {
        bar.css({ width: '0%' });
        text.text('');
    }
});


    // 비밀번호 확인 실시간 검사
$('#confirmPassword, #password').on('input', function() {
    const pw = $('#password').val();
    const confirmPw = $('#confirmPassword').val();

    if (confirmPw === '') {
        $('#confirmPassword').removeClass('valid invalid');
    } else if (pw === confirmPw) {
        $('#confirmPassword').addClass('valid').removeClass('invalid');
    } else {
        $('#confirmPassword').addClass('invalid').removeClass('valid');
    }
});

    
    //도메인 자동 채우기
    $(document).ready(function () {
        $('#emailSelect').on('change', function () {
            const selected = $(this).val();
            $('#emailDomain').val(selected);
            if (selected === '') {
                $('#emailDomain').prop('readonly', false).val('');
            } else {
                $('#emailDomain').prop('readonly', true);
            }
        });
    });
    
    // 유효성 검사 실시간 적용
    $('#signupForm').on('submit', function(e) {
    const pw = $('#password').val();
    const confirmPw = $('#confirmPassword').val();

    if (pw !== confirmPw) {
        alert('비밀번호가 일치하지 않습니다.');
        e.preventDefault(); // 폼 제출 중단
    }
});
    
    function getFullEmail() {
        return $('#emailId').val() + '@' + ($('#emailSelect').val() || $('#emailDomain').val());
    }

    
</script>


<script>
//이메일 주소 합치기
function getFullEmail() {
    return $('#emailId').val() + '@' + ($('#emailSelect').val() || $('#emailDomain').val());
}

// 이메일 인증 코드 발송 AJAX
function sendEmailVerificationAJAX() {
    const email = getFullEmail();
    $.ajax({
        type: "POST",
        url: "sendVerificationEmail.jsp",  // 서버에서 이메일을 발송하는 JSP 파일
        data: { email: email },
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

// 이메일 인증 코드 확인 AJAX
function verifyEmailCode() {
    const emailCode = $('#emailCodeInput').val();
    const email = getFullEmail();

    // 입력값 체크
    if (emailCode.trim() === "") {
        alert("인증 코드를 입력해 주세요.");
        return;
    }

    console.log("전송되는 데이터: ", { email: email, emailCode: emailCode });  // 데이터 확인

    $.ajax({
        type: "POST",
        url: "verifyEmailCode.jsp",  // 서버에서 인증 코드를 확인하는 JSP 파일
        data: { email: email, emailCode: emailCode },  // 파라미터 확인
        success: function(response) {
            console.log("서버 응답: ", response);  // 서버 응답을 콘솔에 출력
            if (response.trim() === "success") {
                alert("인증이 완료되었습니다.");
            } else if (response.trim() === "expired") {
                alert("인증 코드가 만료되었습니다. 다시 시도해 주세요.");
            } else if (response.trim() === "verified") {
                alert("이미 인증된 이메일입니다.");
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

</script>
<script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script>
function execDaumPostcode() {
    new daum.Postcode({
        oncomplete: function(data) {
            // data.zonecode: 우편번호
            // data.roadAddress or data.jibunAddress: 기본 주소
            document.getElementById('post').value = data.zonecode;
            document.getElementById('address').value = data.roadAddress || data.jibunAddress;
            document.getElementById('detailAddress').focus();
        }
    }).open();
}


</script>

<script>
    // 이미지 미리보기 함수
    function previewImage(input) {
        if (input.files && input.files[0]) {
            var reader = new FileReader();
            reader.onload = function(e) {
                $('#profilePreview').attr('src', e.target.result);
            }
            reader.readAsDataURL(input.files[0]);
        }
    }
</script>
</body>
</html>
