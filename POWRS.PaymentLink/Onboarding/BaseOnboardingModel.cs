using System;
using System.Collections.Generic;
using System.Reflection;
using Waher.Things.DisplayableParameters;

namespace POWRS.PaymentLink.Onboarding
{
    public class BaseOnboardingModel<T> where T : class
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

        public static T CreateInstance(T instance, Dictionary<string, object> data)
        {
            if (instance == null)
            {
                instance = Activator.CreateInstance<T>();
            }

            PropertyInfo[] properties = typeof(T).GetProperties();

            foreach (var property in properties)
            {
                if (data.ContainsKey(property.Name))
                {
                    object value = data[property.Name];
                    if (value != null)
                    {
                        try
                        {
                            if (property.PropertyType.IsEnum)
                            {
                                property.SetValue(instance, Enum.Parse(property.PropertyType, value.ToString()));
                            }
                            else if (property.PropertyType == typeof(DateTime))
                            {
                                var parsedDateTime = DateTime.Parse(value?.ToString());
                                property.SetValue(instance, parsedDateTime);
                            }
                            else if (property.PropertyType.IsAssignableFrom(value.GetType()))
                            {
                                property.SetValue(instance, value);
                            }
                        }
                        catch(Exception ex)
                        {
                            var message = "Unable to set property: " + property.Name + ". Given value: " + value ?? string.Empty + "Error: " + ex.Message;
                            throw new Exception(message);
                        }
                    }
                }
            }

            return instance;
        }
    }
}
