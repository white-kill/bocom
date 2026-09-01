import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

class UserJobOccupationPage extends StatelessWidget {
  const UserJobOccupationPage({super.key});

  static const List<String> primaryOptions = [
    '国家公务员及企事业单位负责人',
    '专业技术人员',
    '公司职员和事业单位员工',
    '商业、服务业人员',
    '农、林、牧、渔、水利业生产人员',
    '工人',
    '军人/武警',
    '私营业主/自由职业',
    '离退休人员',
    '学生/学龄前儿童',
    '无业',
  ];

  static const Map<String, List<String>> secondaryOptions = {
    '国家公务员及企事业单位负责人': [
      '国家公务员',
      '事业单位负责人',
      '企业负责人',
    ],
    '专业技术人员': [
      '科学研究人员',
      '工程技术人员',
      '农业技术人员',
      '飞机和船舶技术人员',
      '卫生专业技术人员',
      '经济业务人员',
      '金融业务人员',
      '法律专业人员',
      '教学人员',
      '文学艺术工作人员',
      '体育工作人员',
      '新闻出版、文化工作人员',
      '宗教职业者',
      '其他专业技术人员',
    ],
    '公司职员和事业单位员工': [
      '行政办公人员',
      '安全保卫和消防人员',
      '邮政和电信业务人员',
      '其他办事人员和有关人员',
      '外国使领馆人员',
      '慈善机构工作人员',
    ],
    '商业、服务业人员': [
      '购销人员',
      '仓储人员',
      '餐饮服务人员',
      '饭店、旅游及健身娱乐场所服务人员',
      '运输服务人员',
      '医疗卫生辅助服务人员',
      '社会服务和居民生活服务人员',
      '其他商业、服务业人员',
      '珠宝、贵金属、艺术品收藏及拍卖人员',
      '废旧物资回收人员',
    ],
    '农、林、牧、渔、水利业生产人员': [
      '农民',
      '林业生产及野生动植物保护人员',
      '畜牧业生产人员',
      '渔业生产人员',
      '水利设施管理养护人员',
      '其他农、林、牧、渔、水利业生产人员',
    ],
    '私营业主/自由职业': ['自由职业', '私营业主'],
    '学生/学龄前儿童': ['学生'],
  };

  @override
  Widget build(BuildContext context) {
    return _OccupationListPage(
      title: '请选择职业类别',
      options: primaryOptions,
      onSelected: (occupation) => _selectPrimary(context, occupation),
    );
  }

  Future<void> _selectPrimary(
    BuildContext context,
    String occupation,
  ) async {
    if (occupation == '离退休人员') {
      final confirmed = await _showRetiredConfirmation(context);
      if (confirmed == true && context.mounted) {
        Navigator.pop(context, occupation);
      }
      return;
    }

    final children = secondaryOptions[occupation];
    if (children == null) {
      Navigator.pop(context, occupation);
      return;
    }

    final selected = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => UserJobOccupationSubcategoryPage(options: children),
      ),
    );
    if (selected != null && context.mounted) Navigator.pop(context, selected);
  }

  Future<bool?> _showRetiredConfirmation(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black45,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: 0.48,
        child: Material(
          key: const Key('user-job-retired-confirm-sheet'),
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 48, 18, 12),
              child: Column(
                children: [
                  const BaseText(
                    text: '提示',
                    color: Color(0xFF181818),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 28),
                  const BaseText(
                    text: '您选择的职业为离退休人员，与您的年龄可能不符，请确认您的职业是否选择正确。如您确认为离退休人员，需由工作人员进一步核实，请您携带您的有效证件以及银行卡至网点办理修改。',
                    color: Color(0xFF181818),
                    fontSize: 16,
                    height: 1.7,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(sheetContext, true),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF0075F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const BaseText(
                        text: '确定',
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UserJobOccupationSubcategoryPage extends StatelessWidget {
  const UserJobOccupationSubcategoryPage({
    super.key,
    required this.options,
  });

  final List<String> options;

  @override
  Widget build(BuildContext context) {
    return _OccupationListPage(
      title: '请选择二级子类别',
      options: options,
      onSelected: (occupation) => Navigator.pop(context, occupation),
    );
  }
}

class _OccupationListPage extends StatelessWidget {
  const _OccupationListPage({
    required this.title,
    required this.options,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF181818),
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 60.w,
        leading: IconButton(
          key: const Key('user-job-occupation-back'),
          onPressed: () => Navigator.maybePop(context),
          icon: Image(
            image: 'nav_back_light_white'.png,
            width: 29.5.w,
            height: 29.5.w,
            fit: BoxFit.contain,
          ),
        ),
        title: BaseText(
          text: title,
          color: const Color(0xFF181818),
          fontSize: 19,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: ListView.separated(
        key: Key('user-job-occupation-list-$title'),
        padding: const EdgeInsets.only(top: 12),
        itemCount: options.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          indent: 24,
          color: Color(0xFFE8E8E8),
        ),
        itemBuilder: (_, index) {
          final option = options[index];
          return Material(
            color: Colors.white,
            child: InkWell(
              onTap: () => onSelected(option),
              child: SizedBox(
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: BaseText(
                      text: option,
                      color: const Color(0xFF181818),
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
