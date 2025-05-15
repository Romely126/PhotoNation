// 이메일 인증 코드 생성 및 비교
@WebServlet("/user")
public class UserServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String cmd = request.getParameter("cmd");

        if ("sendVerificationEmail".equals(cmd)) {
            String email = request.getParameter("email");
            GmailSender gmailSender = new GmailSender();
            try {
                // 이메일 인증 코드 발송
                gmailSender.sendEmailVerificationCode(email);

                // 인증 코드를 세션에 저장 (예시)
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
