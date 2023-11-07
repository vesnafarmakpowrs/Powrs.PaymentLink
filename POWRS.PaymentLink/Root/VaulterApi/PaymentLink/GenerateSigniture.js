
function Base64Encode(Data) 
{   
    var Result = "";
    var i;
    var c = Data.length;
   
    var Base64Alphabet = [
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
        "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
        "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
        "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "+", "/"   ];

    for (i = 2; i < c; i += 3)
    {
        Result += Base64Alphabet[Data[i - 2] >> 2];
        Result += Base64Alphabet[((Data[i - 2] & 0x03) << 4) | (Data[i - 1] >> 4)];
        Result += Base64Alphabet[((Data[i - 1] & 0x0F) << 2) | (Data[i] >> 6)];
        Result += Base64Alphabet[Data[i] & 0x3F];
    }

    if (i === c)
    {
        Result += Base64Alphabet[Data[i - 2] >> 2];
        Result += Base64Alphabet[((Data[i - 2] & 0x03) << 4) | (Data[i - 1] >> 4)];
        Result += Base64Alphabet[(Data[i - 1] & 0x0F) << 2];
        Result += "=";
    }
    else if (i === c + 1)
    {
        Result += Base64Alphabet[Data[i - 2] >> 2];
        Result += Base64Alphabet[(Data[i - 2] & 0x03) << 4];
        Result += "==";
    }

    return Result;
}



function GenerateSignature (username, password) {   
    
    var Nonce = Base64Encode(window.crypto.getRandomValues(new Uint8Array(32)));
    var s = username + ":" + window.location.host + ":" + Nonce;
    var Utf8 = new TextEncoder("utf-8");
 
    var Algorithm = await window.crypto.subtle.importKey("raw", Utf8.encode(password), { name: "HMAC", "hash": "SHA-256" }, false, ["sign"]);
    var H = await window.crypto.subtle.sign("HMAC", Algorithm, Utf8.encode(s));
 
    var signature = Base64Encode(new Uint8Array(H));
 
    
}