using System;
using System.ComponentModel.Design;
using System.IO;

namespace POWRS.PaymentLink.Onboarding
{
    public class Document
    {
        private string name;
        private string content;

        public string Name { get => name; set => name = value; }
        public string Content { get => content; set => content = value; }

        public static bool IsValidBase64String(string base64String, decimal maxSizeMB)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(base64String))
                {
                    return false;
                }

                byte[] byteArray = System.Convert.FromBase64String(base64String);
                return byteArray.Length <= maxSizeMB * 1024 * 1024;
            }
            catch (FormatException ex)
            {
                return false;
            }
        }


    }
}
