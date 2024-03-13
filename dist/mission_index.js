const lua_index_mission = require('./index_mission');
const lua_mission = require('./mission');
const lua_jjbx = require('./jjbx');
const lua_system = require('./system');
const lua_ask = require('./ask');
const lua_format = require('./format');
const lua_page = require('./page');
const lua_upload = require('./upload');
const lua_menu = require('./menu');
const lua_login = require('./login');
lua_index_mission = {};
lua_index_mission.analysis_show_lead = function () {
    var IndexLeadPageVersion = vt('IndexLeadPageVersion', configTable);
    var show_lead = lua_index_mission.need_lead(IndexLeadPageVersion);
    if (lua_mission.index_debug() === 'true') {
        show_lead = 'true';
    }
    if (show_lead === 'true') {
        lua_index_mission.create_index_lead_page();
        set_db_value('IndexLeadPageVersion', IndexLeadPageVersion);
        index_page_iPhoneX_ctrl('hide');
        show_ele('lead_page_bg_div');
        set_android_top_bar_color('#090813');
        lua_index_mission.show_lead(1);
    } else {
        lua_mission.index_handle();
    }
};
lua_index_mission.create_index_lead_page = function () {
    height_adapt('lead_page_bg_div', 0, 0);
    var lead_page_icon_html = '';
    var lead_page_btn_html = '';
    for (let i = 1; 4; i++) {
        var index = tostring(i);
        var next = tostring(i + 1);
        lead_page_icon_html = lead_page_icon_html + ('[[\n            <img src="local:lead_page_icon]]' + (index + ('[[.png" class="lead_page_icon]]' + (index + '[[" name="lead_page_icon"/>\n        ]]'))));
        var btn_img_src = 'local:lead_page_btn' + (index + '.png');
        var btn_class = 'lead_page_btn_none';
        var btn_onclick = 'lua_index_mission.show_lead(' + (next + ')');
        if (i === 1) {
            btn_img_class = 'lead_page_btn_block';
        } else if (i === 4) {
            btn_onclick = 'lua_index_mission.close_lead()';
        }
        lead_page_btn_html = lead_page_btn_html + ('[[\n            <img src="]]' + (btn_img_src + ('[[" class="]]' + (btn_class + ('[[" name="lead_page_btn" onclick="]]' + (btn_onclick + '[[" />\n        ]]'))))));
    }
    var lead_page_html = '[[\n        <div class="lead_page_bg_div" name="lead_page_bg_div" border="0" onclick="">\n            <div class="lead_page_div_]]' + (systemTable['SysLayoutStyle'] + ('[[" border="0" name="lead_page_div">\n                ]]' + (lead_page_icon_html + ('[[\n                ]]' + (lead_page_btn_html + '[[\n            </div>\n        </div>\n    ]]')))));
    document.getElementsByName('lead_page_bg_div')[1].setInnerHTML(lead_page_html);
    height_adapt('lead_page_div', 0);
    page_reload();
};
lua_index_mission.need_lead = function (ServerV) {
    var LocalV = get_db_value('IndexLeadPageVersion');
    var ServerV = formatNull(ServerV);
    var ShowIndexLeadPage = 'false';
    if (LocalV === '') {
        if (ServerV === '') {
        } else {
            ShowIndexLeadPage = 'true';
        }
    } else {
        if (LocalV === ServerV) {
        } else {
            ShowIndexLeadPage = 'true';
        }
    }
    return ShowIndexLeadPage;
};
lua_index_mission.show_lead = function (index) {
    var nextPages = document.getElementsByName('lead_page_icon');
    var nextBtns = document.getElementsByName('lead_page_btn');
    for (let i = 1; nextBtns.length; i++) {
        if (i === index) {
            nextBtns[i].setStyleByName('display', 'block');
            nextPages[i].setStyleByName('display', 'block');
        } else {
            nextBtns[i].setStyleByName('display', 'none');
            nextPages[i].setStyleByName('display', 'none');
        }
    }
};
lua_index_mission.close_lead = function () {
    index_page_iPhoneX_ctrl('show');
    set_android_top_bar_image('index_top_bar_up.png');
    hide_ele('lead_page_bg_div');
    lua_mission.index_handle();
};
lua_index_mission.analysis_show_confirm_collection = function () {
    lua_index_mission.query_Common_hint('', {});
};
lua_index_mission.query_Common_hint = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        ReqParams = formatNull(ReqParams, {});
        ReqParams['ReqAddr'] = 'pubUserHint/queryCommonHint';
        ReqParams['ReqUrlExplain'] = '查询消息是否弹窗';
        var BusinessParams = { channal: vt('channal', ReqParams, '009') };
        ReqParams['BusinessParams'] = table2json(BusinessParams);
        ReqParams['BusinessCall'] = lua_index_mission.query_Common_hint;
        lua_jjbx.common_req(ReqParams);
    } else {
        var responseBody = json2table(ResParams['responseBody']);
        if (vt('value', responseBody) === '0') {
            lua_index_mission.do_analysis_show_confirm_collection();
        } else {
            lua_mission.index_handle();
        }
    }
};
lua_index_mission.do_analysis_show_confirm_collection = function (params) {
    if (MsgCenterFlag === 'disenable') {
        lua_mission.index_handle();
    } else {
        var params = formatNull(params);
        if (params === '') {
            var ReqParams = {};
            ReqParams['ReqAddr'] = 'bankDepositReconciliation/querySubBankTransactionRecord';
            ReqParams['ReqUrlExplain'] = '查询发布的对账待确认消息';
            var BusinessParams = {
                pagenum: '1',
                pagesize: '1',
                status: '0'
            };
            ReqParams['BusinessParams'] = table2json(BusinessParams);
            ReqParams['BusinessCall'] = lua_index_mission.do_analysis_show_confirm_collection;
            lua_jjbx.common_req(ReqParams);
        } else {
            var responseBody = json2table(params['responseBody']);
            var showMsgList = vt('recordList', responseBody);
            var showMsgListCounts = showMsgList.length;
            if (showMsgListCounts > 0) {
                var MsgItemTable = {};
                for (var [key, value] in pairs(showMsgList)) {
                    var ItemData = formatNull(value);
                    ItemData['messageSubclassEn'] = 'bankTransactionAuthorization';
                    var MsgCtrlIndex = tostring(key);
                    var MsgTitle = '银行对账流水';
                    var isShowCheckBox = 'true';
                    var MsgContent = '您有收付款业务待确认\uFF0C请及时前往极简报销查看确认通知并发起单据处理\u3002';
                    var Timestamp = vt('transactionDate', ItemData);
                    var MsgTypeCode = '';
                    var res3 = '';
                    var MsgTypeName = '';
                    if (MsgTypeCode === '1') {
                        MsgTypeName = '业务消息';
                    } else if (MsgTypeCode === '2') {
                        MsgTypeName = '企业公告';
                    } else if (MsgTypeCode === '3') {
                        MsgTypeName = '产品消息';
                    } else {
                        MsgTypeName = '发布消息';
                    }
                    var popupFlag = '';
                    var pkNotimsg = '';
                    var pkMsgPublishList = '';
                    var replyState = '';
                    var AddItem = {
                        MsgCtrlIndex: MsgCtrlIndex,
                        MsgTitle: MsgTitle,
                        MsgContent: MsgContent,
                        MsgTypeName: MsgTypeName,
                        MsgTime: string.sub(Timestamp, 1, 10),
                        MsgIconName: 'msg_item_bg.png',
                        IsShowCheckBox: isShowCheckBox,
                        MsgTypeCode: MsgTypeCode,
                        MsgPopupFlag: popupFlag,
                        MsgNotimsg: pkNotimsg,
                        Res3: res3,
                        MsgPublishList: pkMsgPublishList,
                        replyState: replyState,
                        isDZD: 'true',
                        MsgInfoData: ItemData
                    };
                    table.insert(MsgItemTable, AddItem);
                }
                var ClientDataTable = {
                    Title: '重要消息',
                    WidgetBgIconName: 'msg_box_bg.png',
                    DetailBtnIconName: 'msg_box_detail_btn.png',
                    DetailBtnContent: '马上查阅',
                    CheckBoxMsgContent: '下次不再提示',
                    CheckBoxMsgDefaultStatus: C_CheckBoxMsgDefaultStatus,
                    ClickFunName: 'lua_system.msg_popup_call',
                    MsgItem: MsgItemTable
                };
                var ClientDataJson = table2json(ClientDataTable);
                globalTable['MsgPopupClientDataTable'] = ClientDataTable;
                lua_system.open_msg_popup(ClientDataJson, 'lua_index_mission.close_msg_popup_call_mission');
            } else {
                lua_mission.index_handle();
            }
        }
    }
};
lua_index_mission.analysis_show_msg = function () {
    lua_index_mission.do_analysis_show_msg();
};
lua_index_mission.do_analysis_show_msg = function (params) {
    lua_mission.index_finish(globalTable['IndexPageMissionIndex'], 'MC');
    globalTable['IndexPageMissionIndex'] = null;
    if (MsgCenterFlag === 'disenable') {
        lua_mission.index_handle();
    } else {
        var params = formatNull(params);
        if (params === '') {
            invoke_trancode_donot_checkRepeat('jjbx_index', 'query_msg', { TranCode: 'QryPopupMsg' }, lua_index_mission.do_analysis_show_msg, {}, all_callback, { CloseLoading: 'false' });
        } else {
            var responseBody = json2table(params['responseBody']);
            var showMsgList = vt('list', responseBody);
            var showMsgListCounts = showMsgList.length;
            if (showMsgListCounts > 0) {
                var MsgItemTable = {};
                for (var [key, value] in pairs(showMsgList)) {
                    var ItemData = formatNull(value);
                    var MsgCtrlIndex = tostring(key);
                    var MsgTitle = vt('headline', ItemData);
                    var isShowCheckBox = 'true';
                    var MsgContent = vt('content', ItemData);
                    var Timestamp = vt('ts', ItemData);
                    var MsgTypeCode = vt('msgType', ItemData);
                    var res3 = vt('res3', ItemData);
                    var MsgTypeName = '';
                    if (MsgTypeCode === '1') {
                        MsgTypeName = '业务消息';
                    } else if (MsgTypeCode === '2') {
                        MsgTypeName = '企业公告';
                    } else if (MsgTypeCode === '3') {
                        MsgTypeName = '产品消息';
                    } else {
                        MsgTypeName = '发布消息';
                    }
                    var popupFlag = vt('popupFlag', ItemData);
                    var pkNotimsg = vt('pkNotimsg', ItemData);
                    var pkMsgPublishList = vt('pkMsgPublishList', ItemData);
                    var replyState = vt('replyState', ItemData);
                    var AddItem = {
                        MsgCtrlIndex: MsgCtrlIndex,
                        MsgTitle: MsgTitle,
                        MsgContent: MsgContent,
                        MsgTypeName: MsgTypeName,
                        MsgTime: string.sub(Timestamp, 1, 10),
                        MsgIconName: 'msg_item_bg.png',
                        IsShowCheckBox: isShowCheckBox,
                        MsgTypeCode: MsgTypeCode,
                        MsgPopupFlag: popupFlag,
                        MsgNotimsg: pkNotimsg,
                        Res3: res3,
                        MsgPublishList: pkMsgPublishList,
                        replyState: replyState,
                        isDZD: 'false',
                        MsgInfoData: ItemData
                    };
                    table.insert(MsgItemTable, AddItem);
                }
                var ClientDataTable = {
                    Title: '重要消息',
                    WidgetBgIconName: 'msg_box_bg.png',
                    DetailBtnIconName: 'msg_box_detail_btn.png',
                    DetailBtnContent: '马上查阅',
                    CheckBoxMsgContent: '下次不再提示',
                    CheckBoxMsgDefaultStatus: C_CheckBoxMsgDefaultStatus,
                    ClickFunName: 'lua_system.msg_popup_call',
                    MsgItem: MsgItemTable
                };
                var ClientDataJson = table2json(ClientDataTable);
                globalTable['MsgPopupClientDataTable'] = ClientDataTable;
                lua_system.open_msg_popup(ClientDataJson, 'lua_index_mission.close_msg_popup_call_mission');
            } else {
                lua_mission.index_handle();
            }
        }
    }
};
lua_index_mission.msg_popup_close_call = function (ClickArg) {
    lua_index_mission.popup_msg_batch_read();
    lua_index_mission.close_msg_popup_call_mission();
};
lua_index_mission.msg_popup_click_call = function (ClickArg) {
    var ClientDataTable = vt('MsgPopupClientDataTable', globalTable);
    var MsgItem = vt('MsgItem', ClientDataTable);
    var ChooseMsgItem = formatNull(MsgItem[parseFloat(ClickArg)]);
    var MsgCtrlIndex = vt('MsgCtrlIndex', ChooseMsgItem);
    var MsgTypeCode = vt('MsgTypeCode', ChooseMsgItem);
    var MsgPopupFlag = vt('MsgPopupFlag', ChooseMsgItem);
    var MsgPublishList = vt('MsgPublishList', ChooseMsgItem);
    var Res3 = vt('Res3', ChooseMsgItem);
    var replyState = vt('replyState', ChooseMsgItem);
    var MsgInfoData = vt('MsgInfoData', ChooseMsgItem);
    var messageSubclassEn = vt('messageSubclassEn', MsgInfoData);
    lua_index_mission.close_msg_popup_call_mission();
    lua_index_mission.popup_msg_batch_read();
    if (messageSubclassEn === 'functionGuide' || messageSubclassEn === 'frequentQuestion') {
        lua_ask.ask_msg_jump({ messageSubclassEn: messageSubclassEn });
    } else if (messageSubclassEn === 'bankTransactionAuthorization') {
        invoke_page('jjbx_msg_center/xhtml/msg_account_checking.xhtml', page_callback, {
            CloseLoading: 'false',
            ClickArg: ClickArg
        });
    } else {
        if (replyState === '0' || replyState === '1') {
            globalTable['DelpkNotimsg'] = MsgNotimsg;
            globalTable['DelpkMsgPublishList'] = MsgPublishList;
            invoke_page('jjbx_msg_center/xhtml/msg_reply.xhtml', page_callback, null);
        } else if (Res3 != '') {
            go_to_jkd('', Res3);
        } else {
            globalTable['webview_back_fun'] = 'lua_menu.back_to_msg_center()';
            var qryArg = {
                PkMsgPublishList: MsgPublishList,
                NeedBase64: 'true',
                MsgType: MsgTypeCode,
                PopupFlag: MsgPopupFlag
            };
            lua_jjbx.qry_msg_h5_link(qryArg);
        }
    }
};
go_to_jkd = function (params, billPId) {
    if (formatNull(params) === '') {
        invoke_trancode('jjbx_process_query', 'receipt_service', {
            billPId: billPId,
            TranCode: 'qryDeductionAccountByBillPId'
        }, go_to_jkd, {}, all_callback, { CloseLoading: 'false' });
    } else {
        var responseBody = json2table(params['responseBody']);
        if (responseBody['errorNo'] === '000000') {
            globalTable['payInDetailData'] = responseBody['deduction'];
            globalTable['from_msg'] = '1';
            invoke_page('jjbx_receipt/xhtml/contribution_detail.xhtml', page_callback, { CloseLoading: 'false' });
        } else {
            alert(responseBody['errorMsg']);
        }
    }
};
lua_index_mission.msg_popup_checkbox_call = function (ClickArg) {
    var MsgPopupCheckBoxStatus = '';
    var arg = splitUtils(ClickArg, ',');
    if (arg[1] === '1') {
        MsgPopupCheckBoxStatus = '1';
    } else {
        MsgPopupCheckBoxStatus = '0';
    }
    globalTable['MsgPopupCheckBoxStatus'] = MsgPopupCheckBoxStatus;
};
lua_index_mission.popup_msg_batch_read = function () {
    var CheckBoxStatus = formatNull(globalTable['MsgPopupCheckBoxStatus'], C_CheckBoxMsgDefaultStatus);
    if (CheckBoxStatus === '1') {
        var MsgPopupClientDataTable = vt('MsgPopupClientDataTable', globalTable);
        var MsgItemList = vt('MsgItem', MsgPopupClientDataTable);
        var MsgPublishLists = '';
        var MsgIdLists = '';
        var MsgPopupFlagLists = '';
        var MsgIsDZD = '';
        for (var [key, value] in pairs(MsgItemList)) {
            MsgPublishLists = MsgPublishLists + (formatNull(value['MsgPublishList']) + ',');
            MsgIdLists = MsgIdLists + (formatNull(value['MsgNotimsg']) + ',');
            MsgPopupFlagLists = MsgPopupFlagLists + (formatNull(value['MsgPopupFlag']) + ',');
            MsgIsDZD = vt('isDZD', value);
        }
        MsgPublishLists = lua_format.delete_last_char(MsgPublishLists);
        MsgIdLists = lua_format.delete_last_char(MsgIdLists);
        MsgPopupFlagLists = lua_format.delete_last_char(MsgPopupFlagLists);
        globalTable['DelpkNotimsg'] = MsgIdLists;
        globalTable['DelpkMsgPublishList'] = MsgPublishLists;
        globalTable['popupFlag'] = MsgPopupFlagLists;
        if (MsgIsDZD === 'true') {
            lua_index_mission.add_common_hint('', {});
        } else {
            lua_jjbx.updMarkunreadFlag();
        }
    }
};
lua_index_mission.add_common_hint = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        ReqParams = formatNull(ReqParams, {});
        ReqParams['ReqAddr'] = 'pubUserHint/addCommonHint';
        ReqParams['ReqUrlExplain'] = '查询消息是否弹窗';
        var BusinessParams = {
            channal: vt('channal', ReqParams, '009'),
            value: '1'
        };
        ReqParams['BusinessParams'] = table2json(BusinessParams);
        ReqParams['BusinessCall'] = lua_index_mission.add_common_hint;
        lua_jjbx.common_req(ReqParams);
    } else {
        var responseBody = json2table(ResParams['responseBody']);
        if (responseBody['errorNo'] === '000000') {
        } else {
            alert(responseBody['errorMsg']);
        }
    }
};
lua_index_mission.close_msg_popup_call_mission = function () {
    lua_system.close_msg_popup();
    lua_mission.index_handle();
};
lua_index_mission.analysis_show_bill_evaluation = function () {
    lua_index_mission.do_analysis_show_bill_evaluation();
};
lua_index_mission.do_analysis_show_bill_evaluation = function (params) {
    var params = formatNull(params);
    var ShowBillEvaluation = formatNull(globalTable['ShowBillEvaluation']);
    if (lua_mission.index_debug() === 'true') {
        ShowBillEvaluation = '';
    }
    if (params === '') {
        if (ShowBillEvaluation === '') {
            globalTable['ShowBillEvaluation'] = 'Showed';
            invoke_trancode_donot_checkRepeat('jjbx_login', 'entrance', { TranCode: 'qryBillEvaluation' }, lua_index_mission.do_analysis_show_bill_evaluation, {}, all_callback, { CloseLoading: 'false' });
        }
    } else {
        var responseBody = json2table(params['responseBody']);
        var ShowEvaluationFlag = 'false';
        if (responseBody['errorNo'] === '000000' && responseBody['popFlag'] === '1' && globalTable['userAppraise'] === 'true') {
            ShowEvaluationFlag = 'true';
        }
        if (lua_mission.index_debug() === 'true') {
            ShowEvaluationFlag = 'true';
        }
        if (ShowEvaluationFlag === 'true') {
            globalTable['billEvaluationInfo'] = responseBody['billEvaluationInfo'];
            lua_index_mission.create_bill_evaluation();
            lua_index_mission.evaluation_page_ctrl('open');
            close_loading();
        } else {
            lua_mission.index_handle();
        }
    }
};
var evaluation_submit_params = {
    totalPoints: '',
    timelinessPoints: '',
    serviceAttitudePoints: '',
    sysFunctionPoints: '',
    otherSuggest: '',
    evaluateFlag: '',
    billEvaluaId: '',
    TranCode: ''
};
lua_index_mission.evaluation_star_choose = function (index, elementName) {
    var imgElement = document.getElementsByName(elementName + 'Img');
    var valueElement = elementName + 'Value';
    var imgSrc = '';
    var valueColor = '';
    var valueStr = '';
    imgSrc = 'pentacle_orange.png';
    valueColor = '#AFACAC';
    if (parseFloat(index) > 4) {
        valueStr = '非常满意';
    } else if (parseFloat(index) > 3) {
        valueStr = '满意';
    } else if (parseFloat(index) > 2) {
        valueStr = '一般';
    } else if (parseFloat(index) > 1) {
        valueStr = '差';
    } else {
        valueStr = '非常差';
    }
    changeProperty(valueElement, 'value', valueStr);
    changeStyle(valueElement, 'color', valueColor);
    for (let i = 1; imgElement.length; i++) {
        if (i <= parseFloat(index)) {
            imgElement[i].setPropertyByName('src', imgSrc);
        } else {
            imgElement[i].setPropertyByName('src', 'pentacle_white.png');
        }
    }
    if (elementName === 'entirety') {
        evaluation_submit_params.totalPoints = index;
    } else if (elementName === 'disposeTimeliness') {
        evaluation_submit_params.timelinessPoints = index;
    } else if (elementName === 'serveAttitude') {
        evaluation_submit_params.serviceAttitudePoints = index;
    } else if (elementName === 'systemFunction') {
        evaluation_submit_params.sysFunctionPoints = index;
    }
};
lua_index_mission.evaluation_suggest_tip = function (inputElement, showElement, showMaxLeng) {
    var elementValue = document.getElementsByName(inputElement)[1].getPropertyByName('value');
    var elementLen = ryt.getLengthByStr(elementValue);
    changeProperty(showElement, 'value', elementLen + ('/' + showMaxLeng));
    if (parseFloat(elementLen) > parseFloat(showMaxLeng)) {
        changeStyle(showElement, 'color', '#FF0000');
    } else {
        changeStyle(showElement, 'color', '#999999');
    }
};
lua_index_mission.evaluation_submit = function (params) {
    var params = formatNull(params);
    if (params === 'Y' || params === 'N') {
        if (params === 'Y') {
            if (evaluation_submit_params.totalPoints === '') {
                alert('您尚未完成该笔单据的整体评价!');
                return;
            } else {
                evaluation_submit_params.evaluateFlag = '1';
                var appraiseText = getValue('appraiseText');
                var appraiseTextLen = ryt.getLengthByStr(appraiseText);
                if (appraiseTextLen > 100) {
                    alert('单据评价建议过长!');
                    return;
                } else {
                    evaluation_submit_params.otherSuggest = getValue('appraiseText');
                }
            }
        } else if (params === 'N') {
            evaluation_submit_params.evaluateFlag = '0';
        }
        var billEvaluationInfo = formatNull(globalTable['billEvaluationInfo']);
        var billEvaluaId = formatNull(billEvaluationInfo['id']);
        if (billEvaluaId != '') {
            evaluation_submit_params.billEvaluaId = billEvaluaId;
            evaluation_submit_params.TranCode = 'updateBillEvaluation';
            invoke_trancode('jjbx_login', 'entrance', evaluation_submit_params, lua_index_mission.evaluation_submit, {}, all_callback, { CloseLoading: 'false' });
        } else {
            alert('单据不存在');
        }
    } else {
        var responseBody = json2table(params['responseBody']);
        if (responseBody['errorNo'] === '000000') {
            if (responseBody['EvaluateFlag'] === '0') {
            } else {
                alert('感谢\uFF0C您的评价已提交成功\uFF01如有反馈请至消息中心查看\u3002');
            }
        } else {
            alert(responseBody['errorMsg']);
            return;
        }
    }
    lua_format.init_table_params(evaluation_submit_params);
    lua_index_mission.evaluation_page_ctrl('close');
};
lua_index_mission.create_bill_evaluation = function () {
    height_adapt('evaluation_bg_div', 0, 0);
    var star1_html = '';
    var star2_html = '';
    var star3_html = '';
    var star4_html = '';
    for (let i = 1; 5; i++) {
        star1_html = star1_html + ('[[\n            <div class="evaluation_star_item]]' + (tostring(i) + ('[[_div" border="0" onclick="lua_index_mission.evaluation_star_choose(\']]' + (tostring(i) + ('[[\',\'entirety\')">\n                <img src="local:pentacle_white.png" class="evaluation_star_icon" name="entiretyImg" onclick="lua_index_mission.evaluation_star_choose(\']]' + (tostring(i) + '[[\',\'entirety\')"/>\n            </div>\n        ]]'))))));
        star2_html = star2_html + ('[[\n            <div class="evaluation_star_item]]' + (tostring(i) + ('[[_div" border="0" onclick="lua_index_mission.evaluation_star_choose(\']]' + (tostring(i) + ('[[\',\'disposeTimeliness\')">\n                <img src="local:pentacle_white.png" class="evaluation_star_icon" name="disposeTimelinessImg" onclick="lua_index_mission.evaluation_star_choose(\']]' + (tostring(i) + '[[\',\'disposeTimeliness\')"/>\n            </div>\n        ]]'))))));
        star3_html = star3_html + ('[[\n            <div class="evaluation_star_item]]' + (tostring(i) + ('[[_div" border="0" onclick="lua_index_mission.evaluation_star_choose(\']]' + (tostring(i) + ('[[\',\'serveAttitude\')">\n                <img src="local:pentacle_white.png" class="evaluation_star_icon" name="serveAttitudeImg" onclick="lua_index_mission.evaluation_star_choose(\']]' + (tostring(i) + '[[\',\'serveAttitude\')"/>\n            </div>\n        ]]'))))));
        star4_html = star4_html + ('[[\n            <div class="evaluation_star_item]]' + (tostring(i) + ('[[_div" border="0" onclick="lua_index_mission.evaluation_star_choose(\']]' + (tostring(i) + ('[[\',\'systemFunction\')">\n                <img src="local:pentacle_white.png" class="evaluation_star_icon" name="systemFunctionImg" onclick="lua_index_mission.evaluation_star_choose(\']]' + (tostring(i) + '[[\',\'systemFunction\')"/>\n            </div>\n        ]]'))))));
    }
    var btn_border = '';
    if (systemTable['SysLayoutStyle'] === 'android') {
        btn_border = '1';
    } else {
        btn_border = '0';
    }
    var btn_html = '[[\n        <div class="evaluation_btn_div" border="]]' + (btn_border + '[[">\n            <div class="evaluation_btn1_div" border="0" onclick="lua_index_mission.evaluation_submit(\'N\')">\n                <label class="evaluation_btn1_label">不评价</label>\n            </div>\n            <div class="evaluation_btn2_div" border="0" onclick="lua_index_mission.evaluation_submit(\'Y\')">\n                <label class="evaluation_btn2_label">提交评价</label>\n            </div>\n        </div>\n    ]]');
    var billEvaluationInfo = formatNull(globalTable['billEvaluationInfo']);
    var show_billNo = formatNull(billEvaluationInfo['djh']);
    var show_billtime = formatNull(billEvaluationInfo['zdrq']);
    var show_billType = formatNull(billEvaluationInfo['djlx']);
    var show_billAmt = formatNull(formatMoney(billEvaluationInfo['hjje']));
    var show_billsm = formatNull(billEvaluationInfo['sy']);
    if (lua_mission.index_debug() === 'true') {
        show_billNo = 'SSX20092217709';
        show_billtime = '2020-08-08';
        show_billType = '测试的单据';
        show_billAmt = '20.50';
        show_billsm = '测试的说明';
    }
    var evaluation_html = '[[\n        <div class="evaluation_bg_div" name="evaluation_bg_div" border="0" onclick="">\n            <div class="evaluation_div" border="1" name="evaluation_div" onClick="">\n                <!-- 标题 -->\n                <label class="evaluation_title_label">单据评价</label>\n                <img src="local:red_down_line.png" class="evaluation_red_line" />\n                <div class="evaluation_close_div" border="0" onclick="lua_index_mission.evaluation_page_ctrl(\'close\')">\n                    <img src="local:close_login.png" class="evaluation_close_icon" onclick="lua_index_mission.evaluation_page_ctrl(\'close\')"/>\n                </div>\n\n                <!-- 内容 -->\n                <div class="evaluation_info_div" border="0" name="billInfoDiv">\n                    <label class="evaluation_info_klabel">单据号</label>\n                    <label class="evaluation_info_vlabel1">]]' + (show_billNo + ('[[</label>\n                    <label class="evaluation_info_vlabel2" name="billtime" value="]]' + (show_billtime + ('[["/>\n\n                    <label class="evaluation_info_klabel">单据类型</label>\n                    <label class="evaluation_info_vlabel1">]]' + (show_billType + ('[[</label>\n                    <label class="evaluation_info_vlabel2">]]' + (show_billAmt + ('[[</label>\n\n                    <label class="evaluation_info_klabel">事由</label>\n                    <label class="evaluation_info_vlabel3">]]' + (show_billsm + ('[[</label>\n                </div>\n                <div class="space_10_div" border="0"></div>\n\n                <!-- 评价打分 -->\n                <div class="evaluation_star_choose_div" name="entiretyDiv" border="0">\n                    <label class="evaluation_star_title">整体评价</label>\n                        ]]' + (star1_html + ('[[\n                    <label class="evaluation_star_label" name="entiretyValue"></label>\n                </div>\n                <div class="evaluation_star_choose_div" name="disposeTimelinessDiv" border="0">\n                    <label class="evaluation_star_title">财务处理时效</label>\n                        ]]' + (star2_html + ('[[\n                    <label class="evaluation_star_label" name="disposeTimelinessValue"></label>\n                </div>\n                <div class="evaluation_star_choose_div" name="serveAttitudeDiv" border="0">\n                    <label class="evaluation_star_title">财务服务态度</label>\n                        ]]' + (star3_html + ('[[\n                    <label class="evaluation_star_label" name="serveAttitudeValue"></label>\n                </div>\n                <div class="evaluation_star_choose_div" name="systemFunctionDiv" border="0">\n                    <label class="evaluation_star_title">系统使用功能</label>\n                        ]]' + (star4_html + ('[[\n                    <label class="evaluation_star_label" name="systemFunctionValue"></label>\n                </div>\n                <div class="space_10_div" border="0"></div>\n\n                <!-- 评价建议 -->\n                <div class="evaluation_info_div" border="1">\n                    <textarea class="evaluation_suggest_input" border="0" name="appraiseText" value="" maxleng="100" onchange="lua_index_mission.evaluation_suggest_tip(\'appraiseText\',\'inputNum\',\'100\')" hold="请输入您的建议..." isShowButton="false"></textarea>\n                    <label class="evaluation_suggest_input_tip" name="inputNum">0/100</label>\n                </div>\n                <div class="space_10_div" border="0"></div>\n\n                ]]' + (btn_html + '[[\n            </div>\n        </div>\n    ]]')))))))))))))))))));
    document.getElementsByName('evaluation_bg_div')[1].setInnerHTML(evaluation_html);
    lua_page.widget_center_adapt('evaluation_div', 'x/y');
    page_reload();
};
lua_index_mission.evaluation_page_ctrl = function (flag) {
    if (flag === 'open') {
        set_android_top_bar_color('#4C4B5B');
        show_ele('evaluation_bg_div');
    } else {
        set_android_top_bar_image('index_top_bar_up.png');
        hide_ele('evaluation_bg_div');
        globalTable['userAppraise'] = 'false';
        lua_mission.index_handle();
    }
};
lua_index_mission.analysis_show_credit_explain = function () {
    var ShowCreditExplainFlag = formatNull(globalTable['ShowCreditExplainFlag'], 'false');
    globalTable['ShowCreditExplainFlag'] = 'false';
    var CreditExplainUrl = formatNull(globalTable['CreditExplainUrl']);
    if (lua_mission.index_debug() === 'true') {
        ShowCreditExplainFlag = 'true';
        CreditExplainUrl = systemTable['ServerHost'];
    }
    if (ShowCreditExplainFlag === 'true') {
        lua_index_mission.show_creditExplain_page(CreditExplainUrl, 'lua_index_mission.update_xkhs_status');
    } else {
        lua_mission.index_handle();
    }
};
lua_index_mission.show_creditExplain_page = function (CreditExplainUrl, CallbckFun) {
    var CallbckFun = formatNull(CallbckFun);
    if (platform === 'iPhone OS') {
        globalTable['webview_url'] = CreditExplainUrl;
        var credit_explain_html = '[[\n            <div class="credit_explain_bg_div" name="credit_explain_bg_div" border="0" onclick="">\n                <div class="credit_explain_div" name="credit_explain_div" border="1">\n                    <!-- 头 -->\n                    <div class="credit_explain_title_div" border="0">\n                        <label class="credit_explain_title_label">信用权益参与提示</label>\n                    </div>\n                    <div class="credit_explain_close_div" border="0" onclick="lua_index_mission.close_credit_explain_page()">\n                        <img src="local:sl_ico_close.png" class="credit_explain_close_icon" onclick="lua_index_mission.close_credit_explain_page()"/>\n                    </div>\n\n                    <!-- 分隔线条 -->\n                    <img src="local:red_down_line.png" class="credit_explain_line_div" />\n\n                    <!-- 内容 -->\n                    <div class="credit_explain_webview_content_div" border="0" name="credit_explain_webview_content_div">\n                        <div class="credit_explain_webview" name="credit_explain_webview" type="webviewLife" url="]]' + (globalTable['webview_url'] + '[[" />\n                    </div>\n\n                    <!-- 底部按钮 -->\n                    <div class="credit_explain_webview_two_btn_div" name="credit_explain_webview_two_btn_div" border="0">\n                        <div class="credit_explain_webview_two_btn1_div" border="0" onclick="lua_index_mission.update_xkhs_status(\'N\')">\n                            <label class="credit_explain_webview_two_btn1_label">不参与</label>\n                        </div>\n                        <div class="credit_explain_webview_two_btn2_div" border="0" onclick="lua_index_mission.update_xkhs_status(\'Y\')">\n                            <label class="credit_explain_webview_two_btn2_label">参与</label>\n                        </div>\n                    </div>\n                </div>\n            </div>\n        ]]');
        document.getElementsByName('credit_explain_bg_div')[1].setInnerHTML(credit_explain_html);
        page_reload();
        index_page_iPhoneX_ctrl('hide');
        lua_page.widget_center_adapt('credit_explain_div', 'x/y');
        height_adapt('credit_explain_bg_div', 0, 0);
        show_ele('credit_explain_bg_div');
    } else {
        luadefine.loadWebviewDialog(CreditExplainUrl, CallbckFun);
    }
};
lua_index_mission.update_xkhs_status = function (params) {
    var params = formatNull(params);
    if (params === 'Y' || params === 'N' || params === 'C') {
        if (params === 'C') {
            lua_mission.index_handle();
        } else {
            globalTable['webview_url'] = '';
            invoke_trancode('jjbx_myInfo', 'creditScore', {
                TranCode: 'update_xkhs_status',
                Status: params
            }, lua_index_mission.update_xkhs_status, {}, all_callback, { CloseLoading: 'false' });
        }
    } else {
        var responseBody = json2table(params['responseBody']);
        var errorNo = formatNull(responseBody['errorNo']);
        var errorMsg = formatNull(responseBody['errorMsg']);
        if (errorNo != '000000') {
            alert(errorMsg);
        }
        lua_index_mission.close_credit_explain_page();
    }
};
lua_index_mission.close_credit_explain_page = function () {
    if (platform === 'iPhone OS') {
        index_page_iPhoneX_ctrl('show');
        hide_ele('credit_explain_bg_div');
    }
    lua_mission.index_handle();
};
lua_index_mission.deal_client_register_mission = function () {
    var ClientRegisterMissionArg = get_db_value('ClientRegisterMissionArg');
    if (ClientRegisterMissionArg != '') {
        var CommonLogRegisterArg = {
            LogExplain: '检查客户端注册的待处理的任务',
            LogInfo: ClientRegisterMissionArg
        };
        lua_jjbx.common_log_register('', CommonLogRegisterArg);
    }
    var missionArg = lua_format.url_decode(ClientRegisterMissionArg);
    var PkUserNow = vt('PkUser', globalTable);
    if (missionArg != '') {
        var ArgObj = json2table(missionArg);
        var MissionType = vt('MissionType', ArgObj);
        lua_system.batch_close_app_alert_window();
        if (MissionType === 'FileOpenByAppUpload') {
            if (PkUserNow != '') {
                var FileName = vt('FileName', ArgObj);
                var FilePath = vt('FilePath', ArgObj);
                lua_upload.upload_file_by_app(FileName, FilePath);
            } else {
            }
        } else if (MissionType === 'ToBudgetPageOpenByOtherApp') {
            var PkUserTarget = vt('JJBXAppLoginUserId', ArgObj);
            if (PkUserNow != '') {
                if (PkUserTarget === PkUserNow) {
                    lua_menu.to_budget_page_by_other_app(ArgObj);
                } else {
                    var ReLoginArgTable = {
                        JJBXAppLoginToken: vt('JJBXAppLoginToken', ArgObj),
                        Relogin: 'true'
                    };
                    var ReLoginArgJson = lua_format.base64_encode(table2json(ReLoginArgTable));
                    alert_confirm('', '当前极简报销登录用户和手机银行登录用户不一致\uFF0C请重新登录', '', '重新登录', 'alert_confirm_call', 'CallFun=lua_login.login_by_otherapp_prepare&CallArg=' + ReLoginArgJson);
                }
            } else {
                var LoginArgTable = {
                    JJBXAppLoginToken: vt('JJBXAppLoginToken', ArgObj),
                    Relogin: 'false'
                };
                var LoginArgJson = lua_format.base64_encode(table2json(LoginArgTable));
                lua_login.login_by_otherapp_prepare(LoginArgJson);
            }
        } else {
            var CommonLogRegisterArg = {
                LogExplain: '客户端注册的待处理的任务无法被解析',
                LogInfo: ClientRegisterMissionArg
            };
            lua_jjbx.common_log_register('', CommonLogRegisterArg);
            lua_mission.clear_app_register_mission({ ClearMsg: '未定义的任务信息' });
            if (PkUserNow != '') {
                lua_mission.index_handle();
            } else {
            }
        }
    } else {
        if (PkUserNow != '') {
            lua_mission.index_handle();
        } else {
        }
    }
};
lua_index_mission.init_my_request_navigation = function (ResParams) {
    if (formatNull(ResParams) === '') {
        invoke_trancode_donot_checkRepeat('jjbx_index', 'my_request', { TranCode: 'init_my_request_navigation' }, lua_index_mission.init_my_request_navigation, {}, all_callback, { CloseLoading: 'false' });
    } else {
        close_loading();
        var res = json2table(ResParams['responseBody']);
        globalTable['navigation'] = {
            localPageIndex: 1,
            menuList: {}
        };
        var index = 1;
        var tempMenuList = [{
                index: index,
                title: '单据任务',
                pending: 'false',
                localPage: 'true',
                pagePath: 'jjbx_index/xhtml/jjbx_approvedItems.xhtml'
            }];
        var list1 = vt('list1', res);
        var list2 = vt('list2', res);
        if (list1.length > 0 || list2.length > 0) {
            index = index + 1;
            var pending = 'false';
            if (list1.length > 0) {
                pending = 'true';
            }
            var t = {
                index: index,
                title: '流水确认',
                pending: pending,
                localPage: 'false',
                pagePath: 'jjbx_msg_center/xhtml/msg_account_checking.xhtml'
            };
            table.insert(tempMenuList, t);
        }
        var list3 = vt('list3', res);
        var list4 = vt('list4', res);
        if (list3.length > 0 || list4.length > 0) {
            index = index + 1;
            var pending = 'false';
            if (list3.length > 0) {
                pending = 'true';
            }
            var t = {
                index: index,
                title: '往来确认',
                pending: pending,
                localPage: 'false',
                pagePath: 'jjbx_index/xhtml/jjbx_wlqr_list.xhtml'
            };
            table.insert(tempMenuList, t);
        }
        var list5 = vt('list5', res);
        var list6 = vt('list6', res);
        if (list5.length > 0 || list6.length > 0) {
            index = index + 1;
            var pending = 'false';
            if (list5.length > 0) {
                pending = 'true';
            }
            var t = {
                index: index,
                title: '消息任务',
                pending: pending,
                localPage: 'false',
                pagePath: 'jjbx_index/xhtml/msg_task.xhtml'
            };
            table.insert(tempMenuList, t);
        }
        globalTable['navigation']['menuList'] = tempMenuList;
        if (document.getElementsByName('navigationDiv').length > 0) {
            lua_index_mission.load_my_quest_navigation();
        }
    }
};
lua_index_mission.save_page_index = function (pageName) {
    var menuList = globalTable['navigation']['menuList'];
    for (let i = 1; menuList.length; i++) {
        if (menuList[i]['title'] === pageName) {
            globalTable['navigation']['localPageIndex'] = menuList[i]['index'];
            break;
        }
    }
};
lua_index_mission.switch_navigation = function (goPageIndex) {
    var navigation = vt('navigation', globalTable);
    var localPageIndex = vt('localPageIndex', navigation);
    if (parseFloat(goPageIndex) != parseFloat(localPageIndex)) {
        globalTable['navigation']['menuList'][parseFloat(localPageIndex)]['localPage'] = 'false';
        globalTable['navigation']['menuList'][parseFloat(goPageIndex)]['localPage'] = 'true';
        var menuList = vt('menuList', navigation);
        var pagePath = menuList[parseFloat(goPageIndex)]['pagePath'];
        var title = menuList[parseFloat(goPageIndex)]['title'];
        var JumpStyle = 'right';
        if (parseFloat(goPageIndex) < parseFloat(localPageIndex)) {
            JumpStyle = 'left';
        }
        if (title === '流水确认') {
            globalTable['qry_status'] = '0';
            globalTable['qry_startTransactionDate'] = '';
            globalTable['qry_endTransactionDate'] = '';
            globalTable['qry_minAmount'] = '';
            globalTable['qry_maxAmount'] = '';
            globalTable['qry_timeCondition'] = '';
        } else if (title === '往来确认') {
            globalTable['qry_status'] = '0';
            globalTable['qry_startTime'] = '';
            globalTable['qry_endTime'] = '';
            globalTable['qry_minAmount'] = '';
            globalTable['qry_maxAmount'] = '';
            globalTable['qry_minHxBalance'] = '';
            globalTable['qry_maxHxBalance'] = '';
            globalTable['qry_timeCondition'] = '';
        } else if (title === '消息任务') {
            globalTable['qry_status'] = '1';
        }
        invoke_page(pagePath, page_callback, { JumpStyle: JumpStyle });
    }
};
lua_index_mission.load_my_quest_navigation = function () {
    var navigation = vt('navigation', globalTable);
    var listLen = navigation['menuList'].length;
    var divWidth = math.ceil(375 / listLen);
    var htmlContent = '';
    var totalWidth = 0;
    for (var [key, value] in pairs(navigation['menuList'])) {
        if (divWidth * listLen > 375 && key === listLen) {
            divWidth = divWidth - (divWidth * listLen - 375) - 1;
        }
        totalWidth = totalWidth + divWidth;
        var pending = 'displayNone';
        if (value['pending'] === 'true') {
            pending = 'displayBlock';
        }
        var nowPageCss = 'displayNone';
        if (value['localPage'] === 'true') {
            nowPageCss = 'displayBlock';
        }
        htmlContent = htmlContent + ('[[\n            <div class="navigation_option" style="width: ]]' + (divWidth + ('[[px" border="0" onclick="lua_index_mission.switch_navigation(\']]' + (value['index'] + ('[[\')">\n                <label class="navigation_title_css" style="width: ]]' + (divWidth - 10 + ('[[px" value="]]' + (value['title'] + ('[[" name="navigation_title" />\n                <label class="navigation_pending_css,]]' + (pending + ('[[" value="\xB7" name="navigation_pending" />\n                <img src="local:red_down_line.png" style="width: ]]' + (divWidth + ('[[px" class="red_down_line_css,]]' + (nowPageCss + '[[" name="red_down_line" />\n            </div>\n        ]]'))))))))))))));
    }
    var e = document.getElementsByName('navigationDiv');
    if (e.length > 0) {
        htmlContent = '[[<div class="navigation_div" border="0" name="navigationDiv">]]' + (htmlContent + '[[</div>]]');
        e[1].setInnerHTML(htmlContent);
    } else {
        alert('获取导航栏元素异常');
    }
};
lua_index_mission.reload_my_quest_navigation = function (index, flag) {
    var navigation = vt('navigation', globalTable);
    var menuList = vt('menuList', navigation);
    if (menuList.length >= parseFloat(index)) {
        globalTable['navigation']['menuList'][parseFloat(index)]['pending'] = formatNull(flag, 'false');
        var navigation_pending = document.getElementsByName('navigation_pending');
        if (flag === 'true') {
            navigation_pending[parseFloat(index)].setStyleByName('display', 'block');
        } else {
            navigation_pending[parseFloat(index)].setStyleByName('display', 'none');
        }
    }
};
module.exports = { lua_index_mission: lua_index_mission };