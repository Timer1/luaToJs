lua_message = {};

--查询消息详情
function lua_message.qry_mess_info_ByPk(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        ReqParams["ReqAddr"] = "pubMessageService/qryMessInfoByPk";
        ReqParams["ReqUrlExplain"] = "查询消息详情";
        ReqParams["BusinessCall"] = lua_message.qry_mess_info_ByPk;
        local qryMessInfoByPk_params = {
            pkNotimsg = ReqParams["pkNotimsg"]
        };
        ReqParams["BusinessParams"] = table2json(qryMessInfoByPk_params);
        lua_jjbx.common_req(ReqParams);
    else
        close_loading();
        local responseBody = json2table(vt("responseBody",ResParams));
        if responseBody["errorNo"] == "000000" then
            local pkNotimsg = responseBody["pkNotimsg"];
            local msgConten = formatSpecialChar(responseBody["content"]);
            local messageSubclassEn = formatSpecialChar(responseBody["messageSubclassEn"]);
            if messageSubclassEn == "billEvaluationInfo" then
                msgConten = formatNull(responseBody["headline"]);
            end;
            local businessModule = formatNull(responseBody["businessModule"]);
            local msgDate = formatNull(responseBody["ts"]);
            local pkMsgPublishList = formatNull(responseBody["pkMsgPublishList"]);
            local replyState = formatNull(responseBody["replyState"]);
            local base64Msgid = lua_format.base64_encode(pkMsgPublishList);
            local popupFlag = formatNull(responseBody["popupFlag"]);
            local readFlag = "false";
            local res3 = formatNull(responseBody["res3"]);
            --单据号
            local billNo = formatNull(responseBody["billNo"]);
            --单据类型
            local billType = "";
            if billNo ~= "" then
                billType = bill_no2type(billNo);
            end;
            local detailContents =
                "pkNotimsg="..pkNotimsg..
                "&base64Msgid="..base64Msgid..
                "&messageSubclassEn="..messageSubclassEn..
                "&msgDate="..msgDate..
                "&pkMsgPublishList="..pkMsgPublishList..
                "&popupFlag="..popupFlag..
                "&businessModule="..businessModule..
                "&content="..msgConten..
                "&billNo="..billNo..
                "&res3="..res3..
                "&billType="..billType..
                "&replyState="..replyState..
                "&readFlag=false";
            lua_message.qryMsgDetail(detailContents,"1");
        else
            alert(responseBody["errorMsg"]);
        end;
    end;
end

--[[查询消息详情]]
function lua_message.qryMsgDetail(detailContents,index)
    local detailContents = formatNull(detailContents);
    if detailContents ~= "" then
        local detail = string_to_table(detailContents);
        --debug_alert("查询消息详情 数据"..foreach_arg2print(detail));

        local billNo = vt("billNo",detail);
        local billType = vt("billType",detail);
        local base64Msgid = vt("base64Msgid",detail);
        local messageSubclassEn = vt("messageSubclassEn",detail);
        local content = vt("content",detail);
        local msgDate = vt("msgDate",detail);
        local pkNotimsg = vt("pkNotimsg",detail);
        local pkMsgPublishList = vt("pkMsgPublishList",detail);
        local businessModule = vt("businessModule",detail);
        local popupFlag = vt("popupFlag",detail);
        local res3 = vt("res3",detail);
        local replyState = vt("replyState",detail);
        --定义用于删除的全局变量
        globalTable["DelpkNotimsg"] = pkNotimsg;
        globalTable["DelpkMsgPublishList"] = pkMsgPublishList;
        globalTable["popupFlag"] = popupFlag;
        globalTable["msgCenterIndex"] = index;
        --1业务消息 2企业公告 3产品消息
        globalTable["msgType"] = msgType;
        --debug_alert(globalTable["msgType"]);
        --是否已读
        local readFlag = vt("readFlag",detail);

        --消息默认弹出参数
        local DefaultAlertArg = {
            content=content,
            readFlag=readFlag
        };

        if globalTable["msgType"] == "1" then globalTable["webview_page_title"] = "消息中心";
        elseif globalTable["msgType"] == "2" then globalTable["webview_page_title"] = "企业公告";
        elseif globalTable["msgType"] == "3" then globalTable["webview_page_title"] = "产品消息";
        else globalTable["webview_page_title"] = "消息详情";
        end;

        globalTable["msgCenterTypeIndex"] = conditionIndex;

        --业务消息
        if messageSubclassEn == "businesspublish" or messageSubclassEn == "internalpublish" then
            --查询链接并前往消息h5页面，访问页面后台置为已读，前端无需发已读接口
            local qryArg = {
                PkMsgPublishList = base64Msgid,
                MsgType = msgType,
                PopupFlag = popupFlag
            };
            lua_jjbx.qry_msg_h5_link(qryArg);

        --工资相关消息
        elseif messageSubclassEn == "salarypublish" then
            --标记已读
            if readFlag ~= "true" then
                lua_jjbx.updMarkunreadFlag();
            end;
            globalTable["salaryMonth"] = string.sub(msgDate,1,7);
            invoke_page("jjbx_salary_service/xhtml/monthSalary.xhtml",page_callback,nil);

        --单据审批消息
        elseif messageSubclassEn == "billEvaluationInfo" then
            --查询链接并前往消息h5页面，访问页面后台置为已读，前端无需发已读接口
            local qryArg = {
                PkMsgPublishList = base64Msgid,
                MsgType = msgType,
                PopupFlag = popupFlag
            };
            lua_jjbx.qry_msg_h5_link(qryArg);

        --薪酬管理消息（其他薪酬数据查询通知），跳转薪金查询-其他薪酬数据
        elseif messageSubclassEn == "salaryrelease" then
            --标记已读
            if readFlag ~= "true" then
                lua_jjbx.updMarkunreadFlag();
            end;
            alert_confirm("薪酬管理",content,"返回","查看","alert_confirm_call","CallFun=lua_menu.to_other_salary_info_page");

        --社保管理消息（社保基数确认通知），跳转薪金查询-社保扣缴明细
        elseif messageSubclassEn == "socialsecurityradixpublish" then
            --标记已读
            if readFlag ~= "true" then
                lua_jjbx.updMarkunreadFlag();
            end;
            alert_confirm("社保管理",content,"返回","查看","alert_confirm_call","CallFun=lua_menu.to_social_detail_page");

        --预算管理消息（预算发布通知、预算主体为个人的预算任务），判断是否支持跳转，返回1则跳转个人预算
        elseif messageSubclassEn=="budgetTaskAdjust" or messageSubclassEn=="budgetTaskPublish" then
            if string.find(res3,",1") then
                --标记已读
                if readFlag ~= "true" then
                    lua_jjbx.updMarkunreadFlag();
                end;
                alert_confirm("预算管理",content,"返回","查看","alert_confirm_call","CallFun=lua_menu.to_budget_info_page");
            else
                --消息默认弹出
                lua_jjbx.msg_default_alert(DefaultAlertArg);
            end;

        --在线采购消息
        elseif messageSubclassEn=="ImproveAssertCardInformation" or messageSubclassEn=="CgPaymentAlertBusi" or messageSubclassEn=="CgPaymentAlertWelfare" then
            --标记已读
            if readFlag ~= "true" then
                lua_jjbx.updMarkunreadFlag();
            end;
            local CallArg = {
                orderId=res3,
                messageSubclassEn=messageSubclassEn
            };
            local CallArgStr = lua_format.base64_encode(table2json(CallArg));
            local TipHeadMsg = "查看订单";
            if messageSubclassEn == "CgPaymentAlertBusi" then
                TipHeadMsg = "查看单据";
            end;
            alert_confirm("消息内容",content,"返回",TipHeadMsg,"alert_confirm_call","CallFun=lua_purchase.purchase_msg_call&CallArg="..CallArgStr);

        --反馈消息
        elseif messageSubclassEn == "questionFeedbackNotification" or messageSubclassEn == "questionReplyNotification" then
            --标记已读
            if readFlag ~= "true" then
                lua_jjbx.updMarkunreadFlag();
            end;
            --跳转我的解答(questionFeedbackNotification)/我的回复(questionReplyNotification)
            local pkQuestion = "";
            if res3 ~= "" then
                pkQuestion = res3;
            else
                pkQuestion = pkMsgPublishList;
            end;
            --前往帮助反馈页面
            lua_ask.to_user_ask_page("feedback_reply",{pkQuestion=pkQuestion,questionType=messageSubclassEn});

        --帮助消息
        elseif messageSubclassEn == "functionGuide" or messageSubclassEn == "frequentQuestion" then
            --标记已读
            if readFlag ~= "true" then
                lua_jjbx.updMarkunreadFlag();
            end;
            --帮助消息跳转
            lua_ask.ask_msg_jump({messageSubclassEn=messageSubclassEn});

        --归档清册移交
        elseif messageSubclassEn == "pushInventoryTransferMsg" then
            --标记已读
            if readFlag ~= "true" then
                lua_jjbx.updMarkunreadFlag();
            end;

            billArchive_receiveInventoryTransfer_CallArg = {
                transferInfoSource = splitUtils(res3,",")[1],
                pkNotimsg = pkNotimsg
            };

            if splitUtils(res3,",")[2] == "0" then
                alert_confirm("消息内容",content,"拒绝","确认","lua_message.pushInventoryTransferMsg_callback");
            elseif splitUtils(res3,",")[2] == "1" then
                --已确认
                alert("该消息已确认");
            elseif splitUtils(res3,",")[2] == "2" then
                alert("该移交申请已作废，无需再处理");
            else
                alert_confirm("消息内容",content,"","返回","","");
            end;
        elseif messageSubclassEn == "bankTransactionAuthorization" then
            --标记已读
            if readFlag ~= "true" then
                lua_jjbx.updMarkunreadFlag();
            end;
            globalTable["ifAlertHint"] = "true";
            --跳转至对账待确认列表
            invoke_page("jjbx_msg_center/xhtml/msg_account_checking.xhtml",page_callback,{CloseLoading="false",ClickArg=ClickArg});
        elseif messageSubclassEn == "gydkpays" or messageSubclassEn == "salaryPensionInfo" then
            --标记已读
            if readFlag ~= "true" then
                lua_jjbx.updMarkunreadFlag();
            end;
            if res3 == "0" then
                --查询养老金缴存计划详情
                lua_message.query_pension_info("",{});
            elseif res3 == "1" then
                local nowTime = os.time();
                local nowDate = os.date("%Y-%m-%d",nowTime);
                globalTable["qryPayYear"] = splitUtils(nowDate,"-")[1];
                --无需确认
                globalTable["selfInfoSure"] = "false";
                invoke_page("jjbx_salary_service/xhtml/ylj_qysb_001.xhtml",page_callback,nil);
            end;
        elseif messageSubclassEn == "SendExchangeConfirmation" or messageSubclassEn == "SendTYKKExchangeConfirmation" then
            --标记已读
            if readFlag ~= "true" then
                lua_jjbx.updMarkunreadFlag();
            end;
            --查询往来确认详情
            lua_message.turn_to_verify("",{djh=res3});

        --商旅订单
        elseif messageSubclassEn == "exp" and string.sub(res3,0,3) == "SSL" then
            --标记已读
            if readFlag ~= "true" then
                lua_jjbx.updMarkunreadFlag();
            end;
            lua_message.checkBillUser("",{djh=res3,content=content});
        elseif messageSubclassEn == "tripReminder" then
            --标记已读
            if readFlag ~= "true" then
                lua_jjbx.updMarkunreadFlag();
            end;
            alert_confirm("消息内容",content,"返回","商旅首页","lua_message.to_travel_index","");
        elseif messageSubclassEn == "registrationMessage" then
            --标记已读
            if readFlag ~= "true" then
                lua_jjbx.updMarkunreadFlag();
            end;
            invoke_page("jjbx_process_bill/xhtml/process_bill_jjdj_detail.xhtml",page_callback,{msgID=res3});
        --其他类型消息直接弹出
        else
            if replyState == "0" or replyState == "1" or replyState == "2" then
                --待回复/已回复的消息，进入消息回复/查看回复详情界面
                invoke_page("jjbx_msg_center/xhtml/msg_reply.xhtml",page_callback,nil);
            --在线采购
            elseif businessModule == "120203" then
                invoke_trancode_noloading("jjbx_index","query_msg",{TranCode="CheckJdMessage",msgId=pkNotimsg},lua_message.checkJdMessageCallBack,{});
            elseif billNo ~= "" and billType ~= "" and res3 ~= nil then
                --标记已读
                if readFlag ~= "true" then
                    lua_jjbx.updMarkunreadFlag();
                end;
                globalTable["billCode"] = billNo;
                globalTable["billTypeCode"] = billType;
                globalTable["res3"] = res3;
                --有单据信息的时候弹出
                alert_confirm("消息内容",content,"返回","查看单据","lua_message.msg_to_billDetail","");
            elseif res3 ~= "" and messageSubclassEn == "deductionpulish" then
                globalTable["res3"] = res3;
                alert_confirm("消息内容",content,"返回","去缴款","lua_message.msg_to_billDetail","");
            else
                --消息默认弹出
                lua_jjbx.msg_default_alert(DefaultAlertArg);
            end;
        end;
    else
        alert("暂无详情");
    end;
end;

--[[查看往来确认消息]]
function lua_message.turn_to_verify(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams,{});
        ReqParams["ReqAddr"] = "billNcVerification/turnToVerify";
        ReqParams["ReqUrlExplain"] = "查看往来确认消息";
        ReqParams["BusinessCall"] = lua_message.turn_to_verify;
        local BusinessParams = {
            djh =ReqParams["djh"]
        };
        ReqParams["BusinessParams"] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    else
        close_loading();
        local res = json2table(ResParams["responseBody"]);
        if res["errorNo"] == "000000" then
            local listData = vt("list",res);
            if #listData > 0 then
                local CallBackData = {
                    ItemData = lua_format.table_arg_pack(listData[1])
                };
                local status = formatNull(listData[1]["editStatus"],"0");
                invoke_page("jjbx_index/xhtml/jjbx_wlqr_detail.xhtml",page_callback,{CallBackData=CallBackData,status=status});
            else
                alert("未获取到往来确认详情");
            end;
        else
            alert(res["errorMsg"]);
        end;
    end;
end;

--[[查看工资缴纳方案信息]]
function lua_message.query_pension_info(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams,{});
        ReqParams["ReqAddr"] = "sspSalaryPensionController/queryPensionInfo";
        ReqParams["ReqUrlExplain"] = "查看工资缴纳方案信息";
        ReqParams["BusinessCall"] = lua_message.query_pension_info;
        --获取当前日期
        local nowTime = os.time();
        local nowDate = os.date("%Y-%m-%d",nowTime);
        local nowYear = splitUtils(nowDate,"-")[1];
        local BusinessParams = {qryYear=nowYear};
        ReqParams["BusinessParams"] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    else
        close_loading();
        local res = json2table(ResParams["responseBody"]);
        if res["errorNo"] == "000000" then
            local salaryPensionItem = vt("salaryPensionItem",res);
            if vt("id",salaryPensionItem) ~= "" then
                --有缴存方案时跳转至查看页面
                invoke_page("jjbx_salary_service/xhtml/ylj_jcfa_004.xhtml",page_callback,{queryPensionInfo=res});
            else
                alert("未获取到缴存方案");
            end;
        else
            alert(res["errorMsg"]);
        end;
    end;
end;

--清册消息确认成功回调
function lua_message.billArchive_receiveInventoryTransfer_callback(params)
    close_loading();
    --操作完成，刷新页面数据
    refreshMsg();
    local responseBody = json2table(params["responseBody"]);
    if responseBody["errorNo"] == "000000" then
        alert("操作成功");
    else
        alert(responseBody["errorMsg"]);
    end;
end;

--清册消息确认
function lua_message.billArchive_receiveInventoryTransfer(operationType)
    local ReqParams = {};
    local BusinessParams = {
        transferInfoSource = vt("transferInfoSource",billArchive_receiveInventoryTransfer_CallArg),
        pkNotimsg = vt("pkNotimsg",billArchive_receiveInventoryTransfer_CallArg),
        operationType = operationType
    };
    ReqParams["ReqAddr"] = "billArchive/receiveInventoryTransfer";
    ReqParams["ReqUrlExplain"] = "清册消息确认";
    ReqParams["BusinessParams"] = table2json(BusinessParams);
    ReqParams["BusinessCall"] = lua_message.billArchive_receiveInventoryTransfer_callback;
    lua_jjbx.common_req(ReqParams);
end;

function lua_message.pushInventoryTransferMsg_callback(index)
    if index == 1 then
        --确认移交消息
        lua_message.billArchive_receiveInventoryTransfer("1");
    else
        --拒绝移交消息
        lua_message.billArchive_receiveInventoryTransfer("0");
    end;
end;

--[[查询在线采购订单消息状态回调]]
function lua_message.checkJdMessageCallBack(params)
    local jsonData = params["responseBody"];
    local data = json2table(jsonData);
    if data["errorNo"] == "000000" then
        --标记消息为已读
        lua_jjbx.updMarkunreadFlag();
        -- 跳转页面  0订单详情页 1订单列表页
        if tonumber(data["page"]) == 0 then
            globalTable["jdOrderId"] = formatNull(data["porderId"]);
            --queryAllOrder_params.listIndex = index;
            invoke_trancode(
                "jjbx_service",
                "online_shopping",
                {TranCode="getOrderInfoByOrderId",jdOrderId=globalTable["jdOrderId"]},
                lua_message.getOrderInfoByOrderIdCallBack,
                {},
                all_callback,
                {CloseLoading="false"}
            );
        elseif tonumber(data["page"]) == 1 then
            globalTable["queryAllOrder_params"] = {
                TranCode = "getJdOrderFlow",
                pageNum="1",
                pageSize="10",
                listIndex = "1",
                screenType = "welfare",
                welfareIndex = "1",
                statusIndex = "1",
                descIndex = "1",
                orderType="",
                orderStatus="0",
                sord="",
                jdOrderId=data["porderId"]
            }
            invoke_page("jjbx_online_shopping/xhtml/onlineShopping_allOrder.xhtml",page_callback,{CloseLoading="false"});
        end;
    else
        alert(data["errorMsg"]);
    end;
end;

--[[查询在线采购订单消息状态回调]]
function lua_message.getOrderInfoByOrderIdCallBack(params)
    local responseBody = json2table(params["responseBody"]);
    if responseBody["errorNo"] == "000000" then
        local orderDetail = responseBody["orderList"][1];
        globalTable["orderDetail"] = orderDetail;
        for i=1,#globalTable["orderDetail"]["subOrders"] do
            globalTable["orderDetail"]["subOrders"][i]["name"] = string.gsub(globalTable["orderDetail"]["subOrders"][i]["name"],"{","%{");
            globalTable["orderDetail"]["subOrders"][i]["name"] = string.gsub(globalTable["orderDetail"]["subOrders"][i]["name"],"}","%}");
            globalTable["orderDetail"]["subOrders"][i]["name"] = string.gsub(globalTable["orderDetail"]["subOrders"][i]["name"],"<","《");
            globalTable["orderDetail"]["subOrders"][i]["name"] = string.gsub(globalTable["orderDetail"]["subOrders"][i]["name"],">","》");
        end;
        --globalTable["queryAllOrder_params"] = queryAllOrder_params;
        if orderDetail["uniqueNo"] == "" then
            invoke_page("jjbx_online_shopping/xhtml/onlineShopping_orderDetail_welfare.xhtml",page_callback,nil);
        else
            invoke_page("jjbx_online_shopping/xhtml/onlineShopping_orderDetail_official.xhtml",page_callback,nil);
        end;
    else
        alert(responseBody["errorMsg"]);
    end;
end;

--[[消息前往单据详情]]
function lua_message.msg_to_billDetail(index)
    if index == 1 then
        if globalTable["res3"] ~= "" then
            --前往缴款单
            go_to_jkd("",globalTable["res3"]);
        else
            invoke_trancode_donot_checkRepeat(
                "jjbx_index",
                "my_request",
                {TranCode="BillHaveProcessInfo",billNo=globalTable["billCode"],billType=globalTable["billTypeCode"]},
                bill_page_router,
                {},
                all_callback,
                {CloseLoading="false"}
            );
        end;
    end;
end;

function lua_message.to_travel_index(index)
    if index == 1 then
        invoke_page("jjbx_travel_service/xhtml/travel_service_index.xhtml",page_callback,{});
    end;
end;

--[[查询消息未读数量]]
function qryMsgMarkUnReadCount(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        invoke_trancode_noloading(
            "jjbx_index",
            "query_msg",
            {TranCode="qryMsgMarkUnReadCount"},
            qryMsgMarkUnReadCount,
            {},
            all_callback,
            {CloseLoading="false"}
        );
    else
        local responseBody = json2table(ResParams["responseBody"]);
        if responseBody["errorNo"] == "000000" then
            local unReadCount = tonumber(responseBody["unReadCount"]);
            if unReadCount > 0 then
                if unReadCount < 100 then
                    changeProperty("JJBX_titleName","value","消息中心("..unReadCount..")");
                else
                    changeProperty("JJBX_titleName","value","消息中心(99+)");
                end;
                page_reload();
                show_ele("head_title_icon_div");
                lua_page.update_top({updateTarget="title_icon"});
            else                            
                changeProperty("JJBX_titleName","value","消息中心");
                hide_ele("head_title_icon_div");
            end;
            close_loading();
        else
            alert(responseBody["errorMsg"]);
        end;
    end;
end;

--[[查看往来确认消息]]
function lua_message.checkBillUser(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams,{});
        ReqParams["ReqAddr"] = "/bill/common/checkBillUser";
        ReqParams["ReqUrlExplain"] = "查看往来确认消息";
        ReqParams["BusinessCall"] = lua_message.checkBillUser;
        local BusinessParams = {
            billNo = ReqParams["djh"]
        };
        globalTable["content"] = ReqParams["content"];
        ReqParams["BusinessParams"] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    else
        close_loading();
        local res = json2table(ResParams["responseBody"]);
        local content = vt("content",globalTable);
        globalTable["content"] = nil;
        if res["errorNo"] == "000000" then
            local bill = vt("bill",res);
            local zdrgh = vt("zdrgh",bill);
            if vt("workid",globalTable) == zdrgh then
                local orderID = ryt:getSubstringValue(content,4,23);
                invoke_page("jjbx_travel_service/xhtml/travel_service_my_orders.xhtml",page_callback,{orderID=orderID});
            else
                alert_confirm("消息内容",content,"","确认","","");
            end;
        else
            alert(res["errorMsg"]);
        end;
    end;
end;