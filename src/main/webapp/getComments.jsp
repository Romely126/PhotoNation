<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    request.setCharacterEncoding("UTF-8");
    String postId = request.getParameter("postId");
    String currentUserId = (String) session.getAttribute("userId");
    
    if (postId == null) {
        out.print("<p class='text-muted'>댓글을 불러올 수 없습니다.</p>");
        return;
    }
    
    // 데이터베이스 연결 정보
    String jdbcUrl = "jdbc:mysql://localhost:3306/photonation?characterEncoding=utf8&serverTimezone=Asia/Seoul";
    String dbUser = "root";
    String dbPassword = "1234";
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);
        
        // comments 테이블에서 댓글 조회 (이미 nickname이 저장되어 있음)
        String sql = "SELECT commentId, userId, nickname, content, createdAt FROM comments " +
                    "WHERE postId = ? " +
                    "ORDER BY createdAt ASC";
        
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, Integer.parseInt(postId));
        rs = pstmt.executeQuery();
        
        boolean hasComments = false;
        while (rs.next()) {
            hasComments = true;
            int commentId = rs.getInt("commentId");
            String content = rs.getString("content");
            String nickname = rs.getString("nickname");
            String userId = rs.getString("userId");
            Timestamp createdAtTimestamp = rs.getTimestamp("createdAt");
            
            // 날짜 포맷팅
            String formattedDate = "";
            if (createdAtTimestamp != null) {
                SimpleDateFormat outputFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                formattedDate = outputFormat.format(createdAtTimestamp);
            }
%>
            <div class="comment-item">
                <div class="d-flex justify-content-between align-items-start">
                    <div class="flex-grow-1">
                        <div class="d-flex align-items-center mb-2">
                            <span class="comment-author"><%= nickname %></span>
                            <span class="comment-date ms-2"><%= formattedDate %></span>
                        </div>
                        <div class="comment-content">
                            <%= content.replace("\n", "<br>") %>
                        </div>
                    </div>
                    <% if (currentUserId != null && currentUserId.equals(userId)) { %>
                        <div class="ms-2">
                            <button class="btn btn-outline-danger btn-sm" 
                                    onclick="deleteComment(<%= commentId %>)">
                                <i class="fas fa-trash"></i>
                            </button>
                        </div>
                    <% } %>
                </div>
            </div>
<%
        }
        
        if (!hasComments) {
%>
            <div class="text-center text-muted py-4">
                <i class="fas fa-comment-slash fa-2x mb-2"></i>
                <p>아직 댓글이 없습니다.<br>첫 번째 댓글을 작성해보세요!</p>
            </div>
<%
        }
        
    } catch (Exception e) {
        e.printStackTrace();
%>
        <div class="alert alert-danger">
            <i class="fas fa-exclamation-triangle"></i>
            댓글을 불러오는 중 오류가 발생했습니다.
        </div>
<%
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>