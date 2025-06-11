<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%@ page import="jakarta.servlet.http.Part" %>
<%@ page import="java.util.*" %>
<%@ page import="java.security.MessageDigest" %>
<%
    request.setCharacterEncoding("UTF-8");
    
    String userId = (String) session.getAttribute("userId");
    
    // 로그인 체크
    if(userId == null) {
        out.print("login_required");
        return;
    }
    
    try {
        // 폼 데이터를 저장할 변수들
        String nickname = request.getParameter("nickname");
        String birthday = request.getParameter("birthday");
        String phoneNum = request.getParameter("phoneNum");
        String email = request.getParameter("email");
        String postNum = request.getParameter("postNum");
        String address = request.getParameter("address");
        String detailAddress = request.getParameter("detailAddress");
        String hashedNewPassword = request.getParameter("hashedNewPassword");
        
     	// 주소 통합 처리
        String fullAddress = address;
        if(detailAddress != null && !detailAddress.trim().isEmpty()) {
            fullAddress = address + " " + detailAddress.trim();
        }

        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/photonation?useUnicode=true&characterEncoding=utf8", "root", "1234");
        
        // 닉네임 중복 체크 (현재 사용자 제외)
        String nickCheckSql = "SELECT COUNT(*) as count FROM user_info WHERE nickname = ? AND id != ?";
        PreparedStatement nickCheckStmt = conn.prepareStatement(nickCheckSql);
        nickCheckStmt.setString(1, nickname);
        nickCheckStmt.setString(2, userId);
        ResultSet nickCheckRs = nickCheckStmt.executeQuery();
        
        if(nickCheckRs.next() && nickCheckRs.getInt("count") > 0) {
            out.print("이미 사용 중인 닉네임입니다.");
            nickCheckRs.close();
            nickCheckStmt.close();
            conn.close();
            return;
        }
        nickCheckRs.close();
        nickCheckStmt.close();
        
        // 사용자 정보 업데이트
        String updateSql;
        PreparedStatement updateStmt;
        
        // 프로필 이미지 관련 변수
        byte[] profileImgData = null;
        String profileImgType = null;
        
        // 파일 업로드
        Part filePart = null;
        try {
            filePart = request.getPart("profileImg");
        } catch (Exception e) {
            // multipart가 아닌 경우 무시
        }
        
        if (filePart != null && filePart.getSize() > 0) {
            String fileName = filePart.getSubmittedFileName();
            if (fileName != null) {
                fileName = fileName.toLowerCase();
                
                // 이미지 파일 타입 검증
                if(fileName.endsWith(".jpg") || fileName.endsWith(".jpeg") || 
                   fileName.endsWith(".png") || fileName.endsWith(".gif")) {
                    
                    // 파일 크기 체크 (5MB)
                    if (filePart.getSize() > 5 * 1024 * 1024) {
                        out.print("파일 크기가 5MB를 초과할 수 없습니다.");
                        return;
                    }
                    
                    // 파일 데이터를 바이트 배열로 저장
                    InputStream inputStream = filePart.getInputStream();
                    ByteArrayOutputStream buffer = new ByteArrayOutputStream();
                    int nRead;
                    byte[] data = new byte[1024];
                    while ((nRead = inputStream.read(data, 0, data.length)) != -1) {
                        buffer.write(data, 0, nRead);
                    }
                    buffer.flush();
                    profileImgData = buffer.toByteArray();
                    inputStream.close();
                    buffer.close();
                    
                    // MIME 타입 설정
                    if(fileName.endsWith(".jpg") || fileName.endsWith(".jpeg")) {
                        profileImgType = "image/jpeg";
                    } else if(fileName.endsWith(".png")) {
                        profileImgType = "image/png";
                    } else if(fileName.endsWith(".gif")) {
                        profileImgType = "image/gif";
                    }
                } else {
                    out.print("지원하지 않는 이미지 형식입니다. (jpg, jpeg, png, gif만 가능)");
                    return;
                }
            }
        }
        
        // 입력값 검증 (필수 필드만 체크)
        if(nickname == null || nickname.trim().isEmpty() ||
           birthday == null || birthday.trim().isEmpty() ||
           phoneNum == null || phoneNum.trim().isEmpty() ||
           email == null || email.trim().isEmpty() ||
           postNum == null || postNum.trim().isEmpty() ||
           address == null || address.trim().isEmpty()) {
            out.print("모든 필수 필드를 입력해주세요.");
            return;
        }
        
        // 이메일 형식 검증
        if(!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            out.print("올바른 이메일 형식이 아닙니다.");
            return;
        }
        
        // 전화번호 형식 검증 (숫자와 하이픈만 허용)
        if(!phoneNum.matches("^[0-9-]+$")) {
            out.print("올바른 전화번호 형식이 아닙니다.");
            return;
        }
        
     // 비밀번호 변경 여부에 따라 쿼리 분기
        boolean updatePassword = (hashedNewPassword != null && !hashedNewPassword.trim().isEmpty());
        String encryptedPassword = hashedNewPassword;
        
        if(profileImgData != null && updatePassword) {
            // 프로필 이미지와 비밀번호 모두 업데이트
            updateSql = "UPDATE user_info SET nickname=?, birthday=?, phoneNum=?, email=?, postNum=?, address=?, profileImg=?, profileImgType=?, password=? WHERE id=?";
            updateStmt = conn.prepareStatement(updateSql);
            updateStmt.setString(1, nickname);
            updateStmt.setString(2, birthday);
            updateStmt.setString(3, phoneNum);
            updateStmt.setString(4, email);
            updateStmt.setString(5, postNum);
            updateStmt.setString(6, fullAddress);
            updateStmt.setBytes(7, profileImgData);
            updateStmt.setString(8, profileImgType);
            updateStmt.setString(9, encryptedPassword);
            updateStmt.setString(10, userId);
        } else if(profileImgData != null) {
            // 프로필 이미지만 업데이트
            updateSql = "UPDATE user_info SET nickname=?, birthday=?, phoneNum=?, email=?, postNum=?, address=?, profileImg=?, profileImgType=? WHERE id=?";
            updateStmt = conn.prepareStatement(updateSql);
            updateStmt.setString(1, nickname);
            updateStmt.setString(2, birthday);
            updateStmt.setString(3, phoneNum);
            updateStmt.setString(4, email);
            updateStmt.setString(5, postNum);
            updateStmt.setString(6, fullAddress);
            updateStmt.setBytes(7, profileImgData);
            updateStmt.setString(8, profileImgType);
            updateStmt.setString(9, userId);
        } else if(updatePassword) {
            // 비밀번호만 업데이트
            updateSql = "UPDATE user_info SET nickname=?, birthday=?, phoneNum=?, email=?, postNum=?, address=?, password=? WHERE id=?";
            updateStmt = conn.prepareStatement(updateSql);
            updateStmt.setString(1, nickname);
            updateStmt.setString(2, birthday);
            updateStmt.setString(3, phoneNum);
            updateStmt.setString(4, email);
            updateStmt.setString(5, postNum);
            updateStmt.setString(6, fullAddress);
            updateStmt.setString(7, encryptedPassword);
            updateStmt.setString(8, userId);
        } else {
            // 기본 정보만 업데이트
            updateSql = "UPDATE user_info SET nickname=?, birthday=?, phoneNum=?, email=?, postNum=?, address=? WHERE id=?";
            updateStmt = conn.prepareStatement(updateSql);
            updateStmt.setString(1, nickname);
            updateStmt.setString(2, birthday);
            updateStmt.setString(3, phoneNum);
            updateStmt.setString(4, email);
            updateStmt.setString(5, postNum);
            updateStmt.setString(6, fullAddress);
            updateStmt.setString(7, userId);
        }
        
        int result = updateStmt.executeUpdate();
        
        if(result > 0) {
            // 세션의 닉네임 정보도 업데이트
            session.setAttribute("userNickname", nickname);
            
            // 게시글과 댓글의 닉네임도 업데이트
            String updatePostsSql = "UPDATE posts SET nickname=? WHERE userId=?";
            PreparedStatement updatePostsStmt = conn.prepareStatement(updatePostsSql);
            updatePostsStmt.setString(1, nickname);
            updatePostsStmt.setString(2, userId);
            updatePostsStmt.executeUpdate();
            updatePostsStmt.close();
            
            String updateCommentsSql = "UPDATE comments SET nickname=? WHERE userId=?";
            PreparedStatement updateCommentsStmt = conn.prepareStatement(updateCommentsSql);
            updateCommentsStmt.setString(1, nickname);
            updateCommentsStmt.setString(2, userId);
            updateCommentsStmt.executeUpdate();
            updateCommentsStmt.close();
            
            out.print("success");
        } else {
            out.print("업데이트에 실패했습니다.");
        }
        
        updateStmt.close();
        conn.close();
        
    } catch(Exception e) {
        e.printStackTrace();
        out.print("서버 오류가 발생했습니다: " + e.getMessage());
    }
%>