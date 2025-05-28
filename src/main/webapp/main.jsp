<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    String userNickname = (String) session.getAttribute("userNickname");
    String userId = (String) session.getAttribute("userId");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>PhotoNation - 메인</title>
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
            height: 600px;
            border-radius: 10px;
            display: none;
        }
        #postList {
            display: block;
        }
        .ad-section {
            height: 600px;
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
                        <a class="nav-link active" data-board-type="all" href="#" onclick="showBoard('all')">모든 게시글</a>
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
                        <a class="nav-link" data-board-type="market" href="#" onclick="showBoard('market')">장터게시판</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" data-board-type="map" href="#" onclick="showMap()">출사지도</a>
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
                    	<img src="img/ad_poster.png" style="width: 100%; height: 100%; object-fit: cover; border-radius: 10px;">
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
                    <div id="map"></div>
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
                            <h6 class="mb-2"><%= userNickname %></h6>
                            <a href="mypage.jsp" class="btn btn-primary btn-sm btn-custom" onclick="window.open(this.href, '_blank'); return false;">마이페이지</a>
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
        var map = L.map('map').setView([37.5665, 126.9780], 13);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap contributors'
        }).addTo(map);

        let currentBoardType = 'all';
        let currentPage = 1;
        let currentSearch = '';

        // 게시판 표시 함수
        function showBoard(type) {
            console.log('showBoard 호출:', type);
            $('#map').hide();
            $('#postList').show();
            
            currentBoardType = type;
            currentPage = 1;
            currentSearch = '';
            loadPosts(currentBoardType, currentPage, '');
            
            // 현재 활성화된 탭 표시
            $('#navbarNav .nav-link').removeClass('active');
            $(`#navbarNav .nav-link[data-board-type="${type}"]`).addClass('active');
        }

        // 지도 표시 함수
        function showMap() {
            console.log('showMap 호출');
            $('#postList').hide();
            $('#map').show();
            map.invalidateSize(); // 지도 크기 재조정
            
            // 현재 활성화된 탭 표시
            $('#navbarNav .nav-link').removeClass('active');
            $('#navbarNav .nav-link[data-board-type="map"]').addClass('active');
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
    </script>
</body>
</html>