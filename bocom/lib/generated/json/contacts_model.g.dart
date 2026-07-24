import 'package:bocom/generated/json/base/json_convert_content.dart';
import 'package:bocom/config/model/contacts_model.dart';

ContactsModel $ContactsModelFromJson(Map<String, dynamic> json) {
  final ContactsModel contactsModel = ContactsModel();
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    contactsModel.name = name;
  }
  final String? bankName = jsonConvert.convert<String>(json['bankName']);
  if (bankName != null) {
    contactsModel.bankName = bankName;
  }
  final String? bankId = jsonConvert.convert<String>(json['bankId']);
  if (bankId != null) {
    contactsModel.bankId = bankId;
  }
  final String? bankCard = jsonConvert.convert<String>(json['bankCard']);
  if (bankCard != null) {
    contactsModel.bankCard = bankCard;
  }
  final String? icon = jsonConvert.convert<String>(json['icon']);
  if (icon != null) {
    contactsModel.icon = icon;
  }
  return contactsModel;
}

Map<String, dynamic> $ContactsModelToJson(ContactsModel entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['name'] = entity.name;
  data['bankName'] = entity.bankName;
  data['bankId'] = entity.bankId;
  data['bankCard'] = entity.bankCard;
  data['icon'] = entity.icon;
  return data;
}

extension ContactsModelExtension on ContactsModel {
  ContactsModel copyWith({
    String? name,
    String? bankName,
    String? bankId,
    String? bankCard,
    String? icon,
  }) {
    return ContactsModel()
      ..name = name ?? this.name
      ..bankName = bankName ?? this.bankName
      ..bankId = bankId ?? this.bankId
      ..bankCard = bankCard ?? this.bankCard
      ..icon = icon ?? this.icon;
  }
}