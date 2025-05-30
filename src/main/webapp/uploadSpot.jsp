<%@ page import="java.io.*, java.sql.*" %>
<%@ page contentType="text/plain;charset=UTF-8" %>
<%@ page import="jakarta.servlet.http.Part" %>
<%
// 로그 출력을 위한 변수
PrintWriter logOut = response.getWriter();

try {
    // 인코딩 설정
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/plain");
    response.setCharacterEncoding("UTF-8");
    
    // 세션 확인
    String userId = (String) session.getAttribute("userId");
    System.out.println("uploadSpot.jsp - userId: " + userId);
    
    if(userId == null) {
        System.out.println("uploadSpot.jsp - 인증되지 않은 사용자");
        out.print("unauthorized");
        return;
    }
    
    // 파라미터 받기
    String title = request.getParameter("title");
    String description = request.getParameter("description");
    String latitudeStr = request.getParameter("latitude");
    String longitudeStr = request.getParameter("longitude");
    
    System.out.println("uploadSpot.jsp - 받은 파라미터:");
    System.out.println("  title: " + title);
    System.out.println("  description: " + description);
    System.out.println("  latitude: " + latitudeStr);
    System.out.println("  longitude: " + longitudeStr);
    
    // 필수 파라미터 검증
    if(title == null || title.trim().isEmpty()) {
        System.out.println("uploadSpot.jsp - 제목이 없음");
        out.print("missing_data");
        return;
    }
    
    if(description == null || description.trim().isEmpty()) {
        System.out.println("uploadSpot.jsp - 설명이 없음");
        out.print("missing_data");
        return;
    }
    
    if(latitudeStr == null || longitudeStr == null) {
        System.out.println("uploadSpot.jsp - 좌표가 없음");
        out.print("missing_data");
        return;
    }
    
    // 좌표 변환
    double latitude, longitude;
    try {
        latitude = Double.parseDouble(latitudeStr);
        longitude = Double.parseDouble(longitudeStr);
        System.out.println("uploadSpot.jsp - 변환된 좌표: " + latitude + ", " + longitude);
    } catch(NumberFormatException e) {
        System.out.println("uploadSpot.jsp - 좌표 변환 실패: " + e.getMessage());
        out.print("invalid_coordinates");
        return;
    }
    
    // 파일 파트 받기
    Part photoPart = null;
    try {
        photoPart = request.getPart("photo");
        System.out.println("uploadSpot.jsp - photoPart: " + (photoPart != null ? "존재" : "null"));
        if(photoPart != null) {
            System.out.println("uploadSpot.jsp - 파일 크기: " + photoPart.getSize());
            System.out.println("uploadSpot.jsp - 파일명: " + photoPart.getSubmittedFileName());
        }
    } catch(Exception e) {
        System.out.println("uploadSpot.jsp - 파일 파트 읽기 실패: " + e.getMessage());
        out.print("file_read_error");
        return;
    }
    
    if(photoPart == null || photoPart.getSize() == 0) {
        System.out.println("uploadSpot.jsp - 사진이 없음");
        out.print("no_photo");
        return;
    }
    
    String photoName = photoPart.getSubmittedFileName();
    if(photoName == null || photoName.trim().isEmpty()) {
        photoName = "uploaded_" + System.currentTimeMillis() + ".jpg";
    }
    
    InputStream photoInputStream = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    
    try {
        photoInputStream = photoPart.getInputStream();
        System.out.println("uploadSpot.jsp - InputStream 생성 성공");
        
        // 데이터베이스 연결
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/PhotoNation?useUnicode=true&characterEncoding=UTF-8", "root", "1234");
        System.out.println("uploadSpot.jsp - DB 연결 성공");
        
        // SQL 실행
        String sql = "INSERT INTO photo_spots (title, description, latitude, longitude, photo_name, photo_data, user_id) VALUES (?, ?, ?, ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, title.trim());
        pstmt.setString(2, description.trim());
        pstmt.setDouble(3, latitude);
        pstmt.setDouble(4, longitude);
        pstmt.setString(5, photoName);
        pstmt.setBinaryStream(6, photoInputStream, (int) photoPart.getSize());
        pstmt.setString(7, userId);
        
        System.out.println("uploadSpot.jsp - SQL 실행 시작");
        int result = pstmt.executeUpdate();
        System.out.println("uploadSpot.jsp - SQL 실행 결과: " + result);
        
        if(result > 0) {
            System.out.println("uploadSpot.jsp - 데이터 삽입 성공");
            out.print("success");
        } else {
            System.out.println("uploadSpot.jsp - 데이터 삽입 실패");
            out.print("failed");
        }
        
    } catch(SQLException e) {
        System.out.println("uploadSpot.jsp - SQL 오류: " + e.getMessage());
        e.printStackTrace();
        out.print("database_error");
    } catch(Exception e) {
        System.out.println("uploadSpot.jsp - 기타 오류: " + e.getMessage());
        e.printStackTrace();
        out.print("processing_error");
    } finally {
        // 리소스 정리
        try {
            if(photoInputStream != null) photoInputStream.close();
            if(pstmt != null) pstmt.close();
            if(conn != null) conn.close();
            System.out.println("uploadSpot.jsp - 리소스 정리 완료");
        } catch(Exception e) {
            System.out.println("uploadSpot.jsp - 리소스 정리 중 오류: " + e.getMessage());
        }
    }
    
} catch(Exception e) {
    System.out.println("uploadSpot.jsp - 전체 처리 중 오류: " + e.getMessage());
    e.printStackTrace();
    out.print("error: " + e.getMessage());
}
%>