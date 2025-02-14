// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

// This code has to be available in both the Flutter app and Dart VM test.
// ignore: implementation_imports
import 'package:flutter_driver/src/common/message.dart';

/// A command that is forwarded to a registered plugin.
final class NativeCommand extends Command {
  /// Creates a new [NativeCommand] with the given [method].
  const NativeCommand(this.method, {this.arguments, super.timeout});

  /// Tries to tap a native view by a selector.
  factory NativeCommand.tap(NativeFinder finder) {
    return NativeCommand('tap_view', arguments: finder);
  }

  /// Requests that the device be rotated to landscape mode.
  static const NativeCommand rotateLandscape = NativeCommand('rotate_landscape');

  /// Requests that the device reset its rotation to the default orientation.
  static const NativeCommand rotateDefault = NativeCommand('rotate_default');

  /// Pings the device to ensure it is responsive.
  static const NativeCommand ping = NativeCommand('ping');

  /// Gets the SDK version code.
  static const NativeCommand getSdkVersion = NativeCommand('sdk_version');

  /// Gets whether the device is an emulator.
  static const NativeCommand getIsEmulator = NativeCommand('is_emulator');

  /// The method to call on the plugin.
  final String method;

  /// What arguments to pass when invoking the [method].
  final Object? arguments;

  @override
  String get kind => 'native_driver';

  @override
  Map<String, String> serialize() {
    final Map<String, String> serialized = super.serialize();
    serialized['method'] = method;
    if (arguments != null) {
      serialized['arguments'] = jsonEncode(arguments);
    }
    return serialized;
  }
}

/// A result from a [NativeCommand].
final class NativeResult extends Result {
  /// Creates a new [NativeResult].
  const NativeResult();

  @override
  Map<String, dynamic> toJson() => const <String, Object?>{};
}

/// An object that describes searching for _native_ elements.
sealed class NativeFinder {
  const NativeFinder();

  /// Serializes to JSON.
  Map<String, Object?> toJson() => const <String, Object?>{};
}

/// Finds a native element by its native accessibility label.
final class ByNativeAccessibilityLabel extends NativeFinder {
  /// Creates a new [ByNativeSemanticsLabel] finder.
  const ByNativeAccessibilityLabel(this.label);

  /// The label to search for.
  ///
  /// ## Android
  ///
  /// On Android, this label is the `contentDescription` of the view:
  ///
  /// ```java
  /// view.setContentDescription("My Label");
  /// ```
  final String label;

  @override
  Map<String, String> toJson() {
    return <String, String>{'kind': 'byNativeAccessibilityLabel', 'label': label};
  }

  /// Deserializes this finder from the value generated by [serialize].
  static ByNativeAccessibilityLabel deserialize(Map<String, String> params) {
    return ByNativeAccessibilityLabel(params['label']!);
  }
}

/// Finds a native element by its native integer-based ID.
final class ByNativeIntegerId extends NativeFinder {
  /// Creates a new [ByNativeIntegerId] finder.
  const ByNativeIntegerId(this.id);

  /// The integer ID to search for.
  ///
  /// ## Android
  ///
  /// On Android, this ID is the `View.getId()` of the view:
  ///
  /// ```java
  /// view.setId(42);
  /// ```
  final int id;

  @override
  Map<String, String> toJson() {
    return <String, String>{'kind': 'byNativeIntegerId', 'id': id.toString()};
  }

  /// Deserializes this finder from the value generated by [serialize].
  static ByNativeIntegerId deserialize(Map<String, String> params) {
    return ByNativeIntegerId(int.parse(params['id']!));
  }
}
