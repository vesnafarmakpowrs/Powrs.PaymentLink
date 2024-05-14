using System;
using System.IO;

namespace POWRS.PaymentLink.Onboarding
{
    public class Document
    {
        private string name;
        private string content;
        public string Name { get => name; set => name = value; }
        public string Content { get => content; set => content = value; }

        public static bool IsBase64String(string base64)
        {
            Span<byte> buffer = new Span<byte>(new byte[base64.Length]);
            return Convert.TryFromBase64String(base64, buffer, out int bytesParsed);
        }
    }
}
