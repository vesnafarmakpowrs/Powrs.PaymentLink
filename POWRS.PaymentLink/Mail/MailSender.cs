using System;
using System.Net.Mail;
using System.Net;
using System.Threading.Tasks;
using Waher.Events;

namespace POWRS.PaymentLink
{
    public class MailSender
    {
        public static async Task SendHtmlMail(string host, int port, string username, string password, string recepient, string subject, string htmlContent)
        {
            if (string.IsNullOrEmpty(host) || string.IsNullOrEmpty(username) ||
                string.IsNullOrEmpty(password) || string.IsNullOrEmpty(recepient) ||
                string.IsNullOrEmpty(subject) || string.IsNullOrEmpty(htmlContent))
            {
                throw new Exception("Parameters missing");
            }

            try
            {
                var smtpClient = new SmtpClient(host)
                {
                    Port = port,
                    Credentials = new NetworkCredential(username, password),
                    EnableSsl = true,
                };

                var mailMessage = new MailMessage(username, recepient)
                {
                    Subject = subject,
                    Body = htmlContent,
                    IsBodyHtml = true,
                };

                await smtpClient.SendMailAsync(mailMessage);
            }
            catch (Exception ex)
            {
                Log.Error(ex);
            }
        }
    }
}
