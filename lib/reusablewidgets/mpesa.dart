import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

enum TransactionType {
  CustomerPayBillOnline,
  CustomerBuyGoodsOnline,
}

enum TransactionMode { IsLive, IsTesting }


class RequestHandler {
  final String consumerKey;
  final String consumerSecret;
  final String b64keySecret;
  final String baseUrl;

  late String mAccessToken;
  DateTime? mAccessExpiresAt;

  RequestHandler({required this.consumerKey, required this.consumerSecret, required this.baseUrl})
      : b64keySecret = base64Url.encode((consumerKey + ":" + consumerSecret).codeUnits);

  Uri getAuthUrl() {
    return Uri(
      scheme: 'https',
      host: baseUrl,
      path: '/oauth/v1/generate',
      queryParameters: <String, String>{'grant_type': 'client_credentials'},
    );
  }

  String generatePassword({
    required String mPassKey,
    required String mShortCode,
    required String actualTimeStamp,
  }) {
    String readyPass = mShortCode + mPassKey + actualTimeStamp;
    var bytes = utf8.encode(readyPass);
    return base64.encode(bytes);
  }

  Future<void> setAccessToken() async {
    DateTime now = DateTime.now();
    if (mAccessExpiresAt != null) {
      if (now.isBefore(mAccessExpiresAt!)) {
        return;
      }
    }

    HttpClient client = HttpClient();
    HttpClientRequest req = await client.getUrl(getAuthUrl());
    req.headers.add("Accept", "application/json");
    req.headers.add("Authorization", "Basic " + b64keySecret);
    HttpClientResponse res = await req.close();

    await res.transform(utf8.decoder).forEach((bodyString) {
      dynamic jsondecodeBody = jsonDecode(bodyString);
      mAccessToken = jsondecodeBody["access_token"].toString();
      mAccessExpiresAt = now.add(Duration(seconds: int.parse(jsondecodeBody["expires_in"].toString())));
    });
  }

  Uri generateSTKPushUrl() {
    return Uri(
      scheme: 'https',
      host: baseUrl,
      path: 'mpesa/stkpush/v1/processrequest',
    );
  }

  Future<Map<String, String>> mSTKRequest({
    required String mBusinessShortCode,
    required String nPassKey,
    required String mTransactionType,
    required String mTimeStamp,
    required double mAmount,
    required String partyA,
    required String partyB,
    required String mPhoneNumber,
    required Uri mCallBackURL,
    required String mAccountReference,
    String? mTransactionDesc,
  }) async {
    await setAccessToken();

    final stkPushPayload = {
      "BusinessShortCode": mBusinessShortCode,
      "Password": generatePassword(
        mShortCode: mBusinessShortCode,
        mPassKey: nPassKey,
        actualTimeStamp: mTimeStamp,
      ),
      "Timestamp": mTimeStamp,
      "Amount": mAmount,
      "PartyA": partyA,
      "PartyB": partyB,
      "PhoneNumber": mPhoneNumber,
      "CallBackURL": mCallBackURL.toString(),
      "AccountReference": mAccountReference,
      "TransactionDesc": mTransactionDesc ?? "",
      "TransactionType": mTransactionType,
    };
    final Map<String, String> result = {};

    HttpClient client = HttpClient();
    return await client.postUrl(generateSTKPushUrl()).then((req) async {
      req.headers.add("Content-Type", "application/json");
      req.headers.add("Authorization", "Bearer " + mAccessToken);
      req.write(jsonEncode(stkPushPayload));
      HttpClientResponse res = await req.close();

      await res.transform(utf8.decoder).forEach((bodyString) {
        dynamic mJsonDecodeBody = jsonDecode(bodyString);

        if (res.statusCode == 200) {
          result["MerchantRequestID"] = mJsonDecodeBody["MerchantRequestID"].toString();
          result["CheckoutRequestID"] = mJsonDecodeBody["CheckoutRequestID"].toString();
          result["ResponseCode"] = mJsonDecodeBody["ResponseCode"].toString();
          result["ResponseDescription"] = mJsonDecodeBody["ResponseDescription"].toString();
          result["CustomerMessage"] = mJsonDecodeBody["CustomerMessage"].toString();
        } else {
          result["requestId"] = mJsonDecodeBody["requestId"].toString();
          result["errorCode"] = mJsonDecodeBody["errorCode"].toString();
          result["errorMessage"] = mJsonDecodeBody["errorMessage"].toString();
        }
      });
      return result;
    }).catchError((error) {
      result["error"] = error.toString();
      return result;
    });
  }
}


class Mpesa {
  static bool _consumerKeySet = false;
  static late String _mConsumerKeyVariable;

  static void setConsumerKey(String consumerKey) {
    _mConsumerKeyVariable = consumerKey;
    _consumerKeySet = true;
  }

  static bool _consumerSecretSet = false;
  static late String _mConsumerSecretVariable;

  static void setConsumerSecret(String consumerSecret) {
    _mConsumerSecretVariable = consumerSecret;
    _consumerSecretSet = true;
  }

  static Future<dynamic> initializeMpesaSTKPush({
    required String businessShortCode,
    required TransactionType transactionType,
    required double amount,
    required String partyA,
    required String partyB,
    required Uri callBackURL,
    required String accountReference,
    String? transactionDesc,
    required String phoneNumber,
    required Uri baseUri,
    required String passKey,
  }) async {
    // Validate the amount
    if (amount < 1.0) {
      throw "error: you provided $amount as the amount which is not valid.";
    }
    // Validate the phone number
    if (phoneNumber.length < 9) {
      throw "error: $phoneNumber doesn't seem to be a valid phone number";
    }
    if (!phoneNumber.startsWith('254')) {
      throw "error: $phoneNumber needs to be in international format";
    }

    // Ensure consumer key and secret are set
    if (!_consumerSecretSet || !_consumerKeySet) {
      throw "error: ensure consumer key & secret is set. Use Mpesa.setConsumer...";
    }

    // Generate timestamp
    var rawTimeStamp = DateTime.now();
    var formatter = DateFormat('yyyyMMddHHmmss');
    String actualTimeStamp = formatter.format(rawTimeStamp);

    // Initialize the RequestHandler
    RequestHandler requestHandler = RequestHandler(
      consumerKey: _mConsumerKeyVariable,
      consumerSecret: _mConsumerSecretVariable,
      baseUrl: baseUri.host,
    );

    // Make the STK push request
    return await requestHandler.mSTKRequest(
      mBusinessShortCode: businessShortCode,
      nPassKey: passKey,
      mTransactionType: transactionType == TransactionType.CustomerPayBillOnline
          ? "CustomerPayBillOnline"
          : "CustomerBuyGoodsOnline",
      mTimeStamp: actualTimeStamp,
      mAmount: amount,
      partyA: partyA,
      partyB: partyB,
      mPhoneNumber: phoneNumber,
      mCallBackURL: callBackURL,
      mAccountReference: accountReference,
      mTransactionDesc: transactionDesc,
    );
  }
}

