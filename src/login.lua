--[[极简报销登录相关函数]]

lua_login = {};

--[[发起登录]]
function lua_login.do_login(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        --debug_alert("登录请求");

        local ReqParams = formatNull(ReqParams);
        --登录的erl接口
        ReqParams["TranCode"] = "login";
        --获取已经存储的设备信息
        local phoneInfo = vt("phoneInfo",systemTable);

        --接口参数
        --设备唯一ID，例：UDID，Mac地址，IMEI，IMSI等，用于绑定设备
        ReqParams["deviceId"] = vt("deviceId",phoneInfo);
        --设备操作系统
        ReqParams["deviceType"] = vt("deviceType",phoneInfo);
        --设备操作系统版本
        ReqParams["osVersion"] = vt("osVersion",phoneInfo);
        --设备类型
        ReqParams["phoneType"] = vt("phoneType",phoneInfo);
        --应用版本
        ReqParams["appVersion"] = vt("appVersion",phoneInfo);

        --系统参数
        --屏幕宽度
        ReqParams["screenWidth"] = vt("screenWidth",phoneInfo);
        --屏幕高度
        ReqParams["screenHeight"] = vt("screenHeight",phoneInfo);

        --设备名称（实时获取）
        local deviceName = lua_system.get_device_name();
        --设备名称编码
        local deviceNameEncode = lua_format.arg_encode(deviceName);
        --设备名称上送
        local deviceNameUse = "";
        if ryt:getLengthByStr(deviceNameEncode) <= 50 then
            deviceNameUse = deviceNameEncode;
        end;
        ReqParams["deviceName"] = deviceNameUse;

        --debug_alert("发起登录\n"..foreach_arg2print(ReqParams));

        --发送登录请求后回调调用处传递的回调方法
        invoke_trancode_donot_checkRepeat(
            "jjbx_login",
            "entrance",
            ReqParams,
            lua_login.do_login,
            {},
            pagecallback,
            {CloseLoading="false"}
        );
    else
        --debug_alert("登录响应");

        local res = json2table(ResParams["responseBody"]);
        local errorNo = vt("errorNo",res);
        local errorMsg = vt("errorMsg",res);
        if errorNo == "000000" then
            --获取系统日期
            systemTable["systemDateTime"] = res["systemDateTime"];

            --保存登录数据
            local SaveLoginRes = lua_login.save_login(res);

            --客户端将用户进行推送注册
            push_register(vt("PkUser",res));

            --用户是否首次登陆（后台返回）
            local fistLogin = vt("FistLogin",res);
            --调试首次登录
            --fistLogin = "1";

            --用户是否已经设置完首次登陆（前端记录）
            local SetFirstLogin = vt("SetFirstLogin",globalTable);

            --是否检查设备登录保护（系统业务配置）
            local LoginDeviceProtect = vt("LoginDeviceProtect",configTable);

            --设备登录保护状态（查询返回）
            local checkDeviceFlag = vt("CheckDeviceFlag",res);

            --涉嫌电信诈骗提示
            globalTable["UserRiskCheckMsg"] = vt("UserRiskCheckMsg",res);

            --登录方式 1密码 2手机号 3免密(一小时) 4快捷(1手势2指纹3刷脸)
            local LoginType = vt("LoginType",res);

            --[[debug_alert(
                "是否检查登录保护 : "..LoginDeviceProtect.."\n"..
                "设备登录保护状态 : "..checkDeviceFlag.."\n"..
                "·0 开启，当前为常用设备登录\n"..
                "·1 关闭\n"..
                "·2 开启，当前为非常用设备登录\n"..
                "\n"..
                "用户是否首次登陆（后台返回） : "..fistLogin.."\n"..
                "用户是否已经设置完首次登陆（前端记录） : "..SetFirstLogin.."\n"..
                ""
            );]]

            if fistLogin == "1" then
                --首次登陆的用户没有单据评价权限
                globalTable["userAppraise"] = "false";

                if SetFirstLogin == "" then
                    --保存当前登录返回数据
                    globalTable["DoLoginResParams"] = ResParams;
                    --是否是超级管理员
                    local KeyUserSet = vt("KeyUserSet",res);
                    --用户首次登陆，需完善信息
                    invoke_page("jjbx_login/xhtml/jjbx_fristLogin_set_password.xhtml",page_callback,{KeyUserSet=KeyUserSet});
                else
                    --状态还原
                    globalTable["SetFirstLogin"] = "";
                    --跳转至首页（前进）
                    lua_menu.to_index_page("go");
                end;
            else
                --非首次登陆的用户才有单据评价权限
                globalTable["userAppraise"] = "true";

                --检查登录设备保护
                if LoginDeviceProtect == "true" then
                    if checkDeviceFlag == "2" then
                        --2 登录保护开启，当前为非常用设备登录

                        --绑定设备
                        lua_login.device_bind("",{LoginType=LoginType});
                    elseif checkDeviceFlag == "" then
                        --没有获取到登录保护状态

                        --检查设备保护异常处理
                        lua_login.device_protect_error();
                    else
                        --正常流程

                        --跳转至首页（前进）
                        lua_menu.to_index_page("go");
                    end;
                else
                    --跳转至首页（前进）
                    lua_menu.to_index_page("go");
                end;
            end;
            --发送注册推送时获取的token
            lua_system.msgMarsRegister("",{});
        else
            --登录会话ID删除
            del_db_value("loginSessionid");

            --报错
            jjbx_show_business_err(errorNo,errorMsg);

            local ClientRegisterMissionArg = get_db_value("ClientRegisterMissionArg");
            local missionArg = lua_format.url_decode(ClientRegisterMissionArg);
            local ArgObj = json2table(missionArg);
            local MissionType = vt("MissionType",ArgObj);

            if MissionType=="ToBudgetPageOpenByOtherApp" or vt("LoginType",res)=="5" then
                --debug_alert("第三方登录极简报销系统失败，错误信息："..errorMsg);
                --通用日志记录注册
                local CommonLogRegisterArg = {
                    LogExplain="第三方登录极简报销系统失败，错误信息："..errorMsg,
                    LogInfo=ClientRegisterMissionArg
                };
                lua_jjbx.common_log_register("",CommonLogRegisterArg);

                --第三方APP免密登录失败
                lua_mission.clear_app_register_mission({ClearMsg="第三方APP免密登录失败"});
                local CurrentPageInfo = lua_page.current_page_info();
                local PageFilePath = vt("page_file_path",CurrentPageInfo);
                if PageFilePath ~= "jjbx_login/xhtml/jjbx_login.xhtml" then
                    lua_login.login_type_router("account_login");
                end;
            else
                if isNoPasswordLogin == "true" then
                    --免密登录状态下，先重置免密登录状态
                    isNoPasswordLogin = "false";
                    local token = get_db_value("token");
                    lua_login.qry_login_type("",{token=token});
                end;
            end;
        end;
    end;
end;

--[[设备绑定]]
function lua_login.device_bind(ResParams,ReqParams)
    --debug_alert("lua_login.device_bind");

    if formatNull(ResParams) == "" then
        --请求

        local ReqParams = formatNull(ReqParams);
        ReqParams["TranCode"] = "GetBindDeviceList";
        invoke_trancode(
            "jjbx_myInfo",
            "securityCenter",
            ReqParams,
            lua_login.device_bind,
            {},
            all_callback,
            {CloseLoading="false"}
        );
    else
        --响应

        local res = json2table(ResParams["responseBody"]);
        local errorNo = vt("errorNo",res);
        local errorMsg = vt("errorMsg",res);
        if res["errorNo"] == "000000" then
            local deviceListData = vt("identificationDeviceList",res);
            --记录当前绑定的设备个数
            local CurrentLoginDeviceCounts = #deviceListData;
            globalTable["CurrentLoginDeviceCounts"] = CurrentLoginDeviceCounts;
            --登录方式
            local ReqLoginType = vt("ReqLoginType",res);
            if ReqLoginType == "2" then
                --debug_alert("手机号登录");
                if CurrentLoginDeviceCounts >= C_Bind_Device_Max_Counts then
                    alert_confirm("温馨提示", "您已开启登录保护，最多可绑定5个设备，当前已绑定5个设备，不允许继续绑定", "", "确定", "lua_menu.to_index_page");
                else
                    alert_confirm("温馨提示", "您已开启登录保护，是否绑定该手机作为您的常用设备", "不绑定", "绑定", "lua_login.bind_device_confirm");
                end;
            else
                invoke_page("jjbx_login/xhtml/device_bind.xhtml",page_callback,{CloseLoading="false"});
            end;
        else
            --检查设备保护异常处理
            lua_login.device_protect_error(errorMsg);
        end;
    end;
end;

--[[检查设备保护异常处理]]
function lua_login.device_protect_error(ErrorMsg)
    local ErrorMsg = formatNull(ErrorMsg,"登录保护状态异常");
    ErrorMsg = ErrorMsg.."，请重新登录";

    alert_confirm("温馨提示", ErrorMsg, "", "确定", "alert_confirm_call", "CallFun=lua_login.exit_login");
end;

--[[绑定设备确认]]
function lua_login.bind_device_confirm(click)
    if tostring(click) == "1" then
        --执行绑定设备
        lua_login.do_bind_device();
    else
        --跳转至首页（前进）
        lua_menu.to_index_page("go");
    end;
end;

--[[执行删除设备]]
function lua_login.do_bind_device(ResParams)
    if formatNull(ResParams) == "" then
        --请求
        invoke_trancode(
            "jjbx_login",
            "entrance",
            {
                TranCode="BindDeviceByToken",
                identificationDevice="1",
                token=get_db_value("token")
            },
            lua_login.do_bind_device,
            {},
            all_callback,
            {CloseLoading="false"}
        );
    else
        --响应
        local res = json2table(ResParams["responseBody"]);
        local errorNo = vt("errorNo",res);
        local errorMsg = vt("errorMsg",res);
        if errorNo ~= "000000" then
            alert(errorMsg);
        end;

        --跳转至首页（前进）
        lua_menu.to_index_page("go");
    end;
end;

--[[保存登录数据]]
function lua_login.save_login(loginRes)
    --debug_alert("保存登录数据\n"..foreach_arg2print(loginRes));

    --存储/更新登陆标识
    --设备唯一ID，例：UDID，Mac地址，IMEI，IMSI等
    local phoneInfo = vt("phoneInfo",systemTable);
    local deviceID = vt("deviceId",phoneInfo);

    --登录会话
    local loginSessionid = vt("loginSessionid",loginRes);
    --登录标识
    local token = loginSessionid.."/"..deviceID;
    --用户名存储
    local userName = vt("UserName",loginRes);
    set_db_value("userName", userName);
    globalTable["userName"] = userName;
    globalTable["name"] = userName;
    --用户姓名
    local psnName = vt("psnname", loginRes);
    globalTable["psnName"] = psnName;

    --工号存储
    local workid = vt("WorkId",loginRes);
    set_db_value("workid", workid);
    globalTable["workid"] = workid;
    --机构存储
    local orgFlag = vt("OrgFlag",loginRes);
    globalTable["orgFlag"] = orgFlag;

    --服务器菜单版本
    local ServerMenuVersion = vt("ServerMenuVersion",loginRes);

    --存储登录标识
    set_db_value("token", token);
    --存储登陆会话
    set_db_value("loginSessionid", loginSessionid);
    globalTable["loginSessionid"] = loginSessionid;
    --存储当前服务器配置的菜单版本号
    set_db_value("ServerMenuVersion", ServerMenuVersion);

    --配置的菜单信息
    globalTable["menuList"] = vt("menuList",loginRes);
    --app运行环境
    systemTable["AppEnvironment"] = vt("AppEnvironment",loginRes);

    --是否需要提示参与先款后审
    globalTable["ShowCreditExplainFlag"] = vt("ShowCreditExplainFlag",loginRes,"false");
    --提示参与先款后审的链接
    globalTable["CreditExplainUrl"] = vt("CreditExplainUrl",loginRes);

    --手机号存储
    globalTable["phone"] = vt("Mobile",loginRes);
    --用户类型存储
    globalTable["userType"] = vt("UserType",loginRes);
    --共享人用户场景存储
    globalTable["sharePeopleScene"] = vt("SharePeopleScene",loginRes);

    --保存登录机构等相关信息
    local defaultCorp = vt("defaultCorp",loginRes);
    globalTable["defaultCorp"] = defaultCorp;

    --保存当前登录机构等相关信息
    globalTable["selectOrgList"] = {
        {
            --存储机构名称
            unitname=vt("unitshotname",loginRes),
            --存储机构编码
            unitcode=vt("unitcode",loginRes),
            --存储默认机构
            pkCorp=globalTable["defaultCorp"]
        }
    };
    --debug_alert(foreach_arg2print(globalTable["selectOrgList"]));

    --保存用户所在公司
    globalTable["PeopleCompanyName"] = vt("corpname",loginRes);

    --保存用户主键
    globalTable["PkUser"] = vt("PkUser",loginRes);

    --保存PC配置参数列表
    globalTable["PCConfigListsTable"] = json2table(vt("PCConfigListsJson",loginRes));

    --保存帮助类型参数
    globalTable["AskPermissionTreeData"] = vt("AskPermissionTreeData",loginRes);

    --保存用户功能权限列表
    companyTable["viewauthority"] = vt("Viewauthority",loginRes);

    --保存用户第三方服务信息
    companyTable["thirdPartyServiceStatus"] = json2table(vt("ThirdPartyServiceStatus",loginRes));

    --保存登录用户列表
    if configTable["lua_debug"] == "true" then
        lua_login.save_login_user_list(loginRes);
    end;

    return "true";
end;

--[[保存登录用户列表]]
function lua_login.save_login_user_list(Arg)
    --用户名
    local userName = vt("UserName",Arg);
    --工号
    local workid = vt("WorkId",Arg);
    --登录名称
    local loginAcc = vt("LoginAcc",Arg);
    --用户类型
    local userType = vt("UserType",Arg);

    local LoginUserListJson = get_db_value("LoginUserListJson");
    local LoginUserListTable = {};
    if LoginUserListJson ~= "" then
        LoginUserListTable = json2table(LoginUserListJson);
    end;
    local LoginUserListCounts = #LoginUserListTable;

    local MatchRes = "false";
    for i=1, LoginUserListCounts do
        local UserInfo = LoginUserListTable[i];
        local SaveLoginAcc = vt("loginAcc",UserInfo);
        if SaveLoginAcc == loginAcc then
            --debug_alert("已匹配");
            MatchRes = "true";
            --删除已保存
            table.remove(LoginUserListTable,i);
            break
        end;
    end;

    local AddUser = {
        userName=userName,
        workid=workid,
        loginAcc=loginAcc,
        userType=userType
    };

    --添加新用户
    table.insert(LoginUserListTable,AddUser);

    --[[debug_alert(
        "保存登录用户列表\n"..
        "已保存的 : "..foreach_arg2print(LoginUserListTable).."\n"..
        ""
    );]]

    set_db_value("LoginUserListJson",table2json(LoginUserListTable));
end;

--[[第三方APP登录前置准备]]
function lua_login.login_by_otherapp_prepare(LoginArg)
    local LoginArg = formatNull(LoginArg);
    local LoginArgDecode = lua_format.base64_decode(LoginArg);
    local LoginArgTable = json2table(LoginArgDecode);
    --debug_alert("第三方APP登录前置准备"..foreach_arg2print(LoginArgTable));

    --登录token
    local JJBXAppLoginToken = vt("Token",LoginArgTable);
    --是否重新登录
    local Relogin = vt("Relogin",LoginArgTable);
    if Relogin == "true" then
        --debug_alert("调用注销");
        local ReqParams = {
            BusinessCall="lua_login.token_login_by_otherapp",
            BusinessArg=LoginArg,
            ForceExit="true"
        };
        lua_login.exit_login("",ReqParams);
    else
        --debug_alert("调用登录"..LoginArg);
        lua_login.token_login_by_otherapp(LoginArg)
    end;
end;

--[[第三方APP进行认证后，通过token登录极简报销]]
function lua_login.token_login_by_otherapp(LoginArg)
    local LoginArg = formatNull(LoginArg);
    local LoginArgDecode = lua_format.base64_decode(LoginArg);
    local LoginArgTable = json2table(LoginArgDecode);
    debug_alert(
        "第三方APP进行认证后，通过token登录极简报销"..foreach_arg2print(LoginArgTable).."\n"..
        "LoginArgDecode : "..LoginArgDecode.."\n"..
        ""
    );
    local LoadLoginArg = {
        JJBXAppLoginToken=vt("JJBXAppLoginToken",LoginArgTable)
    };
    lua_login.load_login(LoadLoginArg);
end;

--[[加载登陆]]
function lua_login.load_login(LoadLoginArg)
    local LoadLoginArg = formatNull(LoadLoginArg);

    --已保存的登录名
    local SaveUserName = get_db_value("jjbx_acc");
    --已保存的登录手机号
    local SavePhoneNo = get_db_value("phoneNo");

    --加载登录类型 1:登录页面手动登录 2:本系统token免密登录(1小时有效) 3:通过用户信息查询登录方式 4:第三方认证Token直接登录
    local LoadLoginStyle = "1";
    --获取传递的Token（第三方传递）
    local JJBXAppLoginToken = vt("JJBXAppLoginToken",LoadLoginArg);
    --获取系统存储的token（本系统产生）
    local token = get_db_value("token");

    if JJBXAppLoginToken ~= "" then
        LoadLoginStyle = "4";
    else
        --没有保存登录名或登录手机号
        if SaveUserName == "" and SavePhoneNo == "" then
            LoadLoginStyle = "1";
        else
            if token == "" then
                LoadLoginStyle = "1";
            else
                --确认是否走免密登录
                --登录成功sessionid,  登录失败时, 退出时,免密登录标识置空
                local loginSessionid = get_db_value("loginSessionid");
                local needUpdate = vt("NeedUpdate",globalTable);
                --[[debug_alert(
                    "lua_login.load_login\n"..
                    "needUpdate : "..needUpdate.."\n"..
                    "token : "..token.."\n"..
                    "loginSessionid : "..loginSessionid.."\n"..
                    ""
                );]]
                if loginSessionid=="" or needUpdate~="" or C_NoPwdLogin=="false" then
                    --登录失败或用户手动退出登录都会清空loginSessionID,查询用户设置过的登陆类型，跳转至相应的登陆页面
                    --有更新的情况下不发起自动登录
                    --免密登录配置为关闭的情况下不发起自动登录
                    LoadLoginStyle = "3";
                else
                    --token、loginSessionID同时存在时，说明已经登陆过且登陆状态未失效，直接发送登陆请求，用户无需再手动登陆
                    LoadLoginStyle = "2";
                end;
            end;
        end;
    end;

    --[[debug_alert(
        "加载登陆\n"..
        "SaveUserName: "..SaveUserName.."\n"..
        "SavePhoneNo: "..SavePhoneNo.."\n"..
        "JJBXAppLoginToken: "..JJBXAppLoginToken.."\n"..
        "token: "..token.."\n"..
        "LoadLoginStyle : "..LoadLoginStyle.."\n"..
        ""
    );]]

    if LoadLoginStyle == "1" then
        --登录页面手动登录
        lua_menu.to_login_page();
    elseif LoadLoginStyle == "2" then
        --本系统token免密登录(1小时有效)
        isNoPasswordLogin = "true";
        --发起登录
        local loginReqParams = {
            token=token,
            loginType="3"
        };
        lua_login.do_login("",loginReqParams);
    elseif LoadLoginStyle == "3" then
        --通过用户信息查询登录方式
        lua_login.qry_login_type("",{token=token});
    elseif LoadLoginStyle == "4" then
        --第三方认证Token直接登录
        --发起登录
        local loginReqParams = {
            token=JJBXAppLoginToken,
            loginType="5"
        };
        lua_login.do_login("",loginReqParams);
    else
        --登录页面手动登录
        lua_menu.to_login_page();
    end;
end;

--[[账号密码登录页面]]
function to_acc_login_page()
    jjbx_to_login_page("0");
end;

--[[手机号登录页面]]
function to_mobile_login_page()
    jjbx_to_login_page("mobile_login");
end;

--[[根据缓存的快捷登录方式跳转到对应登录页面]]
function to_other_login_page()
    jjbx_to_login_page(globalTable["loginType"]);
end;

--[[
    登录页面配置
    logintype：0密码登录 1手势登录 2指纹 3刷脸
]]
function jjbx_to_login_page(logintype)
    --默认账号密码页面
    local logintype = formatNull(logintype, "0");

    --获取登录页面
    local PageUrl = login_page(logintype);

    --账号密码登录页面-左侧滑出
    local UseJumpStyle = "";
    if logintype == "0" then
        UseJumpStyle = "left";
    end;

    history:clear();
    invoke_page_noloading_checkRepeat(PageUrl, page_callback, {JumpStyle=UseJumpStyle, AddPage="true"});
end;

--[[提示注销登录]]
function lua_login.exit_login_confirm()
    alert_confirm("温馨提示","您确定要安全退出登录吗？","取消","确定","alert_confirm_call","CallFun=lua_login.exit_login");
end;

--[[注销登录]]
function lua_login.exit_login(ResParams,ReqParams)
    --注销请求处理
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams);
        local BusinessCall = vt("BusinessCall",ReqParams);
        local BusinessArg = vt("BusinessArg",ReqParams);
        local ForceExit = vt("ForceExit",ReqParams);
        --debug_alert("注销请求处理-请求"..foreach_arg2print(ReqParams));

        local token = get_db_value("token");

        invoke_trancode_noloading(
            "jjbx_login",
            "entrance",
            {
                TranCode="exitLogin",
                token=token
            },
            lua_login.exit_login,
            {
                BusinessCall=BusinessCall,
                BusinessArg=BusinessArg,
                ForceExit=ForceExit
            }
        );
    --注销响应处理
    else
        --登录会话ID删除
        del_db_value("loginSessionid");
        --重置免密登录状态
        isNoPasswordLogin = "false";

        --清空用户缓存数据
        globalTable = {};
        --清空机构缓存数据
        companyTable = {};

        --退出登录后，不自动发起登录
        globalTable["AutoQuickLogin"] = "false";

        --退出登录时清空栈值
        history:clear();

        --首页任务重置
        lua_mission.index_set("ready");

        local responseBody = json2table(ResParams["responseBody"]);

        --0-密码登录 1-手势登录 2-指纹 3-刷脸
        --这里后台返回的字段为logonType，注意勿混淆
        local loginType = formatNull(responseBody["logonType"]);
        globalTable["loginType"] = loginType;

        --[[debug_alert(
            "注销响应处理\n"..
            "exit login query type : "..loginType.."\n"..
            "exit login set type : "..globalTable["loginType"].."\n"..
            "exit login auto quick login : "..globalTable["AutoQuickLogin"].."\n"..
            ""
        );]]

        --获取登录页面并跳转
        local PageUrl = login_page(loginType);
        invoke_page_noloading_checkRepeat(PageUrl,page_callback,{JumpStyle="none"});

        --指定业务回调
        local BusinessCall = vt("BusinessCall",ResParams);
        local BusinessArg = vt("BusinessArg",ResParams);
        if BusinessCall ~= "" then
            debug_alert(
                "注销后调用回调\n"..
                "BusinessCall : "..BusinessCall.."\n"..
                "BusinessArg : "..BusinessArg.."\n"..
                ""
            );
            lua_system.do_function(BusinessCall,BusinessArg);
        end;
    end;
end;

--[[根据查询到的登录方式跳转登录页面]]
function lua_login.qry_login_type(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams);
        ReqParams["TranCode"] = "getLoginType";
        invoke_trancode_donot_checkRepeat(
            "jjbx_login",
            "entrance",
            ReqParams,
            lua_login.qry_login_type,
            {},
            all_callback,
            {CloseLoading="false"}
        );
    else
        close_loading();

        local res = json2table(ResParams["responseBody"]);
        local errorNo = vt("errorNo",res);
        local errorMsg = vt("errorMsg",res);
        if errorNo ~= "000000" then
            --报错
            alert(errorMsg);
            --登录会话ID删除
            del_db_value("loginSessionid");
            --重置免密登录状态
            isNoPasswordLogin = "false";
        end;

        --0-密码 1-手势 2-指纹 3-刷脸
        --这里后台返回的字段为logonType，注意勿混淆，缺省为密码登录
        local loginType = vt("logonType",res,"0");
        globalTable["loginType"] = loginType;

        --获取登录页面
        local PageUrl = login_page(loginType);
        invoke_page_noloading_checkRepeat(PageUrl,page_callback,{JumpStyle="none"});
    end;
end;

--[[判断是否调用快捷登录]]
function auto_quick_login_status()
    local res = "";
    local AutoQuickLogin = formatNull(globalTable["AutoQuickLogin"],"true");
    local NeedUpdate = formatNull(globalTable["NeedUpdate"]);
    --不发起自动快捷登录的场景: 退出登录、需要更新、用户自行取消快捷登录
    if AutoQuickLogin=="true" and NeedUpdate=="" then
        res = "true";
    else
        res = "false";
    end;

    --[[debug_alert(
        "auto_quick_login_status\n"..
        "AutoQuickLogin : "..AutoQuickLogin.."\n"..
        "NeedUpdate : "..NeedUpdate.."\n"..
        "Res : "..res.."\n"..
        ""
    );]]

    return res;
end;

--[[是否阅读隐私政策]]
function lua_login.read_agreement_ctrl()
    if globalTable["ReadLoginAgreementFlag"] == "false" then
        globalTable["ReadLoginAgreementFlag"] = "true";
        changeProperty("agreement_ctrl_icon","src","local:selected_round.png");
    else
        globalTable["ReadLoginAgreementFlag"] = "false";
        changeProperty("agreement_ctrl_icon","src","local:select.png");
    end;
end;

--[[登录方式路由]]
function lua_login.login_type_router(LoginType)
    --关闭菜单
    lua_system.close_app_alert_menu();

    --获取当前登录类型
    local LastLoginType = vt("LastLoginType",globalTable);

    local PageUrl = "";

    if LoginType == "account_login" then
        --账号登录
        PageUrl = "jjbx_login/xhtml/jjbx_login.xhtml";
    elseif LoginType == "mobile_login" then
        --手机号登录
        PageUrl = "jjbx_login/xhtml/jjbx_mobileLogin.xhtml";
    elseif LoginType == "FaceID_login" then
        --人脸登录
        PageUrl = "jjbx_login/xhtml/jjbx_faceIDLogin.xhtml";
    elseif LoginType == "TouchID_login" then
        --指纹登录
        PageUrl = "jjbx_login/xhtml/jjbx_touchIDLogin.xhtml";
    elseif LoginType == "gesture_login" then
        --手势登录
        PageUrl = "jjbx_login/xhtml/jjbx_gestureLogin.xhtml";
    elseif LoginType == "change_user" then
        globalTable["ChangeUserFlag"] = "true";
        if LastLoginType == "account_login" then
            PageUrl = "jjbx_login/xhtml/jjbx_login.xhtml";
        elseif LastLoginType == "mobile_login" then
            PageUrl = "jjbx_login/xhtml/jjbx_mobileLogin.xhtml";
        else
            PageUrl = "jjbx_login/xhtml/jjbx_login.xhtml";
        end;
    else
        debug_alert("未定义");
    end;

    --[[debug_alert(
        "登录方式路由\n"..
        "LoginType : "..LoginType.."\n"..
        "PageUrl : "..PageUrl.."\n"..
        "LastLoginType : "..LastLoginType.."\n"..
        "ChangeUserFlag : "..vt("ChangeUserFlag",globalTable).."\n"..
        ""
    );]]

    if PageUrl ~= "" then
        history:clear();
        invoke_page_noloading_checkRepeat(PageUrl, page_callback, {JumpStyle="right", AddPage="true"});
    end;
end;

--[[加载登录方式]]
function lua_login.init_login_type(LastLoginType)
    local LastLoginType = formatNull(LastLoginType);
    --存储当前登录类型
    globalTable["LastLoginType"] = LastLoginType;

    --查询的登录方式 0密码登录 1手势登录 2指纹 3刷脸
    local QryLoginType = vt("loginType",globalTable);

    --是否切换用户
    local ChangeUserFlag = vt("ChangeUserFlag",globalTable);

    --[[debug_alert(
        "加载登录方式\n"..
        "登记登录方式 : "..QryLoginType.."\n"..
        "当前登录类型 : "..LastLoginType.."\n"..
        "是否切换用户 : "..ChangeUserFlag.."\n"..
        ""
    );]]

    --菜单路由函数
    local router_fun = "lua_login.login_type_router";
    --菜单关闭函数
    local close_fun = "lua_system.close_app_alert_menu";

    local account_login_menu = {
        title="账号密码登录",
        tip="",
        fun=router_fun,
        arg="account_login"
    };

    local mobile_login_menu = {
        title="手机号登录",
        tip="",
        fun=router_fun,
        arg="mobile_login"
    };

    local FaceID_login_menu = {
        title="人脸登录",
        tip="",
        fun=router_fun,
        arg="FaceID_login"
    };

    local TouchID_login_menu = {
        title="指纹登录",
        tip="",
        fun=router_fun,
        arg="TouchID_login"
    };

    local gesture_login_menu = {
        title="手势密码登录",
        tip="",
        fun=router_fun,
        arg="gesture_login"
    };

    local change_user_menu = {
        title="切换用户",
        tip="",
        fun=router_fun,
        arg="change_user"
    };

    local menu_info_list = {};

    if ChangeUserFlag == "true" then
        globalTable["ChangeUserFlag"] = "true";
        --切换用户只提供账号登录和手机号登录
        if LastLoginType == "account_login" then
            table.insert(menu_info_list,mobile_login_menu);
        elseif LastLoginType == "mobile_login" then
            table.insert(menu_info_list,account_login_menu);
        end;
    else
        globalTable["ChangeUserFlag"] = "false";
        --账号、手机号、手势登录所有机型均支持，直接添加
        if LastLoginType ~= "account_login" then
            --不重复添加当前页面的类型
            table.insert(menu_info_list,account_login_menu);
        end;
        if LastLoginType ~= "mobile_login" then
            --不重复添加当前页面的类型
            table.insert(menu_info_list,mobile_login_menu);
        end;
        if LastLoginType ~= "gesture_login" then
            --不重复添加当前页面的类型
            if QryLoginType == "1" then
                --后台返回该用户开通了手势登录则添加
                table.insert(menu_info_list,gesture_login_menu);
            end;
        end;
        if LastLoginType ~= "TouchID_login" then
            --不重复添加当前页面的类型
            if systemTable["SupportLoginType"] == "TouchID" then
                --指纹登录需要判断机型
                if QryLoginType == "2" then
                    --后台返回该用户开通了指纹登录则添加
                    table.insert(menu_info_list,TouchID_login_menu);
                end;
            end;
        end;
        if LastLoginType ~= "FaceID_login" then
            --不重复添加当前页面的类型
            if systemTable["SupportLoginType"] == "FaceID" then
                --人脸登录需要判断机型
                if QryLoginType == "3" then
                    --后台返回该用户开通了人脸登录则添加
                    table.insert(menu_info_list,FaceID_login_menu);
                end;
            end;
        end;
        if QryLoginType ~= "" then
            --后台返回该用户登录渠道后添加切换用户菜单，新装客户端不添加该菜单
            table.insert(menu_info_list,change_user_menu);
        end;
    end;

    --菜单参数
    local tableArg = {
        menu_info_list=menu_info_list,
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
    lua_system.app_alert_menu(jsonArg);
end;

--[[取消切换用户]]
function lua_login.cancel_change_user()
    globalTable["ChangeUserFlag"] = "false";
    local LastLoginType = vt("LastLoginType",globalTable);

    --[[debug_alert(
        "取消切换用户\n"..
        "上一次登录方式 : "..LastLoginType.."\n"..
        ""
    );]]

    lua_login.login_type_router(LastLoginType);
end;
