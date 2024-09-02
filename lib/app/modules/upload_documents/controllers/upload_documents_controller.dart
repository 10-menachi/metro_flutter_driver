import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metroberry/app/models/documents_model.dart';
import 'package:metroberry/app/models/driver_user_model.dart';
import 'package:metroberry/app/models/verify_driver_model.dart';
import 'package:metroberry/app/modules/verify_documents/controllers/verify_documents_controller.dart';
import 'package:metroberry/constant/constant.dart';
import 'package:metroberry/constant_widgets/network_image_widget.dart';
import 'package:metroberry/constant_widgets/show_toast_dialog.dart';
import 'package:metroberry/theme/responsive.dart';
import 'package:metroberry/utils/fire_store_utils.dart';

class UploadDocumentsController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  PageController controller = PageController();
  RxInt pageIndex = 0.obs;

  final ImagePicker imagePicker = ImagePicker();

  Rx<VerifyDocument> verifyDocument =
      VerifyDocument(documentImage: ['', '']).obs;
  RxList<Widget> imageWidgetList = <Widget>[].obs;
  RxList<int> imageList = <int>[].obs;

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

  void setData(bool isUploaded, String id, BuildContext context) {
    imageWidgetList.clear();
    VerifyDocumentsController uploadDocumentsController =
        Get.find<VerifyDocumentsController>();

    if (isUploaded) {
      int index = uploadDocumentsController
              .verifyDriverModel.value.verifyDocument
              ?.indexWhere((element) => element.documentId == id) ??
          -1;

      if (index != -1) {
        var document = uploadDocumentsController
            .verifyDriverModel.value.verifyDocument![index];

        if (document.documentImage.isNotEmpty) {
          for (var element in document.documentImage) {
            imageList.add(document.documentImage.indexOf(element));
            imageWidgetList.add(
              Center(
                child: NetworkImageWidget(
                  imageUrl: element.toString(),
                  height: 220,
                  width: Responsive.width(100, context),
                  borderRadius: 12,
                  fit: BoxFit.cover,
                ),
              ),
            );
          }
        } else {
          ShowToastDialog.showToast("No images available for this document.");
        }

        nameController.text = document.name ?? '';
        numberController.text = document.number ?? '';
        dobController.text = document.dob ?? '';
      } else {
        ShowToastDialog.showToast("Document not found.");
      }
    } else {
      ShowToastDialog.showToast("Document not uploaded yet.");
    }
  }

  Future<void> pickFile(
      {required ImageSource source, required int index}) async {
    try {
      XFile? image =
          await imagePicker.pickImage(source: source, imageQuality: 60);
      if (image == null) return;

      Get.back();

      Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
        image.path,
        quality: 50,
      );

      if (compressedBytes == null) {
        ShowToastDialog.showToast("Failed to compress image");
        return;
      }

      File compressedFile = File(image.path);
      await compressedFile.writeAsBytes(compressedBytes);

      List<dynamic> files = verifyDocument.value.documentImage;
      files.removeAt(index);
      files.insert(index, compressedFile.path);
      verifyDocument.value = VerifyDocument(documentImage: files);
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("Failed to pick image: ${e.message}");
    } catch (e) {
      ShowToastDialog.showToast("Unexpected error occurred: ${e.toString()}");
    }
  }

  Future<void> uploadDocument(DocumentsModel document) async {
    ShowToastDialog.showLoader("Please wait");
    try {
      // Access the underlying VerifyDocument object
      VerifyDocument verifyDoc = verifyDocument.value;
      if (verifyDoc.documentImage.isNotEmpty) {
        for (int i = 0; i < verifyDoc.documentImage.length; i++) {
          if (verifyDoc.documentImage[i].isNotEmpty) {
            if (Constant.hasValidUrl(verifyDoc.documentImage[i].toString())) {
              print('HEREEEEEEE');
              String image =
                  await Constant.uploadDriverDocumentImageToFireStorage(
                File(verifyDoc.documentImage[i].toString()),
                "documents/${document.id}/${FireStoreUtils.getCurrentUid()}",
                verifyDoc.documentImage[i].split('/').last,
              );
              verifyDoc.documentImage[i] = image;
            }
          }
        }
      }

      verifyDoc.documentId = document.id;
      verifyDoc.name = nameController.text;
      verifyDoc.number = numberController.text;
      verifyDoc.dob = dobController.text;
      verifyDoc.isVerify = false;

      VerifyDocumentsController verifyDocumentsController =
          Get.find<VerifyDocumentsController>();
      DriverUserModel? userModel = await FireStoreUtils.getDriverUserProfile(
          FireStoreUtils.getCurrentUid());

      if (userModel == null) {
        ShowToastDialog.showToast("Failed to get user profile");
        ShowToastDialog.closeLoader();
        return;
      }

      List<VerifyDocument> verifyDocumentList =
          verifyDocumentsController.verifyDriverModel.value.verifyDocument ??
              [];
      verifyDocumentList.add(verifyDoc);

      VerifyDriverModel verifyDriverModel = VerifyDriverModel(
        createAt: Timestamp.now(),
        driverEmail: userModel.email ?? '',
        driverId: userModel.id ?? '',
        driverName: userModel.fullName ?? '',
        verifyDocument: verifyDocumentList,
      );

      bool isUpdated = await FireStoreUtils.addDocument(verifyDriverModel);

      if (isUpdated) {
        ShowToastDialog.showToast(
            "${document.title} updated, Please wait for verification.");
        verifyDocumentsController.getData();
        Get.back();
      } else {
        ShowToastDialog.showToast(
            "Something went wrong, Please try again later.");
      }
    } catch (e) {
      ShowToastDialog.showToast("Error uploading document: ${e.toString()}");
    } finally {
      ShowToastDialog.closeLoader();
    }
  }
}
