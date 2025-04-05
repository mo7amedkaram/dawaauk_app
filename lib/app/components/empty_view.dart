// lib/app/components/empty_view.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyView extends StatelessWidget {
  final String? message;
  final String? actionText;
  final VoidCallback? onAction;
  final bool isFullScreen;

  const EmptyView({
    Key? key,
    this.message,
    this.actionText,
    this.onAction,
    this.isFullScreen = false,
    required LottieBuilder customWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final widget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LottieBuilder.asset(
          'assets/animations/empty.json',
          width: 150,
          height: 150,
          frameRate: FrameRate(60),
        ),
        const SizedBox(height: 16),
        Text(
          message ?? 'لا توجد بيانات',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        if (onAction != null && actionText != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ElevatedButton(
              onPressed: onAction,
              child: Text(actionText!),
            ),
          ),
      ],
    );

    if (isFullScreen) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: widget,
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: widget,
      ),
    );
  }
}
