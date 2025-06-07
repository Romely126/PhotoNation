<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%
    request.setCharacterEncoding("UTF-8");

    
    String boardType = request.getParameter("boardType");
    String pageParam = request.getParameter("page");
    String searchParam = request.getParameter("search");
    
    int currentPageNum = (pageParam != null) ? Integer.parseInt(pageParam) : 1;
    int postsPerPage = 10;
    int offset = (currentPageNum - 1) * postsPerPage;
    
    String dbURL = "jdbc:mysql://localhost:3306/photonation?characterEncoding=utf8&serverTimezone=Asia/Seoul";
    String dbUser = "root";
    String dbPassword = "1234";
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
        
        // 전체 게시글 수 조회
        String countQuery = "SELECT COUNT(*) as total FROM posts";
        if (boardType != null && !boardType.equals("all")) {
            countQuery += " WHERE boardType = ?";
        }
        if (searchParam != null && !searchParam.trim().isEmpty()) {
            if (boardType != null && !boardType.equals("all")) {
                countQuery += " AND (title LIKE ? OR content LIKE ?)";
            } else {
                countQuery += " WHERE (title LIKE ? OR content LIKE ?)";
            }
        }
        
        PreparedStatement countStmt = conn.prepareStatement(countQuery);
        int paramIndex = 1;
        if (boardType != null && !boardType.equals("all")) {
            countStmt.setString(paramIndex++, boardType);
        }
        if (searchParam != null && !searchParam.trim().isEmpty()) {
            String searchTerm = "%" + searchParam + "%";
            countStmt.setString(paramIndex++, searchTerm);
            countStmt.setString(paramIndex++, searchTerm);
        }
        
        ResultSet countRs = countStmt.executeQuery();
        int totalPosts = 0;
        if (countRs.next()) {
            totalPosts = countRs.getInt("total");
        }
        countRs.close();
        countStmt.close();
        
        int totalPages = (int) Math.ceil((double) totalPosts / postsPerPage);
        
        // 게시글 목록 조회 - ResultSet 타입을 TYPE_SCROLL_INSENSITIVE로 변경
        String query = "SELECT p.postId, p.title, p.nickname, p.userId, p.createdAt, p.viewCount, p.likeCount, p.boardType, " +
                      "(SELECT COUNT(*) FROM comments c WHERE c.postId = p.postId) as commentCount, " +
                      "(SELECT fileName FROM post_images pi WHERE pi.postId = p.postId LIMIT 1) as thumbnail " +
                      "FROM posts p";
        
        if (boardType != null && !boardType.equals("all")) {
            query += " WHERE p.boardType = ?";
        }
        if (searchParam != null && !searchParam.trim().isEmpty()) {
            if (boardType != null && !boardType.equals("all")) {
                query += " AND (p.title LIKE ? OR p.content LIKE ?)";
            } else {
                query += " WHERE (p.title LIKE ? OR p.content LIKE ?)";
            }
        }
        
        // admin 글들을 최상단에, 그 다음은 최신순으로 정렬
        query += " ORDER BY CASE WHEN p.userId = 'admin' THEN 0 ELSE 1 END, p.createdAt DESC LIMIT ? OFFSET ?";
        
        // ResultSet 타입을 TYPE_SCROLL_INSENSITIVE로 설정
        pstmt = conn.prepareStatement(query, ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
        paramIndex = 1;
        if (boardType != null && !boardType.equals("all")) {
            pstmt.setString(paramIndex++, boardType);
        }
        if (searchParam != null && !searchParam.trim().isEmpty()) {
            String searchTerm = "%" + searchParam + "%";
            pstmt.setString(paramIndex++, searchTerm);
            pstmt.setString(paramIndex++, searchTerm);
        }
        pstmt.setInt(paramIndex++, postsPerPage);
        pstmt.setInt(paramIndex++, offset);
        
        rs = pstmt.executeQuery();
        
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        SimpleDateFormat today = new SimpleDateFormat("HH:mm");
        SimpleDateFormat dateFormat = new SimpleDateFormat("MM-dd");
        Date now = new Date();
%>

<!-- 검색 바 -->
<div class="mb-3">
    <div class="input-group">
        <input type="text" class="form-control" id="searchInput" placeholder="제목 또는 내용으로 검색..." value="<%= searchParam != null ? searchParam : "" %>">
        <button class="btn btn-outline-secondary" type="button" onclick="searchPosts()">
            <i class="fas fa-search"></i> 검색
        </button>
    </div>
</div>

<!-- 게시판 정보 -->
<div class="d-flex justify-content-between align-items-center mb-3">
    <h5 class="mb-0">
        <% 
        String boardName = "전체 게시글";
        if ("free".equals(boardType)) boardName = "자유게시판";
        else if ("photo".equals(boardType)) boardName = "포토게시판";
        else if ("qna".equals(boardType)) boardName = "질문게시판";
        else if ("market".equals(boardType)) boardName = "장터게시판";
        %>
        <%= boardName %> <small class="text-muted">(<%= totalPosts %>개)</small>
    </h5>
    <% if (session.getAttribute("userId") != null) { %>
    <a href="writePost.jsp" class="btn btn-primary btn-sm">
        <i class="fas fa-pen"></i> 글쓰기
    </a>
    <% } %>
</div>

<!-- 게시글 목록 -->
<div class="list-group">
    <%
    if (!rs.next()) {
    %>
    <div class="text-center py-5">
        <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
        <p class="text-muted">게시글이 없습니다.</p>
    </div>
    <%
    } else {
        rs.beforeFirst(); 
        while (rs.next()) {
            int postId = rs.getInt("postId");
            String title = rs.getString("title");
            String nickname = rs.getString("nickname");
            String userId = rs.getString("userId");
            Timestamp createdAt = rs.getTimestamp("createdAt");
            int viewCount = rs.getInt("viewCount");
            int likeCount = rs.getInt("likeCount");
            String postBoardType = rs.getString("boardType");
            int commentCount = rs.getInt("commentCount");
            String thumbnail = rs.getString("thumbnail");
            
            // 시간 포맷팅
            String timeStr;
            long timeDiff = now.getTime() - createdAt.getTime();
            long hoursDiff = timeDiff / (1000 * 60 * 60);
            
            if (hoursDiff < 24) {
                timeStr = today.format(createdAt);
            } else if (hoursDiff < 24 * 365) {
                timeStr = dateFormat.format(createdAt);
            } else {
                timeStr = sdf.format(createdAt);
            }
            
            // 게시판 타입별 뱃지 색상
            String badgeClass = "secondary";
            String badgeName = "";
            switch(postBoardType) {
                case "free": badgeClass = "primary"; badgeName = "자유"; break;
                case "photo": badgeClass = "success"; badgeName = "포토"; break;
                case "qna": badgeClass = "warning"; badgeName = "질문"; break;
                case "market": badgeClass = "danger"; badgeName = "장터"; break;
            }
    %>
    <div class="list-group-item list-group-item-action post-item" 
         data-post-id="<%= postId %>" 
         style="cursor: pointer;">
        <div class="row align-items-center">
            <% if (thumbnail != null) { %>
            <div class="col-2">
                <img src="uploads/<%= thumbnail %>" class="img-fluid rounded post-thumbnail" alt="썸네일" style="height: 80px; object-fit: cover;">
            </div>
            <div class="col-10">
            <% } else { %>
            <div class="col-12">
            <% } %>
                <div class="d-flex w-100 justify-content-between align-items-start mb-2">
                    <div class="d-flex align-items-center">
                        <% if (!"all".equals(boardType)) { %>
                        <span class="badge bg-<%= badgeClass %> me-2"><%= badgeName %></span>
                        <% } %>
                        <h6 class="mb-0 fw-bold"><%= title %></h6>
                        <% if (commentCount > 0) { %>
                        <span class="badge bg-light text-dark ms-2">[<%= commentCount %>]</span>
                        <% } %>
                    </div>
                    <small class="text-muted"><%= timeStr %></small>
                </div>
                <div class="d-flex justify-content-between align-items-center">
                    <span class="text-muted small">
                        <% if ("admin".equals(userId)) { %>
                            <i class="fas fa-crown" style="color: #FFD700; margin-right: 5px;"></i><%= nickname %>
                        <% } else {%>
                        <i class="fas fa-user"></i> <%= nickname %> <%} %> 
                    </span>
                    <div class="text-muted small">
                        <i class="fas fa-eye"></i> <%= viewCount %>
                        <% if (likeCount > 0) { %>
                        <i class="fas fa-heart ms-2"></i> <%= likeCount %>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <%
        }
    }
    %>
</div>
</div>

<!-- 페이징 -->
<% if (totalPages > 1) { %>
<nav aria-label="게시글 페이지네이션" class="mt-4">
    <ul class="pagination justify-content-center">
        <% if (currentPageNum > 1) { %>
        <li class="page-item">
            <a class="page-link" href="#" onclick="loadPosts('<%= boardType %>', <%= currentPageNum - 1 %>, '<%= searchParam != null ? searchParam : "" %>')">이전</a>
        </li>
        <% } %>
        
        <%
        int startPage = Math.max(1, currentPageNum - 2);
        int endPage = Math.min(totalPages, currentPageNum + 2);
        
        for (int i = startPage; i <= endPage; i++) {
        %>
        <li class="page-item <%= (i == currentPageNum) ? "active" : "" %>">
            <a class="page-link" href="#" onclick="loadPosts('<%= boardType %>', <%= i %>, '<%= searchParam != null ? searchParam : "" %>')"><%= i %></a>
        </li>
        <% } %>
        
        <% if (currentPageNum < totalPages) { %>
        <li class="page-item">
            <a class="page-link" href="#" onclick="loadPosts('<%= boardType %>', <%= currentPageNum + 1 %>, '<%= searchParam != null ? searchParam : "" %>')">다음</a>
        </li>
        <% } %>
    </ul>
</nav>
<% } %>

<%
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<div class='alert alert-danger'>게시글을 불러오는 중 오류가 발생했습니다: " + e.getMessage() + "</div>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>