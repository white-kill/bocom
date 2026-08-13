class Apis {
  static const login = '/auth/api/login';

  ///用户信息
  static const memberInfo = '/servicecomm/member/info';

  ///查询明细
  static const billPage = '/servicecomm/bill/page';

  ///分页获取收支账单列表
  static const pagePayment = '/servicecomm/bill/pagePayment';

  ///获取收支范围账单列表
  static const pageRangePayment = '/servicecomm/bill/pageRangePayment';

  ///获取收支关键字账单列表
  static const pageKeyWordPayment = '/servicecomm/bill/pageKeyWordPayment';

  ///联系人列表
  static const contactsList = '/servicecomm/contacts/list';

  ///银行列表
  static const bankList = '/servicecomm/bank/list';

  ///查询转账列表
  static const transferPage = '/servicecomm/bill/transferPage';

  ///银行卡转账
  static const transfer = '/servicecomm/bill/transfer';

  ///单笔账单详情
  static const billDetail = '/serviceboc/bill/detail';

  ///分页查询账单打印申请列表
  static const applyPageList = '/servicecomm/flowExport/applyPage';

  ///账单信息打印
  static const print = '/servicecomm/flowExport/print';

  // 账本总览
  static const bookOverView = '/servicecomm/bill/book/overview';

  // 明细流水
  static const bookDetailPage = '/servicecomm/bill/book/detailPage';

  // 账本分析
  static const bookAnalysis = '/servicecomm/bill/book/analysis';

  // 账本分析全部分类
  static const bookAnalysisCategoryList =
      '/servicecomm/bill/book/analysis/categoryList';
}
