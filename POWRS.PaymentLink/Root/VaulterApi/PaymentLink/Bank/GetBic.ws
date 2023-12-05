({
    "bankAccount":Required(String(PBankAccount)) like "SE\\d{22}"
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

Global.ValidateAgentApiToken(false);

bankAccountInformationList := [
         { 'ClearingNumberFrom' : 1100, 'ClearingNumberTo' : 1199, 'Method' : 1, 'IbanId' : "300", 'Bic' :"NDEASESS" },
	 { 'ClearingNumberFrom' : 1200, 'ClearingNumberTo' : 1399, 'Method' : 1, 'IbanId' : "120", 'Bic' :"DABASESX" },
	 { 'ClearingNumberFrom' : 1400, 'ClearingNumberTo' : 2099, 'Method' : 1, 'IbanId' : "300", 'Bic' :"NDEASESS" },
	 { 'ClearingNumberFrom' : 2300, 'ClearingNumberTo' : 2399, 'Method' : 1, 'IbanId' : "230", 'Bic' :"AABASESS" },
	 { 'ClearingNumberFrom' : 2400, 'ClearingNumberTo' : 2499, 'Method' : 1, 'IbanId' : "120", 'Bic' :"DABASESX" },
	 { 'ClearingNumberFrom' : 3000, 'ClearingNumberTo' : 3399, 'Method' : 1, 'IbanId' : "300", 'Bic' :"NDEASESS" },
	 { 'ClearingNumberFrom' : 3300, 'ClearingNumberTo' : 3300, 'Method' : 0, 'IbanId' : "300", 'Bic' :"NDEASESS" },
	 { 'ClearingNumberFrom' : 3400, 'ClearingNumberTo' : 3409, 'Method' : 1, 'IbanId' : "902", 'Bic' :"ELLFSESS" },
	 { 'ClearingNumberFrom' : 3410, 'ClearingNumberTo' : 4999, 'Method' : 1, 'IbanId' : "300", 'Bic' :"NDEASESS" },
	 { 'ClearingNumberFrom' : 3782, 'ClearingNumberTo' : 3782, 'Method' : 0, 'IbanId' : "300", 'Bic' :"NDEASESS" },
	 { 'ClearingNumberFrom' : 5000, 'ClearingNumberTo' : 5999, 'Method' : 1, 'IbanId' : "500", 'Bic' :"ESSESESS" },
	 { 'ClearingNumberFrom' : 6000, 'ClearingNumberTo' : 6999, 'Method' : 2, 'IbanId' : "600", 'Bic' :"HANDSESS" },
	 { 'ClearingNumberFrom' : 7000, 'ClearingNumberTo' : 7999, 'Method' : 1, 'IbanId' : "800", 'Bic' :"SWEDSESS" },
	 { 'ClearingNumberFrom' : 8000, 'ClearingNumberTo' : 8999, 'Method' : 3, 'IbanId' : "800", 'Bic' :"SWEDSESS" },
	 { 'ClearingNumberFrom' : 9020, 'ClearingNumberTo' : 9029, 'Method' : 1, 'IbanId' : "902", 'Bic' :"ELLFSESS" },
	 { 'ClearingNumberFrom' : 9040, 'ClearingNumberTo' : 9049, 'Method' : 1, 'IbanId' : "904", 'Bic' :"CITISESX" },
	 { 'ClearingNumberFrom' : 9060, 'ClearingNumberTo' : 9069, 'Method' : 1, 'IbanId' : "902", 'Bic' :"ELLFSESS" },
	 { 'ClearingNumberFrom' : 9070, 'ClearingNumberTo' : 9079, 'Method' : 1, 'IbanId' : "907", 'Bic' :"FEMAMTMT" },
	 { 'ClearingNumberFrom' : 9100, 'ClearingNumberTo' : 9109, 'Method' : 1, 'IbanId' : "910", 'Bic' :"NNSESES1" },
	 { 'ClearingNumberFrom' : 9120, 'ClearingNumberTo' : 9124, 'Method' : 1, 'IbanId' : "500", 'Bic' :"ESSESESS" },
	 { 'ClearingNumberFrom' : 9130, 'ClearingNumberTo' : 9149, 'Method' : 1, 'IbanId' : "500", 'Bic' :"ESSESESS" },
	 { 'ClearingNumberFrom' : 9150, 'ClearingNumberTo' : 9169, 'Method' : 1, 'IbanId' : "915", 'Bic' :"SKIASESS" },
	 { 'ClearingNumberFrom' : 9170, 'ClearingNumberTo' : 9179, 'Method' : 1, 'IbanId' : "917", 'Bic' :"IKANSE21" },
	 { 'ClearingNumberFrom' : 9190, 'ClearingNumberTo' : 9199, 'Method' : 1, 'IbanId' : "919", 'Bic' :"DNBASESX" },
	 { 'ClearingNumberFrom' : 9230, 'ClearingNumberTo' : 9239, 'Method' : 1, 'IbanId' : "923", 'Bic' :"MARGSESS" },
	 { 'ClearingNumberFrom' : 9250, 'ClearingNumberTo' : 9259, 'Method' : 1, 'IbanId' : "925", 'Bic' :"SBAVSESS" },
	 { 'ClearingNumberFrom' : 9270, 'ClearingNumberTo' : 9279, 'Method' : 1, 'IbanId' : "927", 'Bic' :"IBCASES1" },
	 { 'ClearingNumberFrom' : 9300, 'ClearingNumberTo' : 9349, 'Method' : 1, 'IbanId' : "930", 'Bic' :"SWEDSESS" },
	 { 'ClearingNumberFrom' : 9280, 'ClearingNumberTo' : 9289, 'Method' : 1, 'IbanId' : "928", 'Bic' :"RESUSE21" },
	 { 'ClearingNumberFrom' : 9390, 'ClearingNumberTo' : 9399, 'Method' : 1, 'IbanId' : "939", 'Bic' :"LAHYSESS" },
	 { 'ClearingNumberFrom' : 9400, 'ClearingNumberTo' : 9449, 'Method' : 1, 'IbanId' : "940", 'Bic' :"FORXSES1" },
	 { 'ClearingNumberFrom' : 9460, 'ClearingNumberTo' : 9469, 'Method' : 1, 'IbanId' : "946", 'Bic' :"BSNOSESS" },
	 { 'ClearingNumberFrom' : 9470, 'ClearingNumberTo' : 9479, 'Method' : 1, 'IbanId' : "947", 'Bic' :"FTSBSESS" },
	 { 'ClearingNumberFrom' : 9500, 'ClearingNumberTo' : 9549, 'Method' : 2, 'IbanId' : "950", 'Bic' :"NDEASESS" },
	 { 'ClearingNumberFrom' : 9550, 'ClearingNumberTo' : 9569, 'Method' : 1, 'IbanId' : "955", 'Bic' :"AVANSES1" },
	 { 'ClearingNumberFrom' : 9570, 'ClearingNumberTo' : 9579, 'Method' : 2, 'IbanId' : "957", 'Bic' :"SPSDSE23" },
	 { 'ClearingNumberFrom' : 9580, 'ClearingNumberTo' : 9589, 'Method' : 1, 'IbanId' : "958", 'Bic' :"BMPBSESS" },
	 { 'ClearingNumberFrom' : 9590, 'ClearingNumberTo' : 9599, 'Method' : 1, 'IbanId' : "959", 'Bic' :"ERPFSES2" },
	 { 'ClearingNumberFrom' : 9630, 'ClearingNumberTo' : 9639, 'Method' : 1, 'IbanId' : "963", 'Bic' :"LOSADKKK" },
	 { 'ClearingNumberFrom' : 9640, 'ClearingNumberTo' : 9649, 'Method' : 1, 'IbanId' : "964", 'Bic' :"NOFBSESS" },
	 { 'ClearingNumberFrom' : 9650, 'ClearingNumberTo' : 9659, 'Method' : 1, 'IbanId' : "965", 'Bic' :"MEMMSE21" },
	 { 'ClearingNumberFrom' : 9660, 'ClearingNumberTo' : 9669, 'Method' : 1, 'IbanId' : "966", 'Bic' :"SVEASES1" },
	 { 'ClearingNumberFrom' : 9670, 'ClearingNumberTo' : 9679, 'Method' : 1, 'IbanId' : "967", 'Bic' :"JAKMSE22" },
	 { 'ClearingNumberFrom' : 9680, 'ClearingNumberTo' : 9689, 'Method' : 1, 'IbanId' : "968", 'Bic' :"BSTPSESS" },
	 { 'ClearingNumberFrom' : 9700, 'ClearingNumberTo' : 9709, 'Method' : 1, 'IbanId' : "970", 'Bic' :"EKMLSE21" },
	 { 'ClearingNumberFrom' : 9710, 'ClearingNumberTo' : 9719, 'Method' : 1, 'IbanId' : "971", 'Bic' :"LUNADK2B" },
	 { 'ClearingNumberFrom' : 9750, 'ClearingNumberTo' : 9759, 'Method' : 1, 'IbanId' : "975", 'Bic' :"NOHLSESS" },
	 { 'ClearingNumberFrom' : 9780, 'ClearingNumberTo' : 9789, 'Method' : 1, 'IbanId' : "978", 'Bic' :"KLRNSESS" },
	 { 'ClearingNumberFrom' : 9960, 'ClearingNumberTo' : 9969, 'Method' : 2, 'IbanId' : "950", 'Bic' :"NDEASESS" }
];

PCountry := PBankAccount.Substring(0,2);
PCurrency := 'SEK';
ClearingNumber := Int(PBankAccount.Substring(4,4));
Bic:= "";
foreach bank in bankAccountInformationList do
   bank.ClearingNumberFrom <= ClearingNumber && ClearingNumber <= bank.ClearingNumberTo ? Bic := bank.Bic;


Providers:=GetServiceProvidersForBuyingEDaler(PCountry,PCurrency);
Mode:=GetSetting("TAG.Payments.OpenPaymentsPlatform.Mode",TAG.Payments.OpenPaymentsPlatform.OperationMode.Sandbox);
EDalerServiceProviderId := "";	
ServiceProviderId := "";
ServiceProviderType := "";
foreach P in Providers do                     
     if P.Id.Replace(Mode + '.','') == Bic then 
       (
          EDalerServiceProviderId := P.BuyEDalerServiceProvider.Id; 
          ServiceProviderId:= P.Id;
          ServiceProviderType := P.BuyEDalerServiceProvider.GetType();  
       );
   
{
   bic: Bic,
   serviceProviderId : ServiceProviderId,
   eDalerServiceProviderId : EDalerServiceProviderId,
   serviceProviderType : ServiceProviderType
}
