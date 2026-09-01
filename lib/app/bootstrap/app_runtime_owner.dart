import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:rest_eye/app/bootstrap/app_runtime.dart';

final class AppRuntimeOwner extends StatefulWidget {
  const AppRuntimeOwner({
    required this.runtime,
    required this.child,
    super.key,
  });

  final AppRuntime runtime;
  final Widget child;

  @override
  State<AppRuntimeOwner> createState() => _AppRuntimeOwnerState();
}

final class _AppRuntimeOwnerState extends State<AppRuntimeOwner> {
  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    unawaited(widget.runtime.dispose());
    super.dispose();
  }
}
