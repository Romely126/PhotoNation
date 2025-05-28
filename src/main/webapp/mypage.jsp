<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.time.*" %>
<%@ page import="java.time.temporal.ChronoUnit" %>
<%
    String userId = (String) session.getAttribute("userId");
    String userNickname = (String) session.getAttribute("userNickname");
    
    if(userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // 사용자 정보 조회
    String name = "";
    String sex = "";
    Date birthday = null;
    String phoneNum = "";
    String email = "";
    String postNum = "";
    String address = "";
    Date joinDate = null;
    
    // 통계 정보
    int postCount = 0;
    int commentCount = 0;
    int totalLikes = 0;
    long daysSinceJoin = 0;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/photonation?useUnicode=true&characterEncoding=utf8", "root", "1234");
        
        // 기본 사용자 정보 조회 (detailAddress 제거)
        String userSql = "SELECT name, sex, birthday, phoneNum, email, postNum, address FROM user_info WHERE id = ?";
        PreparedStatement userStmt = conn.prepareStatement(userSql);
        userStmt.setString(1, userId);
        ResultSet userRs = userStmt.executeQuery();
        
        if(userRs.next()) {
            name = userRs.getString("name");
            sex = userRs.getString("sex");
            birthday = userRs.getDate("birthday");
            phoneNum = userRs.getString("phoneNum");
            email = userRs.getString("email");
            postNum = userRs.getString("postNum");
            address = userRs.getString("address");
            
            // 가입일 계산
            String joinDateSql = "SELECT joinDate FROM user_info WHERE id = ?";
			PreparedStatement joinStmt = conn.prepareStatement(joinDateSql);
			joinStmt.setString(1, userId);
			ResultSet joinRs = joinStmt.executeQuery();
			if(joinRs.next()) {
    			Timestamp joinTimestamp = joinRs.getTimestamp("joinDate");
    			if (joinTimestamp != null) {
        			LocalDate join = joinTimestamp.toLocalDateTime().toLocalDate();
        			LocalDate now = LocalDate.now();
        			daysSinceJoin = ChronoUnit.DAYS.between(join, now) + 1;	//가입일부터 1일차
    			}
			}
        }
        
        // 작성 글 개수
        String postSql = "SELECT COUNT(*) as count FROM posts WHERE userId = ?";
        PreparedStatement postStmt = conn.prepareStatement(postSql);
        postStmt.setString(1, userId);
        ResultSet postRs = postStmt.executeQuery();
        if(postRs.next()) {
            postCount = postRs.getInt("count");
        }
        
        // 댓글 수
        String commentSql = "SELECT COUNT(*) as count FROM comments WHERE userId = ?";
        PreparedStatement commentStmt = conn.prepareStatement(commentSql);
        commentStmt.setString(1, userId);
        ResultSet commentRs = commentStmt.executeQuery();
        if(commentRs.next()) {
            commentCount = commentRs.getInt("count");
        }
        
        // 받은 총 좋아요 수
        String likeSql = "SELECT SUM(likeCount) as totalLikes FROM posts WHERE userId = ?";
        PreparedStatement likeStmt = conn.prepareStatement(likeSql);
        likeStmt.setString(1, userId);
        ResultSet likeRs = likeStmt.executeQuery();
        if(likeRs.next()) {
            totalLikes = likeRs.getInt("totalLikes");
        }
        
        conn.close();
    } catch(Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>마이페이지 - PhotoNation</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/crypto-js/4.1.1/crypto-js.min.js"></script>
    <style>
        body {
            background-color: #f8f9fa;
        }
        
        .mypage-container {
            max-width: 1000px;
            margin: 20px auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .mypage-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        
        .profile-img-large {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            border: 5px solid white;
            object-fit: cover;
            margin-bottom: 15px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        }
        
        .nav-tabs {
            border-bottom: 2px solid #dee2e6;
            background-color: #f8f9fa;
        }
        
        .nav-tabs .nav-link {
            border: none;
            color: #666;
            font-weight: 500;
            padding: 15px 25px;
            margin: 0 5px;
            border-radius: 10px 10px 0 0;
            transition: all 0.3s ease;
        }
        
        .nav-tabs .nav-link:hover {
            background-color: #e9ecef;
            color: #495057;
        }
        
        .nav-tabs .nav-link.active {
            background-color: white;
            color: #495057;
            border-bottom: 3px solid #667eea;
        }
        
        .tab-content {
            padding: 30px;
        }
        
        .stat-card {
            background: linear-gradient(135deg, #ff6b6b, #ee5a24);
            color: white;
            border-radius: 15px;
            padding: 20px;
            text-align: center;
            margin-bottom: 20px;
            box-shadow: 0 4px 15px rgba(238, 90, 36, 0.3);
            transition: transform 0.3s ease;
        }
        
        .stat-card:nth-child(2) {
            background: linear-gradient(135deg, #74b9ff, #0984e3);
            box-shadow: 0 4px 15px rgba(9, 132, 227, 0.3);
        }
        
        .stat-card:nth-child(3) {
            background: linear-gradient(135deg, #55a3ff, #3742fa);
            box-shadow: 0 4px 15px rgba(55, 66, 250, 0.3);
        }
        
        .stat-card:nth-child(4) {
            background: linear-gradient(135deg, #26de81, #20bf6b);
            box-shadow: 0 4px 15px rgba(32, 191, 107, 0.3);
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
        }
        
        .stat-number {
            font-size: 2.5rem;
            font-weight: bold;
            margin-bottom: 5px;
        }
        
        .stat-label {
            font-size: 1rem;
            opacity: 0.9;
        }
        
        .form-control:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            border-radius: 25px;
            padding: 10px 30px;
            font-weight: 500;
        }
        
        .btn-danger {
            background: linear-gradient(135deg, #ff6b6b, #ee5a24);
            border: none;
            border-radius: 25px;
            padding: 10px 30px;
            font-weight: 500;
        }
        
        .withdraw-warning {
            background: #fff3cd;
            border: 1px solid #ffeaa7;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
        }
        
        .withdraw-input {
            border: 2px solid #dc3545;
            border-radius: 10px;
        }
        
        .withdraw-input:focus {
            border-color: #dc3545;
            box-shadow: 0 0 0 0.2rem rgba(220, 53, 69, 0.25);
        }
        
        #withdrawBtn:disabled {
            background: #6c757d;
            cursor: not-allowed;
        }
        
        .close-btn {
            position: absolute;
            top: 15px;
            right: 20px;
            background: none;
            border: none;
            font-size: 1.5rem;
            color: white;
            cursor: pointer;
            z-index: 1000;
        }
        
        .close-btn:hover {
            color: #ccc;
        }
        
        .readonly-field {
    		background-color: #e9ecef !important;
    		cursor: not-allowed;
		}

		.email-verification {
    		background-color: #f8f9fa;
    		border: 1px solid #dee2e6;
    		border-radius: 10px;
    		padding: 15px;
    		margin-top: 10px;
    		display: none;
		}

		.verification-success {
    		color: #28a745;
    		font-weight: bold;
		}

		.verification-error {
    		color: #dc3545;
    		font-weight: bold;
		}
		
		 #confirmNewPassword.valid {
            border-color: green !important;
        }
        #confirmNewPassword.invalid {
            border-color: red !important;
        }
        #profilePreview {
    		transition: all 0.3s ease;
		}

		#profilePreview, #headerProfileImg {
    		object-fit: cover;
    		background-color: #f8f9fa;
		}
    </style>
</head>
<body>
    <div class="mypage-container">
        <!-- 헤더 -->
        <div class="mypage-header position-relative">
            <button class="close-btn" onclick="window.close()">&times;</button>
            <h3><%= userNickname %></h3>
            <p class="mb-0">PhotoNation과 함께한 지 <%= daysSinceJoin %>일째</p>
        </div>
        
        <!-- 탭 네비게이션 -->
        <ul class="nav nav-tabs" id="mypageTabs" role="tablist">
            <li class="nav-item" role="presentation">
                <button class="nav-link active" id="history-tab" data-bs-toggle="tab" 
                        data-bs-target="#history" type="button" role="tab">
                    <i class="fas fa-chart-line me-2"></i>내 활동
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="profile-tab" data-bs-toggle="tab" 
                        data-bs-target="#profile" type="button" role="tab">
                    <i class="fas fa-user-edit me-2"></i>개인정보 수정
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="withdraw-tab" data-bs-toggle="tab" 
                        data-bs-target="#withdraw" type="button" role="tab">
                    <i class="fas fa-user-times me-2"></i>회원탈퇴
                </button>
            </li>
        </ul>
        
        <!-- 탭 내용 -->
        <div class="tab-content" id="mypageTabContent">
            <!-- 내 활동 탭 -->
            <div class="tab-pane fade show active" id="history" role="tabpanel">
                <h4 class="mb-4"><i class="fas fa-chart-line me-2"></i>나의 PhotoNation 활동</h4>
                
                <div class="row">
                    <div class="col-md-3 col-sm-6">
                        <div class="stat-card">
                            <div class="stat-number"><%= postCount %></div>
                            <div class="stat-label">작성한 글</div>
                        </div>
                    </div>
                    <div class="col-md-3 col-sm-6">
                        <div class="stat-card">
                            <div class="stat-number"><%= commentCount %></div>
                            <div class="stat-label">작성한 댓글</div>
                        </div>
                    </div>
                    <div class="col-md-3 col-sm-6">
                        <div class="stat-card">
                            <div class="stat-number"><%= totalLikes %></div>
                            <div class="stat-label">받은 좋아요</div>
                        </div>
                    </div>
                    <div class="col-md-3 col-sm-6">
                        <div class="stat-card">
                            <div class="stat-number"><%= daysSinceJoin %></div>
                            <div class="stat-label">함께한 날</div>
                        </div>
                    </div>
                </div>
                
                <div class="row mt-4">
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header">
                                <h6><i class="fas fa-user me-2"></i>기본 정보</h6>
                            </div>
                            <div class="card-body">
                                <p><strong>이름:</strong> <%= name %></p>
                                <p><strong>닉네임:</strong> <%= userNickname %></p>
                                <p><strong>성별:</strong> <%= sex %></p>
                                <p><strong>이메일:</strong> <%= email %></p>
                                <p><strong>주소:</strong> <%= address %></p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header">
                                <h6><i class="fas fa-trophy me-2"></i>활동 등급</h6>
                            </div>
                            <div class="card-body text-center">
                                <%
                                    String grade = "새싹";
                                    String gradeIcon = "🌱";
                                    if(postCount >= 50) {
                                        grade = "사진작가";
                                        gradeIcon = "📸";
                                    } else if(postCount >= 20) {
                                        grade = "열성회원";
                                        gradeIcon = "⭐";
                                    } else if(postCount >= 5) {
                                        grade = "일반회원";
                                        gradeIcon = "👤";
                                    }
                                %>
                                <div style="font-size: 3rem;"><%= gradeIcon %></div>
                                <h5 class="mt-2"><%= grade %></h5>
                                <small class="text-muted">총 활동 점수: <%= postCount * 10 + commentCount * 5 + totalLikes * 2 %></small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- 개인정보 수정 탭 -->
            <div class="tab-pane fade" id="profile" role="tabpanel">
    <h4 class="mb-4"><i class="fas fa-user-edit me-2"></i>개인정보 수정</h4>
    
    <form id="updateForm" enctype="multipart/form-data">
        <div class="row">
            <div class="col-md-4 text-center mb-4">
                <img id="profilePreview" src="getProfileImage.jsp?userId=<%= userId %>" 
                     alt="프로필 미리보기" class="profile-img-large"
                     onerror="this.src='img/default_profile.jpg'">
                <div class="mt-3">
                    <input type="file" class="form-control" id="profileImg" name="profileImg" 
                           accept="image/*" onchange="previewImage(this)">
                    <small class="text-muted">프로필 사진 변경</small>
                </div>
            </div>
            
            <div class="col-md-8">
                <!-- 아이디 (변경불가) -->
                <div class="mb-3">
                    <label class="form-label">아이디</label>
                    <input type="text" class="form-control readonly-field" value="<%= userId %>" readonly>
                </div>
                
                <!-- 이름 (변경불가) -->
                <div class="mb-3">
                    <label class="form-label">이름</label>
                    <input type="text" class="form-control readonly-field" value="<%= name %>" readonly>
                </div>
                
                <!-- 성별 (변경불가) -->
                <div class="mb-3">
                    <label class="form-label">성별</label>
                    <input type="text" class="form-control readonly-field" value="<%= sex %>" readonly>
                </div>
                
                <!-- 닉네임 수정 -->
                <div class="mb-3">
                    <label class="form-label">닉네임</label>
                    <div class="input-group">
                        <input type="text" class="form-control" id="nickname" name="nickname" 
                               value="<%= userNickname %>" required>
                        <button type="button" class="btn btn-outline-secondary" id="checkNicknameBtn" onclick="checkNickname()">중복확인</button>
                    </div>
                    <div id="nicknameCheckResult" class="form-text"></div>
                </div>
                
                <!-- 비밀번호 변경 수정 -->
                <div class="mb-3">
                    <label class="form-label">새 비밀번호</label>
                    <input type="password" class="form-control" id="newPassword" name="newPassword" 
                           placeholder="새 비밀번호 (변경하지 않으려면 비워두세요)">
                    <!-- 비밀번호 강도 표시 -->
                    <div class="mt-2">
                        <div class="progress" style="height: 8px;">
                            <div id="password-strength-bar" class="progress-bar" role="progressbar"
                                 style="width: 0%; transition: all 0.3s ease;" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"></div>
                        </div>
                        <div id="password-strength-text" class="mt-1 small text-muted"></div>
                    </div>
                </div>
                
                <!-- 비밀번호 확인 수정 -->
                <div class="mb-3">
                    <label class="form-label">새 비밀번호 확인</label>
                    <input type="password" class="form-control" id="confirmNewPassword" name="confirmNewPassword" 
                           placeholder="새 비밀번호 확인">
                    <div id="password-match-result" class="form-text mt-1"></div>
                </div>
            </div>
        </div>
                    
                    <!-- 나머지 필드들 -->
                    <div class="row">
                        <div class="col-md-6">
                            <!-- 생년월일 -->
                            <div class="mb-3">
                                <label class="form-label">생년월일</label>
                                <input type="date" class="form-control" id="birthday" name="birthday" 
                                       value="<%= birthday %>" required>
                            </div>
                            
                            <!-- 전화번호 -->
                            <div class="mb-3">
                                <label class="form-label">전화번호</label>
                                <input type="text" class="form-control" id="phoneNum" name="phoneNum" 
                                       value="<%= phoneNum %>" required>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <!-- 이메일 -->
                            <div class="mb-3">
    <label class="form-label">이메일</label>
    <div class="input-group">
        <input type="email" class="form-control" id="email" name="email" 
               value="<%= email %>" required>
        <button type="button" class="btn btn-outline-secondary" id="checkEmailBtn">변경 확인</button>
    </div>
    
    <!-- 이메일 인증 영역 -->
    <div id="emailVerificationArea" class="email-verification" style="display: none;">
        <div class="alert alert-info mb-2">
            <small><i class="fas fa-info-circle me-1"></i>새로운 이메일 주소로 인증 코드를 발송했습니다.</small>
        </div>
        <div class="input-group mb-2">
            <input type="text" class="form-control" id="emailVerificationCode" placeholder="인증코드 입력" maxlength="6">
            <button type="button" class="btn btn-outline-primary" id="verifyEmailBtn">인증 확인</button>
        </div>
        <div class="d-flex justify-content-between align-items-center">
            <button type="button" class="btn btn-secondary btn-sm" id="resendEmailBtn">재발송</button>
            <div id="emailVerificationStatus" class="small"></div>
        </div>
    </div>
</div>
                            
                            <!-- 우편번호 (읽기 전용) -->
                            <div class="mb-3">
                                <label class="form-label">우편번호</label>
                                <input type="text" class="form-control readonly-field" id="postNum" name="postNum" 
                                       value="<%= postNum %>" readonly>
                                <small class="text-muted">주소 변경은 고객센터에 문의해주세요.</small>
                            </div>
                        </div>
                    </div>
                    
                    <!-- 주소 (읽기 전용) -->
                    <div class="mb-3">
                        <label class="form-label">주소</label>
                        <input type="text" class="form-control readonly-field" id="address" name="address" 
                               value="<%= address %>" readonly>
                        <small class="text-muted">주소 변경은 고객센터에 문의해주세요.</small>
                    </div>
                    
                    <div class="text-end">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save me-2"></i>정보 수정
                        </button>
                    </div>
                </form>
            </div>
            
            <!-- 회원탈퇴 탭 -->
            <div class="tab-pane fade" id="withdraw" role="tabpanel">
                <h4 class="mb-4 text-danger"><i class="fas fa-user-times me-2"></i>회원탈퇴</h4>
                
                <div class="withdraw-warning">
                    <h5 class="text-warning"><i class="fas fa-exclamation-triangle me-2"></i>주의사항</h5>
                    <ul class="mt-3">
                        <li>회원탈퇴 시 계정 정보와 작성한 모든 글, 댓글이 삭제됩니다.</li>
                        <li>삭제된 정보는 복구할 수 없습니다.</li>
                        <li>동일한 아이디로 재가입이 불가능할 수 있습니다.</li>
                        <li>탈퇴 후에는 서비스 이용이 제한됩니다.</li>
                    </ul>
                </div>
                
                <div class="alert alert-danger">
                    <h6><i class="fas fa-info-circle me-2"></i>탈퇴 확인</h6>
                    <p>정말로 회원탈퇴를 하시려면 아래 입력란에 <strong>"탈퇴하겠습니다."</strong>라고 정확히 입력해주세요.</p>
                </div>
                
                <div class="mb-4">
                    <input type="text" class="form-control withdraw-input" id="withdrawConfirm" 
                           placeholder="탈퇴하겠습니다." onkeyup="checkWithdrawText()">
                </div>
                
                <div class="text-center">
                    <button type="button" class="btn btn-danger" id="withdrawBtn" 
                            onclick="processWithdraw()" disabled>
                        <i class="fas fa-user-times me-2"></i>회원탈퇴
                    </button>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
    	let originalEmail = '<%= email %>';
    	let isEmailVerified = false;
    	let newEmailToVerify = '';
    	let isNicknameChecked = false;

        // 프로필 이미지 미리보기
        function previewImage(input) {
    		if (input.files && input.files[0]) {
        		const reader = new FileReader();
        		reader.onload = function(e) {
        		    $('#profilePreview').attr('src', e.target.result);
        		}
        		reader.readAsDataURL(input.files[0]);
    		}
		}
        
        // 닉네임 중복 확인
        function checkNickname() {
    		const nickname = $('#nickname').val().trim();
		    const currentNickname = '<%= userNickname %>';
		    const resultDiv = $('#nicknameCheckResult');
		    const checkBtn = $('#checkNicknameBtn');
		    
		    // 입력값 검증
		    if (nickname === '') {
		        resultDiv.html('<i class="fas fa-times-circle text-danger me-1"></i>닉네임을 입력하세요.').removeClass('text-success text-primary').addClass('text-danger');
		        isNicknameChecked = false;
 		       	return;
    		}
    
    		if (nickname === currentNickname) {
        		resultDiv.html('<i class="fas fa-info-circle text-primary me-1"></i>현재 사용중인 닉네임입니다.').removeClass('text-danger text-success').addClass('text-primary');
        		isNicknameChecked = true;
        		return;
    		}
    
    		// 버튼 비활성화
    		checkBtn.prop('disabled', true).html('<span class="spinner-border spinner-border-sm me-1"></span>확인중...');
    
    		// AJAX 요청
    		$.ajax({
        		url: "checkNickname.jsp",
        		type: "POST",
        		data: { nickname: nickname },
        		timeout: 5000,
        		success: function(response) {
		            if (response.trim() === "ok") {
        		        resultDiv.html('<i class="fas fa-check-circle text-success me-1"></i>사용 가능한 닉네임입니다.').removeClass('text-danger text-primary').addClass('text-success');
                		isNicknameChecked = true;
		            } else {
		                resultDiv.html('<i class="fas fa-times-circle text-danger me-1"></i>이미 사용 중인 닉네임입니다.').removeClass('text-success text-primary').addClass('text-danger');
        		        isNicknameChecked = false;
            		}
        		},
        		error: function(xhr, status, error) {
            		resultDiv.html('<i class="fas fa-exclamation-triangle text-warning me-1"></i>서버 오류가 발생했습니다. 다시 시도해주세요.').removeClass('text-success text-primary').addClass('text-warning');
            		isNicknameChecked = false;
        		},
        		complete: function() {
            		checkBtn.prop('disabled', false).html('중복확인');
        		}
    		});
		}
        
        $('#nickname').on('input', function() {
            isNicknameChecked = false;
            $('#nicknameCheckResult').empty();
        });
        
        // 회원탈퇴 텍스트 확인
        function checkWithdrawText() {
    		const input = $('#withdrawConfirm').val();
    		const btn = $('#withdrawBtn');
    
    		if (input === '탈퇴하겠습니다.') {
        		btn.prop('disabled', false);
        		btn.removeClass('btn-secondary').addClass('btn-danger');
        		btn.html('<i class="fas fa-user-times me-2"></i>회원탈퇴 실행');
    		} else {
        		btn.prop('disabled', true);
        		btn.removeClass('btn-danger').addClass('btn-secondary');
        		btn.html('<i class="fas fa-user-times me-2"></i>회원탈퇴');
    		}
		}
        
     // 페이지 로드 시 이벤트 리스너 등록
        $(document).ready(function() {
            // 탈퇴 확인 텍스트 입력 시 실시간 체크
            $('#withdrawConfirm').on('input', checkWithdrawText);
            
            // 엔터키로 탈퇴 진행 방지
            $('#withdrawConfirm').on('keypress', function(e) {
                if (e.which === 13) { // Enter key
                    e.preventDefault();
                    if (!$('#withdrawBtn').prop('disabled')) {
                        processWithdraw();
                    }
                }
            });
            
            // 페이지 떠날 때 경고 (탈퇴 진행 중일 때)
            let isWithdrawing = false;
            
            $('#withdrawBtn').on('click', function() {
                isWithdrawing = true;
            });
            
            $(window).on('beforeunload', function(e) {
                if (isWithdrawing) {
                    const message = '회원탈퇴가 진행 중입니다. 페이지를 떠나시겠습니까?';
                    e.returnValue = message;
                    return message;
                }
            });
        });
        
     // 비밀번호 강도 체크
        $('#newPassword').on('input', function() {
    		const password = $(this).val();
    		const bar = $('#password-strength-bar');
    		const text = $('#password-strength-text');
    
    		if (password === '') {
        		bar.css('width', '0%').removeClass('bg-danger bg-warning bg-success bg-primary');
        		text.text('');
        		return;
    		}
    
    		let strength = 0;
    		let strengthText = '';
    		let strengthClass = '';
    
    		// 길이 체크
    		if (password.length >= 8) strength++;
    
    		// 대소문자 체크
    		if (/[a-z]/.test(password) && /[A-Z]/.test(password)) strength++;
    
    		// 숫자 체크
    		if (/\d/.test(password)) strength++;
    
    		// 특수문자 체크
    		if (/[!@#$%^&*(),.?":{}|<>]/.test(password)) strength++;
    
    		// 강도 계산
    		switch(strength) {
        		case 0:
        		case 1:
            		strengthText = '매우 약함';
            		strengthClass = 'bg-danger';
            		bar.css('width', '25%');
            		break;
        		case 2:
            		strengthText = '약함';
            		strengthClass = 'bg-warning';
            		bar.css('width', '50%');
            		break;
        		case 3:
            		strengthText = '보통';
            		strengthClass = 'bg-success';
            		bar.css('width', '75%');
            		break;
        		case 4:
            		strengthText = '강함';
            		strengthClass = 'bg-primary';
            		bar.css('width', '100%');
            		break;
    		}
    
    		bar.removeClass('bg-danger bg-warning bg-success bg-primary').addClass(strengthClass);
    		text.text('비밀번호 강도: ' + strengthText).removeClass('text-danger text-warning text-success text-primary').addClass(strengthClass.replace('bg-', 'text-'));
		});

        // 비밀번호 확인 실시간 검사
        $('#confirmNewPassword, #newPassword').on('input', function() {
    		const newPw = $('#newPassword').val();
    		const confirmPw = $('#confirmNewPassword').val();
    		const resultDiv = $('#password-match-result');
    
    		if (confirmPw === '') {
        		$('#confirmNewPassword').removeClass('is-valid is-invalid');
        		resultDiv.empty();
        		return;
    		}
    
    		if (newPw === confirmPw) {
        		$('#confirmNewPassword').removeClass('is-invalid').addClass('is-valid');
        		resultDiv.html('<i class="fas fa-check-circle text-success me-1"></i>비밀번호가 일치합니다.').removeClass('text-danger').addClass('text-success');
    		} else {
        		$('#confirmNewPassword').removeClass('is-valid').addClass('is-invalid');
        		resultDiv.html('<i class="fas fa-times-circle text-danger me-1"></i>비밀번호가 일치하지 않습니다.').removeClass('text-success').addClass('text-danger');
    		}
		});
        
        $(document).ready(function() {
            let originalEmail = '<%= email %>';
            let isEmailVerified = false;
            let newEmailToVerify = '';
            
            // 이메일 변경 확인 버튼 클릭 이벤트
            $('#checkEmailBtn').on('click', function(e) {
                e.preventDefault();
                checkEmailChange();
            });
            
            // 이메일 인증 확인 버튼 클릭 이벤트
            $('#verifyEmailBtn').on('click', function(e) {
                e.preventDefault();
                verifyNewEmail();
            });
            
            // 재발송 버튼 클릭 이벤트
            $('#resendEmailBtn').on('click', function(e) {
                e.preventDefault();
                resendEmailVerification();
            });

         // 이메일 입력 시 상태 초기화
            $('#email').on('input', function() {
                const currentEmail = $(this).val().trim();
                if (currentEmail !== originalEmail) {
                    isEmailVerified = false;
                    $('#emailVerificationArea').hide();
                } else {
                    isEmailVerified = true;
                    $('#emailVerificationArea').hide();
                }
            });
        });
     // 이메일 변경 확인 함수
        function checkEmailChange() {
            const newEmail = $('#email').val().trim();
            const checkBtn = $('#checkEmailBtn');
            
            // 현재 이메일과 같은 경우
            if (newEmail === originalEmail) {
                $('#emailVerificationArea').slideUp();
                isEmailVerified = true;
                return;
            }

            // 빈 값 체크
            if (newEmail === '') {
                alert('이메일을 입력해주세요.');
                $('#email').focus();
                return;
            }
            
            // 이메일 형식 검증
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(newEmail)) {
                alert('올바른 이메일 형식을 입력해주세요.');
                $('#email').focus();
                return;
            }

            newEmailToVerify = newEmail;
            isEmailVerified = false;

            // 버튼 상태 변경
            checkBtn.prop('disabled', true).html('<span class="spinner-border spinner-border-sm me-1"></span>발송중...');

            // 인증 코드 발송
            sendEmailVerification(newEmail);
        }

        // 이메일 인증 코드 발송
        function sendEmailVerification(email) {
            $.ajax({
                url: "sendVerificationEmail.jsp",
                type: "POST",
                data: { email: email },
                timeout: 10000,
                success: function(response) {
                    const statusDiv = $('#emailVerificationStatus');
                    
                    if (response.trim() === "success") {
                        $('#emailVerificationArea').slideDown();
                        statusDiv.html('<i class="fas fa-check-circle text-success me-1"></i>인증 코드가 발송되었습니다.')
                                 .removeClass('text-danger text-warning').addClass('text-success');
                    } else {
                        statusDiv.html('<i class="fas fa-times-circle text-danger me-1"></i>이메일 발송에 실패했습니다.')
                                 .removeClass('text-success text-warning').addClass('text-danger');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('이메일 발송 오류:', status, error);
                    $('#emailVerificationStatus')
                        .html('<i class="fas fa-exclamation-triangle text-warning me-1"></i>서버 오류가 발생했습니다.')
                        .removeClass('text-success text-danger').addClass('text-warning');
                },
                complete: function() {
                    $('#checkEmailBtn').prop('disabled', false).html('변경 확인');
                }
            });
        }

        // 이메일 인증 코드 확인
        function verifyNewEmail() {
            const emailCode = $('#emailVerificationCode').val().trim();

            if (emailCode === "") {
                alert("인증 코드를 입력해 주세요.");
                $('#emailVerificationCode').focus();
                return;
            }

            const verifyBtn = $('#verifyEmailBtn');
            verifyBtn.prop('disabled', true).html('<span class="spinner-border spinner-border-sm me-1"></span>확인중...');

            $.ajax({
                url: "verifyEmailCode.jsp",
                type: "POST",
                data: { 
                    email: newEmailToVerify, 
                    emailCode: emailCode 
                },
                success: function(response) {
                    const statusDiv = $('#emailVerificationStatus');
                    
                    if (response.trim() === "success") {
                        alert("이메일 인증이 완료되었습니다.");
                        isEmailVerified = true;
                        statusDiv.html('<i class="fas fa-check-circle text-success me-1"></i>이메일 인증이 완료되었습니다.')
                                 .removeClass('text-danger text-warning').addClass('text-success');
                        $('#emailVerificationArea').slideUp();
                    } else if (response.trim() === "expired") {
                        statusDiv.html('<i class="fas fa-clock text-warning me-1"></i>인증 코드가 만료되었습니다.')
                                 .removeClass('text-success text-danger').addClass('text-warning');
                    } else if (response.trim() === "invalid") {
                        statusDiv.html('<i class="fas fa-times-circle text-danger me-1"></i>잘못된 인증 코드입니다.')
                                 .removeClass('text-success text-warning').addClass('text-danger');
                    } else {
                        statusDiv.html('<i class="fas fa-times-circle text-danger me-1"></i>인증에 실패했습니다.')
                                 .removeClass('text-success text-warning').addClass('text-danger');
                    }
                },
                error: function() {
                    $('#emailVerificationStatus')
                        .html('<i class="fas fa-exclamation-triangle text-warning me-1"></i>서버 오류가 발생했습니다.')
                        .removeClass('text-success text-danger').addClass('text-warning');
                },
                complete: function() {
                    verifyBtn.prop('disabled', false).html('인증 확인');
                }
            });
        }

        // 인증 코드 재발송
        function resendEmailVerification() {
            if (newEmailToVerify) {
                sendEmailVerification(newEmailToVerify);
            }
        }
     // 개인정보 수정 처리
        $('#updateForm').on('submit', function(e) {
    e.preventDefault();
    
    const submitBtn = $('#submitBtn');
    const nickname = $('#nickname').val().trim();
    const currentNickname = '<%= userNickname %>';
    
    // 닉네임 변경 시 중복 확인 체크
    if (nickname !== currentNickname && !isNicknameChecked) {
        alert('닉네임 중복 확인을 해주세요.');
        return;
    }
    
    // 이메일 변경 시 인증 확인 체크
    const currentEmail = $('#email').val().trim();
    if (currentEmail !== originalEmail && !isEmailVerified) {
        alert('이메일이 변경되었습니다. 이메일 인증을 완료해주세요.');
        return;
    }
    
    // 비밀번호 확인 검사
    const newPassword = $('#newPassword').val();
    const confirmNewPassword = $('#confirmNewPassword').val();
    
    if (newPassword !== '' && newPassword !== confirmNewPassword) {
        alert('새 비밀번호가 일치하지 않습니다.');
        return;
    }
    
    // 제출 버튼 비활성화
    submitBtn.prop('disabled', true).html('<span class="spinner-border spinner-border-sm me-1"></span>수정중...');
    
    // FormData 생성
    const formData = new FormData(this);
    
    // 비밀번호 MD5 해싱 처리
    if (newPassword !== '') {
        const hashedPassword = CryptoJS.MD5(newPassword).toString();
        formData.append('hashedNewPassword', hashedPassword);
    }
    
    // AJAX 요청
    $.ajax({
        url: 'updateProfile.jsp',
        type: 'POST',
        data: formData,
        processData: false,
        contentType: false,
        timeout: 30000,
        success: function(response) {
            if (response.trim() === 'success') {
                alert('개인정보가 성공적으로 수정되었습니다.');
                location.reload();
            } else {
                alert('수정 중 오류가 발생했습니다: ' + response);
            }
        },
        error: function(xhr, status, error) {
            alert('서버 오류가 발생했습니다. 다시 시도해주세요.');
            console.error('Error:', error);
        },
        complete: function() {
            submitBtn.prop('disabled', false).html('<i class="fas fa-save me-2"></i>정보 수정');
        }
    });
});
        
        // 회원탈퇴 처리
        function processWithdraw() {
    // 첫 번째 확인
    if (!confirm('정말로 회원탈퇴를 하시겠습니까?\n\n⚠️ 주의사항:\n• 계정 정보와 작성한 모든 글, 댓글이 삭제됩니다\n• 삭제된 정보는 복구할 수 없습니다\n• 동일한 아이디로 재가입이 불가능할 수 있습니다')) {
        return;
    }
    
    // 두 번째 확인 (더 강력한 경고)
    if (!confirm('⚠️ 최종 확인 ⚠️\n\n회원탈퇴를 진행하면:\n\n✗ 모든 개인정보가 영구 삭제됩니다\n✗ 작성한 게시글과 댓글이 모두 삭제됩니다\n✗ 받은 좋아요와 활동 기록이 삭제됩니다\n✗ 이 작업은 되돌릴 수 없습니다\n\n정말로 계속 진행하시겠습니까?')) {
        return;
    }
    
    // 버튼 비활성화 및 로딩 상태 표시
    const withdrawBtn = $('#withdrawBtn');
    const originalText = withdrawBtn.html();
    withdrawBtn.prop('disabled', true)
               .html('<span class="spinner-border spinner-border-sm me-2"></span>탈퇴 처리중...')
               .removeClass('btn-danger')
               .addClass('btn-secondary');
    
    // 입력 필드도 비활성화
    $('#withdrawConfirm').prop('disabled', true);
    
    $.ajax({
        url: 'withdrawMember.jsp',
        type: 'POST',
        timeout: 30000, // 30초 타임아웃
        success: function(response) {
            console.log('서버 응답:', response);
            
            if (response.trim() === 'success') {
                // 성공 메시지
                alert('✅ 회원탈퇴가 완료되었습니다.\n\n그동안 PhotoNation을 이용해주셔서 감사합니다.\n안전한 하루 되세요! 😊');
                
                // 부모 창을 로그인 페이지로 리다이렉트
                if (window.opener) {
                    window.opener.location.href = 'login.jsp';
                }
                
                // 현재 창 닫기
                window.close();
                
                // 만약 창이 닫히지 않는다면 강제로 로그인 페이지로 이동
                setTimeout(function() {
                    location.href = 'login.jsp';
                }, 1000);
                
            } else {
                // 오류 처리
                let errorMessage = '탈퇴 처리 중 오류가 발생했습니다.';
                
                if (response.includes('database error')) {
                    errorMessage = '데이터베이스 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.';
                } else if (response.includes('user not found')) {
                    errorMessage = '사용자 정보를 찾을 수 없습니다.\n로그인 상태를 확인해주세요.';
                } else if (response.includes('not logged in')) {
                    errorMessage = '로그인이 필요합니다.';
                    location.href = 'login.jsp';
                    return;
                }
                
                alert('❌ ' + errorMessage + '\n\n오류 내용: ' + response);
                console.error('탈퇴 오류:', response);
            }
        },
        error: function(xhr, status, error) {
            console.error('AJAX 오류:', status, error, xhr.responseText);
            
            let errorMessage = '서버 연결 오류가 발생했습니다.';
            
            if (status === 'timeout') {
                errorMessage = '요청 시간이 초과되었습니다.\n네트워크 상태를 확인하고 다시 시도해주세요.';
            } else if (status === 'error') {
                errorMessage = '서버 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.';
            }
            
            alert('❌ ' + errorMessage);
        },
        complete: function() {
            // 버튼 상태 복구 (오류 발생 시에만)
            withdrawBtn.prop('disabled', false)
                       .html(originalText)
                       .removeClass('btn-secondary')
                       .addClass('btn-danger');
            
            $('#withdrawConfirm').prop('disabled', false);
        }
    });
}
    </script>
</body>
</html>