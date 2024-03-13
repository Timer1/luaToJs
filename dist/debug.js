const lua_page = require('./page');
const lua_system = require('./system');
lua_debug = {};
lua_debug.switch = function (PageReload) {
    if (systemTable['EnvAllowDebug'] === 'true') {
        if (configTable['lua_debug'] === 'true') {
            configTable['lua_debug'] = 'false';
            alertToast1('调试关闭');
        } else {
            configTable['lua_debug'] = 'true';
            if (get_db_value('DebugPageTipShow') === '') {
                set_db_value('DebugPageTipShow', 'true');
                alert_confirm('APP调试开启', '用于查看设查信息\uFF0C了解业务执行流程\uFF0C执行客户端开放功能等\u3002\\n应用于开发\u3001测试\u3001验证环境\u3002\\n生产环境屏蔽该功能\u3002');
            } else {
                alertToast0('调试开启');
            }
        }
        if (PageReload === 'true') {
            lua_page.reload_page();
        }
    }
};
lua_debug.default_pwd = function () {
    var res = '';
    if (configTable['lua_debug'] === 'true') {
        var AppEnvironment = vt('AppEnvironment', systemTable);
        if (AppEnvironment != '' && AppEnvironment != 'pro') {
            res = 'Aa95527';
            debug_alertToast('密码填充');
        } else {
            res = '';
        }
    }
    return res;
};
lua_debug.change_env = function () {
    if (configTable['lua_debug'] === 'true') {
        var close_fun = 'lua_system.close_app_alert_menu';
        var tableArg = {
            menu_info_list: [
                {
                    title: '开发环境',
                    tip: 'dev',
                    fun: 'lua_debug.env_switch',
                    arg: 'dev'
                },
                {
                    title: '测试环境',
                    tip: 'sit',
                    fun: 'lua_debug.env_switch',
                    arg: 'sit'
                },
                {
                    title: '验证环境',
                    tip: 'uat',
                    fun: 'lua_debug.env_switch',
                    arg: 'uat'
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
    }
};
lua_debug.env_switch = function (env) {
    lua_system.close_app_alert_menu();
    var AppEnvironment = vt('AppEnvironment', systemTable);
    if (AppEnvironment != env) {
        var reqParams = { env: env };
        lua_debug.do_env_switch('', reqParams);
    } else {
        alert('当前为' + (AppEnvironment + '环境'));
    }
};
lua_debug.do_env_switch = function (resParams, reqParams) {
    if (configTable['lua_debug'] === 'true') {
        if (formatNull(resParams) === '') {
            var reqParams = formatNull(reqParams);
            reqParams['TranCode'] = 'ChangeRunEnv';
            invoke_trancode_donot_checkRepeat('jjbx_service', 'app_service', reqParams, lua_debug.do_env_switch, {}, all_callback, { CloseLoading: 'false' });
        } else {
            var res = json2table(resParams['responseBody']);
            systemTable['AppEnvironment'] = vt('Env', res);
            alert(res['ReMsg']);
        }
    }
};
debug_alert = function (alertMsg) {
    if (configTable['lua_debug'] === 'true' && systemTable['EnvAllowDebug'] === 'true') {
        var alertMsg = formatNull(alertMsg, '调试打印参数为空');
        alertMsg = '\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D调试信息\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\\n\\n' + alertMsg;
        if (platform === 'iPhone OS') {
            ryt.ios_alert(alertMsg);
        } else {
            window.alert(alertMsg);
        }
    }
};
debug_alertToast = function (alertMsg) {
    if (configTable['lua_debug'] === 'true') {
        if (systemTable['EnvAllowDebug'] === 'true') {
            var alertMsg = formatNull(alertMsg, '无信息');
            if (alertMsg != '') {
                ryt.showToast('0', alertMsg, '', '', '');
            }
        }
    }
};
lua_debug.reload_page = function () {
    if (configTable['lua_debug'] === 'true') {
        lua_page.reload_page();
    }
};
lua_debug.alert_menu = function (Arg) {
    if (systemTable['EnvAllowDebug'] === 'true' && configTable['lua_debug'] === 'true') {
        var close_fun = 'lua_system.close_app_alert_menu';
        var call_fun = 'lua_debug.alert_menu_call';
        var debugTip = '开启调试';
        if (configTable['lua_debug'] === 'true') {
            debugTip = '关闭调试';
        }
        var tableArg = {
            menu_info_list: [
                {
                    title: '返回首页',
                    tip: '',
                    fun: call_fun,
                    arg: 'CallFun=lua_menu.to_index_page&CallArg=back'
                },
                {
                    title: '业务首页',
                    tip: '',
                    fun: call_fun,
                    arg: 'CallFun=back_fun&CallArg=2'
                },
                {
                    title: '应用重启',
                    tip: '更新最新离线资源',
                    fun: call_fun,
                    arg: 'CallFun=lua_system.call_client_timeout'
                },
                {
                    title: '应用还原',
                    tip: '删除应用数据',
                    fun: call_fun,
                    arg: 'CallFun=lua_system.confirm_clear_app_cache'
                },
                {
                    title: '首页调试',
                    tip: '首页任务序列调试',
                    fun: call_fun,
                    arg: 'CallFun=index_page_test'
                },
                {
                    title: '功能演示',
                    tip: '前往demo页面',
                    fun: call_fun,
                    arg: 'CallFun=lua_menu.to_demo_page'
                },
                {
                    title: '切换环境',
                    tip: '切换当前服务器直连的后台服务器',
                    fun: call_fun,
                    arg: 'CallFun=lua_debug.change_env'
                },
                {
                    title: '注销登录',
                    tip: '注销当前用户登录并退到登录界面',
                    fun: call_fun,
                    arg: 'CallFun=lua_login.exit_login_confirm'
                }
            ],
            cancel_menu_info: [{
                    title: '应用关闭',
                    tip: '',
                    fun: call_fun,
                    arg: 'CallFun=closeApp'
                }],
            bg_click_fun: close_fun,
            bg_click_arg: ''
        };
        var jsonArg = table2json(tableArg);
        lua_system.app_alert_menu(jsonArg);
    }
};
lua_debug.alert_menu_call = function (CallArg) {
    lua_system.close_app_alert_menu();
    var CallArgTable = string_to_table(CallArg);
    var DoCallFun = vt('CallFun', CallArgTable);
    var DoCallArg = vt('CallArg', CallArgTable);
    lua_system.do_function(DoCallFun, DoCallArg);
};
lua_debug.app_debug = function (ResParams, ReqParams) {
    if (systemTable['EnvAllowDebug'] === 'true') {
        if (formatNull(ResParams) === '') {
            var ReqParams = formatNull(ReqParams);
            ReqParams['TranCode'] = 'AppDebug';
            invoke_trancode_noloading('jjbx_service', 'app_service', ReqParams, lua_debug.app_debug, {});
        } else {
        }
    }
};
module.exports = { lua_debug: lua_debug };