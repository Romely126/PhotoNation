<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.time.*" %>
<%
    // POST 요청만 허용
    if (!"POST".equals(request.getMethod())) {
        response.getWriter().print("error: invalid request method");
        return;
    }
    
    String userId = (String) session.getAttribute("userId");
    
    if(userId == null) {
        response.getWriter().print("error: not logged in");
        return;
    }
    
    Connection conn = null;
    PreparedStatement selectStmt = null;
    PreparedStatement insertLostUserStmt = null;
    PreparedStatement insertProfileStmt = null;
    PreparedStatement deleteStmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/photonation?useUnicode=true&characterEncoding=utf8", "root", "1234");
        
        // 트랜잭션 시작
        conn.setAutoCommit(false);
        
        // 1. user_info 테이블에서 사용자 데이터 조회
        String selectSql = "SELECT * FROM user_info WHERE id = ?";
        selectStmt = conn.prepareStatement(selectSql);
        selectStmt.setString(1, userId);
        rs = selectStmt.executeQuery();
        
        if (!rs.next()) {
            response.getWriter().print("error: user not found");
            return;
        }
        
        // 2. lost_user 테이블에 사용자 데이터 백업
        String insertLostUserSql = "INSERT INTO lost_user (id, password, name, nickname, sex, birthday, phoneNum, email, postNum, address, joinDate, withdrawDate) " +
                                  "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";
        insertLostUserStmt = conn.prepareStatement(insertLostUserSql);
        insertLostUserStmt.setString(1, rs.getString("id"));
        insertLostUserStmt.setString(2, rs.getString("password"));
        insertLostUserStmt.setString(3, rs.getString("name"));
        insertLostUserStmt.setString(4, rs.getString("nickname"));
        insertLostUserStmt.setString(5, rs.getString("sex"));
        insertLostUserStmt.setDate(6, rs.getDate("birthday"));
        insertLostUserStmt.setString(7, rs.getString("phoneNum"));
        insertLostUserStmt.setString(8, rs.getString("email"));
        insertLostUserStmt.setString(9, rs.getString("postNum"));
        insertLostUserStmt.setString(10, rs.getString("address"));
        insertLostUserStmt.setTimestamp(11, rs.getTimestamp("joinDate"));
        
        int insertLostUserResult = insertLostUserStmt.executeUpdate();
        
        if (insertLostUserResult == 0) {
            conn.rollback();
            response.getWriter().print("error: failed to backup user data");
            return;
        }
        
        // 3. 프로필 이미지가 있다면 lost_user_profiles 테이블에 백업
        Blob profileImg = rs.getBlob("profileImg");
        if (profileImg != null) {
            String insertProfileSql = "INSERT INTO lost_user_profiles (id, withdrawDate, profileImage, uploadDate) " +
                                     "VALUES (?, NOW(), ?, NOW())";
            insertProfileStmt = conn.prepareStatement(insertProfileSql);
            insertProfileStmt.setString(1, rs.getString("id"));
            insertProfileStmt.setBlob(2, profileImg);
            insertProfileStmt.executeUpdate();
        }
        
        // 4. 관련된 다른 테이블의 데이터 삭제 (외래 키 제약 조건 순서 고려)
        
        // 4-1. post_reactions 테이블에서 해당 사용자의 반응 삭제
        String deleteReactionsSql = "DELETE FROM post_reactions WHERE userId = ?";
        PreparedStatement deleteReactionsStmt = conn.prepareStatement(deleteReactionsSql);
        deleteReactionsStmt.setString(1, userId);
        deleteReactionsStmt.executeUpdate();
        deleteReactionsStmt.close();
        
        // 4-2. 댓글 삭제
        String deleteCommentsSql = "DELETE FROM comments WHERE userId = ?";
        PreparedStatement deleteCommentsStmt = conn.prepareStatement(deleteCommentsSql);
        deleteCommentsStmt.setString(1, userId);
        deleteCommentsStmt.executeUpdate();
        deleteCommentsStmt.close();
        
        // 4-3. 게시글에 대한 모든 반응 삭제 (사용자의 게시글에 대한 다른 사용자의 반응)
        String deletePostReactionsSql = "DELETE pr FROM post_reactions pr " +
                                       "INNER JOIN posts p ON pr.postId = p.postId " +
                                       "WHERE p.userId = ?";
        PreparedStatement deletePostReactionsStmt = conn.prepareStatement(deletePostReactionsSql);
        deletePostReactionsStmt.setString(1, userId);
        deletePostReactionsStmt.executeUpdate();
        deletePostReactionsStmt.close();
        
        // 4-4. 게시글에 대한 모든 댓글 삭제 (사용자의 게시글에 대한 다른 사용자의 댓글)
        String deletePostCommentsSql = "DELETE c FROM comments c " +
                                      "INNER JOIN posts p ON c.postId = p.postId " +
                                      "WHERE p.userId = ?";
        PreparedStatement deletePostCommentsStmt = conn.prepareStatement(deletePostCommentsSql);
        deletePostCommentsStmt.setString(1, userId);
        deletePostCommentsStmt.executeUpdate();
        deletePostCommentsStmt.close();
        
        // 4-5. 게시글 이미지 삭제
        String deletePostImagesSql = "DELETE pi FROM post_images pi " +
                                    "INNER JOIN posts p ON pi.postId = p.postId " +
                                    "WHERE p.userId = ?";
        PreparedStatement deletePostImagesStmt = conn.prepareStatement(deletePostImagesSql);
        deletePostImagesStmt.setString(1, userId);
        deletePostImagesStmt.executeUpdate();
        deletePostImagesStmt.close();
        
        // 4-6. 게시글 삭제
        String deletePostsSql = "DELETE FROM posts WHERE userId = ?";
        PreparedStatement deletePostsStmt = conn.prepareStatement(deletePostsSql);
        deletePostsStmt.setString(1, userId);
        deletePostsStmt.executeUpdate();
        deletePostsStmt.close();
        
        // 5. user_info 테이블에서 사용자 데이터 삭제
        String deleteUserSql = "DELETE FROM user_info WHERE id = ?";
        deleteStmt = conn.prepareStatement(deleteUserSql);
        deleteStmt.setString(1, userId);
        
        int deleteResult = deleteStmt.executeUpdate();
        
        if (deleteResult == 0) {
            conn.rollback();
            response.getWriter().print("error: failed to delete user data");
            return;
        }
        
        // 트랜잭션 커밋
        conn.commit();
        
        // 세션 무효화
        session.invalidate();
        
        response.getWriter().print("success");
        
    } catch(SQLException e) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch(SQLException ex) {
                ex.printStackTrace();
            }
        }
        e.printStackTrace();
        response.getWriter().print("error: database error - " + e.getMessage());
    } catch(Exception e) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch(SQLException ex) {
                ex.printStackTrace();
            }
        }
        e.printStackTrace();
        response.getWriter().print("error: " + e.getMessage());
    } finally {
        try {
            if (rs != null) rs.close();
            if (selectStmt != null) selectStmt.close();
            if (insertLostUserStmt != null) insertLostUserStmt.close();
            if (insertProfileStmt != null) insertProfileStmt.close();
            if (deleteStmt != null) deleteStmt.close();
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        } catch(SQLException e) {
            e.printStackTrace();
        }
    }
%>