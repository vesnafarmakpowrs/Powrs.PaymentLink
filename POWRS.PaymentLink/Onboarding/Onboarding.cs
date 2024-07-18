using System;
using System.ComponentModel;
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
        public LegalDocuments LegalDocuments { get; set; } = new();

        public bool CanSubmit
        {
            get
            {
                bool canSubmit = GeneralCompanyInformation?.IsCompleted() == true &&
                CompanyStructure?.IsCompleted() == true &&
                BusinessData?.IsCompleted() == true &&
                LegalDocuments?.IsCompleted() == true;

                if (!canSubmit)
                    return false;

                if (!BusinessData.IPSOnly && string.IsNullOrWhiteSpace(LegalDocuments?.PromissoryNote))
                    return false;
                else
                    return true;
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
            var legalDocumentsTask = Database.FindFirstDeleteRest<LegalDocuments>(userNameFilter);

            Task[] tasks = new Task[]
            {
                   companyInformationsTask,
                   companyStructureTask,
                   businessDataTask,
                   legalDocumentsTask
            };

            await Task.WhenAll(tasks);

            var onboardingResult = new Onboarding
            {
                GeneralCompanyInformation = companyInformationsTask.Result ?? new GeneralCompanyInformation(),
                CompanyStructure = companyStructureTask.Result ?? new CompanyStructure(),
                BusinessData = businessDataTask.Result ?? new BusinessData(),
                LegalDocuments = legalDocumentsTask.Result ?? new LegalDocuments()
            };

            return onboardingResult;
        }
    }
}
