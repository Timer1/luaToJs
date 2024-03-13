const lua_jjbx = require('./jjbx');
const lua_system = require('./system');
const lua_animation = require('./animation');
reimbursement = {};
SPECIAL_EXPLAIN_TITLE = '情况说明';
load_standingBook = function () {
    var standingBookInfoList = vt('standingBookInfoList', globalTable);
    var htmlContent = '';
    if (standingBookInfoList.length > 0) {
        var delID = vt('id', standingBookInfoList[1]);
        htmlContent = htmlContent + ('[[\n            <horiTableViewControl class=\'main_module_div2\' width=\'355\' divwidth=\'355\' divheight=\'64\' divwidth2=\'45\' value=\'0\' >\n                <div class="invoiceInfo_div" border="0" onclick="standing_book_detail(\'1\')" name="assetInfo">\n                    <label class="label_value_productName" value="招待日期\uFF1A]]' + (formatdate(2, standingBookInfoList[1].date) + ('[[" />\n                    <label class="label_value_num" value="招待地点\uFF1A]]' + (standingBookInfoList[1].location + ('[[" ></label>\n                    <label class="label_value_szxm" value="招待人数\uFF1A]]' + (standingBookInfoList[1].number + ('[[" ></label>\n                    <div class="space_10_div" border="0" />\n                </div>\n                <div class="delete_div2" border="0" onclick="delete_standing_book_alert(\']]' + (delID + '[[\')">\n                    <label class="delete_value2" value="删除" />\n                </div>\n            </horiTableViewControl>\n        ]]'))))))));
    }
    htmlContent = '[[\n        <div class="billList_div" border="0" name="standingBook_div">\n            <div class="billList_option" border="1">\n                <label class="ifRequired_css"></label>\n                <label class="label_title" value="已录入]]' + (tostring(standingBookInfoList.length) + ('[[条" />\n                <label class="label_value" value="录入台账信息" onclick="standing_book_detail(\'0\')" />\n                <img src="local:arrow_common.png" class="arrow_common_css" />\n            ]]' + htmlContent));
    if (standingBookInfoList.length > 1) {
        htmlContent = htmlContent + '[[\n            <div class="billList_inoviceList_div" border="1" onclick="jjbx_all_standing_book_relevance()">\n                <label class="label_button_findAll_css" value="查看全部" />\n            </div>\n        ]]';
    }
    htmlContent = htmlContent + '[[</div></div>]]';
    document.getElementsByName('standingBook_div')[1].setInnerHTML(htmlContent);
    page_reload();
};
standing_book_detail = function (index) {
    jjbx_getPageElementValue();
    var standingBookInfoList = vt('standingBookInfoList', globalTable);
    var standingBookInfo = '';
    if (parseFloat(index) > 0) {
        standingBookInfo = standingBookInfoList[parseFloat(index)];
    }
    var editFlag = 'look';
    var djzt = globalTable['responseBody_bzd']['bill'][1]['djzt'];
    var ifApproverEdit = vt('ifApproverEdit', globalTable);
    if (djzt === '0' || djzt === '99' || ifApproverEdit === 'true') {
        editFlag = 'edit';
    } else {
        editFlag = 'look';
    }
    invoke_page('jjbx_proccess_reimbursement_bill/xhtml/reimbursement_bill_standing_book.xhtml', page_callback, {
        standingBookInfo: standingBookInfo,
        editFlag: editFlag
    });
};
jjbx_all_standing_book_relevance = function () {
    jjbx_getPageElementValue();
    var editFlag = 'look';
    var djzt = globalTable['responseBody_bzd']['bill'][1]['djzt'];
    var ifApproverEdit = vt('ifApproverEdit', globalTable);
    if (djzt === '0' || djzt === '99' || ifApproverEdit === 'true') {
        editFlag = 'edit';
    } else {
        editFlag = 'look';
    }
    invoke_page('jjbx_proccess_reimbursement_bill/xhtml/reimbursement_bill_standing_book_relevance.xhtml', page_callback, { editFlag: editFlag });
};
query_billB = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams, {});
        ReqParams['ReqAddr'] = 'feeReim/queryBillB';
        ReqParams['ReqUrlExplain'] = '查询台账信息';
        ReqParams['BusinessCall'] = query_billB;
        var BusinessParams = {
            id: globalTable['bxd'].billBid,
            pkCorp: globalTable['responseBody_bzd']['bill'][1]['ssjgPk']
        };
        ReqParams['BusinessParams'] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    } else {
        close_loading();
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            globalTable['standingBookInfoList'] = vt('standingBookInfoList', res);
            var loadStandingBookFunc = vt('loadStandingBookFunc', globalTable);
            lua_system.do_function(loadStandingBookFunc, '');
        } else {
            alert(res['errorMsg']);
        }
    }
};
delete_bill_standing_book_info = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams, {});
        ReqParams['ReqAddr'] = 'feeReim/deleteBillStandingBookInfo';
        ReqParams['ReqUrlExplain'] = '台账信息删除';
        ReqParams['BusinessCall'] = delete_bill_standing_book_info;
        var standingBookInfoId = vt('standingBookInfoId', globalTable);
        globalTable['standingBookInfoId'] = null;
        var BusinessParams = { standingBookInfoId: standingBookInfoId };
        ReqParams['BusinessParams'] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    } else {
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            alertToast0('删除成功');
            query_billB('', {});
        } else {
            alert(res['errorMsg']);
        }
    }
};
delete_standing_book_confirm = function (index) {
    if (index === 1) {
        delete_bill_standing_book_info('', {});
    }
};
delete_standing_book_alert = function (deleteID) {
    globalTable['standingBookInfoId'] = deleteID;
    alert_confirm('温馨提示', '确认是否删除', '取消', '确认', 'delete_standing_book_confirm');
};
check_bill_standing_book_info = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams, {});
        ReqParams['ReqAddr'] = 'feeReim/checkBillStandingBookInfo';
        ReqParams['ReqUrlExplain'] = '查询是否录入台账信息';
        ReqParams['BusinessCall'] = check_bill_standing_book_info;
        var BusinessParams = {
            billBId: globalTable['bxd'].billBid,
            billNo: globalTable['responseBody_bzd']['bill'][1]['djh'],
            ywcjbm: ReqParams['ywcjbm'],
            pageType: lua_jjbx.getPageType()
        };
        ReqParams['BusinessParams'] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    } else {
        close_loading();
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            var pageConfig = vt('pageConfig', globalTable);
            globalTable['pageConfig'] = null;
            var fieldVisible = jjbx_getPageConfigDetail('standingBookInfo', pageConfig, 'fieldVisible');
            if (res['checkResult'] === '1' && fieldVisible === '1') {
                changeStyle('standingBook_div', 'display', 'block');
            } else {
                changeStyle('standingBook_div', 'display', 'none');
            }
            page_reload();
        } else {
            alert(res['errorMsg']);
        }
    }
};
qry_detail_by_jg = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams, {});
        ReqParams['ReqAddr'] = 'ruleCorrelation/qryDetailByJg';
        ReqParams['ReqUrlExplain'] = '查询当前登录机构可以使用的模板';
        ReqParams['BusinessCall'] = qry_detail_by_jg;
        var BusinessParams = {
            djlxbm: ReqParams['billTypeCode'],
            billNo: ReqParams['billNo']
        };
        ReqParams['BusinessParams'] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    } else {
        close_loading();
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            globalTable['specialExplainRules'] = vt('rules', res);
        } else {
            globalTable['specialExplainRules'] = {};
        }
    }
};
get_view_pdf_url = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams, {});
        globalTable['tempBillNo'] = ReqParams['billNo'];
        globalTable['tempBillType'] = ReqParams['billType'];
        invoke_trancode_donot_checkRepeat('jjbx_process_query', 'process_bill', {
            BusinessType: 'reimbursement_bill',
            TranCode: 'getViewPdfUrl',
            billNo: ReqParams['billNo'],
            pageType: lua_jjbx.getPageType()
        }, get_view_pdf_url, {}, all_callback, { CloseLoading: 'false' });
    } else {
        close_loading();
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            var rulesList = vt('rulesList', res);
            globalTable['rulesList'] = vt('rulesList', res);
            if (rulesList.length > 0) {
                changeStyle('drag_ctrl_ele1', 'display', 'block');
                AniSetDragArg1['DragEleNames'] = 'drag_ctrl_ele1';
                AniSetDragArg1['DragXStyleCtrl'] = '';
                AniSetDragArg1['DragYStyleCtrl'] = 'CloseToRight';
                lua_animation.set_drag_listener(AniSetDragArg1);
            } else {
                changeStyle('drag_ctrl_ele1', 'display', 'none');
            }
        } else {
            alert(res['errorMsg']);
        }
    }
};
updateStats = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams, {});
        invoke_trancode_donot_checkRepeat('jjbx_process_query', 'process_bill', {
            BusinessType: 'reimbursement_bill',
            TranCode: 'updateStats',
            billNo: ReqParams['billNo'],
            pageType: lua_jjbx.getPageType()
        }, updateStats, {}, all_callback, { CloseLoading: 'false' });
    } else {
        close_loading();
    }
};
look_special_img = function (index) {
    var i = formatNull(index, 1);
    if (i === 1) {
        var rulesList = vt('rulesList', globalTable);
        if (rulesList.length > 0) {
            invoke_page('jjbx_proccess_reimbursement_bill/xhtml/reimbursement_bill_special_explain_look.xhtml', page_callback, {});
        } else {
            alert('暂无可查看的情况说明');
        }
    }
};
update_stats = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams, {});
        ReqParams['ReqAddr'] = 'ruleCorrelation/updateStats';
        ReqParams['ReqUrlExplain'] = '更新特殊说明查看状态';
        ReqParams['BusinessCall'] = update_stats;
        var billNo = vt('tempBillNo', globalTable);
        globalTable['tempBillNo'] = null;
        var BusinessParams = {
            billNo: billNo,
            approverPk: globalTable['nodeCode']
        };
        ReqParams['BusinessParams'] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    } else {
        close_loading();
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
        } else {
        }
    }
};
module.exports = { reimbursement: reimbursement };