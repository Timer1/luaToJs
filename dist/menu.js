const lua_ota = require('./ota');
const lua_eat = require('./eat');
const lua_jjbx = require('./jjbx');
const lua_system = require('./system');
const lua_service = require('./service');
const lua_format = require('./format');
const lua_page_list = require('./page_list');
const lua_bill = require('./bill');
const lua_upload = require('./upload');
const lua_page = require('./page');
const lua_mission = require('./mission');
lua_menu = {};
lua_menu.onclick = function (params) {
    if (globalTable['IndexPageInitFinish'] === 'true') {
        var menu = '';
        if (type(params) === 'table') {
            menu = params;
        } else {
            menu = string_to_table(params);
        }
        lua_menu.router(menu);
    } else {
        alert('查询用户信息失败\uFF0C请重试');
    }
};
lua_menu.server_menu_info = function (menuId) {
    var menuExist = 'false';
    var menuInfo = '';
    var allMenuList = globalTable['menuList'][1]['allMenuList'];
    for (let i = 1; allMenuList.length; i++) {
        var serverMenuInfo = allMenuList[i];
        var serverMenuId = vt('id', serverMenuInfo);
        if (serverMenuId === menuId) {
            menuExist = 'true';
            menuInfo = serverMenuInfo;
            break;
        }
    }
    var serverMenuInfoRes = {
        menuExist: menuExist,
        menuInfo: menuInfo
    };
    return serverMenuInfoRes;
};
lua_menu.router = function (menuRouterArg) {
    var menuRouterArg = formatNull(menuRouterArg);
    var clicKMenuId = vt('id', menuRouterArg);
    var serverMenuConfig = lua_menu.server_menu_info(clicKMenuId);
    var serverMenuExist = vt('menuExist', serverMenuConfig);
    if (serverMenuExist === 'false') {
        alert('服务不可用');
    } else {
        var serverMenuInfo = vt('menuInfo', serverMenuConfig);
        var menuId = vt('id', serverMenuInfo);
        var menuUrl = vt('url', serverMenuInfo);
        var menuTitleName = vt('titleName', serverMenuInfo);
        var menuIcon = vt('icon', serverMenuInfo);
        var menufunc = vt('function', serverMenuInfo);
        var menuparams = vt('params', serverMenuInfo);
        var menuOrgFlag = vt('orgFlag', serverMenuInfo);
        var verifyConditions = vt('verifyConditions', serverMenuInfo);
        var appSupportInfo = lua_ota.version_support(menuId);
        var appSupport = vt('appSupport', appSupportInfo);
        var appSupportTipMsg = vt('appSupportTipMsg', appSupportInfo, '服务已经升级\uFF0C请更新后使用');
        if (menuId === '') {
            debug_alert('请配置频道编号');
        } else if (menuUrl === '' && menufunc === '') {
            debug_alert('请配置频道请求');
        } else if (appSupport === 'false') {
            var upverArg = {
                updateType: 'OPTION',
                updateMsg: appSupportTipMsg
            };
            lua_ota.show_upvsr_view(upverArg);
        } else {
            if (globalTable['userType'] === '2') {
                var sharePeopleScene = vt('sharePeopleScene', globalTable);
                if (menuId === 'zxcg') {
                    if (string.find(sharePeopleScene, JJBX_SharePeopleSecneCode.ejyshop)) {
                        menuUrl = vt('url', serverMenuInfo);
                    } else {
                        alert(onlineShoppingCheckMsg);
                        return;
                    }
                }
                if (menuId === 'ycfw') {
                    if (string.find(sharePeopleScene, 'MT')) {
                        menuUrl = vt('redirect_url', serverMenuInfo);
                        lua_eat.page_router('index');
                        return;
                    } else if (string.find(sharePeopleScene, 'ELM')) {
                        menuUrl = vt('url', serverMenuInfo);
                    } else {
                        alert(onlineShoppingCheckMsg);
                        return;
                    }
                }
            } else {
                if (menuId === 'zxcg') {
                    var MatchRes = lua_jjbx.user_fun_match({ FunCode: '0301' });
                    var Matched = vt('Matched', MatchRes);
                    if (Matched === 'true') {
                        menuUrl = vt('url', serverMenuInfo);
                    } else {
                        alert(onlineShoppingCheckMsg);
                        return;
                    }
                }
                if (menuId === 'yccx') {
                    var MatchRes = lua_jjbx.user_fun_match({ FunCode: '0401' });
                    var Matched = vt('Matched', MatchRes);
                    if (Matched === 'true') {
                        menuUrl = vt('url', serverMenuInfo);
                    } else {
                        alert(carServiceCheckMsg);
                        return;
                    }
                }
                if (menuId === 'ycfw') {
                    var MatchRes = lua_jjbx.user_fun_match({ FunCode: '0105' });
                    var Matched = vt('Matched', MatchRes);
                    if (Matched === 'true') {
                        menuUrl = vt('redirect_url', serverMenuInfo);
                        lua_eat.page_router('index');
                        return;
                    } else {
                        if (eatServiceFlag === 'enable') {
                            menuUrl = vt('url', serverMenuInfo);
                        } else {
                            alert(eatServiceCheckMsg);
                            return;
                        }
                    }
                }
            }
            if (menuId === 'slfw' && travelServiceFlag === 'disenable') {
                alert(travelServiceCheckMsg);
                return;
            }
            if (menuId === 'bxsq' && processBillFlag === 'disenable') {
                alert(processBillCheckMsg);
                return;
            }
            if (menuId === 'hkHospital' && HKHospitalFlag === 'disenable') {
                alert(HKHospitalCheckMsg);
                return;
            }
            if (menuId === 'zffw' && RenatalHourseFlag === 'disenable') {
                alert(RenatalHourseCheckMsg);
                return;
            }
            if (menuUrl != '') {
                invoke_page_donot_checkRepeat(menuUrl, page_callback, { CloseLoading: 'false' });
            } else if (menufunc != '') {
                lua_system.do_function(menufunc, menuparams);
            } else {
                alert('服务未配置');
            }
        }
    }
};
lua_menu.get = function () {
    var menu = {};
    var WorkId = get_db_value('workid');
    var DBMenuKey = WorkId + '_SavedMenu';
    var homePageCompileMenuJson = get_db_value(DBMenuKey);
    set_db_value('homePageCompileMenuJson', homePageCompileMenuJson);
    var serverMenuList = formatNull(globalTable['menuList']);
    if (serverMenuList === '') {
        alert('菜单加载失败\uFF0C请重试');
        return;
    } else {
        var defaultMenuListTable = formatNull(serverMenuList[1]['defaultMenuList']);
        var defaultMenuListJson = table2json(defaultMenuListTable);
        if (homePageCompileMenuJson != '') {
            var ServerMenuVersion = get_db_value('ServerMenuVersion');
            var DBMenuVerKey = WorkId + '_SavedMenuVer';
            var SaveMenuVersion = get_db_value(DBMenuVerKey);
            if (ServerMenuVersion === SaveMenuVersion) {
                menu = homePageCompileMenuJson;
            } else {
                del_db_value('homePageCompileMenuJson');
                del_db_value(DBMenuKey);
                del_db_value(DBMenuVerKey);
                menu = defaultMenuListJson;
            }
        } else {
            menu = defaultMenuListJson;
        }
        return menu;
    }
};
lua_menu.create_index_menu = function (Arg) {
    var userType = vt('userType', globalTable);
    var menuList = vt('menuList', Arg);
    var menuCounts = menuList.length;
    var SetBorder = '0';
    var htmlContent = '';
    for (let i = 1; menuCounts; i++) {
        var menuItem = menuList[i];
        var menuID = formatNull(menuItem['id']);
        var menuUrl = formatNull(menuItem['url']);
        var menuFunc = formatNull(menuItem['function']);
        var menuParams = formatNull(menuItem['params']);
        var menuOrgFlag = formatNull(menuItem['orgFlag']);
        var menuDefault = formatNull(menuItem['default']);
        var menuName = formatNull(menuItem['titleName']);
        var menuIcon = formatNull(menuItem['icon']);
        var menuOnclickArg = 'id=' + (menuID + ('&function=' + (menuFunc + ('&params=' + (menuParams + '')))));
        var OnClickFunC = 'lua_menu.onclick(\'' + (menuOnclickArg + '\')');
        var LineFlag = tostring(i % 4);
        var classFlag = 'menuList_css' + LineFlag;
        var MenuHtmlItem = '[[\n            <div class="]]' + (classFlag + ('[[" border="]]' + (SetBorder + ('[[" onclick="]]' + (OnClickFunC + ('[[">\n                <img src="local:]]' + (menuIcon + ('[[" class="menu_icon" onclick="]]' + (OnClickFunC + ('[[" />\n                <label class="menu_name" value="]]' + (menuName + ('[[" onclick="]]' + (OnClickFunC + '[[" />\n            </div>\n        ]]')))))))))))));
        var MoreMenuItem = '[[\n            <div class="menuList_css0" border="]]' + (SetBorder + '[[" onclick="jjbx_allMenu()">\n                <img src="local:jjbxmenu_all.png" class="menu_icon" onclick="jjbx_allMenu()" />\n                <label class="menu_name" name="bxsq" onclick="jjbx_allMenu()">更多</label>\n            </div>\n        ]]');
        if (LineFlag === '1') {
            htmlContent = htmlContent + ('[[\n                <div class="menuList_div" border="]]' + (SetBorder + '[[">\n            ]]'));
        }
        htmlContent = htmlContent + MenuHtmlItem;
        var endLoopCounts = '';
        if (userType === '2') {
            endLoopCounts = menuCounts;
        } else {
            endLoopCounts = 7;
        }
        if (LineFlag === '0') {
            htmlContent = htmlContent + '[[\n                </div>\n                <label class="space_10_div" border="0" value="  " />\n            ]]';
        } else {
            if (i === endLoopCounts) {
                if (userType === '2') {
                } else {
                    htmlContent = htmlContent + MoreMenuItem;
                }
                htmlContent = htmlContent + '[[\n                    </div>\n                ]]';
                break;
            } else {
            }
        }
    }
    if (htmlContent != '') {
        var menuListDiv = '[[\n            <div class="menu_div" border="]]' + (SetBorder + ('[[" name="menu_div">\n                <label class="space_15_div" border="0" value="  " />\n                ]]' + (htmlContent + '[[\n                <label class="space_15_div" border="0" value="  " />\n            </div>\n        ]]')));
        document.getElementsByName('menu_div')[1].setInnerHTML(menuListDiv);
        show_ele('menu_div');
    } else {
        hide_ele('menu_div');
    }
    page_reload();
};
lua_menu.to_login_page = function () {
    invoke_page('jjbx_login/xhtml/jjbx_login.xhtml', page_callback, {});
};
lua_menu.to_index_page = function (flag) {
    var flag = formatNull(flag);
    var InvokePageArg = { CloseLoading: 'false' };
    if (flag === 'back') {
        InvokePageArg['JumpStyle'] = 'left';
    } else {
        InvokePageArg['JumpStyle'] = 'right';
    }
    invoke_page_donot_checkRepeat('jjbx_index/xhtml/jjbx_index.xhtml', page_callback, InvokePageArg);
};
lua_menu.back_to_index = function () {
    lua_menu.to_index_page('back');
};
lua_menu.init_anneng_url = function (ResParams) {
    if (formatNull(ResParams) === '') {
        invoke_trancode('jjbx_page', 'webview_page', { TranCode: 'InitAnnengUrl' }, lua_menu.init_anneng_url, {});
    } else {
        var jsonData = ResParams['responseBody'];
        var responseBody = json2table(ResParams['responseBody']);
        if (responseBody['errorNo'] === '000000') {
            globalTable['webview_url'] = responseBody['webview_url'];
            globalTable['webview_page_title'] = responseBody['webview_page_title'];
            invoke_page_noloading_checkRepeat('jjbx_page/xhtml/webview_page.xhtml', page_callback, null);
        } else {
            jjbx_show_business_err(responseBody['errorNo'], responseBody['errorMsg']);
        }
    }
};
lua_menu.hkHospital_init_qry = function (ResParams) {
    var CtrlArg = {
        CtrlStyle: 'Get',
        CtrlCallBackFunc: 'lua_menu.do_hkHospital_init',
        CtrlKey: '008'
    };
    lua_jjbx.pc_cache_arg_ctrl('', CtrlArg);
};
lua_menu.do_hkHospital_init = function (Arg) {
    var ArgValue = vt('ArgValue', Arg);
    var NowVersion = vt('hkHospitalUseInstructionVersion', configTable);
    if (ArgValue === NowVersion) {
        lua_service.qry_hk_budget();
    } else {
        lua_menu.to_hkHospital_use_instruction_page({
            CloseLoading: 'false',
            AddPage: 'false'
        });
    }
};
lua_menu.to_hkHospital_use_instruction_page = function (Arg) {
    invoke_page('jjbx_local_service/hkHospital/use_instruction.xhtml', page_callback, Arg);
};
lua_menu.to_invoice_info_page = function () {
    var pageFun = '';
    var pageArg = '';
    if (formatNull(companyTable['openNoteInfoDetail']) === '') {
        pageFun = 'invoke_page';
        pageArg = { CloseLoading: 'false' };
    } else {
        pageFun = 'invoke_page_noloading_checkRepeat';
        pageArg = null;
    }
    var doPageFun = lua_format.str2fun(pageFun);
    doPageFun('jjbx_index/xhtml/jjbx_cominvoice_info.xhtml', page_callback, pageArg);
};
lua_menu.to_scanQRcode_page = function (arg) {
    var arg = formatNull(arg, { JumpStyle: 'none' });
    index_page_iPhoneX_ctrl('hide');
    invoke_page_noloading_checkRepeat('jjbx_fpc/xhtml/jjbx_invoice_scanQRcode.xhtml', page_callback, arg);
};
lua_menu.to_msg_center = function (arg) {
    var arg = formatNull(arg);
    var JumpStyle = formatNull(arg['JumpStyle'], 'right');
    globalTable['msgType'] = '';
    globalTable['businessModule'] = '';
    globalTable['messageCenter_screenButton'] = '1';
    invoke_page('jjbx_msg_center/xhtml/msg_center_index.xhtml', page_callback, {
        CloseLoading: 'false',
        JumpStyle: JumpStyle
    });
};
lua_menu.back_to_msg_center = function () {
    var arg = { JumpStyle: 'left' };
    lua_menu.to_msg_center(arg);
};
lua_menu.to_my_approval_page = function () {
    var LeaderApprovedFlag = 'false';
    var orgFlag = formatNull(globalTable['selectOrgList'][1]['unitcode']);
    var workidStr = vt('approvedItems_leader', configTable);
    var workid = get_db_value('workid');
    var InvokePageArg = { CloseLoading: 'false' };
    if (orgFlag === '001' || orgFlag === '330000001001') {
        if (workid != '' && workidStr != '') {
            var WorkidList = splitUtils(workidStr, ',');
            for (let i = 1; WorkidList.length; i++) {
                if (string.lower(workid) === string.lower(formatNull(WorkidList[i]))) {
                    LeaderApprovedFlag = 'true';
                    break;
                }
            }
        }
    }
    globalTable['quickFiltrateFlag'] = '0';
    globalTable['quickFiltrateIndex'] = '';
    globalTable['LeaderApprovedFlag'] = LeaderApprovedFlag;
    InvokePageArg['LeaderApprovedFlag'] = LeaderApprovedFlag;
    invoke_page('jjbx_index/xhtml/jjbx_approvedItems.xhtml', page_callback, InvokePageArg);
};
lua_menu.to_my_request_page = function (support) {
    var support = formatNull(support);
    globalTable['MyAskBillSupport'] = support;
    globalTable['BillApplyBackBtnText'] = '返回报销首页';
    invoke_page('jjbx_index/xhtml/jjbx_myAsk.xhtml', page_callback, { CloseLoading: 'false' });
};
lua_menu.to_change_company_page = function () {
    invoke_page('jjbx_myInfo/xhtml/changeCompany.xhtml', page_callback, { CloseLoading: 'false' });
};
lua_menu.to_contactUs_page = function () {
    invoke_page_noloading_checkRepeat('jjbx_contact_us/xhtml/contact_us.xhtml', page_callback, null);
};
lua_menu.to_alipay_auth_instruction_page = function () {
    invoke_page_noloading_checkRepeat('jjbx_myInfo/xhtml/alipay_auth_instruction.xhtml', page_callback, null);
};
lua_menu.to_msg_setting_page = function (params) {
    invoke_page('jjbx_msg_setting/xhtml/msg_setting.xhtml', page_callback, null);
};
lua_menu.to_credit_management_page = function () {
    invoke_page('jjbx_credit_manage/xhtml/creditManage.xhtml', page_callback, null);
};
lua_menu.to_security_center_page = function () {
    invoke_page('jjbx_security_center/xhtml/securityCenter.xhtml', page_callback, null);
};
lua_menu.to_share_people_manage_page = function () {
    invoke_page('jjbx_share_people_manage/list.xhtml', page_callback, { CloseLoading: 'false' });
};
lua_menu.to_gesture_login_set_page = function () {
    invoke_page('jjbx_security_center/xhtml/setGestureLogin.xhtml', page_callback, null);
};
lua_menu.to_face_login_set_page = function () {
    invoke_page('jjbx_security_center/xhtml/setFaceLogin.xhtml', page_callback, null);
};
lua_menu.to_change_login_pwd_page = function () {
    invoke_page_noloading_checkRepeat('jjbx_security_center/xhtml/change_Password.xhtml', page_callback, null);
};
lua_menu.to_finger_login_set_page = function () {
    invoke_page('jjbx_security_center/xhtml/setFingerLogin.xhtml', page_callback, null);
};
lua_menu.to_information_edit_page = function () {
    invoke_page_noloading_checkRepeat('jjbx_myInfo/xhtml/myEdit.xhtml', page_callback, null);
};
lua_menu.to_card_management_page = function () {
    invoke_page('jjbx_card_management/xhtml/card_management.xhtml', page_callback, { CloseLoading: 'false' });
};
lua_menu.to_mail_edit_page = function () {
    invoke_page_noloading('jjbx_myInfo/xhtml/change_email.xhtml', page_callback, null);
};
lua_menu.to_telephone_edit_page = function () {
    invoke_page_noloading('jjbx_myInfo/xhtml/change_telphone.xhtml', page_callback, null);
};
lua_menu.to_phone_edit_page = function () {
    invoke_page_noloading('jjbx_myInfo/xhtml/change_phone.xhtml', page_callback, null);
};
lua_menu.to_protocol_menu_page = function () {
    var appSupportInfo = lua_ota.version_support('ryt:client_database_ctrl');
    var appSupport = vt('appSupport', appSupportInfo);
    if (appSupport === 'false') {
        lua_menu.to_protocol_page();
    } else {
        invoke_page_noloading('jjbx_myInfo/xhtml/protocol_menu.xhtml', page_callback, null);
    }
};
lua_menu.to_protocol_page = function (params) {
    var protocol_pdf_url = formatNull(globalTable['ProtocolPdfUrl']);
    var params = formatNull(params);
    if (protocol_pdf_url === '') {
        if (params === '') {
            invoke_trancode_noloading_checkRepeat('jjbx_page', 'webview_page', { TranCode: 'InitPrivacyProtocolUrl' }, lua_menu.to_protocol_page, {});
        } else {
            var jsonData = params['responseBody'];
            var responseBody = json2table(params['responseBody']);
            if (responseBody['errorNo'] === '000000') {
                var Url = vt('webview_url', responseBody);
                globalTable['ProtocolPdfUrl'] = Url;
                lua_system.alert_webview({
                    title: '隐私政策',
                    visit_url: Url
                });
            } else {
                jjbx_show_business_err(responseBody['errorNo'], responseBody['errorMsg']);
            }
        }
    } else {
        lua_system.alert_webview({
            title: '隐私政策',
            visit_url: protocol_pdf_url
        });
    }
};
lua_menu.to_guide_page = function (params) {
    var guide_page_url = formatNull(globalTable['GuidePageUrl']);
    var params = formatNull(params);
    if (guide_page_url === '') {
        if (params === '') {
            invoke_trancode_noloading_checkRepeat('jjbx_page', 'webview_page', { TranCode: 'InitGuidePageUrl' }, lua_menu.to_guide_page, {});
        } else {
            var jsonData = params['responseBody'];
            var responseBody = json2table(params['responseBody']);
            if (responseBody['errorNo'] === '000000') {
                lua_jjbx.open_guide_page(responseBody['webview_url']);
            } else {
                jjbx_show_business_err(responseBody['errorNo'], responseBody['errorMsg']);
            }
        }
    } else {
        lua_jjbx.open_guide_page(guide_page_url);
    }
};
lua_menu.to_choose_invoice_relate_page = function () {
    invoke_page('jjbx_proccess_reimbursement_bill/xhtml/reimbursement_bill_invoice_list.xhtml', page_callback, { CloseLoading: 'false' });
};
lua_menu.to_custom_input_invoice_page = function () {
    globalTable['invoiceFlag'] = 'sglr';
    globalTable['fpDetail'] = {};
    globalTable['scfpTip'] = 'false';
    globalTable['UploadInvoiceInfo'] = '';
    invoke_page('jjbx_proccess_reimbursement_bill/xhtml/reimbursement_bill_invoice_add.xhtml', page_callback, {});
};
lua_menu.to_device_management_page = function (resParams) {
    if (formatNull(resParams) === '') {
        invoke_trancode_donot_checkRepeat('jjbx_myInfo', 'securityCenter', { TranCode: 'GetBindDeviceList' }, lua_menu.to_device_management_page, {}, all_callback, { CloseLoading: 'false' });
    } else {
        var res = json2table(resParams['responseBody']);
        var errorNo = vt('errorNo', res);
        var errorMsg = vt('errorMsg', res);
        if (res['errorNo'] === '000000') {
            globalTable['GetBindDeviceListRes'] = res;
            invoke_page_donot_checkRepeat('jjbx_security_center/xhtml/device_m_page.xhtml', page_callback, { CloseLoading: 'false' });
        } else {
            jjbx_show_business_err(errorNo, errorMsg);
        }
    }
};
lua_menu.to_budget_info_page = function (Arg) {
    var InvokePageArg = formatNull(Arg, {});
    InvokePageArg['CloseLoading'] = 'false';
    invoke_page('jjbx_budget_info/xhtml/budget_info_index.xhtml', page_callback, InvokePageArg);
};
lua_menu.to_budget_detail_page = function (TableStringArg) {
    for (let i = 1; JJBX_BudgetProcessType.length; i++) {
        JJBX_BudgetProcessType[i]['selected'] = 'false';
    }
    globalTable['BudgetUseDetailStatusIndex'] = '1';
    var Arg = lua_format.table_arg_unpack(TableStringArg);
    var TaskId = vt('TaskId', Arg);
    var TaskName = vt('TaskName', Arg);
    var CarrierList = vt('CarrierList', Arg);
    var PublishFlag = vt('PublishFlag', Arg);
    var FiltBudgetProcessType = {};
    JJBX_BudgetProcessType[1]['selected'] = 'true';
    if (CarrierList === '') {
        alert('没有指定预算载体');
        return;
    } else if (TaskId === '') {
        alert('没有指定预算任务');
        return;
    } else if (PublishFlag != '1') {
        alert('预算任务未发布\uFF0C可联系所在公司系统管理员确认预算执行明细');
        return;
    } else {
        for (let i = 1; JJBX_BudgetProcessType.length; i++) {
            var BPItem = formatNull(JJBX_BudgetProcessType[i]);
            var ConfigCarrierId = vt('value', BPItem);
            var MatchRes = 'false';
            var Carriers = splitUtils(CarrierList, ',');
            for (let i = 1; Carriers.length; i++) {
                if (ConfigCarrierId === Carriers[i]) {
                    MatchRes = 'true';
                    break;
                }
            }
            if (MatchRes === 'true' || i === 1) {
                table.insert(FiltBudgetProcessType, BPItem);
            }
        }
    }
    var InvokePageArg = {
        budgetTaskId: TaskId,
        publishName: TaskName + '已用明细',
        CloseLoading: 'false',
        FiltBudgetProcessType: FiltBudgetProcessType,
        billType: vt('billType', Arg)
    };
    invoke_page('jjbx_budget_info/xhtml/budget_used_details.xhtml', page_callback, InvokePageArg);
};
lua_menu.to_other_salary_info_page = function () {
    invoke_page('jjbx_salary_service/xhtml/moreInfomation.xhtml', page_callback, { CloseLoading: 'false' });
};
lua_menu.to_social_detail_page = function () {
    invoke_page('jjbx_salary_service/xhtml/socialDetail.xhtml', page_callback, { CloseLoading: 'false' });
};
lua_menu.to_demo_page = function (arg) {
    if (systemTable['EnvAllowDebug'] === 'true') {
        if (formatNull(show_demo_menu_type) === '') {
            show_demo_menu_type = 'open';
        }
        if (formatNull(show_demo_menu_index) === '') {
            show_demo_menu_index = 1;
        }
        var arg = formatNull(arg, { CloseLoading: 'false' });
        invoke_page_donot_checkRepeat('jjbx_page_demo/xhtml/demo_index_page.xhtml', page_callback, arg);
    }
};
lua_menu.to_dbx_invoice_list_page = function () {
    lua_format.reset_table(C_ClientListSelectListArg);
    C_ClientListSelectListArg.SelectAllType = '0';
    invoke_page('jjbx_fpc/xhtml/jjbx_invoiceList_dbx.xhtml', page_callback, { CloseLoading: 'false' });
};
lua_menu.to_porcess_travel_reimbursement_page = function (Arg) {
    lua_format.reset_table(C_ClientListSelectListArg);
    C_ClientListSelectListArg.SelectAllType = '0';
    invoke_page('jjbx_travel_reimbursement/xhtml/travel_service_reimbursement_myOrder.xhtml', page_callback, Arg);
};
lua_menu.to_add_glhx_page = function (Arg) {
    lua_format.reset_table(C_ClientListSelectListArg);
    C_ClientListSelectListArg.SelectAllType = '0';
    lua_page_list.init_qry_arg('process_glhx_list');
    var Arg = formatNull(Arg, {});
    Arg['CloseLoading'] = 'false';
    invoke_page('jjbx_process_bill/xhtml/process_bill_glhx.xhtml', page_callback, Arg);
};
lua_menu.to_add_glzjgc_page = function (Arg) {
    lua_format.reset_table(C_ClientListSelectListArg);
    C_ClientListSelectListArg.SelectAllType = '0';
    lua_page_list.init_qry_arg('process_glzjgc_list');
    var Arg = formatNull(Arg, {});
    Arg['CloseLoading'] = 'false';
    invoke_page('jjbx_process_bill/xhtml/process_bill_glzjgc.xhtml', page_callback, Arg);
};
lua_menu.top_right_menu_action = function (ctrl) {
    if (ctrl === 'get_bill_cover_pdf') {
        lua_jjbx.get_bill_cover_pdf();
    } else if (ctrl === 'edit_bill') {
        globalTable['ifApproverEdit'] = 'true';
        to_bill_edit_page();
    } else if (ctrl === 'process_information') {
        to_process_information_page();
    } else if (ctrl === 'msg_filt_flag_all') {
        update_markunread_flag('');
    } else if (ctrl === 'msg_filt_flag_unread') {
        update_markunread_flag('0');
    } else if (ctrl === 'msg_filt_flag_read') {
        update_markunread_flag('1');
    } else if (ctrl === 'new_bill') {
        create_new_bill();
    } else if (ctrl === 'jjdj') {
        lua_bill.to_jjdj_list();
    } else {
        alert('敬请期待');
    }
};
lua_menu.app_alert_menu_action = function (ctrl) {
    var ctrl = formatNull(ctrl);
    globalTable['invoiceUploadCtrl'] = ctrl;
    lua_jjbx.close_add_invoice_menu('');
    var router_fun = 'lua_menu.app_alert_menu_action';
    var close_fun = 'lua_jjbx.close_add_invoice_menu';
    var PCConfigListsTable = vt('PCConfigListsTable', globalTable);
    var MenuEnableConfig = vt('INV0012', PCConfigListsTable);
    var UploadAppCacheEnclosureParams1 = lua_format.base64_encode(vt('UploadAppCacheEnclosureParams1', globalTable));
    if (ctrl === 'invoice_relate_by_fpc') {
        jjbx_relate_invoice();
    } else if (ctrl === 'invoice_add_by_upload') {
        var menu_add_by_camera = {
            title: '拍照',
            tip: vt('INV0006', PCConfigListsTable),
            fun: router_fun,
            arg: 'invoice_add_by_camera'
        };
        var menu_add_by_album = {
            title: '相册',
            tip: vt('INV0007', PCConfigListsTable),
            fun: router_fun,
            arg: 'invoice_add_by_album'
        };
        var menu_add_by_filesystem = {
            title: '从文件选择',
            tip: vt('INV0008', PCConfigListsTable),
            fun: router_fun,
            arg: 'invoice_add_by_filesystem'
        };
        var menu_info_list = {};
        table.insert(menu_info_list, menu_add_by_camera);
        table.insert(menu_info_list, menu_add_by_album);
        table.insert(menu_info_list, menu_add_by_filesystem);
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
    } else if (ctrl === 'invoice_add_by_camera' || ctrl === 'invoice_relate_by_camera' || ctrl === 'scan_train_ticket_by_camera' || ctrl === 'scan_air_ticket_by_camera') {
        var camera_call = '';
        var uploadFlag = '';
        if (ctrl === 'invoice_add_by_camera') {
            camera_call = 'lua_jjbx.upload_invoice_to_add_call';
            uploadFlag = 'upInvoiceFile';
        } else if (ctrl === 'invoice_relate_by_camera') {
            camera_call = 'lua_jjbx.upload_invoice_to_relate_call';
            uploadFlag = 'upInvoiceFile';
        } else if (ctrl === 'scan_train_ticket_by_camera') {
            camera_call = 'lua_jjbx.upload_train_ticket_to_scan_call';
            uploadFlag = 'upTrainTicket';
        } else if (ctrl === 'scan_air_ticket_by_camera') {
            camera_call = 'lua_jjbx.upload_air_ticket_to_scan_call';
            uploadFlag = 'upAirTicket';
        } else {
        }
        var open_camera_arg = {
            doFlag: 'Upload',
            uploadFlag: uploadFlag,
            compressStyle: 'Normal',
            maxSize: '20',
            callback: camera_call,
            params1: UploadAppCacheEnclosureParams1,
            params2: '',
            params3: ''
        };
        lua_system.open_camera(open_camera_arg);
    } else if (ctrl === 'invoice_add_by_album' || ctrl === 'invoice_relate_by_album' || ctrl === 'scan_train_ticket_by_album' || ctrl === 'scan_air_ticket_by_album') {
        var album_call = '';
        var uploadFlag = '';
        var maxCounts = '1';
        var closeLoading = 'false';
        var backFileListCallFun = '';
        globalTable['invoiceUploadCtrl'] = ctrl;
        if (ctrl === 'invoice_add_by_album') {
            album_call = 'lua_jjbx.upload_invoice_to_add_call';
            uploadFlag = 'upInvoiceFile';
            maxCounts = '100';
            closeLoading = 'true';
            backFileListCallFun = 'get_uploading_file';
        } else if (ctrl === 'invoice_relate_by_album') {
            album_call = 'lua_jjbx.upload_invoice_to_relate_call';
            uploadFlag = 'upInvoiceFile';
            maxCounts = '5';
        } else if (ctrl === 'scan_train_ticket_by_album') {
            album_call = 'lua_jjbx.upload_train_ticket_to_scan_call';
            uploadFlag = 'upTrainTicket';
        } else if (ctrl === 'scan_air_ticket_by_album') {
            album_call = 'lua_jjbx.upload_air_ticket_to_scan_call';
            uploadFlag = 'upAirTicket';
        } else {
        }
        var open_album_arg = {
            doFlag: 'Upload',
            uploadFlag: uploadFlag,
            compressStyle: 'Normal',
            maxCounts: maxCounts,
            maxCountsTip: '选择图片不能大于' + (maxCounts + '张'),
            maxSize: '20',
            callback: album_call,
            closeLoading: closeLoading,
            backFileListCallFun: backFileListCallFun,
            params1: UploadAppCacheEnclosureParams1,
            params2: '',
            params3: ''
        };
        lua_system.open_album(open_album_arg);
    } else if (ctrl === 'invoice_add_by_filesystem' || ctrl === 'invoice_relate_by_filesystem' || ctrl === 'scan_train_ticket_by_filesystem' || ctrl === 'scan_air_ticket_by_filesystem' || ctrl === 'pension_voucher_by_filesystem') {
        var filesystem_call = '';
        var uploadFlag = '';
        var maxCounts = '5';
        var filetype = 'pdf,ofd,png,jpg,jpeg,PDF,OFD,PNG,JPG,JPEG';
        var fileTypeMsg = '目前只支持上传pdf,ofd格式的文件和发票图片';
        var loadFileType = '图片,PDF,OFD';
        var closeLoading = 'false';
        var backFileListCallFun = '';
        globalTable['invoiceUploadCtrl'] = ctrl;
        if (ctrl === 'invoice_add_by_filesystem') {
            filesystem_call = 'lua_jjbx.upload_invoice_to_add_call';
            uploadFlag = 'upInvoiceFile';
            closeLoading = 'true';
            maxCounts = '50';
            backFileListCallFun = 'get_uploading_file';
        } else if (ctrl === 'scan_train_ticket_by_filesystem') {
            maxCounts = '1';
            filesystem_call = 'lua_jjbx.upload_train_ticket_to_scan_call';
            uploadFlag = 'upTrainTicket';
        } else if (ctrl === 'scan_air_ticket_by_filesystem') {
            maxCounts = '1';
            filesystem_call = 'lua_jjbx.upload_air_ticket_to_scan_call';
            uploadFlag = 'upAirTicket';
        } else if (ctrl === 'pension_voucher_by_filesystem') {
            maxCounts = '1';
            filetype = 'pdf,PDF';
            fileTypeMsg = '目前只支持识别PDF格式的文件';
            loadFileType = 'PDF';
            filesystem_call = 'lua_jjbx.upload_pension_voucher_call';
            uploadFlag = 'upPensionVoucher';
        } else {
            filesystem_call = 'lua_jjbx.upload_invoice_to_relate_call';
            uploadFlag = 'upInvoiceFile';
        }
        var client_file_upload_arg = {
            pagetitle: C_SearchContextBegin + ('文件名' + C_SearchContextEnd),
            uploadtype: 'multiple',
            counts: maxCounts,
            countsmsg: '选择文件不能大于' + (maxCounts + '个'),
            filetype: filetype,
            filetypemsg: fileTypeMsg,
            callfun: filesystem_call,
            uploadflag: uploadFlag,
            loadFileType: loadFileType,
            defaultType: 'PDF',
            closeLoading: closeLoading,
            backFileListCallFun: backFileListCallFun,
            params1: UploadAppCacheEnclosureParams1
        };
        lua_system.client_file_upload(client_file_upload_arg);
    } else if (ctrl === 'invoice_relate_by_upload') {
        var menu_info_list = {};
        var menu_relate_by_camera = {
            title: '拍照',
            tip: '',
            fun: router_fun,
            arg: 'invoice_relate_by_camera'
        };
        var menu_relate_by_album = {
            title: '相册',
            tip: '',
            fun: router_fun,
            arg: 'invoice_relate_by_album'
        };
        var menu_relate_by_filesystem = {
            title: '从文件选择',
            tip: '',
            fun: router_fun,
            arg: 'invoice_relate_by_filesystem'
        };
        table.insert(menu_info_list, menu_relate_by_camera);
        table.insert(menu_info_list, menu_relate_by_album);
        table.insert(menu_info_list, menu_relate_by_filesystem);
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
    } else if (ctrl === 'invoice_relate_by_input') {
        lua_menu.to_custom_input_invoice_page();
    } else if (ctrl === 'invoice_add_by_input') {
        invoke_page('jjbx_fpc/xhtml/jjbx_invoice_input_save.xhtml', page_callback, { CloseLoading: 'false' });
    } else if (ctrl === 'upload_headPic_by_camera') {
        lua_upload.upload_headPic('camera');
    } else if (ctrl === 'upload_headPic_by_album') {
        lua_upload.upload_headPic('album');
    } else if (ctrl === 'upload_enclosure_by_camera') {
        lua_upload.upload_enclosure('camera');
    } else if (ctrl === 'upload_enclosure_by_album') {
        lua_upload.upload_enclosure('album');
    } else if (ctrl === 'upload_enclosure_by_filesystem') {
        lua_upload.upload_enclosure('filesystem');
    } else if (ctrl === 'upload_app_cache_enclosure_by_camera') {
        lua_upload.upload_app_cache_enclosure('camera');
    } else if (ctrl === 'upload_app_cache_enclosure_by_album') {
        lua_upload.upload_app_cache_enclosure('album');
    } else if (ctrl === 'upload_app_cache_video_by_shoot') {
        lua_upload.upload_app_cache_enclosure('shoot_video');
    } else if (ctrl === 'upload_app_cache_video_by_album') {
        lua_upload.upload_app_cache_enclosure('album_video');
    } else if (ctrl === 'upload_bank_card_to_scan_by_camera') {
        lua_upload.upload_bank_card_to_scan('camera');
    } else if (ctrl === 'upload_bank_card_to_scan_by_album') {
        lua_upload.upload_bank_card_to_scan('album');
    } else if (ctrl === 'process_invoice_by_bzd' || ctrl === 'process_invoice_by_xcbxd') {
        var SelectedIdListStr = C_ClientListSelectListArg.SelectedIdListStr;
        var ProcessInvoiceIdList = {};
        var SelectedInvoiceIdList = splitUtils(SelectedIdListStr, ',');
        for (let i = 1; SelectedInvoiceIdList.length; i++) {
            var IdStr = formatNull(SelectedInvoiceIdList[i]);
            if (IdStr === '' || IdStr === ',') {
            } else {
                var AddIdStr = string.gsub(IdStr, '\'', '');
                table.insert(ProcessInvoiceIdList, AddIdStr);
            }
        }
        var InvokePageArg = { ProcessInvoiceIdListJson: table2json({ ProcessInvoiceIdList: ProcessInvoiceIdList }) };
        if (ctrl === 'process_invoice_by_bzd') {
            if (ProcessInvoiceIdList.length > 50) {
                alert('最多可以选择50张\uFF0C目前选择了' + (tostring(ProcessInvoiceIdList.length) + '张'));
            } else {
                globalTable['billType'] = billTypeList_utils.bzd;
                globalTable['BillApplyBackBtnText'] = '返回首页';
                lua_bill.to_bill_module_page(InvokePageArg);
            }
        } else if (ctrl === 'process_invoice_by_xcbxd') {
            lua_menu.to_porcess_travel_reimbursement_page(InvokePageArg);
        }
    } else {
        alert('敬请期待');
    }
};
lua_menu.process_invoice_by_reimbursement_menu = function () {
    var router_fun = 'lua_menu.app_alert_menu_action';
    var close_fun = 'lua_jjbx.close_add_invoice_menu';
    var menu1 = {
        title: '报账单',
        tip: '',
        fun: router_fun,
        arg: 'process_invoice_by_bzd'
    };
    var menu2 = {
        title: '行程报销单',
        tip: '',
        fun: router_fun,
        arg: 'process_invoice_by_xcbxd'
    };
    var menu_info_list = {};
    table.insert(menu_info_list, menu1);
    table.insert(menu_info_list, menu2);
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
lua_menu.alert_upload_enclosure_menu = function () {
    var router_fun = 'lua_menu.app_alert_menu_action';
    var close_fun = 'lua_system.close_app_alert_menu';
    var tableArg = {
        menu_info_list: [
            {
                title: '拍照',
                tip: '',
                fun: router_fun,
                arg: 'upload_enclosure_by_camera'
            },
            {
                title: '相册',
                tip: '',
                fun: router_fun,
                arg: 'upload_enclosure_by_album'
            },
            {
                title: '从文件夹选择',
                tip: '',
                fun: router_fun,
                arg: 'upload_enclosure_by_filesystem'
            }
        ],
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
lua_menu.alert_upload_app_cache_enclosure_menu = function (MenuArg) {
    var MenuArg = formatNull(MenuArg);
    var SupportFileType = vt('SupportFileType', MenuArg);
    var router_fun = 'lua_menu.app_alert_menu_action';
    var close_fun = 'lua_system.close_app_alert_menu';
    var menu_info_list = {};
    if (string.find(SupportFileType, 'image')) {
        var imageUploadMenu1 = {
            title: '拍照',
            tip: '',
            fun: router_fun,
            arg: 'upload_app_cache_enclosure_by_camera'
        };
        var imageUploadMenu2 = {
            title: '相册',
            tip: '',
            fun: router_fun,
            arg: 'upload_app_cache_enclosure_by_album'
        };
        table.insert(menu_info_list, imageUploadMenu1);
        table.insert(menu_info_list, imageUploadMenu2);
    }
    if (string.find(SupportFileType, 'file')) {
    }
    if (string.find(SupportFileType, 'video')) {
        var videoUploadMenu1 = {
            title: '拍摄视频',
            tip: '',
            fun: router_fun,
            arg: 'upload_app_cache_video_by_shoot'
        };
        var videoUploadMenu2 = {
            title: '从相册选择视频',
            tip: '',
            fun: router_fun,
            arg: 'upload_app_cache_video_by_album'
        };
        table.insert(menu_info_list, videoUploadMenu1);
        table.insert(menu_info_list, videoUploadMenu2);
    }
    if (menu_info_list.length > 0) {
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
    } else {
        debug_alert('菜单为空');
    }
};
lua_menu.alert_upload_bank_card = function (widgetname) {
    globalTable['CardNoWidgetName'] = widgetname;
    var router_fun = 'lua_menu.app_alert_menu_action';
    var close_fun = 'lua_system.close_app_alert_menu';
    var tableArg = {
        menu_info_list: [
            {
                title: '拍照',
                tip: '',
                fun: router_fun,
                arg: 'upload_bank_card_to_scan_by_camera'
            },
            {
                title: '相册',
                tip: '',
                fun: router_fun,
                arg: 'upload_bank_card_to_scan_by_album'
            }
        ],
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
lua_menu.get_index_advert = function () {
    var res = {};
    var paddingStr = '';
    if (platform === 'iPhone OS') {
        paddingStr = '\\"';
    } else {
        paddingStr = '\\\\\\"';
    }
    var tsjyItem = {
        src: 'local:index_bannerBottom_tsjy.png',
        onClick: 'indexPage_advert_router(' + (paddingStr + ('tsjy' + (paddingStr + ')')))
    };
    var jjdsjItem = {
        src: 'local:index_bannerBottom_jjdsj_2022.png',
        onClick: 'indexPage_advert_router(' + (paddingStr + ('jjdsj' + (paddingStr + ')')))
    };
    var slfwItem = {
        src: 'local:index_bannerBottom_slfw.png',
        onClick: 'indexPage_advert_router(' + (paddingStr + ('slfw' + (paddingStr + ')')))
    };
    var zxcgItem = {
        src: 'local:index_bannerBottom_zxcg.png',
        onClick: 'indexPage_advert_router(' + (paddingStr + ('zxcg' + (paddingStr + ')')))
    };
    var yccxItem = {
        src: 'local:index_bannerBottom_yccx.png',
        onClick: 'indexPage_advert_router(' + (paddingStr + ('yccx' + (paddingStr + ')')))
    };
    var ycfwItem = {
        src: 'local:index_bannerBottom_ycfw.png',
        onClick: 'indexPage_advert_router(' + (paddingStr + ('ycfw' + (paddingStr + ')')))
    };
    if (globalTable['userType'] === '2') {
        var sharePeopleScene = vt('sharePeopleScene', globalTable);
        if (string.find(sharePeopleScene, JJBX_SharePeopleSecneCode.zxcg) || string.find(sharePeopleScene, JJBX_SharePeopleSecneCode.ejyshop)) {
            table.insert(res, zxcgItem);
        }
        if (string.find(sharePeopleScene, JJBX_SharePeopleSecneCode.yccx)) {
            table.insert(res, yccxItem);
        }
        var ycfwConfigList = splitUtils(JJBX_SharePeopleSecneCode.ycfw, ',');
        var ycfwMatchRes = 'false';
        for (let i = 1; ycfwConfigList.length; i++) {
            if (string.find(sharePeopleScene, ycfwConfigList[i])) {
                ycfwMatchRes = 'true';
                break;
            }
        }
        if (ycfwMatchRes === 'true') {
            table.insert(res, ycfwItem);
        }
    } else {
        table.insert(res, tsjyItem);
        table.insert(res, slfwItem);
        table.insert(res, zxcgItem);
        table.insert(res, yccxItem);
        table.insert(res, ycfwItem);
    }
    return res;
};
lua_menu.myinfo_menu_config = function () {
    var userType = vt('userType', globalTable);
    var PCConfigListsTable = vt('PCConfigListsTable', globalTable);
    var res = {};
    if (userType != '2') {
        table.insert(res, {
            Name: '银行卡管理',
            Icon: 'mine_ico_01.png',
            Func: 'lua_menu.to_card_management_page()'
        });
    }
    if (userType != '2') {
        table.insert(res, {
            Name: '信用值',
            Icon: 'mine_ico_02.png',
            Func: 'lua_menu.to_credit_management_page()'
        });
    }
    table.insert(res, {
        Name: '安全中心',
        Icon: 'mine_ico_03.png',
        Func: 'lua_menu.to_security_center_page()'
    });
    if (userType != '2') {
        table.insert(res, {
            Name: '共享人管理',
            Icon: 'mine_ico_sharepm.png',
            Func: 'lua_menu.to_share_people_manage_page()'
        });
    }
    table.insert(res, {
        Name: '消息设置',
        Icon: 'mine_ico_04.png',
        Func: 'lua_menu.to_msg_setting_page()'
    });
    table.insert(res, {
        Name: '隐私',
        Icon: 'ico_private.png',
        Func: 'lua_menu.to_protocol_menu_page()'
    });
    table.insert(res, {
        Name: '联系我们',
        Icon: 'mine_ico_05.png',
        Func: 'lua_menu.to_contactUs_page()'
    });
    return res;
};
lua_menu.to_budget_page_by_other_app = function (ArgObj) {
    var OpenByAppName = vt('OpenByAppName', ArgObj);
    if (OpenByAppName === 'CzbankMobileBankApp') {
        var JJBXAppOpenPage = vt('JJBXAppOpenPage', ArgObj);
        var CurrentPageInfo = lua_page.current_page_info();
        var PageFilePath = vt('page_file_path', CurrentPageInfo);
        lua_mission.clear_app_register_mission({ ClearMsg: '打开成功' });
        if (JJBXAppOpenPage === 'TravelTongCheng') {
            init_travel_reserve_h5_page('tongcheng');
        } else if (JJBXAppOpenPage === 'TravelXieCheng') {
            init_travel_reserve_h5_page('xiecheng');
        } else {
            var visitMenuId = '';
            if (JJBXAppOpenPage === 'CarService') {
                visitMenuId = 'yccx';
            } else if (JJBXAppOpenPage === 'TravelService') {
                visitMenuId = 'slfw';
            } else if (JJBXAppOpenPage === 'EatELMe') {
                visitMenuId = 'ycfw';
            } else {
            }
            if (visitMenuId != '') {
                var serverMenuConfig = lua_menu.server_menu_info(visitMenuId);
                var serverMenuInfo = vt('menuInfo', serverMenuConfig);
                var menuUrl = vt('url', serverMenuInfo);
                if (PageFilePath === menuUrl) {
                } else {
                    history.clear();
                    lua_menu.onclick('id=' + visitMenuId);
                }
            } else {
            }
        }
    } else {
        alert('未知渠道 ' + OpenByAppName);
    }
};
open_file_system = function () {
    globalTable['uploadInvoiceBack'] = 'true';
    var UploadAppCacheEnclosureParams1 = lua_format.base64_encode(vt('UploadAppCacheEnclosureParams1', globalTable));
    var client_file_upload_arg = {
        pagetitle: C_SearchContextBegin + ('文件名' + C_SearchContextEnd),
        uploadtype: 'multiple',
        counts: '5',
        countsmsg: '选择文件不能大于5个',
        filetype: 'pdf,ofd,png,jpg,jpeg,PDF,OFD,PNG,JPG,JPEG',
        filetypemsg: '目前只支持上传pdf,ofd格式的文件和发票图片',
        callfun: 'lua_jjbx.upload_invoice_to_relate_call',
        uploadflag: 'upInvoiceFile',
        loadFileType: '图片,PDF,OFD',
        defaultType: 'PDF',
        params1: UploadAppCacheEnclosureParams1
    };
    lua_system.client_file_upload(client_file_upload_arg);
};
module.exports = { lua_menu: lua_menu };