import 'package:bocom/main/my_app_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  test('页面使用从右向左进入并反向退出的默认动画', () {
    const app = MyApp();

    expect(app.defaultTransition, Transition.rightToLeft);
    expect(app.transitionDuration, const Duration(milliseconds: 240));
  });
}
