import 'package:bocom/pages/tabs/mine/mine_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('refreshes the login time text whenever MinePage becomes visible', () {
    final logic = MineLogic();
    final visibleAt = DateTime(2026, 9, 4, 12);

    logic.onPageVisible(now: visibleAt);

    expect(logic.loginTimeReference.value, visibleAt);
  });
}
