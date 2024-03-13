const lua_system = require('./system');
const lua_page = require('./page');
const lua_ota = require('./ota');
const lua_jjbx = require('./jjbx');
const lua_animation = require('./animation');
const lua_components = require('./components');
lua_bill = {};
VERIFY_UN_CHECKED = '1';
lua_bill.save_billB = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['BusinessType'] = 'reimbursement_bill';
        ReqParams['TranCode'] = 'saveBillB';
        invoke_trancode('jjbx_process_query', 'process_bill', ReqParams, lua_bill.save_billB, { ResCallFunc: ReqParams['ResCallFunc'] }, all_callback, { CloseLoading: 'false' });
    } else {
        var res = json2table(ResParams['responseBody']);
        var errorNo = vt('errorNo', res);
        var errorMsg = vt('errorMsg', res, '保存失败');
        if (errorNo === '000000') {
            alertToast0(C_SavedMsg);
            var ResCallFunc = vt('ResCallFunc', ResParams);
            if (ResCallFunc === '') {
                back_fun_noloading();
            } else {
                lua_system.do_function(ResCallFunc);
            }
        } else {
            alert(errorMsg);
        }
    }
};
lua_bill.receiptsModelList = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        invoke_trancode_donot_checkRepeat('jjbx_process_query', 'process_bill', {
            BusinessType: 'bill_index',
            TranCode: 'ReceiptsModelList',
            billTypeCode: ReqParams['billType']
        }, lua_bill.receiptsModelList, { receiptsModelList_callBack: ReqParams['receiptsModelList_callBack'] }, all_callback, { CloseLoading: 'false' });
    } else {
        var responseBody = json2table(ResParams['responseBody']);
        if (responseBody['errorNo'] === '000000') {
            var receiptsDemoList = formatNull(responseBody['receiptsDemoList']);
            if (receiptsDemoList.length > 0) {
                globalTable['receiptsDemoList'] = receiptsDemoList;
            } else {
                globalTable['receiptsDemoList'] = {};
            }
        } else {
            globalTable['receiptsDemoList'] = {};
        }
        var CallBackFun = vt('receiptsModelList_callBack', ResParams);
        if (CallBackFun === '') {
            close_loading();
        } else {
            lua_system.do_function(CallBackFun, '');
        }
    }
};
new_reimbursement_bill = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        globalTable['ifApproverEdit'] = 'false';
        var InitReimbursementBillReqParams = {
            BusinessType: 'reimbursement_bill',
            TranCode: 'applyNewBill',
            billTypeCode: billTypeList_utils.bzd,
            billTemplateId: globalTable['modelIdList'],
            ProcessInvoiceIdListJson: ReqParams['ProcessInvoiceIdListJson']
        };
        invoke_trancode_donot_checkRepeat('jjbx_process_query', 'process_bill', InitReimbursementBillReqParams, new_reimbursement_bill, { ProcessInvoiceIdListJson: ReqParams['ProcessInvoiceIdListJson'] }, all_callback, { CloseLoading: 'false' });
    } else {
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            globalTable['responseBody_bzd'] = res;
            globalTable['billNo'] = res['bill'][1]['djh'];
            globalTable['billState_bzd'] = res['bill'][1]['djzt'];
            globalTable['pageConfig_bzd'] = res['queryConfig'];
            globalTable['bzdZDY1Name'] = formatNull(res['ZDY1Name']);
            globalTable['bzdZDY2Name'] = formatNull(res['ZDY2Name']);
            globalTable['bzdZDY3Name'] = formatNull(res['ZDY3Name']);
            globalTable['bzdZDY4Name'] = formatNull(res['ZDY4Name']);
            globalTable['bzdZDY5Name'] = formatNull(res['ZDY5Name']);
            globalTable['bzdZDY6Name'] = formatNull(res['ZDY6Name']);
            var billBs = formatNull(res['billBs'], {});
            globalTable['billBid'] = billBs[1]['id'];
            globalTable['editFlag'] = 'false';
            globalTable['szxmEnableFlag'] = 'true';
            globalTable['ywlxEnableFlag'] = 'true';
            globalTable['fjzs'] = '';
            globalTable['zdyzd'] = '';
            globalTable['firstInPage'] = 'true';
            globalTable['modelIdList'] = '';
            globalTable['temp_flag'] = 'invoice';
            invoke_page('jjbx_proccess_reimbursement_bill/xhtml/reimbursement_bill_edit.xhtml', page_callback, { CloseLoading: 'false' });
        } else {
            alert(res['errorMsg']);
        }
    }
};
lua_bill.to_bill_apply_page = function (Arg) {
    globalTable['receiptsType'] = globalTable['billType'];
    globalTable['pageType'] = 'newBill';
    globalTable['modelIdList'] = vt('modelIdList', Arg);
    var billNo = vt('billNo', Arg);
    var PageUrl = '';
    var PageCallBack = page_callback;
    var PageCallBackParams = formatNull(Arg, {});
    PageCallBackParams['CloseLoading'] = 'false';
    PageCallBackParams['billNo'] = billNo;
    if (globalTable['billType'] === billTypeList_utils.bzd) {
        globalTable['billNo'] = billNo;
        PageUrl = 'jjbx_proccess_reimbursement_bill/xhtml/reimbursement_bill_index.xhtml';
    } else if (globalTable['billType'] === billTypeList_utils.sxsq) {
        globalTable['billCode'] = billNo;
        PageUrl = 'jjbx_proccess_matter_apply_bill/xhtml/matter_apply_bill_index.xhtml';
    } else if (globalTable['billType'] === billTypeList_utils.clbx) {
        globalTable['billCode'] = billNo;
        PageUrl = 'jjbx_proccess_travel_process_bill/xhtml/travel_process_bill_index.xhtml';
    } else if (globalTable['billType'] === billTypeList_utils.jk) {
        globalTable['JKDbillNo'] = billNo;
        globalTable['if_conn_exame'] = '';
        PageUrl = 'jjbx_process_borrow_bill/xhtml/borrow_bill_index.xhtml';
    } else if (globalTable['billType'] === billTypeList_utils.hk) {
        globalTable['hkBillNo'] = billNo;
        PageUrl = 'jjbx_proccess_repayment_bill/xhtml/repayment_bill_index.xhtml';
    } else if (globalTable['billType'] === billTypeList_utils.yfkzf) {
        PageUrl = 'jjbx_proccess_pay_bill/xhtml/pay_bill_index.xhtml';
        globalTable['YFKZFbillNo'] = billNo;
        globalTable['newFlag'] = vt('newFlag', Arg, 1);
    } else {
        alert('暂不支持该单据');
        return;
    }
    if (vt('ProcessInvoiceIdListJson', Arg) != '') {
        new_reimbursement_bill('', PageCallBackParams);
    } else {
        invoke_page_donot_checkRepeat(PageUrl, PageCallBack, PageCallBackParams);
    }
};
lua_bill.select_business_scene_zdrbm = function (index) {
    lua_page.div_page_ctrl();
    globalTable['zdrbmInfo'] = globalTable['zdrbmList'][parseFloat(index)];
    var element = document.getElementsByName('zdrbm');
    if (element.length > 0) {
        changeProperty('zdrbm', 'value', globalTable['zdrbmInfo']['unitname']);
    } else {
        changeProperty('ssbm', 'value', globalTable['zdrbmInfo']['unitname']);
    }
};
lua_bill.show_zdrbm_select_page = function () {
    var zdrbmData = formatNull(globalTable['zdrbmList']);
    if (zdrbmData === '') {
        alert('无可用的制单人部门');
    } else {
        lua_page.div_page_ctrl('zdrbm_page_div', 'false', 'false');
    }
};
lua_bill.render_business_purchase_scene_zdrbm = function () {
    var zdrbmData = formatNull(globalTable['zdrbmList']);
    if (zdrbmData.length > 0) {
        var selectEleArg = {};
        for (var [key, value] in pairs(zdrbmData)) {
            var unitcode = formatNull(value['unitcode']);
            var unitname = formatNull(value['unitname']);
            var selectEleArgItem = {
                labelName: unitname,
                tipName: '',
                clickFunc: 'lua_bill.select_business_scene_zdrbm',
                clickFuncArg: tostring(key)
            };
            table.insert(selectEleArg, selectEleArgItem);
        }
        var renderSelectArg = {
            bgName: 'zdrbm_page_div',
            topEleName: 'top_zdrbm_div',
            topTitleName: '选择申请部门',
            selectEleName: 'zdrbm_list_div',
            selectEleArg: selectEleArg,
            renderCallBackFun: 'render_select_zdrbm_page_call'
        };
        lua_page.render_select_page(renderSelectArg);
    }
};
lua_bill.jjbx_getDeptInfo = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        ReqParams['BusinessType'] = 'reimbursement_bill';
        ReqParams['TranCode'] = 'getDeptInfo';
        invoke_trancode_donot_checkRepeat('jjbx_process_query', 'process_bill', ReqParams, lua_bill.jjbx_getDeptInfo, {}, all_callback, { CloseLoading: 'false' });
    } else {
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            globalTable['zdrbmList'] = res['list'];
            lua_bill.render_business_purchase_scene_zdrbm();
        } else {
            alert(res['errorMsg']);
        }
    }
};
lua_bill.to_bill_module_page = function (Arg) {
    var BillModuleManagementInstall = lua_system.check_app_func('BillModuleManagement');
    var ModulePageStyle = vt('ModulePageStyle', Arg, 'Choose');
    if (BillModuleManagementInstall === 'true') {
        var InovkePageArg = formatNull(Arg, {});
        InovkePageArg['CloseLoading'] = 'false';
        InovkePageArg['ModulePageStyle'] = ModulePageStyle;
        globalTable['modelIdList'] = '';
        invoke_page('jjbx_process_bill/xhtml/process_bill_module.xhtml', page_callback, InovkePageArg);
    } else {
        close_loading();
        var SkipVersionUpdateCallFuc = '';
        if (ModulePageStyle === 'Choose') {
            SkipVersionUpdateCallFuc = 'lua_bill.to_bill_apply_page';
        }
        var upverArg = {
            updateType: 'OPTION',
            updateMsg: '模板服务已经升级\uFF0C请更新后使用\u3002',
            SkipVersionUpdateCallFuc: SkipVersionUpdateCallFuc
        };
        lua_ota.show_upvsr_view(upverArg);
        return;
    }
};
lua_bill.reloadTemplate_to_back = function () {
    var billMenu_historyLength = vt('billMenu_historyLength', globalTable);
    if (billMenu_historyLength === '') {
        billMenu_historyLength = 0;
    }
    var thisHistory = history.length();
    var pageIndex = 0;
    var differHistory = parseFloat(thisHistory) - parseFloat(billMenu_historyLength);
    if (vt('reloadTemplate', globalTable) === 'true') {
        globalTable['reloadTemplate'] = null;
        if (differHistory > 1) {
            if (differHistory === 3) {
                pageIndex = billMenu_historyLength;
            } else {
                pageIndex = parseFloat(billMenu_historyLength) + 1;
            }
        } else {
            pageIndex = billMenu_historyLength;
        }
        back_fun_getHistory(pageIndex);
    } else {
        if (billMenu_historyLength != 0) {
            back_fun_getHistory(billMenu_historyLength);
        } else {
            back_fun();
        }
    }
};
lua_bill.query_bill_module = function (billTypeCode) {
    globalTable['billType'] = billTypeCode;
    if (billTypeCode === billTypeList_utils.bzd) {
        globalTable['pageName'] = '报账单';
    } else if (billTypeCode === billTypeList_utils.sxsq) {
        globalTable['pageName'] = '事项申请单';
    } else if (billTypeCode === billTypeList_utils.clbx) {
        globalTable['pageName'] = '差旅报销单';
    } else if (billTypeCode === billTypeList_utils.jk) {
        globalTable['pageName'] = billNameList_utils.jk;
    } else if (billTypeCode === billTypeList_utils.hk) {
        globalTable['pageName'] = '还款单';
    } else if (billTypeCode === billTypeList_utils.yfkzf) {
        globalTable['pageName'] = '应付款支付单';
    }
    lua_bill.do_query_bill_module('', {});
};
lua_bill.do_query_bill_module = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        invoke_trancode_donot_checkRepeat('jjbx_process_query', 'process_bill', {
            BusinessType: 'bill_index',
            TranCode: 'ReceiptsModelList',
            billTypeCode: globalTable['billType']
        }, lua_bill.do_query_bill_module, {}, all_callback, { CloseLoading: 'false' });
    } else {
        responseBody = json2table(ResParams['responseBody']);
        if (responseBody['errorNo'] === '000000') {
            var receiptsDemoList = vt('receiptsDemoList', responseBody);
            var receiptsDemoCounts = receiptsDemoList.length;
            var billType = vt('billType', globalTable);
            if (receiptsDemoCounts <= 0 || billType === billTypeList_utils.yfkzf || billType === billTypeList_utils.hkd) {
                lua_bill.to_bill_apply_page({});
            } else {
                globalTable['receiptsDemoList'] = receiptsDemoList;
                lua_bill.to_bill_module_page(Arg);
            }
        } else {
            jjbx_show_business_err(responseBody['errorNo'], responseBody['errorMsg']);
        }
    }
};
lua_bill.bill_check_config = function (elementName, valueType) {
    var elements = document.getElementsByName(elementName);
    var valueType = formatNull(valueType, 'string');
    if (elements.length > 0) {
        var eValue = getValue(elementName);
        if (getValue(elementName + '_required') === '*' && getStyleList(elementName + '_div', 'display')[1] === 'block') {
            if (valueType === 'select') {
                if (eValue === '请选择' || eValue === '') {
                    alert('请选择' + getValue(elementName + '_title'));
                    return 'false';
                } else {
                    return 'true';
                }
            } else if (valueType === 'number') {
                eValue = formatNull(eValue, 0);
                eValue = string.gsub(eValue, ',', '');
                if (parseFloat(eValue)) {
                    if (parseFloat(eValue) <= 0) {
                        alert('请输入' + getValue(elementName + '_title'));
                        return 'false';
                    } else {
                        return 'true';
                    }
                } else {
                    debug_alert('数据类型错误');
                    return 'false';
                }
            } else {
                if (eValue === '') {
                    alert('请输入' + getValue(elementName + '_title'));
                    return 'false';
                } else {
                    return 'true';
                }
            }
        } else {
            return 'true';
        }
    } else {
        debug_alert('元素未定义');
        return 'true';
    }
};
lua_bill.createAuthCorpTree = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        invoke_trancode_donot_checkRepeat('jjbx_service', 'app_service', ReqParams, lua_bill.createAuthCorpTree, {}, all_callback, { CloseLoading: 'false' });
    } else {
        var responseBody = json2table(ResParams['responseBody']);
        if (responseBody['errorNo'] === '000000') {
            globalTable['CompanyData'] = vt('CompanyData', responseBody);
            changeProperty('wlgsView', 'value', globalTable['CompanyData'] + '&');
        } else {
            alert(responseBody['errorMsg']);
        }
    }
};
lua_bill.check_wlgs_required = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams, {});
        ReqParams['ReqAddr'] = 'bill/common/checkWlgsRequired';
        ReqParams['ReqUrlExplain'] = '根据收支项目或借垫款类型查询是否为往来公司科目';
        ReqParams['BusinessCall'] = lua_bill.check_wlgs_required;
        var BusinessParams = {
            billNo: ReqParams['billNo'],
            fieldValueCode: ReqParams['fieldValueCode']
        };
        ReqParams['BusinessParams'] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    } else {
        close_loading();
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            if (vt('required', res) === '0') {
                changeStyle('wlgs_div', 'display', 'none');
            } else {
                var pageConfig = vt('temp_pageConfig', globalTable);
                globalTable['temp_pageConfig'] = null;
                var fieldVisible = jjbx_getPageConfigDetail('wlgs', pageConfig, 'fieldVisible');
                if (fieldVisible === '1') {
                    changeStyle('wlgs_div', 'display', 'block');
                }
            }
            page_reload();
        } else {
            alert(res['errorMsg']);
        }
    }
};
lua_bill.jjbx_doubleButton1 = function (index) {
    back_fun();
};
lua_bill.jjbx_doubleButton2 = function (index) {
    if (index === 0) {
        back_fun();
    } else {
        RobotCheckFlag = '0';
        var callFunName = vt('callFunName', globalTable);
        globalTable['callFunName'] = '';
        if (callFunName != '') {
            lua_system.do_function(callFunName, {});
        } else {
            jjbx_confirm();
        }
    }
};
lua_bill.robot_check_callBack = function (responseBody, type, callFunName) {
    var weakStr = formatNull(responseBody['weakStr'], {});
    var alertInfo_weakStr = '';
    if (weakStr.length > 0) {
        for (let i = 1; weakStr.length; i++) {
            if (weakStr.length > 1 && i != weakStr.length) {
                alertInfo_weakStr = alertInfo_weakStr + (weakStr[i] + '/');
            } else {
                alertInfo_weakStr = alertInfo_weakStr + weakStr[i];
            }
        }
    }
    var strongStr = formatNull(responseBody['strongStr'], {});
    var alertInfo_strongStr = '';
    if (strongStr.length > 0) {
        for (let i = 1; strongStr.length; i++) {
            if (strongStr.length > 1 && i != strongStr.length) {
                alertInfo_strongStr = alertInfo_strongStr + (strongStr[i] + '/');
            } else {
                alertInfo_strongStr = alertInfo_strongStr + strongStr[i];
            }
        }
    }
    var alertInfo = '';
    if (alertInfo_weakStr != '' && alertInfo_strongStr != '') {
        alertInfo = alertInfo_strongStr;
    } else {
        alertInfo = alertInfo_strongStr + ('\\n' + alertInfo_weakStr);
    }
    if (responseBody['errorNo'] === '800009') {
        alert_confirm('温馨提示', alertInfo, '', '返回', 'lua_bill.jjbx_doubleButton1');
    } else if (responseBody['errorNo'] === '800008') {
        var btnName = '继续批准';
        if (type === 'submit') {
            btnName = '继续提交';
        }
        globalTable['callFunName'] = callFunName;
        alert_confirm('温馨提示', alertInfo_weakStr, '返回', btnName, 'lua_bill.jjbx_doubleButton2');
    } else if (responseBody['errorNo'] === 'SPE001') {
        alert_confirm('温馨提示', responseBody['errorMsg'], '返回', SPECIAL_EXPLAIN_TITLE, 'look_special_img');
    } else if (responseBody['errorNo'] === 'I00999') {
        globalTable['reSubmit_agreeBill_arg'] = {
            callBackFun: callFunName,
            callBackArg: ''
        };
        alert_confirm('温馨提示', responseBody['errorMsg'], '取消', '确认', 'lua_bill.reSubmit_agreeBill');
    } else {
        alert(responseBody['errorMsg']);
    }
};
lua_bill.query_select_node = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams, {});
        ReqParams['ReqAddr'] = 'bill/common/querySelectNode';
        ReqParams['ReqUrlExplain'] = '查询审批节点';
        ReqParams['BusinessCall'] = lua_bill.query_select_node;
        var BusinessParams = { billNo: ReqParams['billNo'] };
        ReqParams['BusinessParams'] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    } else {
        close_loading();
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            globalTable['selectNodelist'] = res['selectNode'];
            globalTable['spjdFlag'] = '1';
        } else {
            globalTable['spjdFlag'] = '0';
        }
    }
};
lua_bill.query_by_billNo = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams, {});
        ReqParams['ReqAddr'] = 'bill/common/queryByBillNo';
        ReqParams['ReqUrlExplain'] = '查询单据信息';
        ReqParams['BusinessCall'] = lua_bill.query_by_billNo;
        var BusinessParams = { billNo: ReqParams['billNo'] };
        ReqParams['BusinessParams'] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    } else {
        close_loading();
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            var bill = res['bill'];
            var PCConfigListsTable = vt('PCConfigListsTable', globalTable);
            var IMG0016 = vt('IMG0016', PCConfigListsTable, '是');
            if (bill['djzt'] === '0' || bill['djzt'] === '99') {
                if (IMG0016 === '是') {
                    globalTable['downloadFlag'] = 'true';
                } else {
                    globalTable['downloadFlag'] = 'false';
                }
            } else {
                globalTable['downloadFlag'] = 'true';
            }
        } else {
        }
    }
};
lua_bill.look_warning_msg = function () {
    var billNo = vt('tempBillNo', globalTable);
    globalTable['tempBillNo'] = null;
    if (billNo != '') {
        var changeWarningFlag = vt('changeWarningFlag', globalTable);
        globalTable['changeWarningFlag'] = null;
        invoke_page('jjbx_process_bill/xhtml/process_bill_warning_msg.xhtml', page_callback, {
            billNo: billNo,
            changeWarningFlag: changeWarningFlag
        });
    }
};
lua_bill.queryWarningInfoByBillNo = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams, {});
        ReqParams['ReqAddr'] = 'warninginfo/queryWarningInfoByBillNo';
        ReqParams['ReqUrlExplain'] = '查询预警消息';
        ReqParams['BusinessCall'] = lua_bill.queryWarningInfoByBillNo;
        var BusinessParams = { billNo: ReqParams['billNo'] };
        ReqParams['BusinessParams'] = table2json(BusinessParams);
        ReqParams['ReqFuncName'] = 'invoke_trancode_noloading';
        lua_jjbx.common_req(ReqParams);
    } else {
        close_loading();
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            var infoList = vt('infoList', res);
            if (infoList.length > 0 || vt('changeWarningFlag', globalTable) === '1') {
                changeStyle('drag_ctrl_ele2', 'display', 'block');
            } else {
                changeStyle('drag_ctrl_ele2', 'display', 'none');
            }
            page_reload();
        } else {
            alert(res['errorMsg']);
        }
    }
};
lua_bill.render_warning_msg = function (warningFlag, changeWarningFlag, billNo) {
    var e = document.getElementsByName('drag_ctrl_ele2');
    if (e.length > 0 && warningFlag === '1') {
        globalTable['tempBillNo'] = billNo;
        globalTable['changeWarningFlag'] = changeWarningFlag;
        AniSetDragArg2['DragYStyleCtrl'] = 'CloseToRight';
        lua_animation.set_drag_listener(AniSetDragArg2);
        lua_bill.queryWarningInfoByBillNo('', { billNo: billNo });
    }
};
lua_bill.updReviewPoolByBillNo = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams, {});
        ReqParams['ReqAddr'] = 'shareReviewPoolIndex/updReviewPoolByBillNo';
        ReqParams['ReqUrlExplain'] = '审批驳回后回调';
        ReqParams['BusinessCall'] = lua_bill.updReviewPoolByBillNo;
        var BusinessParams = {
            billNo: ReqParams['billNo'],
            operate: ReqParams['operate']
        };
        ReqParams['BusinessParams'] = table2json(BusinessParams);
        ReqParams['ReqFuncName'] = 'invoke_trancode_noloading';
        lua_jjbx.common_req(ReqParams);
    } else {
        close_loading();
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
        } else {
        }
    }
};
lua_bill.getSupplier = function (index, Arg) {
    lua_page.div_page_ctrl();
    var supplierInfo = splitUtils(Arg, '_');
    var tempIndex = vt('tempIndex_supplierList', globalTable);
    var e = document.getElementsByName('supplierSelected');
    if (vt('gys', globalTable) === '') {
        globalTable['gys'] = {
            gys: '',
            gysbm: ''
        };
    }
    if (tempIndex != '' && supplierInfo[1] === globalTable['gys'].gysbm) {
        e[parseFloat(tempIndex)].setStyleByName('display', 'none');
        globalTable['tempIndex_supplierList'] = '';
        globalTable['gys'].gysbm = '';
        globalTable['gys'].gys = '';
        changeProperty('gys', 'value', '请选择');
    } else {
        if (tempIndex != '') {
            e[parseFloat(tempIndex)].setStyleByName('display', 'none');
        }
        e[parseFloat(index)].setStyleByName('display', 'block');
        globalTable['tempIndex_supplierList'] = index;
        globalTable['gys'].gysbm = supplierInfo[1];
        globalTable['gys'].gys = supplierInfo[2];
        changeProperty('gys', 'value', supplierInfo[2]);
    }
};
lua_bill.render_supplier_list_page = function () {
    var supplierList = {};
    if (vt('searchFlag_supplierInfo', globalTable) === 'true') {
        supplierList = vt('supplierInfoList_search', globalTable);
    } else {
        supplierList = vt('supplierInfoList', globalTable);
    }
    if (supplierList.length > 0) {
        var htmlContent = '';
        var supplierCode = '';
        var supplierName = '';
        var arg = '';
        for (var [key, value] in pairs(supplierList)) {
            supplierCode = jjbx_utils_setStringLength(value['supplierCode'], 14);
            supplierName = jjbx_utils_setStringLength(value['supplierName'], 14);
            arg = value['supplierCode'] + ('_' + value['supplierName']);
            htmlContent = htmlContent + ('[[\n                <div class="supplierInfo_div" name="supplierInfo" border="0" onclick="lua_bill.getSupplier(\']]' + (key + ('[[\',\']]' + (arg + ('[[\')" >\n                    <label class="supplierInfoCode_css" value="]]' + (supplierCode + ('[[" />\n                    <label class="supplierInfoName_css" value="]]' + (supplierName + '[[" />\n                    <img src="local:selected_round.png" class="selected_round_css" name="supplierSelected" />\n                    <line class="line_css_supplier" />\n                </div>\n            ]]'))))))));
        }
        htmlContent = '[[\n            <div class="supplierInfoList_div" border="0" name="supplierInfoList">\n        ]]' + (htmlContent + '[[\n            </div>\n        ]]');
        document.getElementsByName('supplierInfoList')[1].setInnerHTML(htmlContent);
        page_reload();
    } else {
        var htmlContent = '[[\n            <div class="supplierInfoList_div" border="0" name="supplierInfoList">\n                <img src="local:noData.png" class="supplierList_noData_img" />\n                <label class="supplierList_noData_label" value="暂无数据" />\n            </div>\n        ]]';
        document.getElementsByName('supplierInfoList')[1].setInnerHTML(htmlContent);
        page_reload();
    }
};
querySupplierInfoForBill = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams, {});
        ReqParams['ReqAddr'] = 'supplierInfoController/querySupplierInfoForBill';
        ReqParams['ReqUrlExplain'] = '查询供应商信息列表接口';
        ReqParams['BusinessCall'] = querySupplierInfoForBill;
        var BusinessParams = {
            pkCorp: vt('billPkCorp', globalTable),
            gys: ReqParams['gys']
        };
        globalTable['billPkCorp'] = '';
        ReqParams['BusinessParams'] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    } else {
        close_loading();
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            globalTable['supplierInfoList'] = vt('supplierInfoList', res, {});
            lua_bill.render_supplier_list_page('show');
        }
    }
};
searchSupplierName = function () {
    var supplierName = getValue('top_search_text');
    if (supplierName != '') {
        querySupplierInfoForBill('', { gys: supplierName });
    } else {
        alert('请输入供应商名称');
    }
};
lua_bill.initSupplierInfo = function (pkCorp) {
    globalTable['billPkCorp'] = pkCorp;
    height_adapt('supplierInfoList');
    var htmlContent = '[[\n        <div class="supplierInfoList_div" border="0" name="supplierInfoList">\n            <img src="local:noData.png" class="supplierList_noData_img" />\n            <label class="supplierList_noData_label" value="暂无数据" />\n        </div>\n    ]]';
    document.getElementsByName('supplierInfoList')[1].setInnerHTML(htmlContent);
    height_adapt('gys_page', 0, 0);
    create_page_title('lua_page.div_page_ctrl()', 'search_bar', '供应商名称', '', 'label_bar', '搜索', 'searchSupplierName()', 'top_supplier_div');
};
lua_bill.initErrorCallBack = function (index) {
    if (parseFloat(index) === 1) {
        back_fun();
    }
};
lua_bill.qryAbnormalExpByBillNoForApp = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        ReqParams['ReqAddr'] = 'bt/expDetails/qryAbnormalExpByBillNoForApp';
        ReqParams['ReqUrlExplain'] = '新建行程报销单校验';
        ReqParams['BusinessCall'] = lua_bill.qryAbnormalExpByBillNoForApp;
        var BusinessParams = { djh: ReqParams['billNo'] };
        ReqParams['BusinessParams'] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    } else {
        var responseBody = json2table(ResParams['responseBody']);
        if (responseBody['errorNo'] === 'AB0004') {
            alert_confirm('温馨提示', responseBody['errorMsg'], '', '确定', 'lua_bill.initErrorCallBack');
        } else {
            if (document.getElementsByName('btn_content_div').length > 0) {
                changeStyle('btn_content_div', 'display', 'block');
            }
        }
    }
};
lua_bill.querySkrInfoByInvoiceForApp = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams, {});
        ReqParams['ReqAddr'] = 'bill/common/querySkrInfoByInvoiceForApp';
        ReqParams['ReqUrlExplain'] = '据单据关联的增值税发票获取收款人信息';
        ReqParams['BusinessCall'] = lua_bill.querySkrInfoByInvoiceForApp;
        var BusinessParams = { billNo: ReqParams['billNo'] };
        ReqParams['BusinessParams'] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    } else {
        close_loading();
        forPayeePsnforAppCallBack(ResParams);
    }
};
lua_bill.queryBusibillP = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        ReqParams['ReqAddr'] = 'bill/common/queryBusibillP';
        ReqParams['ReqUrlExplain'] = '查询结算详情信息';
        ReqParams['BusinessCall'] = lua_bill.queryBusibillP;
        var BusinessParams = { billPId: ReqParams['billPId'] };
        ReqParams['BusinessParams'] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    } else {
        close_loading();
        var responseBody = json2table(ResParams['responseBody']);
        if (responseBody['errorNo'] === '000000') {
            var billPs = responseBody['billPs'];
            if (billPs.length > 0) {
                var billp = billPs[1];
                var skzh = vt('skzh', billp);
                if (skzh != '') {
                    globalTable['jsd']['skzh'] = skzh;
                    changeProperty('skzh', 'value', skzh);
                }
                var qbmc = vt('qbmc', billp);
                var e = document.getElementsByName('qbmc');
                if (e.length > 0) {
                    changeProperty('qbmc', 'value', qbmc);
                }
                e = document.getElementsByName('zhbs_div');
                if (e.length > 0) {
                    var zhbsbm = vt('zhbsbm', billp);
                    lua_components.set_radio_select(zhbsbm, 'accountType', 'getZHBS');
                }
            }
        } else {
            alert(responseBody['errorMsg']);
        }
        jjbx_initPage(globalTable['jsd']);
    }
};
lua_bill.getSelectValue = function (index, Arg) {
    lua_page.div_page_ctrl();
    var selectInfo = splitUtils(Arg, '_');
    var selectValue = vt('temp_select_value', globalTable);
    var e = '';
    if (selectInfo.length > 2) {
        e = document.getElementsByName(selectInfo[3]);
    } else {
        e = document.getElementsByName('selected');
    }
    if (selectValue != '') {
        if (selectInfo[2] === selectValue) {
            e[parseFloat(index)].setStyleByName('display', 'none');
            globalTable['temp_select_value'] = '';
            return '';
        } else {
            for (let i = 1; e.length; i++) {
                if (i === parseFloat(index)) {
                    e[parseFloat(i)].setStyleByName('display', 'block');
                } else {
                    e[parseFloat(i)].setStyleByName('display', 'none');
                }
            }
            globalTable['temp_select_value'] = selectInfo[2];
            return selectInfo;
        }
    } else {
        e[parseFloat(index)].setStyleByName('display', 'block');
        globalTable['temp_select_value'] = selectInfo[2];
        return selectInfo;
    }
};
lua_bill.getZdsy = function (index, arg) {
    var selectInfo = lua_bill.getSelectValue(index, arg);
    if (selectInfo != '') {
        globalTable['bxd'].zdsybm = selectInfo[1];
        globalTable['bxd'].zdsy = selectInfo[2];
        changeProperty('zdsy', 'value', selectInfo[2]);
    } else {
        globalTable['bxd'].zdsybm = '';
        globalTable['bxd'].zdsy = '';
        changeProperty('zdsy', 'value', '请选择');
    }
};
lua_bill.getJddx = function (index, arg) {
    var selectInfo = lua_bill.getSelectValue(index, arg);
    if (selectInfo != '') {
        globalTable['bxd'].jddxbm = selectInfo[1];
        globalTable['bxd'].jddx = selectInfo[2];
        changeProperty('jddx', 'value', selectInfo[2]);
    } else {
        globalTable['bxd'].jddxbm = '';
        globalTable['bxd'].jddx = '';
        changeProperty('jddx', 'value', '请选择');
    }
};
lua_bill.countRJXF = function () {
    var bxje = formatNull(getValue('bxje'), 0);
    var zdjsje = formatNull(getValue('zdjsje'), 0);
    var khrs = formatNull(getValue('khrs'), 0);
    var ptrs = formatNull(getValue('ptrs'), 0);
    var rjxf = 0;
    if (parseFloat(bxje) + parseFloat(zdjsje) > 0 && parseFloat(ptrs) + parseFloat(khrs) > 0) {
        rjxf = (parseFloat(bxje) + parseFloat(zdjsje)) / (parseFloat(ptrs) + parseFloat(khrs));
        rjxf = formatMoney(rjxf);
        changeProperty('rjxf', 'value', rjxf);
    } else {
        changeProperty('rjxf', 'value', '0.00');
    }
};
lua_bill.query_bill_config = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        ReqParams['ReqAddr'] = 'billConfig/queryConfigApp';
        ReqParams['ReqUrlExplain'] = '单据配置查询';
        ReqParams['BusinessCall'] = lua_bill.query_bill_config;
        var queryBillConfigParams = {
            billType: ReqParams['billType'],
            pageType: ReqParams['pageType'],
            orgFlag: ReqParams['orgFlag']
        };
        ReqParams['BusinessParams'] = table2json(queryBillConfigParams);
        lua_jjbx.common_req(ReqParams);
    } else {
        var responseBody = json2table(ResParams['responseBody']);
        if (responseBody['errorNo'] === '000000') {
            var list = vt('list', responseBody);
            var ResCallFunc = vt('ResCallFunc', ResParams);
            if (ResCallFunc != '') {
                lua_system.do_function(ResCallFunc, list);
            } else {
                jjbx_utils_reloadPageElement(list);
            }
        } else {
            alert(responseBody['errorMsg']);
        }
    }
};
lua_bill.getRegistrationListByBill = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams, {});
        ReqParams['ReqAddr'] = 'busibillRegistration/getRegistrationListByBill';
        ReqParams['ReqUrlExplain'] = '根据单据号查询已关联的登记单';
        ReqParams['BusinessCall'] = lua_bill.getRegistrationListByBill;
        globalTable['jjdj_billNo'] = ReqParams['djh'];
        var BusinessParams = { djh: ReqParams['djh'] };
        ReqParams['BusinessParams'] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    } else {
        close_loading();
        var add_menu_list = vt('addMenuList', globalTable, {});
        globalTable['addMenuList'] = null;
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            var registrationList = vt('registrationList', res);
            if (registrationList.length > 0) {
                var t = {
                    menu_name: '交接登记',
                    menu_click: 'lua_page.top_right_menu_router(\'jjdj\')',
                    menu_icon: 'menu_bar_edit.png'
                };
                table.insert(add_menu_list, t);
            }
        }
        lua_page.render_bill_top_right_menu(add_menu_list);
    }
};
lua_bill.to_jjdj_list = function () {
    invoke_page('jjbx_process_bill/xhtml/process_bill_jjdj_list.xhtml', page_callback, {});
};
lua_bill.reSubmit_agreeBill = function (index) {
    if (index === 1) {
        VERIFY_UN_CHECKED = '0';
        var reSubmitAgreeBillArg = vt('reSubmit_agreeBill_arg', globalTable);
        globalTable['reSubmit_agreeBill_arg'] = null;
        var callBackFun = vt('callBackFun', reSubmitAgreeBillArg);
        if (callBackFun != '') {
            var callBackArg = vt('callBackArg', reSubmitAgreeBillArg);
            lua_system.do_function(callBackFun, callBackArg);
        } else {
            debug_alert('回调方法未定义');
        }
    }
};
module.exports = { lua_bill: lua_bill };