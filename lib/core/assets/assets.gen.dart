/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/Group 723.svg
  SvgGenImage get group723 => const SvgGenImage('assets/icons/Group 723.svg');

  /// File path: assets/icons/Icon-1.svg
  SvgGenImage get icon1 => const SvgGenImage('assets/icons/Icon-1.svg');

  /// File path: assets/icons/Icon.svg
  SvgGenImage get icon => const SvgGenImage('assets/icons/Icon.svg');

  /// File path: assets/icons/Vector-1.svg
  SvgGenImage get vector1 => const SvgGenImage('assets/icons/Vector-1.svg');

  /// File path: assets/icons/Vector-2.svg
  SvgGenImage get vector2 => const SvgGenImage('assets/icons/Vector-2.svg');

  /// File path: assets/icons/Vector-3.svg
  SvgGenImage get vector3 => const SvgGenImage('assets/icons/Vector-3.svg');

  /// File path: assets/icons/Vector.svg
  SvgGenImage get vector => const SvgGenImage('assets/icons/Vector.svg');

  /// File path: assets/icons/carbon_favorite.svg
  SvgGenImage get carbonFavorite =>
      const SvgGenImage('assets/icons/carbon_favorite.svg');

  /// File path: assets/icons/ic_round-alternate-email-1.svg
  SvgGenImage get icRoundAlternateEmail1 =>
      const SvgGenImage('assets/icons/ic_round-alternate-email-1.svg');

  /// File path: assets/icons/ic_round-alternate-email-2.svg
  SvgGenImage get icRoundAlternateEmail2 =>
      const SvgGenImage('assets/icons/ic_round-alternate-email-2.svg');

  /// File path: assets/icons/ic_round-alternate-email-3.svg
  SvgGenImage get icRoundAlternateEmail3 =>
      const SvgGenImage('assets/icons/ic_round-alternate-email-3.svg');

  /// File path: assets/icons/ic_round-alternate-email.svg
  SvgGenImage get icRoundAlternateEmail =>
      const SvgGenImage('assets/icons/ic_round-alternate-email.svg');

  /// File path: assets/icons/pepicons-pop_eye.svg
  SvgGenImage get pepiconsPopEye =>
      const SvgGenImage('assets/icons/pepicons-pop_eye.svg');

  /// List of all assets
  List<SvgGenImage> get values => [
        group723,
        icon1,
        icon,
        vector1,
        vector2,
        vector3,
        vector,
        carbonFavorite,
        icRoundAlternateEmail1,
        icRoundAlternateEmail2,
        icRoundAlternateEmail3,
        icRoundAlternateEmail,
        pepiconsPopEye
      ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/background.png
  AssetGenImage get background =>
      const AssetGenImage('assets/images/background.png');

  /// File path: assets/images/clock.png
  AssetGenImage get clock => const AssetGenImage('assets/images/clock.png');

  /// File path: assets/images/light-1.png
  AssetGenImage get light1 => const AssetGenImage('assets/images/light-1.png');

  /// File path: assets/images/light-2.png
  AssetGenImage get light2 => const AssetGenImage('assets/images/light-2.png');

  /// File path: assets/images/logomoper.png
  AssetGenImage get logomoper =>
      const AssetGenImage('assets/images/logomoper.png');

  /// File path: assets/images/logomoperr.png
  AssetGenImage get logomoperr =>
      const AssetGenImage('assets/images/logomoperr.png');

  /// File path: assets/images/moper.png
  AssetGenImage get moper => const AssetGenImage('assets/images/moper.png');

  /// File path: assets/images/profile-bg3.jpg
  AssetGenImage get profileBg3 =>
      const AssetGenImage('assets/images/profile-bg3.jpg');

  /// List of all assets
  List<AssetGenImage> get values => [
        background,
        clock,
        light1,
        light2,
        logomoper,
        logomoperr,
        moper,
        profileBg3
      ];
}

class Assets {
  Assets._();

  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class SvgGenImage {
  const SvgGenImage(this._assetName);

  final String _assetName;

  SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    SvgTheme theme = const SvgTheme(),
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    return SvgPicture.asset(
      _assetName,
      key: key,
      matchTextDirection: matchTextDirection,
      bundle: bundle,
      package: package,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      theme: theme,
      colorFilter: colorFilter,
      color: color,
      colorBlendMode: colorBlendMode,
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
