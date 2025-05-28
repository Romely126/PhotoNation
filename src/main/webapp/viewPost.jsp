<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%
String userNickname = (String) session.getAttribute("userNickname");
String userId = (String) session.getAttribute("userId");
String postId = request.getParameter("postId");
int postIdInt = Integer.parseInt(postId);

    // 데이터베이스 연결 정보 (실제 환경에 맞게 수정)
    String jdbcUrl = "jdbc:mysql://localhost:3306/photonation";
    String dbUser = "root";
    String dbPassword = "1234";
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    // 게시글 정보
    String title = "";
    String content = "";
    String author = "";
    String authorId = "";
    String boardType = "";
    String createdAt = "";
    int views = 0;
    int likes = 0;
    boolean isLiked = false;
    String imageUrl = "";
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);
        
        // 조회수 증가
        String updateViewSql = "UPDATE posts SET viewCount = viewCount + 1 WHERE postId = ?";
        pstmt = conn.prepareStatement(updateViewSql);
        pstmt.setInt(1, postIdInt);
        pstmt.executeUpdate();
        pstmt.close();
        
        // 게시글 정보 조회 (posts 테이블에 nickname이 저장되어 있음)
        String postSql = "SELECT * FROM posts WHERE postId = ?";
        pstmt = conn.prepareStatement(postSql);
        pstmt.setInt(1, postIdInt);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            title = rs.getString("title");
            content = rs.getString("content");
            author = rs.getString("nickname");
            authorId = rs.getString("userId");
            boardType = rs.getString("boardType");
            createdAt = rs.getString("createdAt");
            views = rs.getInt("viewCount");
            likes = rs.getInt("likeCount");
        } else {
            // 게시글이 존재하지 않는 경우
            response.sendRedirect("main.jsp");
            return;
        }
        rs.close();
        pstmt.close();
        
        // 게시글 이미지 조회
        String imageSql = "SELECT filePath FROM post_images WHERE postId = ? LIMIT 1";
        pstmt = conn.prepareStatement(imageSql);
        pstmt.setInt(1, postIdInt);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            imageUrl = rs.getString("filePath");
        }
        rs.close();
        pstmt.close();
        
        // 좋아요 여부 확인
        if (userId != null) {
            String likeSql = "SELECT COUNT(*) FROM post_reactions WHERE postId = ? AND userId = ? AND reactionType = 'like'";
            pstmt = conn.prepareStatement(likeSql);
            pstmt.setInt(1, postIdInt);
            pstmt.setString(2, userId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                isLiked = rs.getInt(1) > 0;
            }
            rs.close();
            pstmt.close();
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("main.jsp");
        return;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>PhotoNation - <%= title %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
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
        .post-header {
            border-bottom: 2px solid #dee2e6;
            padding-bottom: 15px;
            margin-bottom: 20px;
        }
        .post-meta {
            color: #6c757d;
            font-size: 0.9em;
        }
        .post-content {
            line-height: 1.8;
            margin-bottom: 30px;
            min-height: 200px;
        }
        .post-image {
            max-width: 100%;
            height: auto;
            border-radius: 8px;
            margin: 15px 0;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .action-buttons {
            border-top: 1px solid #dee2e6;
            padding-top: 15px;
            margin: 20px 0;
        }
        .like-btn {
            transition: all 0.3s ease;
        }
        .like-btn.liked {
            color: #dc3545;
        }
        .comment-section {
            background-color: #f8f9fa;
            border-radius: 8px;
            padding: 20px;
            margin-top: 30px;
        }
        .comment-item {
            background-color: white;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
            border-left: 3px solid #007bff;
        }
        .comment-author {
            font-weight: bold;
            color: #495057;
        }
        .comment-date {
            color: #6c757d;
            font-size: 0.85em;
        }
        .comment-content {
            margin-top: 8px;
            line-height: 1.6;
        }
        .comment-form {
            background-color: white;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
        }
        .board-type-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.8em;
            font-weight: 500;
            margin-bottom: 10px;
        }
        .board-free { background-color: #e3f2fd; color: #1976d2; }
        .board-photo { background-color: #f3e5f5; color: #7b1fa2; }
        .board-qna { background-color: #e8f5e8; color: #388e3c; }
        .board-market { background-color: #fff3e0; color: #f57c00; }
        
        .btn-back {
            background-color: #6c757d;
            border-color: #6c757d;
            color: white;
        }
        .btn-back:hover {
            background-color: #5a6268;
            border-color: #545b62;
            color: white;
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

    <!-- 메인 컨텐츠 -->
    <div class="container mt-4" style="max-width: 80%;">
        <div class="row">
            <div class="col-md-12">
                <!-- 뒤로가기 버튼 -->
                <div class="mb-3">
                    <button onclick="location.href='main.jsp'" class="btn btn-back">
                        <i class="fas fa-arrow-left"></i> 목록으로
                    </button>
                </div>

                <!-- 게시글 내용 -->
                <div class="card">
                    <div class="card-body">
                        <!-- 게시글 헤더 -->
                        <div class="post-header">
                            <% 
                                String boardTypeKor = "";
                                String badgeClass = "";
                                switch(boardType) {
                                    case "free":
                                        boardTypeKor = "자유게시판";
                                        badgeClass = "board-free";
                                        break;
                                    case "photo":
                                        boardTypeKor = "포토게시판";
                                        badgeClass = "board-photo";
                                        break;
                                    case "qna":
                                        boardTypeKor = "질문게시판";
                                        badgeClass = "board-qna";
                                        break;
                                    case "market":
                                        boardTypeKor = "장터게시판";
                                        badgeClass = "board-market";
                                        break;
                                    default:
                                        boardTypeKor = "게시판";
                                        badgeClass = "board-free";
                                }
                            %>
                            <span class="board-type-badge <%= badgeClass %>"><%= boardTypeKor %></span>
                            <h2 class="mb-3"><%= title %></h2>
                            <div class="post-meta">
                                <span><i class="fas fa-user"></i> <%= author %></span>
                                <span class="ms-3"><i class="fas fa-calendar"></i> <%= createdAt %></span>
                                <span class="ms-3"><i class="fas fa-eye"></i> 조회 <%= views %></span>
                                <span class="ms-3"><i class="fas fa-heart"></i> 좋아요 <span id="likeCount"><%= likes %></span></span>
                            </div>
                        </div>

                        <!-- 게시글 내용 -->
                        <div class="post-content">
                            <% if (imageUrl != null && !imageUrl.trim().isEmpty()) { %>
                                <img src="<%= imageUrl %>" alt="게시글 이미지" class="post-image">
                            <% } %>
                            <div style="white-space: pre-wrap;"><%= content %></div>
                        </div>

                        <!-- 액션 버튼들 -->
                        <div class="action-buttons">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <% if (userId != null) { %>
                                        <button class="btn btn-outline-danger like-btn <%= isLiked ? "liked" : "" %>" 
                                                onclick="toggleLike('<%= postId %>')">
                                            <i class="fas fa-heart"></i> 
                                            <span id="likeText"><%= isLiked ? "좋아요 취소" : "좋아요" %></span>
                                        </button>
                                    <% } %>
                                </div>
                                <div>
                                    <% if (userId != null && userId.equals(authorId)) { %>
                                        <a href="editPost.jsp?postId=<%= postId %>" class="btn btn-outline-primary btn-sm">
                                            <i class="fas fa-edit"></i> 수정
                                        </a>
                                        <button class="btn btn-outline-danger btn-sm" onclick="deletePost(<%= postId %>)">
                                            <i class="fas fa-trash"></i> 삭제
                                        </button>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 댓글 섹션 -->
                <div class="comment-section">
                    <h5 class="mb-3"><i class="fas fa-comments"></i> 댓글</h5>
                    
                    <!-- 댓글 작성 폼 -->
                    <% if (userId != null) { %>
                        <div class="comment-form">
                            <div class="mb-3">
                                <textarea class="form-control" id="commentContent" rows="3" 
                                          placeholder="댓글을 입력하세요..."></textarea>
                            </div>
                            <div class="text-end">
                                <button class="btn btn-primary" onclick="addComment()">
                                    <i class="fas fa-paper-plane"></i> 댓글 작성
                                </button>
                            </div>
                        </div>
                    <% } else { %>
                        <div class="comment-form text-center">
                            <p class="text-muted">댓글을 작성하려면 <a href="login.jsp">로그인</a>해주세요.</p>
                        </div>
                    <% } %>

                    <!-- 댓글 목록 -->
                    <div id="commentList">
                        <!-- 댓글들이 여기에 동적으로 로드됩니다 -->
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
 // 좋아요 토글 함수 (수정된 버전)
    function toggleLike(postId) {
        <% if (userId == null) { %>
            alert('로그인이 필요합니다.');
            return;
        <% } %>
        
        $.ajax({
            url: 'toggleLike.jsp',
            method: 'POST',
            data: { postId: postId },
            dataType: 'json', // 응답 타입을 JSON으로 명시
            success: function(result) {
                if (result.success) {
                    $('#likeCount').text(result.likeCount);
                    const btn = $('.like-btn');
                    const text = $('#likeText');
                    
                    if (result.isLiked) {
                        btn.addClass('liked');
                        text.text('좋아요 취소');
                    } else {
                        btn.removeClass('liked');
                        text.text('좋아요');
                    }
                } else {
                    alert(result.message || '좋아요 처리에 실패했습니다.');
                }
            },
            error: function(xhr, status, error) {
                console.error('AJAX Error:', error);
                console.error('Response:', xhr.responseText);
                alert('좋아요 처리 중 오류가 발생했습니다.');
            }
        });
    }

 // 댓글 작성 함수 (수정된 버전)
    function addComment() {
        const content = $('#commentContent').val().trim();
        if (!content) {
            alert('댓글 내용을 입력해주세요.');
            return;
        }

        $.ajax({
            url: 'addComment.jsp',
            method: 'POST',
            data: {
                postId: <%= postId %>,
                content: content
            },
            dataType: 'json',
            success: function(result) {
                if (result.success) {
                    $('#commentContent').val('');
                    loadComments();
                } else {
                    alert(result.message || '댓글 작성에 실패했습니다.');
                }
            },
            error: function(xhr, status, error) {
                console.error('AJAX Error:', error);
                alert('댓글 작성 중 오류가 발생했습니다.');
            }
        });
    }

 // 댓글 삭제 함수 (수정된 버전)
    function deleteComment(commentId) {
        if (confirm('댓글을 삭제하시겠습니까?')) {
            $.ajax({
                url: 'deleteComment.jsp',
                method: 'POST',
                data: { commentId: commentId },
                dataType: 'json',
                success: function(result) {
                    if (result.success) {
                        loadComments();
                    } else {
                        alert(result.message || '댓글 삭제에 실패했습니다.');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('AJAX Error:', error);
                    alert('댓글 삭제 중 오류가 발생했습니다.');
                }
            });
        }
    }

 // 게시글 삭제 함수 (수정된 버전)
    function deletePost(postId) {
        if (confirm('게시글을 삭제하시겠습니까?')) {
            $.ajax({
                url: 'deletePost.jsp',
                method: 'POST',
                data: { postId: postId },
                dataType: 'json',
                success: function(result) {
                    if (result.success) {
                        alert('게시글이 삭제되었습니다.');
                        window.location.href = 'main.jsp';
                    } else {
                        alert(result.message || '게시글 삭제에 실패했습니다.');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('AJAX Error:', error);
                    alert('게시글 삭제 중 오류가 발생했습니다.');
                }
            });
        }
    }

        // 댓글 목록 로드 함수
        function loadComments() {
            $.ajax({
                url: 'getComments.jsp',
                method: 'GET',
                data: { postId: <%= postId %> },
                success: function(response) {
                    $('#commentList').html(response);
                },
                error: function() {
                    $('#commentList').html('<p class="text-muted">댓글을 불러오는 중 오류가 발생했습니다.</p>');
                }
            });
        }

        // 페이지 로드 시 댓글 로드
        $(document).ready(function() {
            loadComments();
        });
    </script>
</body>
</html>