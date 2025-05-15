import javax.mail.*;
import javax.mail.internet.*;
import java.util.Properties;
import java.security.SecureRandom;

public class GmailSender {

    // �̸��� ���� �޼���
    public void sendEmailVerificationCode(String email) throws Exception {
        // 6�ڸ� ���� �ڵ� ����
        String verificationCode = generateVerificationCode();

        // �̸��� ���� ����
        String subject = "�̸��� ���� �ڵ�";
        String content = "������ ���� �ڵ�� " + verificationCode + " �Դϴ�. �ش� �ڵ带 �Է����ּ���.";

        // �߼��� �̸��� �ּ�
        String from = "vega0101938@gmail.com"; // �߽��� �̸���

        // SMTP ���� ���� ����
        Properties properties = new Properties();
        properties.put("mail.smtp.host", "smtp.gmail.com");
        properties.put("mail.smtp.port", "465");  // SSL ��Ʈ
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.socketFactory.port", "465");
        properties.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
        properties.put("mail.smtp.starttls.enable", "true");

        // Gmail ����
        Authenticator auth = new Gmail();
        Session session = Session.getInstance(properties, auth);
        session.setDebug(true);

        // �̸��� �޽��� ����
        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress(from));
        message.addRecipient(Message.RecipientType.TO, new InternetAddress(email));
        message.setSubject(subject);
        message.setContent(content, "text/html; charset=UTF-8");

        // �̸��� ����
        Transport.send(message);

        // ���� �ڵ� ��ȯ (���� ������ ���� ���)
        System.out.println("���� �ڵ�: " + verificationCode); // �α׿� ���� �ڵ� ��� (������)
    }

    // 6�ڸ� ���� ���� �ڵ� ����
    private String generateVerificationCode() {
        SecureRandom random = new SecureRandom();
        int code = random.nextInt(999999);
        return String.format("%06d", code); // 6�ڸ��� ������
    }
}
