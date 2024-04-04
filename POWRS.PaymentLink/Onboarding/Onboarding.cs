using System;
using System.Threading.Tasks;
using Waher.Persistence;
using Waher.Persistence.Filters;

namespace POWRS.PaymentLink.Onboarding
{
    public class Onboarding
    {
        public BaseCompanyInformation BaseCompanyInformation { get; private set; } = new();
        public CompanyModel CompanyModel { get; private set; } = new();
        public CompanyStructure CompanyStructure { get; private set; } = new();
        public EconomicData EconomicData { get; private set; } = new();

        public static async Task<Onboarding> GetOnboardingData(string userName)
        {
            if (string.IsNullOrEmpty(userName))
            {
                throw new Exception("parameter username is mandatory");
            }

            var userNameFilter = new FilterFieldEqualTo("UserName", userName);
            var companyInformationsTask = Database.FindFirstDeleteRest<BaseCompanyInformation>(userNameFilter);
            var companyModelTask = Database.FindFirstDeleteRest<CompanyModel>(userNameFilter);
            var companyStructureTask = Database.FindFirstDeleteRest<CompanyStructure>(userNameFilter);
            var economicDataTask = Database.FindFirstDeleteRest<EconomicData>(userNameFilter);

            Task[] tasks = new Task[]
            {
                   companyInformationsTask,
                   companyModelTask,
                   companyStructureTask,
                   economicDataTask
            };

            await Task.WhenAll(tasks);

            var onboardingResult = new Onboarding
            {
                BaseCompanyInformation = companyInformationsTask.Result ?? new BaseCompanyInformation(),
                CompanyModel = companyModelTask.Result ?? new CompanyModel(),
                CompanyStructure = companyStructureTask.Result ?? new CompanyStructure(),
                EconomicData = economicDataTask.Result ?? new EconomicData(),
            };

            return onboardingResult;
        }
    }
}
