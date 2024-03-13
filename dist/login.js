const lua_system = require('./system');
const lua_format = require('./format');
const lua_menu = require('./menu');
const lua_jjbx = require('./jjbx');
const lua_mission = require('./mission');
const lua_page = require('./page');
lua_login = {};
lua_login.do_login = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['TranCode'] = 'login';
        var phoneInfo = vt('phoneInfo', systemTable);
        ReqParams['deviceId'] = vt('deviceId', phoneInfo);
        ReqParams['deviceType'] = vt('deviceType', phoneInfo);
        ReqParams['osVersion'] = vt('osVersion', phoneInfo);
        ReqParams['phoneType'] = vt('phoneType', phoneInfo);
        ReqParams['appVersion'] = vt('appVersion', phoneInfo);
        ReqParams['screenWidth'] = vt('screenWidth', phoneInfo);
        ReqParams['screenHeight'] = vt('screenHeight', phoneInfo);
        var deviceName = lua_system.get_device_name();
        var deviceNameEncode = lua_format.arg_encode(deviceName);
        var deviceNameUse = '';
        if (ryt.getLengthByStr(deviceNameEncode) <= 50) {
            deviceNameUse = deviceNameEncode;
        }
        ReqParams['deviceName'] = deviceNameUse;
        invoke_trancode_donot_checkRepeat('jjbx_login', 'entrance', ReqParams, lua_login.do_login, {}, pagecallback, { CloseLoading: 'false' });
    } else {
        var res = json2table(ResParams['responseBody']);
        var errorNo = vt('errorNo', res);
        var errorMsg = vt('errorMsg', res);
        if (errorNo === '000000') {
            systemTable['systemDateTime'] = res['systemDateTime'];
            var SaveLoginRes = lua_login.save_login(res);
            push_register(vt('PkUser', res));
            var fistLogin = vt('FistLogin', res);
            var SetFirstLogin = vt('SetFirstLogin', globalTable);
            var LoginDeviceProtect = vt('LoginDeviceProtect', configTable);
            var checkDeviceFlag = vt('CheckDeviceFlag', res);
            globalTable['UserRiskCheckMsg'] = vt('UserRiskCheckMsg', res);
            var LoginType = vt('LoginType', res);
            if (fistLogin === '1') {
                globalTable['userAppraise'] = 'false';
                if (SetFirstLogin === '') {
                    globalTable['DoLoginResParams'] = ResParams;
                    var KeyUserSet = vt('KeyUserSet', res);
                    invoke_page('jjbx_login/xhtml/jjbx_fristLogin_set_password.xhtml', page_callback, { KeyUserSet: KeyUserSet });
                } else {
                    globalTable['SetFirstLogin'] = '';
                    lua_menu.to_index_page('go');
                }
            } else {
                globalTable['userAppraise'] = 'true';
                if (LoginDeviceProtect === 'true') {
                    if (checkDeviceFlag === '2') {
                        lua_login.device_bind('', { LoginType: LoginType });
                    } else if (checkDeviceFlag === '') {
                        lua_login.device_protect_error();
                    } else {
                        lua_menu.to_index_page('go');
                    }
                } else {
                    lua_menu.to_index_page('go');
                }
            }
            lua_system.msgMarsRegister('', {});
        } else {
            del_db_value('loginSessionid');
            jjbx_show_business_err(errorNo, errorMsg);
            var ClientRegisterMissionArg = get_db_value('ClientRegisterMissionArg');
            var missionArg = lua_format.url_decode(ClientRegisterMissionArg);
            var ArgObj = json2table(missionArg);
            var MissionType = vt('MissionType', ArgObj);
            if (MissionType === 'ToBudgetPageOpenByOtherApp' || vt('LoginType', res) === '5') {
                var CommonLogRegisterArg = {
                    LogExplain: '第三方登录极简报销系统失败\uFF0C错误信息\uFF1A' + errorMsg,
                    LogInfo: ClientRegisterMissionArg
                };
                lua_jjbx.common_log_register('', CommonLogRegisterArg);
                lua_mission.clear_app_register_mission({ ClearMsg: '第三方APP免密登录失败' });
                var CurrentPageInfo = lua_page.current_page_info();
                var PageFilePath = vt('page_file_path', CurrentPageInfo);
                if (PageFilePath != 'jjbx_login/xhtml/jjbx_login.xhtml') {
                    lua_login.login_type_router('account_login');
                }
            } else {
                if (isNoPasswordLogin === 'true') {
                    isNoPasswordLogin = 'false';
                    var token = get_db_value('token');
                    lua_login.qry_login_type('', { token: token });
                }
            }
        }
    }
};
lua_login.device_bind = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['TranCode'] = 'GetBindDeviceList';
        invoke_trancode('jjbx_myInfo', 'securityCenter', ReqParams, lua_login.device_bind, {}, all_callback, { CloseLoading: 'false' });
    } else {
        var res = json2table(ResParams['responseBody']);
        var errorNo = vt('errorNo', res);
        var errorMsg = vt('errorMsg', res);
        if (res['errorNo'] === '000000') {
            var deviceListData = vt('identificationDeviceList', res);
            var CurrentLoginDeviceCounts = deviceListData.length;
            globalTable['CurrentLoginDeviceCounts'] = CurrentLoginDeviceCounts;
            var ReqLoginType = vt('ReqLoginType', res);
            if (ReqLoginType === '2') {
                if (CurrentLoginDeviceCounts >= C_Bind_Device_Max_Counts) {
                    alert_confirm('温馨提示', '您已开启登录保护\uFF0C最多可绑定5个设备\uFF0C当前已绑定5个设备\uFF0C不允许继续绑定', '', '确定', 'lua_menu.to_index_page');
                } else {
                    alert_confirm('温馨提示', '您已开启登录保护\uFF0C是否绑定该手机作为您的常用设备', '不绑定', '绑定', 'lua_login.bind_device_confirm');
                }
            } else {
                invoke_page('jjbx_login/xhtml/device_bind.xhtml', page_callback, { CloseLoading: 'false' });
            }
        } else {
            lua_login.device_protect_error(errorMsg);
        }
    }
};
lua_login.device_protect_error = function (ErrorMsg) {
    var ErrorMsg = formatNull(ErrorMsg, '登录保护状态异常');
    ErrorMsg = ErrorMsg + '\uFF0C请重新登录';
    alert_confirm('温馨提示', ErrorMsg, '', '确定', 'alert_confirm_call', 'CallFun=lua_login.exit_login');
};
lua_login.bind_device_confirm = function (click) {
    if (tostring(click) === '1') {
        lua_login.do_bind_device();
    } else {
        lua_menu.to_index_page('go');
    }
};
lua_login.do_bind_device = function (ResParams) {
    if (formatNull(ResParams) === '') {
        invoke_trancode('jjbx_login', 'entrance', {
            TranCode: 'BindDeviceByToken',
            identificationDevice: '1',
            token: get_db_value('token')
        }, lua_login.do_bind_device, {}, all_callback, { CloseLoading: 'false' });
    } else {
        var res = json2table(ResParams['responseBody']);
        var errorNo = vt('errorNo', res);
        var errorMsg = vt('errorMsg', res);
        if (errorNo != '000000') {
            alert(errorMsg);
        }
        lua_menu.to_index_page('go');
    }
};
lua_login.save_login = function (loginRes) {
    var phoneInfo = vt('phoneInfo', systemTable);
    var deviceID = vt('deviceId', phoneInfo);
    var loginSessionid = vt('loginSessionid', loginRes);
    var token = loginSessionid + ('/' + deviceID);
    var userName = vt('UserName', loginRes);
    set_db_value('userName', userName);
    globalTable['userName'] = userName;
    globalTable['name'] = userName;
    var psnName = vt('psnname', loginRes);
    globalTable['psnName'] = psnName;
    var workid = vt('WorkId', loginRes);
    set_db_value('workid', workid);
    globalTable['workid'] = workid;
    var orgFlag = vt('OrgFlag', loginRes);
    globalTable['orgFlag'] = orgFlag;
    var ServerMenuVersion = vt('ServerMenuVersion', loginRes);
    set_db_value('token', token);
    set_db_value('loginSessionid', loginSessionid);
    globalTable['loginSessionid'] = loginSessionid;
    set_db_value('ServerMenuVersion', ServerMenuVersion);
    globalTable['menuList'] = vt('menuList', loginRes);
    systemTable['AppEnvironment'] = vt('AppEnvironment', loginRes);
    globalTable['ShowCreditExplainFlag'] = vt('ShowCreditExplainFlag', loginRes, 'false');
    globalTable['CreditExplainUrl'] = vt('CreditExplainUrl', loginRes);
    globalTable['phone'] = vt('Mobile', loginRes);
    globalTable['userType'] = vt('UserType', loginRes);
    globalTable['sharePeopleScene'] = vt('SharePeopleScene', loginRes);
    var defaultCorp = vt('defaultCorp', loginRes);
    globalTable['defaultCorp'] = defaultCorp;
    globalTable['selectOrgList'] = [{
            unitname: vt('unitshotname', loginRes),
            unitcode: vt('unitcode', loginRes),
            pkCorp: globalTable['defaultCorp']
        }];
    globalTable['PeopleCompanyName'] = vt('corpname', loginRes);
    globalTable['PkUser'] = vt('PkUser', loginRes);
    globalTable['PCConfigListsTable'] = json2table(vt('PCConfigListsJson', loginRes));
    globalTable['AskPermissionTreeData'] = vt('AskPermissionTreeData', loginRes);
    companyTable['viewauthority'] = vt('Viewauthority', loginRes);
    companyTable['thirdPartyServiceStatus'] = json2table(vt('ThirdPartyServiceStatus', loginRes));
    if (configTable['lua_debug'] === 'true') {
        lua_login.save_login_user_list(loginRes);
    }
    return 'true';
};
lua_login.save_login_user_list = function (Arg) {
    var userName = vt('UserName', Arg);
    var workid = vt('WorkId', Arg);
    var loginAcc = vt('LoginAcc', Arg);
    var userType = vt('UserType', Arg);
    var LoginUserListJson = get_db_value('LoginUserListJson');
    var LoginUserListTable = {};
    if (LoginUserListJson != '') {
        LoginUserListTable = json2table(LoginUserListJson);
    }
    var LoginUserListCounts = LoginUserListTable.length;
    var MatchRes = 'false';
    for (let i = 1; LoginUserListCounts; i++) {
        var UserInfo = LoginUserListTable[i];
        var SaveLoginAcc = vt('loginAcc', UserInfo);
        if (SaveLoginAcc === loginAcc) {
            MatchRes = 'true';
            table.remove(LoginUserListTable, i);
            break;
        }
    }
    var AddUser = {
        userName: userName,
        workid: workid,
        loginAcc: loginAcc,
        userType: userType
    };
    table.insert(LoginUserListTable, AddUser);
    set_db_value('LoginUserListJson', table2json(LoginUserListTable));
};
lua_login.login_by_otherapp_prepare = function (LoginArg) {
    var LoginArg = formatNull(LoginArg);
    var LoginArgDecode = lua_format.base64_decode(LoginArg);
    var LoginArgTable = json2table(LoginArgDecode);
    var JJBXAppLoginToken = vt('Token', LoginArgTable);
    var Relogin = vt('Relogin', LoginArgTable);
    if (Relogin === 'true') {
        var ReqParams = {
            BusinessCall: 'lua_login.token_login_by_otherapp',
            BusinessArg: LoginArg,
            ForceExit: 'true'
        };
        lua_login.exit_login('', ReqParams);
    } else {
        lua_login.token_login_by_otherapp(LoginArg);
    }
};
lua_login.token_login_by_otherapp = function (LoginArg) {
    var LoginArg = formatNull(LoginArg);
    var LoginArgDecode = lua_format.base64_decode(LoginArg);
    var LoginArgTable = json2table(LoginArgDecode);
    debug_alert('第三方APP进行认证后\uFF0C通过token登录极简报销' + (foreach_arg2print(LoginArgTable) + ('\\n' + ('LoginArgDecode : ' + (LoginArgDecode + ('\\n' + ''))))));
    var LoadLoginArg = { JJBXAppLoginToken: vt('JJBXAppLoginToken', LoginArgTable) };
    lua_login.load_login(LoadLoginArg);
};
lua_login.load_login = function (LoadLoginArg) {
    var LoadLoginArg = formatNull(LoadLoginArg);
    var SaveUserName = get_db_value('jjbx_acc');
    var SavePhoneNo = get_db_value('phoneNo');
    var LoadLoginStyle = '1';
    var JJBXAppLoginToken = vt('JJBXAppLoginToken', LoadLoginArg);
    var token = get_db_value('token');
    if (JJBXAppLoginToken != '') {
        LoadLoginStyle = '4';
    } else {
        if (SaveUserName === '' && SavePhoneNo === '') {
            LoadLoginStyle = '1';
        } else {
            if (token === '') {
                LoadLoginStyle = '1';
            } else {
                var loginSessionid = get_db_value('loginSessionid');
                var needUpdate = vt('NeedUpdate', globalTable);
                if (loginSessionid === '' || needUpdate != '' || C_NoPwdLogin === 'false') {
                    LoadLoginStyle = '3';
                } else {
                    LoadLoginStyle = '2';
                }
            }
        }
    }
    if (LoadLoginStyle === '1') {
        lua_menu.to_login_page();
    } else if (LoadLoginStyle === '2') {
        isNoPasswordLogin = 'true';
        var loginReqParams = {
            token: token,
            loginType: '3'
        };
        lua_login.do_login('', loginReqParams);
    } else if (LoadLoginStyle === '3') {
        lua_login.qry_login_type('', { token: token });
    } else if (LoadLoginStyle === '4') {
        var loginReqParams = {
            token: JJBXAppLoginToken,
            loginType: '5'
        };
        lua_login.do_login('', loginReqParams);
    } else {
        lua_menu.to_login_page();
    }
};
to_acc_login_page = function () {
    jjbx_to_login_page('0');
};
to_mobile_login_page = function () {
    jjbx_to_login_page('mobile_login');
};
to_other_login_page = function () {
    jjbx_to_login_page(globalTable['loginType']);
};
jjbx_to_login_page = function (logintype) {
    var logintype = formatNull(logintype, '0');
    var PageUrl = login_page(logintype);
    var UseJumpStyle = '';
    if (logintype === '0') {
        UseJumpStyle = 'left';
    }
    history.clear();
    invoke_page_noloading_checkRepeat(PageUrl, page_callback, {
        JumpStyle: UseJumpStyle,
        AddPage: 'true'
    });
};
lua_login.exit_login_confirm = function () {
    alert_confirm('温馨提示', '您确定要安全退出登录吗\uFF1F', '取消', '确定', 'alert_confirm_call', 'CallFun=lua_login.exit_login');
};
lua_login.exit_login = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        var BusinessCall = vt('BusinessCall', ReqParams);
        var BusinessArg = vt('BusinessArg', ReqParams);
        var ForceExit = vt('ForceExit', ReqParams);
        var token = get_db_value('token');
        invoke_trancode_noloading('jjbx_login', 'entrance', {
            TranCode: 'exitLogin',
            token: token
        }, lua_login.exit_login, {
            BusinessCall: BusinessCall,
            BusinessArg: BusinessArg,
            ForceExit: ForceExit
        });
    } else {
        del_db_value('loginSessionid');
        isNoPasswordLogin = 'false';
        globalTable = {};
        companyTable = {};
        globalTable['AutoQuickLogin'] = 'false';
        history.clear();
        lua_mission.index_set('ready');
        var responseBody = json2table(ResParams['responseBody']);
        var loginType = formatNull(responseBody['logonType']);
        globalTable['loginType'] = loginType;
        var PageUrl = login_page(loginType);
        invoke_page_noloading_checkRepeat(PageUrl, page_callback, { JumpStyle: 'none' });
        var BusinessCall = vt('BusinessCall', ResParams);
        var BusinessArg = vt('BusinessArg', ResParams);
        if (BusinessCall != '') {
            debug_alert('注销后调用回调\\n' + ('BusinessCall : ' + (BusinessCall + ('\\n' + ('BusinessArg : ' + (BusinessArg + ('\\n' + '')))))));
            lua_system.do_function(BusinessCall, BusinessArg);
        }
    }
};
lua_login.qry_login_type = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['TranCode'] = 'getLoginType';
        invoke_trancode_donot_checkRepeat('jjbx_login', 'entrance', ReqParams, lua_login.qry_login_type, {}, all_callback, { CloseLoading: 'false' });
    } else {
        close_loading();
        var res = json2table(ResParams['responseBody']);
        var errorNo = vt('errorNo', res);
        var errorMsg = vt('errorMsg', res);
        if (errorNo != '000000') {
            alert(errorMsg);
            del_db_value('loginSessionid');
            isNoPasswordLogin = 'false';
        }
        var loginType = vt('logonType', res, '0');
        globalTable['loginType'] = loginType;
        var PageUrl = login_page(loginType);
        invoke_page_noloading_checkRepeat(PageUrl, page_callback, { JumpStyle: 'none' });
    }
};
auto_quick_login_status = function () {
    var res = '';
    var AutoQuickLogin = formatNull(globalTable['AutoQuickLogin'], 'true');
    var NeedUpdate = formatNull(globalTable['NeedUpdate']);
    if (AutoQuickLogin === 'true' && NeedUpdate === '') {
        res = 'true';
    } else {
        res = 'false';
    }
    return res;
};
lua_login.read_agreement_ctrl = function () {
    if (globalTable['ReadLoginAgreementFlag'] === 'false') {
        globalTable['ReadLoginAgreementFlag'] = 'true';
        changeProperty('agreement_ctrl_icon', 'src', 'local:selected_round.png');
    } else {
        globalTable['ReadLoginAgreementFlag'] = 'false';
        changeProperty('agreement_ctrl_icon', 'src', 'local:select.png');
    }
};
lua_login.login_type_router = function (LoginType) {
    lua_system.close_app_alert_menu();
    var LastLoginType = vt('LastLoginType', globalTable);
    var PageUrl = '';
    if (LoginType === 'account_login') {
        PageUrl = 'jjbx_login/xhtml/jjbx_login.xhtml';
    } else if (LoginType === 'mobile_login') {
        PageUrl = 'jjbx_login/xhtml/jjbx_mobileLogin.xhtml';
    } else if (LoginType === 'FaceID_login') {
        PageUrl = 'jjbx_login/xhtml/jjbx_faceIDLogin.xhtml';
    } else if (LoginType === 'TouchID_login') {
        PageUrl = 'jjbx_login/xhtml/jjbx_touchIDLogin.xhtml';
    } else if (LoginType === 'gesture_login') {
        PageUrl = 'jjbx_login/xhtml/jjbx_gestureLogin.xhtml';
    } else if (LoginType === 'change_user') {
        globalTable['ChangeUserFlag'] = 'true';
        if (LastLoginType === 'account_login') {
            PageUrl = 'jjbx_login/xhtml/jjbx_login.xhtml';
        } else if (LastLoginType === 'mobile_login') {
            PageUrl = 'jjbx_login/xhtml/jjbx_mobileLogin.xhtml';
        } else {
            PageUrl = 'jjbx_login/xhtml/jjbx_login.xhtml';
        }
    } else {
        debug_alert('未定义');
    }
    if (PageUrl != '') {
        history.clear();
        invoke_page_noloading_checkRepeat(PageUrl, page_callback, {
            JumpStyle: 'right',
            AddPage: 'true'
        });
    }
};
lua_login.init_login_type = function (LastLoginType) {
    var LastLoginType = formatNull(LastLoginType);
    globalTable['LastLoginType'] = LastLoginType;
    var QryLoginType = vt('loginType', globalTable);
    var ChangeUserFlag = vt('ChangeUserFlag', globalTable);
    var router_fun = 'lua_login.login_type_router';
    var close_fun = 'lua_system.close_app_alert_menu';
    var account_login_menu = {
        title: '账号密码登录',
        tip: '',
        fun: router_fun,
        arg: 'account_login'
    };
    var mobile_login_menu = {
        title: '手机号登录',
        tip: '',
        fun: router_fun,
        arg: 'mobile_login'
    };
    var FaceID_login_menu = {
        title: '人脸登录',
        tip: '',
        fun: router_fun,
        arg: 'FaceID_login'
    };
    var TouchID_login_menu = {
        title: '指纹登录',
        tip: '',
        fun: router_fun,
        arg: 'TouchID_login'
    };
    var gesture_login_menu = {
        title: '手势密码登录',
        tip: '',
        fun: router_fun,
        arg: 'gesture_login'
    };
    var change_user_menu = {
        title: '切换用户',
        tip: '',
        fun: router_fun,
        arg: 'change_user'
    };
    var menu_info_list = {};
    if (ChangeUserFlag === 'true') {
        globalTable['ChangeUserFlag'] = 'true';
        if (LastLoginType === 'account_login') {
            table.insert(menu_info_list, mobile_login_menu);
        } else if (LastLoginType === 'mobile_login') {
            table.insert(menu_info_list, account_login_menu);
        }
    } else {
        globalTable['ChangeUserFlag'] = 'false';
        if (LastLoginType != 'account_login') {
            table.insert(menu_info_list, account_login_menu);
        }
        if (LastLoginType != 'mobile_login') {
            table.insert(menu_info_list, mobile_login_menu);
        }
        if (LastLoginType != 'gesture_login') {
            if (QryLoginType === '1') {
                table.insert(menu_info_list, gesture_login_menu);
            }
        }
        if (LastLoginType != 'TouchID_login') {
            if (systemTable['SupportLoginType'] === 'TouchID') {
                if (QryLoginType === '2') {
                    table.insert(menu_info_list, TouchID_login_menu);
                }
            }
        }
        if (LastLoginType != 'FaceID_login') {
            if (systemTable['SupportLoginType'] === 'FaceID') {
                if (QryLoginType === '3') {
                    table.insert(menu_info_list, FaceID_login_menu);
                }
            }
        }
        if (QryLoginType != '') {
            table.insert(menu_info_list, change_user_menu);
        }
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
lua_login.cancel_change_user = function () {
    globalTable['ChangeUserFlag'] = 'false';
    var LastLoginType = vt('LastLoginType', globalTable);
    lua_login.login_type_router(LastLoginType);
};
module.exports = { lua_login: lua_login };