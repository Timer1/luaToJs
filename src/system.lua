--[[系统相关]]

lua_system = {};

--安卓指纹校验错误次数
FingerprintCheckCount = 5;

--[[初始化系统]]
function lua_system.init_system()
    --系统定时器启动
    lua_system.start_timer();

    --通知客户端加载一次配置
    if systemTable["LoadAppConfigRes"] ~= "true" then
        lua_system.load_app_config();
    end;

    --初始化极简报销
    lua_jjbx.init();
end;

--[[获取手机型号]]
function getInfoPlatForm()
    local platform = system:getInfo("platform");
    if platform == "iPhone OS" or platform == "iOS" then
        return "iPhone OS";
    else
        return "Android";
    end;
end;

--[[判断是不是iPhoneX以上设备，支持人脸且需要适配“刘海屏”]]
function lua_system.is_iPhoneX()
    local platform = getInfoPlatForm();
    local res = "true";
    if platform =="iPhone OS" then
        local PhoneType = get_phone_type();
        if     PhoneType == "iPhone X" then
        elseif PhoneType == "iPhone XS" then
        elseif PhoneType == "iPhone XS Max" then
        elseif PhoneType == "iPhone XR" then
        elseif PhoneType == "iPhone 11" then
        elseif PhoneType == "iPhone 11 Pro" then
        elseif PhoneType == "iPhone 11 Pro Max" then
        elseif PhoneType == "iPhone 12" then
        elseif PhoneType == "iPhone 12 mini" then
        elseif PhoneType == "iPhone 12 Pro" then
        elseif PhoneType == "iPhone 12 Pro Max" then
        else
            if systemTable["phoneInfo"].screenStyle == "full" then
                --未配置的机型，判断是否为全面屏
            else
                res = "false";
            end;
        end;
    else
        res = "false";
    end;

    return res;
end;

--[[获取手机类型]]
function get_phone_type()
    local platform = getInfoPlatForm();
    local PhoneType = "";
    if platform =="iPhone OS" then
        PhoneType = formatNull(ryt:getIPhoneType());
    else
        PhoneType = formatNull(system:getInfo("model"));
    end;
    return PhoneType;
end;

--[[系统定时器启动]]
function lua_system.start_timer(Arg)
    local TimerSwith = vt("TimerSwith",appTable);
    if TimerSwith == "OPEN" then
        --debug_alert("定时器已启动");
    else
        --debug_alert("定时器启动");

        if platform == "iPhone OS" then
            appTable["SystemTimer"] = timer:startTimer(1,1,lua_system.system_timer_call);
        else
            --Android自定义定时器
            appTable["SystemTimer"] = mtimer:startTimer(1,1,"lua_system.system_timer_call");
        end;
    end;

    --记录启动状态
    appTable["TimerSwith"] = "OPEN";
end;

--[[系统定时器关闭]]
function lua_system.stop_timer()
    local TimerSwith = vt("TimerSwith",appTable);
    if TimerSwith == "OPEN" then
        --debug_alert("系统定时器关闭");

        if platform == "iPhone OS" then
            timer:stopTimer(appTable["SystemTimer"]);
        else
            --Android自定义定时器
            mtimer:stopTimer(1);
        end;
    else
        --debug_alert("系统定时器已关闭");
    end;

    --记录关闭状态
    appTable["TimerSwith"] = "CLOSE";
end;

--[[定时器回调注册]]
function lua_system.timer_register(Arg)
    local SystemTimerMission = vt("SystemTimerMission",globalTable);
    if SystemTimerMission == "" then
        globalTable["SystemTimerMission"] = {};
    end;

    --任务ID
    local MissionID = vt("ID",Arg);
    --是否唤起定时器
    local DoStartTimer = vt("DoStartTimer",Arg,"false");
    if DoStartTimer == "true" then
        --系统定时器启动
        lua_system.start_timer();
    end;

    --追加参数
    local AddMission = {
        --任务名称
        Name = vt("Name",Arg),
        --任务页面
        PageUrl = vt("PageUrl",Arg),
        --回调方法
        CallFunc = vt("CallFunc",Arg),
        --回调参数
        CallArg = vt("CallArg",Arg)
    };
    --ID为键存储任务
    globalTable["SystemTimerMission"][MissionID] = AddMission;
end;

--[[定时器回调注销]]
function lua_system.timer_unregister()
    globalTable["SystemTimerMission"] = "";
end;

--[[系统定时器回调]]
function lua_system.system_timer_call()
    local SystemTimerMission = vt("SystemTimerMission",globalTable);
    --debug_alert("系统定时回调"..foreach_arg2print(SystemTimerMission));

    if SystemTimerMission~="" and type(SystemTimerMission)=="table" then
        --debug_alert("遍历任务并检查是否执行");

        --获取当前页面地址
        local CurrentPageInfo = lua_page.current_page_info();
        local PageFilePath = vt("page_file_path",CurrentPageInfo);

        for MissionID,Data in pairs(SystemTimerMission) do
            --任务名称
            local Name = vt("Name",Data);
            --任务页面
            local PageUrl = vt("PageUrl",Data);
            --回调方法
            local CallFunc = vt("CallFunc",Data);
            --回调参数
            local CallArg = vt("CallArg",Data);
            --定时器回调参数
            local TimerCallArg = {
                --时间戳
                TimeStamp=os.time(),
                --业务参数
                BusinessArg=CallArg
            };

            if PageUrl == PageFilePath then
                --[[debug_alert(
                    "执行任务\n"..
                    "ID : "..MissionID.."\n"..
                    "名称 : "..Name.."\n"..
                    ""
                );]]
                lua_system.do_function(CallFunc,TimerCallArg);
            else
                --debug_alert("当前不在任务页面");
            end;
        end;
    else
        --debug_alert("没有注册任务");
    end;
end;

--获取安卓设备是否支持指纹回调
function lua_system.checkStatusFinger_callBack(checkCode)
    --debug_alert("设备是否支持指纹："..checkCode);
    if checkCode == "1" then
        systemTable["SupportLoginType"] = "TouchID";
    end;
end;

--检测安卓设备是否支持指纹
function lua_system.checkStatusFinger()
    local nowVersion = vt("nowVersion",systemTable)
    local appSupport = lua_ota.version_ctrl(nowVersion,"2.11.3");
    if appSupport == "true" then
        local checkStatusFingerBackFun = "{\"func\":\"lua_system.checkStatusFinger_callBack\"}";
        eSand:checkStatusFinger(checkStatusFingerBackFun);
    end;
end;

--[[iOS指纹验证]]
function iOS_start_fingerID(callbackname)
    globalTable["iOSIDType"] = "Touch ID";
    iOS_start_fingerOrFaceID(callbackname);
end;

--[[iOS人脸验证]]
function iOS_start_faceID(callbackname)
    globalTable["iOSIDType"] = "Face ID";
    iOS_start_fingerOrFaceID(callbackname);
end;

--[[iOS指纹或人脸控件调起，回调函数用于处理返回信息]]
function iOS_start_fingerOrFaceID(callbackname)
    --debug_alert("iOS_start_fingerOrFaceID");
    globalTable["iOSFingerOrFaceIDCallBack"] = callbackname;
    fingerprint:startvalidate("iOS_validate_fingerOrFaceID");
end;

--[[
    验证faceID或指纹的回调
    p1: 1成功 0失败
    p2: 见回调
]]
function iOS_validate_fingerOrFaceID(p1, p2)
    --修改指纹控件状态
    systemTable["fingerPrintStatus"] = "cancel";
    --用一次后参数清空
    local iOSIDType = formatNull(globalTable["iOSIDType"]);
    globalTable["iOSIDType"] = "";
    --定义验证成功后的回调方法，由于是异步线程，放到缓存里，使用后清空
    local validateCallback = formatNull(globalTable["iOSFingerOrFaceIDCallBack"]);
    --[[debug_alert(
        "iOS_validate_fingerOrFaceID\n"..
        "p1:"..p1.."\n"..
        "p2:"..p2.."\n"..
        "iOSFingerOrFaceIDCallBack:"..validateCallback..
        ""
    );]]

    if p1 == "1" then
        --关闭指纹启动界面
        if platform ~= "iPhone OS" then
            --校验成功，重置次数
            FingerprintCheckCount = 5;
            changeStyle("fingerprint_page","display","none");
            changeProperty("fingerprintText","value","请按压指纹");
        end;
        globalTable["iOSFingerOrFaceIDCallBack"] = "";
        lua_system.do_function(validateCallback,p1);
    else
        if p2 == "-1" then
            FingerprintCheckCount = FingerprintCheckCount-1;
            if FingerprintCheckCount > 0 then
                --"-1":校验失败
                --alertToast("1","再试一次","","","");
                changeProperty("fingerprintText","value","指纹不匹配，再试一次");
            else
                --关闭指纹启动界面
                if platform ~= "iPhone OS" then
                    --重置使用次数
                    FingerprintCheckCount = 5;
                    if systemTable["fingerprintStratType"] == "login" then
                        changeProperty("fingerprintText","value","指纹已关闭，如需指纹登陆请点击指纹图片重新启动");
                        changeStyle("fingerprintText","font-size","14px");
                        --隐藏取消按钮
                        changeStyle("cancelFingerprint","display","none");
                        --显示切换登陆方式按钮
                        changeStyle("changeLoginType","display","block");
                    else
                        changeProperty("fingerprintText","value","请按压指纹");
                        changeStyle("fingerprint_page","display","none");
                    end;
                end;
            end; 
        else
            FingerprintCheckCount = 5;
            if systemTable["fingerprintStratType"] == "login" then
                changeProperty("fingerprintText","value","指纹已关闭，如需指纹登陆请点击指纹图片重新启动");
                changeStyle("fingerprintText","font-size","14px");
                changeStyle("cancelFingerprint","display","none");
                changeStyle("changeLoginType","display","block");
            else
                changeProperty("fingerprintText","value","请按压指纹");
                changeStyle("fingerprint_page","display","none");
            end;
            --关闭指纹启动界面
            if platform ~= "iPhone OS" then
                changeStyle("fingerprint_page","display","none");
            end;
            if p2 == "-2" or p2 == "-4" then
                --"-2":用户主动取消 "-4":系统取消，取消的情况下不再发起自动登录
                globalTable["AutoQuickLogin"] = "false";
                if platform ~= "iPhone OS" then
                    eSand:cancelFinger();
                    systemTable["fingerPrintStatus"] = "cancel";
                    changeProperty("fingerprintText","value","指纹已关闭，如需指纹登陆请点击指纹图片重新启动");
                    changeStyle("fingerprintText","font-size","14px");
                    changeStyle("cancelFingerprint","display","none");
                    changeStyle("changeLoginType","display","block");
                end;
                alertToast("1",C_CancelMsg,"","","");
            elseif p2 == "-5" then
                --"-5":未设置锁屏
                alert("未设置"..iOSIDType.."，请在系统中设置");
            elseif p2 == "-6" then
                --"-6":设置了指纹/人脸不给app权限
                alert("未启用"..iOSIDType.."，请在系统中修改");
            elseif p2 == "-7" then
                --"-7":没有录入指纹/人脸
                alert("未录入"..iOSIDType.."，请在系统中录入");
            elseif p2 == "-8" then
                --"-8":指纹/人脸已经被锁定
                alert(iOSIDType.."已锁定，请在系统中解除锁定");
            else
                --其他：直接显示文字
                changeProperty("fingerprintText","value",formatNull(p2,"系统异常"));
                alert(formatNull(p2,"系统异常"));
            end;
        end;
    end;
end;

--[[关闭应用]]
function do_closeApp(index)
    if index == 1 then
        window:close();
    end;
end;

--[[关闭应用]]
function closeApp()
    alert_confirm("温馨提示","您确定要退出极简报销吗？","取消","确定","do_closeApp");
end;

--[[数据库存值]]
function set_db_value(key, value)
    local Dbkey = formatNull(key);
    local DbValue = formatNull(value);

    if Dbkey ~= "" then
        local OldDbValue = get_db_value(Dbkey);
        if OldDbValue == "" then
            database:addData(Dbkey,DbValue);
        else
            database:updateData(Dbkey,DbValue);
        end;
    end;
end;

--[[数据库取值]]
function get_db_value(key)
    local Dbkey = formatNull(key);
    local DbValue = "";
    if Dbkey ~= "" then
        DbValue = formatNull(database:getData(Dbkey));
    else
        DbValue = "";
    end;
    return DbValue;
end;

--[[数据库删除值]]
function del_db_value(key)
    local Dbkey = formatNull(key);
    if Dbkey ~= "" then
        database:deleteData(Dbkey);
    end;
end;

--[[app弹窗]]
function lua_system.app_alert(Arg)
    if type(Arg) == "table" then
        lua_system.do_app_alert(Arg);
    else
        --解码
        Arg = lua_format.table_arg_unpack(Arg);
    end;
    lua_system.do_app_alert(Arg);
end;
function lua_system.do_app_alert(Arg)
    --弹窗标题
    local titleMsg = vt("titleMsg",Arg);
    --提示内容
    local alertMsg = vt("alertMsg",Arg);
    --内容是否编码
    local msgEncodeType = vt("msgEncodeType",Arg);
    --左侧按钮文字
    local leftbtnText = vt("leftbtnText",Arg);
    --右侧按钮文字
    local rightbtnText = vt("rightbtnText",Arg);
    --点击按钮回调方法
    local ClickFun = vt("ClickFun",Arg);
    --按钮点击回调参数，传递字符串，建议编码
    local ClickParams = vt("ClickParams",Arg);

    --消息内容解码
    if msgEncodeType == "url_encode" then
        alertMsg = lua_format.url_decode(alertMsg);
    end;

    alert_confirm(titleMsg,alertMsg,leftbtnText,rightbtnText,ClickFun,ClickParams)
end;

--[[
    只有确定按钮的弹窗，不给回调方法的情况下直接弹窗
    alertMsg:提示信息
]]
function alert(alertMsg)
    close_loading();

    local alertMsg = formatNull(alertMsg);
    if alertMsg ~= "" then
        if alertMsg == "网络请求失败" then
            alertToast1("网络异常");
        else
            alert_confirm("温馨提示",alertMsg,"","确定","","");
        end;
    else
        --没有错误信息给个默认提示
        alertToast0(C_Toast_DefaultMsg);
    end;
end;

--[[自定义弹窗]]
function alert_confirm(titleMsg,alertMsg,leftbtnText,rightbtnText,ClickFun,ClickParams)
    local Arg = {
        --弹窗标题
        titleMsg=titleMsg,
        --提示内容
        alertMsg=alertMsg,
        --左侧按钮文字
        leftbtnText=leftbtnText,
        --右侧按钮文字
        rightbtnText=rightbtnText,
        --点击按钮回调方法
        ClickFun=ClickFun,
        --按钮点击回调参数，传递字符串，客户端透传回来，可以自定义json或者简单格式字符串
        ClickParams=ClickParams
    };
    lua_system.alert_confirm(Arg);
end;
function lua_system.alert_confirm(Arg)
    local Arg = formatNull(Arg);
    if type(Arg) == "string" then
        --参数解码
        Arg = lua_format.table_arg_unpack(Arg);
    end;
    close_loading();

    local titleMsg = vt("titleMsg",Arg,C_Default_Title_Msg);
    local alertMsg = vt("alertMsg",Arg,C_Default_Alert_Msg);
    local leftbtnText = vt("leftbtnText",Arg);
    local rightbtnText = vt("rightbtnText",Arg);
    local ClickFun = vt("ClickFun",Arg);
    local ClickParams = vt("ClickParams",Arg);

    --没有错误信息不提示
    if alertMsg ~= "" then
        --按钮数据上报
        local reportArg = {
            Event="JJBXAppAlertMsg",
            AlertMsg=alertMsg
        };
        lua_system.sensors_report(reportArg);

        if leftbtnText == "" then
            --没有左侧按钮的调用
            ryt:alert(titleMsg,alertMsg,rightbtnText,ClickFun,ClickParams);
        else
            --左右侧按钮均存在的调用
            ryt:alert(titleMsg,alertMsg,leftbtnText,rightbtnText,ClickFun,ClickParams);
        end;
    end;
end;

--[[自定义弹窗默认回调]]
function alert_confirm_call(TouchIndex,CallArg)
    --[[debug_alert(
        "自定义弹窗默认回调\n"..
        "TouchIndex : "..TouchIndex.."\n"..
        "CallArg : "..CallArg.."\n"..
        ""
    );]]
    if tostring(TouchIndex) == "1" then
        local CallArg = formatNull(CallArg);
        if CallArg ~= "" then
            local CallArgTable = string_to_table(CallArg);
            --debug_alert(foreach_arg2print(CallArgTable));

            local DoCallFun = vt("CallFun",CallArgTable);
            local DoCallArg = vt("CallArg",CallArgTable);
            lua_system.do_function(DoCallFun,DoCallArg);
        end;
    end;
end;

--[[
    显示不再提示的弹窗
    titleMsg     : 弹窗标题
    alertMsg     : 提示内容
    tipMsg       : 带复选框的提示信息
    leftbtnText  : 左侧按钮文字
    rightbtnText : 右侧按钮文字
    ClickFun     : 点击按钮回调方法
    ClickParams  : 按钮点击回调参数，传递字符串，客户端透传回来，可以自定义json或者简单格式字符串

    回调方法实现说明：
    客户端会传递点击按钮标记和ClickParams回来，标记左侧按钮为0，右侧按钮为1，选中复选为1，不选中为0
]]
function alertTip(titleMsg,alertMsg,tipMsg,leftbtnText,rightbtnText,ClickFun,ClickParams)
    close_loading();

    local titleMsg = formatNull(titleMsg,C_Default_Title_Msg);
    local alertMsg = formatNull(alertMsg,C_Default_Alert_Msg);
    local tipMsg = formatNull(tipMsg);
    local leftbtnText = formatNull(leftbtnText);
    local rightbtnText = formatNull(rightbtnText);
    local ClickFun = formatNull(ClickFun);
    local ClickParams = formatNull(ClickParams);

    --没有错误信息不提示
    if alertMsg ~= "" then
        ryt:tip_alert(titleMsg,alertMsg,tipMsg,leftbtnText,rightbtnText,ClickFun,ClickParams);
    end;
end;

--[[成功的消息提示]]
function alertToast0(msg)
    alertToast("0",msg,"","","");
end;

--[[失败的消息提示]]
function alertToast1(msg)
    alertToast("1",msg,"","","");
end;

--[[
    消息弹窗
    style           : 图标样式 0:√ 1:×
    alertMsg        : 提示内容，最长6个字
    time            : toast显示时间，string类型，单位毫秒。客户端默认2秒，后台默认1秒
    removecall      : toast移除时客户端回调函数名，为空时客户端不回调
    removecallparam : toast移除时客户端回调函数参数，string类型，客户端原样透传给lua
]]
function alertToast(style,alertMsg,time,removecall,removecallparam)
    close_loading();

    --默认值为空
    local style = formatNull(style);
    local alertMsg = formatNull(alertMsg,C_Toast_DefaultMsg);
    local time = formatNull(time,"1000");
    local removecall = formatNull(removecall);
    local removecallparam = formatNull(removecallparam);

    if platform == "iPhone OS" then
        --iOS延时回调
        ryt:showToast(style,alertMsg,time,removecall,removecallparam);
    else
        if removecall=="back_fun" or removecall=="back_fun_noloading" or removecall=="back_fun_loading" then
            ryt:showToast(style,alertMsg,time,"","");
            --手动调用返回
            back_fun_noloading();
        else
            --其他情况使用Android延时回调
            ryt:showToast(style,alertMsg,time,removecall,removecallparam);
        end;
    end;
end;

--[[校验是否短时间内的接口请求]]
function check_repeat_do_request_erl()
    local isRepeatClick = ryt:isRepeatClick();
    if isRepeatClick == "false" then
        --重复点击
        return false;
    else
        return true;
    end;
end;

--[[校验是否短时间内的页面请求]]
function check_repeat_do_request_page()
    local isRepeatClick = ryt:noLoadRepeatClick();
    if isRepeatClick == "false" then
        --重复点击
        return false;
    else
        return true;
    end;
end;

--[[打开加载框]]
function show_loading(Arg)
    if configTable["lua_debug"] == "true" then
        local Msg = vt("Msg",Arg);
        if Msg ~= "" then
            debug_alert(Msg.."，打开加载框");
        end;
    end;
    picker:showLoadingView("open");
end;

--[[关闭加载框]]
function close_loading(Arg)
    if configTable["lua_debug"] == "true" then
        local Msg = vt("Msg",Arg);
        if Msg ~= "" then
            debug_alert(Msg.."，关闭加载框");
        end;
    end;
    picker:showLoadingView("close");
end;

--[[重新刷新页面布局]]
function page_reload()
    --debug_alert("page_reload");
    ryt:reload();
end;

--[[注册推送]]
function push_register(uuid,func)
    local uuid = formatNull(uuid);
    local callbackfun = formatNull(func,"push_register_callback");
    local regId = get_db_value("PUSH_REGISTERID_DB");

    --[[debug_alert(
        "注册推送\n"..
        "前端平台 : "..platform.."\n"..
        "用户编号 : "..uuid.."\n"..
        "注册编号 : "..regId.."\n"..
        "注册回调 : "..callbackfun.."\n"..
        ""
    );]]

    --用户不为空的时候进行绑定
    if uuid ~= "" then
        if platform == "iPhone OS" then
            push:setAlias(uuid,callbackfun);
        elseif platform == "Android" then
            --Android是否已经注册
            if regId == "" then
                --注册推送,由客户端设置别名
                push:pushRegister(uuid,callbackfun);
            else
                --设置别名
                push:setAlias(uuid,callbackfun);
            end;
        else
            --不处理
        end;
    end;
end;

--[[推送绑定用户回调]]
function push_register_callback(registerToken)
    --[[debug_alert(
        "推送注册回调\n"..
        "registerToken:"..registerToken.."\n"..
        ""
    );]]
end;

--[[推送通知栏点击回调]]
function showPushMessage(msgcontent)
    --[[debug_alert(
        "推送通知栏点击回调\n"..
        "消息内容:"..msgcontent.."\n"..
        ""
    );]]
    if msgcontent ~= "" then
        local MsgContent = lua_format.base64_decode(msgcontent);
        local detail = json2table(MsgContent);
        local pkNotimsg = vt("pkNotimsg",detail);
        lua_message.qry_mess_info_ByPk("",{pkNotimsg=pkNotimsg});
    else
        alert("暂无详情");
    end;
end;

--[[删除已经收到的推送通知，并清空角标数]]
function clear_past_push_msg()
    if platform == "Android" then
        picker:setAllMessageAsRead();
    end;
end

function setBadgeNum(flag)
    local appSupportInfo = lua_ota.version_support("setBadgeNum");
    local appSupport = vt("appSupport",appSupportInfo);
    if appSupport == "true" and platform == "iPhone OS" then
        local setValue = "{\"flag\":\""..flag.."\"}";
        picker:setBadgeNum(setValue);
    end;
end;

--[[
    安卓设置物理返回建
    funName: 返回键回调方法
    funArg: 返回键回调参数
]]
function set_android_Physical_back(funName,funArg)
    local funName = formatNull(funName);
    --去掉括号
    funName = string.gsub(funName,"%(%)","");
    local funArg = formatNull(funArg);

    if platform == "Android" then
        globalTable["ADPhysicalBackFun"] = funName;
        globalTable["ADPhysicalBackArg"] = funArg;
        --[[debug_alert(
            "Android设置返回键：\n"..
            "ADPhysicalBackFun:"..globalTable["ADPhysicalBackFun"].."\n"..
            "ADPhysicalBackArg:"..globalTable["ADPhysicalBackArg"].."\n"..
            ""
        );]]
        window:setPhysicalkeyListener("backspace",backspace_call);
    end;
end;

--[[
    安卓物理返回建调用
    funName: 返回键回调方法
    funArg: 返回键回调参数
]]
function backspace_call(funName,funArg)
    local ADPhysicalBackFun = formatNull(globalTable["ADPhysicalBackFun"]);
    local ADPhysicalBackArg = formatNull(globalTable["ADPhysicalBackArg"]);

    --[[debug_alert(
        "Android调用返回键：\n"..
        "ADPhysicalBackFun:"..ADPhysicalBackFun.."\n"..
        "ADPhysicalBackArg:"..ADPhysicalBackArg.."\n"..
        ""
    );]]

    if ADPhysicalBackFun == "" then
        --没有指定返回默认返回上一个页面
        back_fun();
    else
        if platform == "Android" then
            lua_system.do_function(ADPhysicalBackFun,ADPhysicalBackArg);
        end;
    end;
end;

--[[设置长按监听]]
function set_longtap_listener(eleName,funName,funArg)
    --监听控件名
    local eleName = formatNull(eleName);
    --回调方法
    local funName = formatNull(funName);
    --回调参数
    local funArg = formatNull(funArg);

    --[[debug_alert(
        "设置长按监听：\n"..
        "监听控件名 :"..eleName.."\n"..
        "回调方法 :"..funName.."\n"..
        "回调参数 :"..funArg.."\n"..
        ""
    );]]

    if eleName ~= "" then
        local eleobjs = document:getElementsByName(eleName);
        for i=1,#eleobjs do
            local eleobj = eleobjs[i];
            --设置监听
            globalTable["LongTapFun"] = funName;
            globalTable["LongTapArg"] = funArg;
            gesture:setLongTapListener(eleobj, longtap_call);
        end;
    end;
end;

--[[长按监听回调]]
function longtap_call(Arg)
    local LongTapFun = formatNull(globalTable["LongTapFun"]);
    local LongTapArg = formatNull(globalTable["LongTapArg"]);

    --[[debug_alert(
        "长按监听回调\n"..
        "LongTapFun : "..LongTapFun.."\n"..
        "LongTapArg : "..LongTapArg.."\n"..
        "回调参数"..foreach_arg2print(Arg).."\n"..
        ""
    );]]

    lua_system.do_function(LongTapFun,LongTapArg);
end;

--[[响应点击]]
function do_onclick()
    close_loading();
    debug_alert("响应点击");
end;

--[[复制内容到剪贴板]]
function lua_system.copy_to_paste(content)
    local content = formatNull(content);
    if content ~= "" then
        RYTL:copyPasteTargetStr(content);
    end;
end;

--[[读取剪贴板内容]]
function lua_system.read_paste()
    local content = "";
    local MatchRes = lua_system.check_app_func("RYTL_readPasteTargetStr");
    if MatchRes == "true" then
        content = RYTL:readPasteTargetStr();
    else
        content = "";
    end;
    return content;
end;

--[[复制内容到剪贴板，并弹出Toast提示]]
function lua_system.copy_and_toast(content,toastMsg)
    alertToast0(formatNull(toastMsg,C_CopyMsg));
    lua_system.copy_to_paste(content);
end;

--[[
    方法执行
    funName: 方法名，string
    FunArg: 参数
]]
function lua_system.do_function(funName,FunArg)
    local funName = formatNull(funName);
    local FunArg = formatNull(FunArg);
    local res = "";
    --调用函数，可传参
    if funName ~= "" then
        local dofunction = lua_format.str2fun(funName);
        if dofunction then
            if FunArg == "" then
                res = dofunction();
            else
                res = dofunction(FunArg);
            end;
        else
            debug_alert("函数未定义，函数名"..funName);
        end;
    end;

    return res;
end;

--[[
    方法说明：
    picker:changeIphoneXTopColor(arg1,arg2,arg3,arg4);
    1.Android头部颜色，优先级低
    2.iPhoneX底部bottom 1隐藏 2显示
    3.iPhoneX底部bottom 颜色
    4.Android头部图片，优先级高

    依赖该方法，封装了以下几个方法
        set_android_top_bar_image
        set_android_top_bar_color
        iPhoneX_bottom_ctrl
]]

--[[通用页面的状态栏适配]]
function set_common_title()
    --设置安卓头部图片
    set_android_top_bar_image("topBar_Bg.png");
    --设置iOS底部为显示，颜色为白色
    iPhoneX_bottom_ctrl("show","#FFFFFF","","");
end;

--[[设置安卓状态栏图片]]
function set_android_top_bar_image(barImageName)
    --默认图片
    local barImageName = formatNull(barImageName,"topBar_Bg.png");

    --这里只设置安卓的状态栏图片
    if platform == "Android" then
        picker:changeIphoneXTopColor("","","",barImageName);
    else
        --debug_alert("iOS设备不生效");
    end;
end;

--[[设置安卓状态栏颜色，颜色需要带#号，会做校验]]
function set_android_top_bar_color(barColor)
    local barColor = formatNull(barColor);

    --这里只设置安卓的状态栏颜色
    if platform == "Android" then
        local CheckColorResult = check_color(barColor);
        if CheckColorResult == "true" then
            picker:changeIphoneXTopColor(barColor,"","","");
        else
            --debug_alert("状态栏颜色格式错误");
        end;
    else
        --debug_alert("iOS设备不生效");
    end;
end;

--[[
    iPhoneX底部控制
    CtrlStyle: 显示show 隐藏hide
    bottomColor: 底部颜色，会做颜色校验，可以传空
    callbackFun: 回调方法名，可以在回调方法自行实现页面适配
    callbackArg: 回调参数
]]
function iPhoneX_bottom_ctrl(CtrlStyle,bottomColor,callbackFun,callbackArg)
    --默认打开
    local CtrlStyle = formatNull(CtrlStyle,"show");
    local CtrlStyleArg = "2";
    if CtrlStyle == "show" then
        CtrlStyleArg = "2";
        globalTable["iPhoneXBottomStyle"] = "show";
    elseif CtrlStyle == "hide" then
        CtrlStyleArg = "1";
        globalTable["iPhoneXBottomStyle"] = "hide";
    else
        CtrlStyleArg = "2";
    end;

    local bottomColor = formatNull(bottomColor);
    --[[debug_alert(
        "iPhoneX_bottom_ctrl\n"..
        "bottomColor:"..bottomColor.."\n"..
        "CtrlStyle:"..CtrlStyle.."\n"..
        "CtrlStyleArg:"..CtrlStyleArg.."\n"..
        "is_iPhoneX:"..systemTable["is_iPhoneX"].."\n"..
        ""
    );]]

    --这里只设置安卓的状态栏颜色
    if systemTable["is_iPhoneX"] == "true" then
        --debug_alert(systemTable["is_iPhoneX"]);
        local CheckColorResult = check_color(bottomColor);
        --debug_alert(CheckColorResult);

        if bottomColor ~= "" and CheckColorResult == "false" then
            --debug_alert("iPhoneX底部颜色格式错误");
        else
            picker:changeIphoneXTopColor("",CtrlStyleArg,bottomColor,"");
            lua_system.do_function(callbackFun,callbackArg);
        end;
    else
        --debug_alert("非iPhoneX设备不生效");
    end;
end;

--[[保存定位信息]]
function lua_system.save_location(flag,longitude,latitude,cityName,addr)
    --debug_alert("lua_system.save_location");
    local locationInfoTable = {
        ResFlag=flag,
        Longitude=longitude,
        Latitude=latitude,
        City=cityName,
        Address=addr
    };
    lua_system.save_location_json(table2json(locationInfoTable));
end;

function lua_system.save_location_json(locationInfoJson)
    local locationInfoJson = formatNull(locationInfoJson);
    local locationInfo = json2table(locationInfoJson);
    --[[debug_alert(
        "lua_system.save_location_json\n"..
        "定位信息"..foreach_arg2print(locationInfo).."\n"..
        ""
    );]]

    --定位结果 0-成功 1-失败
    local ResFlag = vt("ResFlag",locationInfo);
    --经度
    local Longitude = vt("Longitude",locationInfo);
    --纬度
    local Latitude = vt("Latitude",locationInfo);
    --省份名称
    local Province = vt("Province",locationInfo);
    --城市名
    local City = vt("City",locationInfo);
    --区县名
    local District = vt("District",locationInfo);
    --街道名
    local Street = vt("Street",locationInfo);
    --具体地址
    local Address = vt("Address",locationInfo);

    --Android地址信息会返回省、市、区，这里进行过滤
    Address = string.gsub(Address,Province,"");
    Address = string.gsub(Address,City,"");
    Address = string.gsub(Address,District,"");
    --debug_alert(Address);

    --具体地址名称
    local AddressName = vt("AddressName",locationInfo);
    --地图类型 0-百度 1-高德 2-GPS
    local Map = vt("Map",locationInfo);

    --上一次定位的城市编码
    local lastCityCode = vt("location_cityCode",systemTable);
    --上一次定位的城市名称
    local lastCityName = vt("location_cityName",systemTable);

    local nowCityCode = "";
    if lastCityName == cityName then
        --debug_alert("城市名称没有变更的时候，不更新城市编码");
        nowCityCode = lastCityCode;
    else
        nowCityCode = "";
    end;

    if ResFlag == "0" then
        systemTable["location_longitude"] = Longitude;
        systemTable["location_latitude"] = Latitude;
        systemTable["location_provinceName"] = Province;
        systemTable["location_cityName"] = City;
        systemTable["location_cityCode"] = nowCityCode;
        systemTable["location_districtName"] = District;
        systemTable["location_street"] = Street;
        systemTable["location_addr"] = Address;
        systemTable["location_addrName"] = AddressName;
        systemTable["location_flag"] = "successed";
    else
        --定位失败清空定位信息
        systemTable["location_longitude"] = "";
        systemTable["location_latitude"] = "";
        systemTable["location_provinceName"] = "";
        systemTable["location_cityName"] = "";
        systemTable["location_cityCode"] = "";
        systemTable["location_districtName"] = "";
        systemTable["location_street"] = "";
        systemTable["location_addr"] = "";
        systemTable["location_addrName"] = "";
        systemTable["location_flag"] = "failed";
    end;

    --执行回调函数
    local callbackFun = globalTable["start_location_call_fun"];
    local callbackArg = globalTable["start_location_call_arg"];
    globalTable["start_location_call_fun"] = "";
    globalTable["start_location_call_arg"] = "";
    lua_system.do_function(callbackFun,callbackArg);
end;

--[[获取定位信息]]
function lua_system.start_location(callbackFun,callbackArg)
    --debug_alert("lua_system.start_location");

    globalTable["start_location_call_fun"] = callbackFun;
    globalTable["start_location_call_arg"] = callbackArg;
    local save_location_call = "";
    local appSupportInfo = lua_ota.version_support("save_location");
    local appSupport = vt("appSupport",appSupportInfo);
    --版本支持判断
    if appSupport == "false" then
        save_location_call = "lua_system.save_location";
    else
        --0611版本后客户端以json入参传递定位信息
        save_location_call = "lua_system.save_location_json";
    end;
    RYTL:startLocation(save_location_call);
end;

--[[
    通过webview预览文件，iOS不限制，Android优先使用X5内核预览，加载失败的时候有预览类型限制
    pdfLinkUrl     : 下载链接
    pdfFileType    : 文件类型
    pdfPageTitle   : 页面标题
    pdfPageBackFun : 页面返回方法
    pdfOpenStyle   : Webview（webview打开）/（ClientWidget）客户端控件打开
]]
function lua_system.view_file_by_webview(pdfarg)
    local pdfLinkUrl = formatNull(pdfarg["pdfLinkUrl"]);
    --除生产环境外其他环境将下载链接拷贝到剪贴板
    if systemTable["EnvAllowDebug"] == "true" then
        lua_system.copy_to_paste(pdfLinkUrl);
    end;
    local pdfFileType = vt("pdfFileType",pdfarg,"pdf");
    local pdfPageTitle = vt("pdfPageTitle",pdfarg,"查看文件");
    local pdfPageBackFun = vt("pdfPageBackFun",pdfarg,"jjbx_utils_hideContent()");
    --默认客户端控件打开
    local pdfOpenStyle = vt("pdfOpenStyle",pdfarg,"ClientWidget");

    --[[debug_alert(
        "通过webview预览文件\n"..
        "文件链接："..pdfLinkUrl.."\n"..
        "文件类型："..pdfFileType.."\n"..
        "返回方法："..pdfPageBackFun.."\n"..
        "打开方式："..pdfOpenStyle.."\n"..
        "页面标题："..pdfPageTitle.."\n"..
        ""
    );]]

    local PCConfigListsTable = vt("PCConfigListsTable",globalTable);
    --是否启动水印
    local IMG0015 = vt("IMG0015",PCConfigListsTable);
    --水印样式
    local waterMarkValue = "";
    if IMG0015 == "是" then
        --获取当前日期
        local nowTime = os.time();
        local nowDate = os.date("%Y-%m-%d",nowTime);
        --获取工号
        local workID = globalTable["workid"];
        --获取所属公司名称
        local unitname = globalTable["selectOrgList"][1]["unitname"];
        waterMarkValue = unitname.." "..nowDate.." "..workID;
    end;

    --是否支持附件下载
    local IMG0016 = vt("IMG0016",PCConfigListsTable);

    if pdfLinkUrl == "" then
        alert("文件不存在");
    else
        if pdfOpenStyle == "Webview" then
            --webview实现
            globalTable["webview_page_title"] = pdfPageTitle;
            globalTable["webview_url"] = pdfLinkUrl;
            globalTable["webview_iPhoneX_bottom"] = "show";
            globalTable["webview_back_fun"] = pdfPageBackFun;

            --仅关闭现有弹出的页面
            jjbx_utils_hideContent("true","false");

            --默认showContent打开
            local DefaultInvokePageArg = {
                ShowPageStyle="showContent",
                AddPage="false",
                JumpStyle=""
            };
            local InvokePageArg = formatNull(pdfarg["InvokePageArg"],DefaultInvokePageArg);
            --打开webview页面展示pdf文件
            invoke_page("jjbx_page/xhtml/webview_page.xhtml",page_callback,InvokePageArg);
        elseif pdfOpenStyle == "ClientWidget" then
            local RightLabelText = vt("right_label_text",pdfarg,"下载");
            if RightLabelText == "NONE" or vt("downloadFlag",globalTable) ~= "true" then
                RightLabelText = "";
            end;
            local RightLabelFunc = vt("right_label_func",pdfarg,"lua_system.download_file('"..pdfLinkUrl.."')");
            if RightLabelFunc == "NONE" or vt("downloadFlag",globalTable) ~= "true" then
                RightLabelFunc = "";
            end;
            
            --RightLabelText = "下载";
            --RightLabelFunc = vt("right_label_func",pdfarg,"lua_system.download_file('"..pdfLinkUrl.."')");

            --[[debug_alert(
                "RightLabelText : "..RightLabelText.."\n"..
                "RightLabelFunc : "..RightLabelFunc.."\n"..
                ""
            );]]

            --客户端控件实现
            if platform == "iPhone OS" then
                --iOS弹出webview控件预览文件
                local previewArg = {
                    --页面标题内容
                    webview_page_title=pdfPageTitle,
                    --页面加载文件链接
                    webview_page_url=pdfLinkUrl,
                    --下载按钮文字
                    file_download_text=RightLabelText,
                    --下载按钮方法
                    file_download_func=RightLabelFunc,
                    --关闭类型
                    back_type="CLOSE",
                    --显示进度条
                    progress_bar="true",
                    --水印文本
                    waterMarkValue=waterMarkValue,
                    --水印样式
                    waterMarkColor="#8B8B8B"
                };
                ryt:h5_preview_file(table2json(previewArg));
            else
                --Android需要根据x5内核加载情况来确认预览控件
                local webviewCore = lua_system.webview_core();
                if webviewCore == "webviewX5" and pdfFileType == "pdf" then
                    --debug_alert("X5内核加载成功，使用客户端h5文件预览页面，链接 : "..pdfLinkUrl);
                    local previewArg = {
                        preview_page_title=pdfPageTitle,
                        preview_file_url=pdfLinkUrl,
                        preview_file_name=tostring(os.time()).."."..pdfFileType,
                        --下载按钮文字
                        file_download_text=RightLabelText,
                        --下载按钮方法
                        file_download_func=RightLabelFunc,
                        --关闭类型
                        back_type="CLOSE",
                        --显示进度条
                        progress_bar="true",
                        --水印文本
                        waterMarkValue=waterMarkValue,
                        --水印样式
                        waterMarkColor="#8B8B8B"
                    };
                    ryt:x5_preview_file(table2json(previewArg));
                else
                    --debug_alert("X5内核加载失败，使用客户端控件打开");
                    local viewArg = {
                        FileDownloadLinkUrl=pdfLinkUrl,
                        FileName=tostring(os.time()).."."..pdfFileType,
                        FileType=pdfFileType
                    };
                    czbank:view_file_by_phone_soft(table2json(viewArg));
                end;
            end;
        end;
    end;
end;

--[[应用切到后台方法（供客户端调用）]]
function app_to_backstage(timestamp)
    --存储切到后台的时间戳
    save_app_switch_stage_TS(timestamp,"back");

    --[[debug_alert(
        "应用切到后台\n"..
        "前台运行: "..formatNull(globalTable["AppToUpstageTS"]).."\n"..
        "后台运行: "..formatNull(globalTable["AppToBackstageTS"]).."\n"..
        ""
    );]]
end;

--[[应用切到前台方法（供客户端调用）]]
function app_to_upstage(timestamp)
    --存储切到前台的时间戳
    save_app_switch_stage_TS(timestamp,"up");
    --获取后台配置的超时检查开关
    local app_backstage_timeout_switch = formatNull(systemTable["ClientBackstageTimeoutClean"],"false");
    local app_timeout = formatNull(globalTable["AppTimeOut"]);

    --[[debug_alert(
        "应用切到前台\n"..
        "超时开关 : "..app_backstage_timeout_switch.."\n"..
        "是否超时 : "..app_timeout.."\n"..
        "前台运行: "..formatNull(globalTable["AppToUpstageTS"]).."\n"..
        "后台运行: "..formatNull(globalTable["AppToBackstageTS"]).."\n"..
        ""
    );]]
    
    --分析是否超时
    if app_backstage_timeout_switch == "true" and app_timeout == "true" then
        --当前用户已经超时的情况下，再切到后台切回前台，客户端不再进行超时判断，直接给超时界面
        lua_system.call_client_timeout();
    else
        analysis_app_backstage();
    end;
end;

--[[存储app切换运行的时间戳]]
function save_app_switch_stage_TS(timestamp,switch)
    local timestamp = tonumber(formatNull(timestamp,"0"));
    if switch == "back" then
        globalTable["AppToBackstageTS"] = timestamp;
    elseif switch == "up" then
        globalTable["AppToUpstageTS"] = timestamp;
    else

    end;

    --[[alert(
        "存储app切换运行的时间戳\n"..
        "当前时间戳: "..timestamp.."\n"..
        "切换类型: "..formatNull(switch).."\n"..
        "前台: "..formatNull(globalTable["AppToUpstageTS"]).."\n"..
        "后台: "..formatNull(globalTable["AppToBackstageTS"]).."\n"..
        ""
    );]]
end;

--[[分析app后台运行情况]]
function analysis_app_backstage(timestamp)
    --获取切到后台的时间戳
    local app_to_backstage_ts = tonumber(formatNull(globalTable["AppToBackstageTS"],"0"));
    --获取切到前台的时间戳
    local app_to_upstage_ts = tonumber(formatNull(globalTable["AppToUpstageTS"],"0"));

    --计算后台运行时间
    local app_backstage_run_secs = 0;
    if app_to_backstage_ts ~= 0 and app_to_upstage_ts ~= 0 then
        local time_diff = app_to_upstage_ts - app_to_backstage_ts;
        --时间差大于0则修改
        if time_diff > 0 then
            app_backstage_run_secs = time_diff;
        end;
    end;

    --存储最近一次后台运行时间，然后将保存的前台后台时间戳重置
    globalTable["AppBackstageRunSecs"] = app_backstage_run_secs;
    globalTable["AppToBackstageTS"] = 0;
    globalTable["AppToUpstageTS"] = 0;

    --获取后台配置的检查开关
    local app_backstage_timeout_switch = formatNull(systemTable["ClientBackstageTimeoutClean"],"false");
    --获取后台配置的客户端后台运行超时时间
    local client_backstage_timeout = tonumber(formatNull(systemTable["ClientBackstageTimeout"],0));

    --后台运行时间大于配置的超时时间认为客户端超时
    if globalTable["AppBackstageRunSecs"] > client_backstage_timeout then
        --记录超时状态
        globalTable["AppTimeOut"] = "true";
    else
        globalTable["AppTimeOut"] = "false";
    end;

    local doAppTimeOut = "false";
    if app_backstage_timeout_switch == "true" and globalTable["AppTimeOut"] == "true" then
        doAppTimeOut = "true";
    end;

    --[[debug_alert(
        "分析app在后台运行的时间\n"..
        "切到后台: "..app_to_backstage_ts.."\n"..
        "切到前台: "..app_to_upstage_ts.."\n"..
        "时间差  : "..formatNull(globalTable["AppBackstageRunSecs"]).."\n"..        
        "会话超时: "..formatNull(systemTable["SessionTimeout"]).."\n"..
        "登录超时: "..formatNull(systemTable["ClientBackstageTimeout"]).."\n"..
        "超时开关: "..app_backstage_timeout_switch.."\n"..
        "是否超时: "..globalTable["AppTimeOut"].."\n"..
        "调用超时: "..doAppTimeOut.."\n"..
        ""
    );]]

    --根据开关状态调用客户端超时
    if doAppTimeOut == "true" then
        lua_system.call_client_timeout();
    else
        --检查客户端注册的待处理的任务
        --debug_alert("客户端后台切到前台，检查客户端注册的待处理的任务并执行");
        lua_index_mission.deal_client_register_mission();
    end;
end;

--[[调用客户端超时流程]]
function lua_system.call_client_timeout()
    --当页面有弹出的时候，先关闭弹出页面
    jjbx_utils_hideContent("false", "false");

    --批量关闭app弹出界面
    lua_system.batch_close_app_alert_window();

    --调用超时
    ryt:timeoutAlert();
end;

--[[
    设置右滑监听
    eleName : 控件名
    funName : 回调方法
    funArg  : 回调参数
]]
function set_rslide_listener(eleName,funName,funArg)
    if platform == "iPhone OS" then
        local eleName = formatNull(eleName);
        if eleName ~= "" then
            local eleobj = document:getElementsByName(eleName)[1];
            --设置监听
            globalTable["RslideFun"] = formatNull(funName, "");
            globalTable["RslideArg"] = formatNull(funArg, "");
            --[[debug_alert(
                "设置右滑监听：\n"..
                "RslideFun:"..globalTable["RslideFun"].."\n"..
                "RslideArg:"..globalTable["RslideArg"].."\n"..
                ""
            );]]

            gesture:setSwipeListener(eleobj, rslide_call);
        end;
    else
        --Android设置监听后会和上下滚动手势冲突
        --后续修复后再使用
    end;
end;

--[[右滑回调]]
function rslide_call(params)
    local direction = formatNull(params["direction"]);
    local RslideFun = formatNull(globalTable["RslideFun"]);
    local RslideArg = formatNull(globalTable["RslideArg"]);

    if direction == "right" then
        --[[debug_alert(
            "右滑调用：\n"..
            "RslideFun:"..RslideFun.."\n"..
            "RslideArg:"..RslideArg.."\n"..
            ""
        );]]
        lua_system.do_function(RslideFun,RslideArg);
    end;
end;

--[[设置单个控件快速滑动监听]]
function lua_system.set_single_swipe_listener(SetArg)
    --控件名
    local eleName = vt("eleName",SetArg);

    if eleName ~= "" then
        local eleobj = document:getElementsByName(eleName);
        if #eleobj >= 1 then
            --存储监听参数
            globalTable["SingleSwipeListenerSetArg"] = SetArg;
            --为第一个控件设置监听
            gesture:setSwipeListener(eleobj[1], lua_system.single_swipe_call);
        else
            debug_alert("未找到快速滑动监听控件");
        end;
    else
        debug_alert("未指定快速滑动监听控件");
    end;
end;

--[[单个控件快速滑动回调]]
function lua_system.single_swipe_call(CallArg)
    --滑动方向
    local direction = vt("direction",CallArg);

    --获取存储的监听参数
    local SetArg = vt("SingleSwipeListenerSetArg",globalTable);

    --[[debug_alert(
        "单个控件快速滑动回调\n"..
        "direction : "..direction.."\n"..
        "监听参数"..foreach_arg2print(SetArg).."\n"..
        ""
    );]]

    --声明执行的回调方法
    local DoCallFun = "";
    --声明执行的回调参数
    local DoCallArg = {
        direction=direction,
        setArg=""
    };

    local defaultCall = vt("defaultCall",SetArg);
    if defaultCall ~= "" then
        --默认回调
        DoCallFun = defaultCall;
        DoCallArg["setArg"] = vt("defaultArg",SetArg);
    else
        --可以为每个方向指定不同的监听方法和监听参数
        if direction == "left" then
            --左滑
            DoCallFun = vt("leftFun",SetArg);
            DoCallArg["setArg"] = vt("leftArg",SetArg);
        elseif direction == "right" then
            --右滑
            DoCallFun = vt("rightFun",SetArg);
            DoCallArg["setArg"] = vt("rightArg",SetArg);
        elseif direction == "up" then
            --上滑
            DoCallFun = vt("upFun",SetArg);
            DoCallArg["setArg"] = vt("upArg",SetArg);
        elseif direction == "down" then
            --下滑
            DoCallFun = vt("downFun",SetArg);
            DoCallArg["setArg"] = vt("downArg",SetArg);
        end;
    end;
    if DoCallFun == "" then
        debug_alert("未指定快速滑动监听回调，滑动方向："..direction);
    else
        lua_system.do_function(DoCallFun,DoCallArg);
    end;
end;

--[[是否支持读取文件]]
function file_sysapi_support()
    if platform =="iPhone OS" then
        --iPhone在iOS11.0后的版本支持
        local iPhoneOsVersion = system:getInfo("version");
        local OsVerArr = splitUtils(iPhoneOsVersion,"%.");
        local OsMainVer = formatNull(OsVerArr[1],"0");
        local OsMainVerNum = tonumber(OsMainVer);
        --[[debug_alert(
            "file_sysapi_support\n"..
            "iPhoneOsVersion : "..iPhoneOsVersion.."\n"..
            "OsMainVer : "..OsMainVer.."\n"..
            ""
        );]]
        if OsMainVerNum >= 11 then
            return "true";
        else
            return "false";
        end;
    else
        --Android默认支持
        return "true";
    end;
end;

--[[
    屏幕分辨率记录和更新
    用于页面初始化和虚拟按钮收回后的通知
    width  : 屏幕宽度
    height : 屏幕高度
]]
function screen_resolution_update(width,height)
    --默认取系统的屏宽和屏高，iOS返回绝对单位dp，Android返回屏幕尺寸
    local screen_width = formatNull(width,screen:width());
    local screen_height = formatNull(height,screen:height());
    --屏幕像素个数
    local screen_dpi = formatNull(screen:dpi());
    --基于系统基准分辨率的比例
    local width_ratio = float(screen_width/C_screenBaseWidth,4);
    local height_ratio = float(screen_height/C_screenBaseHeight,4);
    --高度适配的标准，是否为已配置的分辨率
    local screen_configured = configured_screen_info(screen_width,screen_height);
    --屏幕实际使用高度
    local screen_use_height = math.ceil(screen_height/width_ratio);

    --存储到会话里
    systemTable["phoneInfo"].screenWidth=screen_width;
    systemTable["phoneInfo"].widthRatio=width_ratio;
    systemTable["phoneInfo"].screenHeight=screen_height;
    systemTable["phoneInfo"].screenUseHeight=screen_use_height;
    systemTable["phoneInfo"].heightRatio=height_ratio;
    systemTable["phoneInfo"].screenDpi=screen_dpi;
    systemTable["phoneInfo"].screenConfigured=screen_configured;
end;

--[[
    屏幕分辨率配置
    用于高度适配时候选择临界像素的适配方案
    苹果默认已配置
]]
function configured_screen_info(width,height)
    --[[debug_alert(
        "configured_screen_info\n"..
        "width:"..width.."\n"..
        "height:"..height.."\n"..
        ""
    );]]

    local res = "";
    if platform == "iPhone OS" then
        res = "true";
    else
        res = "false";
    end;

    return res;
end;

--[[拨号]]
function tel_call(telno)
    local telno = formatNull(telno);
    if telno ~= "" then
        system:openURL("tel:"..telno);
    end;
end;

--[[邮箱]]
function mail_call(mailaddr)
    local mailaddr = formatNull(mailaddr);
    if mailaddr ~= "" then
        system:openURL("mailto:"..mailaddr);
    end;
end;

--[[确认清除客户端缓存]]
function lua_system.confirm_clear_app_cache()
    alert_confirm(
        "重要提示",
        "该操作会清理客户端所有已保存数据，包括但不限于离线资源、登录信息、保存菜单、本地文件等，清理后客户端会关闭",
        "取消",
        "确定",
        "alert_confirm_call",
        "CallFun=lua_system.clear_app_cache&CallArg="
    );
end;

--[[清除客户端缓存]]
function lua_system.clear_app_cache()
    --生产环境不使用
    if systemTable["EnvAllowDebug"] == "true" then
        if platform == "iPhone OS" then
            ryt:clear_app_cache();
            alert_confirm("","清理成功","","关闭程序","do_closeApp");
        else
            alert("Android设备请至系统设置-应用管理中清理缓存");
        end;
    end;
end;

--[[
    获取客户端Html内核
      ·webviewLife（默认系统内核）
      ·webviewX5（X5内核）
]]
function lua_system.webview_core()
    --默认系统内核
    local WebviewType = "webviewLife";

    --Android客户端提供了检查X5是否加载成功的回调，在外网访问时，检查X5是否加载成功，满足条件使用X5内核
    if platform == "Android" then
        if systemTable["PublicNetHost"]=="true" then
            local status = formatNull(ryt:get_X5Core_status());
            if status == "true" then
                WebviewType = "webviewX5";
            end;
        end;
    end;

    return WebviewType;
end;

--[[文件下载]]
function lua_system.download_file(dlurl)
    local dlurl = formatNull(dlurl);
    if dlurl ~= "" then
        system:openURL(dlurl);
    end;
end;

--[[用浏览器打开]]
function lua_system.open_by_browser(url)
    local url = formatNull(url);
    if url ~= "" then
        system:openURL(url);
    end;
end;

--[[
    图片预览，参数格式json
    ImageCounts : 图片张数
    ImageLists  : 图片集合
      · ImageSeq   : 图片序号
      · ImageDLUrl : 图片下载链接
]]
function lua_system.image_preview(arg)
    local arg = formatNull(arg);
    arg = json2table(arg);
    local PCConfigListsTable = vt("PCConfigListsTable",globalTable);
    --是否启动水印
    local IMG0015 = vt("IMG0015",PCConfigListsTable);
    --水印样式
    local waterMarkValue = "";
    if IMG0015 == "是" then
        --获取当前日期
        local nowTime = os.time();
        local nowDate = os.date("%Y-%m-%d",nowTime);
        --获取工号
        local workID = globalTable["workid"];
        --获取所属公司名称
        local unitname = globalTable["selectOrgList"][1]["unitname"];
        waterMarkValue = unitname.." "..nowDate.." "..workID;
    end;
    arg["waterMarkValue"] = waterMarkValue;
    arg["waterMarkColor"] = "#8B8B8B";
    arg = table2json(arg);
    if arg ~= "" then
        ryt:image_preview(arg);
    end;
end;

--[[预览单张图片]]
function lua_system.view_single_image(dlLink)
    local previewImageTableArg = {
        ImageCounts = "1",
        ImageLists = {
            {
                ImageSeq = "1",
                ImageDLUrl = dlLink
            }
        }
    };
    --debug_alert(table2json(previewImageTableArg));
    lua_system.image_preview(table2json(previewImageTableArg));
end;

--[[####################发布消息弹窗-Begin####################]]

--[[显示发布消息弹窗]]
function lua_system.open_msg_popup(popupJsonArg,backFunName)
    --[[debug_alert(
        "显示发布消息弹窗\n"..
        "参数 : "..popupJsonArg.."\n"..
        "返回 : "..backFunName.."\n"..
        ""
    );]]
    --默认系统函数，可以重写
    local backFunName = formatNull(backFunName,"lua_system.close_msg_popup");
    set_android_Physical_back(backFunName);

    --更新状态
    msg_popup_status = "open";
    --判断app最低版本支持
    local appSupportInfo = lua_ota.version_support("ryt:msg_popup_ctrl");
    local appSupport = vt("appSupport",appSupportInfo);
    local appSupportTipMsg = vt("appSupportTipMsg",appSupportInfo);

    --[[debug_alert(
        "appSupport : "..appSupport.."\n"..
        "appSupportTipMsg : "..appSupportTipMsg.."\n"..
        ""
    );]]

    --版本支持判断
    if appSupport == "false" then
        --debug_alert("该版本不支持弹窗，不调用，直接处理后续任务");
        lua_mission.index_handle();
    else
        ryt:msg_popup_ctrl("open",popupJsonArg);
    end;
end;

--[[关闭发布消息弹窗]]
function lua_system.close_msg_popup(backFunName)
    --[[debug_alert(
        "关闭发布消息弹窗\n"..
        "返回 : "..backFunName.."\n"..
        ""
    );]]

    --默认系统函数，可以重写
    local backFunName = formatNull(backFunName,"back_fun");
    set_android_Physical_back(backFunName);

    --更新状态
    msg_popup_status = "close";
    ryt:msg_popup_ctrl("close","");

    --关闭时回调任务处理
    lua_mission.index_handle();
end;

--[[
    发布消息弹窗点击回调
    ClickFlag-点击类型, ClickArg-操作参数
      · "Close", ""         : 关闭弹窗不带参
      · "Detail", ItemIndex : 点击查看详情，参数为点击条目的json对象的下标
      · "CheckBox", "0"/"1" : 点击提示信息复选框，参数为点击状态(0未选中，1选中)
]]
function lua_system.msg_popup_call(ClickFlag,ClickArg)
    local ClickFlag = formatNull(ClickFlag);
    local ClickArg = formatNull(ClickArg);

    local call_debug_msg = 
        "发布消息弹窗点击回调\n"..
        "点击类型 : "..ClickFlag.."\n"..
        "点击参数 : "..ClickArg.."\n"..
        "";
    --debug_alert(call_debug_msg);

    --控件交互的具体实现，目前控件只用到首页发布消息弹出，后续如果需要复用，可以通过客户端参数路由
    if ClickFlag == "Close" then
        --发布消息弹窗关闭实现
        lua_index_mission.msg_popup_close_call(ClickArg);
    elseif ClickFlag == "Detail" then
        --发布消息弹窗点击详情实现
        lua_index_mission.msg_popup_click_call(ClickArg);
    elseif ClickFlag == "CheckBox" then
        --发布消息弹窗复选框操作实现
        lua_index_mission.msg_popup_checkbox_call(ClickArg);
    else
        debug_alert("未定义的操作类型");
    end;
end;

--[[####################发布消息弹窗-End####################]]

--[[
    APP弹出菜单
    menu_info_list   : 业务菜单配置列表
    cancel_menu_info : 取消菜单配置
    菜单配置参数说明
      ·title : 菜单标题
      ·tip   : 菜单注解
      ·fun   : 菜单点击函数名
      ·arg   : 菜单点击函数入参
    bg_click_fun : 背景点击方法
    bg_click_arg : 背景点击参数
]]
function lua_system.app_alert_menu(jsonArg)
    if formatNull(jsonArg) ~= "" then
        menu_alert_status = "open";
        picker:app_alert_menu(jsonArg);
    end;
end;

--[[关闭APP弹出菜单]]
function lua_system.close_app_alert_menu()
    menu_alert_status = "close";
    picker:close_app_alert_menu();
end;

--[[调用相机]]
function lua_system.open_camera(CallTableArg)
    local doFlag = vt("doFlag",CallTableArg);
    if doFlag == "Upload" then
        --清理上传缓存参数
        lua_upload.clear_upload_cache_arg();
    end;

    local UseTableArg = lua_system.pic_upload_arg_prepare(CallTableArg);
    --debug_alert("调用相机，参数"..foreach_arg2print(UseTableArg));

    local JsonArg = table2json(UseTableArg);
    if formatNull(JsonArg) ~= "" then
        picker:open_camera(JsonArg);
    end;
end;

--[[调用相册]]
function lua_system.open_album(CallTableArg)
    local doFlag = vt("doFlag",CallTableArg);
    if doFlag == "Upload" then
        --清理上传缓存参数
        lua_upload.clear_upload_cache_arg();
    end;

    local UseTableArg = lua_system.pic_upload_arg_prepare(CallTableArg);
    --debug_alert("调用相册，参数"..foreach_arg2print(UseTableArg));

    local JsonArg = table2json(UseTableArg);
    if formatNull(JsonArg) ~= "" then
        picker:open_album(JsonArg);
    end;
end;

--[[调用相机拍摄]]
function lua_system.open_camera_shoot(CallTableArg)
    local doFlag = vt("doFlag",CallTableArg);
    if doFlag == "Upload" then
        --清理上传缓存参数
        lua_upload.clear_upload_cache_arg();
    end;

    local MatchRes = lua_system.check_app_func("picker_open_camera_shoot");
    if MatchRes == "true" then
        local UseTableArg = CallTableArg;
        local JsonArg = table2json(UseTableArg);
        if formatNull(JsonArg) ~= "" then
            picker:open_camera_shoot(JsonArg);
        end;
    else
        --更新提示
        local upverArg = {
            updateType="OPTION",
            updateMsg="上传视频需要升级，请更新后使用。"
        };
        lua_ota.show_upvsr_view(upverArg);
    end;    
end;

--[[调用相册选择视频]]
function lua_system.open_album_video(CallTableArg)
    local doFlag = vt("doFlag",CallTableArg);
    if doFlag == "Upload" then
        --清理上传缓存参数
        lua_upload.clear_upload_cache_arg();
    end;

    local MatchRes = lua_system.check_app_func("picker_open_album_video");
    if MatchRes == "true" then
        local UseTableArg = CallTableArg;
        local JsonArg = table2json(UseTableArg);
        if formatNull(JsonArg) ~= "" then
            picker:open_album_video(JsonArg);
        end;
    else
        --更新提示
        local upverArg = {
            updateType="OPTION",
            updateMsg="上传视频需要升级，请更新后使用。"
        };
        lua_ota.show_upvsr_view(upverArg);
    end;
end;

--[[
    图片上传参数预处理，上传需要用到的参数，和doFlag参数同级
    uploadFlag    : 后台获取的上传类型，用于区分上传资源使用的业务
    compressStyle : 压缩类型，默认Min [No不压缩，Min最小压缩（头像），Normal正常压缩（发票）]
    maxSize       : 单张照片最大尺寸，单位M
    maxSizeTip    : 单张照片超过尺寸的提示
    splitsize     : 客户端拆包的单个包大小
    uploadtimeout : 客户端上传单个包的超时时间，单位秒
    callback      : 上传完成的LUA回调方法
    params1       : 上传请求上送时，向后台上送的预留参数1
    params2       : 上传请求上送时，向后台上送的预留参数2
    params3       : 上传请求上送时，向后台上送的预留参数3
]]
function lua_system.pic_upload_arg_prepare(CallTableArg)
    local UploadTableArg = formatNull(CallTableArg);
    local splitsize = "";
    if platform == "iPhone OS" then
        splitsize = C_ClientUploadSplitSize_iPhone;
    else
        splitsize = C_ClientUploadSplitSize_Android;
    end;

    --上传参数缺省处理
    if vt("params1",UploadTableArg) == "" then
        UploadTableArg["params1"] = "";
    end;
    if vt("params2",UploadTableArg) == "" then
        UploadTableArg["params2"] = "";
    end;
    if vt("params3",UploadTableArg) == "" then
        UploadTableArg["params3"] = "";
    end;
    if vt("maxSize",UploadTableArg) == "" then
        --单张照片最大尺寸默认10M
        UploadTableArg["maxSize"] = "10";
    end;
    if vt("maxSizeTip",UploadTableArg) == "" then
        UploadTableArg["maxSizeTip"] = "相片尺寸大于"..vt("maxSize",UploadTableArg).."M，不能上传";
    end;
    if vt("splitsize",UploadTableArg) == "" then
        UploadTableArg["splitsize"] = splitsize;
    end;
    if vt("uploadtimeout",UploadTableArg) == "" then
        UploadTableArg["uploadtimeout"] = "30";
    end;

    return UploadTableArg;
end;

--[[
    客户端附件上传控件
    UploadTableArg    : 调用控件的参数，json格式
        pagetitle     : Android的界面标题，iOS系统应用不可修改
        uploadtype    : 上传类型 single 单个选择， multiple 批量选择， singleauto 自动上传一个，用于app打开文件
          ·sa-filename : uploadtype为singleauto时，客户端通过系统接口通知LUA文件名，取出后，回传给客户端
          ·sa-filepath : uploadtype为singleauto时，客户端通过系统接口通知LUA文件路径，取出后，回传给客户端
        counts        : 客户端可以选择的文件数上限
        countsmsg     : 客户端选择文件超限报错信息
        filetype      : 文件类型，以半角逗号分隔，例"pdf,ofd"
        filetypemsg   : 文件类型不支持时，提示信息
        maxlen        : 单个文件的最大尺寸，单位kb
        maxlenmsg     : 单个文件的最大尺寸超限报错信息
        callfun       : 上传后客户端回调lua方法名
        splitsize     : 客户端拆包的单个包大小
        uploadtimeout : 客户端上传单个包的超时时间，单位秒

        上传的http请求参数（客户端调用后台的http上传接口的参数） : 
        uploadflag   : 后台接收的上传类型，入参名flag
        params1      : 后台接收的预留参数1，入参名params1
        params2      : 后台接收的预留参数2，入参名params2
        params3      : 后台接收的预留参数3，入参名params3
        fileName     : 后台接收的文件名，入参名fileName，例"test.pdf"

    SuccessCallFun   : 上传完成的回调，不支持传参
    CheckFileSupport : 是否检查文件系统，手动选择需要检查，自动上传无需检查
]]
function lua_system.client_file_upload(UploadTableArg, SuccessCallFun, CheckFileSupport)
    local UploadTableArg = formatNull(UploadTableArg);
    local splitsize = "";
    local maxlen = "";
    if platform == "iPhone OS" then
        splitsize = C_ClientUploadSplitSize_iPhone;
        maxlen = C_UploadMaxKbSize_iPhone;
    else
        splitsize = C_ClientUploadSplitSize_Android;
        maxlen = C_UploadMaxKbSize_Android;
    end;

    --上传参数缺省处理
    if vt("maxlen",UploadTableArg) == "" then
        UploadTableArg["maxlen"] = maxlen;
    end;
    if vt("maxlenmsg",UploadTableArg) == "" then
        UploadTableArg["maxlenmsg"] = C_UploadMaxTipMsg;
    end;
    if vt("splitsize",UploadTableArg) == "" then
        UploadTableArg["splitsize"] = splitsize;
    end;
    if vt("uploadtimeout",UploadTableArg) == "" then
        UploadTableArg["uploadtimeout"] = "30";
    end;
    if vt("params1",UploadTableArg) == "" then
        UploadTableArg["params1"] = "";
    end;
    if vt("params2",UploadTableArg) == "" then
        UploadTableArg["params2"] = "";
    end;
    if vt("params3",UploadTableArg) == "" then
        UploadTableArg["params3"] = "";
    end;

    local fileSupport = formatNull(systemTable["phoneInfo"].fileSupport);
    local CheckFileSupport = formatNull(CheckFileSupport,"true");

    if CheckFileSupport=="true" and platform=="iPhone OS" and fileSupport=="false" then
        alert("访问文件应用需要iOS11.0或更高系统版本。");
    else
        --存储成功回调函数
        globalTable["ClientFileUploadSuccessCallFun"] = SuccessCallFun;

        --debug_alert("调用文件系统上传，参数"..foreach_arg2print(UploadTableArg));
        local UploadJsonArg = table2json(UploadTableArg);
        ryt:upload_client_file(UploadJsonArg);
    end;
end;

--[[文件预览]]
function lua_system.file_preview(previewUrl,fileType)
    --[[debug_alert(
        "file_preview\n"..
        "previewUrl : "..previewUrl.."\n"..
        "fileType : "..fileType.."\n"..
        ""
    );]]

    if fileType=="png" or fileType=="jpg" or fileType=="jpeg" then
        --debug_alert("调用客户端图片预览控件");

        local previewImageTableArg = {
            ImageCounts = "1",
            ImageLists = {
                {
                    ImageSeq = "1",
                    ImageDLUrl = previewUrl
                }
            }
        };
        --debug_alert(table2json(previewImageTableArg));
        lua_system.image_preview(table2json(previewImageTableArg));
    elseif fileType == "pdf" then
        --debug_alert("调用客户端pdf预览控件");

        local openPdfArg = {
            pdfLinkUrl=previewUrl,
            pdfPageTitle="查看发票"
        };
        lua_system.view_file_by_webview(openPdfArg);
    elseif fileType == "ofd" then
        lua_system.alert_webview(
            {
                title = "文件预览",
                visit_url = previewUrl,
                close_call_func="",
                back_type = "BACK",
                listen_url = "http://app_h5_callback_url",
                listen_call = "lua_system.webview_h5_callback"
            }
        );
    end;
end;

--[[
    批量关闭app弹出界面
    应用场景
    1、 app超时后，需要关闭弹出菜单或窗口
    2、 app有上传任务时，从后台切到前台，需要关闭弹出菜单或窗口
]]
function lua_system.batch_close_app_alert_window()
    --debug_alert("批量关闭app弹出界面");

    --当页面有弹出菜单时，关闭
    if menu_alert_status == "open" then
        lua_system.close_app_alert_menu();
    end;

    --当页面有发布消息弹窗时，关闭
    if msg_popup_status == "open" then
        lua_system.close_msg_popup();
    end;
end;

--[[webview回调url监听]]
function lua_system.webview_h5_callback(url)
    local callbackUrl = formatNull(url);
    --debug_alert("webview回调url监听地址 : \n"..callbackUrl);
    if callbackUrl ~= "" then
        local argTable = lua_format.url_arg2table(callbackUrl);
        --debug_alert("webview回调url监听参数列表 : "..foreach_arg2print(argTable));

        --约定的回调标签，用于区分业务类型
        local CallFlag = vt("CallFlag",argTable);

        if CallFlag == "UseCarSelectCity" then
            --debug_alert("用车-通过H5选择城市");
            lua_car.use_car_selectCity(argTable);
        elseif CallFlag == "EJYH5Back2JJBX" then
            --debug_alert("采购-提交订单后对端关闭H5");
            lua_system.do_function("ejy_h5_back2jjbx_call");
        elseif CallFlag == "EatMtH5OpenJJBXScanWidgetToPay" then
            --debug_alert("用餐-美团-打开扫码控件扫码支付");
            lua_system.do_function("lua_eat.scan_to_pay",argTable);
        end;
    else
        --debug_alert("webview正常关闭");
    end;
end;

--[[调用客户端控件选择日期区间]]
function lua_system.select_interval_date(arg)
    --开始日期
    local startDate = formatNull(arg["startDate"]);
    --结束日期
    local endDate = formatNull(arg["endDate"]);
    --最大可选天数
    local maxDayCounts = formatNull(arg["maxDayCounts"],"365");
    --最大加载月数
    local maxMonthCounts = formatNull(arg["maxMonthCounts"],"12");
    --确定按钮回调方法
    local callbackFunc = formatNull(arg["callbackFunc"]);
    --标题
    local title = formatNull(arg["title"],"请选择时间");

    --[[debug_alert(
        "调用客户端控件选择日期区间\n"..
        "startDate : "..startDate.."\n"..
        "endDate : "..endDate.."\n"..
        "maxDayCounts : "..maxDayCounts.."\n"..
        "maxMonthCounts : "..maxMonthCounts.."\n"..
        "callbackFunc : "..callbackFunc.."\n"..
        "title : "..title.."\n"..
        ""
    );]]
    jjbx:showMealTime(startDate,endDate,maxDayCounts,maxMonthCounts,callbackFunc,title);
end;

--[[弹出webview界面]]
function lua_system.alert_webview(alertWebviewArg)
    local alertWebviewArg = formatNull(alertWebviewArg);

    --界面标题
    local title = vt("title",alertWebviewArg);
    --访问地址
    local visit_url = vt("visit_url",alertWebviewArg);
    --监听地址
    local listen_url = vt("listen_url",alertWebviewArg);
    --监听回调
    local listen_call = vt("listen_call",alertWebviewArg);
    --关闭方法
    local close_call_func = vt("close_call_func",alertWebviewArg);
    --关闭参数
    local close_call_arg = vt("close_call_arg",alertWebviewArg);
    --是否添加关闭按钮（左上角返回按钮旁边添加一个X关闭按钮、Close：不显示按钮、 BACK： 显示按钮）
    local back_type = vt("back_type",alertWebviewArg,"CLOSE");
    --是否显示进度条
    local progress_bar = vt("progress_bar",alertWebviewArg,"true");
    --右侧按钮文字
    local RightLabelText = vt("RightLabelText",alertWebviewArg);
    --右侧按钮方法
    local RightLabelFunc = vt("RightLabelFunc",alertWebviewArg);
    --右侧按钮点击是否关闭控件
    local RightLabelClickClose = vt("RightLabelClickClose",alertWebviewArg,"false");
    --下载文件名
    local preview_file_name = vt("preview_file_name",alertWebviewArg);
    --当前webview控件试图打开外部浏览器时，是否关闭当前视图，iOS适用
    local OpenBrowserCloseWebview = vt("OpenBrowserCloseWebview",alertWebviewArg);
    --追加的UserAgent
    local AddUserAgent = vt("AddUserAgent",alertWebviewArg);
    --被打开的H5是否有定位请求
    local location = vt("location",alertWebviewArg,"false");

    --除生产环境外其他环境开启调试
    if systemTable["EnvAllowDebug"] == "true" then
        --将访问链接拷贝到剪贴板
        lua_system.copy_to_paste(visit_url);

        --将链接缓存
        local DebugReqParams = {
            DebugFlag="CacheH5Url",
            H5Url=visit_url
        };
        lua_debug.app_debug("",DebugReqParams);
    end;

    --H5访问数据上报
    local reportArg = {
        Event="JJBXAppOpenHtml",
        PageUrl=visit_url,
        PageName=title
    };
    lua_system.sensors_report(reportArg);

    local previewArg = {    
        listen_call_url = listen_url,
        listen_call_fun = listen_call,
        close_call_func = close_call_func,
        close_call_arg = close_call_arg,
        back_type = back_type,
        progress_bar="true",
        file_download_text=RightLabelText,
        file_download_func=RightLabelFunc,
        file_download_close=RightLabelClickClose,
        AddUserAgent=AddUserAgent,
        location = location
    };
    --debug_alert("弹出webview界面"..foreach_arg2print(previewArg));
    if platform == "iPhone OS" then
        previewArg["webview_page_title"] = title;
        previewArg["webview_page_url"] = visit_url;
        previewArg["OpenBrowserCloseWebview"] = OpenBrowserCloseWebview;
        ryt:h5_preview_file(table2json(previewArg));
    else
        previewArg["preview_page_title"] = title;
        previewArg["preview_file_url"] = visit_url;
        previewArg["preview_file_name"] = preview_file_name;
        ryt:x5_preview_file(table2json(previewArg));
    end;
end;

--[[
    拼接客户端选择控件数据（一级，只涉及父级）
    涉及控件
        ·incomeexpenditureView
        ·reimbursementScenarioView
]]
function lua_system.select_widget_parent_data(dataArg)
    --debug_alert("render_single_select_widget_data arg :\n"..foreach_arg2print(dataArg));
    local tableArg = {};
    for key,value in pairs(dataArg) do
        local dataCode = dataArg[key]["dataCode"];
        local dataName = dataArg[key]["dataName"];

        --[[debug_alert(
            "dataCode : "..dataCode.."\n"..
            "dataName : "..dataName.."\n"..
            ""
        );]]

        local addTable = {
            parent={dataCode},
            contentcode=dataCode,
            supContent="-1",
            channels="",
            channel={
                parent={dataCode},
                contentcode=dataCode,
                hasChildren="0",
                supContent="-1",
                contentname=dataName
            }
        };
        table.insert(tableArg,addTable);
    end;
    return table2json(tableArg);
end;

--[[客户端加载服务端信息]]
function lua_system.load_app_config()
    local serverInfoTable = {
        --文本域输入限制字符
        textarea_disenable_input_char=lua_format.base64_encode("[]`~!#$%^*+=|{}''\\[\\]<>~#￥%…&*——+|{}【】‘’～＃％＊（）－＝＋、｜［］｛｝；：”“《》/"),
        --附件预览图标配置（仅Android使用）
        upload_file_view_icon_info={
            pdf="file_pdf_icon.png",
            ofd="file_ofd_icon.png",
            xls="file_excel_icon.png",
            xlsx="file_excel_icon.png",
            doc="file_word_icon.png",
            docx="file_word_icon.png",
            ppt="file_ppt_icon.png",
            pptx="file_ppt_icon.png",
            eml="file_eml_icon.png",
            zip="file_zip_icon.png",
            rar="file_rar_icon.png",
            other="file_other_icon.png"
        },
        --下载支持类型
        webview_download_support_file="ofd,eml,zip,rar,mp4,png",
        --预览支持类型
        webview_view_support_file="pdf,doc,docx,xls,xlsx,ppt,pptx,txt,xml"
    };
    local serverInfoJson = table2json(serverInfoTable);

    --调用客户端加载
    --[[debug_alert(
        "调用客户端加载\n"..
        "serverInfoJson : "..serverInfoJson.."\n"..
        ""
    );]]
    ryt:load_app_config(serverInfoJson);

    --标记加载结果
    systemTable["LoadAppConfigRes"] = "true";
end;

--[[获取设备名称]]
function lua_system.get_device_name()
    local DeviceName = "";
    if platform =="iPhone OS" then
        --iOS直接获取
        DeviceName = system:getInfo("name");
    else
        --Android获取通过蓝牙名称获取
        DeviceName = ryt:getDeviceName();
    end;

    --存储至系统缓存
    systemTable["phoneInfo"]["deviceName"] = DeviceName;

    return formatNull(DeviceName);
end;

--[[键盘回收并调用回调]]
function lua_system.hide_keyboard(arg)
    --回收键盘后的回调方法
    local CallFun = vt("CallFun",arg,"undefined_fun");
    --默认100ms延时
    local DelayTime = vt("DelayTime",arg,"100");

    --版本控制
    local appSupportInfo = lua_ota.version_support("ryt:hideKeyBoard");
    local appSupport = vt("appSupport",appSupportInfo);
    if appSupport == "false" then
        --debug_alert("不支持直接调用回调");
        lua_system.do_function(CallFun,"");
    else
        ryt:hideKeyBoard(CallFun, DelayTime);
    end;
end;

--[[获取设备ID]]
function lua_system.get_deviceId()
    local deviceIDRes = "";

    --从本地数据库获取
    local LocalDeviceID = get_db_value("SaveDeviceId");

    if LocalDeviceID == "" then
        --debug_alert("本地未存储设备ID");

        --从客户端API获取
        local AppDeviceID = formatNull(system:getInfo("deviceID"));

        if AppDeviceID == "" then
            --debug_alert("客户端API未获取到");

            --自建一个设备ID并存储
            local timestampStr = tostring(os.time());
            local randomStr = tostring(math.random(0,10000000));
            local AddLocalDeviceID = timestampStr..randomStr;
            set_db_value("SaveDeviceId",AddLocalDeviceID);
            deviceIDRes = AddLocalDeviceID;
        else
            --debug_alert("客户端API获取到");

            --存储数据库
            set_db_value("SaveDeviceId",AppDeviceID);
            deviceIDRes = AppDeviceID;
        end;
    else
        --debug_alert("优先获取本地存储的设备ID");

        deviceIDRes = LocalDeviceID;
    end;

    --[[debug_alert(
        "获取设备ID\n"..
        "数据库 : "..formatNull(LocalDeviceID).."\n"..
        "客户端 : "..formatNull(AppDeviceID).."\n"..
        "返回 : "..formatNull(deviceIDRes).."\n"..
        ""
    );]]

    return deviceIDRes;
end;

--[[获取地图当前定位图片下载地址]]
function lua_system.get_map_mark_pic_dlurl(Arg)
    --debug_alert("获取地图当前定位图片下载地址"..foreach_arg2print(Arg));

    --返回地址
    local mark_pic_dlurl = "";
    --web地图地址
    local WebMapApiUrl = vt("WebMapApiUrl",configTable);
    --经度（优先从调用处获取）
    local Longitude = formatNull(vt("Longitude",Arg),vt("location_longitude",systemTable));
    --纬度（优先从调用处获取）
    local Latitude = formatNull(vt("Latitude",Arg),vt("location_latitude",systemTable));
    --图片宽度
    local MapPicWidth = vt("MapPicWidth",Arg);
    --图片高度
    local MapPicHeight = vt("MapPicHeight",Arg);
    --坐标类型（调用指定）
    local MapCoordType = vt("MapCoordType",Arg);

    local MapUrlArgTable = {
        WebMapApiUrl,
        Longitude,
        Latitude,
        MapPicWidth,
        MapPicHeight
    };
    local argCheckRes = lua_form.arglist_check_empty(MapUrlArgTable);
    if argCheckRes == "true" then
        --坐标类型（自动分析）
        local AutoCoordType = "";
        if platform == "iPhone OS" then
            --GPS坐标系
            AutoCoordType = "wgs84ll";
        else
            --百度坐标系
            AutoCoordType = "bd09ll";
        end;

        --百度地图
        --[[mark_pic_dlurl =
            WebMapApiUrl..
            "&center="..Longitude..","..Latitude..
            "&width="..MapPicWidth..
            "&height="..MapPicHeight..
            "&dpiType=ph"..
            "&scale=2"..
            "&zoom=16"..
            "&coordtype="..formatNull(MapCoordType,AutoCoordType)..
            "";]]

        --高德地图
        mark_pic_dlurl = 
            WebMapApiUrl..
            "&location="..Longitude..","..Latitude..
            "&zoom=17"..
            "&size="..MapPicWidth.."*"..MapPicHeight..
            "&markers=mid,,A:"..Longitude..","..Latitude..
            "&scale=2"..
            "";
    end;

    --返回
    return mark_pic_dlurl;
end;

--[[操作和客户端协议的数据存储-获取]]
function lua_system.get_client_dbvalue(DBKey)
    local GetArg = {
        Ctrl="GET",
        Key=DBKey
    };
    local res = ryt:client_database_ctrl(table2json(GetArg));
    return res;
end;

--[[操作和客户端协议的数据存储-设置]]
function lua_system.set_client_dbvalue(DBKey,DBValue)
    local SetArg = {
        Ctrl="SET",
        Key=DBKey,
        Value=DBValue
    };
    local res = ryt:client_database_ctrl(table2json(SetArg));
    return res;
end;

--[[启动应用监听]]
function lua_system.start_app_listener(Arg)
    local listenerTableArg = {
        --监听名称，后续可以用于回收关闭
        listenerName=vt("listenerName",Arg),
        --监听类型 屏幕监听:ScreenShortCut
        listenerType=vt("listenerType",Arg),
        --监听器控制类型 启动:START 关闭:STOP
        listenerCtrlType="START",
        --监听器控制回调方法名称
        listenerCtrlCallFun="lua_system.AppListenerCtrlCall",
        --监听器控制回调方法参数，直接传递整个json
        listenerCtrlCallArg={
            listenerCtrlType="START"
        },
        --监听回调方法名称
        listenerCallFun="lua_system.AppListenerCall",
        --监听回调方法参数，直接传递整个json
        listenerCallArg={
            listenerCallFunc=vt("listenerCallFunc",Arg),
            listenerCallArg=vt("listenerCallArg",Arg)
        }
    };
    lua_system.app_listener_ctrl(listenerTableArg);
end;

--[[关闭应用监听]]
function lua_system.stop_app_listener(Arg)
    local listenerTableArg = {
        --监听名称，后续可以用于回收关闭
        listenerName=vt("listenerName",Arg),
        --监听类型 屏幕监听:ScreenShortCut
        listenerType=vt("listenerType",Arg),
        --监听器控制类型 启动:START 关闭:STOP
        listenerCtrlType="STOP",
        --监听器控制回调方法名称
        listenerCtrlCallFun="lua_system.AppListenerCtrlCall",
        --监听器控制回调方法参数，直接传递整个json
        listenerCtrlCallArg={
            listenerCtrlType="STOP"
        },
        --监听回调方法名称
        listenerCallFun="lua_system.AppListenerCall",
        --监听回调方法参数，直接传递整个json
        listenerCallArg={
            listenerCallFunc=vt("listenerCallFunc",Arg),
            listenerCallArg=vt("listenerCallArg",Arg)
        }
    };
    lua_system.app_listener_ctrl(listenerTableArg);
end;

--[[应用监听器控制]]
function lua_system.app_listener_ctrl(listenerTableArg)
    --debug_alert("应用监听器控制"..foreach_arg2print(listenerTableArg));

    local appSupportInfo = lua_ota.version_support("ryt:app_listener_ctrl");
    local appSupport = vt("appSupport",appSupportInfo);
    --版本支持判断
    if appSupport == "false" then
        --debug_alert("不支持截屏监听，暂不处理");
    else
        local listenerJsonArg = table2json(listenerTableArg);
        --调用客户端应用监听器控制方法
        ryt:app_listener_ctrl(listenerJsonArg);
    end;
end;

--[[客户端监听回调]]
function lua_system.AppListenerCall(CallArgJson)
    local TableArg = json2table(CallArgJson);

    --[[debug_alert(
        "ScreenShortCutListenerCall\n"..
        "CallArgJson : "..CallArgJson.."\n"..
        "TableArg : "..foreach_arg2print(TableArg).."\n"..
        ""
    );]]

    listenerCallFunc=vt("listenerCallFunc",TableArg);
    listenerCallArg=vt("listenerCallArg",TableArg);

    lua_system.do_function(listenerCallFunc,listenerCallArg);
end;

--[[客户端监听控制（启动/关闭）回调]]
function lua_system.AppListenerCtrlCall(CallArgJson)
    --[[debug_alert(
        "AppListenerCtrlCall\n"..
        "CallArgJson : "..CallArgJson.."\n"..
        ""
    );]]
end;

--[[检查lua是否可用]]
function lua_system.check_app_func(luaID)
    local appSupportInfo = lua_ota.version_support("ryt:app_project_info");
    --debug_alert("检查lua是否可用"..foreach_arg2print(appSupportInfo));

    local appSupport = vt("appSupport",appSupportInfo);
    local MatchRes = "false";

    --版本支持判断
    if appSupport == "true" then
        --从客户端获取lua信息
        local AppProjectInfoJson = ryt:app_project_info("");
        local AppProjectInfoTable = json2table(AppProjectInfoJson);
        local LuaFunction = vt("LuaFunction",AppProjectInfoTable);
        local LoopCounts = #LuaFunction;

        --[[debug_alert(
            "检查lua是否可用\n"..
            "appSupportInfo : "..foreach_arg2print(appSupportInfo).."\n\n"..
            "LoopCounts : "..tostring(LoopCounts).."\n"..
            "AppProjectInfoJson : "..AppProjectInfoJson.."\n\n"..
            "LuaFunction : "..foreach_arg2print(LuaFunction).."\n\n"..
            ""
        );]]

        --当前受检查的lua函数
        local luaID = formatNull(luaID);
        for i=1,LoopCounts do
            local InfoData = formatNull(LuaFunction[i]);
            local AppFuncName = vt("FuncName",InfoData);
            local ServerFuncName = vt("FuncName",C_SYSTEM_LUA_INFO[luaID]);

            --[[debug_alert(
                "开始检查\n"..
                "检查的LUA ID : "..luaID.."\n"..
                "检查的LUA 名 : "..ServerFuncName.."\n"..
                "客户端LUA 名 : "..AppFuncName.."\n"..
                ""
            );]]

            if AppFuncName == ServerFuncName then
                MatchRes = "true";
                break
            end;
        end;
    end;

    return MatchRes;
end;

--[[用户数据上报]]
function lua_system.user_data_report(Arg)
    --debug_alert("用户数据上报"..foreach_arg2print(Arg));

    --数据接收者 神策:SensorsData
    local Receiver = vt("Receiver",Arg);

    if Receiver == "SensorsData" then
        if vt("SensorsInstallFlag",systemTable) == "" then
            --检查是否安装神策
            local MatchRes1 = lua_system.check_app_func("picker_sensorsAnalyticsLogin");
            local MatchRes2 = lua_system.check_app_func("picker_sensorsAnalyticsPointTrack");
            if MatchRes1=="true" or MatchRes2=="true" then
                --已安装
                systemTable["SensorsInstallFlag"] = "true";
            else
                --未安装
                systemTable["SensorsInstallFlag"] = "false";
                --debug_alert("APP未集成神策数据采集服务");
            end;
        end;

        if systemTable["SensorsInstallFlag"] == "true" then
            --当前事件
            local Event = vt("Event",Arg);
            --上报数据
            local Data = vt("Data",Arg);
            if Event == "JJBXAppLoginRegister" then
                --调用客户端登记注册接口，向数据收集方说明用户已经登录
                local SensorsLoginId = vt("SensorsLoginId",Data);
                --登记登录状态
                globalTable["SensorsLoginFlag"] = "true";
                --debug_alert("神策登录 : "..SensorsLoginId);
                picker:sensorsAnalyticsLogin(SensorsLoginId);
            else
                local JsonData = table2json(Data);
                --[[debug_alert(
                    "神策上报 : "..foreach_arg2print(Data).."\n"..
                    "JsonData : "..JsonData.."\n"..
                    ""
                );]]
                picker:sensorsAnalyticsPointTrack(Event,JsonData);
            end;
        else
            --debug_alert("APP未集成神策数据采集服务，不进行数据上报");
        end;
    end;
end;

--[[神策登录]]
function lua_system.sensors_login()
    if vt("SensorsLoginFlag",globalTable) ~= "true" then
        --获取神策登录ID
        local SensorsLoginId = lua_system.sensors_login_id();
        if SensorsLoginId ~= "" then
            local UserDataReportLoginArg = {
                Receiver="SensorsData",
                Event="JJBXAppLoginRegister",
                Data={
                    SensorsLoginId=SensorsLoginId
                }
            };
            lua_system.user_data_report(UserDataReportLoginArg);
        else
            --debug_alert("登录信息不完整，无法神策登录");
        end;
    else
        --debug_alert("神策已经登录，无需重复登录");
    end;
end;

--[[获取神策登录ID]]
function lua_system.sensors_login_id()
    --优先取缓存
    local SensorsLoginId = vt("SensorsLoginId",globalTable);
    if SensorsLoginId == "" then
        local orgFlag = vt("orgFlag",globalTable);
        local workid = vt("workid",globalTable);
        if orgFlag~="" and workid~="" then
            if orgFlag == "001" then
                --浙商银行不加机构
                SensorsLoginId = workid;
            else
                SensorsLoginId = orgFlag.."-"..workid;
            end;
        end;
    end;
    return SensorsLoginId;
end;

--[[神策数据上报]]
function lua_system.sensors_report(Arg)
    local SensorsReportStyle = vt("sensors_report_style",configTable);

    --[[debug_alert(
        "神策数据上报"..foreach_arg2print(Arg).."\n"..
        "SensorsReportStyle : "..SensorsReportStyle.."\n"..
        ""
    );]]

    if SensorsReportStyle ~= "" then
        --上报数据
        local Data = {
            SensorsLoginId=lua_system.sensors_login_id(),
            UserName=vt("userName",globalTable),
            WorkId=vt("workid",globalTable)
        };

        --事件类型
        local Event = vt("Event",Arg);
        if Event == "JJBXAppOpenHtml" and string.find(SensorsReportStyle,"01") then
            --打开网页
            Data["ReportExplain"] = "打开网页";
            Data["PageUrl"] = vt("PageUrl",Arg);
            Data["PageName"] = vt("PageName",Arg);
        elseif Event == "JJBXAppOpenAppPage" and string.find(SensorsReportStyle,"01") then
            --打开APP页面
            Data["ReportExplain"] = "打开APP页面";
            Data["PageUrl"] = vt("PageUrl",Arg);
            Data["PageName"] = vt("PageName",Arg);
        elseif Event == "JJBXAppAlertMsg" and string.find(SensorsReportStyle,"02") then
            --APP提示消息
            Data["ReportExplain"] = "APP提示消息";
            Data["AlertMsg"] = vt("AlertMsg",Arg);
        else
            --debug_alert("未定义的数据上报类型");
            return;
        end;

        --数据上报
        local UserDataReportArg = {
            Receiver="SensorsData",
            Event=Event,
            Data=Data
        };
        lua_system.user_data_report(UserDataReportArg);
    else
        --debug_alert("自定义数据上报神策未配置");
    end;
end;

--[[打开摄像头扫码]]
function lua_system.open_scan_by_camera(Arg)
    local MatchRes = lua_system.check_app_func("picker_open_scan_by_camera");
    if MatchRes == "true" then
        local Arg = formatNull(Arg);
        local OpenArg = {
            --返回按钮方法
            BackFunc=vt("BackFunc",Arg),
            --返回按钮方法入参
            BackFuncArg=vt("BackFuncArg",Arg),
            --扫描回调方法，入参1：扫描结果base64编码后的string 入参2：传递ScanCallFuncSetArg参数值
            ScanCallFunc=vt("ScanCallFunc",Arg),
            --扫描回调方法入参
            ScanCallFuncSetArg=vt("ScanCallFuncSetArg",Arg),
            --通过相册选择导入提示
            ScanByAlbumTipText=vt("ScanByAlbumTipText",Arg,"从相册中导入二维码"),
            --提示信息1
            ScanTip1Text=vt("ScanTip1Text",Arg,"请对准二维码进行扫描"),
            --提示信息2
            ScanTip2Text=vt("ScanTip2Text",Arg,"放入框内，自动扫描")
        };
        debug_alert("打开摄像头扫码参数"..foreach_arg2print(OpenArg));
        picker:open_scan_by_camera(table2json(OpenArg));
    else
        debug_alert("未安装扫码功能");
    end;
end;

--查询发票文件信息回调
function lua_system.show_electronic_invoice_detail(ResParams)
    local res = json2table(vt("responseBody",ResParams));
    close_loading();
    if res["errorNo"] == "000000" then
        --获取发票文件类型
        local InvoiceType = vt("InvoiceType",globalTable);
        if InvoiceType == "0133" or InvoiceType == "0135" then
            --火车票
            invoke_page_donot_checkRepeat("jjbx_fpc/xhtml/jjbx_invoice_fileDetail_train.xhtml",page_callback,{invoiceFileDetail=res,InvoiceType=InvoiceType});
        elseif InvoiceType == "0134" then
            --机票
            invoke_page_donot_checkRepeat("jjbx_fpc/xhtml/jjbx_invoice_fileDetail_air.xhtml",page_callback,{invoiceFileDetail=res,InvoiceType=InvoiceType});
        else
            alert("未定义发票文件类型");
        end;
    else
        alert(res["errorMsg"]);
    end;
end;

--根据发票号码和文件路劲查询文件信息
function lua_system.query_invoiceFile_detail(InvoiceType,FileOriginalPath)
    local ReqParams = {};
    globalTable["InvoiceType"] = InvoiceType;
    ReqParams["ReqAddr"] = "electronicInvoice/showElectronicInvoiceDetail";
    ReqParams["ReqUrlExplain"] = "根据发票号码和文件路劲查询文件信息";
    ReqParams["BusinessCall"] = lua_system.show_electronic_invoice_detail;
    local searchBillNo_params = {
        invoiceType = InvoiceType,
        path = FileOriginalPath
    };
    ReqParams["BusinessParams"] = table2json(searchBillNo_params);
    lua_jjbx.common_req(ReqParams);
end;

--消息推送注册成功后通知后台
function lua_system.msgMarsRegister(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        ReqParams["ReqAddr"] = "pubMessageService/msgMarsRegister";
        ReqParams["ReqUrlExplain"] = "消息推送注册成功后通知后台";
        ReqParams["BusinessCall"] = lua_system.msgMarsRegister;
        local MatchRes = lua_system.check_app_func("RYTL_get_push_token");
        local registerToken = "";
        if MatchRes == "true" then
            registerToken = RYTL:get_push_token();
            --debug_alert("消息推送注册Token:"..registerToken);
        else
            --debug_alert("方法未注册");
        end;
        local msgMarsRegister_params = {
            appToken = registerToken
        };
        ReqParams["BusinessParams"] = table2json(msgMarsRegister_params);
        lua_jjbx.common_req(ReqParams);
    else
        local responseBody = json2table(vt("responseBody",ResParams));
        if responseBody["errorNo"] == "000000" then

        else
            alert(responseBody["errorMsg"]);
        end;
    end;
end;

--跳转系统设置界面
function lua_system.checkSystemAuthority()
    local MatchRes = lua_system.check_app_func("RYTL_open_system_settings");
    if MatchRes == "true" then
        RYTL:openSystemSettings();
    else
        --更新提示
        local upverArg = {
            updateType="OPTION",
            updateMsg="查看系统设置需要升级，请更新后使用。"
        };
        lua_ota.show_upvsr_view(upverArg);
    end;
end;