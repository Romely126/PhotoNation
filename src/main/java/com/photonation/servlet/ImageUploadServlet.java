package com.photonation.servlet;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import org.json.*;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 15,
    location = ""  // 임시 파일 저장 위치를 서블릿 컨테이너의 기본값으로 사용
)
@WebServlet("/uploadImage")
public class ImageUploadServlet extends HttpServlet {
    
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	@Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject jsonResponse = new JSONObject();
        
        try {
            System.out.println("파일 업로드 요청 받음");
            
            // 파일 저장 경로 설정
            String uploadPath = getServletContext().getRealPath("/uploads");
            System.out.println("파일 저장 경로: " + uploadPath);
            
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                boolean created = uploadDir.mkdirs();
                System.out.println("파일 저장 디렉토리 생성: " + created);
            }
            
            Part filePart = request.getPart("file");
            System.out.println("파일 크기: " + filePart.getSize());
            System.out.println("파일 컨텐츠 타입: " + filePart.getContentType());
            
            String fileName = getSubmittedFileName(filePart);
            System.out.println("파일 이름: " + fileName);
            
            // 파일 이름 유효성 검사
            if (fileName == null || fileName.trim().isEmpty()) {
                throw new ServletException("파일 이름을 입력해주세요.");
            }
            
            // 파일 확장자 유효성 검사
            String fileExt = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
            if (!isValidImageExtension(fileExt)) {
                throw new ServletException("허용되지 않은 파일 확장자입니다. (jpg, jpeg, png, gif만 가능)");
            }
            
            String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
            String filePath = uploadPath + File.separator + uniqueFileName;
            System.out.println("파일 저장 경로: " + filePath);
            
            // 파일 저장
            filePart.write(filePath);
            System.out.println("파일 저장 완료");
            
            // 파일 유효성 검사
            File savedFile = new File(filePath);
            if (savedFile.exists()) {
                System.out.println("파일 저장 완료. 크기: " + savedFile.length() + " bytes");
            } else {
                throw new ServletException("파일 저장 실패");
            }
            
            // 파일 URL 반환
            String fileUrl = request.getContextPath() + "/uploads/" + uniqueFileName;
            System.out.println("반환 URL: " + fileUrl);
            
            jsonResponse.put("url", fileUrl);
            
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("오류: " + e.getMessage());
            jsonResponse.put("error", e.getMessage() != null ? e.getMessage() : "파일 업로드 중 오류 발생");
        }
        
        String responseStr = jsonResponse.toString();
        System.out.println("응답 JSON: " + responseStr);
        out.print(responseStr);
    }
    
    private String getSubmittedFileName(Part part) {
        String header = part.getHeader("content-disposition");
        System.out.println("Content-Disposition 헤더: " + header);
        
        if(header == null) return null;
        
        for(String token : header.split(";")) {
            if(token.trim().startsWith("filename")) {
                String fileName = token.substring(token.indexOf("=") + 2, token.length() - 1);
                System.out.println("파일 이름: " + fileName);
                return fileName;
            }
        }
        return null;
    }
    
    private boolean isValidImageExtension(String extension) {
        return extension != null && (
            extension.equals("jpg") ||
            extension.equals("jpeg") ||
            extension.equals("png") ||
            extension.equals("gif")
        );
    }
} 