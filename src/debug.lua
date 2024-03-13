--[[调试的lua]]

lua_debug = {};

--[[调试开关]]
function lua_debug.switch(PageReload)
    if systemTable["EnvAllowDebug"] == "true" then
        if configTable["lua_debug"] == "true" then
            configTable["lua_debug"] = "false";
            alertToast1("调试关闭");
        else
            configTable["lua_debug"] = "true";
            --调试信息只弹一次
            if get_db_value("DebugPageTipShow") == "" then
                set_db_value("DebugPageTipShow", "true");
                alert_confirm("APP调试开启","用于查看设查信息，了解业务执行流程，执行客户端开放功能等。\n应用于开发、测试、验证环境。\n生产环境屏蔽该功能。");
            else
                alertToast0("调试开启");
            end;
        end;

        if PageReload == "true" then
            lua_page.reload_page();
        end;
    end;
end;

--[[填充调试默认密码]]
function lua_debug.default_pwd()
    local res = "";
    if configTable["lua_debug"] == "true" then
        local AppEnvironment = vt("AppEnvironment",systemTable);
        if AppEnvironment~="" and AppEnvironment~="pro" then
            res = "Aa95527";
            debug_alertToast("密码填充");
        else
            res = "";
        end;
    end;
    return res;
end;

--[[切换后台环境]]
function lua_debug.change_env()
    if configTable["lua_debug"] == "true" then
        --菜单关闭函数
        local close_fun = "lua_system.close_app_alert_menu";

        local tableArg = {
            menu_info_list={
                {
                    title="开发环境",
                    tip="dev",
                    fun="lua_debug.env_switch",
                    arg="dev"
                },
                {
                    title="测试环境",
                    tip="sit",
                    fun="lua_debug.env_switch",
                    arg="sit"
                },
                {
                    title="验证环境",
                    tip="uat",
                    fun="lua_debug.env_switch",
                    arg="uat"
                }
            },
            cancel_menu_info={
                {
                    title="取消",
                    tip="",
                    fun=close_fun,
                    arg=""
                }
            },
            bg_click_fun=close_fun,
            bg_click_arg=""
        };

        local jsonArg = table2json(tableArg);
        --debug_alert(jsonArg);
        lua_system.app_alert_menu(jsonArg);
    end;
end;

--[[环境切换]]
function lua_debug.env_switch(env)
    lua_system.close_app_alert_menu();

    local AppEnvironment = vt("AppEnvironment",systemTable);
    if AppEnvironment ~= env then
        local reqParams = {
            env=env
        };
        lua_debug.do_env_switch("",reqParams);
    else
        alert("当前为"..AppEnvironment.."环境");
    end;
end;
function lua_debug.do_env_switch(resParams,reqParams)
    if configTable["lua_debug"] == "true" then
        if formatNull(resParams) == "" then
            local reqParams = formatNull(reqParams);
            reqParams["TranCode"] = "ChangeRunEnv";
            invoke_trancode_donot_checkRepeat(
                "jjbx_service",
                "app_service",
                reqParams,
                lua_debug.do_env_switch,
                {},
                all_callback,
                {CloseLoading="false"}
            );
        else
            local res = json2table(resParams["responseBody"]);
            --app运行环境
            systemTable["AppEnvironment"] = vt("Env",res);
            alert(res["ReMsg"]);
        end;
    end;
end;

--[[用于调试的系统弹窗，上线前关闭]]
function debug_alert(alertMsg)
    if configTable["lua_debug"]=="true" and systemTable["EnvAllowDebug"]=="true" then
        --加个空判断，避免弹窗报错
        local alertMsg = formatNull(alertMsg,"调试打印参数为空");
        alertMsg = "－－－－－调试信息－－－－－\n\n"..alertMsg;
        if platform == "iPhone OS" then
            ryt:ios_alert(alertMsg);
        else
            window:alert(alertMsg);
        end;
    end;
end;

--[[用于调试的Toast弹窗，上线前关闭]]
function debug_alertToast(alertMsg)
    --lua调试
    if configTable["lua_debug"] == "true" then
        if systemTable["EnvAllowDebug"] == "true" then
            --加个空判断，避免弹窗报错
            local alertMsg = formatNull(alertMsg,"无信息");
            if alertMsg ~= "" then
                ryt:showToast("0",alertMsg,"","","");
            end;
        end;
    end;
end;

--[[页面刷新（调试）]]
function lua_debug.reload_page()
    if configTable["lua_debug"] == "true" then
        lua_page.reload_page();
    end;
end;

--[[弹出调试菜单]]
function lua_debug.alert_menu(Arg)
    if systemTable["EnvAllowDebug"]=="true" and configTable["lua_debug"]=="true" then
        --菜单关闭函数
        local close_fun = "lua_system.close_app_alert_menu";
        local call_fun = "lua_debug.alert_menu_call";

        local debugTip = "开启调试";
        if configTable["lua_debug"] == "true" then
            debugTip = "关闭调试";
        end;

        local tableArg = {
            menu_info_list={
                {
                    title="返回首页",
                    tip="",
                    fun=call_fun,
                    arg="CallFun=lua_menu.to_index_page&CallArg=back"
                },
                {
                    title="业务首页",
                    tip="",
                    fun=call_fun,
                    arg="CallFun=back_fun&CallArg=2"
                },
                {
                    title="应用重启",
                    tip="更新最新离线资源",
                    fun=call_fun,
                    arg="CallFun=lua_system.call_client_timeout"
                },
                {
                    title="应用还原",
                    tip="删除应用数据",
                    fun=call_fun,
                    arg="CallFun=lua_system.confirm_clear_app_cache"
                },
                {
                    title="首页调试",
                    tip="首页任务序列调试",
                    fun=call_fun,
                    arg="CallFun=index_page_test"
                },
                {
                    title="功能演示",
                    tip="前往demo页面",
                    fun=call_fun,
                    arg="CallFun=lua_menu.to_demo_page"
                },
                {
                    title="切换环境",
                    tip="切换当前服务器直连的后台服务器",
                    fun=call_fun,
                    arg="CallFun=lua_debug.change_env"
                },
                {
                    title="注销登录",
                    tip="注销当前用户登录并退到登录界面",
                    fun=call_fun,
                    arg="CallFun=lua_login.exit_login_confirm"
                }
            },
            cancel_menu_info={
                {
                    title="应用关闭",
                    tip="",
                    fun=call_fun,
                    arg="CallFun=closeApp"
                }
            },
            bg_click_fun=close_fun,
            bg_click_arg=""
        };

        local jsonArg = table2json(tableArg);
        --debug_alert(jsonArg);
        lua_system.app_alert_menu(jsonArg);
    end;
end;

--[[点击调试菜单]]
function lua_debug.alert_menu_call(CallArg)
    lua_system.close_app_alert_menu();
    local CallArgTable = string_to_table(CallArg);
    local DoCallFun = vt("CallFun",CallArgTable);
    local DoCallArg = vt("CallArg",CallArgTable);
    lua_system.do_function(DoCallFun,DoCallArg);
end;

--[[链接缓存]]
function lua_debug.app_debug(ResParams,ReqParams)
    if systemTable["EnvAllowDebug"] == "true" then
        if formatNull(ResParams) == "" then
            local ReqParams = formatNull(ReqParams);
            --请求接口
            ReqParams["TranCode"] = "AppDebug";
            invoke_trancode_noloading(
                "jjbx_service",
                "app_service",
                ReqParams,
                lua_debug.app_debug,
                {}
            );
        else
            --debug_alert("调试响应");
        end;
    end;
end;
