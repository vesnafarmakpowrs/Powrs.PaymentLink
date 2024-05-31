Response.SetHeader("Access-Control-Allow-Origin","*");
SessionUser:= Global.ValidateAgentApiToken(true, false);

try
(
        payoutSchedule:= POWRS.Payment.PaySpot.Scheduler.PayoutSchedule.Get(SessionUser.orgName);

        if(payoutSchedule == null) then 
        (
            payoutSchedule:=  Create(POWRS.Payment.PaySpot.Scheduler.PayoutSchedule);
            payoutSchedule.WorkingDay:= System.DayOfWeek.Monday;
        );   
    
    {
       "WorkingDay": payoutSchedule.WorkingDay,
       "Mode": payoutSchedule.Mode,
       "DayInMonth": payoutSchedule.DayInMonth
    }
)
catch
(
    BadRequest(Exception.Message);
);