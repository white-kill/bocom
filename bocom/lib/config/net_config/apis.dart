class Apis {
  static const login = '/auth/api/login';

  ///用户信息
  static const memberInfo = '/serviceboc/member/info';

  ///查询明细
  static const billPage = '/serviceboc/bill/page';

  ///分页获取收支账单列表
  static const pagePayment = '/serviceboc/bill/pagePayment';

  ///获取收支范围账单列表
  static const pageRangePayment = '/serviceboc/bill/pageRangePayment';

  ///获取收支关键字账单列表
  static const pageKeyWordPayment = '/serviceboc/bill/pageKeyWordPayment';

  ///联系人列表
  static const contactsList = '/serviceboc/contacts/list';

  ///银行列表
  static const bankList = '/serviceboc/bank/list';

  ///查询转账列表
  static const transferPage = '/serviceboc/bill/transferPage';

  ///银行卡转账
  static const transfer = '/serviceboc/bill/transfer';

  ///分页查询账单打印申请列表
  static const applyPageList = '/serviceboc/flowExport/applyPage';

  ///账单信息打印
  static const print = '/serviceboc/flowExport/print';

}
