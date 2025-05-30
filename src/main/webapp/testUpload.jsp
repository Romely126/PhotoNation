<%@ page import="java.io.*, java.sql.*" %>
<%@ page import="jakarta.servlet.http.Part" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>업로드 테스트</title>
</head>
<body>
    <h2>업로드 테스트</h2>
    
    <%
    String method = request.getMethod();
    out.println("<p>요청 메서드: " + method + "</p>");
    out.println("<p>Content-Type: " + request.getContentType() + "</p>");
    String userId = (String) session.getAttribute("userId");
    out.println("<p>세션 사용자 ID: " + userId + "</p>");
    
    if("POST".equals(method)) {
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String latStr = request.getParameter("latitude");
        String lonStr = request.getParameter("longitude");
        double latitude = Double.parseDouble(latStr);
        double longitude = Double.parseDouble(lonStr);
        
        Part photoPart = null;
        String photoName = null;
        InputStream photoStream = null;
        
        try {
            photoPart = request.getPart("photo");
            if(photoPart != null && photoPart.getSize() > 0) {
                photoName = photoPart.getSubmittedFileName();
                photoStream = photoPart.getInputStream();
                out.println("<p>파일명: " + photoName + "</p>");
                out.println("<p>파일 크기: " + photoPart.getSize() + " bytes</p>");
                out.println("<p>Content-Type: " + photoPart.getContentType() + "</p>");
            } else {
                out.println("<p>파일 파트를 찾을 수 없습니다.</p>");
            }
        } catch(Exception e) {
            out.println("<p>파일 처리 오류: " + e.getMessage() + "</p>");
        }
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/PhotoNation", "root", "1234");
            out.println("<p>데이터베이스 연결 성공</p>");
            
            String sql = "INSERT INTO photo_spots (title, description, latitude, longitude, photo_name, photo_data, user_id) VALUES (?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, title);
            pstmt.setString(2, description);
            pstmt.setDouble(3, latitude);
            pstmt.setDouble(4, longitude);
            pstmt.setString(5, photoName);
            if(photoStream != null) {
                pstmt.setBlob(6, photoStream);
            } else {
                pstmt.setNull(6, java.sql.Types.BLOB);
            }
            pstmt.setString(7, userId);
            
            int rows = pstmt.executeUpdate();
            if(rows > 0) {
                out.println("<p>DB에 성공적으로 저장되었습니다.</p>");
            } else {
                out.println("<p>DB 저장 실패.</p>");
            }
            
            pstmt.close();
            conn.close();
        } catch(Exception e) {
            out.println("<p>데이터베이스 작업 실패: " + e.getMessage() + "</p>");
        }
    }
    %>
    
    <form method="post" enctype="multipart/form-data">
        <p>제목: <input type="text" name="title" value="테스트 제목"></p>
        <p>설명: <textarea name="description">테스트 설명</textarea></p>
        <p>위도: <input type="text" name="latitude" value="37.5665"></p>
        <p>경도: <input type="text" name="longitude" value="126.9780"></p>
        <p>사진: <input type="file" name="photo" accept="image/*"></p>
        <p><input type="submit" value="테스트 전송"></p>
    </form>
</body>
</html>
