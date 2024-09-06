import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> makeMpesaRequest() async {
  final url = Uri.parse("https://sandbox.safaricom.co.ke/mpesa/c2b/v1/simulate");

  final headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer VkUQkfME77URcIGDD2CnIfx1VuDN",
  };

  final Map<String, dynamic> requestData = {
    "ShortCode": 600990,
    "CommandID": "CustomerBuyGoodsOnline",
    "Amount": "1",
    "Msisdn": "254705912645",
    "BillRefNumber": "",
  };

  final response = await http.post(
    url,
    headers: headers,
    body: jsonEncode(requestData),
  );

  if (response.statusCode == 200) {
    // Request was successful
    print("Response: ${response.body}");
  } else {
    // Request failed
    print("Request failed with status code: ${response.statusCode}");
  }
}

Future<void> makeMpesaB2BRequest(String Pno , int amount) async {
  final url = Uri.parse("https://sandbox.safaricom.co.ke/mpesa/b2b/v1/paymentrequest");

  final headers = {
    "Authorization": "Basic QUtWN0s3aW5xcHRhc0c1MEpybXREbDUxRG1BNXlwOU46cVVNYmdjZG02Sk85R3NnQw==",
    "Content-Type": "application/json",
  };

  final Map<String, dynamic> requestData = {
    "Initiator": "testapi",
    "SecurityCredential": "ZyQppoUCTKMM35g6ZuU6q9J4DV0UGwO7Ipy0O9sULCQ3xrZW/lPUI7U8KMYjwaG4GleZ6RSQQo5dC/NZm3L2TpGo9rOIfg4L+g/YSblg0KYFIB7AVN4wj9954BVOVsTm+fjZW7sZbsdS1CaJ6h2anqefkQuPvu462WbeB0i1UTTULiVLelQJiigrm8+NMa6lxDyxx/LiRErOe1QBU53L6Y/SyUk/YfQbHdbzJ74DhGz13Y/PzYjypWRMxotod2PzIP2taZ9Erd9oTidNBPvqt+gmIijy84huWrvIinW1zgF0yXokmgZ5rM8U70v5W92pl4pkadto0wL8soIPpTog6g==",
    "CommandID": "BusinessBuyGoods",
    "SenderIdentifierType": "4",
    "RecieverIdentifierType": "4",
    "Amount": amount,
    "PartyA": "600978",
    "PartyB": "000000",
    "AccountReference": "353353",
    "Requester": Pno,
    "Remarks": "ok",
    "QueueTimeOutURL": "https://mydomain.com/b2b/queue/",
    "ResultURL": "https://mydomain.com/b2b/result/",
  };

  final response = await http.post(
    url,
    headers: headers,
    body: jsonEncode(requestData),
  );

  if (response.statusCode == 200) {
    // Request was successful
    print("Response: ${response.body}");
  } else {
    // Request failed
    print("Request failed with status code: ${response.statusCode}");
  }
}





void Response() {
  const jsonString = '''
  {
    "Result": {
      "ResultType": "0",
      "ResultCode": "0",
      "ResultDesc": "The service request is processed successfully",
      "OriginatorConversationID": "626f6ddf-ab37-4650-b882-b1de92ec9aa4",
      "ConversationID": "12345677dfdf89099B3",
      "TransactionID": "QKA81LK5CY",
      "ResultParameters": {
        "ResultParameter": [
          {
            "Key": "DebitAccountBalance",
            "Value": "{Amount={CurrencyCode=KES, MinimumAmount=618683, BasicAmount=6186.83}}"
          },
          {
            "Key": "Amount",
            "Value": "190.00"
          },
          {
            "Key": "DebitPartyAffectedAccountBalance",
            "Value": "Working Account|KES|346568.83|6186.83|340382.00|0.00"
          },
          {
            "Key": "TransCompletedTime",
            "Value": "20221110110717"
          },
          {
            "Key": "DebitPartyCharges",
            "Value": ""
          },
          {
            "Key": "ReceiverPartyPublicName",
            "Value": "000000– Biller Company"
          },
          {
            "Key": "Currency",
            "Value": "KES"
          },
          {
            "Key": "InitiatorAccountCurrentBalance",
            "Value": "{Amount={CurrencyCode=KES, MinimumAmount=618683, BasicAmount=6186.83}}"
          }
        ]
      },
      "ReferenceData": {
        "ReferenceItem": [
          {"Key": "BillReferenceNumber", "Value": "19008"},
          {"Key": "QueueTimeoutURL", "Value": "https://mydomain.com/b2b/businessbuygoods/queue/"}
        ]
      }
    }
  }
  ''';

  final jsonResponse = jsonDecode(jsonString);

  final result = jsonResponse['Result'];

  if (result != null) {
    final resultCode = result['ResultCode'];
    final resultDesc = result['ResultDesc'];
    final transactionID = result['TransactionID'];
    final amount = result['ResultParameters']['ResultParameter']
        .firstWhere((param) => param['Key'] == 'Amount', orElse: () => {'Value': ''})['Value'];

    print("Result Code: $resultCode");
    print("Result Description: $resultDesc");
    print("Transaction ID: $transactionID");
    print("Amount: $amount");
  }
}
