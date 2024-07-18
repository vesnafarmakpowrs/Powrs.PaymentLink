/*
using PdfSharp.Pdf;
using PdfSharp.Pdf.IO;
*/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;

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
