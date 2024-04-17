using POWRS.PaymentLink.Onboarding.Structure;
using System;
using System.Threading.Tasks;
using Waher.Persistence;
using Waher.Persistence.Filters;

namespace POWRS.PaymentLink.Onboarding
{
    public class Onboarding
    {
        public GeneralCompanyInformation GeneralCompanyInformation { get; private set; } = new();
        public CompanyStructure CompanyStructure { get; private set; } = new();
        public BussinesData EconomicData { get; private set; } = new();

        public static async Task<Onboarding> GetOnboardingData(string userName)
        {
            if (string.IsNullOrEmpty(userName))
            {
                throw new Exception("parameter username is mandatory");
            }

            var userNameFilter = new FilterFieldEqualTo("UserName", userName);
            var companyInformationsTask = Database.FindFirstDeleteRest<GeneralCompanyInformation>(userNameFilter);
            
            var companyStructureTask = Database.FindFirstDeleteRest<CompanyStructure>(userNameFilter);
            var economicDataTask = Database.FindFirstDeleteRest<BussinesData>(userNameFilter);

            Task[] tasks = new Task[]
            {
                   companyInformationsTask,
                   companyStructureTask,
                   economicDataTask
            };

            await Task.WhenAll(tasks);

            var onboardingResult = new Onboarding
            {
                GeneralCompanyInformation = companyInformationsTask.Result ?? new GeneralCompanyInformation(),
                CompanyStructure = companyStructureTask.Result ?? new CompanyStructure(),
                EconomicData = economicDataTask.Result ?? new BussinesData(),
            };

            return onboardingResult;
        }
    }
}
