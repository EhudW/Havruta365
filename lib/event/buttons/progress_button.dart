import 'package:flutter/material.dart';

import 'iconed_button.dart';

//
// [L]   idle - you can join to this LECTURE
// [L,H] fail - you already joined to this LECTURE \ HAVRUTA, which isn't online right now
// [H]   idle2 - you can send request to join to this HAVRUTA
// [H]   fail2 - you already asked to join to this HAVRUTA [even if it's online right now]
//
// [L,H] loading - loading...
// [L,H] success - this shiur/havruta is online
// cant join:
// [L,H] full - you can't join shiur\ask to join havruta since it full
// [L,H] rejected - you can't join unless the creator accept you
// [L,H] notForMe - Globals.currentUser?.isTargetedForMe(event)!=true
// examples:
// shiur[L]:      idle  <-> loading <-> success / fail
//               or start at full
// HAVRUTA[H]:    idle2 <-> loading <-> fail2
//               or start at[if creator accept request]: fail/full/success
//
enum ButtonState {
  idle,
  loading,
  success,
  fail,
  full,
  idle2,
  fail2,
  rejected,
  notForMe
}

class ProgressButton extends StatefulWidget {
  final Map<ButtonState, Widget> stateWidgets;
  final Map<ButtonState, Color?> stateColors;
  final Function? onPressed;
  final Function? onAnimationEnd;
  final ButtonState state;
  final minWidth;
  final maxWidth;
  final radius;
  final height;
  final ProgressIndicator? progressIndicator;
  final progressIndicatorSize;
  final MainAxisAlignment progressIndicatorAligment;
  final EdgeInsets padding;
  final List<ButtonState> minWidthStates;

  ProgressButton(
      {Key? key,
      required this.stateWidgets,
      required this.stateColors,
      this.state = ButtonState.idle,
      this.onPressed,
      this.onAnimationEnd,
      this.minWidth = 200.0,
      this.maxWidth = 400.0,
      this.radius = 16.0,
      this.height = 53.0,
      this.progressIndicatorSize = 35.0,
      this.progressIndicator,
      this.progressIndicatorAligment = MainAxisAlignment.spaceBetween,
      this.padding = EdgeInsets.zero,
      this.minWidthStates = const <ButtonState>[ButtonState.loading]})
      : assert(
          stateWidgets.keys.toSet().containsAll(ButtonState.values.toSet()),
          'Must be non-null widgetds provided in map of stateWidgets. Missing keys => ${ButtonState.values.toSet().difference(stateWidgets.keys.toSet())}',
        ),
        assert(
          stateColors.keys.toSet().containsAll(ButtonState.values.toSet()),
          'Must be non-null widgetds provided in map of stateWidgets. Missing keys => ${ButtonState.values.toSet().difference(stateColors.keys.toSet())}',
        ),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProgressButtonState();
  }

  factory ProgressButton.icon({
    required Map<ButtonState, IconedButton> iconedButtons,
    Function? onPressed,
    ButtonState state = ButtonState.idle,
    Function? animationEnd,
    maxWidth = 170.0,
    minWidth = 58.0,
    height = 53.0,
    radius = 100.0,
    progressIndicatorSize = 35.0,
    double iconPadding = 4.0,
    TextStyle? textStyle,
    CircularProgressIndicator? progressIndicator,
    MainAxisAlignment? progressIndicatorAligment,
    EdgeInsets padding = EdgeInsets.zero,
    List<ButtonState> minWidthStates = const <ButtonState>[ButtonState.loading],
  }) {
    assert(
      iconedButtons.keys.toSet().containsAll(ButtonState.values.toSet()),
      'Must be non-null widgets provided in map of stateWidgets. Missing keys => ${ButtonState.values.toSet().difference(iconedButtons.keys.toSet())}',
    );

    if (textStyle == null) {
      textStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.w500);
    }

    Map<ButtonState, Widget> stateWidgets = {
      ButtonState.idle: buildChildWithIcon(
          iconedButtons[ButtonState.idle]!, iconPadding, textStyle),
      ButtonState.idle2: buildChildWithIcon(
          iconedButtons[ButtonState.idle2]!, iconPadding, textStyle),
      ButtonState.loading: Column(),
      ButtonState.fail: buildChildWithIcon(
          iconedButtons[ButtonState.fail]!, iconPadding, textStyle),
      ButtonState.fail2: buildChildWithIcon(
          iconedButtons[ButtonState.fail2]!, iconPadding, textStyle),
      ButtonState.success: buildChildWithIcon(
          iconedButtons[ButtonState.success]!, iconPadding, textStyle),
      ButtonState.full: buildChildWithIcon(
          iconedButtons[ButtonState.full]!, iconPadding, textStyle),
      ButtonState.rejected: buildChildWithIcon(
          iconedButtons[ButtonState.rejected]!, iconPadding, textStyle),
      ButtonState.notForMe: buildChildWithIcon(
          iconedButtons[ButtonState.notForMe]!, iconPadding, textStyle),
    };

    Map<ButtonState, Color?> stateColors = {
      ButtonState.idle: iconedButtons[ButtonState.idle]!.color,
      ButtonState.idle2: iconedButtons[ButtonState.idle2]!.color,
      ButtonState.loading: iconedButtons[ButtonState.loading]!.color,
      ButtonState.fail: iconedButtons[ButtonState.fail]!.color,
      ButtonState.fail2: iconedButtons[ButtonState.fail2]!.color,
      ButtonState.success: iconedButtons[ButtonState.success]!.color,
      ButtonState.full: iconedButtons[ButtonState.full]!.color,
      ButtonState.rejected: iconedButtons[ButtonState.rejected]!.color,
      ButtonState.notForMe: iconedButtons[ButtonState.notForMe]!.color,
    };

    return ProgressButton(
      stateWidgets: stateWidgets,
      stateColors: stateColors,
      state: state,
      onPressed: onPressed,
      onAnimationEnd: animationEnd,
      maxWidth: maxWidth,
      minWidth: minWidth,
      radius: radius,
      height: height,
      progressIndicatorSize: progressIndicatorSize,
      progressIndicatorAligment: MainAxisAlignment.center,
      progressIndicator: progressIndicator,
      minWidthStates: minWidthStates,
    );
  }
}

class _ProgressButtonState extends State<ProgressButton>
    with TickerProviderStateMixin {
  AnimationController? colorAnimationController;
  Animation<Color?>? colorAnimation;
  double? width;
  Duration animationDuration = Duration(milliseconds: 500);
  Widget? progressIndicator;

  void startAnimations(ButtonState oldState, ButtonState newState) {
    Color? begin = widget.stateColors[oldState];
    Color? end = widget.stateColors[newState];
    if (widget.minWidthStates.contains(newState)) {
      width = widget.minWidth;
    } else {
      width = widget.maxWidth;
    }
    colorAnimation = ColorTween(begin: begin, end: end).animate(CurvedAnimation(
      parent: colorAnimationController!,
      curve: Interval(
        0,
        1,
        curve: Curves.easeIn,
      ),
    ));
    colorAnimationController!.forward();
  }

  Color? get backgroundColor => colorAnimation == null
      ? widget.stateColors[widget.state]
      : colorAnimation!.value ?? widget.stateColors[widget.state];

  @override
  void initState() {
    super.initState();

    width = widget.maxWidth;

    colorAnimationController =
        AnimationController(duration: animationDuration, vsync: this);
    colorAnimationController!.addStatusListener((status) {
      if (widget.onAnimationEnd != null) {
        widget.onAnimationEnd!(status, widget.state);
      }
    });

    progressIndicator = widget.progressIndicator ??
        CircularProgressIndicator(
            backgroundColor: widget.stateColors[widget.state],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white));
  }

  @override
  void dispose() {
    colorAnimationController!.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ProgressButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.state != widget.state) {
      colorAnimationController?.reset();
      startAnimations(oldWidget.state, widget.state);
    }
  }

  Widget getButtonChild(bool visibility) {
    Widget? buttonChild = widget.stateWidgets[widget.state];
    if (widget.state == ButtonState.loading) {
      return Row(
        mainAxisAlignment: widget.progressIndicatorAligment,
        children: <Widget>[
          SizedBox(
            child: progressIndicator,
            width: widget.progressIndicatorSize,
            height: widget.progressIndicatorSize,
          ),
          buttonChild ?? Container(),
          Container()
        ],
      );
    }
    return AnimatedOpacity(
        opacity: visibility ? 1.0 : 0.0,
        duration: Duration(milliseconds: 250),
        child: buttonChild);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: colorAnimationController!,
      builder: (context, child) {
        return AnimatedContainer(
            width: width,
            height: widget.height,
            duration: animationDuration,
            child: MaterialButton(
              padding: widget.padding,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(widget.radius),
                  side: BorderSide(color: Colors.transparent, width: 0)),
              color: backgroundColor,
              onPressed: widget.onPressed as void Function()?,
              child: getButtonChild(
                  colorAnimation == null ? true : colorAnimation!.isCompleted),
            ));
      },
    );
  }
}
