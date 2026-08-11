import 'dart:async';

import 'package:dio/dio.dart';

import '../../utils/sp_util.dart';
import '../app_config.dart';
import '../net_config/net_config.dart';
import 'interceptor.dart';


enum HttpMethod {
  /// Get.
  get,

  /// Post
  post,

  /// Put
  put,

  /// Delete
  delete,
}

///网络封装
class NetUtil {
  factory NetUtil() => instance;

  static NetUtil? _instance;

  static NetUtil get instance => _instance ??= NetUtil._internal();

  Dio dio = Dio();
  final CancelToken _cancelToken = CancelToken();


  LoadingInterceptor loadingInterceptor = LoadingInterceptor();

  NetUtil._internal() {
    // BaseOptions、Options、RequestOptions 都可以配置参数，优先级别依次递增，且可以根据优先级别覆盖参数
    dio.options = BaseOptions(
      baseUrl:AppConfig.config.netConfig.baseUrl??'',
      // 连接超时
      connectTimeout: Duration(milliseconds: AppConfig.config.netConfig.connectTimeout),
      //发送超时
      sendTimeout:  Duration(milliseconds: AppConfig.config.netConfig.sendTimeout),
      // 响应流上前后两次接受到数据的间隔，单位为毫秒。
      receiveTimeout:  Duration(milliseconds: AppConfig.config.netConfig.receiveTimeout),
      // Http请求头.
      headers: {
        'content-type': 'application/json',
        'Authorization':token,
        'client_type':'APP',
        'BANKTYPE':'5'
      },
    );

    // 添加异常拦截器
    dio.interceptors.add(ErrorInterceptor());
    // 添加日志拦截器
    dio.interceptors.add(LogInterceptor());
    //处理通用的实体
    dio.interceptors.add(ResponseInterceptor());
    //处理全局loading
    dio.interceptors.add(loadingInterceptor);
    // 注入设备类型请求头，放在最后确保不被其他拦截器覆盖
    dio.interceptors.add(DeviceHeaderInterceptor());

  }


  /// Get 操作
  Future<T> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    var response = await request<T>(
      path,
      method: HttpMethod.get,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
    );
    return response;
  }

  /// Post 操作
  Future<T> post<T>(
      String path, {
        data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    var response = await request<T>(
      path,
      method: HttpMethod.post,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
    );
    return response;
  }

  /// Put 操作
  Future<T> put<T>(
      String path, {
        data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    var response = await request<T>(
      path,
      method: HttpMethod.put,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
    );
    return response;
  }

  /// delete 操作
  Future<T> delete<T>(
      String path, {
        data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    var response = await request<T>(
      path,
      method: HttpMethod.delete,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
    );
    return response;
  }

  /// Request 操作
  Future<T> request<T>(
      String path, {
        required HttpMethod method,
        data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
        bool isLoading = true,
      }) async {
    loadingInterceptor.isLoading = isLoading;
    //处理网络类型
    if (method == HttpMethod.get) {
      dio.options.method = 'GET';
    } else if (method == HttpMethod.post) {
      dio.options.method = 'POST';
    } else if (method == HttpMethod.delete) {
      dio.options.method = 'DELETE';
    } else if (method == HttpMethod.put) {
      dio.options.method = 'PUT';
    }
    //处理请求设置
    options = options ?? Options();
    Completer<T> completer = Completer();
    dio.request<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    )
        .then((value) => {
      completer.complete(value.data),
    })
        .catchError((error) => {
      completer.complete(null),
      completer.completeError(error),
    })
        .whenComplete(() => null);

    return completer.future;
  }


  /// 设置headers
  void setHeaders(Map<String, dynamic> map) {
    dio.options.headers.addAll(map);
  }

  /// 移除header
  void removeHeader(String? key) {
    dio.options.headers.remove(key);
  }

  /// 取消请求
  ///
  /// 同一个cancel token 可以用于多个请求，当一个cancel token取消时，所有使用该cancel token的请求都会被取消。
  /// 所以参数可选
  void cancelRequests({CancelToken? token}) {
    token ?? _cancelToken.cancel("cancelled");
  }
}
