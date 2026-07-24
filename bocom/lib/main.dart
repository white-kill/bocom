import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'config/app_config.dart';
import 'main/my_app_page.dart';

void main() async{
  await AppConfig.config.initApp();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]).then((_) {
    runApp(const MyApp());
  });

}

