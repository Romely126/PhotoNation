<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>게시글 수정</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <!-- Bootstrap -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <!-- Summernote CSS -->
    <link href="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote-lite.min.css" rel="stylesheet">
    <!-- Summernote JS -->
    <script src="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote-lite.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/lang/summernote-ko-KR.min.js"></script>
    
    <style>
        .image-preview {
            position: relative;
            display: inline-block;
            margin: 10px;
        }
        .image-preview img {
            max-width: 200px;
            max-height: 200px;
            border-radius: 8px;
            border: 2px solid #ddd;
        }
        .image-preview .remove-btn {
            position: absolute;
            top: -8px;
            right: -8px;
            background: #dc3545;
            color: white;
            border: none;
            border-radius: 50%;
            width: 24px;
            height: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            font-size: 12px;
        }
        .file-upload-area {
            border: 2px dashed #ddd;
            border-radius: 8px;
            padding: 40px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
            margin: 20px 0;
        }
        .file-upload-area:hover {
            border-color: #007bff;
            background-color: #f8f9fa;
        }
        .file-upload-area.dragover {
            border-color: #007bff;
            background-color: #e3f2fd;
        }
        .badge-board {
            font-size: 12px;
        }
        .write-container {
            max-width: 900px;
            margin: 30px auto;
            padding: 20px;
        }
        .note-editor {
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
<%
    request.setCharacterEncoding("UTF-8");
    
    String postIdParam = request.getParameter("postId");
    String currentUserId = (String) session.getAttribute("userId");
    
    // 로그인 체크
    if (currentUserId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    if (postIdParam == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    int postId = Integer.parseInt(postIdParam);
    
    String dbURL = "jdbc:mysql://localhost:3306/photonation?characterEncoding=utf8&serverTimezone=Asia/Seoul";
    String dbUser = "root";
    String dbPassword = "1234";
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    // 게시글 정보 변수들
    String title = "";
    String content = "";
    String nickname = "";
    String boardType = "";
    Timestamp createdAt = null;
    String postUserId = "";
    List<String> images = new ArrayList<>();
    boolean hasPermission = false;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
        
        // 게시글 정보 조회 및 권한 확인
        String postQuery = "SELECT * FROM posts WHERE postId = ?";
        pstmt = conn.prepareStatement(postQuery);
        pstmt.setInt(1, postId);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            title = rs.getString("title");
            content = rs.getString("content");
            nickname = rs.getString("nickname");
            boardType = rs.getString("boardType");
            createdAt = rs.getTimestamp("createdAt");
            postUserId = rs.getString("userId");
            
            // 권한 확인 (작성자만 수정 가능)
            hasPermission = currentUserId.equals(postUserId);
        } else {
            response.sendRedirect("index.jsp");
            return;
        }
        rs.close();
        pstmt.close();
        
        // 권한이 없으면 리다이렉트
        if (!hasPermission) {
            response.sendRedirect("viewPost.jsp?postId=" + postId);
            return;
        }
        
        // 게시글 이미지 조회 (fileName 대신 originalName 사용)
        String imageQuery = "SELECT fileName, originalName FROM post_images WHERE postId = ? ORDER BY imageId";
        pstmt = conn.prepareStatement(imageQuery);
        pstmt.setInt(1, postId);
        rs = pstmt.executeQuery();
        while (rs.next()) {
            images.add(rs.getString("fileName"));
        }
        rs.close();
        pstmt.close();
        
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("index.jsp");
        return;
    }
    
    // 게시판 타입별 정보
    String boardName = "";
    String badgeClass = "secondary";
    switch(boardType) {
        case "free": boardName = "자유게시판"; badgeClass = "primary"; break;
        case "photo": boardName = "포토게시판"; badgeClass = "success"; break;
        case "qna": boardName = "질문게시판"; badgeClass = "warning"; break;
        case "market": boardName = "장터게시판"; badgeClass = "danger"; break;
    }
%>

<div class="write-container">
    <!-- 뒤로가기 버튼 -->
    <div class="mb-3">
        <button type="button" class="btn btn-outline-secondary" onclick="history.back()">
            <i class="fas fa-arrow-left"></i> 취소
        </button>
    </div>
    
    <!-- 게시글 수정 폼 -->
    <div class="card">
        <div class="card-header">
            <div class="d-flex align-items-center">
                <span class="badge bg-<%= badgeClass %> badge-board me-2"><%= boardName %></span>
                <h4 class="mb-0">게시글 수정</h4>
            </div>
        </div>
        
        <div class="card-body">
            <form id="editPostForm" enctype="multipart/form-data">
                <input type="hidden" name="postId" value="<%= postId %>">
                
                <!-- 제목 입력 -->
                <div class="mb-3">
                    <label for="title" class="form-label">제목 <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="title" name="title" value="<%= title %>" required maxlength="200">
                </div>
                
                <!-- 내용 입력 (Summernote 에디터) -->
                <div class="mb-3">
                    <label for="content" class="form-label">내용 <span class="text-danger">*</span></label>
                    <textarea id="content" name="content" required><%= content %></textarea>
                </div>
                
                <!-- 기존 이미지 -->
                <% if (!images.isEmpty()) { %>
                <div class="mb-3">
                    <label class="form-label">기존 이미지</label>
                    <div id="existingImages">
                        <% for (int i = 0; i < images.size(); i++) { %>
                        <div class="image-preview" data-filename="<%= images.get(i) %>">
                            <img src="uploads/<%= images.get(i) %>" alt="기존 이미지">
                            <button type="button" class="remove-btn" onclick="removeExistingImage(this, '<%= images.get(i) %>')">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                        <% } %>
                    </div>
                </div>
                <% } %>
                
                <!-- 새 이미지 업로드 -->
                <div class="mb-3">
                    <label for="imageFiles" class="form-label">새 이미지 추가 (선택사항)</label>
                    <div class="file-upload-area" onclick="document.getElementById('imageFiles').click()">
                        <i class="fas fa-cloud-upload-alt fa-2x mb-2 text-muted"></i>
                        <p class="mb-0">클릭하여 이미지를 선택하거나 드래그하여 업로드하세요</p>
                        <small class="text-muted">JPG, PNG, GIF 파일만 가능 (최대 5MB)</small>
                    </div>
                    <input type="file" class="form-control d-none" id="imageFiles" name="imageFiles" multiple accept="image/*">
                    <div id="newImagePreviews"></div>
                </div>
                
                <!-- 삭제할 이미지 목록 (숨김 필드) -->
                <input type="hidden" id="imagesToDelete" name="imagesToDelete" value="">
                
                <!-- 버튼 -->
                <div class="d-flex justify-content-end gap-2">
                    <button type="button" class="btn btn-secondary" onclick="history.back()">취소</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> 수정 완료
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
let imagesToDelete = [];
let newImages = [];

// Summernote 에디터 초기화
$(document).ready(function() {
    $('#content').summernote({
        lang: 'ko-KR',
        height: 400,
        callbacks: {
            onImageUpload: function(files) {
                for(let i = 0; i < files.length; i++) {
                    uploadImage(files[i], this);
                }
            }
        },
        toolbar: [
            ['style', ['style']],
            ['font', ['bold', 'underline', 'clear']],
            ['color', ['color']],
            ['para', ['ul', 'ol', 'paragraph']],
            ['table', ['table']],
            ['insert', ['link', 'picture']],
            ['view', ['fullscreen', 'codeview', 'help']]
        ]
    });
});

// Summernote 에디터 내 이미지 업로드 처리
function uploadImage(file, editor) {
    const formData = new FormData();
    formData.append('file', file);
    
    $.ajax({
        url: 'uploadImage',
        method: 'POST',
        data: formData,
        processData: false,
        contentType: false,
        success: function(response) {
            if (response.error) {
                alert(response.error);
                return;
            }
            $(editor).summernote('insertImage', response.url);
        },
        error: function() {
            alert('이미지 업로드에 실패했습니다.');
        }
    });
}

// 파일 업로드 영역 드래그 앤 드롭 처리
const fileUploadArea = document.querySelector('.file-upload-area');
const imageFilesInput = document.getElementById('imageFiles');

fileUploadArea.addEventListener('dragover', function(e) {
    e.preventDefault();
    this.classList.add('dragover');
});

fileUploadArea.addEventListener('dragleave', function(e) {
    e.preventDefault();
    this.classList.remove('dragover');
});

fileUploadArea.addEventListener('drop', function(e) {
    e.preventDefault();
    this.classList.remove('dragover');
    const files = Array.from(e.dataTransfer.files).filter(file => file.type.startsWith('image/'));
    handleNewImages(files);
});

// 파일 선택 처리
imageFilesInput.addEventListener('change', function(e) {
    handleNewImages(Array.from(e.target.files));
});

// 새 이미지 처리
function handleNewImages(files) {
    const maxSize = 5 * 1024 * 1024; // 5MB
    const validFiles = [];
    
    for (let file of files) {
        if (file.size > maxSize) {
            alert(`${file.name}은(는) 5MB를 초과합니다.`);
            continue;
        }
        validFiles.push(file);
    }
    
    newImages = newImages.concat(validFiles);
    displayNewImagePreviews();
}

// 새 이미지 미리보기 표시
function displayNewImagePreviews() {
    const container = document.getElementById('newImagePreviews');
    container.innerHTML = '';
    
    newImages.forEach((file, index) => {
        const reader = new FileReader();
        reader.onload = function(e) {
            const div = document.createElement('div');
            div.className = 'image-preview';
            div.innerHTML = `
                <img src="${e.target.result}" alt="새 이미지">
                <button type="button" class="remove-btn" onclick="removeNewImage(${index})">
                    <i class="fas fa-times"></i>
                </button>
            `;
            container.appendChild(div);
        };
        reader.readAsDataURL(file);
    });
}

// 기존 이미지 삭제
function removeExistingImage(button, filename) {
    if (confirm('이 이미지를 삭제하시겠습니까?')) {
        imagesToDelete.push(filename);
        button.parentElement.remove();
        document.getElementById('imagesToDelete').value = imagesToDelete.join(',');
    }
}

// 새 이미지 삭제
function removeNewImage(index) {
    newImages.splice(index, 1);
    displayNewImagePreviews();
}

// 폼 제출 처리
document.getElementById('editPostForm').addEventListener('submit', function(e) {
    e.preventDefault();
    
    const title = document.getElementById('title').value.trim();
    const content = $('#content').summernote('code'); // Summernote에서 HTML 내용 가져오기
    
    if (!title) {
        alert('제목을 입력해주세요.');
        return;
    }
    
    if (!content || content.trim() === '' || content === '<p><br></p>') {
        alert('내용을 입력해주세요.');
        return;
    }
    
    // FormData 생성
    const formData = new FormData();
    formData.append('postId', '<%= postId %>');
    formData.append('title', title);
    formData.append('content', content);
    formData.append('imagesToDelete', imagesToDelete.join(','));
    
    // 새 이미지 파일 추가
    newImages.forEach(file => {
        formData.append('newImages', file);
    });
    
    // 버튼 비활성화
    const submitBtn = document.querySelector('button[type="submit"]');
    submitBtn.disabled = true;
    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> 수정 중...';
    
    // 서버로 전송
    fetch('updatePost.jsp', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert('게시글이 수정되었습니다.');
            window.location.href = 'viewPost.jsp?postId=<%= postId %>';
        } else {
            alert('게시글 수정에 실패했습니다: ' + (data.message || '알 수 없는 오류'));
            submitBtn.disabled = false;
            submitBtn.innerHTML = '<i class="fas fa-save"></i> 수정 완료';
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('게시글 수정 중 오류가 발생했습니다.');
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-save"></i> 수정 완료';
    });
});
</script>

<%
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
%>
</body>
</html>