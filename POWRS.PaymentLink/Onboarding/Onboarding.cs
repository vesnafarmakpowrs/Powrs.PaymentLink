using POWRS.PaymentLink.Onboarding.Documents;
using POWRS.PaymentLink.Onboarding.Structure;
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
        public BussinesData BussinesData { get; set; } = new();
        public LegalDocuments LegalDocuments { get; set; } = new();

        public bool CanSubmit
        {
            get
            {
                return GeneralCompanyInformation?.IsCompleted() == true &&
                CompanyStructure?.IsCompleted() == true &&
                BussinesData?.IsCompleted() == true &&
                LegalDocuments?.IsCompleted() == true;
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
            var bussinesDataTask = Database.FindFirstDeleteRest<BussinesData>(userNameFilter);
            var legalDocumentsTask = Database.FindFirstDeleteRest<LegalDocuments>(userNameFilter);

            Task[] tasks = new Task[]
            {
                   companyInformationsTask,
                   companyStructureTask,
                   bussinesDataTask,
                   legalDocumentsTask
            };

            await Task.WhenAll(tasks);

            var onboardingResult = new Onboarding
            {
                GeneralCompanyInformation = companyInformationsTask.Result ?? new GeneralCompanyInformation(),
                CompanyStructure = companyStructureTask.Result ?? new CompanyStructure(),
                BussinesData = bussinesDataTask.Result ?? new BussinesData(),
                LegalDocuments = legalDocumentsTask.Result ?? new LegalDocuments()
            };

            return onboardingResult;
        }
    }
}
