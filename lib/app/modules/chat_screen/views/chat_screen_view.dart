import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metroberry/app/models/chat_model/chat_model.dart';
import 'package:metroberry/constant/collection_name.dart';
import 'package:metroberry/constant/constant.dart';
import 'package:metroberry/theme/app_them_data.dart';
import 'package:metroberry/utils/dark_theme_provider.dart';
import 'package:metroberry/utils/fire_store_utils.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../controllers/chat_screen_controller.dart';

class ChatScreenView extends StatefulWidget {
  final String receiverId;

  const ChatScreenView({
    super.key,
    required this.receiverId,
  });

  @override
  _ChatScreenViewState createState() => _ChatScreenViewState();
}

class _ChatScreenViewState extends State<ChatScreenView> {
  final ScrollController _scrollController = ScrollController();
  final int _limit = 10;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;
  final List<ChatModel> _chatMessages = [];

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchMessages();
      }
    });
  }

  Future<void> _fetchMessages() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Query query = FireStoreUtils.fireStore
          .collection(CollectionName.chat)
          .doc(widget.receiverId) // Assuming sender's ID is used here
          .collection(widget.receiverId)
          .orderBy("timestamp", descending: true)
          .limit(_limit);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final QuerySnapshot querySnapshot = await query.get();
      final List<ChatModel> messages = querySnapshot.docs
          .map((doc) => ChatModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      if (messages.isEmpty) {
        setState(() {
          _hasMore = false;
        });
      } else {
        setState(() {
          _lastDocument = querySnapshot.docs.last;
          _chatMessages.addAll(messages);
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final ChatScreenController controller = Get.find();

    return Obx(() => Scaffold(
          backgroundColor:
              themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
          appBar: AppBar(
            forceMaterialTransparency: true,
            surfaceTintColor: Colors.transparent,
            backgroundColor: themeChange.isDarkTheme()
                ? AppThemData.black
                : AppThemData.white,
            titleSpacing: 0,
            automaticallyImplyLeading: true,
            shape: Border(
                bottom: BorderSide(
                    color: themeChange.isDarkTheme()
                        ? AppThemData.grey800
                        : AppThemData.grey100,
                    width: 1)),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                controller.isLoading.value
                    ? Constant.loader()
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                            height: 36,
                            width: 36,
                            fit: BoxFit.cover,
                            imageUrl: controller.receiverUserModel.value
                                            .profilePic ==
                                        null ||
                                    controller.receiverUserModel.value
                                            .profilePic ==
                                        ""
                                ? Constant.profileConstant
                                : controller.receiverUserModel.value.profilePic
                                    .toString()),
                      ),
                const SizedBox(
                  width: 12,
                ),
                Text(controller.receiverUserModel.value.fullName ?? '',
                    style: GoogleFonts.inter(
                      color: themeChange.isDarkTheme()
                          ? AppThemData.white
                          : AppThemData.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 0.08,
                    )),
              ],
            ),
            actions: [
              InkWell(
                  onTap: () {
                    Constant().launchCall(
                        "${controller.receiverUserModel.value.countryCode}${controller.receiverUserModel.value.phoneNumber}");
                  },
                  child: SvgPicture.asset("assets/icon/ic_phone.svg")),
              const SizedBox(width: 12),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _chatMessages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _chatMessages.length) {
                      return _hasMore
                          ? Center(child: CircularProgressIndicator())
                          : Center(child: Text('No more messages'));
                    }

                    final chatModel = _chatMessages[index];
                    return chatBubbles(
                        chatModel.senderId ==
                            controller.senderUserModel.value.id,
                        chatModel,
                        themeChange);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  controller: controller.messageTextEditorController.value,
                  textAlign: TextAlign.start,
                  maxLines: null,
                  minLines: 1,
                  textInputAction: TextInputAction.done,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: themeChange.isDarkTheme()
                        ? AppThemData.grey400
                        : AppThemData.grey500,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                      errorStyle: const TextStyle(color: Colors.red),
                      isDense: true,
                      fillColor: themeChange.isDarkTheme()
                          ? AppThemData.grey900
                          : AppThemData.grey50,
                      filled: true,
                      enabled: true,
                      suffixIcon: InkWell(
                        onTap: () {
                          if (controller.messageTextEditorController.value.text
                              .isNotEmpty) {
                            controller.sendMessage();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
                          child: SvgPicture.asset(
                            "assets/icon/ic_send.svg",
                            height: 15,
                            width: 15,
                          ),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      disabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          borderSide: BorderSide(color: Colors.transparent)),
                      focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          borderSide: BorderSide(color: Colors.transparent)),
                      enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          borderSide: BorderSide(color: Colors.transparent)),
                      errorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          borderSide: BorderSide(color: Colors.transparent)),
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          borderSide: BorderSide(color: Colors.transparent)),
                      hintText: "Type your message here...".tr,
                      hintStyle: GoogleFonts.inter(
                        fontSize: 16,
                        color: themeChange.isDarkTheme()
                            ? AppThemData.grey400
                            : AppThemData.grey500,
                      )),
                ),
              ),
            ],
          ),
        ));
  }

  Widget chatBubbles(
      bool isMe, ChatModel chatModel, DarkThemeProvider themeChange) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: isMe
                    ? AppThemData.primary500
                    : themeChange.isDarkTheme()
                        ? AppThemData.grey900
                        : AppThemData.grey50,
                borderRadius: isMe
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      )
                    : const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      )),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  '${chatModel.message}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: themeChange.isDarkTheme()
                        ? AppThemData.white
                        : AppThemData.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  Constant.timestampToTime(chatModel.timestamp!),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: themeChange.isDarkTheme()
                        ? AppThemData.white
                        : AppThemData.black,
                  ),
                ),
              ],
            ),
          ).paddingOnly(left: isMe ? 70 : 0, right: isMe ? 0 : 70),
        ),
      ],
    );
  }
}
