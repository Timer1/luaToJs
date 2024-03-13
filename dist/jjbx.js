const lua_system = require('./system');
const lua_format = require('./format');
const lua_login = require('./login');
const lua_page = require('./page');
const lua_travel = require('./travel');
const lua_purchase = require('./purchase');
const lua_ota = require('./ota');
const lua_upload = require('./upload');
const lua_form = require('./form');
const lua_menu = require('./menu');
lua_jjbx = {};
lua_jjbx.init = function () {
    systemTable['invoiceTypeList'] = lua_system.select_widget_parent_data(C_invoiceTypeList);
    var LoadLoginArg = {};
    var ClientRegisterMissionArg = get_db_value('ClientRegisterMissionArg');
    if (ClientRegisterMissionArg != '') {
        var CommonLogRegisterArg = {
            LogExplain: '极简报销系统打开时候\uFF0C已经被注册的客户端任务',
            LogInfo: ClientRegisterMissionArg
        };
        lua_jjbx.common_log_register('', CommonLogRegisterArg);
        var missionArg = lua_format.url_decode(ClientRegisterMissionArg);
        var ArgObj = json2table(missionArg);
        var MissionType = vt('MissionType', ArgObj);
        var JJBXAppLoginToken = vt('JJBXAppLoginToken', ArgObj);
        if (MissionType === 'ToBudgetPageOpenByOtherApp' && JJBXAppLoginToken != '') {
            debug_alert('其他APP通过PC认证后\uFF0C使用token登录极简报销并进行后续操作' + foreach_arg2print(ArgObj));
            LoadLoginArg['JJBXAppLoginToken'] = JJBXAppLoginToken;
        }
    }
    lua_login.load_login(LoadLoginArg);
};
lua_jjbx.arg_init_after_login = function (resParams) {
    companyTable['ArgInitAfterLoginFlag'] = 'true';
    if (formatNull(resParams) === '') {
        invoke_trancode_donot_checkRepeat('jjbx_service', 'app_service', { TranCode: 'QrySysArg' }, lua_jjbx.arg_init_after_login, {}, all_callback, { CloseLoading: 'false' });
    } else {
        var res = json2table(resParams['responseBody']);
        var JJBXAnnualEventUrl = vt('JJBXAnnualEventUrl', res);
        globalTable['JJBXAnnualEventUrl'] = JJBXAnnualEventUrl;
        lua_jjbx.arg_init_after_login_call();
    }
};
lua_jjbx.arg_init_after_login_call = function () {
    close_loading();
};
jjbx_checkTagEnableToApprover_js = function (elementName) {
    var pageConfig = globalTable['pageConfig_jsmx'];
    var fieldName = '';
    var enableFlag = 'false';
    for (var [key, value] in pairs(pageConfig)) {
        fieldName = value['fieldAppId'];
        fieldName = splitUtils(fieldName, '_')[1];
        if (fieldName === elementName && value['modelType'] === '3' && value['editable'] === '1') {
            enableFlag = 'true';
            break;
        }
    }
    return enableFlag;
};
changeEditStateByPageConfigToJsmx = function (type) {
    var pageConfig = globalTable['pageConfig_jsmx'];
    for (let i = 1; pageConfig.length; i++) {
        if (pageConfig[i]['modelType'] === '3') {
            var fieldAppId = pageConfig[i]['fieldAppId'];
            var fieldName = string.gsub(fieldAppId, '_div', '');
            if (pageConfig[i]['editable'] === '0') {
                changeProperty(fieldName, 'enable', 'false');
                if (fieldName === 'jsfs') {
                    changeStyle('jsfs_img', 'display', 'none');
                    changeStyle('jsfs', 'right', '13px');
                }
                if (fieldName === 'skr') {
                    if (type === 'xjzf') {
                        changeProperty('xjzf_skr', 'enable', 'false');
                        changeStyle('xjzf_skr_img', 'display', 'none');
                    } else {
                        changeStyle('skr_img', 'display', 'none');
                        changeStyle('skr', 'right', '13px');
                    }
                }
                if (fieldName === 'khyh') {
                    changeStyle('khyh_img', 'display', 'none');
                    changeStyle('khyh', 'right', '13px');
                }
                if (fieldName === 'je') {
                    if (type === 'zxzf') {
                        changeProperty('zfje', 'enable', 'false');
                    } else if (type === 'zjgc') {
                        changeProperty('zjgc_zfje', 'enable', 'false');
                        changeStyle('zjgc_img', 'display', 'none');
                    } else if (type === 'xjzf') {
                        changeProperty('xjzf_zfje', 'enable', 'false');
                    } else if (type === 'gyf') {
                        changeProperty('gyf_zfje', 'enable', 'false');
                    } else if (type === 'cjk') {
                        changeProperty('cjk_zfje', 'enable', 'false');
                        changeStyle('cjk_img', 'display', 'none');
                    }
                }
            }
        }
    }
};
jjbx_utils_reloadPageElement = function (pageConfig, modelType) {
    var debug_alert_msg = '根据配置加载\uFF1A\\n';
    var modelType = formatNull(modelType);
    var pageConfig = formatNull(pageConfig, {});
    for (var [key, value] in pairs(pageConfig)) {
        var DoLoop = 'true';
        if (modelType != '') {
            if (value['modelType'] != modelType) {
                DoLoop = 'false';
            }
        }
        if (value['modelType'] === '2' && value['fieldName'] === 'zdy2') {
            globalTable['zdy2Title'] = value['fieldDispName'];
            globalTable['zdy2Display'] = value['fieldVisible'];
        }
        if (DoLoop === 'true') {
            var fieldAppId = formatNull(value['fieldAppId']);
            fieldAppId = string.gsub(fieldAppId, '_div', '');
            var divEleName = fieldAppId + '_div';
            var displayFlag = formatNull(value['fieldVisible'], '1');
            var requiredFlag = formatNull(value['fieldRequired'], '0');
            var labelValue = formatNull(value['fieldDispName']);
            var devEleObj = formatNull(document.getElementsByName(divEleName)[1]);
            var elementName = formatNull(splitUtils(divEleName, '_')[1]);
            var labelEleName = elementName + '_title';
            var RequiredEleName = elementName + '_required';
            var RequiredEleValue = '';
            if (devEleObj != '' && elementName != '') {
                if (displayFlag === '1') {
                    show_ele(divEleName);
                    changeProperty(labelEleName, 'value', labelValue);
                    if (requiredFlag === '1') {
                        RequiredEleValue = '*';
                    } else {
                        RequiredEleValue = '';
                    }
                    changeProperty(RequiredEleName, 'value', RequiredEleValue);
                } else {
                    hide_ele(divEleName);
                    changeProperty(RequiredEleName, 'value', '');
                }
            }
            debug_alert_msg = debug_alert_msg + ('fieldAppId:' + (fieldAppId + ('\\n' + ('displayFlag:' + (displayFlag + ('\\n' + ('divEleName:' + (divEleName + ('\\n' + ('requiredFlag:' + (requiredFlag + ('\\n' + ('RequiredEleName:' + (RequiredEleName + ('\\n' + ('labelEleName:' + (labelEleName + ('\\n' + ('labelValue:' + (labelValue + ('\\n' + '\\n')))))))))))))))))))));
        }
    }
};
jjbx_show_business_err = function (errcode, errmsg) {
    close_loading();
    if (errcode != 'SKIP_ErrorNo') {
        alert(errmsg);
    }
};
to_jiesuan = function (responseBodyBill, jsdData) {
    history.clear(1);
    var params = {
        responseBodyBill: responseBodyBill,
        JumpStyle: 'none',
        AddPage: 'true',
        JsdData: jsdData
    };
    if (string.find(globalTable['jsd'].jsfsbm, 'FIN%-011%-1')) {
        invoke_page_noloading_checkRepeat('jjbx_process_bill/xhtml/process_bill_jiesuan_xjzf.xhtml', page_callback, params);
    } else if (string.find(globalTable['jsd'].jsfsbm, 'FIN%-011%-203')) {
        globalTable['jsd'].zfje = '';
        params['CloseLoading'] = 'false';
        invoke_page('jjbx_process_bill/xhtml/process_bill_jiesuan_zjgc.xhtml', page_callback, params);
    } else if (string.find(globalTable['jsd'].jsfsbm, 'FIN%-011%-202')) {
        globalTable['jsd'].zfje = '';
        params['CloseLoading'] = 'false';
        invoke_page('jjbx_process_bill/xhtml/process_bill_jiesuan_cjk.xhtml', page_callback, params);
    } else if (string.find(globalTable['jsd'].jsfsbm, 'FIN%-011%-0')) {
        invoke_page_noloading_checkRepeat('jjbx_process_bill/xhtml/process_bill_jiesuan_zxzf.xhtml', page_callback, params);
    } else if (string.find(globalTable['jsfsbmDetail'], 'FIN%-011%-201')) {
        invoke_page_noloading_checkRepeat('jjbx_process_bill/xhtml/process_bill_jiesuan_gyf.xhtml', page_callback, params);
    } else {
        invoke_page_noloading_checkRepeat('jjbx_process_bill/xhtml/process_bill_jiesuan_other.xhtml', page_callback, params);
    }
};
to_jiesuan2 = function (responseBodyBill, jsdData) {
    if (globalTable['ifEditBillP'] === 'false') {
        invoke_page('jjbx_process_bill/xhtml/process_bill_jiesuan_zxzf.xhtml', page_callback, {
            responseBodyBill: responseBodyBill,
            JsdData: jsdData
        });
    } else {
        if (string.find(globalTable['jsd'].jsfsbm, 'FIN%-011%-1')) {
            invoke_page('jjbx_process_bill/xhtml/process_bill_jiesuan_xjzf.xhtml', page_callback, {
                responseBodyBill: responseBodyBill,
                JsdData: jsdData
            });
        } else if (string.find(globalTable['jsd'].jsfsbm, 'FIN%-011%-203')) {
            invoke_page('jjbx_process_bill/xhtml/process_bill_jiesuan_zjgc.xhtml', page_callback, {
                AddPage: 'true',
                CloseLoading: 'false',
                responseBodyBill: responseBodyBill,
                JsdData: jsdData
            });
        } else if (string.find(globalTable['jsd'].jsfsbm, 'FIN%-011%-202')) {
            invoke_page('jjbx_process_bill/xhtml/process_bill_jiesuan_cjk.xhtml', page_callback, {
                AddPage: 'true',
                CloseLoading: 'false',
                responseBodyBill: responseBodyBill,
                JsdData: jsdData
            });
        } else if (string.find(globalTable['jsd'].jsfsbm, 'FIN%-011%-0')) {
            invoke_page('jjbx_process_bill/xhtml/process_bill_jiesuan_zxzf.xhtml', page_callback, {
                responseBodyBill: responseBodyBill,
                JsdData: jsdData
            });
        } else if (string.find(formatNull(globalTable['jsfsbmDetail'], ''), 'FIN%-011%-201')) {
            invoke_page('jjbx_process_bill/xhtml/process_bill_jiesuan_gyf.xhtml', page_callback, {
                responseBodyBill: responseBodyBill,
                JsdData: jsdData
            });
        } else {
            invoke_page('jjbx_process_bill/xhtml/process_bill_jiesuan_other.xhtml', page_callback, {
                responseBodyBill: responseBodyBill,
                JsdData: jsdData
            });
        }
    }
};
to_jiesuan_look = function (pageConfig, responseBodyBill, jsdData) {
    var fileCode = '';
    globalTable['pageConfig_jsmx'] = pageConfig;
    var pageConfig = formatNull(pageConfig, globalTable['pageConfig']);
    globalTable['pageConfig'] = formatNull(globalTable['pageConfig'], pageConfig);
    for (var [key, value] in pairs(pageConfig)) {
        if (value['fieldAppId'] === 'zdy2_div') {
            fileCode = value['fileCode'];
            break;
        }
    }
    globalTable['fileCode'] = fileCode;
    invoke_trancode_donot_checkRepeat('jjbx_process_query', 'process_bill', {
        BusinessType: 'bill_index',
        TranCode: 'InitAddJieSuanInfo',
        billType: globalTable['receiptsType'],
        fileCode: fileCode,
        ifEditBillP: globalTable['ifEditBillP'],
        jsfsbm: globalTable['jsd'].jsfsbm,
        pkCorp: globalTable['pkCorp']
    }, initAddJieSuanInfoCallBack, {
        flag: 'look',
        responseBodyBill: responseBodyBill,
        jsdData: jsdData
    });
};
initAddJieSuanInfoCallBack = function (params) {
    var responseBody = json2table(params['responseBody']);
    var responseBodyBill = params['responseBodyBill'];
    if (responseBody['billDictQueryList'].length < 1) {
        alert('无可选择的结算方式');
        return;
    }
    var djlxbm = vt('receiptsType', globalTable);
    var bill = '';
    if (responseBodyBill['bill'].length > 0) {
        bill = responseBodyBill['bill'][1];
    } else {
        bill = responseBodyBill['bill'];
    }
    djlxbm = vt('djlxbm', bill);
    if (vt('ifApproverEdit', globalTable) === 'true' && djlxbm === billTypeList_utils.bzd) {
    } else {
        globalTable['jsfsList'] = responseBody['billDictQueryList'];
    }
    globalTable['zdyList2'] = responseBody['zdyList'];
    if (globalTable['ifEditBillP'] === 'false') {
        globalTable['jsd'].billPid = responseBody['billPId'];
    } else {
    }
    globalTable['jsfsbmDetail'] = formatNull(responseBody['jsfsbm2']['supContent'], '');
    globalTable['gyf_zfje'] = '';
    globalTable['cjk_zfje'] = '请选择';
    globalTable['zjgc_zfje'] = '请选择';
    var jsdData = params['jsdData'];
    if (params['flag'] === 'look') {
        if (string.find(globalTable['jsd'].jsfsbm, 'FIN%-011%-202')) {
            invoke_page('jjbx_process_bill/xhtml/process_bill_jiesuan_cjk_look.xhtml', page_callback, {
                AddPage: 'true',
                CloseLoading: 'false',
                responseBodyBill: responseBodyBill,
                JsdData: jsdData
            });
        } else if (string.find(globalTable['jsd'].jsfsbm, 'FIN%-011%-203')) {
            invoke_page('jjbx_process_bill/xhtml/process_bill_jiesuan_zjgc_look.xhtml', page_callback, {
                AddPage: 'true',
                CloseLoading: 'false',
                responseBodyBill: responseBodyBill,
                JsdData: jsdData
            });
        } else {
            invoke_page('jjbx_process_bill/xhtml/process_bill_jiesuan_look.xhtml', page_callback, {
                responseBodyBill: responseBodyBill,
                JsdData: jsdData
            });
        }
    } else {
        to_jiesuan2(responseBodyBill, jsdData);
    }
};
initJieSuan = function (pageConfig, responseBodyBill, jsdData) {
    var fileCode = '';
    globalTable['pageConfig_jsmx'] = pageConfig;
    var pageConfig = formatNull(pageConfig, globalTable['pageConfig']);
    globalTable['pageConfig'] = formatNull(globalTable['pageConfig'], pageConfig);
    for (var [key, value] in pairs(pageConfig)) {
        if (value['fieldAppId'] === 'zdy2_div') {
            fileCode = value['fileCode'];
            break;
        }
    }
    globalTable['fileCode'] = fileCode;
    var bill = vt('bill', responseBodyBill);
    globalTable['billSource'] = responseBodyBill['bill'][1]['billSource'];
    if (globalTable['ifEditBillP'] === 'false' || globalTable['jsfsbmDetail'] === null) {
        var editFlag = '';
        if (jsdData['sy'] === '往来确认') {
            editFlag = 'look';
        } else {
            editFlag = 'edit';
        }
        invoke_trancode_donot_checkRepeat('jjbx_process_query', 'process_bill', {
            BusinessType: 'bill_index',
            TranCode: 'InitAddJieSuanInfo',
            billType: globalTable['receiptsType'],
            fileCode: fileCode,
            ifEditBillP: globalTable['ifEditBillP'],
            jsfsbm: globalTable['jsd'].jsfsbm,
            pkCorp: globalTable['pkCorp']
        }, initAddJieSuanInfoCallBack, {
            flag: editFlag,
            responseBodyBill: responseBodyBill,
            jsdData: jsdData
        });
    } else {
        if (jsdData['sy'] === '往来确认') {
            if (string.find(jsdData.jsfsbm, 'FIN%-011%-202')) {
                invoke_page('jjbx_process_bill/xhtml/process_bill_jiesuan_cjk_look.xhtml', page_callback, {
                    AddPage: 'true',
                    CloseLoading: 'false',
                    responseBodyBill: responseBodyBill,
                    JsdData: jsdData
                });
            } else if (string.find(jsdData.jsfsbm, 'FIN%-011%-203')) {
                invoke_page('jjbx_process_bill/xhtml/process_bill_jiesuan_zjgc_look.xhtml', page_callback, {
                    AddPage: 'true',
                    CloseLoading: 'false',
                    responseBodyBill: responseBodyBill,
                    JsdData: jsdData
                });
            } else {
                invoke_page('jjbx_process_bill/xhtml/process_bill_jiesuan_look.xhtml', page_callback, {
                    responseBodyBill: responseBodyBill,
                    JsdData: jsdData
                });
            }
        } else {
            to_jiesuan2(responseBodyBill, jsdData);
        }
    }
};
jjbx_getJSFSValue = function (params) {
    if (formatNull(params, '') === '') {
        alert('请选择结算方式');
        return;
    }
    globalTable['jsfsbmDetail'] = params;
    jjbx_utils_hideContent();
    var codeAndName = splitUtils(params, ',');
    var jsfstree = '';
    var jsfsbm = '';
    var jsfs = '';
    var listLen = codeAndName.length;
    for (let i = 1; listLen; i++) {
        if (i != listLen) {
            if (jsfstree === '') {
                jsfstree = codeAndName[i];
            } else {
                jsfstree = jsfstree + (',' + codeAndName[i]);
            }
            if (i === listLen - 1) {
                jsfsbm = codeAndName[i];
            }
        } else {
            jsfs = codeAndName[i];
        }
    }
    globalTable['jsd'].jsfs = jsfs;
    globalTable['jsd'].jsfsbm = jsfsbm;
    getContent();
    var CurrentPageInfo = lua_page.current_page_info();
    var responseBody = vt('responseBodyBill', CurrentPageInfo);
    var jsdData = vt('jsdData', CurrentPageInfo);
    to_jiesuan(responseBody, jsdData);
};
orderTypeIsIncludes = function (orderTypeList, orderType) {
    var orderTypeList = orderTypeList;
    var includFlag = 'fasle';
    for (let i = 1; orderTypeList.length; i++) {
        if (orderType === orderTypeList[i]) {
            includFlag = 'true';
            break;
        }
    }
    return includFlag;
};
jjbx_formatSPLC = function (splcStatus, opinion) {
    if (splcStatus === 'right') {
        if (opinion === '提交申请') {
            return '已提交';
        } else {
            return '已批准';
        }
    } else if (splcStatus === 'close') {
        return '已驳回';
    } else if (splcStatus === 'point') {
        if (opinion === '待提交') {
            return '待提交';
        } else if (opinion === '待回复') {
            return '待回复';
        } else {
            return '审批中';
        }
    } else if (splcStatus === 'more') {
        return '待审批';
    } else if (splcStatus === 'end') {
        return '流程结束';
    } else if (splcStatus === 'slash') {
        return '流程强制结束';
    } else if (splcStatus === 'void') {
        return '单据作废';
    } else if (splcStatus === 'revoke') {
        return '已撤回';
    } else if (splcStatus === 'turn') {
        return '已转办';
    } else if (splcStatus === 'reply') {
        return '已回复';
    } else if (splcStatus === 'turnBack') {
        return '撤回转办';
    } else if (splcStatus === 'handover') {
        return '移交';
    } else {
        return '未定义';
    }
};
jjbx_utils_checkTagEnableToApprover = function (tagName, config) {
    var pageConfig = formatNull(formatNull(config, globalTable['pageConfig']), {});
    var fieldName = '';
    var enableFlag = 'false';
    for (var [key, value] in pairs(pageConfig)) {
        fieldName = value['fieldAppId'];
        fieldName = splitUtils(fieldName, '_')[1];
        if (fieldName === tagName) {
            if (formatNull(value['editable'], '') != '1') {
                changeProperty(fieldName, 'enable', 'false');
            } else {
                enableFlag = 'true';
                changeProperty(fieldName, 'enable', 'true');
            }
            break;
        }
    }
    if (vt('ifApproverEdit', globalTable) === 'true') {
        return enableFlag;
    } else {
        return 'true';
    }
};
setoperate_text_labelTimeRight = function () {
    var elements = document.getElementsByName('operate_stop_time_label');
    var elementValue = elements[1].getPropertyByName('value');
    if (elementValue != '') {
        var valueLen = ryt.getLengthByStr(elementValue);
        var elementWidth = parseFloat(valueLen) * 8;
        elements[1].setStyleByName('width', tostring(elementWidth) + 'px');
        var selfElment = document.getElementsByName('operate_text_label');
        selfElment[1].setStyleByName('right', tostring(elementWidth) + 'px');
        page_reload();
    }
};
show_SMS_alertMsg = function (mobileNo) {
    alert('验证码已发送至手机尾号' + string.sub(mobileNo, string.len(mobileNo) - 3, string.len(mobileNo)));
};
apply_order = function (applicationNo) {
    var TravelChannelFlag = globalTable['TravelChannelFlag'];
    if (TravelChannelFlag.length > 0) {
        invoke_page('jjbx_travel_service/xhtml/travel_service_channel.xhtml', page_callback, {
            CloseLoading: 'fasle',
            flag: '0',
            billNo: applicationNo
        });
    } else {
        alert(ApplyTravelChannelCheckMsg);
    }
};
apply_menu_click = function (reserve_type) {
    init_travel_reserve_h5_page(reserve_type);
};
init_travel_reserve_h5_page = function (reserve_type) {
    var UserRiskCheckMsg = vt('UserRiskCheckMsg', globalTable);
    if (UserRiskCheckMsg != '') {
        alert(UserRiskCheckMsg);
    } else {
        globalTable['webView_reserve_type'] = reserve_type;
        var TravelChannelFlag = globalTable['TravelChannelFlag'];
        if (reserve_type === 'xiecheng') {
            var flag = 'false';
            for (let i = 1; TravelChannelFlag.length; i++) {
                if (parseFloat(TravelChannelFlag[i]) === 1) {
                    flag = 'true';
                    break;
                }
            }
            if (flag === 'true') {
                globalTable['webview_back2jjbx'] = '返回极简';
                globalTable['isShowBackBut'] = 'false';
                invoke_trancode('jjbx_page', 'webview_page', {
                    TranCode: 'InitXCReservelUrl',
                    pkCorp: globalTable['selectOrgList'][1]['pkCorp']
                }, to_reserve_h5_page, {});
            } else {
                alert(ApplyTravelChannelXieChengCheckMsg);
            }
        } else if (reserve_type === 'tongcheng') {
            var flag = 'false';
            for (let i = 1; TravelChannelFlag.length; i++) {
                if (parseFloat(TravelChannelFlag[i]) === 2) {
                    flag = 'true';
                    break;
                }
            }
            if (flag === 'true') {
                globalTable['isShowBackBut'] = 'true';
                invoke_trancode('jjbx_page', 'webview_page', {
                    TranCode: 'InitTCReservelUrl',
                    tripappno: globalTable['select_tripNo']
                }, to_reserve_h5_page, {});
            } else {
                alert(ApplyTravelChannelTongchengCheckMsg);
            }
        } else if (reserve_type === 'aLi') {
            var flag = 'false';
            for (let i = 1; TravelChannelFlag.length; i++) {
                if (parseFloat(TravelChannelFlag[i]) === 3) {
                    flag = 'true';
                    break;
                }
            }
            if (flag === 'true') {
                invoke_trancode('jjbx_page', 'webview_page', {
                    TranCode: 'InitALiReserveUrl',
                    tripappno: globalTable['select_tripNo']
                }, to_reserve_h5_page, {});
            } else {
                alert(ApplyTravelChannelALiCheckMsg);
            }
        } else {
            alert('不支持的预订渠道\u3002');
        }
    }
};
to_reserve_h5_page = function (params) {
    var jsonData = params['responseBody'];
    var responseBody = json2table(params['responseBody']);
    if (responseBody['errorNo'] === '000000') {
        globalTable['select_tripNo'] = '';
        globalTable['toReserveH5ResponseBody'] = responseBody;
        if (vt('promptFlag', responseBody) === '0') {
            var labelStyleCss = 'style=\'font-size: 14px;\'';
            var divStyleCss = 'style=\'left: 20px; width: 275px;\'';
            lua_format.split_str('', {
                str: vt('promptInf', responseBody),
                labelStyleCss: labelStyleCss,
                divStyleCss: divStyleCss,
                elementName: 'alertTextDiv'
            });
            changeStyle('alert_page', 'display', 'block');
        } else {
            lua_jjbx.to_reserve_h5_page('', '', '');
        }
    } else {
        jjbx_show_business_err(responseBody['errorNo'], responseBody['errorMsg']);
    }
};
lua_jjbx.to_reserve_h5_page = function (sureFlag, checkFlag, responseBody) {
    var responseBody = globalTable['toReserveH5ResponseBody'];
    if (parseFloat(formatNull(checkFlag, '0')) === 1) {
        if (globalTable['webView_reserve_type'] === 'xiecheng') {
            lua_travel.update_tip_status('', {
                flag: '8',
                value: responseBody['promptInf']
            });
        } else if (globalTable['webView_reserve_type'] === 'tongcheng') {
            lua_travel.update_tip_status('', {
                flag: '9',
                value: responseBody['promptInf']
            });
        } else {
            lua_travel.update_tip_status('', {
                flag: '7',
                value: responseBody['promptInf']
            });
        }
    }
    globalTable['webview_url'] = formatNull(responseBody['webview_url']);
    globalTable['webview_page_title'] = formatNull(responseBody['webview_page_title']);
    globalTable['webview_upBody'] = formatNull(responseBody['webview_upBody']);
    if (globalTable['webview_upBody'] != '') {
        globalTable['webview_method'] = 'post';
    } else {
        globalTable['webview_method'] = '';
    }
    if (globalTable['webView_reserve_type'] === 'aLi') {
        lua_system.alert_webview({
            title: '阿里商旅',
            visit_url: responseBody['webview_url'],
            close_call_func: '',
            back_type: 'BACK',
            listen_url: 'http://app_h5_callback_url',
            listen_call: 'lua_system.webview_h5_callback'
        });
    } else {
        invoke_page('jjbx_page/xhtml/webview_page.xhtml', page_callback, null);
    }
    globalTable['toReserveH5ResponseBody'] = null;
};
bill_page_router = function (params) {
    var params = formatNull(params, '');
    var mealType = '';
    if (type(params) === 'string') {
        params = lua_format.table_arg_unpack(params);
        mealType = vt('mealType', params);
        params = '';
    }
    var BillPageStyle = 'EditPage';
    var iSRejectBill = '';
    globalTable['zdrbmInfo'] = null;
    if (params != '') {
        var responseBody = json2table(params['responseBody']);
        if (vt('mealChannel', params) != '') {
            mealType = vt('mealChannel', params);
        }
        var BillHaveProcessInfo = responseBody['BillHaveProcessInfo'];
        globalTable['BillPageStyle'] = BillPageStyle;
        if (responseBody['status'] === '1' && BillHaveProcessInfo === 'true') {
            BillPageStyle = 'DetailPage';
            globalTable['iSRejectBill'] = 'true';
            iSRejectBill = 'true';
        } else if (responseBody['status'] === '1') {
            BillPageStyle = 'EditPage';
            globalTable['ifApproverEdit'] = null;
            globalTable['iSRejectBill'] = '';
        } else {
            BillPageStyle = 'DetailPage';
            globalTable['iSRejectBill'] = '';
        }
    }
    var billnumber = globalTable['billCode'];
    var billState = globalTable['billState'];
    var PageUrl = '';
    var PageCallArg = { CloseLoading: 'false' };
    if (globalTable['billTypeCode'] === billTypeList_utils.clbx) {
        if (BillPageStyle === 'EditPage') {
            PageUrl = 'jjbx_proccess_travel_process_bill/xhtml/travel_process_bill_index.xhtml';
        } else {
            PageUrl = 'jjbx_proccess_travel_process_bill/xhtml/travel_process_bill_applyDetail.xhtml';
        }
    } else if (globalTable['billTypeCode'] === billTypeList_utils.sxsq) {
        if (BillPageStyle === 'EditPage') {
            PageUrl = 'jjbx_proccess_matter_apply_bill/xhtml/matter_apply_bill_index.xhtml';
        } else {
            PageUrl = 'jjbx_proccess_matter_apply_bill/xhtml/matter_apply_bill_applyDetail.xhtml';
        }
    } else if (globalTable['billTypeCode'] === billTypeList_utils.bzd) {
        globalTable['billNo'] = billnumber;
        globalTable['billState'] = billState;
        if (BillPageStyle === 'EditPage') {
            PageUrl = 'jjbx_proccess_reimbursement_bill/xhtml/reimbursement_bill_index.xhtml';
        } else {
            PageCallArg['reimbursement_billNo'] = billnumber;
            PageUrl = 'jjbx_proccess_reimbursement_bill/xhtml/reimbursement_bill_detail.xhtml';
        }
    } else if (globalTable['billTypeCode'] === billTypeList_utils.jk) {
        globalTable['JKDbillNo'] = billnumber;
        if (BillPageStyle === 'EditPage') {
            PageUrl = 'jjbx_process_borrow_bill/xhtml/borrow_bill_edit.xhtml';
        } else {
            PageUrl = 'jjbx_process_borrow_bill/xhtml/borrow_bill_applyDetail.xhtml';
        }
    } else if (globalTable['billTypeCode'] === billTypeList_utils.hk) {
        globalTable['hkBillNo'] = billnumber;
        if (BillPageStyle === 'EditPage') {
            PageUrl = 'jjbx_proccess_repayment_bill/xhtml/repayment_bill_index.xhtml';
        } else {
            PageUrl = 'jjbx_proccess_repayment_bill/xhtml/repayment_bill_applyDetail.xhtml';
        }
    } else if (globalTable['billTypeCode'] === billTypeList_utils.ycsq) {
        globalTable['carService_billNo'] = billnumber;
        globalTable['shenpi'] = 'true';
        if (BillPageStyle === 'EditPage') {
            PageUrl = 'jjbx_car_service/xhtml/car_service_travelApply_edit.xhtml';
        } else {
            PageUrl = 'jjbx_car_service/xhtml/car_service_detail.xhtml';
        }
    } else if (globalTable['billTypeCode'] === billTypeList_utils.eatServer) {
        globalTable['eatServer_djh'] = billnumber;
        globalTable['shenpi'] = 'true';
        if (BillPageStyle === 'EditPage') {
            if (mealType === '1') {
                PageCallArg['billNo'] = billnumber;
                PageUrl = 'jjbx_eat_service/apply.xhtml';
            } else {
                PageUrl = 'jjbx_eat_service/xhtml/eatServer_limitApply_edit.xhtml';
            }
        } else {
            PageUrl = 'jjbx_eat_service/apply_detail.xhtml';
        }
    } else if (globalTable['billTypeCode'] === billTypeList_utils.yfkzf) {
        globalTable['YFKZFbillNo'] = billnumber;
        globalTable['YFKZFbillNo2'] = billnumber;
        if (BillPageStyle === 'EditPage') {
            PageUrl = 'jjbx_proccess_pay_bill/xhtml/pay_bill_index.xhtml';
        } else {
            PageUrl = 'jjbx_proccess_pay_bill/xhtml/pay_bill_detail.xhtml';
        }
    } else if (globalTable['billTypeCode'] === billTypeList_utils.xcbx) {
        globalTable['ifNewXCBX'] = 'false';
        if (BillPageStyle === 'EditPage') {
            PageUrl = 'jjbx_travel_reimbursement/xhtml/travel_service_reimbursement_submit_process.xhtml';
        } else {
            PageUrl = 'jjbx_travel_reimbursement/xhtml/travel_service_reimbursement_applyDetail.xhtml';
        }
    } else if (globalTable['billTypeCode'] === billTypeList_utils.xcsq) {
        globalTable['XCSQ_billNo'] = billnumber;
        globalTable['detailNo'] = billnumber;
        globalTable['firstPage'] = 'true';
        if (BillPageStyle === 'EditPage') {
            PageUrl = 'jjbx_travel_service/xhtml/travel_service_apply_edit.xhtml';
        } else {
            PageUrl = 'jjbx_travel_service/xhtml/travel_service_proccess_bill_detail.xhtml';
        }
    } else if (globalTable['billTypeCode'] === billTypeList_utils.cgsq) {
        globalTable['purchaseNo'] = billnumber;
        globalTable['categoryList'] = {};
        if (BillPageStyle === 'EditPage') {
            globalTable['onlineShoppingApply_params'] = {
                purchaseNo: '',
                feeTakerPk: '',
                feeTaker: '',
                feeTakerDept: '',
                feeTakerCode: '',
                feeTakerDeptCode: '',
                purchasecause: '',
                corpName: '',
                totalprice: '',
                purchasetype: '对公采购-公司支付',
                purchasetypecode: 'A',
                borrowflag: '',
                unitprice: '',
                purchasenum: '',
                groupprice: '',
                servicetype: '',
                servicetypeCode: '',
                purchasingcategory: '',
                categorycode: '',
                expenditureproject: '',
                expenditureprojectcode: '',
                TranCode: 'addPurchaseRequistion',
                saveFlag: 'save'
            };
            PageUrl = 'jjbx_online_shopping/xhtml/onlineShopping_apply_edit.xhtml';
        } else {
            globalTable['shenpiFlag'] = 0;
            PageUrl = 'jjbx_online_shopping/xhtml/onlineShopping_applyDetail.xhtml';
        }
    } else if (globalTable['billTypeCode'] === billTypeList_utils.cgsq_new) {
        if (BillPageStyle === 'EditPage') {
            lua_purchase.reset_onlineShopping_initParams();
            globalTable['onlineShopping_initParams']['purchaseBillNo'] = billnumber;
            PageUrl = 'jjbx_online_shopping/apply.xhtml';
        } else {
            globalTable['purchaseNo'] = billnumber;
            PageUrl = 'jjbx_online_shopping/apply_detail.xhtml';
        }
    } else if (globalTable['billTypeCode'] === billTypeList_utils.sxjs) {
        PageCallArg['billNo'] = billnumber;
        if (BillPageStyle === 'EditPage') {
            PageUrl = 'jjbx_process_items_account/xhtml/items_account_index.xhtml';
        } else {
            PageUrl = 'jjbx_process_items_account/xhtml/items_account_detail.xhtml';
        }
    } else if (globalTable['billTypeCode'] === billTypeList_utils.byjsq) {
        PageUrl = 'jjbx_budget_info/xhtml/sparegold_show.xhtml';
    } else if (globalTable['billTypeCode'] === billTypeList_utils.xtnzf) {
        PageUrl = 'jjbx_budget_info/xhtml/syspayment_show.xhtml';
    } else if (globalTable['billTypeCode'] === billTypeList_utils.cbft) {
        PageUrl = 'jjbx_budget_info/xhtml/costsharing_show.xhtml';
    } else if (globalTable['billTypeCode'] === billTypeList_utils.pzdj) {
        PageUrl = 'jjbx_budget_info/xhtml/voucher_show.xhtml';
    } else if (globalTable['billTypeCode'] === billTypeList_utils.tyjs) {
        PageUrl = 'jjbx_budget_info/xhtml/settlement_show.xhtml';
    } else if (globalTable['billTypeCode'] === billTypeList_utils.yfksq) {
        PageUrl = 'jjbx_budget_info/xhtml/payApply_show.xhtml';
    } else if (globalTable['billTypeCode'] === billTypeList_utils.kkd) {
        PageUrl = 'jjbx_budget_info/xhtml/payIn_show.xhtml';
    } else if (globalTable['billTypeCode'] === billTypeList_utils.xcsp) {
        PageUrl = 'jjbx_budget_info/xhtml/remuneration_show.xhtml';
    } else if (globalTable['billTypeCode'] === billTypeList_utils.zybzd) {
        PageCallArg['billNo'] = billnumber;
        PageUrl = 'jjbx_budget_info/xhtml/specialty_reimbursement.xhtml';
    } else {
    }
    if (PageUrl === '') {
        alert('暂无详情');
    } else {
        invoke_page(PageUrl, page_callback, PageCallArg);
    }
};
jjbx_toBillDetail = function (billNo) {
    var billNo = formatNull(billNo);
    if (billNo != '') {
        globalTable['billCode'] = billNo;
        var billTypeCode = bill_no2type(billNo);
        globalTable['billTypeCode'] = billTypeCode;
        if (billTypeCode === billTypeList_utils.clbx) {
            invoke_page('jjbx_proccess_travel_process_bill/xhtml/travel_process_bill_applyDetail.xhtml', page_callback, { CloseLoading: 'false' });
        } else if (billTypeCode === billTypeList_utils.sxsq) {
            invoke_page('jjbx_proccess_matter_apply_bill/xhtml/matter_apply_bill_applyDetail.xhtml', page_callback, { CloseLoading: 'false' });
        } else if (billTypeCode === billTypeList_utils.bzd) {
            globalTable['billNo'] = billNo;
            globalTable['isShowReApplyBtn'] = 'false';
            invoke_page('jjbx_proccess_reimbursement_bill/xhtml/reimbursement_bill_detail.xhtml', page_callback, { reimbursement_billNo: billNo });
        } else if (billTypeCode === billTypeList_utils.jk) {
            globalTable['JKDbillNo'] = billNo;
            invoke_page('jjbx_process_borrow_bill/xhtml/borrow_bill_applyDetail.xhtml', page_callback, null);
        } else if (billTypeCode === billTypeList_utils.hk) {
            globalTable['hkBillNo'] = billNo;
            invoke_page('jjbx_proccess_repayment_bill/xhtml/repayment_bill_applyDetail.xhtml', page_callback, null);
        } else if (billTypeCode === billTypeList_utils.ycsq) {
            globalTable['carService_billNo'] = billNo;
            globalTable['shenpi'] = 'true';
            invoke_page('jjbx_car_service/xhtml/car_service_detail.xhtml', page_callback, null);
        } else if (billTypeCode === billTypeList_utils.eatServer) {
            globalTable['eatServer_djh'] = billNo;
            globalTable['shenpi'] = 'true';
            invoke_page('jjbx_eat_service/apply_detail.xhtml', page_callback, null);
        } else if (billTypeCode === billTypeList_utils.yfkzf) {
            globalTable['YFKZFbillNo2'] = billNo;
            invoke_page('jjbx_proccess_pay_bill/xhtml/pay_bill_detail.xhtml', page_callback, null);
        } else if (billTypeCode === billTypeList_utils.xcbx) {
            globalTable['ifNewXCBX'] = 'false';
            invoke_page('jjbx_travel_reimbursement/xhtml/travel_service_reimbursement_applyDetail.xhtml', page_callback, { CloseLoading: 'false' });
        } else if (billTypeCode === billTypeList_utils.xcsq) {
            globalTable['XCSQ_billNo'] = billNo;
            globalTable['detailNo'] = billNo;
            lua_travel.to_ts_page('xcsqxq');
        } else if (billTypeCode === billTypeList_utils.cgsq) {
            globalTable['purchaseNo'] = billNo;
            globalTable['categoryList'] = {};
            globalTable['shenpiFlag'] = 0;
            invoke_page('jjbx_online_shopping/xhtml/onlineShopping_applyDetail.xhtml', page_callback, { CloseLoading: 'false' });
        } else if (billTypeCode === billTypeList_utils.byjsq) {
            invoke_page('jjbx_budget_info/xhtml/sparegold_show.xhtml', page_callback, null);
        } else if (billTypeCode === billTypeList_utils.xtnzf) {
            invoke_page('jjbx_budget_info/xhtml/syspayment_show.xhtml', page_callback, null);
        } else if (billTypeCode === billTypeList_utils.cbft) {
            invoke_page('jjbx_budget_info/xhtml/costsharing_show.xhtml', page_callback, null);
        } else if (billTypeCode === billTypeList_utils.pzdj) {
            invoke_page('jjbx_budget_info/xhtml/voucher_show.xhtml', page_callback, null);
        } else if (billTypeCode === billTypeList_utils.tyjs) {
            invoke_page('jjbx_budget_info/xhtml/settlement_show.xhtml', page_callback, null);
        } else if (billTypeCode === billTypeList_utils.yfksq) {
            invoke_page('jjbx_budget_info/xhtml/payApply_show.xhtml', page_callback, null);
        } else if (billTypeCode === billTypeList_utils.cgsq_new) {
            globalTable['purchaseNo'] = billNo;
            PageUrl = 'jjbx_online_shopping/apply_detail.xhtml';
        } else if (billTypeCode === billTypeList_utils.xcsp) {
            invoke_page('jjbx_budget_info/xhtml/remuneration_show.xhtml', page_callback, null);
        } else {
            debug_alert(billTypeCode);
            alert('暂不支持该单据类型');
        }
    } else {
        alert('单据号为空');
    }
};
show_invoice_rule = function () {
    var tb = splitUtils(globalTable['hintInfo'], ';');
    var noteInfo = '';
    for (let i = 1; tb.length; i++) {
        noteInfo = noteInfo + tb[i];
        if (tb.length > 1 && i != tb.length) {
            noteInfo = noteInfo + '\\n';
        }
    }
    alert(noteInfo);
};
up_bill_tip_amount = function (amount) {
    var amount = tostring(formatMoney(amount));
    var amount = formatNull(amount, '0.00');
    changeProperty('head_tip_content_label', 'value', '单据金额\uFF1A' + amount);
};
jjbx_yccx = function (cartype) {
    if (cartype === '100') {
        return '专车舒适型';
    } else if (cartype === '200') {
        return '专车行政型';
    } else if (cartype === '400') {
        return '专车商务型';
    } else if (cartype === '600') {
        return '普通快车';
    } else if (cartype === '900') {
        return '快车优享';
    } else {
        return '';
    }
};
lua_jjbx.set_auth = function (res) {
    var userType = vt('userType', globalTable);
    if (vt('UseCarJDFlag', res) === '1' || userType === '2') {
        carServiceFlag = 'enable';
    } else {
        carServiceFlag = 'disenable';
    }
    if (vt('TravelJDFlag', res) === '1') {
        travelServiceFlag = 'enable';
    } else {
        travelServiceFlag = 'disenable';
    }
    if (vt('EatAuthFlag', res) === '1' || userType === '2') {
        eatServiceFlag = 'enable';
    } else {
        eatServiceFlag = 'disenable';
    }
    if (vt('OBEatAuthFlag', res) === '1') {
        OBeatServiceFlag = 'enable';
    } else {
        OBeatServiceFlag = 'disenable';
    }
    if (vt('OtherEatAuthFlag', res) === '1' || userType === '2') {
        OtherEatServiceFlag = 'enable';
    } else {
        OtherEatServiceFlag = 'disenable';
    }
    if (vt('OtherEat2AuthFlag', res) === '1' || userType === '2') {
        OtherEat2ServiceFlag = 'enable';
    } else {
        OtherEat2ServiceFlag = 'disenable';
    }
    if (vt('OtherEat3AuthFlag', res) === '1' || userType === '2') {
        OtherEat3ServiceFlag = 'enable';
    } else {
        OtherEat3ServiceFlag = 'disenable';
    }
    if (vt('MsgCenterAuthFlag', res) === '1' || userType === '2') {
        MsgCenterFlag = 'enable';
    } else {
        MsgCenterFlag = 'disenable';
    }
    if (vt('HKHospitalFlag', res) === '1') {
        HKHospitalFlag = 'enable';
    } else {
        HKHospitalFlag = 'disenable';
    }
    if (vt('RenatalHourseFlag', res) === '1') {
        RenatalHourseFlag = 'enable';
    } else {
        RenatalHourseFlag = 'disenable';
    }
    var EatServiceGrycName = vt('EatServiceGrycName', res);
    if (EatServiceGrycName != '') {
        globalTable['EatServiceGrycName'] = EatServiceGrycName;
    } else {
        globalTable['EatServiceGrycName'] = '自由用餐';
    }
    var EatServiceGryc2Name = vt('EatServiceGryc2Name', res);
    if (EatServiceGryc2Name != '') {
        globalTable['EatServiceGryc2Name'] = EatServiceGryc2Name;
    } else {
        globalTable['EatServiceGryc2Name'] = '自由用餐2';
    }
    var EatServiceGryc3Name = vt('EatServiceGryc3Name', res);
    if (EatServiceGryc3Name != '') {
        globalTable['EatServiceGryc3Name'] = EatServiceGryc3Name;
    } else {
        globalTable['EatServiceGryc3Name'] = '自由用餐3';
    }
    if (vt('ProcessBillFlag', res) === '1') {
        processBillFlag = 'enable';
    } else {
        processBillFlag = 'disenable';
    }
    companyTable['viewauthority'] = vt('Viewauthority', res);
    companyTable['thirdPartyServiceStatus'] = json2table(vt('ThirdPartyServiceStatus', res));
    lua_travel.set_channel(res);
};
login_page = function (loginType) {
    var DefaultPageUrl = 'jjbx_login/xhtml/jjbx_login.xhtml';
    var PageUrl = '';
    var loginType = formatNull(loginType, '0');
    if (loginType === '0') {
        PageUrl = DefaultPageUrl;
    } else if (loginType === '1') {
        PageUrl = 'jjbx_login/xhtml/jjbx_gestureLogin.xhtml';
    } else if (loginType === '2') {
        if (systemTable['SupportLoginType'] === 'TouchID') {
            PageUrl = 'jjbx_login/xhtml/jjbx_touchIDLogin.xhtml';
        } else {
            PageUrl = DefaultPageUrl;
        }
    } else if (loginType === '3') {
        if (systemTable['SupportLoginType'] === 'FaceID') {
            PageUrl = 'jjbx_login/xhtml/jjbx_faceIDLogin.xhtml';
        } else {
            PageUrl = DefaultPageUrl;
        }
    } else if ('mobile_login') {
        PageUrl = 'jjbx_login/xhtml/jjbx_mobileLogin.xhtml';
    } else {
        PageUrl = DefaultPageUrl;
    }
    return PageUrl;
};
check_feature_month = function (checkMonth) {
    var checkMonth = formatNull(checkMonth);
    var checkMonthRes = 'false';
    if (checkMonth === '') {
        alert('日期格式错误');
        checkMonthRes = 'false';
    } else {
        var CheckDayTS = dateToTime(checkMonth + '01');
        var NowMonthFirstDayTS = dateToTime(string.sub(os.date('%Y-%m-%d', os.time()), 1, 7) + '01');
        if (CheckDayTS > NowMonthFirstDayTS) {
            if (platform === 'iPhone OS') {
                window.alert('不能选择未来的时间', '确定');
            } else {
                alert('不能选择未来的时间');
            }
            checkMonthRes = 'false';
        } else {
            checkMonthRes = 'true';
        }
    }
    return checkMonthRes;
};
showFJZSFlagTip = function () {
    alert(formatNull(globalTable['fjzsTip'], ''));
};
submitAttachment = function (submitAttachment, billType) {
    if (submitAttachment === '1') {
        changeProperty('SWFJImg', 'src', 'local:dj_ico_radioed.png');
        changeProperty('noSWFJImg', 'src', 'local:dj_ico_radio.png');
    } else if (submitAttachment === '0') {
        changeProperty('noSWFJImg', 'src', 'local:dj_ico_radioed.png');
        changeProperty('SWFJImg', 'src', 'local:dj_ico_radio.png');
    } else {
        changeProperty('noSWFJImg', 'src', 'local:dj_ico_radio.png');
        changeProperty('SWFJImg', 'src', 'local:dj_ico_radio.png');
    }
    page_reload();
    globalTable['submitAttachment' + ('_' + billType)] = submitAttachment;
    return '';
};
qryBillFJZSTipCallback = function (params) {
    var responseBody = json2table(params['responseBody']);
    globalTable['fjzsTip'] = responseBody['value'];
    if (formatNull(globalTable['fjzsTip'], '') === '') {
        changeStyle('fjzs_tip_div', 'display', 'none');
        changeProperty('fjzsFlag_title', 'enable', 'false');
    } else {
        changeStyle('fjzs_tip_div', 'display', 'block');
    }
    page_reload();
};
qryBillFJZSTip = function () {
    invoke_trancode_noloading('jjbx_process_query', 'process_bill', {
        BusinessType: 'matter_apply_bill',
        TranCode: 'QryBillFJZSTip'
    }, qryBillFJZSTipCallback, { CloseLoading: 'false' });
};
chooseOneJd = function (index) {
    var elements = document.getElementsByName('check_img');
    for (let i = 1; elements.length; i++) {
        if (i != index) {
            elements[i].setPropertyByName('src', 'local:select.png');
        } else {
            var bacImg = elements[index].getPropertyByName('src');
            if (bacImg === 'local:select.png') {
                document.getElementsByName('check_img')[index].setPropertyByName('src', 'local:selected_round.png');
                globalTable['spjdData'] = globalTable['selectNodelist'][index]['nodeId'];
            } else {
                document.getElementsByName('check_img')[index].setPropertyByName('src', 'local:select.png');
                globalTable['spjdData'] = null;
            }
        }
    }
};
checkChoose = function () {
    if (null != globalTable['spjdData'] && globalTable['spjdData'] != '') {
        return 1;
    } else {
        return 0;
    }
};
agreeJuger = function () {
    if (globalTable['spjdFlag'] === '1') {
        var check = checkChoose();
        if (check === 0) {
            alert('请选择下个审批流程');
            return 0;
        } else {
            return 1;
        }
    } else {
        return 1;
    }
};
alert_page = function (arg) {
    var argObj = json2table(arg);
    var pageTag = formatNull(argObj['pageTag']);
    if (pageTag === 'upload_pic') {
        var appSupportInfo = lua_ota.version_support('upload_enclosure_page');
        var appSupport = vt('appSupport', appSupportInfo);
        var appSupportTipMsg = vt('appSupportTipMsg', appSupportInfo);
        if (appSupport === 'false') {
            var upverArg = {
                updateType: 'OPTION',
                updateMsg: appSupportTipMsg
            };
            lua_ota.show_upvsr_view(upverArg);
        } else {
            var invokeArg = {
                ShowPageStyle: 'showContent',
                AddPage: 'false',
                JumpStyle: ''
            };
            invoke_page('jjbx_page/xhtml/upload_enclosure_pic_page.xhtml', page_callback, invokeArg);
        }
    } else {
        alert('页面请求失败\uFF01');
    }
};
do_put_bank_data = function (params) {
    var responseBody = json2table(params['responseBody']);
    if (responseBody['bankCounts'] === '0') {
        hide_banknetwork_widget();
        alert('查询银行信息失败');
    } else {
        var bankList = responseBody['bankList'];
        var bankValue = '';
        for (var [key, value] in pairs(bankList)) {
            bankValue = bankValue + ('{' + ('\\"bankType\\":\\"' + (value['bankcode'] + ('\\",' + ('\\"bankName\\":\\"' + (value['bankname'] + ('\\",' + ('\\"bankCode\\":\\"' + (value['bankcode'] + ('\\",' + ('\\"headChar\\":\\"' + (value['firstPinYinPro'] + ('\\",' + ('\\"fullChars\\":\\"' + (value['pinYin'] + ('\\",' + ('\\"fullHeadChars\\":\\"' + (value['firstPinYin'] + ('\\"' + '},')))))))))))))))))));
        }
        bankValue = string.sub(bankValue, 1, string.len(bankValue) - 1);
        var hotBankList = responseBody['hotBankList'];
        var hotBankValue = '';
        for (var [key, value] in pairs(hotBankList)) {
            hotBankValue = hotBankValue + ('{' + ('\\"bankType\\":\\"' + (value['bankcode'] + ('\\",' + ('\\"bankName\\":\\"' + (value['bankname'] + ('\\",' + ('\\"bankCode\\":\\"' + (value['bankcode'] + ('\\",' + ('\\"bankLogo\\":\\"czb_zjsyyh.png\\",' + ('\\"hotNo\\":\\"1\\"' + '},'))))))))))));
        }
        hotBankValue = string.sub(hotBankValue, 1, string.len(hotBankValue) - 1);
        var changeBankSelectValue = '';
        changeBankSelectValue = '{' + ('\\"ebankList\\":' + ('[' + ('{' + ('\\"hotBankList\\":[' + (hotBankValue + ('],' + ('\\"bankList\\":[' + (bankValue + (']' + ('}' + (']' + '}')))))))))));
        changeProperty('bank_widget', 'value', changeBankSelectValue);
        show_ele('bank_bg_div');
        set_android_Physical_back('hide_banknetwork_widget');
        globalTable['BankData'] = params;
    }
};
show_banknetwork_widget = function (index) {
    show_ele('bank_network_widget_div');
    changeProperty('top_search_text', 'value', '');
    if (index === 'bank') {
        var BankData = formatNull(globalTable['BankData']);
        if (BankData === '') {
            invoke_trancode_noloading('jjbx_myInfo', 'cardManagement', { TranCode: 'GetBankList' }, do_put_bank_data, {});
        } else {
            do_put_bank_data(BankData);
        }
    } else if (index === 'network') {
        if (globalTable['bank_code'] === '') {
            alert_confirm('温馨提示', '您尚未选择开户行\uFF0C请选择', '确定', '搜索网点', 'show_search_network');
        } else {
            get_network_data('GetProvenceList', '', '');
        }
    }
};
show_search_network = function (index) {
    if (index === 1) {
        show_ele('search_network_bg_div');
        changeProperty('top_search_text', 'focus', 'true');
        set_android_Physical_back('hide_banknetwork_widget');
    } else {
        hide_ele('bank_network_widget_div');
    }
};
hide_banknetwork_widget = function () {
    changeProperty('bank_widget', 'value', '');
    changeProperty('network_widget', 'value', '');
    hide_ele('bank_bg_div');
    hide_ele('network_bg_div');
    hide_ele('search_network_bg_div');
    hide_ele('bank_network_widget_div');
    page_reload();
    set_android_Physical_back();
};
hide_network_widget = function () {
    hide_ele('network_widget_div');
};
get_network_data = function (TranCode, Code, Name) {
    var ProvinceData = formatNull(globalTable['ProvinceData']);
    if (TranCode === 'GetProvenceList' && ProvinceData != '') {
        do_put_network_data(ProvinceData);
    } else {
        invoke_trancode_donot_checkRepeat('jjbx_myInfo', 'cardManagement', {
            TranCode: TranCode,
            Code: Code,
            Name: Name,
            BankCode: globalTable['bank_code']
        }, do_put_network_data, {});
    }
};
do_put_network_data = function (params) {
    var responseBody = json2table(params['responseBody']);
    var dataCounts = formatNull(responseBody['dataCounts']);
    if (dataCounts === '0') {
        hide_banknetwork_widget();
        alertToast('0', C_NoneMsg, '', '', '');
    } else {
        var resType = responseBody['dataType'];
        var dataType = '0';
        if (resType === 'city') {
            dataType = '1';
        } else if (resType === 'network') {
            dataType = '2';
        } else if (resType === 'province') {
            globalTable['ProvinceData'] = params;
            dataType = '0';
        } else {
            dataType = '0';
        }
        var networkKey = formatNull(responseBody['dataFrom'], '请选择');
        if (dataCounts != '1' || resType != 'city') {
            networkKey = '请选择';
        }
        var dataList = responseBody['dataList'];
        var dataValue = '';
        for (var [key, value] in pairs(dataList)) {
            dataValue = dataValue + ('{\\"name\\":\\"' + (value['name'] + ('\\",\\"code\\":\\"' + (value['code'] + '\\"},'))));
        }
        dataValue = string.sub(dataValue, 1, string.len(dataValue) - 1);
        var changeDataValue = '';
        changeDataValue = '{' + ('\\"type\\":\\"' + (dataType + ('\\",' + ('\\"networkKey\\":\\"' + (networkKey + ('\\",' + ('\\"isOver\\":\\"F\\",' + ('\\"success\\":\\"T\\",' + ('\\"list\\":[' + (dataValue + (']' + '}')))))))))));
        show_ele('network_bg_div');
        changeProperty('network_widget', 'value', changeDataValue);
        set_android_Physical_back('hide_banknetwork_widget');
        page_reload();
        if (dataCounts === '1' && resType === 'city') {
            var qryName = formatNull(dataList[1]['name']);
            var qryCode = formatNull(dataList[1]['code']);
            get_network_data('GetNetworkList', qryCode, qryName);
        }
    }
};
select_network = function (type, code, name) {
    var TranCode = '';
    if (type === '0') {
        get_network_data('GetCityList', code, name);
    } else if (type === '1') {
        get_network_data('GetNetworkList', code, name);
    } else {
        choose_banknetwork_widget('network', name);
        globalTable['network_name'] = name;
        globalTable['network_code'] = code;
        hide_banknetwork_widget();
    }
};
select_bank = function (ishotbank, bankname, bankcode) {
    globalTable['bank_name'] = bankname;
    globalTable['bank_code'] = bankcode;
    choose_banknetwork_widget('bank', bankname);
    if (bankname === '浙商银行' && bankcode === '316') {
        hide_ele('network_container_div');
    } else {
        globalTable['network_name'] = '';
        globalTable['network_code'] = '';
        show_ele('network_container_div');
        choose_banknetwork_widget('network', '请选择');
        changeProperty('network_widget', 'value', '');
    }
    hide_banknetwork_widget();
};
search_network = function (index) {
    var searchText = formatNull(document.getElementsByName('top_search_text')[parseFloat(index)].getPropertyByName('value'));
    if (searchText != '') {
        invoke_trancode('jjbx_myInfo', 'cardManagement', {
            TranCode: 'SearchNetwork',
            NetWorkName: searchText
        }, show_search_network_result, {});
    } else {
        alert('请输入要搜索的网点名称');
    }
};
show_search_network_result = function (params) {
    var responseBody = json2table(params['responseBody']);
    if (responseBody['errorNo'] === '000000') {
        var network_code = formatNull(responseBody['hh']);
        var network_name = formatNull(responseBody['qcname']);
        var bank_code = formatNull(responseBody['hbdm']);
        var bank_name = formatNull(responseBody['bankName']);
        globalTable['network_code'] = network_code;
        globalTable['network_name'] = network_name;
        globalTable['bank_code'] = bank_code;
        globalTable['bank_name'] = bank_name;
        choose_banknetwork_widget('network', network_name);
        choose_banknetwork_widget('bank', bank_name);
        hide_banknetwork_widget();
    } else {
        alertToast('0', C_NoneMsg, '', '', '');
    }
};
search_network_onChange = function (index) {
    var searchText = formatNull(document.getElementsByName('top_search_text')[parseFloat(index)].getPropertyByName('value'));
    if (searchText === '') {
        show_ele('network_widget_div');
        show_ele('radius_bg_div');
    } else {
        hide_ele('network_widget_div');
        hide_ele('radius_bg_div');
    }
};
choose_banknetwork_widget = function (widget, value) {
    var value = formatNull(value);
    if (widget === 'bank') {
        changeProperty('bank_name', 'value', jjbx_utils_setStringLength(value, 16));
    } else {
        changeProperty('network_name', 'value', jjbx_utils_setStringLength(value, 16));
    }
};
lua_jjbx.get_bill_cover_pdf = function (params) {
    var params = formatNull(params);
    if (params === '') {
        invoke_trancode('jjbx_service', 'app_service', {
            TranCode: 'printBill',
            billNo: globalTable['billNo_download'],
            qryAllBillB: vt('qryAllBillB', globalTable)
        }, lua_jjbx.get_bill_cover_pdf, {}, all_callback, { CloseLoading: 'false' });
    } else {
        var responseBody = json2table(params['responseBody']);
        if (responseBody['errorNo'] === '000000') {
            globalTable['qryAllBillB'] = '';
            close_loading();
            lua_system.download_file(responseBody['CacheFileDLUrl']);
        } else {
            alert(responseBody['errorMsg']);
        }
    }
};
lua_jjbx.qry_msg_h5_link = function (qryArg) {
    var qryArg = formatNull(qryArg);
    var PkMsgPublishList = formatNull(qryArg['PkMsgPublishList']);
    var NeedBase64 = formatNull(qryArg['NeedBase64'], 'false');
    var MsgType = formatNull(qryArg['MsgType']);
    var PopupFlag = formatNull(qryArg['PopupFlag']);
    invoke_trancode_donot_checkRepeat('jjbx_page', 'webview_page', {
        TranCode: 'InitPublishMsgUrl',
        PkMsgPublishList: PkMsgPublishList,
        NeedBase64: NeedBase64,
        MsgType: MsgType,
        popupFlag: PopupFlag
    }, lua_jjbx.open_msg_h5_page, {}, all_callback, { CloseLoading: 'false' });
};
lua_jjbx.open_msg_h5_page = function (params) {
    var data = json2table(params['responseBody']);
    globalTable['webview_url'] = data['webview_url'];
    invoke_page('jjbx_page/xhtml/webview_page.xhtml', page_callback, { CloseLoading: 'false' });
};
lua_jjbx.msg_default_alert = function (Arg) {
    var content = vt('content', Arg);
    var readFlag = vt('readFlag', Arg);
    if (readFlag != 'true') {
        alert_confirm('消息内容', content, '', '确定', 'lua_jjbx.updMarkunreadFlag', '');
    } else {
        alert_confirm('消息内容', content, '', '确定', '', '');
    }
};
lua_jjbx.updMarkunreadFlag = function (params) {
    var params = formatNull(params);
    if (params === '' || params === 1) {
        var pkNotimsg = formatNull(globalTable['DelpkNotimsg']);
        var pkMsgPublishList = formatNull(globalTable['DelpkMsgPublishList']);
        var popupFlag = formatNull(globalTable['popupFlag']);
        globalTable['DelpkMsgPublishList'] = '';
        globalTable['DelpkNotimsg'] = '';
        globalTable['popupFlag'] = '';
        invoke_trancode_noloading('jjbx_index', 'query_msg', {
            TranCode: 'UpdMarkunreadFlag',
            pkNotimsg: pkNotimsg,
            pkMsgPublishList: pkMsgPublishList,
            popupFlag: popupFlag
        }, lua_jjbx.updMarkunreadFlag, {});
    } else {
        var jsonData = params['responseBody'];
        var data = json2table(jsonData);
        if (data['errorNo'] === '000000') {
            qryMsgMarkUnReadCount();
            isClean = 'true';
        } else {
            alert(data['errorMsg']);
        }
    }
};
lua_jjbx.open_guide_page = function (url) {
    globalTable['webview_url'] = url;
    globalTable['webview_page_title'] = '新手指南';
    globalTable['webview_back2jjbx'] = '返回首页';
    globalTable['GuidePageUrl'] = url;
    invoke_page_noloading_checkRepeat('jjbx_page/xhtml/webview_page.xhtml', page_callback, null);
};
lua_jjbx.invoice_menu_enable_ctrl = function (MenuEnableConfig, MenuConfigId) {
    var needCheck = formatNull(configTable['add_invoice_menu_config']);
    if (needCheck === 'false') {
        return 'true';
    } else {
        if (string.find(MenuEnableConfig, MenuConfigId)) {
            return 'true';
        } else {
            return 'false';
        }
    }
};
lua_jjbx.alert_add_invoice_menu = function (menuType) {
    var PCConfigListsTable = vt('PCConfigListsTable', globalTable);
    var MenuEnableConfig = vt('INV0012', PCConfigListsTable);
    var menuType = formatNull(menuType);
    var router_fun = 'lua_menu.app_alert_menu_action';
    var close_fun = 'lua_jjbx.close_add_invoice_menu';
    var menu_relate_by_fpc = {
        title: '从发票池选择',
        tip: vt('INV0005', PCConfigListsTable),
        fun: router_fun,
        arg: 'invoice_relate_by_fpc'
    };
    var menu_relate_by_upload = {
        title: '添加电票',
        tip: vt('INV0008', PCConfigListsTable),
        fun: router_fun,
        arg: 'invoice_relate_by_filesystem'
    };
    var menu_relate_by_input = {
        title: '添加纸票',
        tip: vt('INV0009', PCConfigListsTable),
        fun: router_fun,
        arg: 'invoice_relate_by_input'
    };
    var menu_add_by_upload = {
        title: '添加电票',
        tip: vt('INV0025', PCConfigListsTable),
        fun: router_fun,
        arg: 'invoice_add_by_filesystem'
    };
    var menu_add_by_input = {
        title: '添加纸票',
        tip: vt('INV0009', PCConfigListsTable),
        fun: router_fun,
        arg: 'invoice_add_by_input'
    };
    var menu_scan_train_ticket_by_camera = {
        title: '拍照识别',
        tip: '',
        fun: router_fun,
        arg: 'scan_train_ticket_by_camera'
    };
    var menu_scan_train_ticket_by_album = {
        title: '上传火车票图片',
        tip: '',
        fun: router_fun,
        arg: 'scan_train_ticket_by_album'
    };
    var menu_scan_train_ticket_by_filesystem = {
        title: '从文件选择',
        tip: '',
        fun: router_fun,
        arg: 'scan_train_ticket_by_filesystem'
    };
    var menu_scan_air_ticket_by_camera = {
        title: '拍照识别',
        tip: '',
        fun: router_fun,
        arg: 'scan_air_ticket_by_camera'
    };
    var menu_scan_air_ticket_by_album = {
        title: '上传行程单图片',
        tip: '',
        fun: router_fun,
        arg: 'scan_air_ticket_by_album'
    };
    var menu_scan_air_ticket_by_filesystem = {
        title: '从文件选择',
        tip: '',
        fun: router_fun,
        arg: 'scan_air_ticket_by_filesystem'
    };
    var menu_pension_voucher_by_filesystem = {
        title: '从文件选择',
        tip: '',
        fun: router_fun,
        arg: 'pension_voucher_by_filesystem'
    };
    var menu_info_list = {};
    if (menuType === 'relate') {
        if (lua_jjbx.invoice_menu_enable_ctrl(MenuEnableConfig, 'INVADD01') === 'true') {
            table.insert(menu_info_list, menu_relate_by_fpc);
        }
        if (lua_jjbx.invoice_menu_enable_ctrl(MenuEnableConfig, 'INVADD04') === 'true') {
            table.insert(menu_info_list, menu_relate_by_upload);
        }
        if (lua_jjbx.invoice_menu_enable_ctrl(MenuEnableConfig, 'INVADD05') === 'true') {
            table.insert(menu_info_list, menu_relate_by_input);
        }
    } else if (menuType === 'add') {
        table.insert(menu_info_list, menu_add_by_upload);
        table.insert(menu_info_list, menu_add_by_input);
    } else if (menuType === 'scan_train_ticket') {
        table.insert(menu_info_list, menu_scan_train_ticket_by_camera);
        table.insert(menu_info_list, menu_scan_train_ticket_by_album);
        table.insert(menu_info_list, menu_scan_train_ticket_by_filesystem);
    } else if (menuType === 'scan_air_ticket') {
        table.insert(menu_info_list, menu_scan_air_ticket_by_camera);
        table.insert(menu_info_list, menu_scan_air_ticket_by_album);
        table.insert(menu_info_list, menu_scan_air_ticket_by_filesystem);
    } else if (menuType === 'pension_voucher') {
        table.insert(menu_info_list, menu_pension_voucher_by_filesystem);
    }
    if (menu_info_list.length <= 0) {
        alert('无可用添加方式');
        return;
    }
    var tableArg = {
        menu_info_list: menu_info_list,
        cancel_menu_info: [{
                title: '取消',
                tip: '',
                fun: close_fun,
                arg: ''
            }],
        bg_click_fun: close_fun,
        bg_click_arg: ''
    };
    var jsonArg = table2json(tableArg);
    lua_system.app_alert_menu(jsonArg);
};
lua_jjbx.close_add_invoice_menu = function (arg) {
    lua_system.close_app_alert_menu();
};
lua_jjbx.upload_invoice_to_add_call = function (totalcounts, successcounts, resmsg, resinfoJson) {
    var totalcounts = formatNull(totalcounts);
    var successcounts = formatNull(successcounts);
    var resmsg = formatNull(resmsg);
    var resinfoJson = formatNull(resinfoJson);
    var appSupportInfo = lua_ota.version_support('invoiceUpload');
    var appSupport = vt('appSupport', appSupportInfo);
    var invoiceUploadCtrl = vt('invoiceUploadCtrl', globalTable);
    if ((invoiceUploadCtrl === 'invoice_add_by_filesystem' || invoiceUploadCtrl === 'invoice_add_by_album') && appSupport === 'true') {
        var resinfoTable = json2table(resinfoJson);
        var res = vt('res', resinfoTable);
        var errorNo = vt('errorNo', res);
        var errorMsg = vt('errorMsg', res, '识别失败');
        var FileID = vt('FileID', res);
        var uploadingFile = vt('uploadingFile', globalTable, {});
        for (var [key, value] in pairs(uploadingFile)) {
            if (FileID === value['fileID']) {
                if (errorNo === '000000') {
                    uploadingFile[key]['uploadState'] = '待保存';
                } else {
                    uploadingFile[key]['uploadState'] = '上传失败';
                }
            }
        }
        if (vt('UploadInvoiceToAddRes', globalTable) === '') {
            globalTable['UploadInvoiceToAddRes'] = {};
        }
        var UploadResultMsg = '';
        if (errorNo === '000000') {
            table.insert(globalTable['UploadInvoiceToAddRes'], res);
            lua_upload.saveCheckSuccessInvoice('', {});
        } else {
            var AddErrorMsg = errorMsg + ('\uFF0C文件名\uFF1A' + (FileName + '\\n'));
            UploadResultMsg = UploadResultMsg + AddErrorMsg;
        }
    } else {
        if (parseFloat(totalcounts) === parseFloat(successcounts)) {
            var resinfoTable = json2table(resinfoJson);
            var res = vt('res', resinfoTable);
            var resCounts = res.length;
            var UploadInvoiceToAddRes = {};
            var UploadResultMsg = '';
            for (let i = 1; resCounts; i++) {
                var LoopData = formatNull(res[i]);
                var errorNo = vt('errorNo', LoopData);
                var errorMsg = vt('errorMsg', LoopData, '识别失败');
                var FileName = vt('FileName', LoopData);
                if (errorNo === '000000') {
                    table.insert(UploadInvoiceToAddRes, LoopData);
                } else {
                    var AddErrorMsg = errorMsg + ('\uFF0C文件名\uFF1A' + (FileName + '\\n'));
                    UploadResultMsg = UploadResultMsg + AddErrorMsg;
                }
            }
            if (UploadResultMsg != '') {
                alert(UploadResultMsg);
            }
            if (UploadInvoiceToAddRes.length > 0) {
                var InvokePageArg = {
                    UploadInvoiceToAddRes: UploadInvoiceToAddRes,
                    CloseLoading: 'false'
                };
                invoke_page('jjbx_fpc/xhtml/jjbx_invoice_upload_save.xhtml', page_callback, InvokePageArg);
            } else {
                alert('发票识别失败');
            }
        } else {
            alert('发票识别失败');
        }
    }
};
lua_jjbx.upload_invoice_to_relate_call = function (totalcounts, successcounts, resmsg, resinfoJson) {
    var totalcounts = formatNull(totalcounts);
    var successcounts = formatNull(successcounts);
    var resmsg = formatNull(resmsg);
    var resinfoJson = formatNull(resinfoJson);
    if (parseFloat(totalcounts) === parseFloat(successcounts)) {
        var resinfoTable = json2table(resinfoJson);
        var res = vt('res', resinfoTable);
        var resCounts = res.length;
        var UploadInvoiceToAddRes = {};
        var UploadResultMsg = '';
        for (let i = 1; resCounts; i++) {
            var LoopData = formatNull(res[i]);
            var errorNo = vt('errorNo', LoopData);
            var errorMsg = vt('errorMsg', LoopData, '识别失败');
            var FileName = vt('FileName', LoopData);
            if (errorNo === '000000') {
                table.insert(UploadInvoiceToAddRes, LoopData);
            } else {
                var AddErrorMsg = errorMsg + ('\uFF0C文件名\uFF1A' + (FileName + '\\n'));
                UploadResultMsg = UploadResultMsg + AddErrorMsg;
            }
        }
        if (UploadResultMsg != '') {
            alert(UploadResultMsg);
        }
        if (UploadInvoiceToAddRes.length > 0) {
            var InvokePageArg = {
                UploadInvoiceToAddRes: UploadInvoiceToAddRes,
                CloseLoading: 'false'
            };
            globalTable['invoiceFlag'] = 'upload';
            globalTable['scfpTip'] = 'false';
            invoke_page('jjbx_proccess_reimbursement_bill/xhtml/reimbursement_bill_invoice_upload_save.xhtml', page_callback, InvokePageArg);
        } else {
            alert('发票识别失败');
        }
    } else {
        alert('发票识别失败');
    }
};
lua_jjbx.upload_train_ticket_to_scan_call = function (totalcounts, successcounts, resmsg, resinfoJson) {
    var totalcounts = formatNull(totalcounts);
    var successcounts = formatNull(successcounts);
    var resmsg = formatNull(resmsg);
    var resinfoJson = formatNull(resinfoJson);
    if (parseFloat(totalcounts) === parseFloat(successcounts)) {
        var resinfoTable = json2table(resinfoJson);
        var res = vt('res', resinfoTable);
        var errorNo = vt('errorNo', res[1]);
        var errorMsg = vt('errorMsg', res[1]);
        if (errorNo === '000000') {
            globalTable['UploadInvoiceInfo'] = res[1];
            train_ticket_info_call(res[1]);
        } else {
            alert(errorMsg);
        }
    } else {
        alert('火车票识别失败');
    }
};
lua_jjbx.upload_air_ticket_to_scan_call = function (totalcounts, successcounts, resmsg, resinfoJson) {
    var totalcounts = formatNull(totalcounts);
    var successcounts = formatNull(successcounts);
    var resmsg = formatNull(resmsg);
    var resinfoJson = formatNull(resinfoJson);
    if (parseFloat(totalcounts) === parseFloat(successcounts)) {
        var resinfoTable = json2table(resinfoJson);
        var res = vt('res', resinfoTable);
        var errorNo = vt('errorNo', res[1]);
        var errorMsg = vt('errorMsg', res[1]);
        if (errorNo === '000000') {
            globalTable['UploadInvoiceInfo'] = res[1];
            air_ticket_info_call(res[1]);
        } else {
            alert(errorMsg);
        }
    } else {
        alert('行程单识别失败');
    }
};
lua_jjbx.upload_pension_voucher_call = function (totalcounts, successcounts, resmsg, resinfoJson) {
    var totalcounts = formatNull(totalcounts);
    var successcounts = formatNull(successcounts);
    var resmsg = formatNull(resmsg);
    var resinfoJson = formatNull(resinfoJson);
    if (parseFloat(totalcounts) === parseFloat(successcounts)) {
        var resinfoTable = json2table(resinfoJson);
        var res = vt('res', resinfoTable);
        var errorNo = vt('errorNo', res[1]);
        var errorMsg = vt('errorMsg', res[1]);
        if (errorNo === '000000') {
            globalTable['UploadInvoiceInfo'] = res[1];
            pension_voucher_info_call(res[1]);
        } else {
            alert(errorMsg);
        }
    } else {
        alert('行程单识别失败');
    }
};
lua_jjbx.load_invoice_content = function (necessaryInvElements, showContentList) {
    var necessaryInvElements = formatNull(necessaryInvElements);
    var showContentList = formatNull(showContentList);
    var Config = formatNull(JJBX_InvoiceContentList);
    var ConfigCounts = Config.length;
    if (necessaryInvElements === '' || showContentList === '') {
        for (let i = 1; ConfigCounts; i++) {
            var ConfigData = formatNull(Config[i]);
            var tagName = vt('tagName', ConfigData);
            changeProperty(tagName + '_required', 'value', '');
            changeStyle(tagName + '_div', 'display', 'none');
        }
    } else {
        var debug_alert_msg = '';
        for (let i = 1; ConfigCounts; i++) {
            var ConfigData = formatNull(Config[i]);
            var code = vt('code', ConfigData);
            var tagName = vt('tagName', ConfigData);
            var name = vt('name', ConfigData);
            var requiredFlag = string.find(necessaryInvElements, code);
            requiredFlag = formatNull(requiredFlag, 0);
            var showFlag = string.find(showContentList, code);
            showFlag = formatNull(showFlag, 0);
            var rmsg = '';
            var smsg = '';
            if (parseFloat(requiredFlag) > 0) {
                rmsg = 'r-' + requiredFlag;
                changeProperty(tagName + '_required', 'value', '*');
            } else {
                changeProperty(tagName + '_required', 'value', '');
            }
            if (parseFloat(showFlag) > 0) {
                smsg = 's-' + showFlag;
                changeStyle(tagName + '_div', 'display', 'block');
            } else {
                changeStyle(tagName + '_div', 'display', 'none');
            }
            if (rmsg != '' || smsg != '') {
                debug_alert_msg = debug_alert_msg + (rmsg + (' ' + (smsg + (' ' + (name + (' ' + (code + (' ' + (tagName + '\\n')))))))));
            }
        }
    }
    page_reload();
};
lua_jjbx.pwd_encrypt_init = function (resParams, reqParams, initCallBackArg) {
    if (formatNull(resParams) === '') {
        globalTable['PwdEncryptInitCallBackArg'] = initCallBackArg;
        invoke_trancode_donot_checkRepeat('jjbx_service', 'app_service', { TranCode: 'PwdEncryptVi' }, lua_jjbx.pwd_encrypt_init, {}, all_callback, { CloseLoading: 'true' });
    } else {
        var res = json2table(resParams['responseBody']);
        var viKey = vt('ViKey', res);
        if (viKey === '') {
            alertToast1('服务异常');
        } else {
            var PwdEncryptInitCallBackArg = formatNull(globalTable['PwdEncryptInitCallBackArg'], {});
            globalTable[PwdEncryptInitCallBackArg] = '';
            PwdEncryptInitCallBackArg['EncryptViKey'] = viKey;
            lua_system.do_function('pwd_encrypt_call', PwdEncryptInitCallBackArg);
        }
    }
};
lua_jjbx.encyrpt_password = function (pwd, encryptViKey) {
    var pwdEncType = vt('PwdEncType', configTable);
    var pwd = formatNull(pwd);
    var encyrptPwd = '';
    if (pwdEncType === 'SM') {
        var sm2Key = vt('PwdEncSm2Key', configTable);
        var sm4Key = vt('PwdEncSm4Key', configTable);
        var viKey = formatNull(encryptViKey);
        var argListTable = [
            pwd,
            sm2Key,
            sm4Key,
            viKey
        ];
        if (lua_form.arglist_check_empty(argListTable) === 'true') {
            var encryptArgTable = {
                sm2Key: sm2Key,
                sm4Key: sm4Key,
                viKey: viKey,
                pwd: pwd
            };
            var encryptArgJson = table2json(encryptArgTable);
            encyrptPwd = ryt.encrypt_password(encryptArgJson);
        } else {
            alertToast1('加密失败');
        }
    } else if (pwdEncType === 'RSA') {
        encyrptPwd = ryt.doEncyrptInput(pwd);
    } else {
        alert('加密方式未配置\uFF0C请检查');
    }
    return encyrptPwd;
};
lua_jjbx.search_cdr = function (cdrEleName) {
    var cdrEleName = formatNull(cdrEleName, 'search_cdr_text');
    var cdrName = getValue(cdrEleName);
    if (cdrName != '') {
        var ReqParams = {
            peoplename: cdrName,
            searchFlag: 'authDept'
        };
        lua_jjbx.do_search_cdr('', ReqParams);
    } else {
    }
};
lua_jjbx.do_search_cdr = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['TranCode'] = 'forPsnApp';
        invoke_trancode_noloading('jjbx_process_query', 'consumption_serial', ReqParams, lua_jjbx.do_search_cdr, {});
    } else {
        var res = json2table(ResParams['responseBody']);
        var htmlOption = '';
        var cdrSearchResList = vt('list', res);
        var cdrSearchCounts = cdrSearchResList.length;
        if (cdrSearchCounts > 0) {
            globalTable['cdrSearchResList'] = cdrSearchResList;
            for (var [key, value] in pairs(cdrSearchResList)) {
                var showCdrWrokId = vt('workid', value);
                var showCdrInfo = vt('name', value) + ('\u3000' + vt('deptName', value));
                htmlOption = htmlOption + ('[[\n                    <div class="search_people_option_div" border="0" onclick="lua_jjbx.select_cdr(]]' + (key + ('[[)">\n                        <label class="search_people_res_info1_label" name="workID">]]' + (showCdrWrokId + ('[[</label>\n                        <label class="search_people_res_info2_label" name="nameAndDept">]]' + (showCdrInfo + '[[</label>\n                        <div class="space_05_div" border="0"/>\n                        <line class="search_people_line" />\n                    </div>\n                ]]'))))));
            }
        } else {
            htmlOption = '[[\n                <div class="search_people_none_div" border="0">\n                    <label class="search_people_none_label" value="查无此人"></label>\n                </div>\n            ]]';
        }
        var htmlContent = '[[\n            <div class="search_people_list_div" border="0" name="search_people_list_div">\n                ]]' + (htmlOption + '[[\n            </div>\n        ]]');
        document.getElementsByName('search_people_list_div')[1].setInnerHTML(htmlContent);
        var cdrOptionHeight = 72;
        var cdrListDivHeight = cdrOptionHeight * 3;
        changeStyle('search_people_list_div', 'height', tostring(cdrListDivHeight));
    }
};
lua_jjbx.select_cdr = function (index) {
    var cdrInfo = '';
    if (index === 'cdr_by_self') {
        cdrInfo = 'cdr_by_self';
    } else {
        cdrInfo = globalTable['cdrSearchResList'][index];
    }
    lua_page.div_page_ctrl();
    lua_system.do_function('select_cdr_call', cdrInfo);
};
lua_jjbx.check_authority_by_funcode = function (ResParams, ReqParams) {
    var ResParams = formatNull(ResParams);
    if (ResParams === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['TranCode'] = 'CheckFuncAuthorityByFuncode';
        invoke_trancode_noloading('jjbx_service', 'app_service', ReqParams, lua_jjbx.check_authority_by_funcode, {}, all_callback, { CloseLoading: 'true' });
    } else {
        var res = json2table(ResParams['responseBody']);
        var errorNo = vt('errorNo', res);
        var ReqFunCode = vt('ReqFunCode', res);
        var cacheArgName = 'Authority_' + ReqFunCode;
        var CallFun = vt('CallFun', res);
        var CallArg = vt('CallArg', res);
        if (errorNo === '000000') {
            globalTable[cacheArgName] = '1';
        } else {
            globalTable[cacheArgName] = '0';
            changeStyle('tsqksm_div', 'display', 'none');
        }
        if (CallFun != '') {
            lua_system.do_function(CallFun, CallArg);
        }
    }
};
lua_jjbx.sp_file_dl = function (FileSeq) {
    var FileSeq = formatNull(FileSeq);
    if (FileSeq === '') {
        alert('下载失败');
        return;
    } else {
        var DlUrl = systemTable['ServerProtectFileDlUrl'] + FileSeq;
        lua_system.download_file(DlUrl);
    }
};
lua_jjbx.update_upload_counts_show = function (uploadedcounts) {
    var uploadedcounts = formatNull(uploadedcounts, '0');
    changeProperty('fj_title', 'value', '已上传' + (uploadedcounts + '个'));
};
jjbx_transfer = function (billNo) {
    globalTable['billNo_djzb'] = billNo;
    invoke_page('jjbx_process_bill/xhtml/process_bill_transfer_verify.xhtml', page_callback, null);
};
jjbx_unTransfer = function (billNo) {
    globalTable['billNo_djzb'] = billNo;
    invoke_page('jjbx_process_bill/xhtml/process_bill_transfer_cancel.xhtml', page_callback, null);
};
jjbx_answerTransfer_upload = function () {
    globalTable['UploadEnclosurePicReloadFlag'] = '1';
    globalTable['UploadEnclosurePicBillNo'] = globalTable['billNo_djzb'];
    globalTable['UploadEnclosurePicBillType'] = globalTable['djlxbm'];
    var alertPageArg = '{' + ('\\"pageTag\\":\\"upload_pic\\"' + ('' + '}'));
    alert_page(alertPageArg);
};
lua_jjbx.update_answer_transfer_enclosure_call = function (params) {
    close_loading();
    var responseBody = json2table(params['responseBody']);
    if (responseBody['BillFileQryErrorNo'] === '000000') {
        lua_jjbx.update_upload_counts_show(formatNull(responseBody['PcEnclosureTotalCounts'], '0'));
    } else {
        alert(responseBody['BillFileQryErrorMsg']);
    }
};
jjbx_showAnswerTransfer = function (billNo) {
    globalTable['billNo_djzb'] = billNo;
    var ReqParams = { billNo: billNo };
    lua_jjbx.show_answer_transfer_window('', ReqParams);
};
lua_jjbx.show_answer_transfer_window = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['BusinessType'] = 'bill_index';
        ReqParams['TranCode'] = 'getYXSCFlagAnswer';
        invoke_trancode_donot_checkRepeat('jjbx_process_query', 'process_bill', ReqParams, lua_jjbx.show_answer_transfer_window, {}, all_callback, { CloseLoading: 'false' });
    } else {
        var responseBody = json2table(ResParams['responseBody']);
        globalTable['djlxbm'] = responseBody['bill'][1]['djlxbm'];
        var yxscFlagAnswer = formatNull(responseBody['yxscFlagAnswer']);
        if (yxscFlagAnswer === '1') {
            var QueryEnclosureArg = {
                billNo: globalTable['billNo_djzb'],
                ReloadFlag: '1',
                callback: 'lua_jjbx.update_answer_transfer_enclosure_call'
            };
            globalTable['temp_reloadFlag'] = '1';
            lua_upload.query_enclosure_pic(QueryEnclosureArg);
        }
        changeProperty('do_operate_input_textarea', 'value', '');
        var RenderArg = {
            title: '转办回复',
            inputhold: '请输入',
            inputmax: '50',
            btntext: '确定',
            btnfun: 'lua_jjbx.answerTransfer()',
            showUploadButton: yxscFlagAnswer,
            uploadBtnFun: 'jjbx_answerTransfer_upload()'
        };
        do_render_input_alert_window(RenderArg);
        show_do_operate_window('do_operate_bg_div');
        close_loading();
    }
};
lua_jjbx.answerTransfer = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var msg = getValue('do_operate_input_textarea');
        if (msg === '') {
            alert('请输入转办回复内容');
            return;
        }
        invoke_trancode_noloading('jjbx_process_query', 'process_bill', {
            BusinessType: 'bill_index',
            TranCode: 'answerTransferMsg',
            billNo: globalTable['billNo_djzb'],
            msg: msg
        }, lua_jjbx.answerTransfer, {});
    } else {
        var responseBody = json2table(ResParams['responseBody']);
        if (responseBody['errorNo'] === '000000') {
            globalTable['temp_reloadFlag'] = '';
            close_do_operate_window('do_operate_bg_div');
            var InitCallFuncName = vt('InitCallFuncName', globalTable, 'init');
            globalTable['InitCallFuncName'] = '';
            alertToast('0', C_Toast_SuccessedMsg, '', InitCallFuncName, '');
        } else {
            alert(responseBody['errorMsg']);
        }
    }
};
getTransferMsg = function (processList) {
    for (let i = 1; processList.length; i++) {
        if (processList[i]['status'] === 'turn') {
            var msg = processList[i]['opinion'];
            return msg;
        }
    }
    return '';
};
lua_jjbx.getJdTrustedLoginUrl = function (ResParams, ReqParams) {
    var PCConfigListsTable = vt('PCConfigListsTable', globalTable);
    var cgSwitch = vt('SYS0017', PCConfigListsTable);
    if (cgSwitch === '是' || globalTable['userType'] === '2') {
        if (formatNull(ResParams) === '') {
            var ReqParams = formatNull(ReqParams);
            ReqParams['TranCode'] = 'getJdTrustedLoginUrl';
            invoke_trancode('jjbx_service', 'online_shopping', ReqParams, lua_jjbx.getJdTrustedLoginUrl, {});
        } else {
            var responseBody = json2table(ResParams['responseBody']);
            if (responseBody['errorNo'] === '000000') {
                if (responseBody['url'] === '') {
                    alert('当前用户暂无权限');
                } else {
                    globalTable['webview_url'] = responseBody['url'];
                    globalTable['webview_page_title'] = '京东采购';
                    globalTable['webview_back2jjbx'] = '返回极简';
                    invoke_page('jjbx_page/xhtml/webview_page.xhtml', page_callback, null);
                }
            } else {
                alert(responseBody['errorMsg']);
            }
        }
    } else {
        alert('系统升级中\uFF0C暂不支持使用');
    }
};
lua_jjbx.alert_zdy = function () {
    var title = formatNull(globalTable['zdy2Title']);
    var content = formatNull(globalTable['zdy2_value']);
    if (content != '') {
        if (ryt.getLengthByStr(content) > 12) {
            alert_confirm(title, content, '', '确定', '');
        }
    }
};
lua_jjbx.alert_zdy2 = function (title, content, cutNum, flag) {
    var title = formatNull(title);
    var content = formatNull(content);
    if (content != '') {
        if (flag === '1') {
            if (ryt.getLengthByStr(content) > cutNum) {
                alert_confirm(title, content, '', '确定', '');
            }
        } else {
            if (ryt.getLengthByStr(title + ('\uFF1A' + content)) > cutNum) {
                alert_confirm(title, content, '', '确定', '');
            }
        }
    }
};
lua_jjbx.getZdy2TitleByConfig = function (queryConfig) {
    for (let i = 1; queryConfig.length; i++) {
        if (queryConfig[i]['modelType'] === '2' && queryConfig[i]['fieldName'] === 'zdy2') {
            globalTable['zdy2Title'] = queryConfig[i]['fieldDispName'];
            globalTable['zdy2Display'] = queryConfig[i]['fieldVisible'];
            return;
        }
    }
};
lua_jjbx.getPageType = function () {
    if (globalTable['pageType'] === 'approve' || vt('ifApproverEdit', globalTable) === 'true') {
        return '3';
    } else if (globalTable['pageType'] === 'look') {
        return '1';
    } else {
        return '2';
    }
};
lua_jjbx.reset_config_arg = function (ResetArgName) {
    if (ResetArgName === 'JJBX_AppPageListQryArg') {
        JJBX_AppPageListQryArg.AppQryPageNum = 1;
        JJBX_AppPageListQryArg.AppQryPageSize = 10;
        JJBX_AppPageListQryArg.ClientLastItemIndex = 1;
        JJBX_AppPageListQryArg.LoadedCounts = 0;
        JJBX_AppPageListQryArg.ReloadAppQryPage = 'true';
    }
};
lua_jjbx.pc_cache_arg_ctrl = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        var CtrlCallBackFunc = vt('CtrlCallBackFunc', ReqParams);
        ReqParams['TranCode'] = 'PcCacheArgCtrl';
        invoke_trancode('jjbx_service', 'app_service', ReqParams, lua_jjbx.pc_cache_arg_ctrl, { CtrlCallBackFunc: CtrlCallBackFunc }, all_callback, { CloseLoading: 'false' });
    } else {
        var CtrlCallBackFunc = vt('CtrlCallBackFunc', ResParams);
        var res = json2table(ResParams['responseBody']);
        var value = vt('value', res);
        lua_system.do_function(CtrlCallBackFunc, { ArgValue: value });
    }
};
lua_jjbx.user_fun_match = function (MatchArg) {
    var MatchArg = formatNull(MatchArg);
    var FunCode = vt('FunCode', MatchArg);
    var MatchRes = {};
    if (FunCode != '') {
        var viewauthority = vt('viewauthority', companyTable);
        var FunCounts = viewauthority.length;
        var Matched = 'false';
        for (let i = 1; FunCounts; i++) {
            if (FunCode === viewauthority[i]) {
                Matched = 'true';
                break;
            }
        }
        MatchRes['Matched'] = Matched;
    }
    return MatchRes;
};
lua_jjbx.common_req = function (ReqParams) {
    var ReqParams = formatNull(ReqParams);
    ReqParams['TranCode'] = 'CommonInterfaceReq';
    var BusinessCall = vt('BusinessCall', ReqParams);
    ReqParams.BusinessCall = '';
    var BusinessParams = vt('BusinessParams', ReqParams);
    var BusinessParamsEncodeType = vt('BusinessParamsEncodeType', ReqParams);
    if (BusinessParamsEncodeType === 'base64') {
        ReqParams['BusinessParams'] = lua_format.base64_encode(BusinessParams);
    } else if (BusinessParamsEncodeType === 'url') {
        ReqParams['BusinessParams'] = lua_format.url_encode(BusinessParams);
    } else {
    }
    var CloseLoading = vt('CloseLoading', ReqParams, 'false');
    ReqParams.CloseLoading = '';
    var ReqFuncName = vt('ReqFuncName', ReqParams, 'invoke_trancode_donot_checkRepeat');
    ReqParams.ReqFuncName = '';
    var ReqUrlExplain = vt('ReqUrlExplain', ReqParams);
    var ReqAddr = vt('ReqAddr', ReqParams);
    if (ReqUrlExplain === '') {
        debug_alert('通用请求未对接口\uFF08' + (ReqAddr + '\uFF09进行说明'));
    }
    var dofunction = lua_format.str2fun(ReqFuncName);
    if (dofunction) {
        dofunction('jjbx_service', 'app_service', ReqParams, BusinessCall, {
            ResCallFunc: vt('ResCallFunc', ReqParams),
            ArgStr: vt('ArgStr', ReqParams)
        }, all_callback, { CloseLoading: CloseLoading });
    } else {
        debug_alert('请求函数未定义\uFF0C函数名' + funName);
    }
};
lua_jjbx.common_log_register = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['TranCode'] = 'CommonLogRegister';
        invoke_trancode_noloading('jjbx_service', 'app_service', ReqParams, lua_jjbx.common_log_register, {});
    } else {
    }
};
lua_jjbx.render_jjbx_banner = function (BannerIndex) {
    var BannerIndex = formatNull(BannerIndex, 1);
    var Banner1Html = '';
    var Banner2Html = '';
    var homeGifFlag = vt('homeGifFlag', globalTable, 'false');
    var myselfGifFlag = vt('myselfGifFlag', globalTable, 'false');
    var Banner1ClickFun = '';
    var Banner2ClickFun = '';
    if (BannerIndex === 1) {
        if (configTable['lua_debug'] === 'true') {
            Banner1ClickFun = 'lua_jjbx.banner_switch(1)';
        }
        Banner2ClickFun = 'lua_jjbx.banner_switch(2)';
        var Banner1ImgHtml = '';
        if (homeGifFlag === 'false') {
            Banner1ImgHtml = '[[\n                <jsonGIFView src="homedata" loop="no" loopCount="1" class="home_icon" height="28" width="28" onclick="]]' + (Banner1ClickFun + '[[" />\n            ]]');
        } else {
            Banner1ImgHtml = '[[\n                <img src="ico_home_red.png" class="home_icon" onclick="]]' + (Banner1ClickFun + '[[" />\n            ]]');
        }
        Banner1Html = '[[\n            <div class="home_button_div" name="home_button_div" border="0" onclick="]]' + (Banner1ClickFun + ('[[">\n                ]]' + (Banner1ImgHtml + ('[[\n                <label class="home_btn_selected_label" value="首页" name="home" onclick="]]' + (Banner1ClickFun + '[["></label>\n            </div>\n        ]]')))));
        Banner2Html = '[[\n            <div class="myself_button_div" border="0" onclick="]]' + (Banner2ClickFun + ('[[">\n                <img src="ico_mine.png" class="home_icon" onclick="]]' + (Banner2ClickFun + ('[[" />\n                <label class="home_btn_label" value="我的" name="myself" onclick="]]' + (Banner2ClickFun + '[[" />\n            </div>\n        ]]')))));
        globalTable['homeGifFlag'] = 'true';
    } else {
        Banner1ClickFun = 'lua_jjbx.banner_switch(1)';
        if (configTable['lua_debug'] === 'true') {
            Banner2ClickFun = 'lua_jjbx.banner_switch(2)';
        }
        Banner1Html = '[[\n            <div class="home_button_div" name="home_button_div" border="0" onclick="]]' + (Banner1ClickFun + ('[[">\n                <img src="ico_home.png" class="home_icon" onclick="]]' + (Banner1ClickFun + ('[[" />\n                <label class="home_btn_label" value="首页" name="home" onclick="]]' + (Banner1ClickFun + '[[" />\n            </div>\n        ]]')))));
        var Banner2ImgHtml = '';
        if (myselfGifFlag === 'false') {
            Banner2ImgHtml = '[[\n                <jsonGIFView src="minedata" loop="no" loopCount="1" class="home_icon" height="28" width="28" onclick="]]' + (Banner2ClickFun + '[[" />\n            ]]');
        } else {
            Banner2ImgHtml = '[[\n                <img src="ico_mine_red.png" class="home_icon" onclick="]]' + (Banner2ClickFun + '[[" />\n            ]]');
        }
        Banner2Html = '[[\n            <div class="myself_button_div" border="0" onclick="]]' + (Banner2ClickFun + ('[[">\n                ]]' + (Banner2ImgHtml + ('[[\n                <label class="home_btn_selected_label" value="我的" name="myself" onclick="]]' + (Banner2ClickFun + '[[" />\n            </div>\n        ]]')))));
        globalTable['myselfGifFlag'] = 'true';
    }
    var BannerHtml = '[[\n        <div class="bottom_button_div" border="0" name="bottom_button_div">\n            ]]' + (Banner1Html + ('[[\n            <div class="line_bottom_icon_div" border="0">\n                <img src="local:line_bottom.png" class="line_bottom_icon" />\n            </div>\n            ]]' + (Banner2Html + '[[\n        </div>\n    ]]')));
    document.getElementsByName('bottom_button_div')[1].setInnerHTML(BannerHtml);
    page_reload();
};
lua_jjbx.banner_switch = function (BannerIndex) {
    if (BannerIndex === 2) {
        globalTable['homeGifFlag'] = 'false';
        var PageUrl = 'jjbx_myInfo/xhtml/myInfo.xhtml';
        if (globalTable['MyinfoHeadFinish'] != 'true') {
            invoke_page(PageUrl, page_callback, { CloseLoading: 'false' });
        } else {
            invoke_page_noloading_checkRepeat(PageUrl, page_callback, null);
        }
    } else {
        globalTable['myselfGifFlag'] = 'false';
        lua_menu.to_index_page('back');
    }
};
lua_jjbx.call_service = function (Type) {
    if (Type === '1') {
        tel_call(JJBX_COMPANY_INFO.service_number);
    } else if (Type === '2') {
        mail_call(JJBX_COMPANY_INFO.service_mail);
    } else {
    }
};
lua_jjbx.allow_add_other_bank_card = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['ReqAddr'] = 'uap/psn/getAddNoCzFlag';
        ReqParams.BusinessCall = lua_jjbx.allow_add_other_bank_card;
        var ResCallFunc = vt('ResCallFunc', ReqParams);
        if (ResCallFunc === '') {
            debug_alert('查询是否允许添加他行卡回调未指定');
        } else {
            lua_jjbx.common_req(ReqParams);
        }
    } else {
        var res = json2table(ResParams['responseBody']);
        var addNoCzFlag = vt('addNoCzFlag', res);
        var AllowAddOtherBankCard = '0';
        if (addNoCzFlag === '是') {
            AllowAddOtherBankCard = '1';
        }
        var ResCallFunc = vt('ResCallFunc', ResParams);
        lua_system.do_function(ResCallFunc, { AllowAddOtherBankCard: AllowAddOtherBankCard });
    }
};
lua_jjbx.qry_city = function (ResParams, ReqParams) {
    var cityList = vt('cityList', globalTable);
    if (cityList === '') {
        lua_jjbx.do_qry_city(ResParams, ReqParams);
    } else {
        var ResCallFunc = vt('ResCallFunc', ReqParams);
        lua_system.do_function(ResCallFunc);
    }
};
lua_jjbx.do_qry_city = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams, {});
        invoke_trancode_donot_checkRepeat('jjbx_process_query', 'process_bill', {
            BusinessType: 'travel_process_bill',
            TranCode: 'Cityquery'
        }, lua_jjbx.do_qry_city, { ResCallFunc: vt('ResCallFunc', ReqParams) }, all_callback, { CloseLoading: 'false' });
    } else {
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            globalTable['cityList'] = vt('list', res);
        } else {
            alert(res['errorMsg']);
        }
        var ResCallFunc = vt('ResCallFunc', ResParams);
        lua_system.do_function(ResCallFunc);
    }
};
lua_jjbx.get_invoice_tag_name = function (Code) {
    var res = {};
    for (let i = 1; JJBX_InvoiceContentList.length; i++) {
        var ItemData = formatNull(JJBX_InvoiceContentList[i]);
        var codeC = vt('code', ItemData);
        if (Code === codeC) {
            res = ItemData;
            break;
        }
    }
    return res;
};
lua_jjbx.split_str = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        invoke_trancode_donot_checkRepeat('jjbx_service', 'app_service', {
            TranCode: 'strSplit',
            str: ReqParams['str']
        }, lua_jjbx.split_str, { callFunName: vt('callFunName', ReqParams) }, all_callback, { CloseLoading: 'false' });
    } else {
        close_loading();
        var res = json2table(ResParams['responseBody']);
        var callFunName = ResParams['callFunName'];
        var callFunArg = res['list'];
        if (callFunName != '') {
            lua_system.do_function(callFunName, callFunArg);
        }
    }
};
module.exports = { lua_jjbx: lua_jjbx };