﻿using Waher.Content.Html.Elements;

namespace POWRS.PaymentLink.Onboarding.Enums
{
    public enum StampUsage
    {
        None,
        UseStamp,
        DoNotUseStamp
    }

    public enum TaxLiability
    {
        None,
        Yes,
        No
    }

    public enum OnboardingPurpose
    {
        Other,
        UsingVaulterPaylinkService
    }

    public enum FunctionaStatusBeneficialOwner
    {
        Yes,
        No
    }

    public enum OwnerStrcture
    {
        Person,
        Company,
        PersonAndCompany
    }

    public enum  OffShoreFondationTrast
    {
        Yes,
        No
    }

    public enum DocumentType 
    {
        IDCard,
        Passport
    }
}
