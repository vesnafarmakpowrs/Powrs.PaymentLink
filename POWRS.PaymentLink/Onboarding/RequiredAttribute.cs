using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace POWRS.PaymentLink.Onboarding
{
    [AttributeUsage(AttributeTargets.Property, Inherited = false, AllowMultiple = false)]
    public sealed class RequiredAttribute : Attribute
    {
        public string RegexPattern { get; }

        public RequiredAttribute(string regexPattern = null)
        {
            RegexPattern = regexPattern;
        }
    }
}
