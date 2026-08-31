import 'package:bocom/config/model/member_info_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads name pinyin and birthday from JSON', () {
    final model = MemberInfoModel.fromJson(const <String, dynamic>{
      'namePinyin': 'ZHANG SAN',
      'birthday': '1990-01-02',
    });

    expect(model.namePinyin, 'ZHANG SAN');
    expect(model.birthday, '1990-01-02');
  });

  test('writes name pinyin and birthday to JSON', () {
    final model = MemberInfoModel()
      ..namePinyin = 'LI SI'
      ..birthday = '2000-08-30';

    final json = model.toJson();

    expect(json['namePinyin'], 'LI SI');
    expect(json['birthday'], '2000-08-30');
  });

  test('copies name pinyin and birthday', () {
    final model = MemberInfoModel()
      ..namePinyin = 'ZHANG SAN'
      ..birthday = '1990-01-02';

    final copied = model.copyWith(
      namePinyin: 'LI SI',
      birthday: '2000-08-30',
    );

    expect(copied.namePinyin, 'LI SI');
    expect(copied.birthday, '2000-08-30');
  });
}
