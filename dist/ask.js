const lua_system = require('./system');
const lua_ota = require('./ota');
const lua_page_list = require('./page_list');
const lua_format = require('./format');
const lua_menu = require('./menu');
const lua_jjbx = require('./jjbx');
const lua_animation = require('./animation');
lua_ask = {};
AQRLQArg = {
    qryFlag: '',
    searchKeyWords: ''
};
lua_ask.to_ask_index_page = function () {
    var FeedbackListInstall = lua_system.check_app_func('feedback_list');
    if (FeedbackListInstall === 'true') {
        var SYS0024Value = vt('SYS0024Value', globalTable);
        if (string.find(SYS0024Value, '01')) {
            lua_ask.to_user_ask_page(1);
        } else if (string.find(SYS0024Value, '02')) {
            lua_ask.to_user_ask_page(2);
        } else if (string.find(SYS0024Value, '03')) {
            lua_ask.to_user_ask_page(3);
        } else {
            alert('功能未启用');
        }
    } else {
        var upverArg = {
            updateType: 'OPTION',
            updateMsg: '服务已经升级\uFF0C请更新后使用\u3002'
        };
        lua_ota.show_upvsr_view(upverArg);
    }
};
lua_ask.to_user_ask_page = function (TargetPageId, InvokePageArg) {
    var TargetPageId = formatNull(TargetPageId, 1);
    var NowPageId = vt('AskIndexBannerFlag', globalTable, 0);
    var InvokePageArg = formatNull(InvokePageArg, {});
    InvokePageArg['CloseLoading'] = 'false';
    if (NowPageId === 0) {
        InvokePageArg['JumpStyle'] = 'right';
    } else {
        InvokePageArg['JumpStyle'] = 'none';
    }
    var InvokePageUrl = '';
    if (TargetPageId === 1) {
        InvokePageUrl = 'jjbx_ask/ask_instructions.xhtml';
    } else if (TargetPageId === 2) {
        InvokePageUrl = 'jjbx_ask/ask_question.xhtml';
        lua_page_list.init_qry_arg('ask_question_list');
        lua_format.reset_table(AQRLQArg);
    } else if (TargetPageId === 3) {
        InvokePageUrl = 'jjbx_ask/ask_feedback.xhtml';
        lua_page_list.init_qry_arg('latest_ask_feedback_list');
    } else if (TargetPageId === 4) {
        InvokePageUrl = 'jjbx_ask/feedback_list.xhtml';
        lua_page_list.init_qry_arg('ask_feedback_list');
    } else if (TargetPageId === 5) {
        InvokePageUrl = 'jjbx_ask/feedback_detail.xhtml';
    } else if (TargetPageId === 6) {
        InvokePageUrl = 'jjbx_ask/add_feedback_input.xhtml';
    } else if (TargetPageId === 7) {
        InvokePageArg['AddPage'] = 'false';
        InvokePageUrl = 'jjbx_ask/add_feedback_result.xhtml';
    } else if (TargetPageId === 'feedback_reply') {
        InvokePageUrl = 'jjbx_ask/feedback_reply.xhtml';
    } else if (TargetPageId === 'feedback_trans_reply') {
        InvokePageUrl = 'jjbx_ask/feedback_trans_reply.xhtml';
    } else {
        debug_alert('帮助页面未找到');
        InvokePageUrl = 'jjbx_ask/ask_instructions.xhtml';
    }
    if (InvokePageUrl != '') {
        invoke_page_donot_checkRepeat(InvokePageUrl, page_callback, InvokePageArg);
    }
};
lua_ask.ask_msg_jump = function (Arg) {
    var messageSubclassEn = vt('messageSubclassEn', Arg);
    if (messageSubclassEn === 'functionGuide') {
        lua_ask.to_user_ask_page(1);
    } else if (messageSubclassEn === 'frequentQuestion') {
        lua_ask.to_user_ask_page(2);
    }
};
lua_ask.index_back = function () {
    globalTable['AskIndexBannerFlag'] = '';
    lua_menu.back_to_index();
};
lua_ask.render_index_banner = function () {
    var SYS0024Value = vt('SYS0024Value', globalTable);
    if (globalTable['userType'] === '2') {
        SYS0024Value = string.gsub(SYS0024Value, ',03', '');
        SYS0024Value = string.gsub(SYS0024Value, '03', '');
    }
    var Border = '0';
    var BannerCounts = tostring(splitUtils(SYS0024Value, ',').length);
    var ShowBannerCounts = 0;
    var InstructionBanner = '';
    if (string.find(SYS0024Value, '01')) {
        ShowBannerCounts = ShowBannerCounts + 1;
        var Onclick = 'lua_ask.index_banner_click(1)';
        var DivClass = 'ask_index_banner' + (tostring(BannerCounts) + ('-' + (tostring(ShowBannerCounts) + '_div')));
        var IconClass = 'ask_index_banner' + (tostring(BannerCounts) + '_icon');
        var LabelClass = 'ask_index_banner' + (tostring(BannerCounts) + '_label');
        InstructionBanner = '[[\n            <div class="]]' + (DivClass + ('[[" border="]]' + (Border + ('[[" onclick="]]' + (Onclick + ('[[">\n                <img src="local:ask_banner1.png" class="]]' + (IconClass + ('[[" name="ask_index_banner_icon" onclick="]]' + (Onclick + ('[[" />\n                <label value="功能指南" class="]]' + (LabelClass + ('[[" name="ask_index_banner_label" onclick="]]' + (Onclick + '[[" />\n            </div>\n        ]]')))))))))))));
    }
    var QuestionBanner = '';
    if (string.find(SYS0024Value, '02')) {
        ShowBannerCounts = ShowBannerCounts + 1;
        var Onclick = 'lua_ask.index_banner_click(2)';
        var DivClass = 'ask_index_banner' + (tostring(BannerCounts) + ('-' + (tostring(ShowBannerCounts) + '_div')));
        var IconClass = 'ask_index_banner' + (tostring(BannerCounts) + '_icon');
        var LabelClass = 'ask_index_banner' + (tostring(BannerCounts) + '_label');
        QuestionBanner = '[[\n            <div class="]]' + (DivClass + ('[[" border="]]' + (Border + ('[[" onclick="]]' + (Onclick + ('[[">\n                <img src="local:ask_banner2.png" class="]]' + (IconClass + ('[[" name="ask_index_banner_icon" onclick="]]' + (Onclick + ('[[" />\n                <label value="常见问题" class="]]' + (LabelClass + ('[[" name="ask_index_banner_label" onclick="]]' + (Onclick + '[[" />\n            </div>\n        ]]')))))))))))));
    }
    var FeedbackBanner = '';
    if (string.find(SYS0024Value, '03')) {
        ShowBannerCounts = ShowBannerCounts + 1;
        var Onclick = 'lua_ask.index_banner_click(3)';
        var DivClass = 'ask_index_banner' + (tostring(BannerCounts) + ('-' + (tostring(ShowBannerCounts) + '_div')));
        var IconClass = 'ask_index_banner' + (tostring(BannerCounts) + '_icon');
        var LabelClass = 'ask_index_banner' + (tostring(BannerCounts) + '_label');
        FeedbackBanner = '[[\n            <div class="]]' + (DivClass + ('[[" border="]]' + (Border + ('[[" onclick="]]' + (Onclick + ('[[">\n                <img src="local:ask_banner3.png" class="]]' + (IconClass + ('[[" name="ask_index_banner_icon" onclick="]]' + (Onclick + ('[[" />\n                <label value="问题反馈" class="]]' + (LabelClass + ('[[" name="ask_index_banner_label" onclick="]]' + (Onclick + '[[" />\n            </div>\n        ]]')))))))))))));
    }
    var Html = '[[\n        <div class="ask_index_banner_div" name="ask_index_banner_div" border="]]' + (Border + ('[[" >\n            <line class="line_css" />]]' + (InstructionBanner + (QuestionBanner + (FeedbackBanner + '[[\n        </div>\n    ]]')))));
    document.getElementsByName('ask_index_banner_div')[1].setInnerHTML(Html);
    page_reload();
};
lua_ask.index_banner_click = function (ClickIndex) {
    var ClickIndex = formatNull(ClickIndex);
    var AskIndexBannerFlag = vt('AskIndexBannerFlag', globalTable);
    if (ClickIndex > 0) {
        var iconEleobjs = document.getElementsByName('ask_index_banner_icon');
        var labelEleobjs = document.getElementsByName('ask_index_banner_label');
        for (let i = 1; iconEleobjs.length; i++) {
            var iconEleobj = iconEleobjs[i];
            var labelEleobj = labelEleobjs[i];
            if (ClickIndex === i) {
                iconEleobj.setPropertyByName('src', 'ask_banner' + (tostring(i) + '.png'));
                labelEleobj.setStyleByName('color', '#F9601F');
            } else {
                iconEleobj.setPropertyByName('src', 'ask_banner' + (tostring(i) + '_disable.png'));
                labelEleobj.setStyleByName('color', '#999999');
            }
        }
    }
    if (ClickIndex != AskIndexBannerFlag) {
        globalTable['AskIndexBannerFlag'] = ClickIndex;
        lua_ask.to_user_ask_page(ClickIndex);
    }
};
lua_ask.del_feedback = function (DelArg) {
    lua_ask.do_del_feedback('', json2table(DelArg));
};
lua_ask.do_del_feedback = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams, {});
        ReqParams['ReqAddr'] = 'question/fb/delete';
        ReqParams['ReqUrlExplain'] = '我的反馈删除';
        var BusinessParams = { pkQuestion: vt('pkQuestion', ReqParams) };
        ReqParams['BusinessParams'] = table2json(BusinessParams);
        ReqParams['BusinessCall'] = lua_ask.do_del_feedback;
        ReqParams['ResCallFunc'] = vt('ResCallFunc', ReqParams);
        lua_jjbx.common_req(ReqParams);
    } else {
        var res = json2table(ResParams['responseBody']);
        var errorNo = vt('errorNo', res);
        var errorMsg = vt('errorMsg', res);
        if (errorNo === '000000') {
            lua_system.do_function(vt('ResCallFunc', ResParams), '');
        } else {
            alert(errorMsg);
        }
    }
};
lua_ask.view_feedback_detail = function (Data) {
    var questionState = vt('questionState', Data);
    if (questionState === '1') {
        lua_ask.to_user_ask_page(5, Data);
    } else {
        lua_ask.to_user_ask_page(6, Data);
    }
};
lua_ask.open_ask_page = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams, {});
        ReqParams['TranCode'] = 'InitAskUrl';
        var AskUrlType = vt('AskUrlType', ReqParams);
        if (AskUrlType === '1') {
            var ReqFuncode = vt('Funcode', ReqParams);
            var FindRes = lua_ask.find_permission_funcode({ FuncCode: ReqFuncode });
            var FuncAbb = vt('FuncAbb', FindRes);
            if (FuncAbb === 'bxsq' && processBillFlag === 'disenable') {
                alert(processBillCheckMsg);
                return;
            }
            if (FuncAbb === 'zxcg') {
                var MatchRes = lua_jjbx.user_fun_match({ FunCode: '0301' });
                var Matched = vt('Matched', MatchRes);
                if (Matched != 'true') {
                    alert(onlineShoppingCheckMsg);
                    return;
                }
            }
            if (FuncAbb === 'yccx') {
                var MatchRes = lua_jjbx.user_fun_match({ FunCode: '0401' });
                var Matched = vt('Matched', MatchRes);
                if (Matched != 'true') {
                    alert(carServiceCheckMsg);
                    return;
                }
            }
            if (FuncAbb === 'ycfw') {
                var MatchRes = lua_jjbx.user_fun_match({ FunCode: '0301' });
                var Matched = vt('Matched', MatchRes);
                if (Matched != 'true' || eatServiceFlag === 'disenable') {
                    alert(eatServiceCheckMsg);
                    return;
                }
            }
            if (FuncAbb === 'slfw' && travelServiceFlag === 'disenable') {
                alert(travelServiceCheckMsg);
                return;
            }
        }
        invoke_trancode_donot_checkRepeat('jjbx_page', 'webview_page', ReqParams, lua_ask.open_ask_page, {}, all_callback, { CloseLoading: 'false' });
    } else {
        close_loading();
        var res = json2table(ResParams['responseBody']);
        var webview_url = vt('webview_url', res);
        var Funcode = vt('Funcode', res);
        if (webview_url != '') {
            var title = '';
            var RightLabelText = '';
            var RightLabelFunc = '';
            var RightLabelClickClose = '';
            if (vt('AskUrlType', res) === '1') {
                RightLabelText = '常见问题';
                RightLabelFunc = 'h5_to_question_page(\'' + (Funcode + '\')');
                RightLabelClickClose = 'true';
                title = '功能指南';
            } else {
                title = '常见问题';
            }
            lua_system.alert_webview({
                title: title,
                visit_url: webview_url,
                back_type: 'BACK',
                RightLabelText: RightLabelText,
                RightLabelFunc: RightLabelFunc,
                RightLabelClickClose: RightLabelClickClose
            });
        } else {
            debug_alert('链接为空');
        }
    }
};
h5_to_question_page = function (Funcode) {
    lua_ask.to_user_ask_page(2, { Funcode: Funcode });
};
lua_ask.find_permission_funcode = function (Arg) {
    var QryFuncAbb = vt('FuncAbb', Arg);
    var QryFuncCode = vt('FuncCode', Arg);
    var res = {};
    for (let i = 1; JJBX_ASK_PERMISSION_INFO.length; i++) {
        var Data = formatNull(JJBX_ASK_PERMISSION_INFO[i]);
        var FuncAbb = vt('FuncAbb', Data);
        var FuncName = vt('FuncName', Data);
        var FuncCode = vt('FuncCode', Data);
        var QryFlag = vt('QryFlag', Data);
        if (QryFuncAbb === FuncAbb) {
            res['FuncAbb'] = FuncAbb;
            res['FuncName'] = FuncName;
            res['FuncCode'] = FuncCode;
            res['QryFlag'] = QryFlag;
            break;
        } else if (QryFuncCode === FuncCode) {
            res['FuncAbb'] = FuncAbb;
            res['FuncName'] = FuncName;
            res['FuncCode'] = FuncCode;
            res['QryFlag'] = QryFlag;
            break;
        }
    }
    return res;
};
lua_ask.create_help_floating = function (FuncAbb) {
    var Html = '';
    var DisPlayCss = '';
    if (lua_ask.switch() === 'true') {
        var AddStyle = '';
        var SetTop = systemTable['phoneInfo']['screenUseHeight'] - get_bottom_diff() - 150 - 58;
        AddStyle = 'top:' + (SetTop + 'px;');
        Html = '[[\n            <div class="floating_help_icon_div" style="]]' + (AddStyle + ('[[" name="drag_ctrl_ele1" onclick="lua_ask.floating_help_click(\']]' + (FuncAbb + '[[\')" border="0" />\n        ]]')));
    }
    return Html;
};
lua_ask.floating_help_click = function (FuncAbb) {
    var FindRes = lua_ask.find_permission_funcode({ FuncAbb: FuncAbb });
    var Funcode = vt('FuncCode', FindRes);
    if (Funcode != '') {
        var ReqParams = {
            AskUrlType: '1',
            Funcode: Funcode
        };
        lua_ask.open_ask_page('', ReqParams);
    } else {
        alert('功能编码为空');
    }
};
lua_ask.floating_drag = function () {
    if (lua_ask.switch() === 'true') {
        AniSetDragArg1['DragEleNames'] = 'drag_ctrl_ele1';
        AniSetDragArg1['DragXStyleCtrl'] = '';
        AniSetDragArg1['DragYStyleCtrl'] = 'CloseToRight';
        lua_animation.set_drag_listener(AniSetDragArg1);
    }
};
lua_ask.switch = function () {
    var res = '';
    var FeedbackListInstall = lua_system.check_app_func('feedback_list');
    if (FeedbackListInstall === 'true') {
        var PCConfigListsTable = vt('PCConfigListsTable', globalTable);
        var SYS0024Value = vt('SYS0024', PCConfigListsTable);
        globalTable['SYS0024Value'] = SYS0024Value;
        if (SYS0024Value === '') {
            res = 'false';
        } else {
            res = 'true';
        }
    } else {
        res = 'false';
    }
    return res;
};
lua_ask.qry_feedback_type = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams, {});
        ReqParams['ReqAddr'] = 'basfileContent/createContentTreeListForApp';
        ReqParams['ReqUrlExplain'] = '帮助-查询反馈问题类型列表';
        var BusinessParams = { filecode: 'ELS-008' };
        ReqParams['BusinessParams'] = table2json(BusinessParams);
        ReqParams['BusinessCall'] = lua_ask.qry_feedback_type;
        lua_jjbx.common_req(ReqParams);
    } else {
        var res = json2table(ResParams['responseBody']);
        var feedback_questionType_list = res['treeJsonArray'];
        globalTable['feedback_questionType_list'] = feedback_questionType_list;
        changeProperty('wtlx_widget', 'value', table2json(res['treeJsonArray']));
    }
};
module.exports = { lua_ask: lua_ask };