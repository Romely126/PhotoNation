<%@ page contentType="application/json; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.nio.file.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="jakarta.servlet.http.Part" %>
<%@ page import="jakarta.servlet.annotation.MultipartConfig" %>
<%@ page contentType="application/json; charset=UTF-8" language="java" %>
<%@ page import="jakarta.servlet.annotation.MultipartConfig" %>
<%@ page session="true" %>


<%!
    // 메서드 선언부 - 여기서만 메서드 선언 가능
    String getPartValue(HttpServletRequest request, String partName) {
        try {
            Part part = request.getPart(partName);
            if (part != null) {
                BufferedReader reader = new BufferedReader(new InputStreamReader(part.getInputStream(), "UTF-8"));
                StringBuilder sb = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
                reader.close();
                return sb.toString();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
%>

<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    String currentUserId = (String) session.getAttribute("userId");
    JSONObject jsonResponse = new JSONObject();
    
    if (currentUserId == null) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "로그인이 필요합니다.");
        out.print(jsonResponse.toString());
        return;
    }
    
    // multipart에서 파라미터 추출
    String postIdParam = getPartValue(request, "postId");
    String title = getPartValue(request, "title");
    String content = getPartValue(request, "content");
    String imagesToDeleteParam = getPartValue(request, "imagesToDelete");
    
    if (postIdParam == null || title == null || content == null) {
        System.out.println("postIdParam = " + postIdParam);
        System.out.println("title = " + title);
        System.out.println("content = " + content);

        jsonResponse.put("success", false);
        jsonResponse.put("message", "필수 파라미터가 누락되었습니다.");
        out.print(jsonResponse.toString());
        return;
    }

    int postId = Integer.parseInt(postIdParam);
    
    String dbURL = "jdbc:mysql://localhost:3306/photonation?characterEncoding=utf8&serverTimezone=Asia/Seoul";
    String dbUser = "root";
    String dbPassword = "1234";
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
        conn.setAutoCommit(false);
        
        // 게시글 권한 확인
        String checkQuery = "SELECT userId FROM posts WHERE postId = ?";
        pstmt = conn.prepareStatement(checkQuery);
        pstmt.setInt(1, postId);
        rs = pstmt.executeQuery();
        
        if (!rs.next()) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "존재하지 않는 게시글입니다.");
            out.print(jsonResponse.toString());
            return;
        }
        
        String postUserId = rs.getString("userId");
        if (!currentUserId.equals(postUserId)) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "수정 권한이 없습니다.");
            out.print(jsonResponse.toString());
            return;
        }
        rs.close();
        pstmt.close();
        
        // 게시글 정보 업데이트
        String updatePostQuery = "UPDATE posts SET title = ?, content = ?, updatedAt = NOW() WHERE postId = ?";
        pstmt = conn.prepareStatement(updatePostQuery);
        pstmt.setString(1, title);
        pstmt.setString(2, content);
        pstmt.setInt(3, postId);
        int updatedRows = pstmt.executeUpdate();
        pstmt.close();
        
        if (updatedRows == 0) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "게시글 업데이트에 실패했습니다.");
            out.print(jsonResponse.toString());
            return;
        }
        
        // 삭제할 이미지 처리
        if (imagesToDeleteParam != null && !imagesToDeleteParam.trim().isEmpty()) {
            String[] imagesToDelete = imagesToDeleteParam.split(",");
            String uploadPath = application.getRealPath("/uploads/");
            
            for (String fileName : imagesToDelete) {
                if (fileName != null && !fileName.trim().isEmpty()) {
                    // 데이터베이스에서 이미지 정보 삭제
                    String deleteImageQuery = "DELETE FROM post_images WHERE postId = ? AND fileName = ?";
                    pstmt = conn.prepareStatement(deleteImageQuery);
                    pstmt.setInt(1, postId);
                    pstmt.setString(2, fileName.trim());
                    pstmt.executeUpdate();
                    pstmt.close();
                    
                    // 실제 파일 삭제
                    try {
                        File fileToDelete = new File(uploadPath + File.separator + fileName.trim());
                        if (fileToDelete.exists()) {
                            fileToDelete.delete();
                        }
                    } catch (Exception e) {
                        // 파일 삭제 실패는 로그만 남기고 계속 진행
                        e.printStackTrace();
                    }
                }
            }
        }
        
        // 새 이미지 처리
        String uploadPath = application.getRealPath("/uploads/");
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
        
        // multipart 요청에서 파일 처리
        try {
            Collection<Part> parts = request.getParts();
            for (Part part : parts) {
                if ("newImages".equals(part.getName()) && part.getSize() > 0) {
                    String originalFileName = part.getSubmittedFileName();
                    if (originalFileName != null && !originalFileName.isEmpty()) {
                        // 파일 확장자 검사
                        String extension = originalFileName.substring(originalFileName.lastIndexOf(".")).toLowerCase();
                        if (!Arrays.asList(".jpg", ".jpeg", ".png", ".gif").contains(extension)) {
                            continue; // 지원하지 않는 파일 형식은 건너뛰기
                        }
                        
                        // 고유한 파일명 생성
                        String fileName = System.currentTimeMillis() + "_" + originalFileName;
                        String filePath = uploadPath + File.separator + fileName;
                        
                        // 파일 저장
                        part.write(filePath);
                        
                        // 데이터베이스에 이미지 정보 저장
                        String insertImageQuery = "INSERT INTO post_images (postId, fileName, originalName, filePath, uploadedAt) VALUES (?, ?, ?, ?, NOW())";
                        pstmt = conn.prepareStatement(insertImageQuery);
                        pstmt.setInt(1, postId);
                        pstmt.setString(2, fileName);
                        pstmt.setString(3, originalFileName);
                        pstmt.setString(4, "uploads/" + fileName);
                        pstmt.executeUpdate();
                        pstmt.close();
                    }
                }
            }
        } catch (Exception e) {
            // 파일 업로드는 선택사항이므로 오류가 있어도 계속 진행
            e.printStackTrace();
        }
        
        conn.commit();
        
        jsonResponse.put("success", true);
        jsonResponse.put("message", "게시글이 성공적으로 수정되었습니다.");
        
    } catch (Exception e) {
        if (conn != null) {
            try { conn.rollback(); } catch (SQLException ex) {}
        }
        e.printStackTrace();
        jsonResponse.put("success", false);
        jsonResponse.put("message", "서버 오류가 발생했습니다: " + e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
    
    out.print(jsonResponse.toString());
%>
