namespace POWRS.PaymentLink.Enums.Reports
{
    public enum TopicFilter
    {
        NoFilter,
        PayLinksVolume,
        AveragePayLink,
        LatestPayLink,
        PayLinkFrequency,
        OnboardingActivity
    }
    public enum TopicFilterCondition
    {
        LessThan,
        EqualTo,
        GreaterThan
    }
}
