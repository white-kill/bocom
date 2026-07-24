import 'package:dio/dio.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'dio_response.dart';
import 'dio_utils.dart';
import 'interceptor.dart';


class Http {

  ///Get请求
  static Future get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        bool isLoading = true,
      }) async {
    var response = await request(
      path,
      method: HttpMethod.get,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      isLoading: isLoading,
    );
    return response;
  }

  ///Post请求
  static Future post(
      String path, {
        data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        bool isLoading = true,
      }) async {
    var response = await request(
      path,
      method: HttpMethod.post,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      isLoading: isLoading,
    );
    return response;
  }

  /// Request 操作
  /// Put、Delete请求之类都请使用Request请求
  ///
  /// 所有类型请求,都是调用此请求
  static Future request(
      String path, {
        HttpMethod method = HttpMethod.get,
        data,
        bool isLoading = true,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
      }) async {

    var response = await NetUtil.instance.request(
      path,
      method: method,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      isLoading:isLoading
    );
    return response;
  }

  ///设置请求头
  static void setHeaders(Map<String, dynamic> map) {
    NetUtil.instance.setHeaders(map);
  }

  ///设置取消token
  static void cancelRequests({CancelToken? token}) {
    NetUtil.instance.cancelRequests(token: token);
  }
}


