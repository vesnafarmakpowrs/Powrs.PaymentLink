using System;
using System.Threading.Tasks;
using Waher.Persistence;
using Waher.Persistence.Filters;

namespace POWRS.PaymentLink.Onboarding
{
    public class Onboarding
    {
        public GeneralCompanyInformation GeneralCompanyInformation { get; set; } = new();
        public CompanyStructure CompanyStructure { get; set; } = new();
        public BusinessData BusinessData { get; set; } = new();

        public bool CanSubmit
        {
            get
            {
                return GeneralCompanyInformation?.IsCompleted() == true &&
                CompanyStructure?.IsCompleted() == true &&
                BusinessData?.IsCompleted() == true;
            }
        }

        public static async Task<Onboarding> GetOnboardingData(string userName)
        {
            if (string.IsNullOrEmpty(userName))
            {
                throw new Exception("parameter username is mandatory");
            }

            var userNameFilter = new FilterFieldEqualTo("UserName", userName);
            var companyInformationsTask = Database.FindFirstDeleteRest<GeneralCompanyInformation>(userNameFilter);
            var companyStructureTask = Database.FindFirstDeleteRest<CompanyStructure>(userNameFilter);
            var businessDataTask = Database.FindFirstDeleteRest<BusinessData>(userNameFilter);

            Task[] tasks = new Task[]
            {
                   companyInformationsTask,
                   companyStructureTask,
                   businessDataTask,
            };

            await Task.WhenAll(tasks);

            var onboardingResult = new Onboarding
            {
                GeneralCompanyInformation = companyInformationsTask.Result ?? new GeneralCompanyInformation(),
                CompanyStructure = companyStructureTask.Result ?? new CompanyStructure(),
                BusinessData = businessDataTask.Result ?? new BusinessData(),
            };

            return onboardingResult;
        }
    }
}
