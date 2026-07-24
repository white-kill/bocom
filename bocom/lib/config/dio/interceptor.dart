import 'dart:io';

import 'package:bocom/utils/sp_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:wb_base_widget/extension/string_extension.dart';

import '../../routes/app_pages.dart';
import 'dio_response.dart';

/// 设备类型拦截器，确保 login_device 始终注入且不被覆盖
/// 1: iOS  2: Android
class DeviceHeaderInterceptor extends Interceptor {
  static const String _key = 'login_device';
  static final String _value = Platform.isIOS ? '1' : '2';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers[_key] = _value;
    handler.next(options);
  }
}

/// 错误处理拦截器
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // error统一处理
    AppException appException = AppException.init(err);
    // 错误提示
    debugPrint('DioError===: ${appException.toString()}');

    err.copyWith(error: {err: appException});

    handler.next(err);
  }
}

/// 自定义异常
class AppException implements Exception {
  final String? message;
  final int? code;

  AppException(this.code, this.message);

  @override
  String toString() => "$code$message";

  factory AppException.init(DioException error) {
    switch (error.type) {
      case DioExceptionType.cancel:
        return AppException(-1, "请求取消");
      case DioExceptionType.connectionTimeout:
        return AppException(-1, "连接超时");
      case DioExceptionType.sendTimeout:
        return AppException(-1, "请求超时");
      case DioExceptionType.receiveTimeout:
        return AppException(-1, "响应超时");
      case DioExceptionType.badResponse:
        try {
          int errCode = error.response?.statusCode ?? -1;
          switch (errCode) {
            case 400:
              return AppException(errCode, "请求语法错误");
            case 401:
              return AppException(errCode, "没有权限");
            case 403:
              return AppException(errCode, "服务器拒绝执行");
            case 404:
              return AppException(errCode, "无法连接服务器");
            case 405:
              return AppException(errCode, "请求方法被禁止");
            case 500:
              return AppException(errCode, "服务器内部错误");
            case 502:
              return AppException(errCode, "无效的请求");
            case 503:
              return AppException(errCode, "服务器挂了");
            case 505:
              return AppException(errCode, "不支持HTTP协议请求");
            default:
              return AppException(
                  errCode, error.response?.statusMessage ?? '未知错误');
          }
        } catch (e) {
          return AppException(-1, "未知错误：${e.toString()}");
        }
      default:
        return AppException(-1, error.message);
    }
  }
}

///此处定义一个响应拦截器
class ResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    //处理最外层数据结构
    BaseResponse bean = BaseResponse.fromJson(response.data);

    //可以在此处处理一些通用的错误信息
    if (bean.code == 401) {
      '登陆失效，请重新登陆'.showToast;
      ''.saveToken;
      Get.offAllNamed(Routes.login);

    }
    if (bean.code != 200) {
      (bean.msg??'请求失败').showToast;
    }
    response.data = bean.data;

    handler.next(response);

  }
}
///此处定义一个弹窗加载拦截器
class LoadingInterceptor extends Interceptor {
  bool isLoading = true;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    //打开加载弹窗
    if (isLoading) ''.showLoading;

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    //关闭弹窗
    if (isLoading && SmartDialog.config.checkExist()) {
      await SmartDialog.dismiss(status: SmartStatus.loading);
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    //关闭弹窗
    if (isLoading && SmartDialog.config.checkExist()) {
      await SmartDialog.dismiss(status: SmartStatus.loading);
    }

    handler.next(err);
  }
}
