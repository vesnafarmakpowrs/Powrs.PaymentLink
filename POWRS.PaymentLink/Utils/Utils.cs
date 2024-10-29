using System;

namespace POWRS.PaymentLink
{
    public static class Utils
    {
        public static bool IsValidBase64String(string base64String, decimal maxSizeMB)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(base64String))
                {
                    return false;
                }

                byte[] byteArray = Convert.FromBase64String(base64String);
                return byteArray.Length <= maxSizeMB * 1024 * 1024;
            }
            catch (FormatException)
            {
                return false;
            }
        }

        public static string PrepareStringForFileName(string fileName)
        {
            return fileName.Replace("Č", "C")
                .Replace("č", "c")
                .Replace("Ć", "C")
                .Replace("ć", "c")
                .Replace("Š", "S")
                .Replace("š", "s")
                .Replace("Đ", "Dj")
                .Replace("đ", "dj")
                .Replace("Ž", "Z")
                .Replace("ž", "z")
                .Replace(" ", "")
                .Replace("'", "")
                .Replace("\"", "");
        }
    }


}
