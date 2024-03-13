const lua_system = require('./system');
lua_service = {};
lua_service.qry_hk_budget = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ResCallBackFunc = vt('ResCallBackFunc', ReqParams);
        invoke_trancode_donot_checkRepeat('jjbx_service', 'local_service', {
            ServiceName: 'hkHospital',
            TranCode: 'getBudget'
        }, lua_service.qry_hk_budget, { ResCallBackFunc: ResCallBackFunc }, all_callback, { CloseLoading: 'false' });
    } else {
        var res = json2table(ResParams['responseBody']);
        var errorNo = vt('errorNo', res);
        var errorMsg = vt('errorMsg', res);
        var ResCallBackFunc = vt('ResCallBackFunc', ResParams);
        var remainValue = vt('remainValue', res);
        if (ResCallBackFunc != '') {
            lua_system.do_function(ResCallBackFunc, { remainValue: remainValue });
        } else {
            if (errorNo === '000000') {
                if (remainValue === '') {
                    alert('未获取到预算\uFF0C无法公司账号支付\uFF0C请联系系统管理员');
                } else {
                    if (parseFloat(remainValue) > 0) {
                        invoke_page('jjbx_local_service/hkHospital/amount_input.xhtml', page_callback, { CloseLoading: 'false' });
                    } else {
                        alert('您的公司账户余额为0\uFF0C暂不可使用');
                    }
                }
            } else {
                alert(errorMsg);
            }
        }
    }
};
lua_service.qry_hk_pay_info = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var InputAmount = formatNull(getValue('input_amount'), '0');
        invoke_trancode('jjbx_service', 'local_service', {
            ServiceName: 'hkHospital',
            TranCode: 'executeBudgetAndGetInfo',
            amount: InputAmount
        }, lua_service.qry_hk_pay_info, {}, all_callback, { CloseLoading: 'false' });
    } else {
        var res = json2table(ResParams['responseBody']);
        var errorNo = vt('errorNo', res);
        var errorMsg = vt('errorMsg', res);
        if (errorNo === '000000') {
            var QrCodeInfoRes = vt('qrCode', res);
            if (QrCodeInfoRes === '') {
                alert('付款码获取失败');
            } else {
                globalTable['hkHospitalPayQrCodeInfo'] = QrCodeInfoRes;
                globalTable['hkHospitalPayAmount'] = vt('InputAmount', res);
                invoke_page('jjbx_local_service/hkHospital/pay_qrcode.xhtml', page_callback, { CloseLoading: 'false' });
            }
        } else {
            update_budget(res);
            alert(errorMsg);
        }
    }
};
module.exports = { lua_service: lua_service };