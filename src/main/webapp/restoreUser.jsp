<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.google.gson.JsonObject" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="javax.naming.Context" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.sql.DataSource" %>

<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
    
    String userId = request.getParameter("userId");
    String withdrawDate = request.getParameter("withdrawDate");
    
    JsonObject result = new JsonObject();
    
    if (userId == null || withdrawDate == null || userId.trim().isEmpty() || withdrawDate.trim().isEmpty()) {
        result.addProperty("success", false);
        result.addProperty("message", "필수 파라미터가 누락되었습니다.");
        out.print(new Gson().toJson(result));
        return;
    }
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        // DB 연결
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/photonation?useSSL=false&serverTimezone=UTC", "root", "1234");
        
        if (conn == null) {
            result.addProperty("success", false);
            result.addProperty("message", "데이터베이스 연결에 실패했습니다.");
            out.print(new Gson().toJson(result));
            return;
        }
        
        conn.setAutoCommit(false); // 트랜잭션 시작
        
     	// 1. lost_user에서 사용자 정보 조회
        String selectQuery = "SELECT * FROM lost_user WHERE id = ? AND withdrawDate = ?";
        pstmt = conn.prepareStatement(selectQuery);
        pstmt.setString(1, userId.trim());
        pstmt.setString(2, withdrawDate.trim());
        rs = pstmt.executeQuery();

        if (!rs.next()) {
            conn.rollback();
            result.addProperty("success", false);
            result.addProperty("message", "해당 탈퇴 회원을 찾을 수 없습니다.");
            out.print(new Gson().toJson(result));
            return;
        }

        // 사용자 정보 저장
        String id = rs.getString("id");
        String password = rs.getString("password");
        String name = rs.getString("name");
        String nickname = rs.getString("nickname");
        String sex = rs.getString("sex");
        Date birthday = rs.getDate("birthday");
        String phoneNum = rs.getString("phoneNum");
        String email = rs.getString("email");
        String postNum = rs.getString("postNum");
        String address = rs.getString("address");
        Timestamp joinDate = rs.getTimestamp("joinDate");

        rs.close();  // rs를 닫고 나서 pstmt를 닫음
        pstmt.close();

        // 2. 기존 활성 계정 확인
        String checkExistQuery = "SELECT COUNT(*) FROM user_info WHERE id = ?";
        pstmt = conn.prepareStatement(checkExistQuery);
        pstmt.setString(1, id);
        ResultSet checkRs = pstmt.executeQuery();

        boolean accountExists = false;
        if (checkRs.next()) {
            accountExists = checkRs.getInt(1) > 0;
        }
        checkRs.close();  // checkRs를 닫은 후 pstmt 닫기
        pstmt.close();

        if (accountExists) {
            conn.rollback();
            result.addProperty("success", false);
            result.addProperty("message", "이미 동일한 ID의 활성 계정이 존재합니다.");
            out.print(new Gson().toJson(result));
            return;
        }

        
        // 3. user_info에 데이터 복원
        String insertQuery = "INSERT INTO user_info (id, password, name, nickname, sex, birthday, phoneNum, email, postNum, address, joinDate, actived) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(insertQuery);
        pstmt.setString(1, id);
        pstmt.setString(2, password);
        pstmt.setString(3, name);
        pstmt.setString(4, nickname);
        pstmt.setString(5, sex);
        pstmt.setDate(6, birthday);
        pstmt.setString(7, phoneNum);
        pstmt.setString(8, email);
        pstmt.setString(9, postNum);
        pstmt.setString(10, address);
        pstmt.setTimestamp(11, joinDate);
        pstmt.setInt(12, 1);
        
        int insertResult = pstmt.executeUpdate();
        pstmt.close();
        
        if (insertResult > 0) {
        	// 4. 프로필 이미지 복원 (데이터가 존재하는 경우)
        	String profileQuery = "SELECT profileImage FROM lost_user_profiles WHERE id = ? AND withdrawDate = ?";
        	pstmt = conn.prepareStatement(profileQuery);
        	pstmt.setString(1, userId.trim());
        	pstmt.setString(2, withdrawDate.trim());
        	ResultSet profileRs = pstmt.executeQuery();

        	if (profileRs.next() && profileRs.getBlob("profileImage") != null) {
        	    // BLOB 데이터를 먼저 가져오기
        	    Blob profileImageBlob = profileRs.getBlob("profileImage");
        	    
        	    // ResultSet과 PreparedStatement 닫기
        	    profileRs.close();
        	    pstmt.close();
        	    
        	    // 새로운 PreparedStatement로 프로필 이미지 업데이트
        	    String updateProfileQuery = "UPDATE user_info SET profileImg = ? WHERE id = ?";
        	    pstmt = conn.prepareStatement(updateProfileQuery);
        	    pstmt.setBlob(1, profileImageBlob);
        	    pstmt.setString(2, id);
        	    pstmt.executeUpdate();
        	    pstmt.close();
        	} else {
        	    // ResultSet과 PreparedStatement 닫기
        	    profileRs.close();
        	    pstmt.close();
        	}
            
            if (profileRs != null) profileRs.close();
            
            // 5. lost_user_profiles에서 삭제
            String deleteProfileQuery = "DELETE FROM lost_user_profiles WHERE id = ? AND withdrawDate = ?";
            pstmt = conn.prepareStatement(deleteProfileQuery);
            pstmt.setString(1, userId.trim());
            pstmt.setString(2, withdrawDate.trim());
            pstmt.executeUpdate();
            pstmt.close();
            
            // 6. lost_user에서 삭제
            String deleteQuery = "DELETE FROM lost_user WHERE id = ? AND withdrawDate = ?";
            pstmt = conn.prepareStatement(deleteQuery);
            pstmt.setString(1, userId.trim());
            pstmt.setString(2, withdrawDate.trim());
            int deleteResult = pstmt.executeUpdate();
            
            if (deleteResult > 0) {
                conn.commit(); // 트랜잭션 커밋
                result.addProperty("success", true);
                result.addProperty("message", "계정이 성공적으로 복구되었습니다.");
                result.addProperty("restoredUserId", id);
            } else {
                conn.rollback();
                result.addProperty("success", false);
                result.addProperty("message", "계정 복구 중 삭제 작업에서 오류가 발생했습니다.");
            }
        } else {
            conn.rollback();
            result.addProperty("success", false);
            result.addProperty("message", "계정 복구 중 삽입 작업에서 오류가 발생했습니다.");
        }
        
    } catch (ClassNotFoundException e) {
        try {
            if (conn != null) conn.rollback();
        } catch (SQLException se) {
            se.printStackTrace();
        }
        result.addProperty("success", false);
        result.addProperty("message", "데이터베이스 드라이버를 찾을 수 없습니다.");
        e.printStackTrace();
    } catch (SQLException e) {
        try {
            if (conn != null) conn.rollback();
        } catch (SQLException se) {
            se.printStackTrace();
        }
        result.addProperty("success", false);
        result.addProperty("message", "데이터베이스 오류가 발생했습니다: " + e.getMessage());
        e.printStackTrace();
    } catch (Exception e) {
        try {
            if (conn != null) conn.rollback();
        } catch (SQLException se) {
            se.printStackTrace();
        }
        result.addProperty("success", false);
        result.addProperty("message", "서버 오류가 발생했습니다: " + e.getMessage());
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    out.print(new Gson().toJson(result));
%>