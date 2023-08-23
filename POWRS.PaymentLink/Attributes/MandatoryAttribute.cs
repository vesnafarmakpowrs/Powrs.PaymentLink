using System;

namespace POWRS.PaymentLink.Attributes
{
    /// <summary>
    /// Attribute used to mark a mandatory property in class
    /// </summary>
    [AttributeUsage(AttributeTargets.Property, Inherited = false, AllowMultiple = false)]
    internal sealed class MandatoryAttribute : Attribute { }
}
