import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal_native/flutter_paypal_native.dart';
import 'package:flutter_paypal_native/models/custom/currency_code.dart';
import 'package:flutter_paypal_native/models/custom/environment.dart';
import 'package:flutter_paypal_native/models/custom/order_callback.dart';
import 'package:flutter_paypal_native/models/custom/user_action.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:metroberry/app/models/bank_detail_model.dart';
import 'package:metroberry/app/models/driver_user_model.dart';
import 'package:metroberry/app/models/payment_method_model.dart';
import 'package:metroberry/app/models/payment_model/stripe_failed_model.dart';
import 'package:metroberry/app/models/wallet_transaction_model.dart';
import 'package:metroberry/app/modules/home/controllers/home_controller.dart';
import 'package:metroberry/constant/constant.dart';
import 'package:metroberry/constant_widgets/show_toast_dialog.dart';
import 'package:metroberry/theme/app_them_data.dart';
import 'package:metroberry/utils/fire_store_utils.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart' as razor_pay_flutter;

class MyWalletController extends GetxController {
  TextEditingController amountController = TextEditingController(text: "100");
  Rx<PaymentModel> paymentModel = PaymentModel().obs;
  RxString selectedPaymentMethod = "".obs;
  final razor_pay_flutter.Razorpay _razorpay = razor_pay_flutter.Razorpay();
  Rx<DriverUserModel> userModel = DriverUserModel().obs;
  Rx<BankDetailsModel> selectedBankMethod = BankDetailsModel().obs;
  RxList<WalletTransactionModel> walletTransactionList =
      <WalletTransactionModel>[].obs;
  RxList<BankDetailsModel> bankDetailsList = <BankDetailsModel>[].obs;
  RxInt selectedTabIndex = 0.obs;
  final TextEditingController withdrawalAmountController =
      TextEditingController();
  final TextEditingController withdrawalNoteController =
      TextEditingController();
  Rx<GlobalKey<FormState>> formKey = GlobalKey<FormState>().obs;

  @override
  void onInit() {
    getPayments();
    super.onInit();
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  getPayments() async {
    ShowToastDialog.showLoader("Please wait");
    await FireStoreUtils().getPayment().then((value) {
      if (value != null) {
        paymentModel.value = value;
        if (paymentModel.value.strip!.isActive == true) {
          Stripe.publishableKey =
              paymentModel.value.strip!.clientPublishableKey.toString();
          Stripe.merchantIdentifier = 'MyTaxi';
          Stripe.instance.applySettings();
        }
        if (paymentModel.value.paypal!.isActive == true) {
          initPayPal();
        }
      }
    });
    await getWalletTransactions();
    await getProfileData();
    await getBankDetails();
    ShowToastDialog.closeLoader();
  }

  getBankDetails() async {
    bankDetailsList.clear();
    await FireStoreUtils.getBankDetailList(FireStoreUtils.getCurrentUid())
        .then((value) {
      if (value != null) {
        bankDetailsList.addAll(value);
        if (bankDetailsList.isNotEmpty) {
          selectedBankMethod.value = bankDetailsList[0];
        }
      }
    });
  }

  getWalletTransactions() async {
    await FireStoreUtils.getWalletTransaction().then((value) {
      walletTransactionList.value = value ?? [];
      log("==>  $walletTransactionList");
    });
  }

  getProfileData() async {
    await FireStoreUtils.getDriverUserProfile(FireStoreUtils.getCurrentUid())
        .then((value) {
      if (value != null) {
        userModel.value = value;
      }
    });
  }

  completeOrder(String transactionId) async {
    WalletTransactionModel transactionModel = WalletTransactionModel(
        id: Constant.getUuid(),
        amount: amountController.value.text,
        createdDate: Timestamp.now(),
        paymentType: selectedPaymentMethod.value,
        transactionId: transactionId,
        userId: FireStoreUtils.getCurrentUid(),
        isCredit: true,
        type: "driver",
        note: "Wallet Top up");
    ShowToastDialog.showLoader("Please wait");
    await FireStoreUtils.setWalletTransaction(transactionModel)
        .then((value) async {
      if (value == true) {
        await FireStoreUtils.updateDriverUserWallet(
                amount: amountController.value.text)
            .then((value) async {
          await getProfileData();
          await getWalletTransactions();
        });
      }
    });
    ShowToastDialog.closeLoader();
    ShowToastDialog.showToast("Amount added in your wallet.");

    HomeController homeController = Get.put(HomeController());
    homeController.getUserData();
    homeController.isLoading.value = false;
  }

  // ::::::::::::::::::::::::::::::::::::::::::::Stripe::::::::::::::::::::::::::::::::::::::::::::::::::::
  Future<void> stripeMakePayment({required String amount}) async {
    try {
      Map<String, dynamic>? paymentIntentData =
          await createStripeIntent(amount: amount);
      if (paymentIntentData!.containsKey("error")) {
        Get.back();
        ShowToastDialog.showToast(
            "Something went wrong, please contact admin.");
      } else {
        await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
                paymentIntentClientSecret: paymentIntentData['client_secret'],
                allowsDelayedPaymentMethods: false,
                googlePay: const PaymentSheetGooglePay(
                  merchantCountryCode: 'US',
                  testEnv: true,
                  currencyCode: "USD",
                ),
                style: ThemeMode.system,
                appearance: PaymentSheetAppearance(
                  colors: PaymentSheetAppearanceColors(
                    primary: AppThemData.primary500,
                  ),
                ),
                merchantDisplayName: 'MyTaxi'));
        displayStripePaymentSheet(amount: amount);
      }
    } catch (e, s) {
      log("$e \n$s");
      ShowToastDialog.showToast("exception:$e \n$s");
    }
  }

  displayStripePaymentSheet({required String amount}) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        ShowToastDialog.showToast("Payment successfully");
        completeOrder(DateTime.now().millisecondsSinceEpoch.toString());
      });
    } on StripeException catch (e) {
      var lo1 = jsonEncode(e);
      var lo2 = jsonDecode(lo1);
      StripePayFailedModel lom = StripePayFailedModel.fromJson(lo2);
      ShowToastDialog.showToast(lom.error.message);
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
      log('Existing in displayStripePaymentSheet: $e');
    }
  }

  createStripeIntent({required String amount}) async {
    try {
      Map<String, dynamic> body = {
        'amount': ((double.parse(amount) * 100).round()).toString(),
        'currency': "USD",
        'payment_method_types[]': 'card',
        "description": "Strip Payment",
        "shipping[name]": userModel.value.fullName,
        "shipping[address][line1]": "510 Townsend St",
        "shipping[address][postal_code]": "98140",
        "shipping[address][city]": "San Francisco",
        "shipping[address][state]": "CA",
        "shipping[address][country]": "US",
      };
      var stripeSecret = paymentModel.value.strip!.stripeSecret;
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization': 'Bearer $stripeSecret',
            'Content-Type': 'application/x-www-form-urlencoded'
          });

      return jsonDecode(response.body);
    } catch (e) {
      log(e.toString());
    }
  }

  // ::::::::::::::::::::::::::::::::::::::::::::PayPal::::::::::::::::::::::::::::::::::::::::::::::::::::
  final _flutterPaypalNativePlugin = FlutterPaypalNative.instance;

  void initPayPal() async {
    FlutterPaypalNative.isDebugMode =
        paymentModel.value.paypal!.isSandbox == true ? true : false;

    await _flutterPaypalNativePlugin.init(
      returnUrl: "com.mytaxi.customer://paypalpay",
      clientID: paymentModel.value.paypal!.paypalClient.toString(),
      payPalEnvironment: paymentModel.value.paypal!.isSandbox == true
          ? FPayPalEnvironment.sandbox
          : FPayPalEnvironment.live,
      currencyCode: FPayPalCurrencyCode.usd,
      action: FPayPalUserAction.payNow,
    );

    _flutterPaypalNativePlugin.setPayPalOrderCallback(
      callback: FPayPalOrderCallback(
        onCancel: () {
          ShowToastDialog.showToast("Payment canceled");
        },
        onSuccess: (data) {
          _flutterPaypalNativePlugin.removeAllPurchaseItems();
          ShowToastDialog.showToast("Payment Successfully");
          completeOrder(
              data.orderId ?? DateTime.now().millisecondsSinceEpoch.toString());
        },
        onError: (data) {
          ShowToastDialog.showToast("error: ${data.reason}");
        },
        onShippingChange: (data) {
          ShowToastDialog.showToast(
              "shipping change: ${data.shippingChangeAddress?.adminArea1 ?? ""}");
        },
      ),
    );
  }

  // ::::::::::::::::::::::::::::::::::::::::::::RazorPay::::::::::::::::::::::::::::::::::::::::::::::::::::
  void razorPayInit() {
    _razorpay.on(razor_pay_flutter.Razorpay.EVENT_PAYMENT_SUCCESS,
        _handlePaymentSuccess);
    _razorpay.on(
        razor_pay_flutter.Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(
        razor_pay_flutter.Razorpay.EVENT_EXTERNAL_WALLET, _handlePaymentCancel);
  }

  void _handlePaymentSuccess(
      razor_pay_flutter.PaymentSuccessResponse response) {
    ShowToastDialog.showToast("Payment Successfully");
    completeOrder(
        response.paymentId ?? DateTime.now().millisecondsSinceEpoch.toString());
  }

  void _handlePaymentError(razor_pay_flutter.PaymentFailureResponse response) {
    ShowToastDialog.showToast("Payment Failed");
  }

  void _handlePaymentCancel() {
    ShowToastDialog.showToast("Payment Cancelled");
  }

  // ::::::::::::::::::::::::::::::::::::::::::::Bank::::::::::::::::::::::::::::::::::::::::::::::::::::
  void payWithBank() async {
    ShowToastDialog.showLoader("Processing");
    completeOrder(DateTime.now().millisecondsSinceEpoch.toString());
  }
}
