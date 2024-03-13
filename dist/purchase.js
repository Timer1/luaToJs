const lua_system = require('./system');
const lua_page_list = require('./page_list');
const lua_format = require('./format');
const lua_page = require('./page');
const lua_jjbx = require('./jjbx');
lua_purchase = {};
PARLQArg = {
    qryFlag: '',
    qryStartDate: '',
    qryEndDate: '',
    qryDateFlag: '',
    qryDateFlagName: '',
    qryBillStatusFlag: '',
    qryBillStatusName: ''
};
POLQArg = {
    qryOrderTypeFlag: '',
    qryOrderTypeName: '',
    qryOrderStatusFlag: '',
    qryOrderStatusName: '',
    qryOrderSortFlag: '',
    qryOrderSortName: ''
};
Visit_EjyH5_ErrorMsg = '获取商城地址失败';
lua_purchase.order_status_name = function (StatusCode) {
    var StatusName = '';
    if (StatusCode === '1') {
        StatusName = '';
    } else if (StatusCode === '2') {
        StatusName = '待审批';
    } else if (StatusCode === '3') {
        StatusName = '待付款';
    } else if (StatusCode === '4') {
        StatusName = '待收货';
    } else if (StatusCode === '5') {
        StatusName = '已完成';
    } else if (StatusCode === '6') {
        StatusName = '已取消';
    } else if (StatusCode === '7') {
        StatusName = '退款中';
    } else if (StatusCode === '8') {
        StatusName = '已退款';
    }
    return StatusName;
};
lua_purchase.order_status_pic = function (StatusName) {
    var StatusPicName = '';
    if (StatusName === '待审批') {
        StatusPicName = 'order_status_dsp.png';
    } else if (StatusName === '待付款') {
        StatusPicName = 'order_status_dfk.png';
    } else if (StatusName === '待收货') {
        StatusPicName = 'order_status_dsh.png';
    } else if (StatusName === '已完成') {
        StatusPicName = 'order_status_ywc.png';
    } else if (StatusName === '已取消') {
        StatusPicName = 'order_status_yqx.png';
    } else if (StatusName === '退款中') {
        StatusPicName = 'order_status_tkz.png';
    } else if (StatusName === '已退款') {
        StatusPicName = 'order_status_ytk.png';
    } else {
        StatusPicName = '';
    }
    return StatusPicName;
};
lua_purchase.apply_status_name = function (StatusCode) {
    var StatusName = '';
    if (StatusCode === '1') {
        StatusName = '待提交';
    } else if (StatusCode === '2') {
        StatusName = '审批中';
    } else if (StatusCode === '3') {
        StatusName = '待支付';
    } else if (StatusCode === '4') {
        StatusName = '已支付';
    } else if (StatusCode === '5') {
        StatusName = '已失效';
    } else if (StatusCode === '6') {
        StatusName = '审批失败';
    } else if (StatusCode === '7') {
        StatusName = '超时失效';
    } else {
        StatusName = '状态未知';
    }
    return StatusName;
};
lua_purchase.arg_init_qry = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        if (vt('PurchaseQueryConfig1', companyTable) === '') {
            ReqParams['QryConfig1'] = 'true';
        }
        if (vt('PurchaseQueryConfig2', companyTable) === '') {
            ReqParams['QryConfig2'] = 'true';
        }
        if (vt('PurchaseQueryConfig3', companyTable) === '') {
            ReqParams['QryConfig3'] = 'true';
        }
        ReqParams['TranCode'] = 'ArgInitQry';
        invoke_trancode_donot_checkRepeat('jjbx_service', 'online_shopping', ReqParams, lua_purchase.arg_init_qry, {}, all_callback, { CloseLoading: 'false' });
    } else {
        var res = json2table(ResParams['responseBody']);
        if (vt('QryConfig1', res) === 'true') {
            companyTable['PurchaseQueryConfig1'] = vt('queryConfig1', res);
        }
        if (vt('QryConfig2', res) === 'true') {
            companyTable['PurchaseQueryConfig2'] = vt('queryConfig2', res);
        }
        if (vt('QryConfig3', res) === 'true') {
            companyTable['PurchaseQueryConfig3'] = vt('queryConfig3', res);
        }
        globalTable['PurchaseBusinessRuleData'] = vt('PurchaseBusinessRuleData', res);
        var InitCallFun = vt('InitCallFun', res);
        lua_system.do_function(InitCallFun, '');
    }
};
lua_purchase.page_router = function (PageName, RouterArg) {
    var PageUrl = '';
    if (PageName === 'index') {
        PageUrl = 'index.xhtml';
    } else if (PageName === 'apply') {
        PageUrl = 'apply.xhtml';
    } else if (PageName === 'apply_edit') {
        PageUrl = 'apply_edit.xhtml';
    } else if (PageName === 'apply_detail') {
        PageUrl = 'apply_detail.xhtml';
    } else if (PageName === 'apply_success') {
        PageUrl = 'apply_success.xhtml';
    } else if (PageName === 'apply_record_list') {
        PageUrl = 'apply_record_list.xhtml';
        lua_page_list.init_qry_arg('purchase_apply_record_list');
        lua_format.reset_table(PARLQArg);
    } else if (PageName === 'apply_record_invalid_list') {
        PageUrl = 'apply_record_invalid_list.xhtml';
        lua_page_list.init_qry_arg('purchase_apply_invalid_record_list');
        lua_format.reset_table(PARLQArg);
    } else if (PageName === 'assets_card_edit') {
        PageUrl = 'assets_card_edit.xhtml';
    } else if (PageName === 'assets_card_look') {
        PageUrl = 'assets_card_look.xhtml';
    } else if (PageName === 'assets_card_info') {
        PageUrl = 'assets_card_info.xhtml';
    } else if (PageName === 'order_detail_business') {
        PageUrl = 'order_detail_business.xhtml';
    } else if (PageName === 'order_detail_personal') {
        PageUrl = 'order_detail_personal.xhtml';
    } else if (PageName === 'order_list') {
        PageUrl = 'order_list.xhtml';
        lua_page_list.init_qry_arg('purchase_order_list');
        lua_format.reset_table(POLQArg);
    } else if (PageName === 'personal_rule_list') {
        PageUrl = 'personal_rule_list.xhtml';
    } else if (PageName === 'category_goods_info') {
        PageUrl = 'category_goods_info.xhtml';
    } else if (PageName === 'category_goods_info_look') {
        PageUrl = 'category_goods_info_look.xhtml';
    } else if (PageName === 'ask_info') {
        PageUrl = 'ask_info.xhtml';
    } else {
        alertToast1('页面异常');
    }
    if (PageUrl != '') {
        var RouterArg = formatNull(RouterArg, {});
        RouterArg['CloseLoading'] = vt('CloseLoading', RouterArg, 'false');
        invoke_page('jjbx_online_shopping' + ('/' + PageUrl), page_callback, RouterArg);
    }
};
lua_purchase.to_assets_card_info_page = function (CallArgEncodeStr) {
    var CallArgEncodeStr = formatNull(CallArgEncodeStr);
    var CallArgDecodeStr = lua_format.base64_decode(CallArgEncodeStr);
    var CallArg = json2table(CallArgDecodeStr);
    lua_purchase.page_router('assets_card_info', CallArg);
};
lua_purchase.show_status_counts = function (CountsNum) {
    var CountsNum = parseFloat(CountsNum);
    if (type(CountsNum) != 'number') {
        return '';
    } else {
        if (CountsNum > 99) {
            return '(99+)';
        } else if (CountsNum != 0) {
            return '(' + (CountsNum + ')');
        } else {
            return '';
        }
    }
};
lua_purchase.show_ywcj_select_page = function () {
    var ywcjData = formatNull(companyTable['PurchaseYWCJData']);
    var element = document.getElementsByName('cgzd');
    var cgzd = '';
    if (element.length > 0) {
        cgzd = getValue('cgzd');
    }
    if (cgzd === '请选择') {
        alert('请选择采购制度');
    } else if (ywcjData === '') {
        alert('当前无可用业务场景\uFF0C请更换采购制度');
    } else if (globalTable['ifApproverEdit'] === 'true') {
        lua_page.div_page_ctrl('ywcj_page_div', 'true', 'false');
    } else if (formatNull(globalTable['onlineShopping_initParams'].flag) === '1') {
        alert('采购申请单的所有商品需在24h内下单\uFF0C超过时间无法下单');
    } else {
        lua_page.div_page_ctrl('ywcj_page_div', 'true', 'false');
    }
};
lua_purchase.select_business_scene = function (params) {
    if (formatNull(params, '') != '') {
        lua_page.div_page_ctrl();
        var codeAndName = splitUtils(params, ',');
        var ywcjbm = '';
        var ywcj = '';
        var listLen = codeAndName.length;
        for (let i = 1; listLen; i++) {
            if (i != listLen) {
                if (i === listLen - 1) {
                    ywcjbm = codeAndName[i];
                }
            } else {
                ywcj = codeAndName[i];
            }
        }
        var element = document.getElementsByName('ywlx');
        if (element.length > 0) {
            changeProperty('ywlx', 'value', ywlx);
        }
        var selectedYWCJList = formatNull(globalTable['onlineShopping_initParams'].selectedYWCJList, {});
        var flag = 'false';
        if (formatNull(globalTable['ifApproverEdit'], 'false') != 'true') {
            for (var [k, v] in pairs(selectedYWCJList)) {
                if (ywcjbm === v['ywcjbm']) {
                    flag = 'true';
                    break;
                }
            }
        }
        if (flag === 'false' || formatNull(globalTable['ifApproverEdit'], 'false') === 'true') {
            globalTable['onlineShopping_initParams'].businessScenarios = ywcjbm;
            globalTable['onlineShopping_initParams'].businessScenariosName = ywcj;
            for (var [key, value] in pairs(companyTable['PurchaseYWCJData'])) {
                if (ywcjbm === value['businessScenarios']) {
                    globalTable['onlineShopping_initParams'].idpurchaseInstitutionCategory = value['idpurchaseInstitutionCategory'];
                    break;
                }
            }
            var reqParams = {
                purchaseBillNo: globalTable['onlineShopping_initParams']['purchaseBillNo'],
                businessScenarios: ywcjbm,
                businessScenariosName: ywcj,
                idpurchaseInstitutionCategory: globalTable['onlineShopping_initParams'].idpurchaseInstitutionCategory
            };
            if (formatNull(globalTable['ifApproverEdit'], 'false') != 'true') {
                onlineShopping_newBillB('', reqParams);
            } else {
                qryBusinessScenarioForBFY('', {
                    businessScenarios: globalTable['onlineShopping_initParams'].businessScenarios,
                    flag: 'change'
                });
            }
        } else {
            alert(ywcj + '已存在\uFF0C不可重复添加\uFF0C请重新选择');
        }
    }
};
lua_purchase.show_cgzd_select_page = function () {
    var cgzdData = formatNull(globalTable['PurchaseBusinessRuleData']);
    if (cgzdData === '') {
        alert('无可用的采购制度');
    } else {
        lua_page.div_page_ctrl('cgzd_page_div', 'false', 'false');
    }
};
createContentTreeListForApp = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        ReqParams['TranCode'] = 'createContentTreeListForApp';
        ReqParams['filecode'] = 'FIN-010';
        ReqParams['applyBillTypeCode'] = billTypeList_utils.cgsq_new;
        ReqParams['pkCorp'] = globalTable['onlineShopping_initParams'].pkCorp;
        invoke_trancode_donot_checkRepeat('jjbx_service', 'online_shopping', ReqParams, createContentTreeListForApp, {}, all_callback, { CloseLoading: 'true' });
    } else {
        var responseBody = json2table(ResParams['responseBody']);
        globalTable['ywcjList'] = table2json(vt('list', responseBody));
        if (responseBody['errorNo'] === '000000') {
            changeProperty('bxcjView', 'value', globalTable['ywcjList']);
        } else {
            alert(responseBody['errorMsg']);
        }
    }
};
lua_purchase.select_business_scene_cgzd = function (index, flag) {
    var flag = formatNull(flag);
    if (flag === '') {
        lua_page.div_page_ctrl();
    }
    if (formatNull(index) != '') {
        var cgzdData = formatNull(globalTable['PurchaseBusinessRuleData']);
        if (cgzdData != '') {
            var cgzdDataLen = cgzdData.length;
            var codeList = '';
            for (let i = 1; cgzdDataLen; i++) {
                if (i === parseFloat(index)) {
                    if (globalTable['onlineShopping_initParams'].institutionName != '' && globalTable['onlineShopping_initParams'].idpurchaseInstitution != vt('idpurchaseInstitution', cgzdData[i])) {
                        deleteCgAllBillBId('', {});
                    }
                    globalTable['onlineShopping_initParams'].institutionName = vt('institutionName', cgzdData[i]);
                    globalTable['onlineShopping_initParams'].institutionCode = vt('institutionCode', cgzdData[i]);
                    globalTable['onlineShopping_initParams'].idpurchaseInstitution = vt('idpurchaseInstitution', cgzdData[i]);
                    globalTable['onlineShopping_initParams'].confirmOrder = vt('confirmOrder', cgzdData[i]);
                    globalTable['onlineShopping_initParams'].maintenanceCard = vt('maintenanceCard', cgzdData[i]);
                    globalTable['onlineShopping_initParams'].maintenanceCardLimit = vt('maintenanceCardLimit', cgzdData[i]);
                    companyTable['PurchaseYWCJData'] = formatNull(vt('businessScenariosList', cgzdData[i]), {});
                    for (var [key, value] in pairs(companyTable['PurchaseYWCJData'])) {
                        if (key === companyTable['PurchaseYWCJData'].length) {
                            codeList = codeList + value['businessScenarios'];
                        } else {
                            codeList = codeList + (value['businessScenarios'] + ',');
                        }
                    }
                    break;
                }
            }
            if (codeList === '') {
                alert('当前制度下无可用采购场景\uFF0C请重新选择');
            } else {
                changeProperty('cgzd', 'value', globalTable['onlineShopping_initParams'].institutionName);
                var setCGZDSelectArg = { showIndex: index };
                lua_page.set_item_selected(setCGZDSelectArg);
                createContentTreeListForApp('', { contentcode: codeList });
            }
        } else {
            alert('无可用的采购制度');
        }
    } else {
        alert('无可用的采购制度');
    }
};
lua_purchase.render_business_purchase_scene_cgzd = function () {
    var cgzdData = formatNull(globalTable['PurchaseBusinessRuleData']);
    var cgzdDataCounts = cgzdData.length;
    if (cgzdDataCounts > 0) {
        var selectEleArg = {};
        for (var [key, value] in pairs(cgzdData)) {
            var institutionCode = formatNull(value['institutionCode']);
            var institutionName = formatNull(value['institutionName']);
            var institutionMarks = formatNull(value['remarks']);
            var selectEleArgItem = {
                labelName: institutionName,
                tipName: institutionMarks,
                clickFunc: 'lua_purchase.select_business_scene_cgzd',
                clickFuncArg: tostring(key)
            };
            table.insert(selectEleArg, selectEleArgItem);
        }
        var renderSelectArg = {
            bgName: 'cgzd_page_div',
            topEleName: 'top_cgzd_div',
            topTitleName: '选择采购制度',
            selectEleName: 'cgzd_list_div',
            selectEleArg: selectEleArg,
            renderCallBackFun: 'onlineShopping_render_select_cgzd_page_call'
        };
        lua_page.render_select_page(renderSelectArg);
    }
    close_loading();
};
lua_purchase.render_order_pic_list_html = function (Data, OnclickFun) {
    var Data = formatNull(Data);
    var OnclickFun = formatNull(OnclickFun);
    var res = '';
    var orderId = vt('orderId', Data);
    var goodsPrice = vt('goodsPrice', Data);
    var goodsNum = vt('goodsNum', Data);
    var goodsInfo = vt('orderGoodsOut', Data);
    var goodsInfoCounts = goodsInfo.length;
    var order_pic_items_html = '';
    for (let i = 1; goodsInfoCounts; i++) {
        var goodsItemData = formatNull(goodsInfo[i]);
        var className = 'px_order_pic_item' + (tostring(i) + '_div');
        if (i > 4) {
            order_pic_items_html = order_pic_items_html + ('[[\n                <div class="]]' + (className + '[[" border="0" />\n            ]]'));
            break;
        } else {
            var picUrl = lua_purchase.order_pic_link_prepare(vt('pic', goodsItemData));
            order_pic_items_html = order_pic_items_html + ('[[\n                <div class="]]' + (className + ('[[" border="0">\n                    <imageView width="50" height="50" class="px_order_pic_image" radius="0" value="]]' + (picUrl + '[[" />\n                </div>\n            ]]'))));
        }
    }
    res = '[[\n        <div class="px_order_div" border="0">\n            <label class="px_order_id_label" value="]]' + (orderId + ('[[" />\n            <div class="px_order_pic_list_div" border="0">\n                ]]' + (order_pic_items_html + ('[[\n                <div class="px_order_list_info_div" border="0" onclick="]]' + (OnclickFun + ('[[">\n                    <label class="px_order_counts_label" value="共]]' + (goodsNum + ('[[件" />\n                    <label class="px_order_price_label" value="\xA5 ]]' + (goodsPrice + '[[" />\n                    <img src="local:arrow_common.png" class="px_order_info_arrow" />\n                </div>\n            </div>\n        </div>\n    ]]')))))))));
    return res;
};
lua_purchase.update_apply_status_counts_label = function (Data) {
    var dtjText = '待提交' + lua_purchase.show_status_counts(vt('dtjNum', Data));
    changeProperty('b_status_dtj_label', 'value', dtjText);
    var shzText = '审批中' + lua_purchase.show_status_counts(vt('shzNum', Data));
    changeProperty('b_status_shz_label', 'value', shzText);
    var dzfText = '待支付' + lua_purchase.show_status_counts(vt('dzfNum', Data));
    changeProperty('b_status_dzf_label', 'value', dzfText);
    var yzfText = '已支付' + lua_purchase.show_status_counts(vt('yzfNum', Data));
    changeProperty('b_status_yzf_label', 'value', yzfText);
    var res = {
        dtjText: dtjText,
        shzText: shzText,
        dzfText: dzfText,
        yzfText: yzfText
    };
    return res;
};
lua_purchase.get_login_url = function (ResParams, ReqParams) {
    var UserRiskCheckMsg = vt('UserRiskCheckMsg', globalTable);
    if (UserRiskCheckMsg != '') {
        alert(UserRiskCheckMsg);
    } else {
        if (formatNull(ResParams) === '') {
            var ReqParams = formatNull(ReqParams);
            ReqParams['TranCode'] = 'GetPurchaseLoginUrl';
            var ResCallFunc = vt('ResCallFunc', ReqParams);
            invoke_trancode_donot_checkRepeat('jjbx_service', 'online_shopping', ReqParams, lua_purchase.get_login_url, { ResCallFunc: ResCallFunc }, all_callback, { CloseLoading: 'false' });
        } else {
            var res = json2table(ResParams['responseBody']);
            var errorNo = vt('errorNo', res);
            var errorMsg = vt('errorMsg', res);
            var ResCallFunc = vt('ResCallFunc', ResParams);
            lua_system.do_function(ResCallFunc, res);
        }
    }
};
lua_purchase.order_pic_link_prepare = function (oldUrl) {
    var AppEnvironment = vt('AppEnvironment', systemTable);
    var PublicNetHost = vt('PublicNetHost', systemTable);
    var newUrl = '';
    if (oldUrl != '') {
        if (string.find(oldUrl, 'http')) {
            newUrl = oldUrl;
        } else {
            if (AppEnvironment === 'dev' || AppEnvironment === 'sit') {
                if (PublicNetHost === 'true') {
                    newUrl = 'http://sccs.ejyshop.com';
                } else {
                    newUrl = 'http://203.3.236.162:8100';
                }
            } else if (AppEnvironment === 'uat') {
                if (PublicNetHost === 'true') {
                    newUrl = 'http://scyz.ejyshop.com';
                } else {
                    newUrl = 'http://x-sitemeshop.verify.com';
                }
            } else {
                newUrl = 'https://x-site.ejyshop.com';
            }
        }
        if (oldUrl != newUrl) {
            newUrl = newUrl + oldUrl;
        }
    } else {
        newUrl = '';
    }
    return newUrl;
};
lua_purchase.order_pay = function (ResParams, ReqParams) {
    lua_page.div_page_ctrl();
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['TranCode'] = 'PurchaseOrderPay';
        var ResCallFunc = vt('ResCallFunc', ReqParams);
        invoke_trancode_donot_checkRepeat('jjbx_service', 'online_shopping', ReqParams, lua_purchase.order_pay, { ResCallFunc: ResCallFunc }, all_callback, { CloseLoading: 'false' });
    } else {
        var res = json2table(vt('responseBody', ResParams));
        var ResCallFunc = vt('ResCallFunc', ResParams);
        var ResCallArg = vt('ResCallArg', ResParams);
        var errorNo = vt('errorNo', res);
        var errorMsg = vt('errorMsg', res, '支付失败');
        if (errorNo === '000000') {
            close_loading();
            var ResCallFunc = vt('ResCallFunc', ResParams);
            lua_system.do_function(ResCallFunc, res);
        } else {
            alert(errorMsg);
        }
    }
};
lua_purchase.qry_relate_order = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['TranCode'] = 'QryOrderListByApplyId';
        var ResCallFunc = vt('ResCallFunc', ReqParams);
        invoke_trancode_donot_checkRepeat('jjbx_service', 'online_shopping', ReqParams, lua_purchase.qry_relate_order, { ResCallFunc: ResCallFunc }, all_callback, { CloseLoading: 'false' });
    } else {
        var res = json2table(ResParams['responseBody']);
        var errorNo = vt('errorNo', res);
        var errorMsg = vt('errorMsg', res);
        var ReqBillNo = vt('ReqBillNo', res);
        if (errorNo === '000000') {
            var ResCallFunc = vt('ResCallFunc', ResParams);
            lua_system.do_function(ResCallFunc, res);
        } else {
            alert(errorMsg);
        }
    }
};
lua_purchase.qryCgGoodsList = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        var ResCallFunc = vt('ResCallFunc', ReqParams);
        ReqParams['TranCode'] = 'qryCgGoodsList';
        invoke_trancode_donot_checkRepeat('jjbx_service', 'online_shopping', ReqParams, lua_purchase.qryCgGoodsList, { ResCallFunc: ResCallFunc }, all_callback, { CloseLoading: 'false' });
    } else {
        var res = json2table(vt('responseBody', ResParams));
        var ResCallFunc = vt('ResCallFunc', ResParams);
        var ResCallArg = vt('ResCallArg', ResParams);
        var errorNo = vt('errorNo', res);
        var errorMsg = vt('errorMsg', res);
        if (errorNo != '000000') {
            alert(errorMsg);
        }
        var ResCallFunc = vt('ResCallFunc', ResParams);
        lua_system.do_function(ResCallFunc, res);
    }
};
lua_purchase.to_jd_order_list = function () {
    globalTable['queryAllOrder_params'] = {
        TranCode: 'getJdOrderFlow',
        pageNum: '1',
        pageSize: '10',
        listIndex: '1',
        screenType: 'welfare',
        welfareIndex: '1',
        statusIndex: '1',
        descIndex: '1',
        orderType: '',
        orderStatus: '0',
        sord: ''
    };
    invoke_page('jjbx_online_shopping/xhtml/onlineShopping_allOrder.xhtml', page_callback, { CloseLoading: 'false' });
};
lua_purchase.debug_to_jdcg = function () {
    invoke_page('jjbx_online_shopping/xhtml/onlineShopping_home.xhtml', page_callback, RouterArg);
};
lua_purchase.debug_to_ejycg = function () {
    lua_purchase.page_router('index');
};
lua_purchase.to_order_detail = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['ReqAddr'] = 'purchaseReq/fetchOrderUrl';
        ReqParams['ReqUrlExplain'] = '获取商城订单详情链接';
        ReqParams.BusinessCall = lua_purchase.to_order_detail;
        lua_jjbx.common_req(ReqParams);
    } else {
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            if (vt('url', res) != '') {
                close_loading();
                lua_system.alert_webview({
                    title: '订单详情',
                    visit_url: res['url'],
                    back_type: 'BACK',
                    close_call_func: 'order_list_h5_close_call'
                });
            } else {
                alert(Visit_EjyH5_ErrorMsg);
            }
        } else {
            alert(res['errorMsg']);
        }
    }
};
lua_purchase.to_order_logistics = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['ReqAddr'] = 'purchaseReq/fetchOrderItemUrl';
        ReqParams['ReqUrlExplain'] = '获取商城订单物流链接';
        ReqParams.BusinessCall = lua_purchase.to_order_logistics;
        lua_jjbx.common_req(ReqParams);
    } else {
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            if (vt('url', res) != '') {
                close_loading();
                lua_system.alert_webview({
                    title: '物流详情',
                    visit_url: res['url'],
                    back_type: 'BACK'
                });
            } else {
                alert(Visit_EjyH5_ErrorMsg);
            }
        } else {
            alert(res['errorMsg']);
        }
    }
};
lua_purchase.to_order_refund_detail = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['ReqAddr'] = 'purchaseReq/fetchReturnOrderListUrl';
        ReqParams['ReqUrlExplain'] = '获取商城订单退款详情链接';
        ReqParams.BusinessCall = lua_purchase.to_order_refund_detail;
        lua_jjbx.common_req(ReqParams);
    } else {
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            if (vt('url', res) != '') {
                close_loading();
                lua_system.alert_webview({
                    title: '退货退款',
                    visit_url: res['url'],
                    back_type: 'BACK'
                });
            } else {
                alert(Visit_EjyH5_ErrorMsg);
            }
        } else {
            alert(res['errorMsg']);
        }
    }
};
lua_purchase.reset_onlineShopping_initParams = function () {
    globalTable['onlineShopping_initParams'] = {
        purchaseBillNo: '',
        selectedYWCJList: {},
        cgsy: '',
        institutionName: '',
        institutionCode: '',
        idpurchaseInstitution: '',
        businessScenarios: '',
        businessScenariosName: '',
        idpurchaseInstitutionCategory: '',
        confirmOrder: '',
        maintenanceCard: '',
        maintenanceCardLimit: ''
    };
};
lua_purchase.purchase_msg_call = function (CallArgEncodeStr) {
    var CallArgEncodeStr = formatNull(CallArgEncodeStr);
    var CallArgDecodeStr = lua_format.base64_decode(CallArgEncodeStr);
    var CallArg = json2table(CallArgDecodeStr);
    var orderId = vt('orderId', CallArg);
    var messageSubclassEn = vt('messageSubclassEn', CallArg);
    if (messageSubclassEn === 'ImproveAssertCardInformation') {
        lua_purchase.page_router('order_list', { QryOrderId: orderId });
    } else if (messageSubclassEn === 'CgPaymentAlertBusi') {
        lua_purchase.page_router('apply_record_list', { PurchaseApplyRecordInitStatusCode: '3' });
    } else if (messageSubclassEn === 'CgPaymentAlertWelfare') {
        lua_purchase.page_router('order_list', { QryOrderId: orderId });
    }
};
lua_purchase.qryReviewUser = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['ReqAddr'] = 'purchaseReq/qryReviewUser';
        ReqParams['ReqUrlExplain'] = '采购申请补录查询复核人';
        ReqParams['BusinessParams'] = table2json(ReqParams['BusinessParams']);
        ReqParams['CloseLoading'] = 'false';
        ReqParams['BusinessCall'] = lua_purchase.qryReviewUser;
        lua_jjbx.common_req(ReqParams);
    } else {
        var res = json2table(ResParams['responseBody']);
        var BusinessParamsJson = json2table(vt('BusinessParamsJson', res));
        if (res['errorNo'] === '000000') {
            var BusinessParams = {
                reviewerCode: vt('reviewerCode', res),
                reviewerPk: vt('reviewerPk', res),
                reviewer: vt('reviewer', res),
                djh: vt('djh', BusinessParamsJson)
            };
            lua_purchase.supplySubmit('', { BusinessParams: BusinessParams });
        } else {
            alert(res['errorMsg']);
        }
    }
};
lua_purchase.supplySubmit = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['ReqAddr'] = 'purchaseReq/supplySubmit';
        ReqParams['ReqUrlExplain'] = '采购申请单补录提交';
        ReqParams['BusinessParams'] = table2json(ReqParams['BusinessParams']);
        ReqParams['BusinessCall'] = lua_purchase.supplySubmit;
        lua_jjbx.common_req(ReqParams);
    } else {
        close_loading();
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            alertToast('0', C_CommitMsg, '', 'back_fun', '');
        } else {
            alert(res['errorMsg']);
        }
    }
};
module.exports = { lua_purchase: lua_purchase };