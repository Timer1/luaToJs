--[[当局相关lua]]
lua_bill = {};
--单据发票查验状态(1：未查验、0：已查验)
VERIFY_UN_CHECKED = "1";

--[[保存报销内容]]
function lua_bill.save_billB(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams);
        ReqParams["BusinessType"] = "reimbursement_bill";
        ReqParams["TranCode"] = "saveBillB";

        invoke_trancode(
            "jjbx_process_query",
            "process_bill",
            ReqParams,
            lua_bill.save_billB,
            {ResCallFunc=ReqParams["ResCallFunc"]},
            all_callback,
            {CloseLoading="false"}
        );
    else
        local res = json2table(ResParams["responseBody"]);
        local errorNo = vt("errorNo",res);
        local errorMsg = vt("errorMsg",res,"保存失败");
        if errorNo == "000000" then
            --alertToast("0",C_SavedMsg,"","back_fun_loading","");
            alertToast0(C_SavedMsg);
            local ResCallFunc = vt("ResCallFunc",ResParams);
            if ResCallFunc == "" then
                back_fun_noloading();
            else
                lua_system.do_function(ResCallFunc);
            end;
        else
            alert(errorMsg);
        end;
    end;
end;

--[[查询单据模板信息]]
function lua_bill.receiptsModelList(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        --查询单据模板信息
        invoke_trancode_donot_checkRepeat(
            "jjbx_process_query",
            "process_bill",
            {
                BusinessType="bill_index",
                TranCode="ReceiptsModelList",
                billTypeCode=ReqParams["billType"]
            },
            lua_bill.receiptsModelList,
            {
                receiptsModelList_callBack=ReqParams["receiptsModelList_callBack"]
            },
            all_callback,
            {CloseLoading="false"}
        );
    else
        local responseBody = json2table(ResParams["responseBody"]);

        if responseBody["errorNo"] == "000000" then
            local receiptsDemoList = formatNull(responseBody["receiptsDemoList"]);
            if #receiptsDemoList > 0 then
                --模板列表存储缓存
                globalTable["receiptsDemoList"] = receiptsDemoList;
            else
                globalTable["receiptsDemoList"] = {};
            end;
        else
            globalTable["receiptsDemoList"] = {};
        end;

        local CallBackFun = vt("receiptsModelList_callBack",ResParams);
        if CallBackFun == "" then
            close_loading();
        else
            lua_system.do_function(CallBackFun,"");
        end;
    end;
end;

--[[新增报账单]]
function new_reimbursement_bill(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        --是否为审批人编辑 false: 否
        globalTable["ifApproverEdit"] = "false";
        local InitReimbursementBillReqParams = {
            BusinessType="reimbursement_bill",
            TranCode="applyNewBill",
            billTypeCode=billTypeList_utils.bzd,
            billTemplateId=globalTable["modelIdList"],
            ProcessInvoiceIdListJson=ReqParams["ProcessInvoiceIdListJson"]
        };
        invoke_trancode_donot_checkRepeat(
            "jjbx_process_query",
            "process_bill",
            InitReimbursementBillReqParams,
            new_reimbursement_bill,
            {ProcessInvoiceIdListJson=ReqParams["ProcessInvoiceIdListJson"]},
            all_callback,
            {CloseLoading="false"}
        );
    else
        local res = json2table(ResParams["responseBody"]);
        if res["errorNo"] == "000000" then
            globalTable["responseBody_bzd"] = res;
            globalTable["billNo"] = res["bill"][1]["djh"];
            globalTable["billState_bzd"] = res["bill"][1]["djzt"];
            globalTable["pageConfig_bzd"] = res["queryConfig"];
            globalTable["bzdZDY1Name"] = formatNull(res["ZDY1Name"]);
            globalTable["bzdZDY2Name"] = formatNull(res["ZDY2Name"]);
            globalTable["bzdZDY3Name"] = formatNull(res["ZDY3Name"]);
            globalTable["bzdZDY4Name"] = formatNull(res["ZDY4Name"]);
            globalTable["bzdZDY5Name"] = formatNull(res["ZDY5Name"]);
            globalTable["bzdZDY6Name"] = formatNull(res["ZDY6Name"]);
            local billBs = formatNull(res["billBs"],{});
            globalTable["billBid"] = billBs[1]["id"];
            globalTable["editFlag"] = "false";
            globalTable["szxmEnableFlag"] = "true";
            globalTable["ywlxEnableFlag"] = "true";
            globalTable["fjzs"] = "";
            globalTable["zdyzd"] = "";
            globalTable["firstInPage"] = "true";
            --清空缓存的模板ID，防止返回时重复载入同一个模板
            globalTable["modelIdList"] = "";
            globalTable["temp_flag"] = "invoice";
            invoke_page("jjbx_proccess_reimbursement_bill/xhtml/reimbursement_bill_edit.xhtml",page_callback,{CloseLoading="false"});
        else
            alert(res["errorMsg"]);
        end;
    end;
end;

--[[跳转单具体单据制单页面]]
function lua_bill.to_bill_apply_page(Arg)
    --单据类型
    globalTable["receiptsType"] = globalTable["billType"];
    --请求查询单据配置时的状态为新增单据
    globalTable["pageType"] = "newBill";
    --模板编号
    globalTable["modelIdList"] = vt("modelIdList",Arg);
    --单据号
    local billNo = vt("billNo",Arg);
    --页面地址
    local PageUrl = "";
    --切换页面回调方法
    local PageCallBack = page_callback;
    --切换页面回调参数
    local PageCallBackParams = formatNull(Arg,{});
    PageCallBackParams["CloseLoading"] = "false";
    PageCallBackParams["billNo"] = billNo;

    if globalTable["billType"] == billTypeList_utils.bzd then
        --[[报账单]]
        globalTable["billNo"] = billNo;
        PageUrl = "jjbx_proccess_reimbursement_bill/xhtml/reimbursement_bill_index.xhtml";
    elseif globalTable["billType"] == billTypeList_utils.sxsq then
        --[[事项申请单]]
        globalTable["billCode"] = billNo;
        PageUrl = "jjbx_proccess_matter_apply_bill/xhtml/matter_apply_bill_index.xhtml";
    elseif globalTable["billType"] == billTypeList_utils.clbx then
        --[[差旅报销单]]
        globalTable["billCode"] = billNo;
        PageUrl = "jjbx_proccess_travel_process_bill/xhtml/travel_process_bill_index.xhtml";
    elseif globalTable["billType"] == billTypeList_utils.jk then
        --[[借垫款单]]
        globalTable["JKDbillNo"] = billNo;
        globalTable["if_conn_exame"] = "";
        PageUrl = "jjbx_process_borrow_bill/xhtml/borrow_bill_index.xhtml";
    elseif globalTable["billType"] == billTypeList_utils.hk then
        --[[还款单]]
        globalTable["hkBillNo"] = billNo;
        PageUrl = "jjbx_proccess_repayment_bill/xhtml/repayment_bill_index.xhtml";
    elseif globalTable["billType"] == billTypeList_utils.yfkzf then
        --[[应付款支付单]]
        PageUrl = "jjbx_proccess_pay_bill/xhtml/pay_bill_index.xhtml";
        globalTable["YFKZFbillNo"] = billNo;
        globalTable["newFlag"] = vt("newFlag",Arg,1);
    else
        alert("暂不支持该单据")
        return;
    end;

    --[[debug_alert(
        "to_bill_apply_page\n"..
        "PageUrl:"..PageUrl.."\n"..
        ""
    );]]
    if vt("ProcessInvoiceIdListJson",Arg) ~= "" then
        --发票发起的报账单直接进入报销明细页面
        new_reimbursement_bill("",PageCallBackParams);
    else
        invoke_page_donot_checkRepeat(PageUrl,PageCallBack,PageCallBackParams);
    end;
end;

--[[选择制单人部门]]
function lua_bill.select_business_scene_zdrbm(index)
    lua_page.div_page_ctrl();
    globalTable["zdrbmInfo"] = globalTable["zdrbmList"][tonumber(index)];
    local element = document:getElementsByName("zdrbm");
    if #element > 0 then
        changeProperty("zdrbm","value",globalTable["zdrbmInfo"]["unitname"]);
    else
        changeProperty("ssbm","value",globalTable["zdrbmInfo"]["unitname"]);
    end;
end;

--[[弹出制单人部门列表]]
function lua_bill.show_zdrbm_select_page()
    local zdrbmData = formatNull(globalTable["zdrbmList"]);
    if zdrbmData == "" then
        alert("无可用的制单人部门");
    else
        lua_page.div_page_ctrl('zdrbm_page_div','false','false');
    end;
end;

--[[渲染制单人部门]]
function lua_bill.render_business_purchase_scene_zdrbm()
    --制单人部门数据
    local zdrbmData = formatNull(globalTable["zdrbmList"]);
    --采购制度存在时创建
    if #zdrbmData > 0 then
        local selectEleArg = {};
        for key,value in pairs(zdrbmData) do
            local unitcode = formatNull(value["unitcode"]);
            local unitname = formatNull(value["unitname"]);
            local selectEleArgItem = {
                --显示文字
                labelName=unitname,
                --备注文字
                tipName="",
                --点击函数
                clickFunc="lua_bill.select_business_scene_zdrbm",
                --点击函数入参
                clickFuncArg=tostring(key)
            };
            table.insert(selectEleArg,selectEleArgItem);
        end;

        --渲染select页面
        local renderSelectArg = {
            bgName="zdrbm_page_div",
            topEleName="top_zdrbm_div",
            topTitleName="选择申请部门",
            selectEleName="zdrbm_list_div",
            selectEleArg=selectEleArg,
            renderCallBackFun="render_select_zdrbm_page_call"
        };
        lua_page.render_select_page(renderSelectArg);
    end;
end;

--[[查询部门]]
function lua_bill.jjbx_getDeptInfo(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        ReqParams["BusinessType"] = "reimbursement_bill";
        ReqParams["TranCode"] = "getDeptInfo";
        invoke_trancode_donot_checkRepeat(
            "jjbx_process_query",
            "process_bill",
            ReqParams,
            lua_bill.jjbx_getDeptInfo,
            {},
            all_callback,
            {CloseLoading="false"}
        );
    else
        local res = json2table(ResParams["responseBody"]);
        if res["errorNo"] == "000000" then
            globalTable["zdrbmList"] = res["list"];
            lua_bill.render_business_purchase_scene_zdrbm();
        else
            alert(res["errorMsg"]);
        end;
    end;
end;

--[[前往单据模板管理页面]]
function lua_bill.to_bill_module_page(Arg)
    local BillModuleManagementInstall = lua_system.check_app_func("BillModuleManagement");
    --模板管理类型 Choose:选择模板 Reload:重新载入
    local ModulePageStyle = vt("ModulePageStyle",Arg,"Choose");
    if BillModuleManagementInstall == "true" then
        --debug_alert("跳转模板管理");
        local InovkePageArg = formatNull(Arg,{});
        InovkePageArg["CloseLoading"] = "false";
        InovkePageArg["ModulePageStyle"] = ModulePageStyle;
        --进入模板页面之前，清空上一次选择
        globalTable["modelIdList"] = "";
        invoke_page("jjbx_process_bill/xhtml/process_bill_module.xhtml",page_callback,InovkePageArg);
    else
        close_loading();
        local SkipVersionUpdateCallFuc = "";
        if ModulePageStyle == "Choose" then
            --选择的情况下，允许跳过
            SkipVersionUpdateCallFuc = "lua_bill.to_bill_apply_page";
        end;

        --更新提示
        local upverArg = {
            updateType="OPTION",
            updateMsg="模板服务已经升级，请更新后使用。",
            SkipVersionUpdateCallFuc=SkipVersionUpdateCallFuc
        };
        lua_ota.show_upvsr_view(upverArg);
        return;
    end;
end;

--[[载入模板返回方法]]
function lua_bill.reloadTemplate_to_back()
    --菜单页栈值
    local billMenu_historyLength = vt("billMenu_historyLength",globalTable);
    if billMenu_historyLength == "" then
        billMenu_historyLength = 0;
    end;
    local thisHistory = history:length();
    local pageIndex = 0;
    local differHistory = tonumber(thisHistory) - tonumber(billMenu_historyLength);
    if vt("reloadTemplate",globalTable) == "true" then
        globalTable["reloadTemplate"] = nil;
        if differHistory > 1 then
            if differHistory == 3 then
                --回到菜单页（单据列表或报销申请首页）
                pageIndex = billMenu_historyLength;
            else
                --回到模板选择页面
                pageIndex = tonumber(billMenu_historyLength) + 1;
            end;
        else
            --回到菜单页（单据列表或报销申请首页）
            pageIndex = billMenu_historyLength;
        end;
        back_fun_getHistory(pageIndex);
    else
        if billMenu_historyLength ~= 0 then
            back_fun_getHistory(billMenu_historyLength);
        else
            back_fun();
        end;
    end;
end;

--[[查询单据模板信息]]
function lua_bill.query_bill_module(billTypeCode)
    --debug_alert("query_bill_module billTypeCode:"..billTypeCode);
    --根据单据类型配置单据页面名称
    globalTable["billType"] = billTypeCode;
    if billTypeCode == billTypeList_utils.bzd then
        globalTable["pageName"] = "报账单";
    elseif billTypeCode == billTypeList_utils.sxsq then
        globalTable["pageName"] = "事项申请单";
    elseif billTypeCode == billTypeList_utils.clbx then
        globalTable["pageName"] = "差旅报销单";
    elseif billTypeCode == billTypeList_utils.jk then
        globalTable["pageName"] = billNameList_utils.jk;
    elseif billTypeCode == billTypeList_utils.hk then
        globalTable["pageName"] = "还款单";
    elseif billTypeCode == billTypeList_utils.yfkzf then
        globalTable["pageName"] = "应付款支付单";
    end;

    --执行查询单据模板信息
    lua_bill.do_query_bill_module("",{});
end;

--[[执行查询单据模板信息]]
function lua_bill.do_query_bill_module(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        invoke_trancode_donot_checkRepeat(
            "jjbx_process_query",
            "process_bill",
            {
                BusinessType="bill_index",
                TranCode="ReceiptsModelList",
                billTypeCode=globalTable["billType"]
            },
            lua_bill.do_query_bill_module,
            {},
            all_callback,
            {CloseLoading="false"}
        );
    else
        responseBody = json2table(ResParams["responseBody"]);
        if responseBody["errorNo"] == "000000" then
            local receiptsDemoList = vt("receiptsDemoList",responseBody);
            local receiptsDemoCounts = #receiptsDemoList;
            --debug_alert(receiptsDemoCounts);
            --获取单据类型
            local billType = vt("billType",globalTable);
            if receiptsDemoCounts<=0 or billType==billTypeList_utils.yfkzf or billType==billTypeList_utils.hkd then
                --debug_alert("应付款支付单，还款单，模板数目为空的情况下直接制单");
                lua_bill.to_bill_apply_page({});
            else
                --debug_alert("模板数据存缓存");
                globalTable["receiptsDemoList"] = receiptsDemoList;

                --前往单据模板管理页面
                lua_bill.to_bill_module_page(Arg);
            end;
        else
            jjbx_show_business_err(responseBody["errorNo"],responseBody["errorMsg"]);
        end;
    end;
end;

--校验配置是否必填项
function lua_bill.bill_check_config(elementName,valueType)
    local elements = document:getElementsByName(elementName);
    local valueType = formatNull(valueType,"string");
    if #elements > 0 then
        local eValue = getValue(elementName);
        if getValue(elementName.."_required") == "*" and getStyleList(elementName.."_div","display")[1] == "block" then
            if valueType == "select" then
                if eValue == "请选择" or eValue == "" then
                    alert("请选择"..getValue(elementName.."_title"));
                    return "false";
                else
                    return "true";
                end;
            elseif valueType == "number" then
                eValue = formatNull(eValue,0);
                eValue = string.gsub(eValue,",","");
                if tonumber(eValue) then
                    if tonumber(eValue) <= 0 then
                        alert("请输入"..getValue(elementName.."_title"));
                        return "false";
                    else
                        return "true";
                    end;
                else
                    debug_alert("数据类型错误");
                    return "false";
                end;
            else
                if eValue == "" then
                    alert("请输入"..getValue(elementName.."_title"));
                    return "false";
                else
                    return "true";
                end;
            end;
        else
            return "true";
        end;
    else
        debug_alert("元素未定义");
        return "true";
    end;
end;

--加载往来公司列表
function lua_bill.createAuthCorpTree(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        invoke_trancode_donot_checkRepeat(
            "jjbx_service",
            "app_service",
            ReqParams,
            lua_bill.createAuthCorpTree,
            {},
            all_callback,
            {CloseLoading="false"}
        );
    else
        local responseBody = json2table(ResParams["responseBody"]);
        if responseBody["errorNo"] == "000000" then
            globalTable["CompanyData"] = vt("CompanyData",responseBody);
            changeProperty("wlgsView","value",globalTable["CompanyData"].."&");
        else
            alert(responseBody["errorMsg"]);
        end;
    end;
end;

function lua_bill.check_wlgs_required(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams,{});
        ReqParams["ReqAddr"] = "bill/common/checkWlgsRequired";
        ReqParams["ReqUrlExplain"] = "根据收支项目或借垫款类型查询是否为往来公司科目";
        ReqParams["BusinessCall"] = lua_bill.check_wlgs_required;
        
        local BusinessParams = {
            billNo=ReqParams["billNo"],
            fieldValueCode=ReqParams["fieldValueCode"]
        };
        ReqParams["BusinessParams"] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    else
        close_loading();
        local res = json2table(ResParams["responseBody"]);
        if res["errorNo"] == "000000" then
            if vt("required",res) == "0" then
                changeStyle("wlgs_div","display","none");
            else
                local pageConfig = vt("temp_pageConfig",globalTable);
                globalTable["temp_pageConfig"] = nil;
                local fieldVisible = jjbx_getPageConfigDetail("wlgs",pageConfig,"fieldVisible");
                --配置显示则显示，否则不处理
                if fieldVisible == "1" then
                    changeStyle("wlgs_div","display","block");
                end;
            end;
            page_reload();
        else
            alert(res["errorMsg"]);
        end;
    end;
end;

function lua_bill.jjbx_doubleButton1(index)
    back_fun();
end;

function lua_bill.jjbx_doubleButton2(index)
    if index == 0 then
        back_fun();
    else
        --再次提交
        RobotCheckFlag = "0";
        local callFunName = vt("callFunName",globalTable);
        globalTable["callFunName"] = "";
        if callFunName ~= "" then
            lua_system.do_function(callFunName,{});
        else
            jjbx_confirm();
        end;
    end;
end;

--机器人审批结果处理
function lua_bill.robot_check_callBack(responseBody,type,callFunName)
    local weakStr = formatNull(responseBody["weakStr"],{});
    local alertInfo_weakStr = "";
    if #weakStr > 0 then
        for i=1,#weakStr do
            if #weakStr > 1 and i ~= #weakStr then
                alertInfo_weakStr = alertInfo_weakStr..weakStr[i].."/";
            else
                alertInfo_weakStr = alertInfo_weakStr..weakStr[i];
            end;
        end;
    end;

    local strongStr = formatNull(responseBody["strongStr"],{});
    local alertInfo_strongStr = "";
    if #strongStr > 0 then
        for i=1,#strongStr do
            if #strongStr > 1 and i ~= #strongStr then
                alertInfo_strongStr = alertInfo_strongStr..strongStr[i].."/";
            else
                alertInfo_strongStr = alertInfo_strongStr..strongStr[i];
            end;
        end;
    end;
    local alertInfo = "";
    if alertInfo_weakStr ~= "" and alertInfo_strongStr ~= "" then
        alertInfo = alertInfo_strongStr;
    else
        alertInfo = alertInfo_strongStr.."\n"..alertInfo_weakStr;
    end;
    if responseBody["errorNo"] == "800009" then
        alert_confirm("温馨提示",alertInfo,"","返回","lua_bill.jjbx_doubleButton1");
    elseif responseBody["errorNo"] == "800008" then
        local btnName = "继续批准";
        if type == "submit" then
            btnName = "继续提交";
        end;
        globalTable["callFunName"] = callFunName;
        alert_confirm("温馨提示",alertInfo_weakStr,"返回",btnName,"lua_bill.jjbx_doubleButton2");
    elseif responseBody["errorNo"] == "SPE001" then
        alert_confirm("温馨提示",responseBody["errorMsg"],"返回",SPECIAL_EXPLAIN_TITLE,"look_special_img");
    elseif responseBody["errorNo"] == "I00999" then
        globalTable["reSubmit_agreeBill_arg"] = {
            callBackFun = callFunName,
            callBackArg = ""
        };
        alert_confirm("温馨提示",responseBody["errorMsg"],"取消","确认","lua_bill.reSubmit_agreeBill");
    else
        alert(responseBody["errorMsg"]);
    end;
end;

-- 查询审批节点
function lua_bill.query_select_node(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams,{});
        ReqParams["ReqAddr"] = "bill/common/querySelectNode";
        ReqParams["ReqUrlExplain"] = "查询审批节点";
        ReqParams["BusinessCall"] = lua_bill.query_select_node;
        
        local BusinessParams = {
            billNo=ReqParams["billNo"]
        };
        ReqParams["BusinessParams"] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    else
        close_loading();
        local res = json2table(ResParams["responseBody"]);
        if res["errorNo"] == "000000" then
            globalTable["selectNodelist"] = res["selectNode"];
            globalTable["spjdFlag"] = "1";
        else
            globalTable["spjdFlag"] = "0";
            --debug_alert(res["errorMsg"]);
        end;
    end;
end;

--查询单据信息
function lua_bill.query_by_billNo(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams,{});
        ReqParams["ReqAddr"] = "bill/common/queryByBillNo";
        ReqParams["ReqUrlExplain"] = "查询单据信息";
        ReqParams["BusinessCall"] = lua_bill.query_by_billNo;
        
        local BusinessParams = {
            billNo=ReqParams["billNo"]
        };
        ReqParams["BusinessParams"] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    else
        close_loading();
        local res = json2table(ResParams["responseBody"]);
        if res["errorNo"] == "000000" then
            local bill = res["bill"];
            --是否支持附件下载
            local PCConfigListsTable = vt("PCConfigListsTable",globalTable);
            local IMG0016 = vt("IMG0016",PCConfigListsTable,"是");
            --待提交且配置为不支持附件下载的情况下，不显示下载按钮
            if bill["djzt"] == "0" or bill["djzt"] == "99" then
                if IMG0016 == "是" then
                    globalTable["downloadFlag"] = "true";
                else
                    globalTable["downloadFlag"] = "false";
                end;
            else
                globalTable["downloadFlag"] = "true";
            end;
        else
            --alert(res["errorMsg"]);
        end;
    end;
end;

--跳转预警消息查看/新增页面
function lua_bill.look_warning_msg()
    local billNo = vt("tempBillNo",globalTable);
    globalTable["tempBillNo"] = nil;
    if billNo ~= "" then
        local changeWarningFlag = vt("changeWarningFlag",globalTable);
        globalTable["changeWarningFlag"] = nil;
        invoke_page("jjbx_process_bill/xhtml/process_bill_warning_msg.xhtml",page_callback,{billNo=billNo,changeWarningFlag=changeWarningFlag})
    end;
end;

function lua_bill.queryWarningInfoByBillNo(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams,{});
        ReqParams["ReqAddr"] = "warninginfo/queryWarningInfoByBillNo";
        ReqParams["ReqUrlExplain"] = "查询预警消息";
        ReqParams["BusinessCall"] = lua_bill.queryWarningInfoByBillNo;
        local BusinessParams = {
            billNo = ReqParams["billNo"]
        };
        ReqParams["BusinessParams"] = table2json(BusinessParams);
        ReqParams["ReqFuncName"] = "invoke_trancode_noloading";
        lua_jjbx.common_req(ReqParams);
    else
        close_loading();
        local res = json2table(ResParams["responseBody"]);
        if res["errorNo"] == "000000" then
            local infoList = vt("infoList",res);     
            --存在预警消息或用户有新增预警消息权限时，显示预警消息按钮
            if #infoList > 0 or vt("changeWarningFlag",globalTable) == "1" then
                changeStyle("drag_ctrl_ele2","display","block");
            else
                changeStyle("drag_ctrl_ele2","display","none");
            end;
            page_reload();
        else
            alert(res["errorMsg"]);
        end;
    end;
end;

--初始化预警消息悬浮按钮
function lua_bill.render_warning_msg(warningFlag,changeWarningFlag,billNo)
    local e = document:getElementsByName("drag_ctrl_ele2");
    if #e > 0 and warningFlag == "1" then
        --预警消息单据号
        globalTable["tempBillNo"] = billNo;
        --是否支持手工补充预警消息
        globalTable["changeWarningFlag"] = changeWarningFlag;
        --初始化动画效果
        AniSetDragArg2["DragYStyleCtrl"] = "CloseToRight";
        lua_animation.set_drag_listener(AniSetDragArg2);
        --查询预警消息
        lua_bill.queryWarningInfoByBillNo("",{billNo=billNo});
    end;
end;

--审批驳回后回调
function lua_bill.updReviewPoolByBillNo(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams,{});
        ReqParams["ReqAddr"] = "shareReviewPoolIndex/updReviewPoolByBillNo";
        ReqParams["ReqUrlExplain"] = "审批驳回后回调";
        ReqParams["BusinessCall"] = lua_bill.updReviewPoolByBillNo;
        -- operate:0-驳回、1-批准
        local BusinessParams = {
            billNo = ReqParams["billNo"],
            operate = ReqParams["operate"]
        };
        ReqParams["BusinessParams"] = table2json(BusinessParams);
        ReqParams["ReqFuncName"] = "invoke_trancode_noloading";
        lua_jjbx.common_req(ReqParams);
    else
        close_loading();
        local res = json2table(ResParams["responseBody"]);
        -- 不处理结果
        if res["errorNo"] == "000000" then

        else
            
        end;
    end;
end;

--选择供应商
function lua_bill.getSupplier(index,Arg)
    --关闭选择页面
    lua_page.div_page_ctrl();
    --获取供应商信息
    local supplierInfo = splitUtils(Arg,"_");
    --获取上一次勾选的下标
    local tempIndex = vt("tempIndex_supplierList",globalTable);
    --获取图标元素
    local e = document:getElementsByName("supplierSelected");
    --初始化供应商变量
    if vt("gys",globalTable) == "" then
        globalTable["gys"] = {
            gys = "",
            gysbm = ""
        };
    end;
    --两次选择的为同一个值时，清空赋值
    if tempIndex ~= "" and (supplierInfo[1] == globalTable["gys"].gysbm) then
        e[tonumber(tempIndex)]:setStyleByName("display","none");
        --将当前项标记为上一次选择
        globalTable["tempIndex_supplierList"] = "";
        --缓存供应商信息
        globalTable["gys"].gysbm = "";
        globalTable["gys"].gys = "";
        --填充信息
        changeProperty("gys","value","请选择");
    else
        --取消上一次选择
        if tempIndex ~= "" then
            e[tonumber(tempIndex)]:setStyleByName("display","none");
        end;
        --勾选当前项
        e[tonumber(index)]:setStyleByName("display","block");
        --将当前项标记为上一次选择
        globalTable["tempIndex_supplierList"] = index;
        --缓存供应商信息
        globalTable["gys"].gysbm = supplierInfo[1];
        globalTable["gys"].gys = supplierInfo[2];
        --填充信息
        changeProperty("gys","value",supplierInfo[2]);
    end;
end;

--渲染供应商列表页面
function lua_bill.render_supplier_list_page()
    local supplierList = {};
    if vt("searchFlag_supplierInfo",globalTable) == "true" then
        --加载搜索结果列表
        supplierList = vt("supplierInfoList_search",globalTable);
    else
        --加载常规列表
        supplierList = vt("supplierInfoList",globalTable);
    end;
    if #supplierList > 0 then
        local htmlContent = "";
        local supplierCode = "";
        local supplierName = "";
        local arg = "";
        for key,value in pairs(supplierList) do
            supplierCode = jjbx_utils_setStringLength(value["supplierCode"],14);
            supplierName = jjbx_utils_setStringLength(value["supplierName"],14);
            arg = value["supplierCode"].."_"..value["supplierName"];
            htmlContent = htmlContent..[[
                <div class="supplierInfo_div" name="supplierInfo" border="0" onclick="lua_bill.getSupplier(']]..key..[[',']]..arg..[[')" >
                    <label class="supplierInfoCode_css" value="]]..supplierCode..[[" />
                    <label class="supplierInfoName_css" value="]]..supplierName..[[" />
                    <img src="local:selected_round.png" class="selected_round_css" name="supplierSelected" />
                    <line class="line_css_supplier" />
                </div>
            ]];
        end;
        htmlContent = [[
            <div class="supplierInfoList_div" border="0" name="supplierInfoList">
        ]]..htmlContent..[[
            </div>
        ]];
        document:getElementsByName("supplierInfoList")[1]:setInnerHTML(htmlContent);
        page_reload();
    else
        local htmlContent = [[
            <div class="supplierInfoList_div" border="0" name="supplierInfoList">
                <img src="local:noData.png" class="supplierList_noData_img" />
                <label class="supplierList_noData_label" value="暂无数据" />
            </div>
        ]];
        document:getElementsByName("supplierInfoList")[1]:setInnerHTML(htmlContent);
        page_reload();
    end;
end;

--查询供应商信息列表
function querySupplierInfoForBill(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams,{});
        ReqParams["ReqAddr"] = "supplierInfoController/querySupplierInfoForBill";
        ReqParams["ReqUrlExplain"] = "查询供应商信息列表接口";
        ReqParams["BusinessCall"] = querySupplierInfoForBill;
        local BusinessParams = {
            pkCorp = vt("billPkCorp",globalTable),
            gys = ReqParams["gys"]
        };
        globalTable["billPkCorp"] = "";
        ReqParams["BusinessParams"] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    else
        close_loading();
        local res = json2table(ResParams["responseBody"]);
        if res["errorNo"] == "000000" then
            --获取供应商列表
            globalTable["supplierInfoList"] = vt("supplierInfoList",res,{});
            --渲染供应商列表页面
            lua_bill.render_supplier_list_page("show");
        end;
    end;
end;

--搜索供应商
function searchSupplierName()
    local supplierName = getValue("top_search_text");
    if supplierName ~= "" then
        querySupplierInfoForBill("",{gys=supplierName});
    else
        alert("请输入供应商名称");
    end;
end;

--初始化供应商列表页
function lua_bill.initSupplierInfo(pkCorp)
    globalTable["billPkCorp"] = pkCorp;
    --适配高度
    height_adapt("supplierInfoList");
    local htmlContent = [[
        <div class="supplierInfoList_div" border="0" name="supplierInfoList">
            <img src="local:noData.png" class="supplierList_noData_img" />
            <label class="supplierList_noData_label" value="暂无数据" />
        </div>
    ]];
    document:getElementsByName("supplierInfoList")[1]:setInnerHTML(htmlContent);
    
    height_adapt("gys_page",0,0);
    --创建供应商页面头部
    create_page_title("lua_page.div_page_ctrl()", "search_bar", "供应商名称", "", "label_bar", "搜索", "searchSupplierName()","top_supplier_div");
end;

--回调直接返回上一页
function lua_bill.initErrorCallBack(index)
    if tonumber(index) == 1 then
        back_fun();
    end;
end;

--新建行程报销单校验
function lua_bill.qryAbnormalExpByBillNoForApp(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        ReqParams["ReqAddr"] = "bt/expDetails/qryAbnormalExpByBillNoForApp";
        ReqParams["ReqUrlExplain"] = "新建行程报销单校验";
        ReqParams["BusinessCall"] = lua_bill.qryAbnormalExpByBillNoForApp;
        local BusinessParams = {
            djh = ReqParams["billNo"]
        };
        ReqParams["BusinessParams"] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    else
        local responseBody = json2table(ResParams["responseBody"]);
        if responseBody["errorNo"] == "AB0004" then
            alert_confirm("温馨提示",responseBody["errorMsg"],"","确定","lua_bill.initErrorCallBack");
        else
            if #document:getElementsByName("btn_content_div") > 0 then
                changeStyle("btn_content_div","display","block");
            end;
        end;
    end;
end;

--据单据关联的增值税发票获取收款人信息
function lua_bill.querySkrInfoByInvoiceForApp(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams,{});
        ReqParams["ReqAddr"] = "bill/common/querySkrInfoByInvoiceForApp";
        ReqParams["ReqUrlExplain"] = "据单据关联的增值税发票获取收款人信息";
        ReqParams["BusinessCall"] = lua_bill.querySkrInfoByInvoiceForApp;
        local BusinessParams = {
            billNo = ReqParams["billNo"]
        }
        ReqParams["BusinessParams"] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    else
        close_loading();
        forPayeePsnforAppCallBack(ResParams);
    end;
end;

--查询结算详情信息(获取用户卡号)
function lua_bill.queryBusibillP(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        ReqParams["ReqAddr"] = "bill/common/queryBusibillP";
        ReqParams["ReqUrlExplain"] = "查询结算详情信息";
        ReqParams["BusinessCall"] = lua_bill.queryBusibillP;
        local BusinessParams = {
            billPId = ReqParams["billPId"]
        };
        ReqParams["BusinessParams"] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    else
        close_loading();
        local responseBody = json2table(ResParams["responseBody"]);
        if responseBody["errorNo"] == "000000" then
            local billPs = responseBody["billPs"];
            if #billPs > 0 then
                local billp = billPs[1];
                local skzh = vt("skzh",billp);
                if skzh ~= "" then
                    globalTable["jsd"]["skzh"] = skzh;
                    changeProperty("skzh","value",skzh);
                end;
                --页面存在钱包名称的时候
                local qbmc = vt("qbmc",billp);
                local e = document:getElementsByName("qbmc");
                if #e > 0 then
                    changeProperty("qbmc","value",qbmc);
                end;
                --页面存在账户标识
                e = document:getElementsByName("zhbs_div");
                if #e > 0 then
                    local zhbsbm = vt("zhbsbm",billp);
                    lua_components.set_radio_select(zhbsbm,'accountType','getZHBS');
                end;
            end;
        else
            alert(responseBody["errorMsg"]);
        end;

        jjbx_initPage(globalTable["jsd"]);
    end;
end;

--选择列表值
function lua_bill.getSelectValue(index,Arg)
    --关闭选择页面
    lua_page.div_page_ctrl();
    --获取供应商信息
    local selectInfo = splitUtils(Arg,"_");
    --获取上一次勾选的下标
    local selectValue = vt("temp_select_value",globalTable);
    --获取图标元素
    local e = "";
    if #selectInfo > 2 then
        e = document:getElementsByName(selectInfo[3]);
    else
        e = document:getElementsByName("selected");
    end;
    if selectValue ~= "" then
        --两次选择的为同一个值时，清空赋值
        if selectInfo[2] == selectValue then
            e[tonumber(index)]:setStyleByName("display","none");
            --将当前项标记为上一次选择
            globalTable["temp_select_value"] = "";
            --返回空值
            return "";
        else
            for i=1,#e do
                if i == tonumber(index) then
                    --勾选当前项
                    e[tonumber(i)]:setStyleByName("display","block");
                else
                    --取消其他选择
                    e[tonumber(i)]:setStyleByName("display","none");
                end;
            end;
            --缓存当前选择的值
            globalTable["temp_select_value"] = selectInfo[2];
            --返回当前选项值
            return selectInfo;
        end;
    else
        --勾选当前项
        e[tonumber(index)]:setStyleByName("display","block");
        --缓存当前选择的值
        globalTable["temp_select_value"] = selectInfo[2];
        --返回当前选项值
        return selectInfo;
    end;
end;

function lua_bill.getZdsy(index,arg)
    local selectInfo = lua_bill.getSelectValue(index,arg);
    if selectInfo ~= "" then
        globalTable["bxd"].zdsybm = selectInfo[1];
        globalTable["bxd"].zdsy = selectInfo[2];
        changeProperty("zdsy","value",selectInfo[2]);
    else
        globalTable["bxd"].zdsybm = "";
        globalTable["bxd"].zdsy = "";
        changeProperty("zdsy","value","请选择");
    end;
end;

function lua_bill.getJddx(index,arg)
    local selectInfo = lua_bill.getSelectValue(index,arg);
    if selectInfo ~= "" then
        globalTable["bxd"].jddxbm = selectInfo[1];
        globalTable["bxd"].jddx = selectInfo[2];
        changeProperty("jddx","value",selectInfo[2]);
    else
        globalTable["bxd"].jddxbm = "";
        globalTable["bxd"].jddx = "";
        changeProperty("jddx","value","请选择");
    end;
end;

function lua_bill.countRJXF()
    local bxje = formatNull(getValue("bxje"),0);
    local zdjsje = formatNull(getValue("zdjsje"),0);
    local khrs = formatNull(getValue("khrs"),0);
    local ptrs = formatNull(getValue("ptrs"),0);
    local rjxf = 0;
    if (tonumber(bxje)+tonumber(zdjsje)) > 0 and (tonumber(ptrs) + tonumber(khrs)) > 0 then
        --计算人均消费金额（总金额/总人数）
        rjxf = (tonumber(bxje)+tonumber(zdjsje)) / (tonumber(ptrs) + tonumber(khrs));
        rjxf = formatMoney(rjxf);
        changeProperty("rjxf","value",rjxf);
    else
        changeProperty("rjxf","value","0.00");
    end;
end;

--单据配置查询
function lua_bill.query_bill_config(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        ReqParams["ReqAddr"] = "billConfig/queryConfigApp";
        ReqParams["ReqUrlExplain"] = "单据配置查询";
        ReqParams["BusinessCall"] = lua_bill.query_bill_config;
        local queryBillConfigParams = {
            billType = ReqParams["billType"],
            pageType = ReqParams["pageType"],
            orgFlag = ReqParams["orgFlag"]
        };
        ReqParams["BusinessParams"] = table2json(queryBillConfigParams);
        lua_jjbx.common_req(ReqParams);
    else
        local responseBody = json2table(ResParams["responseBody"]);
        if responseBody["errorNo"] == "000000" then
            local list = vt("list",responseBody);
            --请求成功执行回调
            local ResCallFunc = vt("ResCallFunc",ResParams);
            if ResCallFunc ~= "" then
                lua_system.do_function(ResCallFunc,list);
            else
                jjbx_utils_reloadPageElement(list);
            end;
        else
            alert(responseBody["errorMsg"]);
        end;
    end;
end;

--根据单据号查询已关联的登记单
function lua_bill.getRegistrationListByBill(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams,{});
        ReqParams["ReqAddr"] = "busibillRegistration/getRegistrationListByBill";
        ReqParams["ReqUrlExplain"] = "根据单据号查询已关联的登记单";
        ReqParams["BusinessCall"] = lua_bill.getRegistrationListByBill;
        globalTable["jjdj_billNo"] = ReqParams["djh"];
        local BusinessParams = {
            djh = ReqParams["djh"]
        };
        ReqParams["BusinessParams"] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    else
        close_loading();
        local add_menu_list = vt("addMenuList",globalTable,{});
        globalTable["addMenuList"] = nil;
        local res = json2table(ResParams["responseBody"]);
        if res["errorNo"] == "000000" then
            local registrationList = vt("registrationList",res);
            if #registrationList > 0 then
                local t = {
                    menu_name="交接登记",
                    menu_click="lua_page.top_right_menu_router('jjdj')",
                    menu_icon="menu_bar_edit.png"
                };
                table.insert(add_menu_list,t);
            end;
        end;
        --渲染单据右侧头部菜单页面
        lua_page.render_bill_top_right_menu(add_menu_list);
    end;
end;

--跳转交接登记单列表
function lua_bill.to_jjdj_list()
    invoke_page("jjbx_process_bill/xhtml/process_bill_jjdj_list.xhtml",page_callback,{});
end;

--发票查验重新提交
function lua_bill.reSubmit_agreeBill(index)
    if index == 1 then
        VERIFY_UN_CHECKED = "0";
        local reSubmitAgreeBillArg = vt("reSubmit_agreeBill_arg",globalTable);
        globalTable["reSubmit_agreeBill_arg"] = nil;
        local callBackFun = vt("callBackFun",reSubmitAgreeBillArg);
        if callBackFun ~= "" then
            local callBackArg = vt("callBackArg",reSubmitAgreeBillArg);
            lua_system.do_function(callBackFun,callBackArg);
        else
            debug_alert("回调方法未定义");
        end;
    end;
end;