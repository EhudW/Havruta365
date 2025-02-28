import 'dart:async';
import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havruta_project/data_base/data_representations/user.dart';
import 'package:havruta_project/globals.dart';
import 'package:havruta_project/data_base/data_representations/chat_message.dart';
import 'package:havruta_project/chat/chat_stream_model.dart';
import 'package:havruta_project/users/screens/user_screen/user_details_page.dart';
import 'package:havruta_project/mydebug.dart';
import 'package:havruta_project/mytimer.dart';
import 'package:havruta_project/notifications/push_notifications/fcm.dart';
import 'package:havruta_project/widgets/my_future_builder.dart';
import 'package:loading_animations/loading_animations.dart';

import '../../event/buttons/next_button.dart';

class ChatL10nHe extends ChatL10n {
  ChatL10nHe()
      : super(
            attachmentButtonAccessibilityLabel: "שלח מדיה",
            emptyChatPlaceholder: "אין כאן הודעות",
            fileButtonAccessibilityLabel: "קובץ",
            inputPlaceholder: "הודעה...",
            sendButtonAccessibilityLabel: "שלח",
            unreadMessagesLabel: "הודעות שלא נקראו");
}

class IconSwitch extends StatefulWidget {
  final bool on;
  final Map<bool, IconData> icons;
  final Map<bool, String> tooltip;
  final Function(bool, Function) action;
  const IconSwitch(this.on, this.action,
      {Map<bool, IconData>? icons, Map<bool, String>? tooltip, Key? key})
      : icons = icons ??
            const {true: FontAwesomeIcons.plus, false: FontAwesomeIcons.minus},
        tooltip = tooltip ?? const {true: "פועל", false: "כבוי"},
        super(key: key);

  @override
  State<IconSwitch> createState() => IconSwitchState();
}

class IconSwitchState extends State<IconSwitch> {
  bool on = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    on = widget.on;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 20),
        // SizedBox(
        //   width: Globals.scaler.getWidth(2),
        // ),
        child: IconButton(
          tooltip: "ללחוץ עבור " + widget.tooltip[!on]!,
          icon: Center(
            child: Icon(widget.icons[!on],
                color: !on ? Colors.teal[400] : Colors.red[400],
                size: ScreenScaler().getTextSize(10)),
          ),
          //tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          onPressed: () {
            widget.action(
                !on,
                () => setState(() {
                      on = !on;
                    }));
          },
        ));
  }
}

// also for forums, the chat itself, preview is in ChatsFeedScreen
class SingleChatScreen extends StatefulWidget {
  // sub/unsub to forum is only via join/leave event, or create/delete (for creator)
  static bool hideSubUnsubButton = true;
  String get _draftKey => "DRAFT~${Globals.currentUser!.email}~TO~$otherPerson";
  String? getDraft() => Globals.prefsReadyOrNull?.getString(_draftKey);
  Future<bool>? setDraft(String val) =>
      Globals.prefsReadyOrNull?.setString(_draftKey, val);
  final String otherPerson;
  final String otherPersonName;
  final String? forumName;
  SingleChatScreen(
      {Key? key,
      required this.otherPerson,
      required this.otherPersonName,
      this.forumName})
      : super(key: key);

  @override
  State<SingleChatScreen> createState() => _SingleChatScreenState();
}

class _SingleChatScreenState extends State<SingleChatScreen> {
  final _myUser = types.User(
      id: Globals.currentUser!.email!,
      firstName: Globals.currentUser!.name,
      imageUrl: Globals.currentUser!.avatar);
  late ChatModel model;
  late MyTimer timer;
  String? tce_init_string;
  @override
  void initState() {
    super.initState();
    tce_init_string = widget.getDraft();
    model = ChatModel(
        myMail: Globals.currentUser!.email!,
        otherPerson: widget.otherPerson,
        forum: widget.forumName != null);
    timer = MyTimer(
      duration: MyConsts.checkNewMessageInChatSec,
      function: () async {
        // ignore all unread msg from opened chat, for fcm
        var spm = SPManager("openChat");
        await spm.load();
        int now = DateTime.now().millisecondsSinceEpoch;
        spm['time'] = now;
        spm['chat'] = widget.otherPerson;
        await spm.save();
        return model.refresh().then((value) => true);
      },
    );
    timer.start(true);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void onSend(types.PartialText pt) {
    widget.setDraft("");
    model.send(ChatMessage(
        isForum: widget.forumName != null,
        avatar: Globals.currentUser!.avatar,
        datetime: DateTime.now(),
        dst_mail: widget.otherPerson,
        id: null,
        message: pt.text,
        name: Globals.currentUser!.name,
        src_mail: Globals.currentUser!.email));
  }

  Widget subUnsubButton({bool hide = false}) {
    // sub/unsub to forum is only via join/leave event
    if (hide) return SizedBox();
    // true => sub
    bool on = Globals.currentUser!.subs_topics.containsKey(widget.otherPerson);
    return IconSwitch(
      on,
      (bool toBe, Function flip) {
        if (toBe == true) {
          Globals.db!.updateUserSubs_Topics(add: {
            widget.otherPerson: {"seen": model.counter}
          });
          flip();
        } else {
          showModalBottomSheet(
            context: context,
            builder: ((builder) => NextButton.bottomSheet(
                  context,
                  "האם לבטל מעקב אחר הפורום?",
                  () {
                    Navigator.pop(context);
                    flip();
                    Globals.db!
                        .updateUserSubs_Topics(remove: [widget.otherPerson]);
                  },
                  () {
                    Navigator.pop(context);
                  },
                )),
          );
        }
      },
      tooltip: {true: "הוספת עוקב", false: "הסרת עוקב"},
    );
  }

  appBar(BuildContext context) {
    String title = widget.forumName != null
        ? "פורום - ${widget.forumName}"
        : "שיחה - ${widget.otherPersonName}";
    int maxTitleLen = 40;
    title = title.length <= maxTitleLen
        ? title
        : title.substring(0, maxTitleLen - 3) + "...";
    var scaler = ScreenScaler();
    return new AppBar(
      leadingWidth: Globals.scaler.getWidth(6),
      toolbarHeight: Globals.scaler.getHeight(4.4),
      elevation: 10,
      leading: widget.forumName != null
          ? Builder(builder: (context) {
              return subUnsubButton(hide: SingleChatScreen.hideSubUnsubButton);
            })
          : Builder(
              builder: (context) => Container(
                    margin: EdgeInsets.only(left: 20),
                    // SizedBox(
                    //   width: Globals.scaler.getWidth(2),
                    // ),
                    child: IconButton(
                      icon: Center(
                        child: Icon(Icons.delete,
                            color: Colors.red[400],
                            size: scaler.getTextSize(10)),
                      ),
                      tooltip: MaterialLocalizations.of(context)
                          .openAppDrawerTooltip,
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: ((builder) => NextButton.bottomSheet(
                                context,
                                "השיחה תימחק גם לצד השני,\nולא ניתן לשחזרה.",
                                () {
                                  Navigator.pop(context);
                                  model.deleteAll();
                                },
                                () {
                                  Navigator.pop(context);
                                },
                              )),
                        );
                      },
                    ),
                  )),
      shadowColor: Colors.teal[400],
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(0),
      )),
      backgroundColor: Colors.white,
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                //Center(
                // child:
                Text(
                  'חברותא+',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'Yiddish',
                    color: Colors.teal,
                    fontSize: Globals.scaler.getTextSize(10),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  // ),
                ),
                SizedBox(
                  width: Globals.scaler.getWidth(0.8),
                )
              ],
            ),
            Row(
              children: [
                // Center(
                //  child:
                Text(
                  title,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    //fontFamily: 'Yiddish',
                    color: Colors.blueGrey,
                    fontSize: Globals.scaler.getTextSize(7.5),
                    fontWeight: FontWeight.bold,
                    //letterSpacing: 8,
                  ),
                ),
                //  ),
                SizedBox(
                  width: Globals.scaler.getWidth(0.8),
                )
              ],
            ),
          ],
        ),
      ],
    );
  }

  void onAvatarClick(types.User u) async {
    User user = (await Globals.db!.getUser(u.id))!;
    timer.cancel();
    Navigator.push(context,
            MaterialPageRoute(builder: ((context) => UserDetailsPage(user))))
        .then((value) => timer.start(true));
  }

  @override
  Widget build(BuildContext context) {
    List<ChatMessage> firstData = [];

    Future<List<ChatMessage>> first =
        model.streamAsEntryKey.first.then((value) => firstData = value);
    model.refresh();

    var chatScreenContent = (dynamic snapshot) => Scaffold(
        appBar: appBar(context),
        resizeToAvoidBottomInset: true,
        body: StreamBuilder<List<ChatMessage>>(
            initialData: firstData,
            stream: model.streamAsEntryKey,
            builder: (context, snapshot) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: Chat(
                  dateHeaderThreshold: 60 * 60 * 1000, //min*sec*mill
                  bubbleBuilder: (child,
                      {required message, required nextMessageInGroup}) {
                    bool currentUserIsAuthor =
                        message.author.id == Globals.currentUser!.email;
                    var w = isConsistsOfEmojis(
                      EmojiEnlargementBehavior.multi,
                      message as types.TextMessage,
                    )
                        ? child
                        : Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30)
                                    .copyWith(
                                        bottomRight:
                                            !currentUserIsAuthor // || nextMessageInGroup
                                                ? null
                                                : Radius.zero,
                                        bottomLeft:
                                            currentUserIsAuthor // || nextMessageInGroup
                                                ? null
                                                : Radius.zero),
                                color: !currentUserIsAuthor ||
                                        message.type == types.MessageType.image
                                    ? Colors.white70
                                    : Colors.teal),
                            child: ClipRRect(
                              //borderRadius: 0.0,
                              child: child,
                            ),
                          );

                    var time = DateTimeFormat.format(
                        DateTime.fromMillisecondsSinceEpoch(message.createdAt!)
                            .toLocal(),
                        format: "H:i");

                    var t = Text(
                      time,
                      style: TextStyle(color: Colors.grey
                          // fontWeight: FontWeight.bold,
                          ),
                    );
                    return Column(
                      children: [w, t],
                    );
                  },
                  inputOptions: InputOptions(
                    onTextChanged: (p0) => widget.setDraft(p0),
                    textEditingController:
                        TextEditingController(text: tce_init_string),
                  ),
                  onMessageVisibilityChanged: (p0, visible) =>
                      !visible //|| (widget.forumName != null)
                          ? null
                          : model.msgWasSeen(p0 as types.TextMessage),
                  theme: DefaultChatTheme(
                    backgroundColor: Colors.cyan[50]!,
                    primaryColor: Colors.teal,
                    secondaryColor: Colors.white70,
                    inputTextColor: Colors.black,
                    userAvatarNameColors: [Colors.indigoAccent],
                    //inputTextCursorColor: Colors.yellow,
                    inputBackgroundColor: Colors.white54,
                  ),
                  onMessageLongPress: (context, p1) {
                    if (p1.author.id != _myUser.id ||
                        p1.id == "NULL" ||
                        ChatMessage.isOnMongo(p1.status) == false) return;
                    showModalBottomSheet(
                      context: context,
                      builder: ((builder) => NextButton.bottomSheet(
                            context,
                            "ההודעה תימחק גם לצד השני,\nולא ניתן לשחזרה.",
                            () {
                              Navigator.pop(context);
                              FocusManager.instance.primaryFocus?.unfocus();
                              model.deleteOne(p1);
                            },
                            () {
                              Navigator.pop(context);
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                          )),
                    );
                  },
                  bubbleRtlAlignment: BubbleRtlAlignment.right,
                  messages: snapshot.data!.reversed
                      .map((e) => e.toTypesTextMsg())
                      .toList(),
                  onAvatarTap: onAvatarClick,
                  l10n: ChatL10nHe(),
                  onSendPressed: onSend,
                  showUserAvatars: true,
                  showUserNames: true,
                  user: _myUser,
                ),
              );
            }));
    return Scaffold(
      body: myFutureBuilder(first, chatScreenContent),
    );
  }
}
