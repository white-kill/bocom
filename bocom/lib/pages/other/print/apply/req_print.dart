
import 'dart:convert';

ReqPrint reqPrintFromJson(String str) => ReqPrint.fromJson(json.decode(str));

String reqPrintToJson(ReqPrint data) => json.encode(data.toJson());

class ReqPrint {
    ReqPrint({
        this.transactionType = '',
        this.minAmount = '',
        this.showType = '',
        this.currency = '',
        this.beginTime = '',
        this.endTime = '',
        this.maxAmount = '',
        this.oppositeName = '',
        this.email = '',
        this.fileType = '',
        this.categoryType = '',
    });

    String transactionType;
    String minAmount;
    String showType;
    String currency;
    String beginTime;
    String endTime;
    String maxAmount;
    String oppositeName;
    String email;
    String fileType;
    String categoryType;

    factory ReqPrint.fromJson(Map<String, dynamic> json) => ReqPrint(
        categoryType: json["categoryType"],
        minAmount: json["minAmount"],
        showType: json["showType"],
        currency: json["currency"],
        beginTime: json["beginTime"],
        endTime: json["endTime"],
        maxAmount: json["maxAmount"],
        oppositeName: json["oppositeName"],
        email: json["email"],
        fileType: json["fileType"],
        transactionType: json["transactionType"],
    );

    Map<String, dynamic> toJson() => {
        "categoryType": categoryType,
        "minAmount": minAmount,
        "showType": showType,
        "currency": currency,
        "beginTime": beginTime,
        "endTime": endTime,
        "maxAmount": maxAmount,
        "oppositeName": oppositeName,
        "email": email,
        "fileType": fileType,
        "transactionType": transactionType,
    };
}
