import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';


class AlterWidget {

  static alterWidget({required Widget Function(BuildContext context) builder,bool dismiss=false}){
    SmartDialog.show(
      usePenetrate: false,
      clickMaskDismiss: dismiss,
      builder:builder,
    );
  }

}