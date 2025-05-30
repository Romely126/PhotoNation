<%@ page import="java.sql.*, java.io.*" %>
<%
String spotId = request.getParameter("id");
if(spotId != null) {
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/PhotoNation", "root", "1234");
        
        String sql = "SELECT photo_data FROM photo_spots WHERE id = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, Integer.parseInt(spotId));
        ResultSet rs = pstmt.executeQuery();
        
        if(rs.next()) {
            response.setContentType("image/jpeg");
            InputStream imageStream = rs.getBinaryStream("photo_data");
            if(imageStream != null) {
                byte[] buffer = new byte[1024];
                int bytesRead;
                while((bytesRead = imageStream.read(buffer)) != -1) {
                    response.getOutputStream().write(buffer, 0, bytesRead);
                }
                imageStream.close();
            }
        }
        
        rs.close();
        pstmt.close();
        conn.close();
    } catch(Exception e) {
        e.printStackTrace();
    }
}
%>