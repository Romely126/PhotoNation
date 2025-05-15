import javax.mail.*;
import javax.mail.internet.*;
import java.util.Properties;
import java.security.SecureRandom;

public class GmailSender {

    // 이메일 전송 메서드
    public void sendEmailVerificationCode(String email) throws Exception {
        // 6자리 인증 코드 생성
        String verificationCode = generateVerificationCode();

        // 이메일 내용 설정
        String subject = "이메일 인증 코드";
        String content = "귀하의 인증 코드는 " + verificationCode + " 입니다. 해당 코드를 입력해주세요.";

        // 발송자 이메일 주소
        String from = "vega0101938@gmail.com"; // 발신자 이메일

        // SMTP 서버 정보 설정
        Properties properties = new Properties();
        properties.put("mail.smtp.host", "smtp.gmail.com");
        properties.put("mail.smtp.port", "465");  // SSL 포트
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.socketFactory.port", "465");
        properties.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
        properties.put("mail.smtp.starttls.enable", "true");

        // Gmail 인증
        Authenticator auth = new Gmail();
        Session session = Session.getInstance(properties, auth);
        session.setDebug(true);

        // 이메일 메시지 설정
        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress(from));
        message.addRecipient(Message.RecipientType.TO, new InternetAddress(email));
        message.setSubject(subject);
        message.setContent(content, "text/html; charset=UTF-8");

        // 이메일 전송
        Transport.send(message);

        // 인증 코드 반환 (이후 검증을 위해 사용)
        System.out.println("인증 코드: " + verificationCode); // 로그에 인증 코드 출력 (디버깅용)
    }

    // 6자리 숫자 인증 코드 생성
    private String generateVerificationCode() {
        SecureRandom random = new SecureRandom();
        int code = random.nextInt(999999);
        return String.format("%06d", code); // 6자리로 포맷팅
    }
}
