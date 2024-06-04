Response.SetHeader("Access-Control-Allow-Origin","*");
SessionUser:= Global.ValidateAgentApiToken(true, false);

try
(
        payoutSchedule:= POWRS.Payment.PaySpot.Scheduler.PayoutSchedule.Get(SessionUser.orgName);

        if(payoutSchedule == null) then 
        (
            payoutSchedule:=  Create(POWRS.Payment.PaySpot.Scheduler.PayoutSchedule);
            payoutSchedule.Day:= -1;
        );   
    
    {
       "Mode": payoutSchedule.Mode,
       "Day": payoutSchedule.Day,
       "CanModify": SessionUser.role == POWRS.PaymentLink.Models.AccountRole.ClientAdmin.ToString()
    }
)
catch
(
    BadRequest(Exception.Message);
);