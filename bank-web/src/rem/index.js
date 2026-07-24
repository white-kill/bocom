import RemFit from '../assets/js/rem-fit'
const remFit = new RemFit(7.5, false)
remFit.init()
window.addEventListener('resize', () => {
    remFit.init()
})
