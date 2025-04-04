// lib/app/components/loader.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class Loader extends StatelessWidget {
  final String? message;
  final bool isFullScreen;

  const Loader({
    Key? key,
    this.message,
    this.isFullScreen = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final widget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LottieBuilder.asset(
          'assets/animations/loading.json',
          width: 120,
          height: 120,
          frameRate: FrameRate(60),
        ),
        if (message != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              message!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );

    if (isFullScreen) {
      return Scaffold(
        body: Center(
          child: widget,
        ),
      );
    }

    return Center(
      child: widget,
    );
  }
}
