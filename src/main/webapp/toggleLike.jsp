<%@ page contentType="application/json; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    String currentUserId = (String) session.getAttribute("userId");
    String postIdParam = request.getParameter("postId");
    
    if (currentUserId == null) {
        out.print("{\"success\":false,\"message\":\"로그인이 필요합니다.\"}");
        return;
    }
    
    if (postIdParam == null) {
        out.print("{\"success\":false,\"message\":\"잘못된 요청입니다.\"}");
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
        
        // 현재 좋아요 상태 확인
        String checkQuery = "SELECT reactionType FROM post_reactions WHERE postId = ? AND userId = ?";
        pstmt = conn.prepareStatement(checkQuery);
        pstmt.setInt(1, postId);
        pstmt.setString(2, currentUserId);
        rs = pstmt.executeQuery();
        
        String currentReaction = null;
        if (rs.next()) {
            currentReaction = rs.getString("reactionType");
        }
        rs.close();
        pstmt.close();
        
        if ("like".equals(currentReaction)) {
            // 이미 좋아요가 되어 있으면 좋아요 취소
            String deleteReactionQuery = "DELETE FROM post_reactions WHERE postId = ? AND userId = ?";
            pstmt = conn.prepareStatement(deleteReactionQuery);
            pstmt.setInt(1, postId);
            pstmt.setString(2, currentUserId);
            pstmt.executeUpdate();
            pstmt.close();
            
            // 게시글의 좋아요 수 감소
            String updateCountQuery = "UPDATE posts SET likeCount = likeCount - 1 WHERE postId = ?";
            pstmt = conn.prepareStatement(updateCountQuery);
            pstmt.setInt(1, postId);
            pstmt.executeUpdate();
            pstmt.close();
            
        } else {
            if ("dislike".equals(currentReaction)) {
                // 비추천이 되어 있으면 비추천 수 감소
                String updateDislikeQuery = "UPDATE posts SET dislikeCount = dislikeCount - 1 WHERE postId = ?";
                pstmt = conn.prepareStatement(updateDislikeQuery);
                pstmt.setInt(1, postId);
                pstmt.executeUpdate();
                pstmt.close();
            }
            
            // 기존 반응 삭제 후 좋아요 추가
            String deleteOldReactionQuery = "DELETE FROM post_reactions WHERE postId = ? AND userId = ?";
            pstmt = conn.prepareStatement(deleteOldReactionQuery);
            pstmt.setInt(1, postId);
            pstmt.setString(2, currentUserId);
            pstmt.executeUpdate();
            pstmt.close();
            
            String insertLikeQuery = "INSERT INTO post_reactions (postId, userId, reactionType, createdAt) VALUES (?, ?, 'like', NOW())";
            pstmt = conn.prepareStatement(insertLikeQuery);
            pstmt.setInt(1, postId);
            pstmt.setString(2, currentUserId);
            pstmt.executeUpdate();
            pstmt.close();
            
            // 게시글의 좋아요 수 증가
            String updateCountQuery = "UPDATE posts SET likeCount = likeCount + 1 WHERE postId = ?";
            pstmt = conn.prepareStatement(updateCountQuery);
            pstmt.setInt(1, postId);
            pstmt.executeUpdate();
            pstmt.close();
        }
        
        // 현재 좋아요 수와 비추천 수 조회
        String countQuery = "SELECT likeCount, dislikeCount FROM posts WHERE postId = ?";
        pstmt = conn.prepareStatement(countQuery);
        pstmt.setInt(1, postId);
        rs = pstmt.executeQuery();
        
        int currentLikeCount = 0;
        int currentDislikeCount = 0;
        if (rs.next()) {
            currentLikeCount = rs.getInt("likeCount");
            currentDislikeCount = rs.getInt("dislikeCount");
        }
        rs.close();
        pstmt.close();
        
        // 업데이트된 사용자 반응 상태 확인
        String newReactionQuery = "SELECT reactionType FROM post_reactions WHERE postId = ? AND userId = ?";
        pstmt = conn.prepareStatement(newReactionQuery);
        pstmt.setInt(1, postId);
        pstmt.setString(2, currentUserId);
        rs = pstmt.executeQuery();
        
        String newReaction = null;
        if (rs.next()) {
            newReaction = rs.getString("reactionType");
        }
        rs.close();
        pstmt.close();
        
        conn.commit();
        
        // JSON 응답 생성
        boolean isLiked = "like".equals(newReaction);
        boolean isDisliked = "dislike".equals(newReaction);
        
        String jsonResponse = "{" +
            "\"success\":true," +
            "\"isLiked\":" + isLiked + "," +
            "\"isDisliked\":" + isDisliked + "," +
            "\"likeCount\":" + currentLikeCount + "," +
            "\"dislikeCount\":" + currentDislikeCount +
            "}";
        
        out.print(jsonResponse);
        
    } catch (Exception e) {
        if (conn != null) {
            try { conn.rollback(); } catch (SQLException ex) {}
        }
        e.printStackTrace();
        out.print("{\"success\":false,\"message\":\"서버 오류가 발생했습니다.\"}");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>