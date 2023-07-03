library my_future_builder;

import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';

Widget defaultWaitActiveWidget = Center(
  child: LoadingBouncingGrid.square(
    borderColor: Colors.teal[400]!,
    backgroundColor: Colors.teal[400]!,
    size: 20.0,
  ),
);

Widget myFutureBuilder(Future<dynamic>? theFuture,
    Widget Function(dynamic snapshot) connectionDoneFunc,
    {bool isCostumise = false,
    Widget connectionWaitActiveWidget =
        const Text('missing default argument to myFutureBuilder')}) {
  return FutureBuilder(
      future: theFuture,
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('none');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return isCostumise
                ? connectionWaitActiveWidget
                : defaultWaitActiveWidget;
          case ConnectionState.done:
            return connectionDoneFunc(snapshot);
          default:
            return Text('default');
        }
      });
}
