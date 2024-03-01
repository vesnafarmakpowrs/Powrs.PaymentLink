using System;
using System.Net.Mail;
using System.Net;
using System.Threading.Tasks;
using Waher.Events;
using System.IO;
using System.Linq;

namespace POWRS.PaymentLink
{
    public class MailSender
    {
        public static async Task SendHtmlMail(string host,
            int port,
            string sender,
            string username,
            string password,
            string recepient,
            string subject,
            string htmlContent,
            string Base64Attachment,
            string AttachementFileName)
        {
            if (string.IsNullOrEmpty(host) || string.IsNullOrEmpty(sender) || string.IsNullOrEmpty(username) ||
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

                var mailMessage = new MailMessage();
                mailMessage.From = new MailAddress(sender, username);
                mailMessage.Subject = subject;
                mailMessage.Body = htmlContent;
                mailMessage.IsBodyHtml = true;

                foreach (var address in recepient.Split(new[] { ";" }, StringSplitOptions.RemoveEmptyEntries))
                {
                    mailMessage.To.Add(address);
                }

                if (!string.IsNullOrEmpty(Base64Attachment))
                {
                        byte[] byteArray = Convert.FromBase64String(Base64Attachment);
                        MemoryStream stream = new MemoryStream(byteArray);
                        string FileName = !string.IsNullOrEmpty(AttachementFileName)? AttachementFileName : "Vaulter.pdf";
                        mailMessage.Attachments.Add(new Attachment(stream, FileName, "application/pdf"));
                }
                await smtpClient.SendMailAsync(mailMessage);
            }
            catch (Exception ex)
            {
                Log.Error(ex);
            }
        }
    }
}
