using System;
using System.Reflection;

namespace POWRS.PaymentLink.Onboarding
{
    public class BaseOnboarding<T> where T : class
    {
        public bool IsCompleted(T obj)
        {
            Type type = typeof(T);
            PropertyInfo[] properties = type.GetProperties(BindingFlags.Public | BindingFlags.Instance);

            foreach (PropertyInfo property in properties)
            {
                if (property.PropertyType != typeof(string))
                {
                    continue;
                }

                object value = property.GetValue(obj);
                if (string.IsNullOrWhiteSpace(value?.ToString()))
                {
                    return false;
                }
            }

            return true;
        }
    }
}
