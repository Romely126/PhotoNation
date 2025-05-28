<%@ page contentType="image/jpeg" %>
<%@ page import="java.sql.*" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%
    String userId = request.getParameter("userId");
    
    if(userId != null) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String url = "jdbc:mysql://localhost:3306/photonation";
            conn = DriverManager.getConnection(url, "root", "1234");
            
            String sql = "SELECT profileImg, profileImgType FROM user_info WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();
            
            if(rs.next()) {
                byte[] imageData = rs.getBytes("profileImg");
                String contentType = rs.getString("profileImgType");
                
                if(imageData != null && imageData.length > 0) {
                    if(contentType != null && !contentType.isEmpty()) {
                        response.setContentType(contentType);
                    } else {
                        response.setContentType("image/jpeg");
                    }
                    response.setContentLength(imageData.length);
                    response.getOutputStream().write(imageData);
                    response.getOutputStream().flush();
                } else {
                    response.sendRedirect("img/default_profile.jpg");
                }
            } else {
                response.sendRedirect("img/default_profile.jpg");
            }
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("img/default_profile.jpg");
        } finally {
            if(rs != null) try { rs.close(); } catch(Exception e) {}
            if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
            if(conn != null) try { conn.close(); } catch(Exception e) {}
        }
    } else {
        response.sendRedirect("img/default_profile.jpg");
    }
%> 