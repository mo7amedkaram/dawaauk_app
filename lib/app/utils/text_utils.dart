// lib/app/utils/text_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// مجموعة من الأدوات المساعدة للتعامل مع النصوص بشكل متجاوب وتجنب مشاكل TextOverflow
class AppTextUtils {
  /// دالة لإنشاء عنوان كبير متجاوب
  static Text largeTitle(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    int maxLines = 1,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return Text(
      text,
      style: style?.copyWith(fontSize: 22.sp) ??
          TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// دالة لإنشاء عنوان متوسط متجاوب
  static Text mediumTitle(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    int maxLines = 1,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return Text(
      text,
      style: style?.copyWith(fontSize: 18.sp) ??
          TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// دالة لإنشاء عنوان صغير متجاوب
  static Text smallTitle(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    int maxLines = 1,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return Text(
      text,
      style: style?.copyWith(fontSize: 16.sp) ??
          TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// دالة لإنشاء نص عادي متجاوب
  static Text bodyText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    int maxLines = 2,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return Text(
      text,
      style: style?.copyWith(fontSize: 14.sp) ?? TextStyle(fontSize: 14.sp),
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// دالة لإنشاء نص صغير متجاوب
  static Text smallText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    int maxLines = 1,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return Text(
      text,
      style: style?.copyWith(fontSize: 12.sp) ?? TextStyle(fontSize: 12.sp),
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// دالة لإنشاء نص قابل للتمدد (يتوسع ويتقلص حسب المساحة المتاحة)
  static Widget expandableText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    int minLines = 1,
    int maxLines = 3,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // حساب كم كلمة يمكن أن تتناسب مع العرض المتاح
        final textSpan = TextSpan(
          text: text,
          style: style?.copyWith(fontSize: 14.sp) ?? TextStyle(fontSize: 14.sp),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.rtl,
          maxLines: maxLines,
        );
        textPainter.layout(maxWidth: constraints.maxWidth);

        // ضبط عدد الأسطر بناءً على حجم النص والمساحة المتاحة
        final textLines = textPainter.computeLineMetrics().length;
        final actualMaxLines = textLines > maxLines
            ? maxLines
            : (textLines < minLines ? minLines : textLines);

        return Text(
          text,
          style: style?.copyWith(fontSize: 14.sp) ?? TextStyle(fontSize: 14.sp),
          textAlign: textAlign ?? TextAlign.start,
          maxLines: actualMaxLines,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }

  /// دالة لإنشاء نص قابل للضغط لعرض المزيد
  static Widget expandableTextWithShowMore(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    int collapsedLines = 2,
    VoidCallback? onExpand,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: style?.copyWith(fontSize: 14.sp) ?? TextStyle(fontSize: 14.sp),
          textAlign: textAlign ?? TextAlign.start,
          maxLines: collapsedLines,
          overflow: TextOverflow.ellipsis,
        ),
        if (getTextLines(text, style) > collapsedLines)
          GestureDetector(
            onTap: onExpand,
            child: Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                'عرض المزيد',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// دالة مساعدة لحساب عدد الأسطر المتوقعة للنص
  static int getTextLines(String text, TextStyle? style) {
    final textSpan = TextSpan(
      text: text,
      style: style?.copyWith(fontSize: 14.sp) ?? TextStyle(fontSize: 14.sp),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.rtl,
      maxLines: 100, // قيمة كبيرة لحساب جميع الأسطر المحتملة
    );
    textPainter.layout(maxWidth: 300.w); // قيمة تقريبية لعرض الشاشة
    return textPainter.computeLineMetrics().length;
  }

  /// دالة لإنشاء نص يتناسب مع المساحة المحددة
  static Widget fittedText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    BoxFit fit = BoxFit.scaleDown,
  }) {
    return FittedBox(
      fit: fit,
      child: Text(
        text,
        style: style,
        textAlign: textAlign ?? TextAlign.start,
      ),
    );
  }
}
