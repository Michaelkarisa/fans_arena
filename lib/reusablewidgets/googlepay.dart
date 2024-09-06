import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import 'package:flutter/services.dart'; // for rootBundle
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../appid.dart';

class GooglePayPage extends StatelessWidget {
  final _paymentItems = <PaymentItem>[
    PaymentItem(
      label: 'Total',
      amount: '12.34',
      status: PaymentItemStatus.final_price,
    )
  ];

  Future<PaymentConfiguration> _loadPaymentConfiguration() async {
    final String configString = await rootBundle.loadString('payment_profile.json');
    return PaymentConfiguration.fromJsonString(configString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Google Pay')),
      body: Center(
        child: FutureBuilder<PaymentConfiguration>(
          future: _loadPaymentConfiguration(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error loading payment configuration');
            } else {
              return GooglePayButton(
                paymentConfiguration: snapshot.data!,
                paymentItems: _paymentItems,
                type: GooglePayButtonType.pay,
                onPaymentResult: (data) {
                  // Handle payment result
                  print(data);
                },
                loadingIndicator: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class MpesaService {
  final String shortCode = "174379";
  final String lipaNaMpesaOnlineUrl = 'https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest';
  final String tokenUrl = 'https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials';

  Future<String> getAccessToken() async {
    String credentials = base64Encode(utf8.encode('$mConsumerKey:$mConsumerSecret'));
    var response = await http.get(
      Uri.parse(tokenUrl),
      headers: {'Authorization': 'Basic $credentials'},
    );
    return json.decode(response.body)['access_token'];
  }

  String mPasskey = 'bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919';

  Future<void> lipaNaMpesa(String phoneNumber, double amount) async {
    String token = await getAccessToken();
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String password = base64Encode(utf8.encode('$shortCode${lipaNaMpesaOnlineUrl}${timestamp}'));
    String baseUrl = "https://us-central1-fans-arena.cloudfunctions.net";
    var response = await http.post(
      Uri.parse(lipaNaMpesaOnlineUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: json.encode({
        'BusinessShortCode': shortCode,
        'Password': password,
        'Timestamp': timestamp,
        'TransactionType': 'CustomerPayBillOnline',
        'Amount': amount,
        'PartyA': phoneNumber,
        'PartyB': shortCode,
        'PhoneNumber': phoneNumber,
        'CallBackURL': Uri.parse('$baseUrl/handleTransaction'),
        'AccountReference': 'account_reference',
        'TransactionDesc': 'Payment description'
      }),
    );

    print(response.body);
  }
}

class MpesaPayPage extends StatelessWidget {
  final MpesaService _mpesaService = MpesaService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('M-Pesa Express')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await _mpesaService.lipaNaMpesa('254712345678', 100.0);
          },
          child: Text('Pay with M-Pesa'),
        ),
      ),
    );
  }
}

class PaymentOptionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment Options')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GooglePayPage()),
                );
              },
              child: Text('Pay with Google Pay'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MpesaPayPage()),
                );
              },
              child: Text('Pay with M-Pesa'),
            ),
          ],
        ),
      ),
    );
  }
}
