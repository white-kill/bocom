import request from '../utils/request'

const getWxUserInfo = (params = {}) =>
    request.post(`/serviceboc/member/info`, params)


const login = (params = {}) =>
    request.post(`/auth/api/login`, params)

const getBillAnalysis = (params = {}) =>
    request.get(`/serviceboc/bill/analysis`, {params})
const getMonthBillList = (params = {}) =>
    request.get(`/serviceboc/bill/monthBillList`, {params})
const getBillCategoryList = (params = {}) =>
    request.get(`/serviceboc/bill/categoryList`, {params})
const getBillCategory = (params = {}) =>
    request.get(`/serviceboc/bill/monthBill`, {params})
export {
    getWxUserInfo, login, getBillAnalysis, getMonthBillList, getBillCategoryList,getBillCategory
}
