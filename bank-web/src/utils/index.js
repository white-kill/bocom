import store from '../store'
import router from '../router'

const sendMessageToFlutter = (message) => {
    if (window.FlutterBridge) {
        window.FlutterBridge.postMessage({
            action: 'showMessage',
            message: message
        });
    }
}
const remToPx = (rem) => {
    let fontSize = document.documentElement.style.fontSize
    return Math.floor(rem * fontSize.replace('px', ''))
}

const pxToRem = (px) => {
    let fontSize = document.documentElement.style.fontSize
    return px / fontSize.replace('px', '')
}
const formatAmount = (amount) => { //将数字格式化为每三位用逗号分隔：
    if (amount === 0) {
        return amount
    }
    if (!amount) return
    let [integerPart, decimalPart] = amount.toString().split('.'); // 拆分整数部分和小数部分
    integerPart = integerPart.replace(/\B(?=(\d{3})+(?!\d))/g, ','); // 给整数部分每三位添加逗号
    return decimalPart ? `${integerPart}.${decimalPart}` : integerPart; // 如果有小数部分，重新拼接
}
export {
    sendMessageToFlutter, remToPx, pxToRem, formatAmount
}
