<%@ page contentType="application/json; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.File" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    String currentUserId = (String) session.getAttribute("userId");
    String postIdParam = request.getParameter("postId");
    
    JSONObject jsonResponse = new JSONObject();
    
    if (currentUserId == null) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "로그인이 필요합니다.");
        out.print(jsonResponse.toString());
        return;
    }
    
    if (postIdParam == null) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "잘못된 요청입니다.");
        out.print(jsonResponse.toString());
        return;
    }
    
    int postId = Integer.parseInt(postIdParam);
    
    // 관리자 권한 체크
    boolean isAdmin = "admin".equals(currentUserId);
    
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
        
        // 게시글 작성자 확인
        String checkQuery = "SELECT userId FROM posts WHERE postId = ?";
        pstmt = conn.prepareStatement(checkQuery);
        pstmt.setInt(1, postId);
        rs = pstmt.executeQuery();
        
        String postUserId = null;
        if (rs.next()) {
            postUserId = rs.getString("userId");
        }
        rs.close();
        pstmt.close();
        
        if (postUserId == null) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "존재하지 않는 게시글입니다.");
            out.print(jsonResponse.toString());
            return;
        }
        
        // 권한 체크: 게시글 작성자이거나 관리자인 경우에만 삭제 가능
        if (!currentUserId.equals(postUserId) && !isAdmin) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "게시글을 삭제할 권한이 없습니다.");
            out.print(jsonResponse.toString());
            return;
        }
        
        // 게시글 이미지 파일명 조회
        List<String> imageFiles = new ArrayList<>();
        String imageQuery = "SELECT fileName FROM post_images WHERE postId = ?";
        pstmt = conn.prepareStatement(imageQuery);
        pstmt.setInt(1, postId);
        rs = pstmt.executeQuery();
        while (rs.next()) {
            imageFiles.add(rs.getString("fileName"));
        }
        rs.close();
        pstmt.close();
        
        // 게시글 관련 데이터 삭제
        // 1. 댓글 삭제
        String deleteCommentsQuery = "DELETE FROM comments WHERE postId = ?";
        pstmt = conn.prepareStatement(deleteCommentsQuery);
        pstmt.setInt(1, postId);
        pstmt.executeUpdate();
        pstmt.close();
        
        // 2. 추천/비추천 삭제
        String deleteReactionsQuery = "DELETE FROM post_reactions WHERE postId = ?";
        pstmt = conn.prepareStatement(deleteReactionsQuery);
        pstmt.setInt(1, postId);
        pstmt.executeUpdate();
        pstmt.close();
        
        // 3. 게시글 이미지 레코드 삭제
        String deleteImagesQuery = "DELETE FROM post_images WHERE postId = ?";
        pstmt = conn.prepareStatement(deleteImagesQuery);
        pstmt.setInt(1, postId);
        pstmt.executeUpdate();
        pstmt.close();
        
        // 4. 게시글 삭제
        String deletePostQuery = "DELETE FROM posts WHERE postId = ?";
        pstmt = conn.prepareStatement(deletePostQuery);
        pstmt.setInt(1, postId);
        int result = pstmt.executeUpdate();
        pstmt.close();
        
        if (result > 0) {
            conn.commit();
            
            // 실제 이미지 파일들 삭제
            String uploadPath = application.getRealPath("/uploads/");
            for (String fileName : imageFiles) {
                try {
                    File file = new File(uploadPath + fileName);
                    if (file.exists()) {
                        file.delete();
                    }
                } catch (Exception e) {
                    // 파일 삭제 실패는 로그만 출력하고 계속 진행
                    e.printStackTrace();
                }
            }
            
            jsonResponse.put("success", true);
            if (isAdmin) {
                jsonResponse.put("message", "관리자 권한으로 게시글이 삭제되었습니다.");
            } else {
                jsonResponse.put("message", "게시글이 삭제되었습니다.");
            }
        } else {
            conn.rollback();
            jsonResponse.put("success", false);
            jsonResponse.put("message", "게시글 삭제에 실패했습니다.");
        }
        
    } catch (Exception e) {
        if (conn != null) {
            try { conn.rollback(); } catch (SQLException ex) {}
        }
        e.printStackTrace();
        jsonResponse.put("success", false);
        jsonResponse.put("message", "서버 오류가 발생했습니다.");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
    
    out.print(jsonResponse.toString());
%>