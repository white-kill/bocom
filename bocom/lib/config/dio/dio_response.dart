class BaseResponse {
  dynamic data;
  int? code;
  String? msg;

  BaseResponse._({
    this.data,
    this.code,
    this.msg,
  });

  static BaseResponse fromJson(Map<String, dynamic> map) {
    return BaseResponse._(
      data: map['data'],
      code: map['code'],
      msg: map['msg'],
    );
  }
}
