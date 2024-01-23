Response.SetHeader("Access-Control-Allow-Origin","*");
SessionUser:= Global.ValidateAgentApiToken(false, false);

({
    "link" : Required(Str(PLink)),
    "width": Required(Int(PWidth))
}:=Posted) ??? BadRequest("Request does not conform to the specification");

try
(
 encoder:= Create(Waher.Content.QR.QrEncoder);
 Rgba:= encoder.GenerateMatrix(CorrectionLevel.H, PLink).ToRGBA(PWidth, PWidth);
 pixelInfo:= PixelInformation.FromRaw(SKColorType.Rgba8888, Rgba, PWidth, PWidth, PWidth << 2);
 base64:= Base64Encode(pixelInfo.EncodeAsPng());
)
catch
(
 Log.Error(Exception.Message, null);
 BadRequest(Exception.Message);
);