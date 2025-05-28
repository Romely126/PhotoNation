<%@ page contentType="application/json; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="org.json.JSONObject" %>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    request.setCharacterEncoding("UTF-8");
    
    String currentUserId = (String) session.getAttribute("userId");
    String postIdParam = request.getParameter("postId");
    String content = request.getParameter("content");
    
    JSONObject jsonResponse = new JSONObject();
    
    if (currentUserId == null) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "로그인이 필요합니다.");
        out.print(jsonResponse.toString());
        return;
    }
    
    if (postIdParam == null || content == null || content.trim().isEmpty()) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "잘못된 요청입니다.");
        out.print(jsonResponse.toString());
        return;
    }
    
    int postId = Integer.parseInt(postIdParam);
    content = content.trim();
    
    String dbURL = "jdbc:mysql://localhost:3306/photonation?characterEncoding=utf8&serverTimezone=Asia/Seoul";
    String dbUser = "root";
    String dbPassword = "1234";
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
        
        // 게시글 존재 여부 확인
        String checkPostQuery = "SELECT COUNT(*) FROM posts WHERE postId = ?";
        pstmt = conn.prepareStatement(checkPostQuery);
        pstmt.setInt(1, postId);
        rs = pstmt.executeQuery();
        
        boolean postExists = false;
        if (rs.next()) {
            postExists = rs.getInt(1) > 0;
        }
        rs.close();
        pstmt.close();
        
        if (!postExists) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "존재하지 않는 게시글입니다.");
            out.print(jsonResponse.toString());
            return;
        }
        
        // 사용자의 닉네임 조회
        String getUserQuery = "SELECT nickname FROM user_info WHERE id = ?";
        pstmt = conn.prepareStatement(getUserQuery);
        pstmt.setString(1, currentUserId);
        rs = pstmt.executeQuery();
        
        String nickname = "";
        if (rs.next()) {
            nickname = rs.getString("nickname");
        }
        rs.close();
        pstmt.close();
        
        if (nickname.isEmpty()) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "사용자 정보를 찾을 수 없습니다.");
            out.print(jsonResponse.toString());
            return;
        }
        
        // 댓글 추가
        String insertQuery = "INSERT INTO comments (postId, userId, nickname, content, createdAt) VALUES (?, ?, ?, ?, NOW())";
        pstmt = conn.prepareStatement(insertQuery);
        pstmt.setInt(1, postId);
        pstmt.setString(2, currentUserId);
        pstmt.setString(3, nickname);
        pstmt.setString(4, content);
        
        int result = pstmt.executeUpdate();
        pstmt.close();
        
        if (result > 0) {
            jsonResponse.put("success", true);
            jsonResponse.put("message", "댓글이 작성되었습니다.");
        } else {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "댓글 작성에 실패했습니다.");
        }
        
    } catch (Exception e) {
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