<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%
    // 캐시 방지 헤더 추가
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/photonation";
        conn = DriverManager.getConnection(url, "root", "1234");
        
        // 복합적인 인기도 점수를 계산하는 SQL
        // 가중치: 좋아요 수 * 3 + 조회수 * 1 + 댓글수 * 2 + 최신성 보너스
        // 최신성 보너스: 24시간 이내 게시글에는 추가 점수 부여
        String sql = 
    "SELECT " +
    "    p.postId, " +
    "    p.title, " +
    "    p.likeCount, " +
    "    p.viewCount, " +
    "    p.createdAt, " +
    "    p.nickname, " +
    "    p.boardType, " +
    "    COALESCE(c.commentCount, 0) as commentCount, " +
    "    ( " +
    "        (p.likeCount * 3) + " +
    "        (p.viewCount * 1) + " +
    "        (COALESCE(c.commentCount, 0) * 2) + " +
    "        (CASE " +
    "            WHEN p.createdAt >= DATE_SUB(NOW(), INTERVAL 24 HOUR) THEN 10 " +
    "            WHEN p.createdAt >= DATE_SUB(NOW(), INTERVAL 72 HOUR) THEN 5 " +
    "            ELSE 0 " +
    "        END) " +
    "    ) as popularityScore " +
    "FROM posts p " +
    "LEFT JOIN ( " +
    "    SELECT postId, COUNT(*) as commentCount " +
    "    FROM comments " +
    "    GROUP BY postId " +
    ") c ON p.postId = c.postId " +
    "ORDER BY popularityScore DESC, p.createdAt DESC " +
    "LIMIT 10";

        
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        
        int rank = 1;
        boolean hasData = false;
        SimpleDateFormat sdf = new SimpleDateFormat("MM-dd HH:mm");
        
        while(rs.next()) {
            hasData = true;
            int postId = rs.getInt("postId");
            String title = rs.getString("title");
            int likeCount = rs.getInt("likeCount");
            int viewCount = rs.getInt("viewCount");
            int commentCount = rs.getInt("commentCount");
            double popularityScore = rs.getDouble("popularityScore");
            Timestamp createdAt = rs.getTimestamp("createdAt");
            String nickname = rs.getString("nickname");
            String boardType = rs.getString("boardType");
            
            // 제목이 너무 길면 자르기
            if(title.length() > 25) {
                title = title.substring(0, 25) + "...";
            }
            
            // 게시판 타입별 색상 및 아이콘
            String boardColor = "";
            String boardIcon = "";
            String boardName = "";
            
            switch(boardType) {
                case "free":
                    boardColor = "text-success";
                    boardIcon = "fas fa-comments";
                    boardName = "자유";
                    break;
                case "photo":
                    boardColor = "text-primary";
                    boardIcon = "fas fa-camera";
                    boardName = "포토";
                    break;
                case "qna":
                    boardColor = "text-warning";
                    boardIcon = "fas fa-question-circle";
                    boardName = "질문";
                    break;
                case "market":
                    boardColor = "text-info";
                    boardIcon = "fas fa-shopping-cart";
                    boardName = "장터";
                    break;
                default:
                    boardColor = "text-secondary";
                    boardIcon = "fas fa-file";
                    boardName = "일반";
            }
            
            // 최신 게시글 표시 (24시간 이내)
            boolean isNew = false;
            if(createdAt != null) {
                long timeDiff = System.currentTimeMillis() - createdAt.getTime();
                isNew = timeDiff < 24 * 60 * 60 * 1000; // 24시간
            }
%>
            <div class="popular-post-item post-item" data-post-id="<%= postId %>" style="cursor: pointer;">
                <div class="d-flex justify-content-between align-items-start">
                    <div class="flex-grow-1">
                        <div class="d-flex align-items-center mb-1">
                            <small class="text-primary fw-bold me-2"><%= rank %>위</small>
                            <span class="<%= boardColor %> me-2" style="font-size: 0.7em;">
                                <i class="<%= boardIcon %>"></i> <%= boardName %>
                            </span>
                            <% if(isNew) { %>
                                <span class="badge bg-danger rounded-pill" style="font-size: 0.6em;">NEW</span>
                            <% } %>
                        </div>
                        <div class="post-title mb-1" style="font-size: 0.9em; line-height: 1.3;" title="<%= rs.getString("title") %>">
                            <%= title %>
                        </div>
                        <div class="post-author mb-1" style="font-size: 0.75em; color: #6c757d;">
                            by <%= nickname %>
                        </div>
                        <div class="post-stats d-flex align-items-center" style="font-size: 0.75em;">
                            <span class="text-danger me-2">
                                <i class="fas fa-heart" style="font-size: 0.8em;"></i> <%= likeCount %>
                            </span>
                            <span class="text-primary me-2">
                                <i class="fas fa-eye" style="font-size: 0.8em;"></i> <%= viewCount %>
                            </span>
                            <span class="text-success">
                                <i class="fas fa-comment" style="font-size: 0.8em;"></i> <%= commentCount %>
                            </span>
                        </div>
                    </div>
                    <div class="popularity-score text-end">
                        <small class="text-muted" style="font-size: 0.7em;">
                            점수: <%= String.format("%.0f", popularityScore) %>
                        </small>
                        <% if(createdAt != null) { %>
                            <br><small class="text-muted" style="font-size: 0.65em;">
                                <%= sdf.format(createdAt) %>
                            </small>
                        <% } %>
                    </div>
                </div>
            </div>
<%
            rank++;
        }
        
        if(!hasData) {
%>
            <div class="text-center text-muted py-3">
                <i class="fas fa-chart-line mb-2"></i>
                <div>인기글이 없습니다.</div>
                <small>게시글에 좋아요와 댓글을 남겨보세요!</small>
            </div>
<%
        }
        
    } catch(Exception e) {
        e.printStackTrace();
        out.println("<div class='text-center text-danger py-3'>");
        out.println("<i class='fas fa-exclamation-triangle mb-2'></i>");
        out.println("<div>인기글을 불러오는 중 오류가 발생했습니다.</div>");
        out.println("<small>잠시 후 다시 시도해주세요.</small>");
        out.println("</div>");
    } finally {
        if(rs != null) try { rs.close(); } catch(Exception e) {}
        if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if(conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>