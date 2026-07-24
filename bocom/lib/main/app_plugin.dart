
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';


/// TransitionBuilder Scaffold
Widget appBuilder(context,child){
  return GestureDetector(
    onTap: (){
      FocusScopeNode focusScopeNode = FocusScope.of(context);
      if (!focusScopeNode.hasPrimaryFocus
          && focusScopeNode.focusedChild != null) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    },
    child: MediaQuery(
      ///设置文字大小不随系统设置改变
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: pluginScreenUtilInit(child),
    )
  );
}



///flutter_ScreenUtil插件
Widget pluginScreenUtilInit (Widget child){
  return ScreenUtilInit(
      designSize: const Size(375, 750), //设计稿的宽度和高度 px
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, c) => pluginRef(child));
}

/// flutter_smart_dialog插件
Widget pluginSmartDialog(child){
  return FlutterSmartDialog(
    child:  child,
  );
}


///刷新插件
Widget pluginRef(child){
  return RefreshConfiguration(
      // headerBuilder: () => const WaterDropHeader(
      //   waterDropColor: Colors.white,
      // ),
      // footerBuilder: () => const ClassicFooter(),
      hideFooterWhenNotFull: true,
      enableBallisticLoad: true,
      child:child
  );
}









