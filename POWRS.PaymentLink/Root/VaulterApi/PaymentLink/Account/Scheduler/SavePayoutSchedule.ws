Response.SetHeader("Access-Control-Allow-Origin","*");

({
    "Mode":Required(String(PMode)),
    "Day":Required(Int(PDay))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

SessionUser:= Global.ValidateAgentApiToken(true, false);

if(SessionUser.role != POWRS.PaymentLink.Models.AccountRole.ClientAdmin.ToString()) then
(
    Forbidden("Insuficient permissions");
);

errorMessages:= Create(System.Collections.Generic.List, System.String);
try
(   
    parsedMode:= POWRS.Payment.PaySpot.Scheduler.RecurrenceMode.Daily;
    day:= -1;

    if(!System.Enum.TryParse(POWRS.Payment.PaySpot.Scheduler.RecurrenceMode,PMode, true, parsedMode)) then 
    (
        errorMessages.Add("Mode");
    );

    if(parsedMode == POWRS.Payment.PaySpot.Scheduler.RecurrenceMode.Weekly) then 
    (
        if(PDay < 1 || PDay > 5) then 
        (
            errorMessages.Add("Day");
        );
    )
    else if(parsedMode == POWRS.Payment.PaySpot.Scheduler.RecurrenceMode.Monthly) then 
    (
        if(PDay < 1 || PDay > 31) then 
        (
             errorMessages.Add("Day");
        );
    );

    if(errorMessages.Count > 0) then 
    (
        Error("");
    );

    payoutSchedule:= POWRS.Payment.PaySpot.Scheduler.PayoutSchedule.Get(SessionUser.orgName) ?? 
                    Create(POWRS.Payment.PaySpot.Scheduler.PayoutSchedule);

    payoutSchedule.OrganizationName:= SessionUser.orgName;
    payoutSchedule.Mode:= parsedMode;
    payoutSchedule.Day:= PDay;
    
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
    if(errorMessages.Count > 0) then 
    (
       BadRequest(errorMessages);
    )
    else
    (
        BadRequest(Exception.Message);
    );
);