--[[帮助与反馈用到的lua函数]]

lua_ask = {};

--常见问题列表查询参数(AskQuestionRecordListQryArg)
AQRLQArg = {
    --查询类型
    qryFlag="",
    --搜索关键字
    searchKeyWords=""
};

--[[前往帮助反馈首页]]
function lua_ask.to_ask_index_page()
    local FeedbackListInstall = lua_system.check_app_func("feedback_list");
    --调试
    --FeedbackListInstall = "true";
    if FeedbackListInstall == "true" then
        --帮助是否启用，多选，01开启功能指南，02开启问题反馈，03开启帮助反馈
        local SYS0024Value = vt("SYS0024Value",globalTable);
        --debug_alert("lua_ask.to_ask_index_page SYS0024 : "..SYS0024Value);
        if string.find(SYS0024Value,"01") then
            --功能指南
            lua_ask.to_user_ask_page(1);
        elseif string.find(SYS0024Value,"02") then
            --常见问题
            lua_ask.to_user_ask_page(2);
        elseif string.find(SYS0024Value,"03") then
            --问题反馈
            lua_ask.to_user_ask_page(3);
        else
            alert("功能未启用");
        end;
    else
        --更新提示
        local upverArg = {
            updateType="OPTION",
            updateMsg="服务已经升级，请更新后使用。"
        };
        lua_ota.show_upvsr_view(upverArg);
    end;
end;

--[[前往帮助反馈页面]]
function lua_ask.to_user_ask_page(TargetPageId,InvokePageArg)
    local TargetPageId = formatNull(TargetPageId,1);
    local NowPageId = vt("AskIndexBannerFlag",globalTable,0);

    --页面参数
    local InvokePageArg = formatNull(InvokePageArg,{});
    InvokePageArg["CloseLoading"] = "false";

    if NowPageId == 0 then
        InvokePageArg["JumpStyle"] = "right";
    else
        --互相之间跳转，没有跳转效果
        InvokePageArg["JumpStyle"] = "none";
    end;

    local InvokePageUrl = "";

    if TargetPageId == 1 then
        --功能指南
        InvokePageUrl = "jjbx_ask/ask_instructions.xhtml";
    elseif TargetPageId == 2 then
        --常见问题
        InvokePageUrl = "jjbx_ask/ask_question.xhtml";
        --分页参数初始化
        lua_page_list.init_qry_arg("ask_question_list");
        --查询参数初始化
        lua_format.reset_table(AQRLQArg);
    elseif TargetPageId == 3 then
        --问题反馈
        InvokePageUrl = "jjbx_ask/ask_feedback.xhtml";
        --分页参数初始化
        lua_page_list.init_qry_arg("latest_ask_feedback_list");
    elseif TargetPageId == 4 then
        --反馈列表
        InvokePageUrl = "jjbx_ask/feedback_list.xhtml";
        --分页参数初始化
        lua_page_list.init_qry_arg("ask_feedback_list");
    elseif TargetPageId == 5 then
        --反馈详情
        InvokePageUrl = "jjbx_ask/feedback_detail.xhtml";
    elseif TargetPageId == 6 then
        --新建反馈
        InvokePageUrl = "jjbx_ask/add_feedback_input.xhtml";
    elseif TargetPageId == 7 then
        --反馈结果
        InvokePageArg["AddPage"] = "false";
        InvokePageUrl = "jjbx_ask/add_feedback_result.xhtml";
    elseif TargetPageId == "feedback_reply" then
        --反馈回复
        InvokePageUrl = "jjbx_ask/feedback_reply.xhtml";
    elseif TargetPageId == "feedback_trans_reply" then
        --转办
        InvokePageUrl = "jjbx_ask/feedback_trans_reply.xhtml";
    else
        debug_alert("帮助页面未找到");
        InvokePageUrl = "jjbx_ask/ask_instructions.xhtml";
    end;

    --[[debug_alert(
        "前往帮助反馈页面\n"..
        "TargetPageId : "..tostring(TargetPageId).."\n"..
        "NowPageId : "..tostring(NowPageId).."\n"..
        "InvokePageUrl : "..InvokePageUrl.."\n"..
        ""
    );]]

    if InvokePageUrl ~= "" then
        invoke_page_donot_checkRepeat(InvokePageUrl, page_callback, InvokePageArg);
    end;
end;

--[[帮助消息跳转]]
function lua_ask.ask_msg_jump(Arg)
    local messageSubclassEn = vt("messageSubclassEn",Arg);
    if messageSubclassEn == "functionGuide" then
        --功能指南通知
        lua_ask.to_user_ask_page(1);
    elseif messageSubclassEn == "frequentQuestion" then
        --常见问题通知
        lua_ask.to_user_ask_page(2);
    end;
end;

--[[帮助首页返回]]
function lua_ask.index_back()
    --清理缓存
    globalTable["AskIndexBannerFlag"] = "";
    --回到首页
    lua_menu.back_to_index();
end;

--[[渲染底部banner]]
function lua_ask.render_index_banner()
    --帮助是否启用，多选，01开启功能指南，02开启常见问题，03开启问题反馈
    local SYS0024Value = vt("SYS0024Value",globalTable);
    --共享人员登录不启用问题反馈
    if globalTable["userType"] == "2" then
        SYS0024Value = string.gsub(SYS0024Value,",03","");
        SYS0024Value = string.gsub(SYS0024Value,"03","");
    end;
    --debug_alert("lua_ask.render_index_banner SYS0024 : "..SYS0024Value);
    local Border = "0";

    --菜单个数
    local BannerCounts = tostring(#splitUtils(SYS0024Value,","));
    local ShowBannerCounts = 0;

    --功能指南
    local InstructionBanner = "";
    if string.find(SYS0024Value,"01") then
        ShowBannerCounts = ShowBannerCounts +1;
        local Onclick = "lua_ask.index_banner_click(1)";
        local DivClass = "ask_index_banner"..tostring(BannerCounts).."-"..tostring(ShowBannerCounts).."_div";
        local IconClass = "ask_index_banner"..tostring(BannerCounts).."_icon";
        local LabelClass = "ask_index_banner"..tostring(BannerCounts).."_label";
        InstructionBanner = [[
            <div class="]]..DivClass..[[" border="]]..Border..[[" onclick="]]..Onclick..[[">
                <img src="local:ask_banner1.png" class="]]..IconClass..[[" name="ask_index_banner_icon" onclick="]]..Onclick..[[" />
                <label value="功能指南" class="]]..LabelClass..[[" name="ask_index_banner_label" onclick="]]..Onclick..[[" />
            </div>
        ]];
    end;

    --常见问题
    local QuestionBanner = "";
    if string.find(SYS0024Value,"02") then
        ShowBannerCounts = ShowBannerCounts +1;
        local Onclick = "lua_ask.index_banner_click(2)";
        local DivClass = "ask_index_banner"..tostring(BannerCounts).."-"..tostring(ShowBannerCounts).."_div";
        local IconClass = "ask_index_banner"..tostring(BannerCounts).."_icon";
        local LabelClass = "ask_index_banner"..tostring(BannerCounts).."_label";
        QuestionBanner = [[
            <div class="]]..DivClass..[[" border="]]..Border..[[" onclick="]]..Onclick..[[">
                <img src="local:ask_banner2.png" class="]]..IconClass..[[" name="ask_index_banner_icon" onclick="]]..Onclick..[[" />
                <label value="常见问题" class="]]..LabelClass..[[" name="ask_index_banner_label" onclick="]]..Onclick..[[" />
            </div>
        ]];
    end;

    --问题反馈
    local FeedbackBanner = "";
    if string.find(SYS0024Value,"03") then
        ShowBannerCounts = ShowBannerCounts +1;
        local Onclick = "lua_ask.index_banner_click(3)";
        local DivClass = "ask_index_banner"..tostring(BannerCounts).."-"..tostring(ShowBannerCounts).."_div";
        local IconClass = "ask_index_banner"..tostring(BannerCounts).."_icon";
        local LabelClass = "ask_index_banner"..tostring(BannerCounts).."_label";
        FeedbackBanner = [[
            <div class="]]..DivClass..[[" border="]]..Border..[[" onclick="]]..Onclick..[[">
                <img src="local:ask_banner3.png" class="]]..IconClass..[[" name="ask_index_banner_icon" onclick="]]..Onclick..[[" />
                <label value="问题反馈" class="]]..LabelClass..[[" name="ask_index_banner_label" onclick="]]..Onclick..[[" />
            </div>
        ]];
    end;

    local Html = [[
        <div class="ask_index_banner_div" name="ask_index_banner_div" border="]]..Border..[[" >
            <line class="line_css" />]]..
            InstructionBanner..
            QuestionBanner..
            FeedbackBanner..[[
        </div>
    ]];

    --[[debug_alert(
        "渲染底部banner\n"..
        "SYS0024Value : "..SYS0024Value.."\n"..
        "BannerCounts : "..tostring(BannerCounts).."\n"..
        "Html : "..Html.."\n"..
        ""
    );]]

    document:getElementsByName("ask_index_banner_div")[1]:setInnerHTML(Html);
    page_reload();
end;

--[[底部banner切换]]
function lua_ask.index_banner_click(ClickIndex)
    local ClickIndex = formatNull(ClickIndex);
    local AskIndexBannerFlag = vt("AskIndexBannerFlag",globalTable);

    --[[debug_alert(
        "底部banner切换\n"..
        "ClickIndex : "..tostring(ClickIndex).."\n"..
        "AskIndexBannerFlag : "..tostring(AskIndexBannerFlag).."\n"..
        ""
    );]]

    if ClickIndex > 0 then
        local iconEleobjs = document:getElementsByName("ask_index_banner_icon");
        local labelEleobjs = document:getElementsByName("ask_index_banner_label");
        for i=1,#iconEleobjs do
            local iconEleobj = iconEleobjs[i];
            local labelEleobj = labelEleobjs[i];
            if ClickIndex == i then
                --设置选中
                iconEleobj:setPropertyByName("src","ask_banner"..tostring(i)..".png");
                labelEleobj:setStyleByName("color","#F9601F");
            else
                --设置未选中
                iconEleobj:setPropertyByName("src","ask_banner"..tostring(i).."_disable.png");
                labelEleobj:setStyleByName("color","#999999");
            end;
        end;
    end;

    if ClickIndex~=AskIndexBannerFlag then
        globalTable["AskIndexBannerFlag"] = ClickIndex;
        lua_ask.to_user_ask_page(ClickIndex);
    end;
end;

--[[删除反馈详情]]
function lua_ask.del_feedback(DelArg)
    --debug_alert("删除"..foreach_arg2print(foreach_arg2print(json2table(DelArg))));
    lua_ask.do_del_feedback("",json2table(DelArg));
end;

--[[删除反馈详情]]
function lua_ask.do_del_feedback(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams,{});
        ReqParams["ReqAddr"] = "question/fb/delete";
        ReqParams["ReqUrlExplain"] = "我的反馈删除";

        local BusinessParams = {
            pkQuestion=vt("pkQuestion",ReqParams)
        };
        ReqParams["BusinessParams"] = table2json(BusinessParams);
        --debug_alert("我的反馈删除-请求"..foreach_arg2print(ReqParams));

        ReqParams["BusinessCall"] = lua_ask.do_del_feedback;
        ReqParams["ResCallFunc"] = vt("ResCallFunc",ReqParams);
        lua_jjbx.common_req(ReqParams);
    else
        local res = json2table(ResParams["responseBody"]);
        --debug_alert("我的反馈删除-请求"..foreach_arg2print(res));
        local errorNo = vt("errorNo",res);
        local errorMsg = vt("errorMsg",res);
        if errorNo == "000000" then
            lua_system.do_function(vt("ResCallFunc",ResParams),"");
        else
            alert(errorMsg);
        end;
    end;
end;

--[[查看反馈详情]]
function lua_ask.view_feedback_detail(Data)
    --debug_alert("反馈详情"..foreach_arg2print(Data));
    local questionState = vt("questionState",Data);
    if questionState == "1" then
        lua_ask.to_user_ask_page(5,Data);
    else
        lua_ask.to_user_ask_page(6,Data);
    end;
end;

--[[打开指南或问题界面]]
function lua_ask.open_ask_page(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams,{});
        ReqParams["TranCode"] = "InitAskUrl";
        --debug_alert("打开指南或问题界面-请求"..foreach_arg2print(ReqParams));

        local AskUrlType = vt("AskUrlType",ReqParams);
        if AskUrlType == "1" then
            --指南添加权限判断
            local ReqFuncode = vt("Funcode",ReqParams);
            local FindRes = lua_ask.find_permission_funcode({FuncCode=ReqFuncode});
            local FuncAbb = vt("FuncAbb",FindRes);

            --报销权限检查
            if FuncAbb=="bxsq" and processBillFlag=="disenable" then
                alert(processBillCheckMsg);
                return;
            end;

            --采购权限检查
            if FuncAbb == "zxcg" then
                local MatchRes = lua_jjbx.user_fun_match({FunCode="0301"});
                local Matched = vt("Matched",MatchRes);
                if Matched ~= "true" then
                    --提示权限限制信息
                    alert(onlineShoppingCheckMsg);
                    return;
                end;
            end;

            --用车权限检查
            if FuncAbb == "yccx" then
                local MatchRes = lua_jjbx.user_fun_match({FunCode="0401"});
                local Matched = vt("Matched",MatchRes);
                if Matched ~= "true" then
                    --提示权限限制信息
                    alert(carServiceCheckMsg);
                    return;
                end;
            end;

            --用餐权限检查
            if FuncAbb == "ycfw" then
                local MatchRes = lua_jjbx.user_fun_match({FunCode="0301"});
                local Matched = vt("Matched",MatchRes);
                if Matched~="true" or eatServiceFlag=="disenable" then
                    --提示权限限制信息
                    alert(eatServiceCheckMsg);
                    return;
                end;
            end;

            --商旅权限检查
            if FuncAbb == "slfw" and travelServiceFlag == "disenable" then
                alert(travelServiceCheckMsg);
                return;
            end;
        end;

        invoke_trancode_donot_checkRepeat(
            "jjbx_page",
            "webview_page",
            ReqParams,
            lua_ask.open_ask_page,
            {},
            all_callback,
            {CloseLoading="false"}
        );
    else
        close_loading();
        local res = json2table(ResParams["responseBody"]);
        --debug_alert("打开指南或问题界面-响应"..foreach_arg2print(res));

        local webview_url = vt("webview_url",res);
        local Funcode = vt("Funcode",res);

        if webview_url ~= "" then
            --debug_alert("打开指南或问题界面\n"..webview_url);
            local title = "";
            local RightLabelText = "";
            local RightLabelFunc = "";
            local RightLabelClickClose = "";
            if vt("AskUrlType",res) == "1" then
                RightLabelText = "常见问题";
                RightLabelFunc = "h5_to_question_page('"..Funcode.."')";
                RightLabelClickClose = "true";
                title = "功能指南";
            else
                title = "常见问题";
            end;

            lua_system.alert_webview(
                {
                    title=title,
                    visit_url=webview_url,
                    back_type="BACK",
                    RightLabelText=RightLabelText,
                    RightLabelFunc=RightLabelFunc,
                    RightLabelClickClose=RightLabelClickClose
                }
            );
        else
            debug_alert("链接为空");
        end;
    end;
end;

--[[帮助跳转常见问题]]
function h5_to_question_page(Funcode)
    lua_ask.to_user_ask_page(2,{Funcode=Funcode});
end;

--[[查找功能编码]]
function lua_ask.find_permission_funcode(Arg)
    local QryFuncAbb = vt("FuncAbb",Arg);
    local QryFuncCode = vt("FuncCode",Arg);

    local res = {};
    for i=1,#JJBX_ASK_PERMISSION_INFO do
        local Data = formatNull(JJBX_ASK_PERMISSION_INFO[i]);
        --debug_alert(foreach_arg2print(Data));
        local FuncAbb = vt("FuncAbb",Data);
        local FuncName = vt("FuncName",Data);
        local FuncCode = vt("FuncCode",Data);
        local QryFlag = vt("QryFlag",Data);
        --debug_alert(FuncAbb.."-"..FuncCode);

        if QryFuncAbb == FuncAbb then
            res["FuncAbb"] = FuncAbb;
            res["FuncName"] = FuncName;
            res["FuncCode"] = FuncCode;
            res["QryFlag"] = QryFlag;            
            break
        elseif QryFuncCode == FuncCode then
            res["FuncAbb"] = FuncAbb;
            res["FuncName"] = FuncName;
            res["FuncCode"] = FuncCode;
            res["QryFlag"] = QryFlag;            
            break
        end;
    end;
    return res;
end;

--[[创建帮助浮层]]
function lua_ask.create_help_floating(FuncAbb)
    local Html = "";
    local DisPlayCss = "";

    if lua_ask.switch() == "true" then
        --追加样式
        local AddStyle = "";
        --获取顶部位置
        local SetTop = systemTable["phoneInfo"]["screenUseHeight"]-get_bottom_diff()-150-58;
        AddStyle = "top:"..SetTop.."px;";
        Html = [[
            <div class="floating_help_icon_div" style="]]..AddStyle..[[" name="drag_ctrl_ele1" onclick="lua_ask.floating_help_click(']]..FuncAbb..[[')" border="0" />
        ]]
    end;

    return Html;
end;

--[[帮助浮层点击]]
function lua_ask.floating_help_click(FuncAbb)
    local FindRes = lua_ask.find_permission_funcode({FuncAbb=FuncAbb})
    local Funcode = vt("FuncCode",FindRes);
    if Funcode ~= "" then
        local ReqParams = {
            AskUrlType="1",
            Funcode=Funcode
        };
        lua_ask.open_ask_page("",ReqParams);
    else
        alert("功能编码为空");
    end;
end;

--[[设置帮助浮层拖动]]
function lua_ask.floating_drag()
    --设置帮助拖动监听
    if lua_ask.switch() == "true" then
        AniSetDragArg1["DragEleNames"] = "drag_ctrl_ele1";
        AniSetDragArg1["DragXStyleCtrl"] = "";
        AniSetDragArg1["DragYStyleCtrl"] = "CloseToRight";
        lua_animation.set_drag_listener(AniSetDragArg1);
    end;
end;

--[[帮助是否启用]]
function lua_ask.switch()
    --返回启用状态 
    local res = "";

    local FeedbackListInstall = lua_system.check_app_func("feedback_list");
    --检查是否安装功能
    if FeedbackListInstall == "true" then
        local PCConfigListsTable = vt("PCConfigListsTable",globalTable);
        --帮助是否启用，为空不启用
        local SYS0024Value = vt("SYS0024",PCConfigListsTable);
        --存缓存
        globalTable["SYS0024Value"] = SYS0024Value;
        --debug_alert("lua_ask.switch SYS0024 : "..globalTable["SYS0024Value"]);

        if SYS0024Value == "" then
            res = "false";
        else
            res = "true";
        end;
    else
        --未安装功能
        res = "false";
    end;

    return res;
end;

--[[查询反馈问题类型列表]]
function lua_ask.qry_feedback_type(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams,{});
        ReqParams["ReqAddr"] = "basfileContent/createContentTreeListForApp";
        ReqParams["ReqUrlExplain"] = "帮助-查询反馈问题类型列表";

        local BusinessParams = {
            filecode="ELS-008"
        };
        ReqParams["BusinessParams"] = table2json(BusinessParams);
        --debug_alert("问题类型列表查询-请求"..foreach_arg2print(ReqParams));

        ReqParams["BusinessCall"] = lua_ask.qry_feedback_type;
        lua_jjbx.common_req(ReqParams);
    else
        local res = json2table(ResParams["responseBody"]);
        --debug_alert("问题类型列表查询-请求"..foreach_arg2print(res));
        local feedback_questionType_list = res["treeJsonArray"];
        globalTable["feedback_questionType_list"] = feedback_questionType_list;
        changeProperty("wtlx_widget","value",table2json(res["treeJsonArray"]));
        --渲染反馈问题类型
        --render_feedback_type(feedback_questionType_list);
    end;
end;


