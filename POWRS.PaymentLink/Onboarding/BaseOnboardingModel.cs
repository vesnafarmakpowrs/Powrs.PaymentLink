using System;
using System.Collections.Generic;
using System.Reflection;
using Waher.Persistence.Attributes;

namespace POWRS.PaymentLink.Onboarding
{
    public class BaseOnboardingModel<T> where T : class
    {
        public virtual bool IsCompleted()
        {
            throw new NotImplementedException();
        }

        public BaseOnboardingModel() { }
        public BaseOnboardingModel(string userName)
        {
            this.userName = userName;
        }

        private string objectId;
        private string userName;

        [ObjectId]
        public string ObjectId { get => this.objectId; set => this.objectId = value; }
        public string UserName { get => this.userName; set => this.userName = value; }

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

        public T Fill(T instance, Dictionary<string, object> data)
        {
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
                                var parsedDateTime = DateTime.ParseExact(value?.ToString(), "dd/MM/yyyy", System.Globalization.CultureInfo.CurrentUICulture);
                                property.SetValue(instance, parsedDateTime);
                            }
                            else if (property.PropertyType == typeof(decimal))
                            {
                                if (!decimal.TryParse(value?.ToString(), out decimal parsedDecimal))
                                {
                                    throw new Exception();
                                }

                                property.SetValue(instance, parsedDecimal);
                            }
                            else if (property.PropertyType == typeof(double))
                            {
                                if (!double.TryParse(value?.ToString(), out double parsedDouble))
                                {
                                    throw new Exception();
                                }

                                property.SetValue(instance, parsedDouble);
                            }
                            else if (property.PropertyType == typeof(int))
                            {
                                if (!int.TryParse(value?.ToString(), out int parsedInt))
                                {
                                    throw new Exception();
                                }

                                property.SetValue(instance, parsedInt);
                            }
                            else if (property.PropertyType == typeof(string))
                            {
                                property.SetValue(instance, value);
                            }
                        }
                        catch (Exception ex)
                        {
                            var message = "Unable to set property: " + property.Name + ". Given value: " + (value ?? string.Empty) + "Error: " + ex.Message;
                            throw new Exception(message);
                        }
                    }
                }
            }

            return instance;
        }
    }
}
