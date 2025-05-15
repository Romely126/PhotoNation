<%@ page import="java.sql.*, java.util.*, javax.mail.*, javax.mail.internet.*, java.io.*" contentType="text/html;charset=UTF-8" %> 
<%
    // 강제 TLS 1.2 사용 설정
    System.setProperty("https.protocols", "TLSv1.2");
    System.setProperty("javax.net.ssl.SSLContext", "TLSv1.2");
    
    String email = request.getParameter("email");
    String verificationCode = String.format("%06d", new Random().nextInt(999999)); // 랜덤 6자리 인증 코드

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    // 기존 'session' 이름이 아니라 'mailSession'으로 변경
    javax.mail.Session mailSession = null;

    try {
        // DB 연결
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/photonation", "root", "1234");

        // 인증 코드 DB에 저장
        String insertSQL = "INSERT INTO email_verifications (email, verification_code, expired_at) VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 3 MINUTE))";
        pstmt = conn.prepareStatement(insertSQL);
        pstmt.setString(1, email);
        pstmt.setString(2, verificationCode);
        pstmt.executeUpdate();

        // 이메일 발송
        String host = "smtp.gmail.com";
        String from = "vega0101938@gmail.com";  // 발송자 이메일
        String subject = "PhotoNation 입국을 환영합니다!";
        String body = "회원가입까지 얼마 남지 않았습니다!\n\n이메일 인증 코드 : " + verificationCode + "\n\n위 이메일 인증 코드를 입력해주세요";

        // properties 설정
        Properties properties = System.getProperties();
        properties.put("mail.smtp.host", host);
        properties.put("mail.smtp.port", "587");
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");

        // 강제 TLS 1.2 사용
        properties.put("mail.smtp.ssl.protocols", "TLSv1.2");

        // 'mailSession'을 사용하여 세션 생성
        mailSession = javax.mail.Session.getInstance(properties, new javax.mail.Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication("vega0101938@gmail.com", "nifseayweoffhvir");  // 이메일과 앱 비밀번호
            }
        });

        MimeMessage message = new MimeMessage(mailSession);
        message.setFrom(new InternetAddress(from));
        message.addRecipient(Message.RecipientType.TO, new InternetAddress(email));
        message.setSubject(subject);
        message.setText(body);

        Transport.send(message);  // 이메일 발송

        out.print("success");

    } catch (Exception e) {
        e.printStackTrace();
        out.print("error");
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>
