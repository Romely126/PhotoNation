<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>

<%
    String userId = (String) session.getAttribute("userId");
    String userNickname = (String) session.getAttribute("userNickname");
    
    if(userId == null || userNickname == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 파일 업로드 설정
    String uploadPath = application.getRealPath("/uploads");
    File uploadDir = new File(uploadPath);
    if (!uploadDir.exists()) {
        uploadDir.mkdir();
    }
    int maxSize = 10 * 1024 * 1024; // 10MB

    try {
        // MultipartRequest 생성
        MultipartRequest multi = new MultipartRequest(
            request,
            uploadPath,
            maxSize,
            "UTF-8",
            new DefaultFileRenamePolicy()
        );

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            // DB 연결
            Class.forName("com.mysql.cj.jdbc.Driver");
            String dbUrl = "jdbc:mysql://localhost:3306/photonation";
            conn = DriverManager.getConnection(dbUrl, "root", "1234");
            conn.setAutoCommit(false); // 트랜잭션 시작
            
            // 게시글 정보 저장
            String sql = "INSERT INTO posts (userId, nickname, boardType, title, content, createdAt) VALUES (?, ?, ?, ?, ?, NOW())";
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setString(1, userId);
            pstmt.setString(2, userNickname);
            pstmt.setString(3, multi.getParameter("boardType"));
            pstmt.setString(4, multi.getParameter("title"));
            pstmt.setString(5, multi.getParameter("content"));
            pstmt.executeUpdate();
            
            // 생성된 게시글의 ID 가져오기
            rs = pstmt.getGeneratedKeys();
            int postId = 0;
            if(rs.next()) {
                postId = rs.getInt(1);
            }
            
            // 이미지 파일 처리
            Enumeration files = multi.getFileNames();
            while(files.hasMoreElements()) {
                String fieldName = (String)files.nextElement();
                String fileName = multi.getFilesystemName(fieldName);
                String originalFileName = multi.getOriginalFileName(fieldName);
                File file = multi.getFile(fieldName);
                
                if(fileName != null && file != null) {
                    // 이미지 정보 DB 저장
                    sql = "INSERT INTO post_images (postId, fileName, originalName, fileSize, filePath, fileType) VALUES (?, ?, ?, ?, ?, ?)";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setInt(1, postId);
                    pstmt.setString(2, fileName);
                    pstmt.setString(3, originalFileName);
                    pstmt.setLong(4, file.length());
                    pstmt.setString(5, "uploads/" + fileName);
                    pstmt.setString(6, getServletContext().getMimeType(fileName));
                    pstmt.executeUpdate();
                }
            }
            
            conn.commit(); // 트랜잭션 커밋
            response.sendRedirect("main.jsp");
            
        } catch(Exception e) {
            if(conn != null) try { conn.rollback(); } catch(Exception ex) {} // 트랜잭션 롤백
            e.printStackTrace();
            %>
            <html>
            <head>
                <meta charset="UTF-8">
                <script>
                    alert('글 작성 중 오류가 발생했습니다.');
                    history.back();
                </script>
            </head>
            <body></body>
            </html>
            <%
            return;
        } finally {
            if(rs != null) try { rs.close(); } catch(Exception e) {}
            if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
            if(conn != null) try {
                conn.setAutoCommit(true);
                conn.close();
            } catch(Exception e) {}
        }
        
    } catch(Exception e) {
        e.printStackTrace();
        %>
        <html>
        <head>
            <meta charset="UTF-8">
            <script>
                alert('파일 업로드 중 오류가 발생했습니다.');
                history.back();
            </script>
        </head>
        <body></body>
        </html>
        <%
        return;
    }
%> 