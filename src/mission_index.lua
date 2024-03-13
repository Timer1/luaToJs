--[[极简报销首页任务实现]]

lua_index_mission = {};

--[[####################引导页展示分析Begin####################]]
--[[引导页展示分析]]
function lua_index_mission.analysis_show_lead()
    --debug_alert("执行引导页展示分析"..os.time());

    --用当前服务端配置的版本，与客户端存储的版本进行比较，确认当前版本是否需要引导提示
    local IndexLeadPageVersion = vt("IndexLeadPageVersion",configTable);
    --debug_alert("lua_index_mission.show_lead IndexLeadPageVersion :"..IndexLeadPageVersion);
    local show_lead = lua_index_mission.need_lead(IndexLeadPageVersion);
    --debug_alert("lua_index_mission.show_lead show_lead :"..show_lead);

    --调试
    if lua_mission.index_debug() == "true" then
        show_lead = "true";
    end;

    if show_lead == "true" then
        --创建首页引导页
        lua_index_mission.create_index_lead_page();
        --存储引导页新手遮罩对应的版本号
        set_db_value("IndexLeadPageVersion",IndexLeadPageVersion);
        --iPhoneX全屏显示
        index_page_iPhoneX_ctrl("hide");
        --显示引导页容器
        show_ele("lead_page_bg_div");
        --Android状态栏颜色修改
        set_android_top_bar_color("#090813");
        --显示引导页
        lua_index_mission.show_lead(1);
    else
        --完成当前任务并处理后续任务
        lua_mission.index_handle();
    end;
end;

--[[创建首页引导页]]
function lua_index_mission.create_index_lead_page()
    --适配背景高度为全屏
    height_adapt("lead_page_bg_div",0,0);

    local lead_page_icon_html = "";
    local lead_page_btn_html = "";

    --4张图
    for i=1,4 do
        local index = tostring(i);
        local next = tostring(i+1);

        lead_page_icon_html = lead_page_icon_html..[[
            <img src="local:lead_page_icon]]..index..[[.png" class="lead_page_icon]]..index..[[" name="lead_page_icon"/>
        ]];

        local btn_img_src = "local:lead_page_btn"..index..".png";
        local btn_class = "lead_page_btn_none";
        local btn_onclick = "lua_index_mission.show_lead("..next..")";
        if i==1 then
            --第一张按钮要显示，其他的隐藏
            btn_img_class = "lead_page_btn_block";
        elseif i==4 then
            --最后一张按钮要关闭控件
            btn_onclick = "lua_index_mission.close_lead()";
        end;

        lead_page_btn_html = lead_page_btn_html..[[
            <img src="]]..btn_img_src..[[" class="]]..btn_class..[[" name="lead_page_btn" onclick="]]..btn_onclick..[[" />
        ]];
    end;

    local lead_page_html = [[
        <div class="lead_page_bg_div" name="lead_page_bg_div" border="0" onclick="">
            <div class="lead_page_div_]]..systemTable['SysLayoutStyle']..[[" border="0" name="lead_page_div">
                ]]..lead_page_icon_html..[[
                ]]..lead_page_btn_html..[[
            </div>
        </div>
    ]];
    document:getElementsByName("lead_page_bg_div")[1]:setInnerHTML(lead_page_html);

    --适配容器高度，由于遮罩背景已经全屏适配，这个层不指定头部差异为0
    height_adapt("lead_page_div",0);

    page_reload();
end;

--[[检查首页当前版本是否需要引导提示]]
function lua_index_mission.need_lead(ServerV)
    --客户端保存的版本号
    local LocalV = get_db_value("IndexLeadPageVersion");
    --服务端配置的版本号
    local ServerV = formatNull(ServerV);

    local ShowIndexLeadPage = "false";
    if LocalV == "" then
        --客户端本地未保存版本
        if ServerV == "" then
            --服务器未配置版本无操作
        else
            --服务器有配置版本展示引导页
            ShowIndexLeadPage = "true";
        end;
    else
        --客户端本地有保存版本
        if LocalV == ServerV then
            --客户端和服务器版本一致无操作
        else
            --客户端和服务器版本不一致展示引导层
            ShowIndexLeadPage = "true";
        end;
    end;

    --[[debug_alert(
        "新手引导页:\n"..
        "数据库读取版本:"..LocalV.."\n"..
        "配置版本:"..ServerV.."\n"..
        "是否展示:"..ShowIndexLeadPage.."\n"..
        ""
    );]]

    return ShowIndexLeadPage;
end;

--[[开启首页引导页]]
function lua_index_mission.show_lead(index)
    local nextPages = document:getElementsByName("lead_page_icon");
    local nextBtns  = document:getElementsByName("lead_page_btn");
    for i=1,#nextBtns do
        if i == index then
            nextBtns[i]:setStyleByName("display","block");
            nextPages[i]:setStyleByName("display","block");
        else
            nextBtns[i]:setStyleByName("display","none");
            nextPages[i]:setStyleByName("display","none");
        end;
    end;
end;

--[[关闭首页引导页]]
function lua_index_mission.close_lead()
    --debug_alert("lua_index_mission.close_lead");
    --还原iPhoneX底部显示
    index_page_iPhoneX_ctrl("show");
    --还原Android状态栏
    set_android_top_bar_image("index_top_bar_up.png");
    --隐藏引导页容器
    hide_ele("lead_page_bg_div");

    --完成首页引导页任务并调用任务处理
    --debug_alert("完成首页引导页任务并调用任务处理，任务编号 : "..globalTable["IndexPageMissionIndex"]);
    lua_mission.index_handle();
end;
--[[####################引导页展示分析End####################]]

--[[####################发布消息提示分析Begin####################]]
--[[分析是否需要展示发布消息]]

--对账待确认消息
function lua_index_mission.analysis_show_confirm_collection()
    lua_index_mission.query_Common_hint("",{});
end;

function lua_index_mission.query_Common_hint(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        ReqParams = formatNull(ReqParams,{});
        ReqParams["ReqAddr"] = "pubUserHint/queryCommonHint";
        ReqParams["ReqUrlExplain"] = "查询消息是否弹窗";
        local BusinessParams = {
            channal=vt("channal",ReqParams,"009")
        };
        ReqParams["BusinessParams"] = table2json(BusinessParams);
        ReqParams["BusinessCall"] = lua_index_mission.query_Common_hint;
        lua_jjbx.common_req(ReqParams);
    else
        local responseBody = json2table(ResParams["responseBody"]);
        if vt("value",responseBody) == "0" then
            lua_index_mission.do_analysis_show_confirm_collection();        
        else
            lua_mission.index_handle();
        end;
    end;
end;

function lua_index_mission.do_analysis_show_confirm_collection(params)
    if MsgCenterFlag == "disenable" then
        --debug_alert("没有权限时不查询弹出消息，直接回调任务序列");
        lua_mission.index_handle();
    else
        local params = formatNull(params);
        if params == "" then
            --debug_alert("执行分析是否需要展示发布消息-请求"..os.time());
            --查询发布消息
            local ReqParams = {};
            ReqParams["ReqAddr"] = "bankDepositReconciliation/querySubBankTransactionRecord";
            ReqParams["ReqUrlExplain"] = "查询发布的对账待确认消息";
            local BusinessParams = {
                pagenum="1",
                pagesize="1",
                status = "0"
            };
            ReqParams["BusinessParams"] = table2json(BusinessParams);
            ReqParams["BusinessCall"] = lua_index_mission.do_analysis_show_confirm_collection;
            lua_jjbx.common_req(ReqParams);
        else
            local responseBody = json2table(params["responseBody"]);
            --debug_alert("执行分析是否需要展示发布消息-响应"..foreach_arg2print(responseBody));
            local showMsgList = vt("recordList",responseBody);
            local showMsgListCounts = #showMsgList;
            --debug_alert(showMsgListCounts);

            if showMsgListCounts > 0 then
                --消息单条信息拼接
                local MsgItemTable = {};

                --循环拼接
                for key,value in pairs(showMsgList) do
                    local ItemData = formatNull(value);
                    --消息类型（不查询消息列表，所以在这里规定消息类型）
                    ItemData["messageSubclassEn"] = "bankTransactionAuthorization";
                    --操作下标
                    local MsgCtrlIndex = tostring(key);
                    --标题
                    local MsgTitle = "银行对账流水";
                    --是否显示不再提示的按钮
                    local isShowCheckBox = "true";
                    --内容
                    local MsgContent = "您有收付款业务待确认，请及时前往极简报销查看确认通知并发起单据处理。";
                    --时间
                    local Timestamp = vt("transactionDate",ItemData);
                    --消息类型编码
                    local MsgTypeCode = "";
                    --缴款确认id
                    local res3 = "";
                    --消息类型文字 1业务消息 2企业公告 3产品消息
                    local MsgTypeName = "";
                    if MsgTypeCode == "1" then
                        MsgTypeName = "业务消息";
                    elseif MsgTypeCode == "2" then
                        MsgTypeName = "企业公告";
                    elseif MsgTypeCode == "3" then
                        MsgTypeName = "产品消息";
                    else
                        MsgTypeName = "发布消息";
                    end;

                    local popupFlag = "";
                    local pkNotimsg = "";
                    local pkMsgPublishList = "";
                    --消息状态
                    local replyState = "";

                    --追加
                    local AddItem = {
                        --客户端参数
                        --消息下标
                        MsgCtrlIndex=MsgCtrlIndex,
                        --消息标题
                        MsgTitle=MsgTitle,
                        --消息内容
                        MsgContent=MsgContent,
                        --消息类型文字
                        MsgTypeName=MsgTypeName,
                        --消息时间
                        MsgTime=string.sub(Timestamp,1,10),
                        --消息容器背景图片
                        MsgIconName="msg_item_bg.png",
                        --是否显示不再提示
                        IsShowCheckBox=isShowCheckBox,

                        --后台参数
                        --消息类型编码
                        MsgTypeCode=MsgTypeCode,
                        --消息是否弹出消息
                        MsgPopupFlag=popupFlag,
                        MsgNotimsg=pkNotimsg,
                        Res3=res3,
                        MsgPublishList=pkMsgPublishList,
                        replyState=replyState,
                        isDZD = "true",
                        --传全量参数
                        MsgInfoData=ItemData
                    };
                    table.insert(MsgItemTable,AddItem);
                end;

                --客户端控件数据
                local ClientDataTable = {
                    --标题
                    Title="重要消息",
                    --弹窗控件容器背景图片
                    WidgetBgIconName="msg_box_bg.png",
                    --弹窗控件容器按钮图片
                    DetailBtnIconName="msg_box_detail_btn.png",
                    --弹窗控件容器按钮文字
                    DetailBtnContent="马上查阅",
                    --弹窗控件容器复选框文字
                    CheckBoxMsgContent="下次不再提示",
                    --弹窗控件容器复选框默认状态，0不勾选，1勾选
                    CheckBoxMsgDefaultStatus=C_CheckBoxMsgDefaultStatus,
                    --弹窗控件交互方法
                    ClickFunName="lua_system.msg_popup_call",
                    --弹窗控件消息集合
                    MsgItem=MsgItemTable
                };
                local ClientDataJson = table2json(ClientDataTable);

                --[[debug_alert(
                    "消息条数 : "..tostring(showMsgListCounts).."\n"..
                    --"客户端控件数据Json :\n"..ClientDataJson.."\n"..
                    "客户端控件数据Table :\n"..foreach_arg2print(ClientDataTable,"true").."\n"..
                    ""
                );]]

                --存缓存
                globalTable["MsgPopupClientDataTable"] = ClientDataTable;

                --显示发布消息弹窗
                lua_system.open_msg_popup(ClientDataJson,"lua_index_mission.close_msg_popup_call_mission");
            else
                --没有数据回调任务处理
                lua_mission.index_handle();
            end;
        end;
    end;
end;

--普通消息
function lua_index_mission.analysis_show_msg()
    lua_index_mission.do_analysis_show_msg();
end;

function lua_index_mission.do_analysis_show_msg(params)
    --最后一个任务需要手动关闭
    lua_mission.index_finish(globalTable["IndexPageMissionIndex"],"MC");
    globalTable["IndexPageMissionIndex"] = nil;

    if MsgCenterFlag == "disenable" then
        --debug_alert("没有权限时不查询弹出消息，直接回调任务序列");
        lua_mission.index_handle();
    else
        local params = formatNull(params);
        if params == "" then
            --debug_alert("执行分析是否需要展示发布消息-请求"..os.time());
            --查询发布消息
            invoke_trancode_donot_checkRepeat(
                "jjbx_index",
                "query_msg",
                {TranCode="QryPopupMsg"},
                lua_index_mission.do_analysis_show_msg,
                {},
                all_callback,
                {CloseLoading="false"}
            );
        else
            local responseBody = json2table(params["responseBody"]);
            --debug_alert("执行分析是否需要展示发布消息-响应"..foreach_arg2print(responseBody));
            local showMsgList = vt("list",responseBody);
            local showMsgListCounts = #showMsgList;
            --debug_alert(showMsgListCounts);

            if showMsgListCounts > 0 then
                --消息单条信息拼接
                local MsgItemTable = {};

                --循环拼接
                for key,value in pairs(showMsgList) do
                    local ItemData = formatNull(value);
                    --操作下标
                    local MsgCtrlIndex = tostring(key);
                    --标题
                    local MsgTitle = vt("headline",ItemData);
                    --是否显示不再提示的按钮
                    local isShowCheckBox = "true";
                    --内容
                    local MsgContent = vt("content",ItemData);
                    --时间
                    local Timestamp = vt("ts",ItemData);
                    --消息类型编码
                    local MsgTypeCode = vt("msgType",ItemData);
                    --缴款确认id
                    local res3 = vt("res3",ItemData);
                    --消息类型文字 1业务消息 2企业公告 3产品消息
                    local MsgTypeName = "";
                    if MsgTypeCode == "1" then
                        MsgTypeName = "业务消息";
                    elseif MsgTypeCode == "2" then
                        MsgTypeName = "企业公告";
                    elseif MsgTypeCode == "3" then
                        MsgTypeName = "产品消息";
                    else
                        MsgTypeName = "发布消息";
                    end;

                    local popupFlag = vt("popupFlag",ItemData);
                    local pkNotimsg = vt("pkNotimsg",ItemData);
                    local pkMsgPublishList =  vt("pkMsgPublishList",ItemData);
                    --消息状态
                    local replyState = vt("replyState",ItemData);

                    --追加
                    local AddItem = {
                        --客户端参数
                        --消息下标
                        MsgCtrlIndex=MsgCtrlIndex,
                        --消息标题
                        MsgTitle=MsgTitle,
                        --消息内容
                        MsgContent=MsgContent,
                        --消息类型文字
                        MsgTypeName=MsgTypeName,
                        --消息时间
                        MsgTime=string.sub(Timestamp,1,10),
                        --消息容器背景图片
                        MsgIconName="msg_item_bg.png",
                        --是否显示不再提示
                        IsShowCheckBox=isShowCheckBox,

                        --后台参数
                        --消息类型编码
                        MsgTypeCode=MsgTypeCode,
                        --消息是否弹出消息
                        MsgPopupFlag=popupFlag,
                        MsgNotimsg=pkNotimsg,
                        Res3=res3,
                        MsgPublishList=pkMsgPublishList,
                        replyState=replyState,
                        isDZD = "false",
                        --传全量参数
                        MsgInfoData=ItemData
                    };
                    table.insert(MsgItemTable,AddItem);
                end;

                --客户端控件数据
                local ClientDataTable = {
                    --标题
                    Title="重要消息",
                    --弹窗控件容器背景图片
                    WidgetBgIconName="msg_box_bg.png",
                    --弹窗控件容器按钮图片
                    DetailBtnIconName="msg_box_detail_btn.png",
                    --弹窗控件容器按钮文字
                    DetailBtnContent="马上查阅",
                    --弹窗控件容器复选框文字
                    CheckBoxMsgContent="下次不再提示",
                    --弹窗控件容器复选框默认状态，0不勾选，1勾选
                    CheckBoxMsgDefaultStatus=C_CheckBoxMsgDefaultStatus,
                    --弹窗控件交互方法
                    ClickFunName="lua_system.msg_popup_call",
                    --弹窗控件消息集合
                    MsgItem=MsgItemTable
                };
                local ClientDataJson = table2json(ClientDataTable);

                --[[debug_alert(
                    "消息条数 : "..tostring(showMsgListCounts).."\n"..
                    --"客户端控件数据Json :\n"..ClientDataJson.."\n"..
                    "客户端控件数据Table :\n"..foreach_arg2print(ClientDataTable,"true").."\n"..
                    ""
                );]]

                --存缓存
                globalTable["MsgPopupClientDataTable"] = ClientDataTable;

                --显示发布消息弹窗
                lua_system.open_msg_popup(ClientDataJson,"lua_index_mission.close_msg_popup_call_mission");
            else
                --没有数据回调任务处理
                lua_mission.index_handle();
            end;
        end;
    end;
end;

--[[发布消息弹窗关闭实现]]
function lua_index_mission.msg_popup_close_call(ClickArg)
    --发布消息批量已读
    lua_index_mission.popup_msg_batch_read();

    --关闭控件并回调任务序列
    lua_index_mission.close_msg_popup_call_mission();
end;

--[[发布消息弹窗点击详情实现]]
function lua_index_mission.msg_popup_click_call(ClickArg)
    --处理消息点击事件，如果是页面请求，返回首页后会重新加载任务序列，无需手动回调

    local ClientDataTable = vt("MsgPopupClientDataTable",globalTable);
    local MsgItem = vt("MsgItem",ClientDataTable);
    local ChooseMsgItem = formatNull(MsgItem[tonumber(ClickArg)]);

    --debug_alert("发布消息弹窗点击详情实现"..foreach_arg2print(ChooseMsgItem));

    local MsgCtrlIndex = vt("MsgCtrlIndex",ChooseMsgItem);
    local MsgTypeCode = vt("MsgTypeCode",ChooseMsgItem);
    local MsgPopupFlag = vt("MsgPopupFlag",ChooseMsgItem);
    local MsgPublishList = vt("MsgPublishList",ChooseMsgItem);
    local Res3 = vt("Res3",ChooseMsgItem);
    --消息状态
    local replyState = vt("replyState",ChooseMsgItem);

    --全量消息参数
    local MsgInfoData = vt("MsgInfoData",ChooseMsgItem);
    --消息类型
    local messageSubclassEn = vt("messageSubclassEn",MsgInfoData);

    --关闭控件并回调任务序列
    lua_index_mission.close_msg_popup_call_mission();

    --发布消息批量已读
    lua_index_mission.popup_msg_batch_read();

    if messageSubclassEn == "functionGuide" or messageSubclassEn == "frequentQuestion" then
        --帮助消息跳转
        lua_ask.ask_msg_jump({messageSubclassEn=messageSubclassEn});
    elseif messageSubclassEn == "bankTransactionAuthorization" then
        --跳转至对账待确认列表
        invoke_page("jjbx_msg_center/xhtml/msg_account_checking.xhtml",page_callback,{CloseLoading="false",ClickArg=ClickArg});
    else
        if replyState=="0" or replyState=="1" then
            --待回复/已回复的消息，进入消息回复/查看回复详情界面
            globalTable["DelpkNotimsg"] = MsgNotimsg;
            globalTable["DelpkMsgPublishList"] = MsgPublishList;
            invoke_page("jjbx_msg_center/xhtml/msg_reply.xhtml",page_callback,nil);
        elseif Res3 ~= "" then
            --前往缴款单
            go_to_jkd("",Res3);
        else
            globalTable["webview_back_fun"] = "lua_menu.back_to_msg_center()";
            --查询链接并前往消息h5页面
            local qryArg = {
                PkMsgPublishList = MsgPublishList,
                NeedBase64 = "true",
                MsgType = MsgTypeCode,
                PopupFlag = MsgPopupFlag
            };
            lua_jjbx.qry_msg_h5_link(qryArg);
        end;
    end;
end;

--[[前往缴款单]]
function go_to_jkd(params,billPId)
    if formatNull(params) == "" then
        invoke_trancode(
            "jjbx_process_query",
            "receipt_service",
            {billPId=billPId,TranCode="qryDeductionAccountByBillPId"},
            go_to_jkd,
            {},
            all_callback,
            {CloseLoading="false"}
        );
    else
        local responseBody = json2table(params["responseBody"]);
        if responseBody["errorNo"] == "000000" then
            --缴款单信息存缓存
            globalTable["payInDetailData"] = responseBody["deduction"];
            --标记从消息页面前往
            globalTable["from_msg"] = "1";
            invoke_page("jjbx_receipt/xhtml/contribution_detail.xhtml",page_callback,{CloseLoading="false"});
        else
            alert(responseBody["errorMsg"]);
        end;
    end;
end;

--[[发布消息弹窗复选框操作实现]]
function lua_index_mission.msg_popup_checkbox_call(ClickArg)
    --选中状态
    local MsgPopupCheckBoxStatus = "";
    local arg = splitUtils(ClickArg,",");
    if arg[1] == "1" then
        MsgPopupCheckBoxStatus = "1";
    else
        MsgPopupCheckBoxStatus = "0";
    end;

    --debug_alert("更新不再提示状态 : "..MsgPopupCheckBoxStatus);
    globalTable["MsgPopupCheckBoxStatus"] = MsgPopupCheckBoxStatus;
end;

--[[发布消息批量已读]]
function lua_index_mission.popup_msg_batch_read()
    --获取复选框状态，取不到认为没有操作过复选框，取默认值
    local CheckBoxStatus = formatNull(globalTable["MsgPopupCheckBoxStatus"],C_CheckBoxMsgDefaultStatus);

    --选中不再提示的时，执行批量已读处理
    if CheckBoxStatus == "1" then
        local MsgPopupClientDataTable = vt("MsgPopupClientDataTable",globalTable);
        local MsgItemList = vt("MsgItem",MsgPopupClientDataTable);
        local MsgPublishLists = "";
        local MsgIdLists = "";
        local MsgPopupFlagLists = "";
        local MsgIsDZD = "";
        for key,value in pairs(MsgItemList) do
            MsgPublishLists = MsgPublishLists..formatNull(value["MsgPublishList"])..",";
            MsgIdLists = MsgIdLists..formatNull(value["MsgNotimsg"])..",";
            MsgPopupFlagLists = MsgPopupFlagLists..formatNull(value["MsgPopupFlag"])..",";
            MsgIsDZD = vt("isDZD",value);
        end;

        --删除最后一个逗号
        MsgPublishLists = lua_format.delete_last_char(MsgPublishLists);
        MsgIdLists = lua_format.delete_last_char(MsgIdLists);
        MsgPopupFlagLists = lua_format.delete_last_char(MsgPopupFlagLists);

        globalTable["DelpkNotimsg"] = MsgIdLists;
        globalTable["DelpkMsgPublishList"] = MsgPublishLists;
        globalTable["popupFlag"] = MsgPopupFlagLists;
        
        --[[debug_alert(
            "执行批量已读处理\n"..
            "参数1 : "..MsgPublishLists.."\n"..
            "参数2 : "..MsgIdLists.."\n"..
            "参数3 : "..MsgPopupFlagLists.."\n"..
            ""
        );]]


        if MsgIsDZD == "true" then
            --对账流水不再执行首页弹窗查看
            lua_index_mission.add_common_hint("",{});
        else
            lua_jjbx.updMarkunreadFlag();
        end;
    end;
end;

-- 对账流水设置消息弹窗
function lua_index_mission.add_common_hint(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        ReqParams = formatNull(ReqParams,{});
        ReqParams["ReqAddr"] = "pubUserHint/addCommonHint";
        ReqParams["ReqUrlExplain"] = "查询消息是否弹窗";
        local BusinessParams = {
            channal=vt("channal",ReqParams,"009"),
            value = "1"
        };
        ReqParams["BusinessParams"] = table2json(BusinessParams);
        ReqParams["BusinessCall"] = lua_index_mission.add_common_hint;
        lua_jjbx.common_req(ReqParams);
    else
        local responseBody = json2table(ResParams["responseBody"]);
        if responseBody["errorNo"] == "000000" then
            
        else
            alert(responseBody["errorMsg"]);
        end;
    end;
end;

--[[关闭发布消息弹窗并回调任务序列]]
function lua_index_mission.close_msg_popup_call_mission()
    --关闭发布弹窗后将物理键设为关闭APP
    lua_system.close_msg_popup();
    --回调任务序列
    lua_mission.index_handle();
end;
--[[####################发布消息提示分析End####################]]


--[[####################参与单据评价分析Begin####################]]
--[[检查是否需要弹出单据评价界面]]
function lua_index_mission.analysis_show_bill_evaluation()
    lua_index_mission.do_analysis_show_bill_evaluation();
end;
function lua_index_mission.do_analysis_show_bill_evaluation(params)
    --debug_alert("执行检查是否需要弹出单据评价界面"..os.time());

    local params = formatNull(params);
    local ShowBillEvaluation = formatNull(globalTable["ShowBillEvaluation"]);

    --调试
    if lua_mission.index_debug() == "true" then
        ShowBillEvaluation = "";
    end;

    if params == "" then
        --debug_alert("检查是否需要弹出单据评价界面 : "..ShowBillEvaluation);
        if ShowBillEvaluation == "" then
            --一次登录会话只查询一次
            globalTable["ShowBillEvaluation"] = "Showed";
            invoke_trancode_donot_checkRepeat(
                "jjbx_login",
                "entrance",
                {TranCode="qryBillEvaluation"},
                lua_index_mission.do_analysis_show_bill_evaluation,
                {},
                all_callback,
                {CloseLoading="false"}
            );
        end;
    else
        --debug_alert("查询结果处理");
        local responseBody = json2table(params["responseBody"]);

        --非首次登陆且需要在评价权限内的才弹出评价界面
        local ShowEvaluationFlag = "false";
        if responseBody["errorNo"]=="000000" and responseBody["popFlag"]=="1" and globalTable["userAppraise"]=="true" then
            ShowEvaluationFlag = "true";
        end;

        --调试
        if lua_mission.index_debug() == "true" then
            ShowEvaluationFlag = "true";
        end;

        if ShowEvaluationFlag == "true" then
            globalTable["billEvaluationInfo"] = responseBody["billEvaluationInfo"];

            --创建单据评价界面并显示
            lua_index_mission.create_bill_evaluation();
            lua_index_mission.evaluation_page_ctrl("open");

            --关闭loading界面
            close_loading();
        else
            --完成当前任务并处理后续任务
            lua_mission.index_handle();
        end;
    end;
end;

--单据评价上送参数列表
local evaluation_submit_params = {
    --评价总分
    totalPoints = "",
    --财务处理时间评价
    timelinessPoints = "",
    --服务评价
    serviceAttitudePoints = "",
    --系统评价
    sysFunctionPoints = "",
    --用户输入建议
    otherSuggest = "",
    --评价 1 / 不评价 0
    evaluateFlag = "",
    --评价的单据ID
    billEvaluaId = "",
    --请求业务层的交易码
    TranCode = ""
};

--[[评价星级选择]]
function lua_index_mission.evaluation_star_choose(index,elementName)
    local imgElement = document:getElementsByName(elementName.."Img");
    local valueElement = elementName.."Value";
    local imgSrc = "";
    local valueColor = "";
    local valueStr = "";
    imgSrc = "pentacle_orange.png";
    valueColor = "#AFACAC";
    if tonumber(index) > 4 then
        valueStr = "非常满意";
    elseif tonumber(index) > 3 then
        valueStr = "满意";
    elseif tonumber(index) > 2 then
        valueStr = "一般";
    elseif tonumber(index) > 1 then
        valueStr = "差";
    else
        valueStr = "非常差";
    end;
    changeProperty(valueElement,"value",valueStr);
    changeStyle(valueElement,"color",valueColor);
    for i=1,#imgElement do
        if i <= tonumber(index) then
            imgElement[i]:setPropertyByName("src",imgSrc);
        else
            imgElement[i]:setPropertyByName("src","pentacle_white.png");
        end;
    end;

    if elementName == "entirety" then
        evaluation_submit_params.totalPoints = index;
    elseif elementName == "disposeTimeliness" then
        evaluation_submit_params.timelinessPoints = index;
    elseif elementName == "serveAttitude" then
        evaluation_submit_params.serviceAttitudePoints = index;
    elseif elementName == "systemFunction" then
        evaluation_submit_params.sysFunctionPoints = index;
    end;
end;

--[[
    评价建议输入提示
    inputElement: 输入框name
    showElement: 展示字数的标签name
    showMaxLeng: 输入框的最大输入字数
]]
function lua_index_mission.evaluation_suggest_tip(inputElement,showElement,showMaxLeng)
    local elementValue = document:getElementsByName(inputElement)[1]:getPropertyByName("value");
    local elementLen = ryt:getLengthByStr(elementValue);
    changeProperty(showElement,"value",elementLen.."/"..showMaxLeng);
    if tonumber(elementLen) > tonumber(showMaxLeng) then
        changeStyle(showElement,"color","#FF0000");
    else
        changeStyle(showElement,"color","#999999");
    end;
end;

--[[单据评价提交]]
function lua_index_mission.evaluation_submit(params)
    local params = formatNull(params);

    --请求
    if params == "Y" or params == "N" then
        --请求参数修改
        if params == "Y" then
            if evaluation_submit_params.totalPoints == "" then
                alert("您尚未完成该笔单据的整体评价!");
                return;
            else
                evaluation_submit_params.evaluateFlag = "1";
                local appraiseText = getValue("appraiseText");
                local appraiseTextLen = ryt:getLengthByStr(appraiseText);
                if appraiseTextLen > 100 then
                    alert("单据评价建议过长!");
                    return;
                else
                    evaluation_submit_params.otherSuggest = getValue("appraiseText");
                end;
            end;
        elseif params == "N" then
            evaluation_submit_params.evaluateFlag = "0";
        end;

        --获取单据ID
        local billEvaluationInfo = formatNull(globalTable["billEvaluationInfo"]);
        local billEvaluaId = formatNull(billEvaluationInfo["id"]);
        if billEvaluaId ~= "" then
            evaluation_submit_params.billEvaluaId=billEvaluaId;
            evaluation_submit_params.TranCode="updateBillEvaluation"
            --提交评价请求并回调自身函数
            invoke_trancode("jjbx_login","entrance",evaluation_submit_params,lua_index_mission.evaluation_submit,{},all_callback,{CloseLoading="false"});
        else
            alert("单据不存在");
        end;
    --响应
    else
        local responseBody = json2table(params["responseBody"]);
        if responseBody["errorNo"] == "000000" then
            if responseBody["EvaluateFlag"] == "0" then
                --不评价的情况下不提示
            else
                alert("感谢，您的评价已提交成功！如有反馈请至消息中心查看。");
            end;
        else
            --评价提交报错，弹出信息，不继续执行
            alert(responseBody["errorMsg"]);
            return;
        end;
    end;

    --参数使用完后重新初始化
    lua_format.init_table_params(evaluation_submit_params);

    --关闭评价界面
    lua_index_mission.evaluation_page_ctrl("close");
end;

--[[创建单据评价界面]]
function lua_index_mission.create_bill_evaluation()
    --适配背景高度为全屏
    height_adapt("evaluation_bg_div",0,0);

    local star1_html = "";
    local star2_html = "";
    local star3_html = "";
    local star4_html = "";
    for i=1,5 do
        star1_html = star1_html..[[
            <div class="evaluation_star_item]]..tostring(i)..[[_div" border="0" onclick="lua_index_mission.evaluation_star_choose(']]..tostring(i)..[[','entirety')">
                <img src="local:pentacle_white.png" class="evaluation_star_icon" name="entiretyImg" onclick="lua_index_mission.evaluation_star_choose(']]..tostring(i)..[[','entirety')"/>
            </div>
        ]];

        star2_html = star2_html..[[
            <div class="evaluation_star_item]]..tostring(i)..[[_div" border="0" onclick="lua_index_mission.evaluation_star_choose(']]..tostring(i)..[[','disposeTimeliness')">
                <img src="local:pentacle_white.png" class="evaluation_star_icon" name="disposeTimelinessImg" onclick="lua_index_mission.evaluation_star_choose(']]..tostring(i)..[[','disposeTimeliness')"/>
            </div>
        ]];

        star3_html = star3_html..[[
            <div class="evaluation_star_item]]..tostring(i)..[[_div" border="0" onclick="lua_index_mission.evaluation_star_choose(']]..tostring(i)..[[','serveAttitude')">
                <img src="local:pentacle_white.png" class="evaluation_star_icon" name="serveAttitudeImg" onclick="lua_index_mission.evaluation_star_choose(']]..tostring(i)..[[','serveAttitude')"/>
            </div>
        ]];

        star4_html = star4_html..[[
            <div class="evaluation_star_item]]..tostring(i)..[[_div" border="0" onclick="lua_index_mission.evaluation_star_choose(']]..tostring(i)..[[','systemFunction')">
                <img src="local:pentacle_white.png" class="evaluation_star_icon" name="systemFunctionImg" onclick="lua_index_mission.evaluation_star_choose(']]..tostring(i)..[[','systemFunction')"/>
            </div>
        ]];
    end;

    local btn_border = "";
    --由于iPhone不支持单独给边框，这里做区分
    if systemTable['SysLayoutStyle'] == "android" then
        btn_border = "1";
    else
        btn_border = "0";
    end;

    local btn_html = [[
        <div class="evaluation_btn_div" border="]]..btn_border..[[">
            <div class="evaluation_btn1_div" border="0" onclick="lua_index_mission.evaluation_submit('N')">
                <label class="evaluation_btn1_label">不评价</label>
            </div>
            <div class="evaluation_btn2_div" border="0" onclick="lua_index_mission.evaluation_submit('Y')">
                <label class="evaluation_btn2_label">提交评价</label>
            </div>
        </div>
    ]];

    
    --需要评价的单据信息
    local billEvaluationInfo = formatNull(globalTable["billEvaluationInfo"]);
    local show_billNo = formatNull(billEvaluationInfo["djh"]);
    local show_billtime = formatNull(billEvaluationInfo["zdrq"]);
    local show_billType = formatNull(billEvaluationInfo["djlx"]);
    local show_billAmt = formatNull(formatMoney(billEvaluationInfo["hjje"]));
    local show_billsm = formatNull(billEvaluationInfo["sy"]);

    if lua_mission.index_debug() == "true" then
        show_billNo = "SSX20092217709";
        show_billtime = "2020-08-08";
        show_billType = "测试的单据";
        show_billAmt = "20.50";
        show_billsm = "测试的说明";
    end;

    --[[debug_alert(
        "show_billNo : "..show_billNo.."\n"..
        "show_billtime : "..show_billtime.."\n"..
        "show_billType : "..show_billType.."\n"..
        "show_billAmt  : "..show_billAmt .."\n"..
        "show_billsm : "..show_billsm.."\n"..
        ""
    );]]

    local evaluation_html = [[
        <div class="evaluation_bg_div" name="evaluation_bg_div" border="0" onclick="">
            <div class="evaluation_div" border="1" name="evaluation_div" onClick="">
                <!-- 标题 -->
                <label class="evaluation_title_label">单据评价</label>
                <img src="local:red_down_line.png" class="evaluation_red_line" />
                <div class="evaluation_close_div" border="0" onclick="lua_index_mission.evaluation_page_ctrl('close')">
                    <img src="local:close_login.png" class="evaluation_close_icon" onclick="lua_index_mission.evaluation_page_ctrl('close')"/>
                </div>

                <!-- 内容 -->
                <div class="evaluation_info_div" border="0" name="billInfoDiv">
                    <label class="evaluation_info_klabel">单据号</label>
                    <label class="evaluation_info_vlabel1">]]..show_billNo..[[</label>
                    <label class="evaluation_info_vlabel2" name="billtime" value="]]..show_billtime..[["/>

                    <label class="evaluation_info_klabel">单据类型</label>
                    <label class="evaluation_info_vlabel1">]]..show_billType..[[</label>
                    <label class="evaluation_info_vlabel2">]]..show_billAmt..[[</label>

                    <label class="evaluation_info_klabel">事由</label>
                    <label class="evaluation_info_vlabel3">]]..show_billsm..[[</label>
                </div>
                <div class="space_10_div" border="0"></div>

                <!-- 评价打分 -->
                <div class="evaluation_star_choose_div" name="entiretyDiv" border="0">
                    <label class="evaluation_star_title">整体评价</label>
                        ]]..star1_html..[[
                    <label class="evaluation_star_label" name="entiretyValue"></label>
                </div>
                <div class="evaluation_star_choose_div" name="disposeTimelinessDiv" border="0">
                    <label class="evaluation_star_title">财务处理时效</label>
                        ]]..star2_html..[[
                    <label class="evaluation_star_label" name="disposeTimelinessValue"></label>
                </div>
                <div class="evaluation_star_choose_div" name="serveAttitudeDiv" border="0">
                    <label class="evaluation_star_title">财务服务态度</label>
                        ]]..star3_html..[[
                    <label class="evaluation_star_label" name="serveAttitudeValue"></label>
                </div>
                <div class="evaluation_star_choose_div" name="systemFunctionDiv" border="0">
                    <label class="evaluation_star_title">系统使用功能</label>
                        ]]..star4_html..[[
                    <label class="evaluation_star_label" name="systemFunctionValue"></label>
                </div>
                <div class="space_10_div" border="0"></div>

                <!-- 评价建议 -->
                <div class="evaluation_info_div" border="1">
                    <textarea class="evaluation_suggest_input" border="0" name="appraiseText" value="" maxleng="100" onchange="lua_index_mission.evaluation_suggest_tip('appraiseText','inputNum','100')" hold="请输入您的建议..." isShowButton="false"></textarea>
                    <label class="evaluation_suggest_input_tip" name="inputNum">0/100</label>
                </div>
                <div class="space_10_div" border="0"></div>

                ]]..btn_html..[[
            </div>
        </div>
    ]];

    document:getElementsByName("evaluation_bg_div")[1]:setInnerHTML(evaluation_html);

    --控件居中适配
    lua_page.widget_center_adapt("evaluation_div","x/y");

    page_reload();
end;

--[[评价界面显示隐藏控制]]
function lua_index_mission.evaluation_page_ctrl(flag)
    if flag == "open" then
        --状态栏置灰
        set_android_top_bar_color("#4C4B5B");
        show_ele("evaluation_bg_div");
    else
        --还原状态栏
        set_android_top_bar_image("index_top_bar_up.png");
        hide_ele("evaluation_bg_div");

        globalTable["userAppraise"] = "false";
        --debug_alert("完成单据评价任务并调用任务处理，任务编号 : "..globalTable["IndexPageMissionIndex"]);
        lua_mission.index_handle();
    end;
end;
--[[####################参与单据评价分析End####################]]


--[[####################信用权益说明展示分析Begin####################]]
--[[信用权益说明展示分析]]
function lua_index_mission.analysis_show_credit_explain()
    --debug_alert("执行信用权益说明展示分析"..os.time());

    --先款后审是否展示
    local ShowCreditExplainFlag = formatNull(globalTable["ShowCreditExplainFlag"],"false");
    --只提示一次
    globalTable["ShowCreditExplainFlag"] = "false";
    --先款后审链接
    local CreditExplainUrl = formatNull(globalTable["CreditExplainUrl"]);

    --调试
    if lua_mission.index_debug() == "true" then
        ShowCreditExplainFlag = "true";
        --设置调试链接
        CreditExplainUrl = systemTable["ServerHost"];
    end;

    --[[debug_alert(
        "show_credit_explain\n"..
        "ShowCreditExplainFlag:"..ShowCreditExplainFlag.."\n"..
        "CreditExplainUrl:"..CreditExplainUrl.."\n"..
        ""
    );]]

    --检查是否需要提示“参与先款后审”
    if ShowCreditExplainFlag == "true" then
        --debug_alert("参与先款后审");
        --展示先款后审页面
        lua_index_mission.show_creditExplain_page(CreditExplainUrl,"lua_index_mission.update_xkhs_status");
    else
        --完成当前任务并处理后续任务
        lua_mission.index_handle();
    end;
end;

--[[展示先款后审页面]]
function lua_index_mission.show_creditExplain_page(CreditExplainUrl, CallbckFun)
    local CallbckFun = formatNull(CallbckFun);
    if platform == "iPhone OS" then
        --debug_alert("iOS以弹出HTML的形式弹出页面");
        globalTable["webview_url"] = CreditExplainUrl;

        local credit_explain_html = [[
            <div class="credit_explain_bg_div" name="credit_explain_bg_div" border="0" onclick="">
                <div class="credit_explain_div" name="credit_explain_div" border="1">
                    <!-- 头 -->
                    <div class="credit_explain_title_div" border="0">
                        <label class="credit_explain_title_label">信用权益参与提示</label>
                    </div>
                    <div class="credit_explain_close_div" border="0" onclick="lua_index_mission.close_credit_explain_page()">
                        <img src="local:sl_ico_close.png" class="credit_explain_close_icon" onclick="lua_index_mission.close_credit_explain_page()"/>
                    </div>

                    <!-- 分隔线条 -->
                    <img src="local:red_down_line.png" class="credit_explain_line_div" />

                    <!-- 内容 -->
                    <div class="credit_explain_webview_content_div" border="0" name="credit_explain_webview_content_div">
                        <div class="credit_explain_webview" name="credit_explain_webview" type="webviewLife" url="]]..globalTable['webview_url']..[[" />
                    </div>

                    <!-- 底部按钮 -->
                    <div class="credit_explain_webview_two_btn_div" name="credit_explain_webview_two_btn_div" border="0">
                        <div class="credit_explain_webview_two_btn1_div" border="0" onclick="lua_index_mission.update_xkhs_status('N')">
                            <label class="credit_explain_webview_two_btn1_label">不参与</label>
                        </div>
                        <div class="credit_explain_webview_two_btn2_div" border="0" onclick="lua_index_mission.update_xkhs_status('Y')">
                            <label class="credit_explain_webview_two_btn2_label">参与</label>
                        </div>
                    </div>
                </div>
            </div>
        ]];
        document:getElementsByName("credit_explain_bg_div")[1]:setInnerHTML(credit_explain_html);
        page_reload();

        --iPhoneX全屏显示
        index_page_iPhoneX_ctrl("hide");

        --控件居中适配
        lua_page.widget_center_adapt("credit_explain_div","x/y");

        --适配为全屏
        height_adapt("credit_explain_bg_div",0,0);
        --显示控件
        show_ele("credit_explain_bg_div");
    else
        --debug_alert("Android调用自定义提示控件");
        --[[
            自定义提示控件，用于展示h5弹框，下方显示两个按钮
            param1 : webview加载的url
            param2 : 点击回调方法，参与传Y，不参与传N，关闭传C
        ]]

        --[[
            webview控件说明
            ·控件背景色灰色透明，点击不响应，同版本更新界面。
            ·控件整体尺寸说明：
                1、整体高度445，宽度305
                2、整体左侧间距35，页面基于375的宽度居中
                3、整体距离顶部145
            ·控件内容分为头、webview容器、按钮三部分，具体说明：
                1、头
                    ·高度45，文字bold加粗，文字颜色#333333，文字居中
                    ·右侧关闭按钮图片使用sl_ico_close.png，尺寸17*17，距离头部14，距离右侧10
                    ·点击事件客户端直接定义，实现关闭控件功能，点击区域做大一点
                2、webview容器
                    ·容器高度405，宽度305，距离顶部45，直接加载lua里给到的链接即可，支持https和http协议链接
                3、按钮
                    ·底部左右两个按钮，背景图片使用btn_double.png
                    ·底部高度55px，距离顶部350，或者直接固定在底部
                    ·左侧文字大小15，不加粗，颜色#333333，右侧按钮文字大小15，不加粗，颜色#FFFFFF
                    ·点击调用lua参数里传递的函数名
        ]]
        luadefine:loadWebviewDialog(CreditExplainUrl,CallbckFun);
    end;
end;

--[[更新参与先款后审状态]]
function lua_index_mission.update_xkhs_status(params)
    local params = formatNull(params);

    --请求
    if params == "Y" or params == "N" or params == "C" then
        --Y参与 N不参与 C关闭
        if params == "C" then
            --完成当前任务并处理后续任务
            lua_mission.index_handle();
        else
            --清空链接缓存
            globalTable['webview_url'] = "";
            invoke_trancode(
                "jjbx_myInfo",
                "creditScore",
                {
                    TranCode="update_xkhs_status",
                    Status=params
                },
                lua_index_mission.update_xkhs_status,
                {},
                all_callback,
                {CloseLoading="false"}
            );
        end;
    --响应
    else
        --更新参与先款后审状态结果处理
        local responseBody = json2table(params["responseBody"]);
        local errorNo = formatNull(responseBody["errorNo"]);
        local errorMsg = formatNull(responseBody["errorMsg"]);
        --[[debug_alert(
            "lua_index_mission.update_xkhs_status_call\n"..
            "errorNo : "..errorNo.."\n"..
            "errorMsg : "..errorMsg.."\n"..
            ""
        );]]

        --报错提示
        if errorNo ~= "000000" then
            alert(errorMsg);
        end;

        --调用关闭
        lua_index_mission.close_credit_explain_page();
    end;
end;

--[[关闭先款后审页面]]
function lua_index_mission.close_credit_explain_page()
    --debug_alert("lua_index_mission.close_credit_explain_page");

    --iPhone是打开的页面，这里需要手动关闭，Android点击后客户端自动关闭控件
    if platform == "iPhone OS" then
        --还原全屏显示
        index_page_iPhoneX_ctrl("show");
        --隐藏信用权益容器
        hide_ele("credit_explain_bg_div");
    end;

    --debug_alert("完成信用权益任务并调用任务处理，任务编号 : "..globalTable["IndexPageMissionIndex"]);
    lua_mission.index_handle();
end;
--[[####################信用权益说明展示分析End####################]]


--[[####################处理客户端登记的任务Begin####################]]
--[[检查客户端注册的待处理的任务]]
function lua_index_mission.deal_client_register_mission()
    --获取客户端登记的任务
    local ClientRegisterMissionArg = get_db_value("ClientRegisterMissionArg");
    if ClientRegisterMissionArg ~= "" then
        --通用日志记录注册
        local CommonLogRegisterArg = {
            LogExplain="检查客户端注册的待处理的任务",
            LogInfo=ClientRegisterMissionArg
        };
        lua_jjbx.common_log_register("",CommonLogRegisterArg);
    end;
    local missionArg = lua_format.url_decode(ClientRegisterMissionArg);

    --[[debug_alert(
        "检查客户端注册的待处理的任务\n"..
        "ClientRegisterMissionArg :\n"..ClientRegisterMissionArg.."\n"..
        "missionArg :\n"..missionArg.."\n"..
        ""
    );]]

    --当前用户登录的主键
    local PkUserNow = vt("PkUser",globalTable);

    if missionArg ~= "" then
        --debug_alert("有客户端登记任务");

        local ArgObj = json2table(missionArg);
        local MissionType = vt("MissionType",ArgObj);

        --debug_alert("检查待办任务"..foreach_arg2print(ArgObj));

        --批量关闭app弹出界面
        lua_system.batch_close_app_alert_window();

        if MissionType == "FileOpenByAppUpload" then
            --debug_alert("用APP上传文件");

            if PkUserNow ~= "" then
                local FileName = vt("FileName",ArgObj);
                local FilePath = vt("FilePath",ArgObj);
                lua_upload.upload_file_by_app(FileName, FilePath);
            else
                --debug_alert("未登录状态下不处理上传任务，当前序列暂停，参数"..foreach_arg2print(ArgObj));
            end;
        elseif MissionType == "ToBudgetPageOpenByOtherApp" then
            --目标用户登录ID
            local PkUserTarget = vt("JJBXAppLoginUserId",ArgObj);

            --[[debug_alert(
                "通过其他APP打开后，前往福利页面\n"..
                "PkUserNow : "..PkUserNow.."\n"..
                "PkUserTarget : "..PkUserTarget.."\n"..
                ""
            );]]

            --登录参数
            if PkUserNow ~= "" then
                --调试登录用户不一致或不一致的情况
                --PkUserTarget = PkUserNow;
                if PkUserTarget == PkUserNow then
                    --debug_alert("登录用户一致，跳转福利页面");
                    lua_menu.to_budget_page_by_other_app(ArgObj);
                else
                    --debug_alert("登录用户不一致，发起注销后重新登录");
                    local ReLoginArgTable = {
                        JJBXAppLoginToken=vt("JJBXAppLoginToken",ArgObj),
                        Relogin="true"
                    };
                    local ReLoginArgJson = lua_format.base64_encode(table2json(ReLoginArgTable));
                    alert_confirm("","当前极简报销登录用户和手机银行登录用户不一致，请重新登录","","重新登录","alert_confirm_call","CallFun=lua_login.login_by_otherapp_prepare&CallArg="..ReLoginArgJson);
                end;
            else
                local LoginArgTable = {
                    JJBXAppLoginToken=vt("JJBXAppLoginToken",ArgObj),
                    Relogin="false"
                };
                local LoginArgJson = lua_format.base64_encode(table2json(LoginArgTable));
                --[[debug_alert(
                    "未登录状态直接发起登录\nLoginArgJson : "..LoginArgJson.."\n"..
                    "LoginArgTable"..foreach_arg2print(LoginArgTable).."\n"..
                    ""
                );]]
                lua_login.login_by_otherapp_prepare(LoginArgJson);
            end;
        else
            --通用日志记录注册
            local CommonLogRegisterArg = {
                LogExplain="客户端注册的待处理的任务无法被解析",
                LogInfo=ClientRegisterMissionArg
            };
            lua_jjbx.common_log_register("",CommonLogRegisterArg);
            lua_mission.clear_app_register_mission({ClearMsg="未定义的任务信息"});
            if PkUserNow ~= "" then
                --debug_alert("登录状态下回调任务序列")
                lua_mission.index_handle();
            else
                --debug_alert("未登录状态暂停任务序列")
            end;
        end;
    else
        if PkUserNow ~= "" then
            --debug_alert("登录状态下回调任务序列")
            lua_mission.index_handle();
        else
            --debug_alert("未登录状态暂停任务序列")
        end;
    end;
end;
--[[####################处理客户端登记的任务End####################]]

--初始化我的任务导航栏
function lua_index_mission.init_my_request_navigation(ResParams)
    if formatNull(ResParams) == "" then
        invoke_trancode_donot_checkRepeat(
            "jjbx_index",
            "my_request",
            {TranCode="init_my_request_navigation"},
            lua_index_mission.init_my_request_navigation,
            {},
            all_callback,
            {CloseLoading="false"}
        );
    else
        close_loading();
        local res = json2table(ResParams["responseBody"]);
        globalTable["navigation"] = {
            localPageIndex = 1,
            menuList = {}
        };
        local index = 1;
        local tempMenuList = {
            {
                index = index,
                title = "单据任务",
                pending = "false",
                localPage = "true",
                pagePath = "jjbx_index/xhtml/jjbx_approvedItems.xhtml"
            }
        };
        --待确认流水
        local list1 = vt("list1",res);
        --已确认流水
        local list2 = vt("list2",res);
        if #list1 > 0 or #list2 > 0 then
            index = index + 1;
            local pending = "false";
            if #list1 > 0 then
                pending = "true";
            end;
            local t = {
                index = index,
                title = "流水确认",
                pending = pending,
                localPage = "false",
                pagePath = "jjbx_msg_center/xhtml/msg_account_checking.xhtml"
            };
            table.insert(tempMenuList,t);
        end;
        --待确认往来确认列表
        local list3 = vt("list3",res);
        --已确认往来确认列表
        local list4 = vt("list4",res);
        if #list3 > 0 or #list4 > 0 then
            index = index + 1;
            local pending = "false";
            if #list3 > 0 then
                pending = "true";
            end;
            local t = {
                index = index,
                title = "往来确认",
                pending = pending,
                localPage = "false",
                pagePath = "jjbx_index/xhtml/jjbx_wlqr_list.xhtml"
            };
            table.insert(tempMenuList,t);
        end;
        --待处理消息任务
        local list5 = vt("list5",res);
        --已处理消息任务
        local list6 = vt("list6",res);
        if #list5 > 0 or #list6 > 0 then
            index = index + 1;
            local pending = "false";
            if #list5 > 0 then
                pending = "true";
            end;
            local t = {
                index = index,
                title = "消息任务",
                pending = pending,
                localPage = "false",
                pagePath = "jjbx_index/xhtml/msg_task.xhtml"
            };
            table.insert(tempMenuList,t);
        end;

        globalTable["navigation"]["menuList"] = tempMenuList;

        --获取数据后主动调用一次加载我的任务导航栏，避免在接口响应之前进入我的任务界面时导航栏加载获取不到实际数据
        if #document:getElementsByName("navigationDiv") > 0 then
            lua_index_mission.load_my_quest_navigation();
        end;
    end;
end;

--记录当前页面导航栏下标
function lua_index_mission.save_page_index(pageName)
    local menuList = globalTable["navigation"]["menuList"];
    for i=1,#menuList do
        if menuList[i]["title"] == pageName then
            globalTable["navigation"]["localPageIndex"] = menuList[i]["index"];
            break
        end;
    end;
end;

function lua_index_mission.switch_navigation(goPageIndex)
    local navigation = vt("navigation",globalTable);
    local localPageIndex = vt("localPageIndex",navigation);
    if tonumber(goPageIndex) ~= tonumber(localPageIndex) then
        --设置当前页面不为当前页
        globalTable["navigation"]["menuList"][tonumber(localPageIndex)]["localPage"] = "false";
        --设置目标页面为当前页面
        globalTable["navigation"]["menuList"][tonumber(goPageIndex)]["localPage"] = "true";
        local menuList = vt("menuList",navigation);
        --获取目标页面路劲
        local pagePath = menuList[tonumber(goPageIndex)]["pagePath"];
        local title = menuList[tonumber(goPageIndex)]["title"];
        --设置默认跳转方式
        local JumpStyle = "right";
        if tonumber(goPageIndex) < tonumber(localPageIndex) then
            JumpStyle = "left";
        end;
        if title == "流水确认" then
            --跳转流水确认页面
            globalTable["qry_status"] = "0";
            globalTable["qry_startTransactionDate"] = "";
            globalTable["qry_endTransactionDate"] = "";
            globalTable["qry_minAmount"] = "";
            globalTable["qry_maxAmount"] = "";
            globalTable["qry_timeCondition"] = "";
        elseif title == "往来确认" then
            --跳转往来确认页面
            globalTable["qry_status"] = "0";
            globalTable["qry_startTime"] = "";
            globalTable["qry_endTime"] = "";
            globalTable["qry_minAmount"] = "";
            globalTable["qry_maxAmount"] = "";
            globalTable["qry_minHxBalance"] = "";
            globalTable["qry_maxHxBalance"] = "";
            globalTable["qry_timeCondition"] = "";
        elseif title == "消息任务" then
            globalTable["qry_status"] = "1";
        end;
        invoke_page(pagePath,page_callback,{JumpStyle=JumpStyle});
    end;
end;

function lua_index_mission.load_my_quest_navigation()
    --计算DIV宽度(向上取整)
    local navigation = vt("navigation",globalTable);
    local listLen = #navigation["menuList"];
    local divWidth = math.ceil(375/listLen);
    local htmlContent = "";
    local totalWidth = 0;
    for key,value in pairs(navigation["menuList"]) do
        --总宽度(div的宽度*div数量)超出375时，对最后一个div进行精简处理
        if (divWidth*listLen) > 375 and (key==listLen) then
            divWidth = divWidth - ((divWidth*listLen) - 375) - 1;
        end;
        totalWidth = totalWidth + divWidth;
        local pending = "displayNone";
        if value["pending"] == "true" then
            pending = "displayBlock";
        end;
        local nowPageCss = "displayNone";
        if value["localPage"] == "true" then
            nowPageCss = "displayBlock";
        end;
        htmlContent = htmlContent..[[
            <div class="navigation_option" style="width: ]]..divWidth..[[px" border="0" onclick="lua_index_mission.switch_navigation(']]..value['index']..[[')">
                <label class="navigation_title_css" style="width: ]]..(divWidth-10)..[[px" value="]]..value['title']..[[" name="navigation_title" />
                <label class="navigation_pending_css,]]..pending..[[" value="·" name="navigation_pending" />
                <img src="local:red_down_line.png" style="width: ]]..divWidth..[[px" class="red_down_line_css,]]..nowPageCss..[[" name="red_down_line" />
            </div>
        ]];
    end;
    local e = document:getElementsByName("navigationDiv");
    if #e > 0 then
        htmlContent = [[<div class="navigation_div" border="0" name="navigationDiv">]]..htmlContent..[[</div>]];
        e[1]:setInnerHTML(htmlContent);
    else
        alert("获取导航栏元素异常");
    end;
end;

--清空待处理图标
function lua_index_mission.reload_my_quest_navigation(index,flag)
    local navigation = vt("navigation",globalTable);
    local menuList = vt("menuList",navigation);
    if #menuList >= tonumber(index) then
        globalTable["navigation"]["menuList"][tonumber(index)]["pending"] = formatNull(flag,"false");
        local navigation_pending = document:getElementsByName("navigation_pending");
        if flag == "true" then
            navigation_pending[tonumber(index)]:setStyleByName("display","block");
        else
            navigation_pending[tonumber(index)]:setStyleByName("display","none");
        end;
    end;
end;