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
    <title>게시글 작성 - PhotoNation</title>
    <link rel="icon" href="img/favicon.ico">
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
        .template-notice {
            background-color: #e7f3ff;
            border: 1px solid #b3d7ff;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 15px;
            font-size: 14px;
            color: #0066cc;
        }
        .template-notice.qna {
            background-color: #fff3e0;
            border-color: #ffcc80;
            color: #e65100;
        }
    </style>
</head>
<body>
    <div class="write-container">
        <h2 class="mb-4">게시글 작성</h2>
        <form action="${pageContext.request.contextPath}/writePostProcess" method="post" enctype="multipart/form-data">
            <div class="mb-3">
                <label for="boardType" class="form-label">게시판 선택</label>
                <select class="form-select" id="boardType" name="boardType" required onchange="handleBoardTypeChange()">
                    <option value="">게시판을 선택하세요</option>
                    <option value="free">자유게시판</option>
                    <option value="photo">포토게시판</option>
                    <option value="qna">질문게시판</option>
                    <option value="market">장터게시판</option>
                </select>
            </div>
            
            <!-- 템플릿 안내 메시지 -->
            <div id="marketTemplateNotice" class="template-notice" style="display: none;">
                <i class="fas fa-info-circle"></i> 장터게시판 양식이 자동으로 적용되었습니다.
            </div>
            
            <div id="qnaTemplateNotice" class="template-notice qna" style="display: none;">
                <i class="fas fa-question-circle"></i> 질문게시판 양식이 자동으로 적용되었습니다.
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
        let summernoteInitialized = false;
        
        // 게시판별 템플릿 정의
        const templates = {
            market: {
                content: `
<h4><b>📦 상품 정보</b></h4>
<b>상품명:</b> [상품명을 입력하세요]<br>
<b>가격:</b> [가격을 입력하세요] 원<br>
<b>거래방법:</b> [직거래/택배거래/기타]<br>
<b>거래지역:</b> [거래 가능한 지역을 입력하세요]<br>
<b>상품상태:</b> [새상품/중고-상/중고-중/중고-하]
<hr>
<h4><b>📝 상품 설명</b></h4>
[상품에 대한 자세한 설명을 입력하세요]<br>
<b>구매시기</b>: <br> 
<b>사용기간</b>: <br>
<b>하자여부</b>: <br> 
<b>포함구성</b>:  
<hr>
<h4><b>📋 거래 안내</b></h4>
<b>연락처:</b> [연락 가능한 방법을 입력하세요]<br>
<b>거래시간:</b> [거래 가능한 시간대를 입력하세요]<br>
<b>기타사항:</b> [추가로 알려드릴 내용이 있다면 입력하세요]
<hr>
<h4><b>📷 상품 사진</b></h4>
<div style="color: #666; font-size: 14px;">
상품의 실제 사진을 첨부해주세요. 여러 각도에서 촬영한 사진을 올리시면 구매자에게 더 도움이 됩니다. <br>
</div>
<div style="margin-bottom: 20px;"><i>※ 이미지는 위의 '이미지 첨부' 버튼을 이용해서 업로드하세요</i></div>
<hr>
<div><small style="color: #666;">
⚠️ <b>거래 주의사항</b><br>
• 직거래 시 안전한 장소에서 만나세요<br>
• 선입금 요구 시 사기일 수 있으니 주의하세요<br>
• 상품 확인 후 거래하시기 바랍니다
</small></div>
                `,
                titlePlaceholder: '한번 쓰고 보관만 해둔 니콘 찌로공 팝니다.',
                noticeId: 'marketTemplateNotice'
            },
            qna: {
                content: `
<h4><b>❓ 질문 내용</b></h4>
<p><b>질문 분야:</b> [바디,렌즈추천/촬영방법/보정작업/출사지추천 등]</p>
<br>
<hr>

<h4><b>🔍 알아본 정보</b></h4>
<p>[문제 해결을 위해 시도해본 방법들을 적어주세요]</p>
<hr>

<h4><b>🎯 요구 사항</b></h4>
<p>[장비 추천을 받을 경우 이 부분을 상세히 작성해주세요]<br>스펙, 예산, 사용 환경, 원하는 기능, 현재 사용하는 주변장비 등.</p>

<hr>

<p><small style="color: #666;">
💡 <b>질문 작성 팁</b><br>
• 구체적이고 명확한 질문일수록 좋은 답변을 받을 수 있습니다<br>
• 관련 정보나 사진을 첨부하시면 답변에 도움이 됩니다.
</small></p>
                `,
                titlePlaceholder: '예: 시그마 BF 사냐??',
                noticeId: 'qnaTemplateNotice'
            }
        };

        $(document).ready(function() {
            initializeSummernote();
        });

        function initializeSummernote() {
            $('#content').summernote({
                lang: 'ko-KR',
                height: 550,
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
            summernoteInitialized = true;
        }

        // 게시판 타입 변경 시 처리 
        function handleBoardTypeChange() {
            const boardType = $('#boardType').val();
            
            // 모든 알림 숨기기
            hideAllNotices();
            
            // 제목 placeholder 초기화
            $('#title').attr('placeholder', '');
            
            if (templates[boardType]) {
                // 해당 게시판의 템플릿 적용
                applyTemplate(boardType);
            } else {
                // 템플릿이 없는 게시판의 경우 내용 초기화
                clearContent();
            }
        }

        // 템플릿 적용 함수
        function applyTemplate(boardType) {
            const template = templates[boardType];
            
            if (summernoteInitialized && template) {
                // 템플릿 내용 적용
                $('#content').summernote('code', template.content);
                
                // 알림 표시
                $(`#${template.noticeId}`).show();
                
                // 제목 placeholder 설정
                if (template.titlePlaceholder && $('#title').val() === '') {
                    $('#title').attr('placeholder', template.titlePlaceholder);
                }
            }
        }

        // 모든 템플릿 알림 숨기기
        function hideAllNotices() {
            $('#marketTemplateNotice').hide();
            $('#qnaTemplateNotice').hide();
        }

        // 내용 초기화
        function clearContent() {
            if (summernoteInitialized) {
                const currentContent = $('#content').summernote('code').trim();
                
                // 현재 내용이 템플릿 중 하나와 일치하는지 확인
                const isTemplate = Object.values(templates).some(template => 
                    currentContent === template.content.trim()
                );
                
                // 템플릿 내용이라면 초기화
                if (isTemplate) {
                    $('#content').summernote('code', '');
                }
            }
        }

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