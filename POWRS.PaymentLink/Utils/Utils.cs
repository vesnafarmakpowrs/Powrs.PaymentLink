/*
using PdfSharp.Pdf;
using PdfSharp.Pdf.IO;
*/
using System;
using System.Collections.Generic;

namespace POWRS.PaymentLink
{
    public class Utils
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

        /*
        public static void CopyPages(PdfDocument from, PdfDocument to)
        {
            for (int i = 0; i < from.PageCount; i++)
            {
                to.AddPage(from.Pages[i]);
            }
        }
        public static void CombinePDFs(List<string> listPDF, string outputPDF)
        {
            try
            {
                using (PdfDocument outPDF = new PdfDocument())
                {
                    foreach (string item in listPDF)
                    {
                        using (PdfDocument pdfDocument = PdfReader.Open(item, PdfDocumentOpenMode.Import))
                        {
                            CopyPages(pdfDocument, outPDF);
                        }
                    }
                    outPDF.Save(outputPDF);
                }
            }
            catch (Exception ex)
            {
                throw;
            }
        }
        */


    }


}
