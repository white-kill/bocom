import 'package:flutter/material.dart';

import 'user_invest_info_logic.dart';

class UserInvestDebtPage extends StatefulWidget {
  const UserInvestDebtPage({
    super.key,
    required this.initialSelection,
  });

  final List<String> initialSelection;

  @override
  State<UserInvestDebtPage> createState() => _UserInvestDebtPageState();
}

class _UserInvestDebtPageState extends State<UserInvestDebtPage> {
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelection.toSet();
  }

  void _toggle(String option) {
    setState(() {
      if (option == UserInvestInfoLogic.debtOptions.first) {
        if (_selected.contains(option)) {
          _selected.clear();
        } else {
          _selected
            ..clear()
            ..add(option);
        }
        return;
      }

      _selected.remove(UserInvestInfoLogic.debtOptions.first);
      if (!_selected.add(option)) _selected.remove(option);
    });
  }

  void _confirm() {
    final result = UserInvestInfoLogic.debtOptions
        .where(_selected.contains)
        .toList(growable: false);
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF181818),
          ),
        ),
        title: const Text(
          '尚未偿清的数额较大的债务',
          style: TextStyle(
            color: Color(0xFF181818),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Material(
            color: Colors.white,
            child: Column(
              children: [
                for (final option in UserInvestInfoLogic.debtOptions)
                  InkWell(
                    key: Key('user-invest-debt-option-$option'),
                    onTap: () => _toggle(option),
                    child: SizedBox(
                      height: 68,
                      child: Row(
                        children: [
                          const SizedBox(width: 20),
                          _DebtCheckbox(selected: _selected.contains(option)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              option,
                              style: const TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 42, 16, 0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                key: const Key('user-invest-debt-confirm'),
                onPressed: _confirm,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF0878EE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '确定',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _DebtCheckbox extends StatelessWidget {
  const _DebtCheckbox({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF0878EE) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: selected
              ? const Color(0xFF0878EE)
              : const Color(0xFFD0D5DD),
          width: 1.2,
        ),
      ),
      child: selected
          ? const Icon(Icons.check, color: Colors.white, size: 17)
          : null,
    );
  }
}
