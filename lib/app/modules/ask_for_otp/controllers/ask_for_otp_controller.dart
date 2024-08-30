import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:metroberry/app/models/booking_model.dart';
import 'package:metroberry/app/models/driver_user_model.dart';
import 'package:metroberry/constant/booking_status.dart';
import 'package:metroberry/constant/collection_name.dart';
import 'package:metroberry/constant/constant.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:metroberry/theme/app_them_data.dart';

class AskForOtpController extends GetxController {
  GoogleMapController? mapController;

  @override
  void onInit() {
    addMarkerSetup();
    getArgument();
    super.onInit();
  }

  Rx<DriverUserModel> driverUserModel = DriverUserModel().obs;
  Rx<BookingModel> bookingModel = BookingModel().obs;

  RxBool isLoading = true.obs;

  Future<void> getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      bookingModel.value = argumentData['bookingModel'];

      FirebaseFirestore.instance
          .collection(CollectionName.bookings)
          .doc(bookingModel.value.id)
          .snapshots()
          .listen((event) async {
        if (event.data() != null) {
          BookingModel orderModelStream = BookingModel.fromJson(event.data()!);
          bookingModel.value = orderModelStream;

          FirebaseFirestore.instance
              .collection(CollectionName.drivers)
              .doc(bookingModel.value.driverId)
              .snapshots()
              .listen((event) {
            if (event.data() != null) {
              driverUserModel.value = DriverUserModel.fromJson(event.data()!);
              if (bookingModel.value.bookingStatus ==
                  BookingStatus.bookingOngoing) {
                getPolyline(
                    sourceLatitude: driverUserModel.value.location?.latitude,
                    sourceLongitude: driverUserModel.value.location?.longitude,
                    destinationLatitude:
                        bookingModel.value.dropLocation?.latitude,
                    destinationLongitude:
                        bookingModel.value.dropLocation?.longitude);
              } else {
                getPolyline(
                    sourceLatitude: driverUserModel.value.location?.latitude,
                    sourceLongitude: driverUserModel.value.location?.longitude,
                    destinationLatitude:
                        bookingModel.value.pickUpLocation?.latitude,
                    destinationLongitude:
                        bookingModel.value.pickUpLocation?.longitude);
              }
            }
          });

          if (bookingModel.value.bookingStatus ==
              BookingStatus.bookingCompleted) {
            Get.back();
          }
        }
      });
    }
    isLoading.value = false;
    update();
  }

  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? driverIcon;

  Future<void> getPolyline({
    required double? sourceLatitude,
    required double? sourceLongitude,
    required double? destinationLatitude,
    required double? destinationLongitude,
  }) async {
    if (sourceLatitude != null &&
        sourceLongitude != null &&
        destinationLatitude != null &&
        destinationLongitude != null) {
      List<LatLng> polylineCoordinates = [];
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          request: PolylineRequest(
        mode: TravelMode.driving,
        origin: PointLatLng(sourceLatitude, sourceLongitude),
        destination: PointLatLng(destinationLatitude, destinationLongitude),
      ));
      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      } else {
        log(result.errorMessage.toString());
      }

      addMarker(
        latitude: bookingModel.value.pickUpLocation?.latitude,
        longitude: bookingModel.value.pickUpLocation?.longitude,
        id: "Departure",
        descriptor: departureIcon!,
        rotation: 0.0,
      );
      addMarker(
        latitude: bookingModel.value.dropLocation?.latitude,
        longitude: bookingModel.value.dropLocation?.longitude,
        id: "Destination",
        descriptor: destinationIcon!,
        rotation: 0.0,
      );
      addMarker(
        latitude: driverUserModel.value.location?.latitude,
        longitude: driverUserModel.value.location?.longitude,
        id: "Driver",
        descriptor: driverIcon!,
        rotation: driverUserModel.value.rotation,
      );

      _addPolyLine(polylineCoordinates);
    }
  }

  RxMap<MarkerId, Marker> markers = <MarkerId, Marker>{}.obs;

  void addMarker({
    required double? latitude,
    required double? longitude,
    required String id,
    required BitmapDescriptor descriptor,
    required double? rotation,
  }) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
      markerId: markerId,
      icon: descriptor,
      position: LatLng(latitude ?? 0.0, longitude ?? 0.0),
      rotation: rotation ?? 0.0,
    );
    markers[markerId] = marker;
  }

  Future<void> addMarkerSetup() async {
    final Uint8List departure = await Constant()
        .getBytesFromAsset('assets/icon/ic_pick_up_map.png', 100);
    final Uint8List destination = await Constant()
        .getBytesFromAsset('assets/icon/ic_drop_in_map.png', 100);
    final Uint8List driver =
        await Constant().getBytesFromAsset('assets/icon/ic_car.png', 50);
    departureIcon = BitmapDescriptor.bytes(departure);
    destinationIcon = BitmapDescriptor.bytes(destination);
    driverIcon = BitmapDescriptor.bytes(driver);
  }

  RxMap<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;
  PolylinePoints polylinePoints = PolylinePoints();

  void _addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      consumeTapEvents: true,
      startCap: Cap.roundCap,
      width: 6,
      color: AppThemData.primary500,
    );
    polyLines[id] = polyline;
    updateCameraLocation(
      polylineCoordinates.first,
      polylineCoordinates.last,
      mapController,
    );
  }

  Future<void> updateCameraLocation(
    LatLng source,
    LatLng destination,
    GoogleMapController? mapController,
  ) async {
    if (mapController == null) return;

    LatLngBounds bounds;

    if (source.latitude > destination.latitude &&
        source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(
        southwest: LatLng(source.latitude, destination.longitude),
        northeast: LatLng(destination.latitude, source.longitude),
      );
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(
        southwest: LatLng(destination.latitude, source.longitude),
        northeast: LatLng(source.latitude, destination.longitude),
      );
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 10);

    return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(
      CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      await Future.delayed(const Duration(milliseconds: 500));
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }
}
