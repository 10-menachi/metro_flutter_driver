// ignore_for_file: unnecessary_overrides

import 'package:get/get.dart';
import 'package:metroberry/app/models/booking_model.dart';
import 'package:metroberry/constant/booking_status.dart';
import 'package:metroberry/constant/constant.dart';
import 'package:metroberry/utils/fire_store_utils.dart';

class ReasonForCancelController extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  RxInt selectedIndex = 0.obs;

  List<dynamic> reasons = Constant.cancellationReason;

  Future<bool> cancelBooking(BookingModel bookingModels) async {
    BookingModel bookingModel = bookingModels;
    bookingModel.bookingStatus = BookingStatus.bookingCancelled;
    bookingModel.cancelledBy = FireStoreUtils.getCurrentUid();
    bool? isCancelled = await FireStoreUtils.setBooking(bookingModel);
    return (isCancelled ?? false);
  }
}
