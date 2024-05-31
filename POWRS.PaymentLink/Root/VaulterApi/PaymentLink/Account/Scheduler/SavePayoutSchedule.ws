Response.SetHeader("Access-Control-Allow-Origin","*");

({
    "WorkingDay":Required(String(PWorkDay)),
    "Mode":Required(String(PMode)),
    "DayInMonth":Required(Int(PDayInMonth))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

SessionUser:= Global.ValidateAgentApiToken(true, false);

if(SessionUser.role != POWRS.PaymentLink.Models.AccountRole.ClientAdmin.ToString()) then
(
    Forbidden("Insuficient permissions");
);

try
(
    errorMessages:= Create(System.Collections.Generics.List, System.String);
    parsedMode:= POWRS.Payment.PaySpot.Scheduler.RecurrenceMode.EveryDay;
    day:= System.DayOfWeek.Monday;

    if(!System.Enum.TryParse(POWRS.Payment.PaySpot.Scheduler.RecurrenceMode, true, parsedMode)) then 
    (
        errorMessages.Add("Mode");
    );

    if(parsedMode == POWRS.Payment.PaySpot.Scheduler.RecurrenceMode.EveryWeek and 
        !System.Enum.TryParse(System.DayOfWeek,PWorkDay true, day)) then 
    (
            errorMessages.Add("WorkDay");
    )
    else if(parsedMode == POWRS.Payment.PaySpot.Scheduler.RecurrenceMode.EveryMonth and 
        (PDayInMonth < 1 || PDayInMonth > 31)) then 
    (
            errorMessages.Add("DayInMonth");
    );

    if(errorMessages.Length > 0) then 
    (
        Error("");
    );

    payoutSchedule:= POWRS.Payment.PaySpot.Scheduler.PayoutSchedule.Get(SessionUser.orgName) ?? 
                    Create(POWRS.Payment.PaySpot.Scheduler.PayoutSchedule);

    payoutSchedule.OrganizationName:= SessionUser.orgName;
    payoutSchedule.Mode:= parsedMode;
    payoutSchedule.WorkingDay:= day;
    payoutSchedule.DayInMonth:= PDayInMonth;
    payoutSchedule.LastUpdated:= NowUtc;
    
    if(System.String.IsNullOrWhiteSpace(payoutSchedule.ObjectId)) then 
    (
        Waher.Persistence.Database.Insert(payoutSchedule);
    )
    else 
    (
        Waher.Persistence.Database.Update(payoutSchedule);
    );

    {
      Message : "ok"
    }
)
catch
(
    Log.Informational(Exception.Message, null);

    if(errorMessages.Length > 0) then 
    (
       BadRequest(errorMessages);
    )
    else
    (
        BadRequest(Exception.Message);
    );
);