

import 'package:sp_util/sp_util.dart';

class  NetConfig{

  NetConfig({
    this.baseUrl = "",
    this.connectTimeout = 20 * 1000,
    this.receiveTimeout = 20 * 1000,
    this.sendTimeout = 20 * 1000,
  });


  ///
  /// 请求baseUrl
  ///
  String? baseUrl;

  /// 超时时间 20s
   int connectTimeout = 20000;

  /// 发送超时时间 20s
   int sendTimeout = 20000;

  /// 接收超时时间 20s
   int receiveTimeout = 20000;
}

enum DioMethod {
  get,
  post,
  put,
  delete,
  patch,
  head,
}