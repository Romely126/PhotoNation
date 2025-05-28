<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    String userId = (String) session.getAttribute("userId");
    if(userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>글쓰기 - PhotoNation</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
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
        .write-container {
            max-width: 900px;
            margin: 30px auto;
            padding: 20px;
        }
        .note-editor {
            margin-bottom: 20px;
        }
        .image-preview {
            max-width: 200px;
            max-height: 200px;
            margin-top: 10px;
        }
    </style>
</head>
<body>
    <div class="write-container">
        <h2 class="mb-4">글쓰기</h2>
        <form action="${pageContext.request.contextPath}/writePostProcess" method="post" enctype="multipart/form-data">
            <div class="mb-3">
                <label for="boardType" class="form-label">게시판 선택</label>
                <select class="form-select" id="boardType" name="boardType" required>
                    <option value="">게시판을 선택하세요</option>
                    <option value="free">자유게시판</option>
                    <option value="photo">포토게시판</option>
                    <option value="qna">질문게시판</option>
                    <option value="market">장터게시판</option>
                </select>
            </div>
            
            <div class="mb-3">
                <label for="title" class="form-label">제목</label>
                <input type="text" class="form-control" id="title" name="title" required>
            </div>
            
            <div class="mb-3">
                <label for="content" class="form-label">내용</label>
                <textarea id="content" name="content" required></textarea>
            </div>

            <!-- 이미지 업로드 필드 -->
            <div class="mb-3">
                <label for="images" class="form-label">이미지 첨부</label>
                <input type="file" class="form-control" id="images" name="images" multiple accept="image/*" onchange="previewImages(this)">
                <div id="imagePreviewContainer" class="mt-2 d-flex flex-wrap gap-2"></div>
            </div>
            
            <div class="d-flex justify-content-between">
                <button type="button" class="btn btn-secondary" onclick="history.back()">취소</button>
                <button type="submit" class="btn btn-primary">등록</button>
            </div>
        </form>
    </div>

    <script>
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

        // 이미지 미리보기 함수
        function previewImages(input) {
            const container = $('#imagePreviewContainer');
            container.empty();

            if (input.files) {
                for(let i = 0; i < input.files.length; i++) {
                    const reader = new FileReader();
                    reader.onload = function(e) {
                        container.append(`
                            <div class="position-relative">
                                <img src="${e.target.result}" class="image-preview">
                            </div>
                        `);
                    }
                    reader.readAsDataURL(input.files[i]);
                }
            }
        }
    </script>
</body>
</html> 