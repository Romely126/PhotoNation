// �̸��� ���� �ڵ� ���� �� ��
@WebServlet("/user")
public class UserServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String cmd = request.getParameter("cmd");

        if ("sendVerificationEmail".equals(cmd)) {
            String email = request.getParameter("email");
            GmailSender gmailSender = new GmailSender();
            try {
                // �̸��� ���� �ڵ� �߼�
                gmailSender.sendEmailVerificationCode(email);

                // ���� �ڵ带 ���ǿ� ���� (����)
                String verificationCode = gmailSender.generateVerificationCode();
                request.getSession().setAttribute("verificationCode", verificationCode);

                response.getWriter().write("success");

            } catch (Exception e) {
                e.printStackTrace();
                response.getWriter().write("fail");
            }

        } else if ("verifyEmailCode".equals(cmd)) {
            String emailCode = request.getParameter("emailCode");
            String sessionCode = (String) request.getSession().getAttribute("verificationCode");

            if (emailCode != null && emailCode.equals(sessionCode)) {
                response.getWriter().write("success");
            } else {
                response.getWriter().write("fail");
            }
        }
    }
}
