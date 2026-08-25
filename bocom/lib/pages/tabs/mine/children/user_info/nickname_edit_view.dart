import 'package:bocom/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

class NicknameEditPage extends StatefulWidget {
  const NicknameEditPage({super.key, required this.initialNickname});

  final String initialNickname;

  @override
  State<NicknameEditPage> createState() => _NicknameEditPageState();
}

class _NicknameEditPageState extends State<NicknameEditPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNickname);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final nickname = _controller.text.trim();
    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: BaseText(text: '昵称不能为空')),
      );
      return;
    }
    Get.back<String>(result: nickname);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF181818),
        title: const BaseText(
          text: '昵称',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        leading: IconButton(
          tooltip: '返回',
          icon: const Icon(Icons.navigate_before, size: 32),
          onPressed: () => Get.back<void>(),
        ),
        actions: [
          Semantics(
            button: true,
            label: '客服',
            child: InkWell(
              onTap: () => Get.toNamed<void>(Routes.customerService),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Image.asset(
                  'assets/images/home_nav_service_dark.png',
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.white,
            child: Row(
              children: [
                const BaseText(
                  text: '昵称',
                  fontSize: 16,
                  color: Color(0xFF4A4A4A),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: TextField(
                    key: const Key('nickname-input'),
                    controller: _controller,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                    style: const TextStyle(
                      fontSize: 17,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 36, 16, 0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                key: const Key('nickname-confirm'),
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF0877ED),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const BaseText(
                  text: '确定',
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
