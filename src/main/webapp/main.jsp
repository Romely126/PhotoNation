<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ include file="sessionCheck.jsp" %>
<%
    String userNickname = (String) session.getAttribute("userNickname");
    String userId = (String) session.getAttribute("userId");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>PhotoNation - 메인</title>
    <link rel="icon" href="img/favicon.ico">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <!-- OpenStreetMap API -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <style>
        .welcome-message {
            background-color: #f8f9fa;
            padding: 10px 0;
            text-align: center;
            border-bottom: 1px solid #dee2e6;
        }
        .welcome-message a {
            color: #333;
            text-decoration: none;
        }
        .welcome-message a:hover {
            color: #007bff;
        }
        .nav-custom {
            background-color: #ffffff;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            padding: 10px 0;
        }
        .nav-item .nav-link {
            color: #333;
            font-weight: 500;
            padding: 8px 20px;
            margin: 0 5px;
            border-radius: 20px;
            transition: all 0.3s ease;
        }
        .nav-item .nav-link:hover {
            background-color: #f8f9fa;
            color: #007bff;
        }
        #contentArea {
            min-height: 600px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            background-color: white;
            padding: 20px;
        }
        #map {
            height: 900px;
            border-radius: 10px;
            display: none;
        }
        #postList {
            display: block;
        }
        .ad-section {
            height: 900px;
            background-color: #f8f9fa;
            border-radius: 10px;
            padding: 15px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        .login-section {
            height: 240px;
            background-color: #f8f9fa;
            border-radius: 10px;
            padding: 15px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        .popular-posts {
            background-color: #f8f9fa;
            border-radius: 10px;
            padding: 15px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        .profile-img {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            margin-bottom: 10px;
            object-fit: cover;
            border: 2px solid #fff;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            background-color: #f8f9fa;
        }
        .btn-custom {
            width: 100%;
            margin-bottom: 10px;
        }
        .popular-post-item {
            padding: 8px;
            border-bottom: 1px solid #dee2e6;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        .popular-post-item:last-child {
            border-bottom: none;
        }
        .popular-post-item:hover {
            background-color: #e9ecef;
        }
        .post-card {
            transition: transform 0.2s, box-shadow 0.2s;
            border: 1px solid #dee2e6;
        }
        .post-card:hover {
            transform: translateY(-2px);
            cursor: pointer;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        .post-thumbnail {
            height: 80px;
            object-fit: cover;
        }
        .nav-link {
            color: #495057;
            font-weight: 500;
        }
        .nav-link.active {
            color: #0d6efd !important;
            border-bottom: 2px solid #0d6efd !important;
        }
        .loading {
            text-align: center;
            padding: 40px;
        }
        .spinner-border {
            width: 3rem;
            height: 3rem;
        }
        
        .popular-posts {
    background-color: #f8f9fa;
    border-radius: 10px;
    padding: 15px;
    box-shadow: 0 0 10px rgba(0,0,0,0.1);
    position: relative;
}

.popular-post-item {
    padding: 12px;
    border-bottom: 1px solid #dee2e6;
    cursor: pointer;
    transition: all 0.3s ease;
    border-radius: 8px;
    margin-bottom: 8px;
    background-color: rgba(255, 255, 255, 0.7);
}

.popular-post-item:last-child {
    border-bottom: none;
    margin-bottom: 0;
}

.popular-post-item:hover {
    background-color: #e9ecef;
    transform: translateX(5px);
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.popular-post-item .post-title {
    font-weight: 500;
    color: #333;
    word-break: break-word;
    line-height: 1.4;
}

.popular-post-item .post-stats {
    display: flex;
    gap: 8px;
    align-items: center;
    margin-top: 6px;
}

.popular-post-item .post-stats i {
    margin-right: 3px;
}

.popularity-score {
    min-width: 60px;
    font-size: 0.75em;
}

/* NEW 배지 스타일 */
.badge.bg-danger {
    font-size: 0.6em !important;
    padding: 2px 6px;
    animation: pulse 2s infinite;
}

@keyframes pulse {
    0% { opacity: 1; }
    50% { opacity: 0.7; }
    100% { opacity: 1; }
}

/* 순위 표시 개선 */
.popular-post-item .text-primary {
    font-weight: bold;
    min-width: 35px;
}

/* 반응형 디자인 */
@media (max-width: 768px) {
    .popular-post-item {
        padding: 10px;
    }
    
    .popular-post-item .post-title {
        font-size: 0.85em;
    }
    
    .popular-post-item .post-stats {
        font-size: 0.7em;
    }
    
    .popularity-score {
        font-size: 0.65em;
    }
}

/* 로딩 애니메이션 */
.popular-posts .spinner-border-sm {
    width: 1.5rem;
    height: 1.5rem;
}

/* 새로고침 버튼 스타일 */
.popular-posts .btn-outline-primary {
    border: none;
    padding: 4px 8px;
    font-size: 0.8em;
    transition: all 0.2s ease;
}

.popular-posts .btn-outline-primary:hover {
    background-color: #007bff;
    color: white;
    transform: rotate(180deg);
}

/* 오류 메시지 스타일 */
.popular-posts .text-danger {
    font-size: 0.85em;
}

.popular-posts .text-danger .btn {
    font-size: 0.75em;
    padding: 4px 12px;
}

/* 통계 아이콘 색상 */
.text-danger i { color: #dc3545 !important; }
.text-primary i { color: #0d6efd !important; }
.text-success i { color: #198754 !important; }

/* 호버 효과 강화 */
.popular-post-item:hover .post-title {
    color: #007bff;
}

.popular-post-item:hover .text-primary {
    color: #0056b3 !important;
}

.popup-form {
    width: 280px;
}
.popup-form input, .popup-form textarea {
    display: block;
    margin-bottom: 8px;
    width: 100%;
    padding: 8px;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 14px;
}
.popup-form button {
    background-color: #007bff;
    color: white;
    border: none;
    padding: 10px 16px;
    border-radius: 4px;
    cursor: pointer;
    width: 100%;
    font-size: 14px;
}
.image-preview {
    width: 100%;
    max-height: 150px;
    object-fit: cover;
    border-radius: 4px;
    margin: 8px 0;
    display: none;
}

/* 지도 검색 박스 스타일 */
.map-search-container {
    position: absolute;
    top: 20px;
    right: 20px;
    z-index: 1000;
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    border-radius: 25px;
    padding: 8px 15px;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
    border: 1px solid rgba(255, 255, 255, 0.3);
    width: 300px;
    transition: all 0.3s ease;
}

.map-search-container:hover {
    background: rgba(255, 255, 255, 1);
    box-shadow: 0 6px 20px rgba(0, 0, 0, 0.25);
}

.map-search-input {
    border: none;
    outline: none;
    background: transparent;
    width: 240px;
    padding: 8px 5px;
    font-size: 14px;
    color: #333;
}

.map-search-input::placeholder {
    color: #666;
}

.map-search-btn {
    border: none;
    background: #007bff;
    color: white;
    border-radius: 50%;
    width: 32px;
    height: 32px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.2s ease;
    font-size: 14px;
}

.map-search-btn:hover {
    background: #0056b3;
    transform: scale(1.05);
}

.map-search-results {
    position: absolute;
    top: 100%;
    left: 0;
    right: 0;
    background: white;
    border-radius: 10px;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
    max-height: 200px;
    overflow-y: auto;
    margin-top: 5px;
    display: none;
}

.map-search-result-item {
    padding: 10px 15px;
    cursor: pointer;
    border-bottom: 1px solid #eee;
    transition: background-color 0.2s;
}

.map-search-result-item:hover {
    background-color: #f8f9fa;
}

.map-search-result-item:last-child {
    border-bottom: none;
}

.map-search-result-name {
    font-weight: 500;
    color: #333;
    font-size: 14px;
}

.map-search-result-address {
    font-size: 12px;
    color: #666;
    margin-top: 2px;
}

/* 검색 로딩 상태 */
.map-search-loading {
    display: none;
    text-align: center;
    padding: 15px;
    color: #666;
    font-size: 13px;
}

.map-search-loading .spinner-border {
    width: 1rem;
    height: 1rem;
    margin-right: 8px;
}
    </style>
</head>
<body>
    <!-- 환영 메시지 -->
    <div class="welcome-message">
        <a href="main.jsp">
            <% if(userNickname != null) { %>
                <%= userNickname %>님 환영합니다!
            <% } else { %>
                PhotoNation에 오신 것을 환영합니다!
            <% } %>
        </a>
    </div>

    <!-- 네비게이션 바 -->
    <nav class="navbar navbar-expand-lg nav-custom">
        <div class="container">
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse justify-content-center" id="navbarNav">
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link active" data-board-type="all" href="#" onclick="showBoard('all')">모든게시글</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" data-board-type="free" href="#" onclick="showBoard('free')">자유게시판</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" data-board-type="photo" href="#" onclick="showBoard('photo')">포토게시판</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" data-board-type="qna" href="#" onclick="showBoard('qna')">질문게시판</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" data-board-type="market" href="#" onclick="showBoard('market')">거래게시판</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" data-board-type="map" href="#" onclick="showMap()">NationMaps™</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- 메인 컨텐츠 영역 -->
    <div class="container mt-4" style="max-width: 90%;">
        <div class="row">
            <!-- 광고 섹션 (좌측 20%) -->
            <div class="col-md-3">
                <div class="ad-section">
                    <!-- 광고 내용 -->
                    <a href="https://www.sigma-global.com/en/" target="_blank">
                    	<img src="img/ad_poster_new.png" style="width: 100%; height: 100%; object-fit: cover; border-radius: 10px;">
                    </a>
                </div>
            </div>

            <!-- 컨텐츠 영역 (중앙 60%) -->
            <div class="col-md-6">
                <div id="contentArea">
                    <!-- 게시글 목록 -->
                    <div id="postList">
                        <div class="loading">
                            <div class="spinner-border text-primary" role="status">
                                <span class="visually-hidden">로딩중...</span>
                            </div>
                            <p class="mt-2">게시글을 불러오는 중...</p>
                        </div>
                    </div>
                    
                    <!-- 지도 -->
                    <div id="map" style="position: relative;">
    <!-- 지도 검색 박스 -->
    <div class="map-search-container" id="mapSearchContainer" style="display: none;">
        <div style="display: flex; align-items: center;">
            <input type="text" 
                   class="map-search-input" 
                   id="mapSearchInput" 
                   placeholder="장소명이나 주소를 검색하세요..."
                   autocomplete="off">
            <button class="map-search-btn" id="mapSearchBtn" onclick="searchLocation()">
                <i class="fas fa-search"></i>
            </button>
        </div>
        
        <!-- 검색 결과 -->
        <div class="map-search-results" id="mapSearchResults">
            <div class="map-search-loading" id="mapSearchLoading">
                <div class="spinner-border spinner-border-sm" role="status"></div>
                검색 중...
            </div>
        </div>
    </div>
</div>
                </div>
            </div>

            <!-- 로그인/프로필 섹션 (우측 20%) -->
            <div class="col-md-3">
                <!-- 로그인/프로필 영역 -->
                <div class="login-section">
                    <% if(userId != null && userNickname != null) { %>
                        <!-- 로그인된 상태 -->
						<div class="text-center">
    						<img src="getProfileImage.jsp?userId=<%= userId %>" 
         						alt="프로필 사진" 
         						class="profile-img"
         							onerror="this.src='img/default_profile.jpg'">
    						<h6 class="mb-2">
        						<% if("admin".equals(userId)) { %>
            						<i class="fas fa-crown text-warning ms-1" title="관리자"></i>
        						<% } %>
        						<%= userNickname %>
    						</h6>
    						<% if("admin".equals(userId)) { %>
        						<a href="adminPanel.jsp" class="btn btn-primary btn-sm btn-custom" target="_blank">관리자 패널</a>
    						<% } else { %>
        						<a href="mypage.jsp" class="btn btn-primary btn-sm btn-custom" onclick="window.open(this.href, '_blank'); return false;">마이페이지</a>
    						<% } %>
    						<a href="writePost.jsp" class="btn btn-success btn-sm btn-custom">글쓰기</a>
    						<a href="logout.jsp" class="btn btn-secondary btn-sm btn-custom">로그아웃</a>
						</div>
                    <% } else { %>
                        <!-- 로그인되지 않은 상태 -->
                        <div class="text-center">
                            <h6 class="mb-3">로그인을 해주세요</h6>
                            <a href="login.jsp" class="btn btn-primary btn-custom">로그인</a>
                        </div>
                    <% } %>
                </div>

                <!-- 실시간 인기글 -->
                <div class="popular-posts">
                    <h6 class="text-center mb-3">실시간 인기글</h6>
                    <div id="popularPosts">
                        <!-- 인기글 목록이 여기에 동적으로 로드됩니다 -->
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // OpenStreetMap 초기화
        var map = L.map('map').setView([37.556883, 126.9780], 11);
		L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    		attribution: '© OpenStreetMap contributors'
		}).addTo(map);
		
		map.on('click', function(e) {
		    <% if(userId != null) { %>
		        var lat = e.latlng.lat;
		        var lng = e.latlng.lng;
		        
		        // 좌표값 검증
		        console.log('클릭된 좌표:', lat, lng);
		        
		        if (!lat || !lng || isNaN(lat) || isNaN(lng)) {
		            console.error('유효하지 않은 좌표:', lat, lng);
		            alert('좌표 정보를 가져올 수 없습니다.');
		            return;
		        }
		        
		        // 고유한 ID를 생성하여 폼을 식별
		        var formId = 'spotForm_' + Date.now();
		        
		        var popupContent = `
		            <div class="popup-form">
		                <div id="${'${formId}'}">
		                    <input type="text" id="${'${formId}'}_title" placeholder="제목" required>
		                    <textarea id="${'${formId}'}_description" placeholder="설명" rows="3" required></textarea>
		                    <div style="display: flex; gap: 5px; margin-bottom: 8px;">
		                        <input type="text" value="위도: ${'${lat.toFixed(6)}'}" readonly style="flex: 1; background-color: #f8f9fa; color: #666; font-size: 12px;">
		                        <input type="text" value="경도: ${'${lng.toFixed(6)}'}" readonly style="flex: 1; background-color: #f8f9fa; color: #666; font-size: 12px;">
		                    </div>
		                    <input type="file" id="${'${formId}'}_photo" accept="image/*" required onchange="previewImage(this, '${'${formId}'}')">
		                    <img id="${'${formId}'}_preview" class="image-preview" style="display:none;">
		                    <button type="button" onclick="uploadSpot('${'${formId}'}', ${'${lat}'}, ${'${lng}'})">저장</button>
		                    <button type="button" onclick="map.closePopup()" style="background-color: #6c757d; margin-top: 5px;">취소</button>
		                </div>
		            </div>
		        `;
		        
		        // 기존 팝업 닫기
		        map.closePopup();
		        
		        // 새 마커와 팝업 생성
		        var tempMarker = L.marker([lat, lng]).addTo(map);
		        tempMarker.bindPopup(popupContent, {
		            closeOnClick: false,
		            autoClose: false,
		            maxWidth: 300
		        }).openPopup();
		        
		        // 팝업이 닫힐 때 임시 마커 제거
		        tempMarker.on('popupclose', function() {
		            map.removeLayer(tempMarker);
		        });
		        
		    <% } else { %>
		        alert('로그인 후 이용해주세요.');
		    <% } %>
		});

		
		function previewImage(input, formId) {
		    const preview = document.getElementById(formId + '_preview');
		    
		    if (input.files && input.files[0]) {
		        const file = input.files[0];
		        
		        // 파일 타입 검사
		        if (!file.type.startsWith('image/')) {
		            alert('이미지 파일만 선택 가능합니다.');
		            input.value = '';
		            preview.style.display = 'none';
		            return;
		        }
		        
		        // 파일 크기 검사 (10MB)
		        if (file.size > 10 * 1024 * 1024) {
		            alert('파일 크기는 10MB 이하여야 합니다.');
		            input.value = '';
		            preview.style.display = 'none';
		            return;
		        }
		        
		        const reader = new FileReader();
		        reader.onload = function(e) {
		            preview.src = e.target.result;
		            preview.style.display = 'block';
		        };
		        reader.readAsDataURL(file);
		    } else {
		        preview.style.display = 'none';
		    }
		}
		
		// 출사지 업로드 함수 추가
		function uploadSpot(formId, lat, lng) {
    console.log('uploadSpot 함수 시작 - formId:', formId, 'lat:', lat, 'lng:', lng);
    console.log('찾고 있는 요소 ID들:', formId + '_title', formId + '_description', formId + '_photo');
    // DOM 요소 가져오기
    const titleInput = document.getElementById(formId + '_title');
    const descriptionInput = document.getElementById(formId + '_description');
    const photoInput = document.getElementById(formId + '_photo');
    const submitBtn = document.querySelector('#' + formId + ' button');
    
    
    // 요소 존재 확인
    if (!titleInput || !descriptionInput || !photoInput || !submitBtn) {
        console.error('필요한 DOM 요소를 찾을 수 없습니다');
        alert('폼 요소를 찾을 수 없습니다.');
        return;
    }
    
    // 입력값 가져오기
    const title = titleInput.value.trim();
    const description = descriptionInput.value.trim();
    const photoFile = photoInput.files[0];
    
    console.log('입력값 확인:', {title, description, photoFile: !!photoFile});
    
    // 유효성 검사
    if (!title) {
        alert('제목을 입력해주세요.');
        titleInput.focus();
        return;
    }
    
    if (!description) {
        alert('설명을 입력해주세요.');
        descriptionInput.focus();
        return;
    }
    
    if (!photoFile) {
        alert('사진을 선택해주세요.');
        photoInput.focus();
        return;
    }
    
    // 파일 크기 및 타입 검사
    if (photoFile.size > 10 * 1024 * 1024) { // 10MB 제한
        alert('파일 크기는 10MB 이하여야 합니다.');
        return;
    }
    
    if (!photoFile.type.startsWith('image/')) {
        alert('이미지 파일만 업로드 가능합니다.');
        return;
    }
    
    // 버튼 비활성화
    const originalText = submitBtn.textContent;
    submitBtn.disabled = true;
    submitBtn.textContent = '저장 중...';
    
    // FormData 생성
    const formData = new FormData();
    formData.append('title', title);
    formData.append('description', description);
    formData.append('latitude', lat.toString());
    formData.append('longitude', lng.toString());
    formData.append('photo', photoFile);
    
    console.log('AJAX 요청 시작');
    
    // AJAX 요청
    $.ajax({
        url: 'uploadSpot.jsp',
        type: 'POST',
        data: formData,
        processData: false,
        contentType: false,
        timeout: 30000,
        success: function(response) {
            console.log('서버 응답 원본:', JSON.stringify(response));
            
            // 응답 정리 (HTML 태그 제거 및 공백 정리)
            const cleanResponse = response.replace(/<[^>]*>/g, '').trim();
            console.log('정리된 응답:', cleanResponse);
            
            if (cleanResponse === 'success') {
                alert('출사 장소가 등록되었습니다!');
                map.closePopup();
                loadSpots(); // 등록된 장소들 다시 로드
            } else if (cleanResponse === 'unauthorized') {
                alert('로그인이 필요합니다.');
                window.location.href = 'login.jsp';
            } else if (cleanResponse === 'missing_data') {
                alert('필수 정보가 누락되었습니다.');
            } else if (cleanResponse === 'no_photo') {
                alert('사진을 선택해주세요.');
            } else if (cleanResponse.startsWith('error:')) {
                const errorMsg = cleanResponse.substring(6);
                console.error('서버 오류:', errorMsg);
                alert('오류가 발생했습니다: ' + errorMsg);
            } else {
                console.error('예상치 못한 응답:', cleanResponse);
                alert('알 수 없는 응답입니다: ' + cleanResponse);
            }
        },
        error: function(xhr, status, error) {
            console.error('AJAX 오류 상세:', {
                status: status,
                error: error,
                responseText: xhr.responseText,
                readyState: xhr.readyState,
                statusText: xhr.statusText
            });
            
            let errorMessage = '네트워크 오류가 발생했습니다.';
            
            if (status === 'timeout') {
                errorMessage = '요청 시간이 초과되었습니다. 다시 시도해주세요.';
            } else if (xhr.status === 404) {
                errorMessage = 'uploadSpot.jsp 파일을 찾을 수 없습니다.';
            } else if (xhr.status === 500) {
                errorMessage = '서버 내부 오류가 발생했습니다.';
            } else if (xhr.status === 0) {
                errorMessage = '네트워크 연결을 확인해주세요.';
            }
            
            alert(errorMessage);
        },
        complete: function() {
            // 버튼 다시 활성화
            submitBtn.disabled = false;
            submitBtn.textContent = originalText;
            console.log('AJAX 요청 완료');
        }
    });
}

		
		
		// 위치 검색 함수 (Nominatim API 사용)
		function searchLocation() {
		    const query = $('#mapSearchInput').val().trim();
		    
		    if (!query) {
		        alert('검색할 장소를 입력해주세요.');
		        return;
		    }
		    
		    // 로딩 표시
		    $('#mapSearchLoading').show();
		    $('#mapSearchResults').show();
		    
		    // Nominatim API를 사용한 위치 검색
		    $.ajax({
		        url: 'https://nominatim.openstreetmap.org/search',
		        method: 'GET',
		        data: {
		            q: query,
		            format: 'json',
		            limit: 5,
		            countrycodes: 'kr', // 한국 우선
		            'accept-language': 'ko,en'
		        },
		        success: function(results) {
		            console.log('검색 결과:', results);
		            $('#mapSearchLoading').hide();
		            
		            if (results && results.length > 0) {
		                displaySearchResults(results);
		            } else {
		                $('#mapSearchResults').html(`
		                    <div class="map-search-result-item">
		                        <div class="text-center text-muted">검색 결과가 없습니다.</div>
		                    </div>
		                `);
		            }
		        },
		        error: function(xhr, status, error) {
		            console.error('검색 실패:', error);
		            $('#mapSearchLoading').hide();
		            $('#mapSearchResults').html(`
		                <div class="map-search-result-item">
		                    <div class="text-center text-danger">검색 중 오류가 발생했습니다.</div>
		                </div>
		            `);
		        }
		    });
		}

		// 검색 결과 표시 함수
		function displaySearchResults(results) {
    let html = '';
    
    results.forEach(function(result, index) {
        const name = result.display_name.split(',')[0];
        const address = result.display_name;
        
        html += '<div class="map-search-result-item" onclick="selectSearchResult(' + 
                result.lat + ', ' + result.lon + ', \'' + name.replace(/'/g, "\\'") + '\')">' +
                '<div class="map-search-result-name">' + name + '</div>' +
                '<div class="map-search-result-address">' + address + '</div>' +
                '</div>';
    });
    
    $('#mapSearchResults').html(html);
}

		// 검색 결과 선택 함수
		function selectSearchResult(lat, lng, name) {
		    console.log('검색 결과 선택:', lat, lng, name);
		    
		    // 검색 결과 숨기기
		    $('#mapSearchResults').hide();
		    $('#mapSearchInput').val(name);
		    
		    // 지도 이동
		    map.setView([lat, lng], 16);
		    
		    <% if(userId != null) { %>
		        // 로그인된 사용자만 등록 팝업 표시
		        setTimeout(function() {
		            showLocationRegisterPopup(lat, lng, name);
		        }, 500);
		    <% } else { %>
		        // 비로그인 사용자에게 알림
		        setTimeout(function() {
		            alert('로그인 후 출사지를 등록할 수 있습니다.');
		        }, 500);
		    <% } %>
		}

		// 위치 등록 팝업 표시 함수
		function showLocationRegisterPopup(lat, lng, locationName) {
		    // 고유한 ID 생성
		    const formId = 'spotForm_' + Date.now();
		    
		    const popupContent = `
		        <div class="popup-form">
		            <div id="${'${formId}'}">
		                <div style="margin-bottom: 10px; padding: 8px; background: #e3f2fd; border-radius: 4px;">
		                    <small><i class="fas fa-map-marker-alt"></i> ${'${locationName}'}</small>
		                </div>
		                <input type="text" id="${'${formId}'}_title" placeholder="출사지 제목을 입력하세요" required>
		                <textarea id="${'${formId}'}_description" placeholder="이 장소에 대한 설명을 입력하세요" rows="3" required></textarea>
		                <div style="display: flex; gap: 5px; margin-bottom: 8px;">
		                    <input type="text" value="위도: ${'${lat.toFixed(6)}'}" readonly style="flex: 1; background-color: #f8f9fa; color: #666; font-size: 12px;">
		                    <input type="text" value="경도: ${'${lng.toFixed(6)}'}" readonly style="flex: 1; background-color: #f8f9fa; color: #666; font-size: 12px;">
		                </div>
		                <input type="file" id="${'${formId}'}_photo" accept="image/*" required onchange="previewImage(this, '${'${formId}'}')">
		                <img id="${'${formId}'}_preview" class="image-preview" style="display:none;">
		                <button type="button" onclick="uploadSpot('${'${formId}'}', ${'${lat}'}, ${'${lng}'})">
		                    <i class="fas fa-save"></i> 출사지 등록
		                </button>
		                <button type="button" onclick="map.closePopup()" style="background-color: #6c757d; margin-top: 5px;">
		                    <i class="fas fa-times"></i> 취소
		                </button>
		            </div>
		        </div>
		    `;
		    
		    // 기존 팝업 닫기
		    map.closePopup();
		    
		    // 새 마커와 팝업 생성
		    const tempMarker = L.marker([lat, lng]).addTo(map);
		    tempMarker.bindPopup(popupContent, {
		        closeOnClick: false,
		        autoClose: false,
		        maxWidth: 320
		    }).openPopup();
		    
		    // 팝업이 닫힐 때 임시 마커 제거
		    tempMarker.on('popupclose', function() {
		        map.removeLayer(tempMarker);
		    });
		}

		// Enter 키 검색
		$(document).on('keypress', '#mapSearchInput', function(e) {
		    if (e.which === 13) {
		        searchLocation();
		    }
		});

		// 검색 결과 외부 클릭 시 숨기기
		$(document).on('click', function(e) {
		    if (!$(e.target).closest('.map-search-container').length) {
		        $('#mapSearchResults').hide();
		    }
		});

		// 등록된 출사지 로드 함수
		function loadSpots() {
    console.log('loadSpots 함수 시작');
    
    $.ajax({
        url: 'getSpots.jsp',
        method: 'GET',
        dataType: 'json',
        timeout: 10000,
        success: function(data) {
            console.log('출사지 데이터 로드 성공:', data);
            
            // 기존 출사지 마커들 제거
            map.eachLayer(function(layer) {
                if (layer instanceof L.Marker && layer.options.isSpot) {
                    map.removeLayer(layer);
                }
            });
            
            // 데이터가 배열인지 확인
            if (Array.isArray(data)) {
                // 새 마커들 추가
                data.forEach(function(spot) {
                    if (spot.latitude && spot.longitude) {
                        // 순위 아이콘 생성
                        var rankIcon = null;
                        var rankColor = '#6c757d'; // 기본 회색
                        
                        if (spot.ranking <= 10 && spot.like_count > 0) {
                            if (spot.ranking === 1) {
                                rankColor = '#ffd700'; // 금색
                            } else if (spot.ranking === 2) {
                                rankColor = '#c0c0c0'; // 은색
                            } else if (spot.ranking === 3) {
                                rankColor = '#cd7f32'; // 동색
                            } else {
                                rankColor = '#007bff'; // 파란색
                            }
                            
                            rankIcon = L.divIcon({
                                html: '<div style="background-color:' + rankColor + ';color:white;border-radius:50%;width:30px;height:30px;display:flex;align-items:center;justify-content:center;font-weight:bold;font-size:12px;border:2px solid white;box-shadow:0 2px 4px rgba(0,0,0,0.3);">' + spot.ranking + '</div>',
                                iconSize: [30, 30],
                                iconAnchor: [15, 15],
                                className: 'custom-rank-icon'
                            });
                        }
                        
                        // 팝업 내용 생성
                        var popupContent = '<div style="min-width: 250px;">';
                        
                        // 순위 표시 (상위 10위까지)
                        if (spot.ranking <= 10 && spot.like_count > 0) {
                            var rankBadge = '';
                            if (spot.ranking === 1) {
                                rankBadge = '<span style="background:#ffd700;color:#333;padding:2px 8px;border-radius:10px;font-size:12px;font-weight:bold;">🏆 1위</span>';
                            } else if (spot.ranking === 2) {
                                rankBadge = '<span style="background:#c0c0c0;color:#333;padding:2px 8px;border-radius:10px;font-size:12px;font-weight:bold;">🥈 2위</span>';
                            } else if (spot.ranking === 3) {
                                rankBadge = '<span style="background:#cd7f32;color:white;padding:2px 8px;border-radius:10px;font-size:12px;font-weight:bold;">🥉 3위</span>';
                            } else {
                                rankBadge = '<span style="background:#007bff;color:white;padding:2px 8px;border-radius:10px;font-size:12px;font-weight:bold;">' + spot.ranking + '위</span>';
                            }
                            popupContent += '<div style="margin-bottom:8px;">' + rankBadge + '</div>';
                        }
                        
                        popupContent += '<h6>' + (spot.title || '제목 없음') + '</h6>' +
                                       '<p style="margin-bottom:10px;">' + (spot.description || '설명 없음') + '</p>' +
                                       '<img src="getSpotImage.jsp?id=' + spot.id + '" ' +
                                       'style="width:100%;max-width:300px;height:auto;border-radius:4px;margin-bottom:10px;" ' +
                                       'onerror="this.style.display=\'none\'">';
                        
                        // 좋아요 버튼 섹션
                        popupContent += '<div style="display:flex;align-items:center;gap:10px;margin-bottom:8px;">';
                        
                        <% if(userId != null) { %>
                        // 로그인된 경우 좋아요 버튼 표시
                        var heartIcon = spot.user_liked ? '❤️' : '🤍';
                        var heartColor = spot.user_liked ? '#dc3545' : '#6c757d';
                        
                        popupContent += '<button onclick="toggleSpotLike(' + spot.id + ', this)" ' +
                                       'class="btn btn-sm" ' +
                                       'style="background:none;border:1px solid ' + heartColor + ';color:' + heartColor + ';display:flex;align-items:center;gap:4px;" ' +
                                       'data-liked="' + spot.user_liked + '">' +
                                       '<span class="heart-icon">' + heartIcon + '</span>' +
                                       '<span class="like-count">' + (spot.like_count || 0) + '</span>' +
                                       '</button>';
                        <% } else { %>
                        // 로그인되지 않은 경우 좋아요 수만 표시
                        popupContent += '<span style="display:flex;align-items:center;gap:4px;color:#6c757d;">' +
                                       '❤️ <span>' + (spot.like_count || 0) + '</span>' +
                                       '</span>';
                        <% } %>
                        
                        popupContent += '</div>';
                        
                        <% if(userId != null) { %>
                        // 삭제 버튼 (자신이 등록한 출사지만)
                        if (spot.user_id === '<%= userId %>' || '<%= userId %>' === 'admin') {
                            popupContent += '<button onclick="deleteSpot(' + spot.id + ')" ' +
                                           'class="btn btn-sm btn-danger" style="width:100%;">삭제</button>';
                        }
                        <% } %>
                        
                        popupContent += '</div>';
                        
                        // 마커 생성
                        var marker;
                        if (rankIcon) {
                            marker = L.marker([spot.latitude, spot.longitude], {
                                icon: rankIcon,
                                isSpot: true,
                                spotData: spot
                            });
                        } else {
                            marker = L.marker([spot.latitude, spot.longitude], {
                                isSpot: true,
                                spotData: spot
                            });
                        }
                        
                        marker.addTo(map).bindPopup(popupContent, {
                            maxWidth: 300,
                            closeOnClick: false
                        });
                    }
                });
                
                console.log(data.length + '개의 출사지 마커가 추가되었습니다.');
            } else {
                console.error('응답 데이터가 배열이 아닙니다:', data);
            }
        },
        error: function(xhr, status, error) {
            console.error('출사지 로드 실패:', {
                status: status,
                error: error,
                responseText: xhr.responseText
            });
        }
    });
}
		// 출사지 삭제 함수 추가
		function deleteSpot(spotId) {
    console.log('deleteSpot 함수 호출, spotId:', spotId);
    
    if(!confirm('이 출사지를 삭제하시겠습니까?')) {
        return;
    }
    
    $.ajax({
        url: 'deleteSpot.jsp',
        method: 'POST',
        data: {spotId: spotId},
        timeout: 10000,
        success: function(response) {
            const cleanResponse = response.trim();
            if (cleanResponse === 'success') {
                alert('삭제되었습니다.');
                loadSpots();
            } else {
                alert('삭제 실패: ' + cleanResponse);
            }
        },
        error: function(xhr, status, error) {
            console.error('삭제 실패:', error);
            alert('삭제 중 오류가 발생했습니다.');
        }
    });
}

		// showMap 함수 
		function showMap() {
    console.log('showMap 호출');
    $('#postList').hide();
    $('#map').show();
    $('#mapSearchContainer').show(); // 검색 박스 표시
    map.invalidateSize();
    loadSpots(); // 출사지 로드
    
    $('#navbarNav .nav-link').removeClass('active');
    $('#navbarNav .nav-link[data-board-type="map"]').addClass('active');
}

        let currentBoardType = 'all';
        let currentPage = 1;
        let currentSearch = '';

        // 게시판 표시 함수
        function showBoard(type) {
    console.log('showBoard 호출:', type);
    $('#map').hide();
    $('#mapSearchContainer').hide(); // 검색 박스 숨기기
    $('#postList').show();
    
    currentBoardType = type;
    currentPage = 1;
    currentSearch = '';
    loadPosts(currentBoardType, currentPage, '');
    
    // 현재 활성화된 탭 표시
    $('#navbarNav .nav-link').removeClass('active');
    $(`#navbarNav .nav-link[data-board-type="${type}"]`).addClass('active');
}

        // 게시글 목록 로드 함수
        function loadPosts(boardType, page, search) {
            console.log('loadPosts 호출:', boardType, page, search);
            currentBoardType = boardType;
            currentPage = page;
            currentSearch = search;
            
            // 로딩 표시
            $('#postList').html(`
                <div class="loading">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">로딩중...</span>
                    </div>
                    <p class="mt-2">게시글을 불러오는 중...</p>
                </div>
            `);
            
            $.ajax({
                url: 'getPosts.jsp',
                method: 'GET',
                data: {
                    boardType: boardType,
                    page: page,
                    search: search
                },
                success: function(response) {
                    console.log('게시글 로드 성공');
                    $('#postList').html(response);
                },
                error: function(xhr, status, error) {
                    console.error('게시글 로드 실패:', error);
                    $('#postList').html(`
                        <div class="alert alert-danger">
                            <i class="fas fa-exclamation-triangle"></i>
                            게시글을 불러오는 중 오류가 발생했습니다.
                        </div>
                    `);
                }
            });
        }

        // 검색 함수
        function searchPosts() {
            console.log('searchPosts 호출');
            const searchValue = $('#searchInput').val();
            loadPosts(currentBoardType, 1, searchValue);
        }

        // 게시글 상세보기 함수 - 단순화
        function viewPost(postId) {
            console.log('viewPost 함수 호출, postId:', postId);
            
            // postId 유효성 검증
            if (!postId) {
                console.error('viewPost: postId가 없습니다');
                alert('유효하지 않은 게시글 ID입니다.');
                return false;
            }
            
            // 문자열을 숫자로 변환
            const numericPostId = parseInt(postId);
            if (isNaN(numericPostId) || numericPostId <= 0) {
                console.error('viewPost: postId가 유효한 숫자가 아닙니다:', postId);
                alert('유효하지 않은 게시글 ID입니다.');
                return false;
            }
            
            const url = `viewPost.jsp?postId=${'${numericPostId}'}`;
            console.log('페이지 이동 시작:', url);
            window.location.href = url;
            return false;
        }


        // 인기글 로드 함수 - 캐시 방지 및 오류 처리 강화
function loadPopularPosts() {
    console.log('loadPopularPosts 호출 - ' + new Date().toLocaleTimeString());
    
    // 로딩 상태 표시
    $('#popularPosts').html(`
        <div class="text-center py-2">
            <div class="spinner-border spinner-border-sm text-primary" role="status">
                <span class="visually-hidden">로딩중...</span>
            </div>
            <small class="d-block mt-1 text-muted">업데이트 중...</small>
        </div>
    `);
    
    $.ajax({
        url: 'getPopularPosts.jsp',
        method: 'GET',
        cache: false, // 캐시 방지
        data: {
            timestamp: new Date().getTime() // 캐시 버스팅을 위한 타임스탬프
        },
        timeout: 10000, // 10초 타임아웃
        success: function(response) {
            console.log('인기글 로드 성공 - ' + new Date().toLocaleTimeString());
            $('#popularPosts').html(response);
            
            // 성공 시 간단한 애니메이션 효과
            $('#popularPosts').hide().fadeIn(300);
        },
        error: function(xhr, status, error) {
            console.error("인기글 로드 실패:", error, status);
            
            let errorMessage = '';
            if (status === 'timeout') {
                errorMessage = '요청 시간이 초과되었습니다.';
            } else if (status === 'error') {
                errorMessage = '서버 오류가 발생했습니다.';
            } else {
                errorMessage = '알 수 없는 오류가 발생했습니다.';
            }
            
            $('#popularPosts').html(`
                <div class="text-center text-danger py-3">
                    <i class="fas fa-exclamation-triangle mb-2"></i>
                    <div style="font-size: 0.9em;">${errorMessage}</div>
                    <button class="btn btn-sm btn-outline-primary mt-2" onclick="loadPopularPosts()">
                        <i class="fas fa-redo"></i> 다시 시도
                    </button>
                </div>
            `);
        }
    });
}
//실시간 업데이트를 위한 개선된 함수
function startRealTimeUpdates() {
    // 페이지가 활성화되어 있을 때만 업데이트
    let updateInterval;
    
    function updateIfVisible() {
        if (!document.hidden) {
            loadPopularPosts();
        }
    }
    
    // 초기 로드
    loadPopularPosts();
    
    // 30초마다 업데이트 (더 자주 업데이트)
    updateInterval = setInterval(updateIfVisible, 30000);
    
    // 페이지 포커스 시 즉시 업데이트
    $(window).on('focus', function() {
        console.log('페이지 포커스 - 인기글 즉시 업데이트');
        loadPopularPosts();
    });
    
    // 페이지 숨김/표시 상태 변경 시 처리
    document.addEventListener('visibilitychange', function() {
        if (!document.hidden) {
            console.log('페이지 다시 표시 - 인기글 업데이트');
            loadPopularPosts();
        }
    });
    
    return updateInterval;
}
function addRefreshButton() {
    const refreshButton = `
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h6 class="mb-0">실시간 인기글</h6>
            <button class="btn btn-sm btn-outline-primary" onclick="loadPopularPosts()" title="새로고침">
                <i class="fas fa-sync-alt"></i>
            </button>
        </div>
    `;
    
    // 기존 제목을 새로운 헤더로 교체
    $('.popular-posts h6').replaceWith(refreshButton);
}
        // Enter 키 검색 - 이벤트 위임 사용
        $(document).on('keypress', '#searchInput', function(e) {
            if (e.which == 13) {
                console.log('Enter 키로 검색 실행');
                searchPosts();
            }
        });

     // 페이지 로드 시 실행하는 메인 함수
        $(document).ready(function() {
            console.log('페이지 로드 완료');
            
            // 기본 게시글 로드
            loadPosts('all', 1, '');
            
            // 실시간 인기글 업데이트 시작
            const updateInterval = startRealTimeUpdates();
            
            // 새로고침 버튼 추가
            setTimeout(addRefreshButton, 1000);
            
            // 페이지 언로드 시 인터벌 정리
            $(window).on('beforeunload', function() {
                if (updateInterval) {
                    clearInterval(updateInterval);
                }
            });
            
            // 네트워크 상태 변경 감지
            if ('onLine' in navigator) {
                $(window).on('online', function() {
                    console.log('네트워크 연결 복구 - 인기글 업데이트');
                    loadPopularPosts();
                });
            }
        });
        
        // 이벤트 핸들러 통합
        $(document).on('click', '.post-item, .popular-post-item', function(e) {
    e.preventDefault();
    e.stopPropagation();
    
    const postId = $(this).attr('data-post-id') || $(this).data('post-id');
    
    console.log('게시글 클릭됨, postId:', postId);
    
    if (postId && postId !== 'undefined' && postId !== '') {
        viewPost(postId);
    } else {
        console.error('postId를 찾을 수 없거나 유효하지 않습니다');
        alert('게시글 정보를 찾을 수 없습니다.');
    }
    
    return false;
});
     // 출사지 좋아요 토글 함수
        function toggleSpotLike(spotId, buttonElement) {
            console.log('toggleSpotLike 함수 호출, spotId:', spotId);
            
            if (!spotId) {
                console.error('spotId가 없습니다');
                alert('출사지 정보를 찾을 수 없습니다.');
                return;
            }
            
            // 버튼 비활성화 (중복 클릭 방지)
            if (buttonElement) {
                buttonElement.disabled = true;
            }
            
            $.ajax({
                url: 'toggleSpotLike.jsp',
                method: 'POST',
                data: {
                    spotId: spotId
                },
                timeout: 10000,
                success: function(response) {
                    console.log('좋아요 토글 응답:', response);
                    
                    try {
                        // JSON 응답 파싱 시도
                        let result;
                        if (typeof response === 'string') {
                            // HTML 태그 제거 및 공백 정리
                            const cleanResponse = response.replace(/<[^>]*>/g, '').trim();
                            
                            if (cleanResponse.startsWith('{')) {
                                result = JSON.parse(cleanResponse);
                            } else {
                                throw new Error('JSON이 아닌 응답: ' + cleanResponse);
                            }
                        } else {
                            result = response;
                        }
                        
                        if (result.success) {
                            // 성공시 UI 업데이트
                            if (buttonElement) {
                                const heartIcon = buttonElement.querySelector('.heart-icon');
                                const likeCount = buttonElement.querySelector('.like-count');
                                
                                if (heartIcon && likeCount) {
                                    // 좋아요 상태에 따라 아이콘과 색상 변경
                                    if (result.liked) {
                                        heartIcon.textContent = '❤️';
                                        buttonElement.style.color = '#dc3545';
                                        buttonElement.style.borderColor = '#dc3545';
                                        buttonElement.setAttribute('data-liked', 'true');
                                    } else {
                                        heartIcon.textContent = '🤍';
                                        buttonElement.style.color = '#6c757d';
                                        buttonElement.style.borderColor = '#6c757d';
                                        buttonElement.setAttribute('data-liked', 'false');
                                    }
                                    
                                    // 좋아요 수 업데이트
                                    likeCount.textContent = result.likeCount || 0;
                                    
                                    // 간단한 애니메이션 효과
                                    buttonElement.style.transform = 'scale(1.1)';
                                    setTimeout(() => {
                                        buttonElement.style.transform = 'scale(1)';
                                    }, 150);
                                }
                            }
                            
                            // 지도의 모든 마커 업데이트 (순위 변경 반영)
                            setTimeout(() => {
                                loadSpots();
                            }, 500);
                            
                        } else {
                            console.error('좋아요 처리 실패:', result);
                            alert('좋아요 처리 중 오류가 발생했습니다.');
                        }
                        
                    } catch (error) {
                        console.error('응답 파싱 오류:', error);
                        
                        // 문자열 응답 처리
                        const cleanResponse = (typeof response === 'string') ? 
                            response.replace(/<[^>]*>/g, '').trim() : String(response);
                        
                        if (cleanResponse === 'unauthorized') {
                            alert('로그인이 필요합니다.');
                            window.location.href = 'login.jsp';
                        } else if (cleanResponse.startsWith('error:')) {
                            const errorMsg = cleanResponse.substring(6);
                            alert('오류: ' + errorMsg);
                        } else {
                            console.error('예상치 못한 응답:', cleanResponse);
                            alert('알 수 없는 오류가 발생했습니다.');
                        }
                    }
                },
                error: function(xhr, status, error) {
                    console.error('좋아요 토글 AJAX 오류:', {
                        status: status,
                        error: error,
                        responseText: xhr.responseText
                    });
                    
                    let errorMessage = '네트워크 오류가 발생했습니다.';
                    
                    if (status === 'timeout') {
                        errorMessage = '요청 시간이 초과되었습니다.';
                    } else if (xhr.status === 404) {
                        errorMessage = 'toggleSpotLike.jsp 파일을 찾을 수 없습니다.';
                    } else if (xhr.status === 500) {
                        errorMessage = '서버 내부 오류가 발생했습니다.';
                    } else if (xhr.status === 0) {
                        errorMessage = '네트워크 연결을 확인해주세요.';
                    }
                    
                    alert(errorMessage);
                },
                complete: function() {
                    // 버튼 다시 활성화
                    if (buttonElement) {
                        buttonElement.disabled = false;
                    }
                }
            });
        }
    </script>
</body>
</html>