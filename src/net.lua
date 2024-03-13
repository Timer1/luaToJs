--[[请求和页面跳转函数]]

lua_net = {};

--定义请求类型
--page:请求实时页面
--data:请求数据填充离线页面
request_type = "page";
--定义页面下标，用于页面后续关闭操作
loadingtag = 3;
--定义一个缓存table，用于后续请求和跳转的参数封装
tempTable = nil

--请求的状态定义
local INVOKE_STATUS = {
    -- 请求开始，目前无效
    START   = 0,
    -- 请求成功，目前无效
    SUCCESS = 1,
    -- 请求失败
    FAILURE = 2,
    --请求结束，目前无效
    FINISH  = 3,
};

--[[
    ·校验重复点击:是
    ·loading窗口:是
    ·自动关闭loading:默认是，可以通过参数修改
]]
function invoke_trancode(channelId, tranCode, postParams, busiCallback, callbackParams, pagecallback, pagecallbackParams)
    --校验接口短时间重复请求
    if check_repeat_do_request_erl() then
        --默认走all_callback回调
        local pagecallback = formatNull(pagecallback, all_callback);
        show_loading();
        do_invoke_trancode(channelId, tranCode, postParams, busiCallback, callbackParams, pagecallback, pagecallbackParams);
    end;
end;

--[[
    ·校验重复点击:否
    ·loading窗口:是
    ·自动关闭loading:默认是，可以通过参数修改
]]
function invoke_trancode_donot_checkRepeat(channelId, tranCode, postParams, busiCallback, callbackParams, pagecallback, pagecallbackParams)
    --默认走all_callback回调
    local pagecallback = formatNull(pagecallback, all_callback);
    show_loading();
    do_invoke_trancode(channelId, tranCode, postParams, busiCallback, callbackParams, pagecallback, pagecallbackParams);
end;

--[[
    ·校验重复点击:否
    ·loading窗口:否
    ·自动关闭loading:默认是，可以通过参数修改
]]
function invoke_trancode_noloading(channelId, tranCode, postParams, busiCallback, callbackParams, pagecallback, pagecallbackParams)
    --默认走all_callback回调
    local pagecallback = formatNull(pagecallback, all_callback);
    do_invoke_trancode(channelId, tranCode, postParams, busiCallback, callbackParams, pagecallback, pagecallbackParams);
end;

--[[
    ·校验重复点击:是
    ·loading窗口:否
    ·自动关闭loading:默认是，可以通过参数修改
]]
function invoke_trancode_noloading_checkRepeat(channelId, tranCode, postParams, busiCallback, callbackParams, pagecallback, pagecallbackParams)
    --校验接口短时间重复请求
    if check_repeat_do_request_erl() then
        --默认走all_callback回调
        local pagecallback = formatNull(pagecallback, all_callback);
        do_invoke_trancode(channelId, tranCode, postParams, busiCallback, callbackParams, pagecallback, pagecallbackParams);
    end;
end;

----------------erlang接口请求函数---------------
--[[
    说明：
        根据是否为开发模式请求不同数据来源
        如果为开发模式请求接口为page_s/get_page,请求资源为各个channelId文件夹下json文件夹中静态json数据。
        如果为生产模式请求接口为channel_s/run,请求数据资源为业务处理流程中返回json数据。

    参数：
    channelId:
        说明：此业务频道channelId。
        格式：string。
        例子："balance_qry"
    tranCode:
        说明：此业务流程唯一业务标识。
        格式：string。
        例子："MB2010"
    postParams:
        说明：此业务流程请求下个接口所需参数。
        格式：table。
        例子：{tranCode="MB2010",accNo= "62252430987612345"}
    busiCallback:
        说明：post请求的回调方法。
        格式：function 名称。
        例子：funCallback
    callbackParams:
        说明：回调方法所需其他参数。
        格式：table。
        例子：{trancode="mb02",channelId="balance_qry"}
    pagecallback:
        说明：页面回调方法。
        格式：function 名称。
        例子：all_callback
    pagecallbackParams:
        说明：页面回调方法。
        格式：table。
        参数：
            ·CloseLoading "true"关闭加载窗 "false"关闭加载窗
            ·AddPage  "true"压栈 "false"不压栈，json数据包不生效，xml生效
        例子：{CloseLoading="true",AddPage="false"}
    返回：
    一般回调函数实现为跳转入下个界面。
]]
function do_invoke_trancode(channelId, tranCode, postParams, busiCallback, callbackParams, pagecallback, pagecallbackParams)
    --保存invoke_trancode()的五个参数到callbackParams，用以传值给all_callback()来进入页面
    --[[debug_alert(
        "do_invoke_trancode".."\n"..
        "channelId : "..formatNull(channelId).."\n"..
        "tranCode  : "..formatNull(tranCode).."\n"..
        ""
    );]]

    --可调试环境，回调错误时会显示请求信息
    if systemTable["EnvAllowDebug"] == "true" then
        if busiCallback == nil then
            debug_alert(
                "回调未定义".."\n"..
                "频道编号 : "..formatNull(channelId).."\n"..
                "交易代码 : "..formatNull(tranCode).."\n"..
                "请求参数 : "..foreach_arg2print(postParams).."\n"..
                ""
            );
        end;
    end;

    local params = {};
    postParams["id"] = channelId;
    postParams["tranCode"] = tranCode;

    params.channelId = channelId;
    params.tranCode = tranCode;
    params.postParams = postParams;
    params.busiCallback = busiCallback;
    params.callbackParams = callbackParams;
    params.app_callback = busiCallback;
    params.pagecallbackParams = pagecallbackParams;

    --debug_alert("调用客户端post方法参数"..foreach_arg2print(params));

    -- ryt:post接口的params格式{header, url, data, callback, parameters, synchronous}
    local client_post = to_post_body(postParams);
    http:postAsyn(nil, "channel_s/run", client_post, pagecallback, params);
end;

--[[
    说明：
        请求回调
        invoke_trancode中post请求回调方法。
        在此方法中封装错误信息处理方法。
        如果返回responseCode 为1599 则表示会话超时，
        此时返回responseBody为超时界面，后台直接replace即可。
        如果返回responseCode 为200 则表示报文正常返回，
        此时需要判断返回报文为json还是xml数据，如果为xml数据表示在处理过程中出现错误返回，
        将此xml界面直接replace即可弹出错误信息界面。
        在项目中业务流程数据从simulator或者网银app中取回时先进行错误码的判断，如果返回为错误信息，
        则将此业务错误信息throw出来即可。
        返回正常即走正常流程，在xhtml界面报文中只用对正确情况进行处理。
    参数：
    params:
    说明：客户端回调传回table列表。
    格式：table
    例子：{["responseCode"] = 1599,["responseBody"] = "<?xml><content>....</content>"}
    返回：
    如果为会话超时则进入会话超时界面。
    如果为错误信息则会弹出错误信息。
    如果为正常返回则调用正常流程回调方法，此时一般为跳转入下个界面。
]]
function all_callback(params)
    --debug_alert("客户端post方法回调参数"..foreach_arg2print(params));

    local responseCode = formatNull(params["responseCode"]);
    local responseBody = formatNull(params["responseBody"]);
    --[[debug_alert(
        "all_callback".."\n"..
        "responseCode : "..responseCode.."\n"..
        "responseBody : "..responseBody.."\n"..
        ""
    );]]

    --会话超时
    if responseCode == 1599 then
        --超时客户端会在responseBody放置超时的xml报文，走客户端逻辑
        location:replace(responseBody,replace_callback,nil);
    elseif responseCode == 200 then
        local data_type = formatNull(get_format(responseBody));

        --返回为xml
        if data_type == "xml" then
            local pageParams = formatNull(params["pagecallbackParams"]);
            --关闭loading
            local CloseLoading = formatNull(pageParams["CloseLoading"],"true");
            --页面压栈
            local AddPage = formatNull(pageParams["AddPage"],"true");
            --[[debug_alert(
                "all_callback\n"..
                "AddPage:"..AddPage.."\n"..
                "CloseLoading:"..CloseLoading.."\n"..
                ""
            );]]

            local bodyPage = string.find(responseBody,"<body");
            if bodyPage ~= nil then
                --压栈
                if AddPage == "true" then
                    history:add(responseBody);
                end;
            end;
            location:replace(responseBody);
            --关闭loading
            if CloseLoading == "true" then
                close_loading();
            end;
        elseif data_type == "json" then
            need_auth(params);
        else
            invoke_callback_extra(params, INVOKE_STATUS["FAILURE"]);
            debug_alert("数据异常");
            close_loading();
        end;
    else
        invoke_callback_extra(params, INVOKE_STATUS["FAILURE"]);
        close_loading();
        if configTable["lua_debug"] == "true" then
            debug_alert("数据请求异常，请检查网络");
        else
            alert("网络不可用，请检查网络");
        end;
    end;
end;

----------------返回函数---------------
--[[返回到上一个页面]]
function back()
    local page = history:get(-1);
    local afterpage = slt2.render(slt2.loadstring(page),nil);
    location:replace(afterpage, transitionType.slideFromLeft);
end;

--[[跳到指定页面]]
function go_page(index)
    show_loading();
    local page = history:get(index);
    if "iPhone OS" == getInfoPlatForm() then
        local afterpage = slt2.render(slt2.loadstring(page),nil);
        location:replace(afterpage, transitionType.slideFromLeft);
        close_loading();
    else
        local afterpage = slt2.render(slt2.loadstring(page),nil);
        location:replace(afterpage,"", back_callback,{});
    end;
end;

--[[返回后的处理]]
function back_callback(params)
    --关闭加载框
    close_loading();
end;

--[[
    说明：组装网络请求参数
    参数：
    params:
    说明：请求下个接口所需参数列表
    格式：table
    例子：{trancode="mb001",accno= "12314"}

    返回：
    根据table组装成post请求参数，如trancode=mb001&accno=12314
]]
function to_post_body(params)
    local post = "";
    local ret_post;
    if params then
        for key,value in pairs(params) do
            print(key);
            post = post .. key .. "=" ..utility:escapeURI(value) .. "&";
        end;
        ret_post = string.sub(post,1,string.len(post)-1);
    else
        ret_post = "";
    end;
    return ret_post;
end;

--[[说明：判断传入数据的格式为json还是xml。
    正则表达式：^%s*%{ 表示以   {开始的字符串。
            ^<%?xml 表示以<?xml 开始的字符串
    参数：
    params_str:
    说明：需要验证字符串
    格式：string
    例子：{"return":{"error":"000000"}}

    返回：
        如果为json返回"json"。
        如果为xml返回"xml"。
        如果不为这两种则返回nil。
]]
function get_format(paramsStr)
    if string.find(paramsStr,"^%s*%{") ~= nil then
        return "json";
    elseif string.find(paramsStr,"^<%?xml ") ~= nil then
        return "xml"
    else
        return nil;
    end;
end;

--[[返回报文验证]]
function need_auth(params)
    local pageParams = formatNull(params["pagecallbackParams"]);
    --关闭loading
    local CloseLoading = formatNull(pageParams["CloseLoading"],"true");
    --页面压栈
    local AddPage = formatNull(pageParams["AddPage"],"true");

    local ret_data = params["responseBody"];
    local jsonObj = json2table(ret_data);

    local ret_code = jsonObj["errorStatus"];
    local errorMsg = "";
    local errorCode = "";
    if jsonObj["errorMsg"] then
        errorMsg = jsonObj["errorMsg"];
        errorCode = jsonObj["errorNO"];
    end;
    params.callbackParams["responseBody"] = params["responseBody"];
    params.callbackParams["responseCode"] = params["responseCode"];

    --[[debug_alert(
        "all_callback->need_auth\n"..
        "AddPage:"..AddPage.."\n"..
        "CloseLoading:"..CloseLoading.."\n"..
        "ret_code:"..formatNull(ret_code).."\n"..
        ""
    );]]

    if ret_code == "0" then
        --errorStatus=0，返回的是错误流程
        if errorCode=="APP0000" then
            alert("请求失败："..errorMsg);
            close_loading();
        else
            alert(errorMsg);
            close_loading();
            height_adapt("body",0,0);
            return;
        end;
    else
        --errorStatus=1或者不为0时，返回的是正常流程
        --根据参数选择是否关闭loading界面
        if CloseLoading == "true" then
            close_loading();
        end;
        params.app_callback(params.callbackParams);
    end;
end;

--[[错误处理，暂时未用到]]
function errorCodeJudge(errorCode, errorMsg)
    --这里配置错误码对应的回调方法
    local errCodeTable = {
        EC9999 = alertError
    };
    --这里配置错误码对应的错误信息
    local errorMsgTable = {
        EC9999 = "对不起，系统发生未知错误！"
    }

    --逻辑待实现，参考逻辑：
    --存在错误码配置时，弹出报错，点击后调用错误回调方法
    --不存在错误码时，弹出缺省报错
end;

--[[弹出错误信息]]
function alertError(errMsg)
    debug_alert(errMsg);
end;

--[[切换页面回调方法（有实现）]]
function replace_callback(params)
    --[[debug_alert(
        "replace_callback\n"..
        "history:length = "..tostring(history:length()).."\n"..
        "replace_callback params : "..foreach_arg2print(params).."\n"..
        "pageinfoTable Arg\n"..foreach_arg2print(pageinfoTable).."\n"..
        ""
    );]]

    local CloseLoading = vt("CloseLoading",params);
    if CloseLoading == "true" then
        --回调里关闭loading
        close_loading();
    end;
end;

--[[
    请求回调扩展方法
    NOTE:只有当 sendMesName 有值的时候才会有效果
    并且 app_callback 中还需要多加一个参数（之前只有一个params参数），来获取当前请求的状态
    @params params
    @params status 当前请求状态，是 INVOKE_STATUS 其中的一个值 
        INVOKE_STATUS = {
            START = 0,
            SUCCESS = 1,
            FAILURE = 2,
            FINISH = 3,
        }
]]
function invoke_callback_extra(params, stauts)
    if params["sendMsgName"] ~= nil then
        params.app_callback(params.callbackParams, stauts);
    end;
end

--[[
    校验重复点击:是
    开启loading窗口:是
]]
function invoke_page(page_file_path,fun_callback,fun_params)
    --校验页面短时间重复请求
    if check_repeat_do_request_page() then
        show_loading();
        do_invoke_page(page_file_path,fun_callback,fun_params);
    end;
end;

--[[
    校验重复点击:否
    开启loading窗口:是
]]
function invoke_page_donot_checkRepeat(page_file_path,fun_callback,fun_params)
    show_loading();
    do_invoke_page(page_file_path,fun_callback,fun_params);
end;

--[[
    校验重复点击:否
    开启loading窗口:否
]]
function invoke_page_noloading(page_file_path,fun_callback,fun_params)
    do_invoke_page(page_file_path,fun_callback,fun_params);
end;

--[[
    校验重复点击:是
    开启loading窗口:否
]]
function invoke_page_noloading_checkRepeat(page_file_path,fun_callback,fun_params)
    --校验页面短时间重复请求
    if check_repeat_do_request_page() then
        do_invoke_page(page_file_path,fun_callback,fun_params);
    end;
end;

----------------页面请求函数---------------
--[[
    说明：
        根据是否为开发模式获取不同界面资源
        如果为开发模式发送请求page_s/get_page获得ewp服务器上静态界面。
        如果为生产模式直接读取客户端本地离线资源界面。
    参数：
    page_file_path：
        说明：请求界面名称。
        格式：string
        例子：balance_qry/xhtml/balance_qry_mb01.xhtml
    fun_callback:
        说明：post请求回调方法。
        格式：function 名称。
        例子：page_callback
    fun_params:
        说明：请求回调方法时所需参数。
        格式：table
        例子：{trancode="mb01",channelId="balance_qry"}
]]
function do_invoke_page(page_file_path, fun_callback, fun_params)
    --默认使用通用页面回调函数
    local fun_callback = formatNull(fun_callback, page_callback);
    local page_file_path = formatNull(page_file_path);
    local fun_params = formatNull(fun_params,{});

    --计时器注销
    lua_system.timer_unregister();

    --栈值
    local HistoryLength = tonumber(history:length());

    --APP首页和我的页面为底栈，进入这两个页面之前将栈内缓存清空，然后再将底栈入栈
    if page_file_path == "jjbx_index/xhtml/jjbx_index.xhtml" or page_file_path == "jjbx_myInfo/xhtml/myInfo.xhtml" then
        --debug_alert("清空所有栈并将底栈入栈");
        history:clear(HistoryLength);

        if vt("loginSessionid",globalTable) == "" then
            --调用注销
            lua_login.exit_login();
            return;
        end;
    end;

    fun_params["page_file_path"] = page_file_path;

    if request_type == "page" then
        --实时请求
        do_request_page(page_file_path, fun_callback, fun_params);
    else
        --离线请求
        do_request_data(page_file_path, fun_callback, fun_params);
    end;
end;

--[[执行页面请求]]
function do_request_page(page_file_path, fun_callback, fun_params)
    local path = "name="..utility:escapeURI("channels/"..page_file_path);
    ryt:post(nil, "page_s/get_page", path, fun_callback, fun_params, false);
end;

--[[执行离线数据请求]]
function do_request_data(page_file_path, fun_callback, fun_params)
    local response = {};
    local page = nil;

    if file:isExist(page_file_path) then
        --本地存在离线页面文件
        response["responseCode"] = 200;
        page = file:read(page_file_path, "text");
        response["responseBody"] = page;
        fun_callback(response);
    else
        --本地不存在离线页面文件
        --发送实时请求
        do_request_page(page_file_path, fun_callback, fun_params);
        --返回404错误
        --[[response["responseCode"] = 404;
        alert("资源请求失败，请重试！");]]
    end;
end;

--[[
    说明：通用请求获取静态界面回调方法
    参数：
    params：
    说明：客户端post请求回调方法传入参数。
    格式：table
    例子：{["responseCode"] = 200,["responseBody"] = "<?xml><content>..</content>"}
    返回：
    跳转入下个界面，并将此界面加入缓存。
]]
function page_callback(params)
    local params = formatNull(params);
    --debug_alert("通用请求获取静态界面回调方法"..foreach_arg2print(params));
    --页面跳转类型，默认为右侧切入
    local JumpStyle = vt("JumpStyle",params);
    --默认压栈
    local AddPage = vt("AddPage",params,"true");
    --默认关闭弹窗
    local CloseLoading = vt("CloseLoading",params,"true");
    --默认展示方式为页面替换
    local ShowPageStyle = vt("ShowPageStyle",params,"replace");

    --[[debug_alert(
        "page_callback\n"..
        "JumpStyle : "..JumpStyle.."\n"..
        "AddPage : "..AddPage.."\n"..
        "CloseLoading : "..CloseLoading.."\n"..
        "ShowPageStyle : "..ShowPageStyle.."\n"..
        "isShowContent : "..formatNull(tostring(isShowContent)).."\n"..
        ""
    );]]

    --响应码
    local responseCode = vt("responseCode",params);
    --响应包
    local responseBody = vt("responseBody",params);
    --响应头
    --local responseHeader = vt("responseHeader",params);

    if responseCode == 1599 then
        close_loading();
        location:replace(responseBody);
    elseif responseCode == 200 then
        if string.find(responseBody,"invalid file path") then
            close_loading();
            debug_alert("页面异常");
        else
            --压栈
            if AddPage == "true" then
                history:add(responseBody);
                --栈值
                local HistoryLength = tonumber(history:length());

                --初始化参数
                params["responseBody"] = "未添加返回包";
                params["responseHeader"] = "未添加返回头";
                --压栈的情况下将参数存储至页面缓存
                pageinfoTable[HistoryLength] = params;

                local PageFilePath = vt("page_file_path",params);
                --debug_alert(PageFilePath);
                local PageInfo = lua_page.info(PageFilePath);
                local PageName = vt("PageName",PageInfo);
                if PageName ~= "" then
                    --页面数据上报
                    local reportArg = {
                        Event="JJBXAppOpenAppPage",
                        PageUrl=PageFilePath,
                        PageName=PageName.."（配置）"
                    };
                    lua_system.sensors_report(reportArg);
                end;

                --[[debug_alert(
                    "do_invoke_page\n"..
                    "HistoryLength : "..tostring(HistoryLength).."\n"..
                    "pageinfoTable length : "..tostring(#pageinfoTable).."\n"..
                    --"pageinfoTable Arg\n"..foreach_arg2print(pageinfoTable).."\n"..
                    ""
                );]]
            end;
            local afterpage = slt2.render(slt2.loadstring(responseBody),nil);
            if ShowPageStyle == "replace" then
                --页面替换

                --页面属性初始化
                page_sys_init();

                --通过跳转样式指定页面切换方式的参数
                local UseJumpStyle = "right";
                if JumpStyle == "" then
                    --默认右侧弹出
                    UseJumpStyle = page_jump_style("right");
                else
                    UseJumpStyle = page_jump_style(JumpStyle);
                end;
                location:replace(afterpage, UseJumpStyle, replace_callback,{CloseLoading=CloseLoading});
            elseif ShowPageStyle == "showContent" then
                --通过跳转样式指定页面切换方式的参数
                local UseJumpStyle = page_jump_style(JumpStyle);
                --页面弹出，默认不压栈，默认参数需要在调用处给定，这里Android客户端需要适配到顶部，从顶部往下开始适配
                window:showContent(afterpage, showContentIndex, UseJumpStyle);
                isShowContent = true;

                if CloseLoading == "true" then
                    close_loading();
                end;
            end;
        end;
    else
        close_loading();
        if configTable["lua_debug"] == "true" then
            debug_alert("页面请求异常，请检查网络");
        else
            alert("网络不可用，请检查网络");
        end;
    end;
end;
