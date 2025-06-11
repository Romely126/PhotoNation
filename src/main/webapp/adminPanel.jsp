<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PhotoNation 관리자 패널</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: #333;
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
        }

        .header {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
        }

        .header h1 {
            font-size: 2.5rem;
            background: linear-gradient(135deg, #667eea, #764ba2);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-align: center;
            margin-bottom: 10px;
        }

        .header p {
            text-align: center;
            color: #666;
            font-size: 1.1rem;
        }

        .tab-container {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
        }

        .tab-buttons {
            display: flex;
            background: rgba(102, 126, 234, 0.1);
            border-bottom: 2px solid rgba(102, 126, 234, 0.2);
        }

        .tab-button {
            flex: 1;
            padding: 20px;
            border: none;
            background: none;
            cursor: pointer;
            font-size: 1.1rem;
            font-weight: 600;
            transition: all 0.3s ease;
            position: relative;
        }

        .tab-button:hover {
            background: rgba(102, 126, 234, 0.15);
        }

        .tab-button.active {
            background: rgba(102, 126, 234, 0.2);
            color: #667eea;
        }

        .tab-button.active::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            width: 100%;
            height: 3px;
            background: linear-gradient(135deg, #667eea, #764ba2);
        }

        .tab-content {
            display: none;
            padding: 30px;
            animation: fadeIn 0.5s ease;
        }

        .tab-content.active {
            display: block;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 25px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: rgba(255, 255, 255, 0.8);
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
            border: 1px solid rgba(102, 126, 234, 0.2);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
        }

        .stat-card h3 {
            color: #667eea;
            margin-bottom: 15px;
            font-size: 1.3rem;
        }

        .stat-number {
            font-size: 2.5rem;
            font-weight: bold;
            color: #333;
            margin-bottom: 10px;
        }

        .stat-label {
            color: #666;
            font-size: 0.9rem;
        }

        .chart-container {
            background: rgba(255, 255, 255, 0.8);
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 25px;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
        }

        .chart-title {
            font-size: 1.5rem;
            color: #667eea;
            margin-bottom: 20px;
            text-align: center;
        }

        .user-table {
            width: 100%;
            border-collapse: collapse;
            background: rgba(255, 255, 255, 0.9);
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
        }

        .user-table th,
        .user-table td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid rgba(102, 126, 234, 0.1);
        }

        .user-table th {
            background: rgba(102, 126, 234, 0.1);
            font-weight: 600;
            color: #667eea;
        }

        .user-table tr:hover {
            background: rgba(102, 126, 234, 0.05);
        }

        .user-row {
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        .user-row.selected {
            background: rgba(102, 126, 234, 0.15);
        }

        .action-buttons {
            margin-top: 20px;
            display: none;
            gap: 15px;
        }

        .action-buttons.show {
            display: flex;
        }

        .btn {
            padding: 12px 25px;
            border: none;
            border-radius: 25px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
            font-size: 1rem;
        }

        .btn-activate {
            background: linear-gradient(135deg, #4CAF50, #45a049);
            color: white;
        }

        .btn-deactivate {
            background: linear-gradient(135deg, #f44336, #da190b);
            color: white;
        }

        .btn-restore {
            background: linear-gradient(135deg, #2196F3, #1976D2);
            color: white;
        }

        .btn-delete {
            background: linear-gradient(135deg, #FF9800, #F57C00);
            color: white;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
        }

        .status-badge {
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
        }

        .status-active {
            background: #e8f5e8;
            color: #4CAF50;
        }

        .status-inactive {
            background: #ffebee;
            color: #f44336;
        }

        .search-box {
            width: 100%;
            padding: 15px;
            border: 2px solid rgba(102, 126, 234, 0.2);
            border-radius: 25px;
            font-size: 1rem;
            margin-bottom: 20px;
            transition: border-color 0.3s ease;
        }

        .search-box:focus {
            outline: none;
            border-color: #667eea;
        }

        .loading {
            text-align: center;
            padding: 50px;
            color: #667eea;
            font-size: 1.2rem;
        }

        .alert {
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
            font-weight: 600;
        }

        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .pagination {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-top: 20px;
        }

        .page-btn {
            padding: 8px 15px;
            border: 2px solid #667eea;
            background: white;
            color: #667eea;
            border-radius: 20px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .page-btn:hover,
        .page-btn.active {
            background: #667eea;
            color: white;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>PhotoNation 관리자 패널</h1>
            <p>환영합니다 관리자님. PhotoNation since 2025</p>
        </div>

        <div class="tab-container">
            <div class="tab-buttons">
                <button class="tab-button active" onclick="showTab('stats')">커뮤니티 통계</button>
                <button class="tab-button" onclick="showTab('users')">회원 리스트</button>
                <button class="tab-button" onclick="showTab('withdrawn')">탈퇴 회원 관리</button>
            </div>

            <!-- 커뮤니티 통계 탭 -->
            <div id="stats" class="tab-content active">
                <div class="stats-grid">
                    <div class="stat-card">
                        <h3>전체 회원 수</h3>
                        <div class="stat-number" id="totalUsers">0</div>
                        <div class="stat-label">등록된 사용자</div>
                    </div>
                    <div class="stat-card">
                        <h3>활성 회원 수</h3>
                        <div class="stat-number" id="activeUsers">0</div>
                        <div class="stat-label">활성화된 사용자</div>
                    </div>
                    <div class="stat-card">
                        <h3>전체 게시글</h3>
                        <div class="stat-number" id="totalPosts">0</div>
                        <div class="stat-label">작성된 게시글</div>
                    </div>
                    <div class="stat-card">
                        <h3>전체 댓글</h3>
                        <div class="stat-number" id="totalComments">0</div>
                        <div class="stat-label">작성된 댓글</div>
                    </div>
                    <div class="stat-card">
                        <h3>출사지</h3>
                        <div class="stat-number" id="totalPhotoSpots">0</div>
                        <div class="stat-label">등록된 출사지</div>
                    </div>
                    <div class="stat-card">
                        <h3>탈퇴 회원</h3>
                        <div class="stat-number" id="withdrawnUsers">0</div>
                        <div class="stat-label">탈퇴한 사용자</div>
                    </div>
                </div>

                <div class="chart-container">
                    <div class="chart-title">게시판별 게시글 현황</div>
                    <canvas id="boardChart" width="400" height="200"></canvas>
                </div>

                <div class="chart-container">
                    <div class="chart-title">월별 회원 가입 현황</div>
                    <canvas id="userJoinChart" width="400" height="200"></canvas>
                </div>

                <div class="chart-container">
                    <div class="chart-title">성별 회원 분포</div>
                    <canvas id="genderChart" width="400" height="200"></canvas>
                </div>
            </div>

            <!-- 회원 리스트 탭 -->
            <div id="users" class="tab-content">
                <input type="text" class="search-box" placeholder="회원 검색 (ID, 닉네임, 이름)" onkeyup="searchUsers(this.value)">
                
                <div id="userAlert"></div>
                
                <table class="user-table" id="userTable">
                    <thead>
                        <tr>
                            <th>순번</th>
                            <th>ID</th>
                            <th>닉네임</th>
                            <th>이름</th>
                            <th>성별</th>
                            <th>가입일</th>
                            <th>상태</th>
                        </tr>
                    </thead>
                    <tbody id="userTableBody">
                        <!-- 사용자 데이터가 여기에 로드됩니다 -->
                    </tbody>
                </table>
                
                <div class="action-buttons" id="userActions">
                    <button class="btn btn-activate" onclick="toggleUserStatus('activate')">회원 활성화</button>
                    <button class="btn btn-deactivate" onclick="toggleUserStatus('deactivate')">회원 정지</button>
                </div>
                
                <div class="pagination" id="userPagination"></div>
            </div>

            <!-- 탈퇴 회원 관리 탭 -->
            <div id="withdrawn" class="tab-content">
                <input type="text" class="search-box" placeholder="탈퇴 회원 검색 (ID, 닉네임, 이름)" onkeyup="searchWithdrawnUsers(this.value)">
                
                <div id="withdrawnAlert"></div>
                
                <table class="user-table" id="withdrawnTable">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>닉네임</th>
                            <th>이름</th>
                            <th>성별</th>
                            <th>가입일</th>
                            <th>탈퇴일</th>
                        </tr>
                    </thead>
                    <tbody id="withdrawnTableBody">
                        <!-- 탈퇴 회원 데이터가 여기에 로드됩니다 -->
                    </tbody>
                </table>
                
                <div class="action-buttons" id="withdrawnActions">
                    <button class="btn btn-restore" onclick="restoreUser()">계정 복구</button>
                    <button class="btn btn-delete" onclick="deleteUser()">데이터 삭제</button>
                </div>
                
                <div class="pagination" id="withdrawnPagination"></div>
            </div>
        </div>
    </div>

    <script>
        let selectedUser = null;
        let selectedWithdrawnUser = null;
        let currentPage = 1;
        let usersPerPage = 10;
        let allUsers = [];
        let allWithdrawnUsers = [];

        // 탭 전환 함수
        function showTab(tabName) {
            // 모든 탭 버튼과 콘텐츠 비활성화
            document.querySelectorAll('.tab-button').forEach(btn => btn.classList.remove('active'));
            document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
            
            // 선택된 탭 활성화
            event.target.classList.add('active');
            document.getElementById(tabName).classList.add('active');
            
            // 선택된 사용자 초기화
            selectedUser = null;
            selectedWithdrawnUser = null;
            document.getElementById('userActions').classList.remove('show');
            document.getElementById('withdrawnActions').classList.remove('show');
            
            // 각 탭별 데이터 로드
            if (tabName === 'stats') {
                loadStats();
            } else if (tabName === 'users') {
                loadUsers();
            } else if (tabName === 'withdrawn') {
                loadWithdrawnUsers();
            }
        }

        // 통계 데이터 로드
        function loadStats() {
            // 게시판별 게시글 차트
            const boardCtx = document.getElementById('boardChart').getContext('2d');
            new Chart(boardCtx, {
                type: 'doughnut',
                data: {
                    labels: ['자유게시판', '사진게시판', 'Q&A', '장터'],
                    datasets: [{
                        data: [1520, 1890, 432, 0],
                        backgroundColor: [
                            '#FF6384',
                            '#36A2EB',
                            '#FFCE56',
                            '#4BC0C0'
                        ],
                        borderWidth: 0
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            position: 'bottom',
                        }
                    }
                }
            });
            
            // 월별 가입 현황 차트
            const joinCtx = document.getElementById('userJoinChart').getContext('2d');
            new Chart(joinCtx, {
                type: 'line',
                data: {
                    labels: ['1월', '2월', '3월', '4월', '5월', '6월'],
                    datasets: [{
                        label: '신규 가입자',
                        data: [65, 89, 123, 156, 234, 187],
                        borderColor: '#667eea',
                        backgroundColor: 'rgba(102, 126, 234, 0.1)',
                        borderWidth: 3,
                        fill: true,
                        tension: 0.4
                    }]
                },
                options: {
                    responsive: true,
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });
            
            // 성별 분포 차트
            const genderCtx = document.getElementById('genderChart').getContext('2d');
            new Chart(genderCtx, {
                type: 'bar',
                data: {
                    labels: ['남성', '여성'],
                    datasets: [{
                        label: '회원 수',
                        data: [687, 558],
                        backgroundColor: [
                            '#36A2EB',
                            '#FF6384'
                        ],
                        borderWidth: 0
                    }]
                },
                options: {
                    responsive: true,
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });
        }

        // 회원 데이터 로드
        function loadUsers() {
    		fetch('getUserList.jsp')
        		.then(response => response.json())
        		.then(data => {
            		if (data && data.length > 0 && data[0].error) {
                		showAlert('userAlert', data[0].error, 'error');
                		allUsers = [];
            		} else {
                		allUsers = data;
            		}
            		displayUsers(allUsers);
        		})
        		.catch(error => {
            		console.error('Error loading users:', error);
            		showAlert('userAlert', '회원 데이터 로드 중 오류가 발생했습니다.', 'error');
            		allUsers = [];
            		displayUsers(allUsers);
        		});
		}

        // 회원 목록 표시
        function displayUsers(users) {
            const tbody = document.getElementById('userTableBody');
            tbody.innerHTML = '';
            
            const startIndex = (currentPage - 1) * usersPerPage;
            const endIndex = startIndex + usersPerPage;
            const pageUsers = users.slice(startIndex, endIndex);
            
            pageUsers.forEach((user, index) => {
                const row = document.createElement('tr');
                row.className = 'user-row';
                row.onclick = () => selectUser(user, row);
                
                const statusClass = user.actived ? 'status-active' : 'status-inactive';
                const statusText = user.actived ? '활성' : '정지';
                
                row.innerHTML = 
                    '<td>' + (startIndex + index + 1) + '</td>' +
                    '<td>' + user.id + '</td>' +
                    '<td>' + user.nickname + '</td>' +
                    '<td>' + user.name + '</td>' +
                    '<td>' + user.sex + '</td>' +
                    '<td>' + user.joinDate + '</td>' +
                    '<td><span class="status-badge ' + statusClass + '">' + statusText + '</span></td>';

                
                tbody.appendChild(row);
            });
            
            // 페이지네이션 업데이트
            updateUserPagination(users.length);
        }

        // 회원 선택
        function selectUser(user, row) {
            // 이전 선택 해제
            document.querySelectorAll('.user-row').forEach(r => r.classList.remove('selected'));
            
            // 새로운 선택
            row.classList.add('selected');
            selectedUser = user;
            
            // 액션 버튼 표시
            document.getElementById('userActions').classList.add('show');
        }

        // 회원 상태 변경
        function toggleUserStatus(action) {
    		if (!selectedUser) {
        		showAlert('userAlert', '먼저 회원을 선택해주세요.', 'error');
        		return;
    		}
    
    		const newStatus = action === 'activate' ? 1 : 0;
    		const actionText = action === 'activate' ? '활성화' : '정지';
    
    		if (confirm(`${'${selectedUser.nickname}'}(${'${selectedUser.id}'}) 회원을 ${'${actionText}'}하시겠습니까?`)) {
        		fetch('updateUserStatus.jsp', {
            		method: 'POST',
            		headers: {
                		'Content-Type': 'application/x-www-form-urlencoded',
            		},
            		body: `userId=${'${encodeURIComponent(selectedUser.id)}'}&status=${'${newStatus}'}`
        		})
        		.then(response => response.json())
        		.then(data => {
            		if (data.success) {
                		selectedUser.actived = newStatus;
                		displayUsers(allUsers);
                		selectedUser = null;
                		document.getElementById('userActions').classList.remove('show');
                		showAlert('userAlert', `회원 ${'${actionText}'}를 완료하였습니다.`, 'success');
            		} else {
                		showAlert('userAlert', data.message || '처리 중 오류가 발생했습니다.', 'error');
            		}
        		})
        		.catch(error => {
            		console.error('Error:', error);
            		showAlert('userAlert', '서버 통신 중 오류가 발생했습니다.', 'error');
        		});
    		}
		}


        // 회원 검색
        function searchUsers(keyword) {
            if (!keyword.trim()) {
                displayUsers(allUsers);
                return;
            }
            
            const filtered = allUsers.filter(user => 
                user.id.toLowerCase().includes(keyword.toLowerCase()) ||
                user.nickname.toLowerCase().includes(keyword.toLowerCase()) ||
                user.name.toLowerCase().includes(keyword.toLowerCase())
            );
            
            currentPage = 1;
            displayUsers(filtered);
        }

     	// 탈퇴 회원 데이터 로드
        function loadWithdrawnUsers() {
    		fetch('getWithdrawnUserList.jsp')
        		.then(response => response.json())
        		.then(data => {
            		if (data && data.length > 0 && data[0].error) {
                		showAlert('withdrawnAlert', data[0].error, 'error');
                		allWithdrawnUsers = [];
            		} else {
                		allWithdrawnUsers = data;
            		}
            		displayWithdrawnUsers(allWithdrawnUsers);
        		})
        		.catch(error => {
            		console.error('Error loading withdrawn users:', error);
            		showAlert('withdrawnAlert', '탈퇴 회원 데이터 로드 중 오류가 발생했습니다.', 'error');
            		allWithdrawnUsers = [];
            		displayWithdrawnUsers(allWithdrawnUsers);
        		});
		}

        // 탈퇴 회원 목록 표시
        function displayWithdrawnUsers(users) {
            const tbody = document.getElementById('withdrawnTableBody');
            tbody.innerHTML = '';
            
            users.forEach(user => {
                const row = document.createElement('tr');
                row.className = 'user-row';
                row.onclick = () => selectWithdrawnUser(user, row);
                
                row.innerHTML = 
                    '<td>' + user.id + '</td>' +
                    '<td>' + user.nickname + '</td>' +
                    '<td>' + user.name + '</td>' +
                    '<td>' + user.sex + '</td>' +
                    '<td>' + user.joinDate + '</td>' +
                    '<td>' + user.withdrawDate + '</td>';
                
                tbody.appendChild(row);
            });
        }

        // 탈퇴 회원 선택
        function selectWithdrawnUser(user, row) {
            // 이전 선택 해제
            document.querySelectorAll('#withdrawnTable .user-row').forEach(r => r.classList.remove('selected'));
            
            // 새로운 선택
            row.classList.add('selected');
            selectedWithdrawnUser = user;
            
            // 액션 버튼 표시
            document.getElementById('withdrawnActions').classList.add('show');
        }

        // 계정 복구
        function restoreUser() {
    		if (!selectedWithdrawnUser) {
        		showAlert('withdrawnAlert', '먼저 탈퇴 회원을 선택해주세요.', 'error');
        		return;
    		}
    
    		if (confirm(`${'${selectedWithdrawnUser.nickname}'}(${'${selectedWithdrawnUser.id}'}) 계정을 복구하시겠습니까?`)) {
        		fetch('restoreUser.jsp', {
            		method: 'POST',
            		headers: {
                		'Content-Type': 'application/x-www-form-urlencoded',
            		},
            		body: `userId=${'${encodeURIComponent(selectedWithdrawnUser.id)}'}&withdrawDate=${'${encodeURIComponent(selectedWithdrawnUser.withdrawDate)}'}`
        		})
        		.then(response => response.json())
        		.then(data => {
            		if (data.success) {
                		allWithdrawnUsers = allWithdrawnUsers.filter(u => u.id !== selectedWithdrawnUser.id);
                		displayWithdrawnUsers(allWithdrawnUsers);
                		selectedWithdrawnUser = null;
                		document.getElementById('withdrawnActions').classList.remove('show');
                		showAlert('withdrawnAlert', '계정 복구가 완료되었습니다.', 'success');
            		} else {
                		showAlert('withdrawnAlert', data.message || '복구 중 오류가 발생했습니다.', 'error');
            		}
        		})
        		.catch(error => {
            		console.error('Error:', error);
            		showAlert('withdrawnAlert', '서버 통신 중 오류가 발생했습니다.', 'error');
        		});
    		}
		}

        // 데이터 완전 삭제
        function deleteUser() {
    		if (!selectedWithdrawnUser) {
        		showAlert('withdrawnAlert', '먼저 탈퇴 회원을 선택해주세요.', 'error');
        		return;
    		}
    
    		if (confirm(`${'${selectedWithdrawnUser.nickname}'}(${'${selectedWithdrawnUser.id}'}) 데이터를 완전히 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.`)) {
        		fetch('deleteUser.jsp', {
            		method: 'POST',
            		headers: {
                		'Content-Type': 'application/x-www-form-urlencoded',
            		},
            		body: `userId=${'${encodeURIComponent(selectedWithdrawnUser.id)}'}&withdrawDate=${'${encodeURIComponent(selectedWithdrawnUser.withdrawDate)}'}`
        		})
        		.then(response => response.json())
        		.then(data => {
            		if (data.success) {
                		allWithdrawnUsers = allWithdrawnUsers.filter(u => u.id !== selectedWithdrawnUser.id);
                		displayWithdrawnUsers(allWithdrawnUsers);
                		selectedWithdrawnUser = null;
                		document.getElementById('withdrawnActions').classList.remove('show');
                		showAlert('withdrawnAlert', '데이터가 완전히 삭제되었습니다.', 'success');
            		} else {
                		showAlert('withdrawnAlert', data.message || '삭제 중 오류가 발생했습니다.', 'error');
            		}
        		})
        		.catch(error => {
            		console.error('Error:', error);
            		showAlert('withdrawnAlert', '서버 통신 중 오류가 발생했습니다.', 'error');
        		});
    		}
		}

        // 탈퇴 회원 검색
        function searchWithdrawnUsers(keyword) {
            if (!keyword.trim()) {
                displayWithdrawnUsers(allWithdrawnUsers);
                return;
            }
            
            const filtered = allWithdrawnUsers.filter(user => 
                user.id.toLowerCase().includes(keyword.toLowerCase()) ||
                user.nickname.toLowerCase().includes(keyword.toLowerCase()) ||
                user.name.toLowerCase().includes(keyword.toLowerCase())
            );
            
            displayWithdrawnUsers(filtered);
        }

        // 페이지네이션 업데이트
        function updateUserPagination(totalUsers) {
    		const totalPages = Math.ceil(totalUsers / usersPerPage);
    		const pagination = document.getElementById('userPagination');
    		pagination.innerHTML = '';
    
    		for (let i = 1; i <= totalPages; i++) {
        		const pageBtn = document.createElement('button');
        		pageBtn.className = 'page-btn' + (i === currentPage ? ' active' : '');
        		pageBtn.textContent = i;
        		pageBtn.onclick = () => {
            		currentPage = i;
            		displayUsers(allUsers);
        		};
        		pagination.appendChild(pageBtn);
    		}
		}

        // 알림 표시
        function showAlert(containerId, message, type) {
            const container = document.getElementById(containerId);
            container.innerHTML = 
                '<div class="alert alert-' + (type === 'success' ? 'success' : 'error') + '">' +
                    message +
                '</div>';
            
            setTimeout(() => {
                container.innerHTML = '';
            }, 3000);
        }

        // 페이지 로드 시 초기화
        document.addEventListener('DOMContentLoaded', function() {
            loadStats();
        });
    </script>

    <%
    // 커뮤니티 통계 데이터를 위한 DB 연결 및 데이터 조회
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        // DB 연결
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/photonation", "root", "1234");
        
        // 통계 데이터 조회를 위한 쿼리들
        String statsQuery = "SELECT "
        + "(SELECT COUNT(*) FROM user_info) as totalUsers, "
        + "(SELECT COUNT(*) FROM user_info WHERE actived = 1) as activeUsers, "
        + "(SELECT COUNT(*) FROM posts) as totalPosts, "
        + "(SELECT COUNT(*) FROM comments) as totalComments, "
        + "(SELECT COUNT(*) FROM photo_spots) as totalPhotoSpots, "
        + "(SELECT COUNT(*) FROM lost_user) as withdrawnUsers";

        
        pstmt = conn.prepareStatement(statsQuery);
        rs = pstmt.executeQuery();
        
        int totalUsers = 0, activeUsers = 0, totalPosts = 0, totalComments = 0, totalPhotoSpots = 0, withdrawnUsers = 0;
        
        if (rs.next()) {
            totalUsers = rs.getInt("totalUsers");
            activeUsers = rs.getInt("activeUsers");
            totalPosts = rs.getInt("totalPosts");
            totalComments = rs.getInt("totalComments");
            totalPhotoSpots = rs.getInt("totalPhotoSpots");
            withdrawnUsers = rs.getInt("withdrawnUsers");
        }
        rs.close();
        pstmt.close();
        
        // 게시판별 게시글 수 조회
        String boardStatsQuery = "SELECT boardType, COUNT(*) as count "
        + "FROM posts "
        + "GROUP BY boardType";

        
        pstmt = conn.prepareStatement(boardStatsQuery);
        rs = pstmt.executeQuery();
        
        StringBuilder boardLabels = new StringBuilder();
        StringBuilder boardData = new StringBuilder();
        
        while (rs.next()) {
            String boardType = rs.getString("boardType");
            int count = rs.getInt("count");
            
            String boardName = "";
            switch(boardType) {
                case "free": boardName = "자유게시판"; break;
                case "photo": boardName = "사진게시판"; break;
                case "qna": boardName = "Q&A"; break;
                case "market": boardName = "장터"; break;
            }
            
            if (boardLabels.length() > 0) {
                boardLabels.append(",");
                boardData.append(",");
            }
            boardLabels.append("'").append(boardName).append("'");
            boardData.append(count);
        }
        rs.close();
        pstmt.close();
        
        // 월별 가입 현황 조회 (최근 6개월)
        String monthlyJoinQuery = "SELECT "
        + "DATE_FORMAT(joinDate, '%Y-%m') as month, "
        + "COUNT(*) as count "
        + "FROM user_info "
        + "WHERE joinDate >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) "
        + "GROUP BY DATE_FORMAT(joinDate, '%Y-%m') "
        + "ORDER BY month";

        
        pstmt = conn.prepareStatement(monthlyJoinQuery);
        rs = pstmt.executeQuery();
        
        StringBuilder monthLabels = new StringBuilder();
        StringBuilder monthData = new StringBuilder();
        
        while (rs.next()) {
            String month = rs.getString("month");
            int count = rs.getInt("count");
            
            if (monthLabels.length() > 0) {
                monthLabels.append(",");
                monthData.append(",");
            }
            monthLabels.append("'").append(month).append("'");
            monthData.append(count);
        }
        rs.close();
        pstmt.close();
        
        // 성별 분포 조회
        String genderStatsQuery = "SELECT sex, COUNT(*) as count "
        + "FROM user_info "
        + "GROUP BY sex";

        
        pstmt = conn.prepareStatement(genderStatsQuery);
        rs = pstmt.executeQuery();
        
        int maleCount = 0, femaleCount = 0;
        while (rs.next()) {
            String sex = rs.getString("sex");
            int count = rs.getInt("count");
            if ("남성".equals(sex)) {
                maleCount = count;
            } else if ("여성".equals(sex)) {
                femaleCount = count;
            }
        }
        rs.close();
        pstmt.close();
    %>

    <script>
        // DB 데이터로 통계 업데이트
        function loadRealStats() {
            document.getElementById('totalUsers').textContent = '<%= totalUsers %>';
            document.getElementById('activeUsers').textContent = '<%= activeUsers %>';
            document.getElementById('totalPosts').textContent = '<%= totalPosts %>';
            document.getElementById('totalComments').textContent = '<%= totalComments %>';
            document.getElementById('totalPhotoSpots').textContent = '<%= totalPhotoSpots %>';
            document.getElementById('withdrawnUsers').textContent = '<%= withdrawnUsers %>';
            
            // 게시판별 게시글 차트
            const boardCtx = document.getElementById('boardChart').getContext('2d');
            new Chart(boardCtx, {
                type: 'doughnut',
                data: {
                    labels: [<%= boardLabels.toString() %>],
                    datasets: [{
                        data: [<%= boardData.toString() %>],
                        backgroundColor: [
                            '#FF6384',
                            '#36A2EB',
                            '#FFCE56',
                            '#4BC0C0'
                        ],
                        borderWidth: 0
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            position: 'bottom',
                        }
                    }
                }
            });
            
            // 월별 가입 현황 차트
            const joinCtx = document.getElementById('userJoinChart').getContext('2d');
            new Chart(joinCtx, {
                type: 'line',
                data: {
                    labels: [<%= monthLabels.toString() %>],
                    datasets: [{
                        label: '신규 가입자',
                        data: [<%= monthData.toString() %>],
                        borderColor: '#667eea',
                        backgroundColor: 'rgba(102, 126, 234, 0.1)',
                        borderWidth: 3,
                        fill: true,
                        tension: 0.4
                    }]
                },
                options: {
                    responsive: true,
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });
            
            // 성별 분포 차트
            const genderCtx = document.getElementById('genderChart').getContext('2d');
            new Chart(genderCtx, {
                type: 'bar',
                data: {
                    labels: ['남성', '여성'],
                    datasets: [{
                        label: '회원 수',
                        data: [<%= maleCount %>, <%= femaleCount %>],
                        backgroundColor: [
                            '#36A2EB',
                            '#FF6384'
                        ],
                        borderWidth: 0
                    }]
                },
                options: {
                    responsive: true,
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });
        }

        // 회원 데이터 로드
        function loadRealUsers() {
            fetch('getUserList.jsp')
                .then(response => response.json())
                .then(data => {
                    allUsers = data;
                    displayUsers(allUsers);
                })
                .catch(error => {
                    console.error('Error loading users:', error);
                    showAlert('userAlert', '회원 데이터 로드 중 오류가 발생했습니다.', 'error');
                });
        }

        // 탈퇴 회원 데이터 로드
        function loadRealWithdrawnUsers() {
            fetch('getWithdrawnUserList.jsp')
                .then(response => response.json())
                .then(data => {
                    allWithdrawnUsers = data;
                    displayWithdrawnUsers(allWithdrawnUsers);
                })
                .catch(error => {
                    console.error('Error loading withdrawn users:', error);
                    showAlert('withdrawnAlert', '탈퇴 회원 데이터 로드 중 오류가 발생했습니다.', 'error');
                });
        }

        // 회원 상태 변경
        function toggleUserStatusReal(action) {
            if (!selectedUser) {
                showAlert('userAlert', '먼저 회원을 선택해주세요.', 'error');
                return;
            }
            
            const newStatus = action === 'activate' ? 1 : 0;
            const actionText = action === 'activate' ? '활성화' : '정지';
            
            if (confirm(`${'${selectedUser.nickname}'}(${'${selectedUser.id}'}) 회원을 ${'${actionText}'}하시겠습니까?`)) {
                fetch('updateUserStatus.jsp', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'userId=' + selectedUser.id + '&status=' + newStatus
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        selectedUser.actived = newStatus;
                        displayUsers(allUsers);
                        selectedUser = null;
                        document.getElementById('userActions').classList.remove('show');
                        showAlert('userAlert', `회원 ${'${actionText}'}를 완료하였습니다.`, 'success');
                    } else {
                        showAlert('userAlert', data.message || '처리 중 오류가 발생했습니다.', 'error');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    showAlert('userAlert', '서버 통신 중 오류가 발생했습니다.', 'error');
                });
            }
        }

        // 계정 복구
        function restoreUserReal() {
            if (!selectedWithdrawnUser) {
                showAlert('withdrawnAlert', '먼저 탈퇴 회원을 선택해주세요.', 'error');
                return;
            }
            
            if (confirm(`${'${selectedWithdrawnUser.nickname}'}(${'${selectedWithdrawnUser.id}'}) 계정을 복구하시겠습니까?`)) {
                fetch('restoreUser.jsp', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'userId=' + selectedWithdrawnUser.id + '&withdrawDate=' + selectedWithdrawnUser.withdrawDate
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        allWithdrawnUsers = allWithdrawnUsers.filter(u => u.id !== selectedWithdrawnUser.id);
                        displayWithdrawnUsers(allWithdrawnUsers);
                        selectedWithdrawnUser = null;
                        document.getElementById('withdrawnActions').classList.remove('show');
                        showAlert('withdrawnAlert', '계정 복구가 완료되었습니다.', 'success');
                    } else {
                        showAlert('withdrawnAlert', data.message || '복구 중 오류가 발생했습니다.', 'error');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    showAlert('withdrawnAlert', '서버 통신 중 오류가 발생했습니다.', 'error');
                });
            }
        }

        // 데이터 완전 삭제
        function deleteUserReal() {
            if (!selectedWithdrawnUser) {
                showAlert('withdrawnAlert', '먼저 탈퇴 회원을 선택해주세요.', 'error');
                return;
            }
            
            if (confirm(`${'${selectedWithdrawnUser.nickname}'}(${'${selectedWithdrawnUser.id}'})의 데이터를 완전히 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.`)) {
                fetch('deleteUser.jsp', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: `userId=${'${selectedWithdrawnUser.id}'}&withdrawDate=${'${selectedWithdrawnUser.withdrawDate}'}`
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        allWithdrawnUsers = allWithdrawnUsers.filter(u => u.id !== selectedWithdrawnUser.id);
                        displayWithdrawnUsers(allWithdrawnUsers);
                        selectedWithdrawnUser = null;
                        document.getElementById('withdrawnActions').classList.remove('show');
                        showAlert('withdrawnAlert', '데이터가 완전히 삭제되었습니다.', 'success');
                    } else {
                        showAlert('withdrawnAlert', data.message || '삭제 중 오류가 발생했습니다.', 'error');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    showAlert('withdrawnAlert', '서버 통신 중 오류가 발생했습니다.', 'error');
                });
            }
        }

        // 각 함수 더미데이터를 실제 데이터로 변경
        function loadStats() {
            loadRealStats();
        }

        function loadUsers() {
            loadRealUsers();
        }

        function loadWithdrawnUsers() {
            loadRealWithdrawnUsers();
        }

        function toggleUserStatus(action) {
            toggleUserStatusReal(action);
        }

        function restoreUser() {
            restoreUserReal();
        }

        function deleteUser() {
            deleteUserReal();
        }
    </script>

    <%
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>console.error('Database error: " + e.getMessage() + "');</script>");
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    %>
</body>
</html>