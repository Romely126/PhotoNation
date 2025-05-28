package com.photonation.servlet;

import java.io.*;
import java.sql.*;
import java.util.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

@WebServlet("/writePostProcess")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 50
)
public class WritePostServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        // 세션에서 사용자 정보 가져오기
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        String userNickname = (String) session.getAttribute("userNickname");
        
        if(userId == null || userNickname == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            // 데이터베이스 연결
            Class.forName("com.mysql.cj.jdbc.Driver");
            String url = "jdbc:mysql://localhost:3306/photonation?useUnicode=true&characterEncoding=UTF-8";
            conn = DriverManager.getConnection(url, "root", "1234");
            conn.setAutoCommit(false); // 트랜잭션 시작
            
            // 게시글 기본 정보 저장
            String title = request.getParameter("title");
            String content = request.getParameter("content");
            String boardType = request.getParameter("boardType");
            
            // SQL 쿼리 수정 - DB 스키마에 맞게 컬럼명 조정
            String sql = "INSERT INTO posts (userId, nickname, boardType, title, content, createdAt) VALUES (?, ?, ?, ?, ?, NOW())";
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setString(1, userId);
            pstmt.setString(2, userNickname);
            pstmt.setString(3, boardType);
            pstmt.setString(4, title);
            pstmt.setString(5, content);
            pstmt.executeUpdate();
            
            // 생성된 게시글의 ID 가져오기
            rs = pstmt.getGeneratedKeys();
            int postId = -1;
            if(rs.next()) {
                postId = rs.getInt(1);
            }
            
            // 사용자가 업로드한 이미지 처리
            Collection<Part> parts = request.getParts();
            for(Part part : parts) {
                if(part.getName().equals("images") && part.getSize() > 0) {
                    String fileName = getSubmittedFileName(part);
                    if(fileName != null && !fileName.trim().isEmpty()) {
                        // 이미지 저장
                        String uploadPath = getServletContext().getRealPath("/uploads");
                        File uploadDir = new File(uploadPath);
                        if (!uploadDir.exists()) {
                            uploadDir.mkdirs();
                        }
                        
                        String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
                        String filePath = uploadPath + File.separator + uniqueFileName;
                        
                        // 파일 저장
                        part.write(filePath);
                        
                        // DB에 이미지 정보 저장 - post_images 테이블 구조에 맞게 쿼리 수정
                        sql = "INSERT INTO post_images (postId, fileName, originalName, fileSize, filePath, fileType) VALUES (?, ?, ?, ?, ?, ?)";
                        pstmt = conn.prepareStatement(sql);
                        pstmt.setInt(1, postId);
                        pstmt.setString(2, uniqueFileName);
                        pstmt.setString(3, fileName);
                        pstmt.setLong(4, part.getSize());
                        pstmt.setString(5, "uploads/" + uniqueFileName);
                        pstmt.setString(6, part.getContentType());
                        pstmt.executeUpdate();
                    }
                }
            }
            
            conn.commit(); // 트랜잭션 커밋
            response.sendRedirect("main.jsp");
            
        } catch(Exception e) {
            try {
                if(conn != null) conn.rollback(); // 오류 발생 시 롤백
            } catch(SQLException se) {
                se.printStackTrace();
            }
            e.printStackTrace();
            
            // 한글 깨짐 방지를 위해 HTML로 완전한 응답 생성
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<meta charset='UTF-8'>");
            out.println("<script>");
            out.println("alert('게시글 등록에 실패했습니다.');");
            out.println("history.back();");
            out.println("</script>");
            out.println("</head>");
            out.println("<body></body>");
            out.println("</html>");
        } finally {
            try {
                if(conn != null) conn.setAutoCommit(true); // 자동 커밋 모드 복원
            } catch(SQLException se) {
                se.printStackTrace();
            }
            if(rs != null) try { rs.close(); } catch(Exception e) {}
            if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
            if(conn != null) try { conn.close(); } catch(Exception e) {}
        }
    }
    
    private String getSubmittedFileName(Part part) {
        String header = part.getHeader("content-disposition");
        if(header == null) return null;
        
        for(String token : header.split(";")) {
            if(token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return null;
    }
} 