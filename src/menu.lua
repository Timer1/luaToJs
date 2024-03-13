--[[菜单处理函数]]

lua_menu = {};

--[[菜单点击]]
function lua_menu.onclick(params)
    --确认首页初始化请求已经完成
    if globalTable["IndexPageInitFinish"] == "true" then
        local menu = "";
        if type(params) == "table" then
            menu = params;
        else
            menu = string_to_table(params);
        end;

        --[[debug_alert(
            "菜单点击参数\n"..foreach_arg2print(params).."\n"..
            "\n"..
            "菜单路由参数\n"..foreach_arg2print(menu).."\n"..
            ""
        );]]

        --调用菜单路由
        lua_menu.router(menu);
    else
        alert("查询用户信息失败，请重试");
    end;
end;

--[[通过菜单ID获取服务端配置的菜单信息]]
function lua_menu.server_menu_info(menuId)
    --获取服务端配置的菜单
    local menuExist = "false";
    local menuInfo = "";
    local allMenuList = globalTable["menuList"][1]["allMenuList"];
    for i=1,#allMenuList do
        local serverMenuInfo = allMenuList[i];
        local serverMenuId = vt("id",serverMenuInfo);
        if serverMenuId == menuId then
            menuExist = "true";
            menuInfo = serverMenuInfo
            break
        end;
    end;

    local serverMenuInfoRes = {
        menuExist=menuExist,
        menuInfo=menuInfo
    };
    --debug_alert(foreach_arg2print(serverMenuInfoRes));
    return serverMenuInfoRes;
end;

--[[菜单路由]]
function lua_menu.router(menuRouterArg)
    --菜单参数
    local menuRouterArg = formatNull(menuRouterArg);
    --点击的菜单id
    local clicKMenuId = vt("id",menuRouterArg);
    --通过菜单ID获取服务端配置的菜单信息
    local serverMenuConfig = lua_menu.server_menu_info(clicKMenuId);
    --菜单是否存在
    local serverMenuExist = vt("menuExist",serverMenuConfig);

    --菜单存在时进行路由
    if serverMenuExist == "false" then
        alert("服务不可用");
    else
        --服务端菜单信息
        local serverMenuInfo = vt("menuInfo",serverMenuConfig);

        --菜单id
        local menuId = vt("id",serverMenuInfo);
        --链接
        local menuUrl = vt("url",serverMenuInfo);
        --标题
        local menuTitleName = vt("titleName",serverMenuInfo);
        --图标名
        local menuIcon = vt("icon",serverMenuInfo);
        --函数
        local menufunc = vt("function",serverMenuInfo);
        --函数入参
        local menuparams = vt("params",serverMenuInfo);
        --使用该功能的顶层机构号
        local menuOrgFlag = vt("orgFlag",serverMenuInfo);
        --校验配置
        local verifyConditions = vt("verifyConditions",serverMenuInfo);

        --判断app最低版本支持
        local appSupportInfo = lua_ota.version_support(menuId);
        local appSupport = vt("appSupport",appSupportInfo);
        local appSupportTipMsg = vt("appSupportTipMsg",appSupportInfo,"服务已经升级，请更新后使用");

        --调试信息
        --[[debug_alert(
            "菜单路由\n\n"..
            "菜单地址  : "..menuUrl.."\n"..
            "菜单参数  : "..foreach_arg2print(menuRouterArg).."\n"..
            "菜单存在  : "..serverMenuExist.."\n"..
            "菜单信息  : "..foreach_arg2print(serverMenuInfo).."\n"..
            "\n"..
            "用车权限  : "..carServiceFlag.."\n"..
            "用餐权限  : "..eatServiceFlag.."\n"..
            "商旅权限  : "..travelServiceFlag.."\n"..
            "报销权限  : "..processBillFlag.."\n"..
            "消息权限  : "..MsgCenterFlag.."\n"..
            "\n"..
            "菜单支持  : "..appSupport.."\n"..
            ""
        );]]

        if menuId == "" then
            debug_alert("请配置频道编号");
        elseif menuUrl == "" and menufunc == ""then
            debug_alert("请配置频道请求");
        elseif appSupport == "false" then
            --更新提示
            local upverArg = {
                updateType="OPTION",
                updateMsg=appSupportTipMsg
            };
            lua_ota.show_upvsr_view(upverArg);
        else
            --菜单权限控制，提示信息配置于config.lua

            --共享人权限检查
            if globalTable["userType"] == "2" then

                --获取被共享人场景
                local sharePeopleScene = vt("sharePeopleScene",globalTable);

                --采购权限检查
                if menuId == "zxcg" then
                    if string.find(sharePeopleScene,JJBX_SharePeopleSecneCode.ejyshop) then
                        --E家银采购
                        menuUrl = vt("url",serverMenuInfo);
                    else
                        --提示权限限制信息
                        alert(onlineShoppingCheckMsg);
                        return;
                    end;
                end;

                --用餐权限检查
                if menuId == "ycfw" then
                    if string.find(sharePeopleScene,"MT") then
                        --美团用餐
                        menuUrl = vt("redirect_url",serverMenuInfo);
                        --重定向
                        lua_eat.page_router("index");
                        return;
                    elseif string.find(sharePeopleScene,"ELM") then
                        --饿了么用餐
                        menuUrl = vt("url",serverMenuInfo);
                    else
                        --提示权限限制信息
                        alert(onlineShoppingCheckMsg);
                        return;
                    end;
                end;
            --被共享人权限检查
            else
                --采购权限检查
                if menuId == "zxcg" then
                    local MatchRes = lua_jjbx.user_fun_match({FunCode="0301"});
                    local Matched = vt("Matched",MatchRes);
                    if Matched == "true" then
                        menuUrl = vt("url",serverMenuInfo);
                    else
                        --提示权限限制信息
                        alert(onlineShoppingCheckMsg);
                        return;
                    end;
                end;

                --用车权限检查
                if menuId == "yccx" then
                    local MatchRes = lua_jjbx.user_fun_match({FunCode="0401"});
                    local Matched = vt("Matched",MatchRes);
                    if Matched == "true" then
                        menuUrl = vt("url",serverMenuInfo);
                    else
                        --提示权限限制信息
                        alert(carServiceCheckMsg);
                        return;
                    end;
                end;

                --用餐权限检查
                if menuId == "ycfw" then
                    --美团
                    local MatchRes = lua_jjbx.user_fun_match({FunCode="0105"});
                    local Matched = vt("Matched",MatchRes);
                    if Matched == "true" then
                        menuUrl = vt("redirect_url",serverMenuInfo);
                        --重定向
                        lua_eat.page_router("index");
                        return;
                    else
                        if eatServiceFlag == "enable" then
                            --饿了么
                            menuUrl = vt("url",serverMenuInfo);
                        else
                            --提示权限限制信息
                            alert(eatServiceCheckMsg);
                            return;
                        end;
                    end;
                end;
            end;

            --商旅权限检查
            if menuId == "slfw" and travelServiceFlag == "disenable" then
                alert(travelServiceCheckMsg);
                return;
            end;

            --报销权限检查
            if menuId == "bxsq" and processBillFlag == "disenable" then
                alert(processBillCheckMsg);
                return;
            end;

            --杭口医院权限检查
            if menuId == "hkHospital" and HKHospitalFlag == "disenable" then
                alert(HKHospitalCheckMsg);
                return;
            end;

            --租房服务权限检查
            if menuId == "zffw" and RenatalHourseFlag == "disenable" then
                alert(RenatalHourseCheckMsg);
                return;
            end;

            --路由检查
            if menuUrl ~= "" then
                --debug_alert("访问页面 : "..menuUrl);
                invoke_page_donot_checkRepeat(menuUrl,page_callback,{CloseLoading="false"});
            elseif menufunc ~= "" then
                --debug_alert("调用函数 : "..menufunc);
                lua_system.do_function(menufunc,menuparams);
            else
                alert("服务未配置");
            end;
        end;
    end;
end;

--[[获取菜单]]
function lua_menu.get()
    --定义菜单
    local menu = {};

    --菜单根据工号保存，多用户切换可以同时保存，通过工号从数据库读取客户端保存的菜单
    local WorkId = get_db_value("workid");
    local DBMenuKey = WorkId.."_SavedMenu";
    local homePageCompileMenuJson = get_db_value(DBMenuKey);

    --将读取的菜单保存在客户端提供的数据库字段中
    set_db_value("homePageCompileMenuJson",homePageCompileMenuJson);
    --debug_alert("从数据库读取客户端保存的菜单:\n"..homePageCompileMenuJson);

    --服务器配置的菜单
    local serverMenuList = formatNull(globalTable["menuList"]);
    if serverMenuList == "" then
        alert("菜单加载失败，请重试");
        return;
    else
        --服务器配置的默认菜单
        local defaultMenuListTable = formatNull(serverMenuList[1]["defaultMenuList"]);
        local defaultMenuListJson = table2json(defaultMenuListTable);
        --debug_alert("服务器配置的默认菜单:\n"..defaultMenuListJson);

        --当客户端存在菜单记录
        if homePageCompileMenuJson ~= "" then
            --获取服务器配置的菜单版本号
            local ServerMenuVersion = get_db_value("ServerMenuVersion");
            --获取保存菜单的版本号
            local DBMenuVerKey = WorkId.."_SavedMenuVer";
            local SaveMenuVersion = get_db_value(DBMenuVerKey);

            --[[debug_alert(
                "loadMenu\n"..
                "DBMenuKey"..DBMenuKey.."\n"..
                "DBMenuKey"..DBMenuVerKey.."\n"..
                "ServerMenuVersion"..ServerMenuVersion.."\n"..
                "SaveMenuVersion"..SaveMenuVersion.."\n"..
                ""
            );]]

            if ServerMenuVersion == SaveMenuVersion then
                --debug_alert("菜单和服务器版本一致则加载保存菜单");
                menu = homePageCompileMenuJson;
            else
                --debug_alert("不一致加载默认菜单并删除数据库保存的菜单和菜单版本号");
                del_db_value("homePageCompileMenuJson");
                del_db_value(DBMenuKey);
                del_db_value(DBMenuVerKey);
                menu = defaultMenuListJson;
            end;
        else
            --当客户端不存在菜单记录
            --debug_alert("当客户端不存在菜单记录使用默认菜单");
            menu = defaultMenuListJson;
        end;

        return menu;
    end;
end;

--[[首页菜单容器渲染]]
function lua_menu.create_index_menu(Arg)
    local userType = vt("userType",globalTable);
    local menuList = vt("menuList",Arg);
    local menuCounts = #menuList;

    --[[debug_alert(
        "首页菜单容器渲染\n"..
        "userType : "..userType.."\n"..
        "menuCounts : "..tostring(menuCounts).."\n"..
        "menuList"..foreach_arg2print(menuList).."\n"..
        ""
    );]]

    local SetBorder = "0";

    --中间内容
    local htmlContent = "";

    --遍历菜单
    for i=1,menuCounts do
        local menuItem = menuList[i];
        local menuID = formatNull(menuItem["id"]);
        local menuUrl = formatNull(menuItem["url"]);
        local menuFunc = formatNull(menuItem["function"]);
        local menuParams = formatNull(menuItem["params"]);
        local menuOrgFlag = formatNull(menuItem["orgFlag"]);
        local menuDefault = formatNull(menuItem["default"]);
        local menuName = formatNull(menuItem["titleName"]);
        local menuIcon = formatNull(menuItem["icon"]);

        --[[debug_alert(
            "loadMenu:\n"..
            "menuID:"..menuID.."\n"..
            "menuUrl:"..menuUrl.."\n"..
            "menuFunc:"..menuFunc.."\n"..
            "menuParams:"..menuParams.."\n"..
            "menuOrgFlag:"..menuOrgFlag.."\n"..
            "menuDefault:"..menuDefault.."\n"..
            "menuName:"..menuName.."\n"..
            "menuIcon:"..menuIcon.."\n"..
            ""
        );]]

        local menuOnclickArg =
            "id="..menuID..
            "&function="..menuFunc..
            "&params="..menuParams..
            "";
        --debug_alert("menuOnclickArg : "..menuOnclickArg);
        local OnClickFunC = "lua_menu.onclick('"..menuOnclickArg.."')";
        --debug_alert("OnClickFunC : "..OnClickFunC);

        --定义每个菜单和菜单样式，1行4个菜单
        local LineFlag = tostring(i%4);
        local classFlag = "menuList_css"..LineFlag;
        --debug_alert("classFlag:"..classFlag);

        --正常菜单
        local MenuHtmlItem = [[
            <div class="]]..classFlag..[[" border="]]..SetBorder..[[" onclick="]]..OnClickFunC..[[">
                <img src="local:]]..menuIcon..[[" class="menu_icon" onclick="]]..OnClickFunC..[[" />
                <label class="menu_name" value="]]..menuName..[[" onclick="]]..OnClickFunC..[[" />
            </div>
        ]];

        --更多菜单
        local MoreMenuItem = [[
            <div class="menuList_css0" border="]]..SetBorder..[[" onclick="jjbx_allMenu()">
                <img src="local:jjbxmenu_all.png" class="menu_icon" onclick="jjbx_allMenu()" />
                <label class="menu_name" name="bxsq" onclick="jjbx_allMenu()">更多</label>
            </div>
        ]];

        if LineFlag == "1" then
            --单行第1个开始套入1个div
            htmlContent = htmlContent..[[
                <div class="menuList_div" border="]]..SetBorder..[[">
            ]];
        end;

        --添加正常菜单
        htmlContent = htmlContent..MenuHtmlItem;

        --结束循环个数
        local endLoopCounts = "";
        if userType == "2" then
            --共享人不控制
            endLoopCounts = menuCounts;
        else
            --正常用户最多显示7个
            endLoopCounts = 7;
        end;

        if LineFlag == "0" then
            --换行
            htmlContent = htmlContent..[[
                </div>
                <label class="space_10_div" border="0" value="  " />
            ]];
        else
            --不换行
            if i == endLoopCounts then
                --debug_alert("结束循环");
                if userType == "2" then

                else
                    --普通用户追加“更多”菜单
                    htmlContent = htmlContent..MoreMenuItem;
                end;

                --最后一个菜单结束布局
                htmlContent = htmlContent..[[
                    </div>
                ]];
                --结束循环
                break
            else
                --debug_alert("不结束循环");
            end;
        end;
    end;

    --debug_alert("htmlContent\n"..htmlContent);

    if htmlContent ~= "" then
        local menuListDiv = [[
            <div class="menu_div" border="]]..SetBorder..[[" name="menu_div">
                <label class="space_15_div" border="0" value="  " />
                ]]..htmlContent..[[
                <label class="space_15_div" border="0" value="  " />
            </div>
        ]];
        --debug_alert("menuListDiv\n"..menuListDiv);
        document:getElementsByName("menu_div")[1]:setInnerHTML(menuListDiv);
        show_ele("menu_div");
    else
        hide_ele("menu_div");
    end;
    page_reload();
end;

--[[跳转登录]]
function lua_menu.to_login_page()
    invoke_page("jjbx_login/xhtml/jjbx_login.xhtml",page_callback,{});
end;

--[[跳转首页]]
function lua_menu.to_index_page(flag)
    local flag = formatNull(flag);
    local InvokePageArg = {CloseLoading="false"};
    if flag == "back" then
        --后退至首页
        InvokePageArg["JumpStyle"] = "left";
    else
        --前进至首页
        InvokePageArg["JumpStyle"] = "right";
    end;
    invoke_page_donot_checkRepeat("jjbx_index/xhtml/jjbx_index.xhtml",page_callback,InvokePageArg);
end;

--[[返回首页]]
function lua_menu.back_to_index()
    lua_menu.to_index_page("back");
end;

--[[前往安能专区页面]]
function lua_menu.init_anneng_url(ResParams)
    if formatNull(ResParams) == "" then
        invoke_trancode(
            "jjbx_page",
            "webview_page",
            {TranCode="InitAnnengUrl"},
            lua_menu.init_anneng_url,
            {}
        );
    else
        local jsonData = ResParams["responseBody"];
        local responseBody = json2table(ResParams["responseBody"]);
        if responseBody["errorNo"] == "000000" then
            globalTable["webview_url"] = responseBody["webview_url"];
            globalTable["webview_page_title"] = responseBody["webview_page_title"];
            invoke_page_noloading_checkRepeat("jjbx_page/xhtml/webview_page.xhtml",page_callback,nil);
        else
            jjbx_show_business_err(responseBody["errorNo"],responseBody["errorMsg"]);
        end;
    end;
end;

--[[杭口医院初始化查询]]
function lua_menu.hkHospital_init_qry(ResParams)
    --查询是否点击过不再提示使用说明
    local CtrlArg = {
        CtrlStyle="Get",
        CtrlCallBackFunc="lua_menu.do_hkHospital_init",
        CtrlKey="008"
    };
    lua_jjbx.pc_cache_arg_ctrl("",CtrlArg);
end;

--[[杭口医院初始化]]
function lua_menu.do_hkHospital_init(Arg)
    local ArgValue = vt("ArgValue",Arg);
    local NowVersion = vt("hkHospitalUseInstructionVersion",configTable);

    --[[debug_alert(
        "杭口医院初始化\n"..
        "不再提示版本 : "..ArgValue.."\n"..
        "当前最新版本 : "..NowVersion.."\n"..
        ""
    );]]

    if ArgValue == NowVersion then
        --debug_alert("点击过不再提示-查询预算");
        lua_service.qry_hk_budget();
    else
        --debug_alert("前往说明页面");
        lua_menu.to_hkHospital_use_instruction_page({CloseLoading="false",AddPage="false"});
    end;
end;

--[[杭口医院使用说明页面]]
function lua_menu.to_hkHospital_use_instruction_page(Arg)
    invoke_page("jjbx_local_service/hkHospital/use_instruction.xhtml",page_callback,Arg);
end;

--[[前往开票信息页面]]
function lua_menu.to_invoice_info_page()
    --debug_alert("lua_menu.to_invoice_info_page")
    
    local pageFun = "";
    local pageArg = "";

    if formatNull(companyTable["openNoteInfoDetail"]) == "" then
        --已经查询并保存过开票信息后，下次点击不需要loading
        pageFun = "invoke_page";
        pageArg = {CloseLoading="false"};
    else
        pageFun = "invoke_page_noloading_checkRepeat";
        pageArg = nil;
    end;

    --执行页面请求
    local doPageFun = lua_format.str2fun(pageFun);
    doPageFun("jjbx_index/xhtml/jjbx_cominvoice_info.xhtml", page_callback, pageArg);
end;

--[[前往扫码页面]]
function lua_menu.to_scanQRcode_page(arg)
    local arg = formatNull(arg,{JumpStyle="none"});
    --打开摄像头前，iPhoneX底部需要隐藏
    index_page_iPhoneX_ctrl("hide");
    invoke_page_noloading_checkRepeat("jjbx_fpc/xhtml/jjbx_invoice_scanQRcode.xhtml",page_callback,arg);
end;

--[[前往消息中心页面]]
function lua_menu.to_msg_center(arg)
    local arg = formatNull(arg);
    local JumpStyle = formatNull(arg["JumpStyle"],"right");

    globalTable["msgType"] = "";
    globalTable["businessModule"] = "";
    globalTable["messageCenter_screenButton"] = "1";
    invoke_page("jjbx_msg_center/xhtml/msg_center_index.xhtml", page_callback, {CloseLoading="false",JumpStyle=JumpStyle});
end;

--[[返回消息中心]]
function lua_menu.back_to_msg_center()
    local arg = {
        JumpStyle = "left"
    };
    lua_menu.to_msg_center(arg);
end;

--[[前往我的审批页面]]
function lua_menu.to_my_approval_page()
    --是否为领导审批
    local LeaderApprovedFlag = "false";
    --机构号码（从当前机构信息获取）
    local orgFlag = formatNull(globalTable["selectOrgList"][1]["unitcode"]);
    --获取配置的工号
    local workidStr = vt("approvedItems_leader",configTable);
    --当前登录的工号
    local workid = get_db_value("workid");
    local InvokePageArg = {CloseLoading="false"};
    if orgFlag=="001" or orgFlag=="330000001001" then
        --机构为浙商时进入定制逻辑
        if workid~="" and workidStr~="" then
            --工号不为空、配置的工号不为空则进行匹配
            local WorkidList = splitUtils(workidStr,",");
            for i=1,#WorkidList do
                if string.lower(workid) == string.lower(formatNull(WorkidList[i])) then
                    --匹配到领导工号
                    LeaderApprovedFlag = "true";
                    break
                end;
            end;
        end;
    end;
    globalTable["quickFiltrateFlag"] = "0";
    globalTable["quickFiltrateIndex"] = "";
    globalTable["LeaderApprovedFlag"] = LeaderApprovedFlag;
    InvokePageArg["LeaderApprovedFlag"] = LeaderApprovedFlag;

    --[[debug_alert(
        "前往我的审批页面\n"..
        "机构号码 : "..orgFlag.."\n"..
        "配置工号 : "..workidStr.."\n"..
        "登录工号 : "..workid.."\n"..
        "匹配结果 : "..LeaderApprovedFlag.."\n"..
        ""
    );]]

    invoke_page("jjbx_index/xhtml/jjbx_approvedItems.xhtml",page_callback,InvokePageArg);
end;

--[[前往我的申请页面]]
function lua_menu.to_my_request_page(support)
    local support = formatNull(support);
    --定义支持的单据类型
    globalTable["MyAskBillSupport"] = support;
    --定义结果页面返回按钮的文字
    globalTable["BillApplyBackBtnText"] = "返回报销首页";
    invoke_page("jjbx_index/xhtml/jjbx_myAsk.xhtml",page_callback,{CloseLoading="false"});
end;

--[[前往切换公司页面]]
function lua_menu.to_change_company_page()
    invoke_page("jjbx_myInfo/xhtml/changeCompany.xhtml",page_callback,{CloseLoading="false"});
end;

--[[前往联系我们页面]]
function lua_menu.to_contactUs_page()
    invoke_page_noloading_checkRepeat("jjbx_contact_us/xhtml/contact_us.xhtml",page_callback,nil);
end;

--[[前往支付宝授权说明]]
function lua_menu.to_alipay_auth_instruction_page()
    invoke_page_noloading_checkRepeat("jjbx_myInfo/xhtml/alipay_auth_instruction.xhtml",page_callback,nil);
end;

--[[前往消息设置页面]]
function lua_menu.to_msg_setting_page(params)
    invoke_page("jjbx_msg_setting/xhtml/msg_setting.xhtml",page_callback,nil);
end;

--[[前往信用管理页面]]
function lua_menu.to_credit_management_page()
    invoke_page("jjbx_credit_manage/xhtml/creditManage.xhtml",page_callback,nil);
end;

--[[前往安全中心页面]]
function lua_menu.to_security_center_page()
    invoke_page("jjbx_security_center/xhtml/securityCenter.xhtml", page_callback, nil);
end;

--[[前往共享人管理页面]]
function lua_menu.to_share_people_manage_page()
    invoke_page("jjbx_share_people_manage/list.xhtml", page_callback, {CloseLoading="false"});
end;

--[[前往手势登录设置页面]]
function lua_menu.to_gesture_login_set_page()
    invoke_page("jjbx_security_center/xhtml/setGestureLogin.xhtml", page_callback, nil);
end;

--[[前往人脸认证设置页面]]
function lua_menu.to_face_login_set_page()
    invoke_page("jjbx_security_center/xhtml/setFaceLogin.xhtml", page_callback, nil);
end;

--[[前往密码登录修改页面]]
function lua_menu.to_change_login_pwd_page()
    invoke_page_noloading_checkRepeat("jjbx_security_center/xhtml/change_Password.xhtml", page_callback, nil);
end;

--[[前往指纹认证设置页面]]
function lua_menu.to_finger_login_set_page()
    invoke_page("jjbx_security_center/xhtml/setFingerLogin.xhtml", page_callback, nil);
end;

--[[前往信息编辑页面]]
function lua_menu.to_information_edit_page()
    invoke_page_noloading_checkRepeat("jjbx_myInfo/xhtml/myEdit.xhtml",page_callback,nil);
end;

--[[前往银行卡管理页面]]
function lua_menu.to_card_management_page()
    invoke_page("jjbx_card_management/xhtml/card_management.xhtml",page_callback,{CloseLoading="false"});
end;

--[[前往修改邮箱页面]]
function lua_menu.to_mail_edit_page()
    invoke_page_noloading("jjbx_myInfo/xhtml/change_email.xhtml",page_callback,nil);
end;

--[[前往修改办公电话页面]]
function lua_menu.to_telephone_edit_page()
    invoke_page_noloading("jjbx_myInfo/xhtml/change_telphone.xhtml",page_callback,nil);
end;

--[[前往修改个人手机号页面]]
function lua_menu.to_phone_edit_page()
    invoke_page_noloading("jjbx_myInfo/xhtml/change_phone.xhtml",page_callback,nil);
end;

--[[前往隐私政策菜单页面]]
function lua_menu.to_protocol_menu_page()
    local appSupportInfo = lua_ota.version_support("ryt:client_database_ctrl");
    local appSupport = vt("appSupport",appSupportInfo);
    --版本支持判断
    if appSupport == "false" then
        --不支持的情况直接查看协议
        lua_menu.to_protocol_page();
    else
        --支持的情况进入协议操作菜单
        invoke_page_noloading("jjbx_myInfo/xhtml/protocol_menu.xhtml",page_callback,nil);
    end;
end;

--[[前往隐私政策页面]]
function lua_menu.to_protocol_page(params)
    --debug_alert("lua_menu.to_protocol_page");

    local protocol_pdf_url = formatNull(globalTable["ProtocolPdfUrl"]);
    local params = formatNull(params);
    if protocol_pdf_url == "" then
        if params == "" then
            --查询链接
            invoke_trancode_noloading_checkRepeat("jjbx_page","webview_page",{TranCode="InitPrivacyProtocolUrl"},lua_menu.to_protocol_page,{});
        else
            --查询结果处理
            local jsonData = params["responseBody"];
            local responseBody = json2table(params["responseBody"]);
            if responseBody["errorNo"] == "000000" then
                local Url = vt("webview_url",responseBody);
                --存储Url
                globalTable["ProtocolPdfUrl"] = Url;
                --打开隐私政策链接
                lua_system.alert_webview({title="隐私政策",visit_url=Url});
            else
                jjbx_show_business_err(responseBody["errorNo"],responseBody["errorMsg"]);
            end;
        end;
    else
        --有缓存链接的情况下直接打开
        lua_system.alert_webview({title="隐私政策",visit_url=protocol_pdf_url});
    end;
end;

--[[前往新手指南页面]]
function lua_menu.to_guide_page(params)
    local guide_page_url = formatNull(globalTable["GuidePageUrl"]);
    local params = formatNull(params);
    if guide_page_url == "" then
        if params == "" then
            invoke_trancode_noloading_checkRepeat("jjbx_page","webview_page",{TranCode="InitGuidePageUrl"},lua_menu.to_guide_page,{});
        else
            local jsonData = params["responseBody"];
            local responseBody = json2table(params["responseBody"]);
            if responseBody["errorNo"] == "000000" then
                --打开页面
                lua_jjbx.open_guide_page(responseBody["webview_url"]);
            else
                jjbx_show_business_err(responseBody["errorNo"],responseBody["errorMsg"]);
            end;
        end;
    else
        lua_jjbx.open_guide_page(guide_page_url);
    end;
end;

--[[前往可关联发票列表页面]]
function lua_menu.to_choose_invoice_relate_page()
    invoke_page("jjbx_proccess_reimbursement_bill/xhtml/reimbursement_bill_invoice_list.xhtml", page_callback,{CloseLoading="false"});
end;

--[[前往手工录入发票界面]]
function lua_menu.to_custom_input_invoice_page()
    globalTable["invoiceFlag"] = "sglr";
    globalTable["fpDetail"] = {};
    globalTable["scfpTip"] = "false";
    --清空上传信息，防止在手工录入之前用户做过上传的操作，会导致上一次上传的信息同手工录入信息一并提交而出现发票信息错误
    globalTable["UploadInvoiceInfo"] = "";
    invoke_page("jjbx_proccess_reimbursement_bill/xhtml/reimbursement_bill_invoice_add.xhtml",page_callback,{});
end;

--[[前往设备管理页面]]
function lua_menu.to_device_management_page(resParams)
    --debug_alert("lua_menu.to_device_management_page");

    if formatNull(resParams) == "" then
        --请求
        invoke_trancode_donot_checkRepeat(
            "jjbx_myInfo",
            "securityCenter",
            {TranCode="GetBindDeviceList"},
            lua_menu.to_device_management_page,
            {},
            all_callback,
            {CloseLoading="false"}
        );
    else
        --响应
        local res = json2table(resParams["responseBody"]);
        local errorNo = vt("errorNo",res);
        local errorMsg = vt("errorMsg",res);
        if res["errorNo"] == "000000" then
            globalTable["GetBindDeviceListRes"] = res;
            invoke_page_donot_checkRepeat("jjbx_security_center/xhtml/device_m_page.xhtml", page_callback, {CloseLoading="false"});
        else
            jjbx_show_business_err(errorNo,errorMsg);
        end;
    end;
end;

--[[前往福利预算页面]]
function lua_menu.to_budget_info_page(Arg)
    local InvokePageArg = formatNull(Arg,{});
    InvokePageArg["CloseLoading"] = "false";
    invoke_page("jjbx_budget_info/xhtml/budget_info_index.xhtml",page_callback,InvokePageArg);
end;

--[[前往福利预算详情页面]]
function lua_menu.to_budget_detail_page(TableStringArg)
    --初始化前还原所有载体选中状态
    for i=1,#JJBX_BudgetProcessType do
        JJBX_BudgetProcessType[i]["selected"] = "false";
    end;

    --还原选中状态
    globalTable["BudgetUseDetailStatusIndex"] = "1";

    local Arg = lua_format.table_arg_unpack(TableStringArg);
    --debug_alert("前往福利预算详情页面"..foreach_arg2print(Arg));
    --预算任务编码
    local TaskId = vt("TaskId",Arg);
    --预算任务名称
    local TaskName = vt("TaskName",Arg);
    --预算载体列表
    local CarrierList = vt("CarrierList",Arg);
    --预算发布状态 1已发布
    local PublishFlag = vt("PublishFlag",Arg);
    --匹配的载体信息
    local FiltBudgetProcessType = {};

    --默认选中全部
    JJBX_BudgetProcessType[1]["selected"] = "true";
    if CarrierList == "" then
        alert("没有指定预算载体");
        return;
    elseif TaskId == "" then
        alert("没有指定预算任务");
        return;
    elseif PublishFlag ~= "1" then
        alert("预算任务未发布，可联系所在公司系统管理员确认预算执行明细");
        return;
    else
        --匹配逻辑
        for i=1,#JJBX_BudgetProcessType do
            local BPItem = formatNull(JJBX_BudgetProcessType[i]);
            local ConfigCarrierId = vt("value",BPItem);
            --获取匹配结果
            local MatchRes = "false";
            local Carriers = splitUtils(CarrierList,",");
            for i=1,#Carriers do
                if ConfigCarrierId == Carriers[i] then
                    MatchRes = "true";
                    break
                end;
            end;

            --[[
            --匹配时选中
            if MatchRes=="true" then
                --debug_alert("选中"..tostring(i).."-"..ConfigCarrierId);
                JJBX_BudgetProcessType[i]["selected"] = "true";
            end;
            ]]

            --匹配时追加并生成新的载体列表
            if MatchRes=="true" or i==1 then
                --追加到新的载体列表
                table.insert(FiltBudgetProcessType,BPItem);
            end;
        end;
    end;

    local InvokePageArg = {
        budgetTaskId=TaskId,
        publishName=TaskName.."已用明细",
        CloseLoading="false",
        FiltBudgetProcessType=FiltBudgetProcessType,
        billType = vt("billType",Arg)
    };
    invoke_page("jjbx_budget_info/xhtml/budget_used_details.xhtml",page_callback,InvokePageArg);
end;

--[[前往其他薪酬数据页面]]
function lua_menu.to_other_salary_info_page()
    invoke_page("jjbx_salary_service/xhtml/moreInfomation.xhtml",page_callback,{CloseLoading="false"});
end;

--[[前往社保扣缴明细页面]]
function lua_menu.to_social_detail_page()
    invoke_page("jjbx_salary_service/xhtml/socialDetail.xhtml",page_callback,{CloseLoading="false"});
end;

--[[前往模板页面]]
function lua_menu.to_demo_page(arg)
    if systemTable["EnvAllowDebug"] == "true" then
        --参数初始化
        --演示菜单显示类型
        if formatNull(show_demo_menu_type) == "" then
            --默认展开全部菜单
            show_demo_menu_type = "open";
        end;

        --演示菜单显示下标
        if formatNull(show_demo_menu_index) == "" then
            show_demo_menu_index = 1;
        end;

        local arg = formatNull(arg,{CloseLoading="false"});
        invoke_page_donot_checkRepeat("jjbx_page_demo/xhtml/demo_index_page.xhtml",page_callback,arg);
    end;
end;

--[[前往待报销发票列表页面]]
function lua_menu.to_dbx_invoice_list_page()
    --还原多选参数
    lua_format.reset_table(C_ClientListSelectListArg);
    --全选类型初始化 0不全选 1全选
    C_ClientListSelectListArg.SelectAllType = "0";

    --前往页面
    invoke_page("jjbx_fpc/xhtml/jjbx_invoiceList_dbx.xhtml",page_callback,{CloseLoading="false"});
end;

--[[前往行程报销发起报销页面]]
function lua_menu.to_porcess_travel_reimbursement_page(Arg)
    --还原多选参数
    lua_format.reset_table(C_ClientListSelectListArg);
    --全选类型初始化 0不全选 1全选
    C_ClientListSelectListArg.SelectAllType = "0";

    --前往页面
    invoke_page("jjbx_travel_reimbursement/xhtml/travel_service_reimbursement_myOrder.xhtml",page_callback,Arg);
end;

--[[前往关联核销页面]]
function lua_menu.to_add_glhx_page(Arg)
    --还原多选参数
    lua_format.reset_table(C_ClientListSelectListArg);
    --全选类型初始化 0不全选 1全选
    C_ClientListSelectListArg.SelectAllType = "0";

    --分页参数初始化
    lua_page_list.init_qry_arg("process_glhx_list");

    local Arg = formatNull(Arg,{});
    Arg["CloseLoading"] = "false";
    invoke_page("jjbx_process_bill/xhtml/process_bill_glhx.xhtml",page_callback,Arg);
end;

--[[前往关联在建工程页面]]
function lua_menu.to_add_glzjgc_page(Arg)
    --还原多选参数
    lua_format.reset_table(C_ClientListSelectListArg);
    --全选类型初始化 0不全选 1全选
    C_ClientListSelectListArg.SelectAllType = "0";

    --分页参数初始化
    lua_page_list.init_qry_arg("process_glzjgc_list");

    local Arg = formatNull(Arg,{});
    Arg["CloseLoading"] = "false";
    invoke_page("jjbx_process_bill/xhtml/process_bill_glzjgc.xhtml",page_callback,Arg);
end;

--[[头部右侧展开菜单调用（业务功能）]]
function lua_menu.top_right_menu_action(ctrl)
    if ctrl == "get_bill_cover_pdf" then
        --获取单据封面，调用和实现统一
        lua_jjbx.get_bill_cover_pdf();
    elseif ctrl == "edit_bill" then
        --编辑单据，调用统一，各自业务页面实现
        globalTable["ifApproverEdit"] = "true";
        to_bill_edit_page();
    elseif ctrl == "process_information" then
        --处理情况，调用统一，各自业务页面实现
        to_process_information_page();
    elseif ctrl == "msg_filt_flag_all" then
        --消息中心查询全部
        update_markunread_flag("");
    elseif ctrl == "msg_filt_flag_unread" then
        --消息中心查询未读
        update_markunread_flag("0");
    elseif ctrl == "msg_filt_flag_read" then
        --消息中心查询已读
        update_markunread_flag("1");
    elseif ctrl == "new_bill" then
        create_new_bill();
    elseif ctrl == "jjdj" then
        lua_bill.to_jjdj_list();
    else
        alert("敬请期待");
    end;
end;

--[[APP弹出菜单调用（业务功能）]]
function lua_menu.app_alert_menu_action(ctrl)
    local ctrl = formatNull(ctrl);
    globalTable["invoiceUploadCtrl"] = ctrl;
    --debug_alert("APP弹出菜单调用（业务功能） : "..ctrl);

    --关闭菜单
    lua_jjbx.close_add_invoice_menu("");

    --菜单路由函数
    local router_fun = "lua_menu.app_alert_menu_action";
    --菜单关闭函数
    local close_fun = "lua_jjbx.close_add_invoice_menu";
    --获取配置信息
    local PCConfigListsTable = vt("PCConfigListsTable",globalTable);
    --获取菜单开关配置参数
    local MenuEnableConfig = vt("INV0012",PCConfigListsTable);
    --debug_alert("菜单开关配置参数 : "..MenuEnableConfig);

    --上传系统交互参数
    local UploadAppCacheEnclosureParams1 = lua_format.base64_encode(vt("UploadAppCacheEnclosureParams1",globalTable));

    --添加发票功能路由
    if ctrl == "invoice_relate_by_fpc" then
        --debug_alert("前往发票池关联，各个页面自行实现jjbx_relate_invoice()方法");
        jjbx_relate_invoice();
    elseif ctrl == "invoice_add_by_upload" then
        --通过拍照后OCR识别添加至发票池
        local menu_add_by_camera = {
            title="拍照",
            tip=vt("INV0006",PCConfigListsTable),
            fun=router_fun,
            arg="invoice_add_by_camera"
        };
        --通过相册选择后OCR识别添加至发票池
        local menu_add_by_album = {
            title="相册",
            tip=vt("INV0007",PCConfigListsTable),
            fun=router_fun,
            arg="invoice_add_by_album"
        };
        --通过文件系统选择后OCR识别添加至发票池
        local menu_add_by_filesystem = {
            title="从文件选择",
            tip=vt("INV0008",PCConfigListsTable),
            fun=router_fun,
            arg="invoice_add_by_filesystem"
        };
        local menu_info_list = {};
        table.insert(menu_info_list, menu_add_by_camera);
        table.insert(menu_info_list, menu_add_by_album);
        table.insert(menu_info_list, menu_add_by_filesystem);
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
        --debug_alert("弹出二级菜单:"..jsonArg);
        lua_system.app_alert_menu(jsonArg);
    elseif ctrl=="invoice_add_by_camera" or ctrl=="invoice_relate_by_camera" or ctrl=="scan_train_ticket_by_camera" or ctrl =="scan_air_ticket_by_camera" then
        local camera_call = "";
        local uploadFlag = "";
        if ctrl=="invoice_add_by_camera" then
            --debug_alert("通过相机拍照上传识别添加发票");
            camera_call = "lua_jjbx.upload_invoice_to_add_call";
            uploadFlag = "upInvoiceFile";
        elseif ctrl=="invoice_relate_by_camera" then
            --debug_alert("通过相机拍照上传识别关联发票");
            camera_call = "lua_jjbx.upload_invoice_to_relate_call";
            uploadFlag = "upInvoiceFile";
        elseif ctrl=="scan_train_ticket_by_camera" then
            --debug_alert("通过相机拍照上传识别火车票");
            camera_call = "lua_jjbx.upload_train_ticket_to_scan_call";
            uploadFlag = "upTrainTicket";
        elseif ctrl=="scan_air_ticket_by_camera" then
            --debug_alert("通过相机拍照上传识别行程单");
            camera_call = "lua_jjbx.upload_air_ticket_to_scan_call";
            uploadFlag = "upAirTicket";
        else

        end;

        local open_camera_arg = {
            --操作标志 Upload上传，目前只用到上传
            doFlag="Upload",
            --doFlag为上传时，需要定义上传类型
            uploadFlag=uploadFlag,
            --压缩类型，默认Min [No不压缩，Min最小压缩（头像），Normal正常压缩（发票）]
            compressStyle="Normal",
            --单张照片最大尺寸，单位M
            maxSize="20",
            --回调方法
            callback=camera_call,
            --预留参数位1
            params1=UploadAppCacheEnclosureParams1,
            --预留参数位2
            params2="",
            --预留参数位3
            params3=""
        };
        --debug_alert("调用相机 :"..foreach_arg2print(open_camera_arg));
        lua_system.open_camera(open_camera_arg);
    elseif ctrl=="invoice_add_by_album" or ctrl=="invoice_relate_by_album" or ctrl=="scan_train_ticket_by_album" or ctrl=="scan_air_ticket_by_album" then
        local album_call = "";
        local uploadFlag = "";
        local maxCounts = "1";
        --是否上传过程中关闭loading,默认不关闭
        local closeLoading = "false";
        --客户端返回用户选择的文件列表的回调方法
        local backFileListCallFun = "";
        globalTable["invoiceUploadCtrl"] = ctrl;
        if ctrl=="invoice_add_by_album" then
            --debug_alert("通过相册选择上传识别添加发票");
            album_call = "lua_jjbx.upload_invoice_to_add_call";
            uploadFlag = "upInvoiceFile";
            maxCounts = "100";
            closeLoading = "true";
            backFileListCallFun = "get_uploading_file";
        elseif ctrl=="invoice_relate_by_album" then
            --debug_alert("通过相册选择上传识别关联发票");
            album_call = "lua_jjbx.upload_invoice_to_relate_call";
            uploadFlag = "upInvoiceFile";
            maxCounts = "5";
        elseif ctrl=="scan_train_ticket_by_album" then
            --debug_alert("通过相册选择上传识别火车票");
            album_call = "lua_jjbx.upload_train_ticket_to_scan_call";
            uploadFlag = "upTrainTicket";
        elseif ctrl=="scan_air_ticket_by_album" then
            --debug_alert("通过相册选择上传识别行程单");
            album_call = "lua_jjbx.upload_air_ticket_to_scan_call";
            uploadFlag = "upAirTicket";
        else

        end;

        local open_album_arg = {
            --操作标志 Upload上传，目前只用到上传
            doFlag="Upload",
            --doFlag为上传时，需要定义上传类型
            uploadFlag=uploadFlag,
            --压缩类型，默认Min [No不压缩，Min最小压缩（头像），Normal正常压缩（发票）]
            compressStyle="Normal",
            --最大文件数
            maxCounts=maxCounts,
            --超过最大文件数提示
            maxCountsTip="选择图片不能大于"..maxCounts.."张",
            --单张照片最大尺寸，单位M
            maxSize="20",
            --回调方法
            callback=album_call,
            --是否关闭loading
            closeLoading=closeLoading,
            --是否返回用户选择的文件列表名称
            backFileListCallFun=backFileListCallFun,
            --预留参数位1
            params1=UploadAppCacheEnclosureParams1,
            --预留参数位2
            params2="",
            --预留参数位3
            params3=""
        };
        --debug_alert("调用相册 :"..foreach_arg2print(open_album_arg));
        lua_system.open_album(open_album_arg);
    elseif ctrl=="invoice_add_by_filesystem" or ctrl=="invoice_relate_by_filesystem" or ctrl == "scan_train_ticket_by_filesystem" or ctrl == "scan_air_ticket_by_filesystem" or ctrl == "pension_voucher_by_filesystem" then
        --上传成功回调方法
        local filesystem_call = "";
        --上传的单据类型
        local uploadFlag = "";
        --单次可上传最大数量
        local maxCounts = "5";
        --默认支持的文件类型
        local filetype = "pdf,ofd,png,jpg,jpeg,PDF,OFD,PNG,JPG,JPEG";
        --默认支持的文件类型提示语
        local fileTypeMsg = "目前只支持上传pdf,ofd格式的文件和发票图片";
        --默认加载的文件分类
        local loadFileType = "图片,PDF,OFD";
        --是否上传过程中关闭loading,默认不关闭
        local closeLoading = "false";
        --客户端返回用户选择的文件列表的回调方法
        local backFileListCallFun = "";
        --功能类型
        globalTable["invoiceUploadCtrl"] = ctrl;

        if ctrl=="invoice_add_by_filesystem" then
            --debug_alert("通过文件系统选择上传识别添加发票-发票池");
            filesystem_call = "lua_jjbx.upload_invoice_to_add_call";
            uploadFlag = "upInvoiceFile";
            --发票池上传文件时，不显示上传的loading
            closeLoading = "true";
            maxCounts = "50";
            backFileListCallFun = "get_uploading_file";
        elseif ctrl == "scan_train_ticket_by_filesystem" then
            --火车票或机票时，单次可选最多一个
            maxCounts = "1";
            filesystem_call = "lua_jjbx.upload_train_ticket_to_scan_call";
            uploadFlag = "upTrainTicket";
        elseif ctrl == "scan_air_ticket_by_filesystem" then
            maxCounts = "1";
            filesystem_call = "lua_jjbx.upload_air_ticket_to_scan_call";
            uploadFlag = "upAirTicket";
        elseif ctrl == "pension_voucher_by_filesystem" then
            --识别个人养老金凭证
            maxCounts = "1";
            filetype = "pdf,PDF";
            fileTypeMsg = "目前只支持识别PDF格式的文件";
            loadFileType = "PDF";
            filesystem_call = "lua_jjbx.upload_pension_voucher_call";
            uploadFlag = "upPensionVoucher";
        else
            --debug_alert("通过文件系统选择上传识别关联发票-单据关联");
            filesystem_call = "lua_jjbx.upload_invoice_to_relate_call";
            uploadFlag = "upInvoiceFile";
        end;

        local client_file_upload_arg = {
            pagetitle = C_SearchContextBegin.."文件名"..C_SearchContextEnd,
            uploadtype = "multiple",
            counts = maxCounts,
            countsmsg = "选择文件不能大于"..maxCounts.."个",
            filetype = filetype,
            filetypemsg = fileTypeMsg,
            callfun = filesystem_call,
            uploadflag = uploadFlag,
            loadFileType = loadFileType,
            defaultType="PDF",
            closeLoading=closeLoading,
            backFileListCallFun=backFileListCallFun,
            params1=UploadAppCacheEnclosureParams1
        };
        lua_system.client_file_upload(client_file_upload_arg);
    elseif ctrl == "invoice_relate_by_upload" then
        local menu_info_list = {};
        --通过拍照后OCR识别保存关联
        local menu_relate_by_camera = {
            title="拍照",
            tip="",
            fun=router_fun,
            arg="invoice_relate_by_camera"
        };
        --通过相册选择后OCR识别保存关联
        local menu_relate_by_album = {
            title="相册",
            tip="",
            fun=router_fun,
            arg="invoice_relate_by_album"
        };
        --通过文件系统选择后OCR识别保存关联
        local menu_relate_by_filesystem = {
            title="从文件选择",
            tip="",
            fun=router_fun,
            arg="invoice_relate_by_filesystem"
        };
        --[[
        根据参数判断是否添加上传渠道
        if lua_jjbx.invoice_menu_enable_ctrl(MenuEnableConfig,"INVADD02") == "true" then
            table.insert(menu_info_list, menu_relate_by_camera);
        end;
        if lua_jjbx.invoice_menu_enable_ctrl(MenuEnableConfig,"INVADD03") == "true" then
            table.insert(menu_info_list, menu_relate_by_album);
        end;
        if lua_jjbx.invoice_menu_enable_ctrl(MenuEnableConfig,"INVADD04") == "true" then
            table.insert(menu_info_list, menu_relate_by_filesystem);
        end;
        ]]
        --不判断参数，直接添加
        table.insert(menu_info_list, menu_relate_by_camera);
        table.insert(menu_info_list, menu_relate_by_album);
        table.insert(menu_info_list, menu_relate_by_filesystem);
        if #menu_info_list <= 0 then
            alert("无可用添加方式");
            return;
        end;
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
        --debug_alert("弹出二级菜单:"..jsonArg);
        lua_system.app_alert_menu(jsonArg);
    elseif ctrl == "invoice_relate_by_input" then
        --debug_alert("通过手工录入关联发票");
        lua_menu.to_custom_input_invoice_page();
    elseif ctrl == "invoice_add_by_input" then
        --debug_alert("通过手工录入添加发票");
        invoke_page("jjbx_fpc/xhtml/jjbx_invoice_input_save.xhtml",page_callback,{CloseLoading="false"});
    elseif ctrl == "upload_headPic_by_camera" then
        --debug_alert("通过相机拍照上传头像");
        lua_upload.upload_headPic("camera");
    elseif ctrl == "upload_headPic_by_album" then
        --debug_alert("通过相册选择上传头像");
        lua_upload.upload_headPic("album");
    elseif ctrl == "upload_enclosure_by_camera" then
        --debug_alert("通过相机拍照上传附件");
        lua_upload.upload_enclosure("camera");
    elseif ctrl == "upload_enclosure_by_album" then
        --debug_alert("通过相册选择上传附件");
        lua_upload.upload_enclosure("album");
    elseif ctrl == "upload_enclosure_by_filesystem" then
        --debug_alert("通过文件系统上传附件");
        lua_upload.upload_enclosure("filesystem");
    elseif ctrl == "upload_app_cache_enclosure_by_camera" then
        --debug_alert("通过相机拍照上传APP缓存附件");
        lua_upload.upload_app_cache_enclosure("camera");
    elseif ctrl == "upload_app_cache_enclosure_by_album" then
        --debug_alert("通过相册选择上传APP缓存附件");
        lua_upload.upload_app_cache_enclosure("album");
    elseif ctrl == "upload_app_cache_video_by_shoot" then
        --debug_alert("通过相机拍摄上传APP缓存视频附件");
        lua_upload.upload_app_cache_enclosure("shoot_video");
    elseif ctrl == "upload_app_cache_video_by_album" then
        --debug_alert("通过相册选择上传APP缓存视频附件");
        lua_upload.upload_app_cache_enclosure("album_video");
    elseif ctrl == "upload_bank_card_to_scan_by_camera" then
        --debug_alert("通过相机拍照上传银行卡识别图片");
        lua_upload.upload_bank_card_to_scan("camera");
    elseif ctrl == "upload_bank_card_to_scan_by_album" then
        --debug_alert("通过相册选择上传银行卡识别图片");
        lua_upload.upload_bank_card_to_scan("album");
    elseif ctrl == "process_invoice_by_bzd" or ctrl == "process_invoice_by_xcbxd" then
        --发起报销

        --获取选中的发票ID
        local SelectedIdListStr = C_ClientListSelectListArg.SelectedIdListStr;
        --清空
        --C_ClientListSelectListArg.SelectedIdListStr = "";

        --发起报销的发票ID列表
        local ProcessInvoiceIdList = {};

        --按照拼接逻辑进行处理
        local SelectedInvoiceIdList = splitUtils(SelectedIdListStr,",");
        for i=1,#SelectedInvoiceIdList do
            local IdStr = formatNull(SelectedInvoiceIdList[i]);
            if IdStr=="" or IdStr=="," then
            else
                local AddIdStr = string.gsub(IdStr,"'","");
                table.insert(ProcessInvoiceIdList,AddIdStr);
            end;
        end;

        --页面传参
        local InvokePageArg = {ProcessInvoiceIdListJson=table2json({ProcessInvoiceIdList=ProcessInvoiceIdList})};
        if ctrl == "process_invoice_by_bzd" then
            if #ProcessInvoiceIdList > 50 then
                alert("最多可以选择50张，目前选择了"..tostring(#ProcessInvoiceIdList).."张");
            else
                --前往模板选择页面
                globalTable["billType"] = billTypeList_utils.bzd;
                --定义结果页面返回按钮的文字
                globalTable["BillApplyBackBtnText"] = "返回首页";
                lua_bill.to_bill_module_page(InvokePageArg);
            end;
        elseif ctrl=="process_invoice_by_xcbxd" then
            --前往行程报销发起报销页面
            lua_menu.to_porcess_travel_reimbursement_page(InvokePageArg);
        end;
    else
        alert("敬请期待");
    end;
end;

--[[发票报销菜单]]
function lua_menu.process_invoice_by_reimbursement_menu()
    --菜单路由函数
    local router_fun = "lua_menu.app_alert_menu_action";
    --菜单关闭函数
    local close_fun = "lua_jjbx.close_add_invoice_menu";

    --通过报账单报销发票
    local menu1 = {
        title="报账单",
        tip="",
        fun=router_fun,
        arg="process_invoice_by_bzd"
    };
    --通过行程报销单报销发票
    local menu2 = {
        title="行程报销单",
        tip="",
        fun=router_fun,
        arg="process_invoice_by_xcbxd"
    };
    local menu_info_list = {};
    table.insert(menu_info_list, menu1);
    table.insert(menu_info_list, menu2);
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
    --debug_alert("弹出二级菜单:"..jsonArg);
    lua_system.app_alert_menu(jsonArg);
end;

--[[弹出附件上传菜单]]
function lua_menu.alert_upload_enclosure_menu()
    --菜单路由函数
    local router_fun = "lua_menu.app_alert_menu_action";
    --菜单关闭函数
    local close_fun = "lua_system.close_app_alert_menu";
    --菜单参数
    local tableArg = {
        menu_info_list={
            {
                title="拍照",
                tip="",
                fun=router_fun,
                arg="upload_enclosure_by_camera"
            },
            {
                title="相册",
                tip="",
                fun=router_fun,
                arg="upload_enclosure_by_album"
            },
            {
                title="从文件夹选择",
                tip="",
                fun=router_fun,
                arg="upload_enclosure_by_filesystem"
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
    --debug_alert("弹出附件上传菜单 : "..jsonArg);
    lua_system.app_alert_menu(jsonArg);
end;

--[[弹出APP缓存附件上传菜单]]
function lua_menu.alert_upload_app_cache_enclosure_menu(MenuArg)
    local MenuArg = formatNull(MenuArg);

    --支持类型 image,file,video
    local SupportFileType = vt("SupportFileType",MenuArg);

    --菜单路由函数
    local router_fun = "lua_menu.app_alert_menu_action";
    --菜单关闭函数
    local close_fun = "lua_system.close_app_alert_menu";
    --菜单集合
    local menu_info_list = {};

    if string.find(SupportFileType,"image") then
        --添加图片上传菜单
        local imageUploadMenu1 = {
            title="拍照",
            tip="",
            fun=router_fun,
            arg="upload_app_cache_enclosure_by_camera"
        };
        local imageUploadMenu2 = {
            title="相册",
            tip="",
            fun=router_fun,
            arg="upload_app_cache_enclosure_by_album"
        };
        table.insert(menu_info_list,imageUploadMenu1);
        table.insert(menu_info_list,imageUploadMenu2);
    end;
    if string.find(SupportFileType,"file") then
        --添加文件上传菜单（暂未实现）
    end;
    if string.find(SupportFileType,"video") then
        --添加视频上传菜单
        local videoUploadMenu1 = {
            title="拍摄视频",
            tip="",
            fun=router_fun,
            arg="upload_app_cache_video_by_shoot"
        };
        local videoUploadMenu2 = {
            title="从相册选择视频",
            tip="",
            fun=router_fun,
            arg="upload_app_cache_video_by_album"
        };
        table.insert(menu_info_list,videoUploadMenu1);
        table.insert(menu_info_list,videoUploadMenu2);
    end;

    if #menu_info_list > 0 then
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
        --debug_alert("弹出APP缓存附件上传菜单 : "..jsonArg);
        lua_system.app_alert_menu(jsonArg);
    else
        debug_alert("菜单为空");
    end;
end;

--[[弹出扫描银行卡菜单]]
function lua_menu.alert_upload_bank_card(widgetname)
    --定义识别成功后设置OCR卡号的控件名
    globalTable["CardNoWidgetName"] = widgetname;

    --菜单路由函数
    local router_fun = "lua_menu.app_alert_menu_action";
    --菜单关闭函数
    local close_fun = "lua_system.close_app_alert_menu";
    --菜单参数
    local tableArg = {
        menu_info_list={
            {
                title="拍照",
                tip="",
                fun=router_fun,
                arg="upload_bank_card_to_scan_by_camera"
            },
            {
                title="相册",
                tip="",
                fun=router_fun,
                arg="upload_bank_card_to_scan_by_album"
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
    --debug_alert("弹出扫描银行卡菜单 : "..jsonArg);
    lua_system.app_alert_menu(jsonArg);
end;

--[[首页滚动广告配置]]
function lua_menu.get_index_advert()
    local res = {};
    local paddingStr = "";
    if platform =="iPhone OS" then
        paddingStr = "\"";
    else
        --Android解析需要多给一个转移符
        paddingStr = "\\\"";
    end;

    --投诉建议
    local tsjyItem = {src="local:index_bannerBottom_tsjy.png", onClick="indexPage_advert_router("..paddingStr.."tsjy"..paddingStr..")"};
    --极简大事记
    local jjdsjItem = {src="local:index_bannerBottom_jjdsj_2022.png", onClick="indexPage_advert_router("..paddingStr.."jjdsj"..paddingStr..")"};
    --商旅服务
    local slfwItem = {src="local:index_bannerBottom_slfw.png", onClick="indexPage_advert_router("..paddingStr.."slfw"..paddingStr..")"};
    --在线采购
    local zxcgItem = {src="local:index_bannerBottom_zxcg.png", onClick="indexPage_advert_router("..paddingStr.."zxcg"..paddingStr..")"};
    --用车出行
    local yccxItem = {src="local:index_bannerBottom_yccx.png", onClick="indexPage_advert_router("..paddingStr.."yccx"..paddingStr..")"};
    --用餐服务
    local ycfwItem = {src="local:index_bannerBottom_ycfw.png", onClick="indexPage_advert_router("..paddingStr.."ycfw"..paddingStr..")"};

    if globalTable["userType"] == "2" then
        --被共享人存在场景时添加
        local sharePeopleScene = vt("sharePeopleScene",globalTable);
        --采购（京东或者E家银）
        if string.find(sharePeopleScene,JJBX_SharePeopleSecneCode.zxcg) or string.find(sharePeopleScene,JJBX_SharePeopleSecneCode.ejyshop) then
            table.insert(res,zxcgItem);
        end;
        --用车
        if string.find(sharePeopleScene,JJBX_SharePeopleSecneCode.yccx) then
            table.insert(res,yccxItem);
        end;
        --用餐
        local ycfwConfigList = splitUtils(JJBX_SharePeopleSecneCode.ycfw,",");
        local ycfwMatchRes = "false";
        for i=1, #ycfwConfigList do
            if string.find(sharePeopleScene,ycfwConfigList[i]) then
                ycfwMatchRes = "true";
                break
            end;
        end;
        if ycfwMatchRes == "true" then
            table.insert(res,ycfwItem);
        end;
    else
        table.insert(res,tsjyItem);
        --table.insert(res,jjdsjItem);
        table.insert(res,slfwItem);
        table.insert(res,zxcgItem);
        table.insert(res,yccxItem);
        table.insert(res,ycfwItem);
    end;

    return res;
end;

--[[我的菜单配置]]
function lua_menu.myinfo_menu_config()
    local userType = vt("userType",globalTable);
    local PCConfigListsTable = vt("PCConfigListsTable",globalTable);

    local res = {};
    if userType ~= "2" then
        table.insert(
            res,
            {
                Name="银行卡管理",
                Icon="mine_ico_01.png",
                Func="lua_menu.to_card_management_page()"
            }
        );
    end;

    if userType ~= "2" then
        table.insert(
            res,
            {
                Name="信用值",
                Icon="mine_ico_02.png",
                Func="lua_menu.to_credit_management_page()"
            }
        );
    end;

    table.insert(
        res,
        {
            Name="安全中心",
            Icon="mine_ico_03.png",
            Func="lua_menu.to_security_center_page()"
        }
    );

    if userType ~= "2" then
        table.insert(
            res,
            {
                Name="共享人管理",
                Icon="mine_ico_sharepm.png",
                Func="lua_menu.to_share_people_manage_page()"
            }
        );
    end;

    table.insert(
        res,
        {
            Name="消息设置",
            Icon="mine_ico_04.png",
            Func="lua_menu.to_msg_setting_page()"
        }
    );

    table.insert(
        res,
        {
            Name="隐私",
            Icon="ico_private.png",
            Func="lua_menu.to_protocol_menu_page()"
        }
    );

    table.insert(
        res,
        {
            Name="联系我们",
            Icon="mine_ico_05.png",
            Func="lua_menu.to_contactUs_page()"
        }
    );
    return  res;
end;

--[[第三方APP打开福利页面]]
function lua_menu.to_budget_page_by_other_app(ArgObj)
    --debug_alert(foreach_arg2print("第三方APP打开福利页面"..foreach_arg2print(ArgObj)));

    --渠道名称 浙商手机银行:CzbankMobileBankApp
    local OpenByAppName = vt("OpenByAppName",ArgObj);
    if OpenByAppName == "CzbankMobileBankApp" then
        --获取协商的打开页面类型
        local JJBXAppOpenPage = vt("JJBXAppOpenPage",ArgObj);

        --获取当前页面
        local CurrentPageInfo = lua_page.current_page_info();
        local PageFilePath = vt("page_file_path",CurrentPageInfo);

        --[[debug_alert(
            "当前打开页面 : "..PageFilePath.."\n"..
            "目标页面类型 : "..JJBXAppOpenPage.."\n"..
            ""
        );]]

        --调试打开页面
        --JJBXAppOpenPage = "TravelXieCheng";

        --打开成功后，清理任务参数
        lua_mission.clear_app_register_mission({ClearMsg="打开成功"});

        if JJBXAppOpenPage == "TravelTongCheng" then
            --同程商旅
            init_travel_reserve_h5_page('tongcheng')
        elseif JJBXAppOpenPage == "TravelXieCheng" then
            --携程商旅
            init_travel_reserve_h5_page('xiecheng');
        else
            local visitMenuId = "";
            if JJBXAppOpenPage=="CarService" then
                --用车
                visitMenuId = "yccx";
            elseif JJBXAppOpenPage == "TravelService" then
                --商旅
                visitMenuId = "slfw";
            elseif JJBXAppOpenPage == "EatELMe" then
                --用餐服务
                visitMenuId = "ycfw";
            else

            end;
            if visitMenuId ~= "" then
                local serverMenuConfig = lua_menu.server_menu_info(visitMenuId);
                --服务端菜单信息
                local serverMenuInfo = vt("menuInfo",serverMenuConfig);
                local menuUrl = vt("url",serverMenuInfo);
                if PageFilePath == menuUrl then
                    --debug_alert("当前页面已经打开，不重复跳转");
                else
                    history:clear();
                    lua_menu.onclick("id="..visitMenuId);
                end;
            else
                --业务参数为空时，不做任何操作
                --alert("没有访问权限");
            end;
        end;
    else
        alert("未知渠道 "..OpenByAppName);
    end;
end;

function open_file_system()
    --是否不压栈返回
    globalTable["uploadInvoiceBack"] = "true";
    --上传系统交互参数
    local UploadAppCacheEnclosureParams1 = lua_format.base64_encode(vt("UploadAppCacheEnclosureParams1",globalTable));
    local client_file_upload_arg = {
        pagetitle = C_SearchContextBegin.."文件名"..C_SearchContextEnd,
        uploadtype = "multiple",
        counts = "5",
        countsmsg = "选择文件不能大于5个",
        filetype = "pdf,ofd,png,jpg,jpeg,PDF,OFD,PNG,JPG,JPEG",
        filetypemsg = "目前只支持上传pdf,ofd格式的文件和发票图片",
        callfun = "lua_jjbx.upload_invoice_to_relate_call",
        uploadflag = "upInvoiceFile",
        loadFileType = "图片,PDF,OFD",
        defaultType = "PDF",
        params1=UploadAppCacheEnclosureParams1
    };
    lua_system.client_file_upload(client_file_upload_arg);
end;