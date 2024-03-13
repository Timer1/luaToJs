--[[极简报销项目中用到的函数]]

lua_jjbx = {};

--[[初始化极简报销]]
function lua_jjbx.init()
    --初始化发票类型列表
    systemTable["invoiceTypeList"] = lua_system.select_widget_parent_data(C_invoiceTypeList);

    --登录参数
    local LoadLoginArg = {};

    --获取客户端注册任务
    local ClientRegisterMissionArg = get_db_value("ClientRegisterMissionArg");
    if ClientRegisterMissionArg ~= "" then
        --通用日志记录注册
        local CommonLogRegisterArg = {
            LogExplain="极简报销系统打开时候，已经被注册的客户端任务",
            LogInfo=ClientRegisterMissionArg
        };
        lua_jjbx.common_log_register("",CommonLogRegisterArg);

        local missionArg = lua_format.url_decode(ClientRegisterMissionArg);
        local ArgObj = json2table(missionArg);

        --[[debug_alert(
            "初始化极简报销，获取客户端注册任务参数 :\n"..missionArg.."\n"..
            "ArgObj :"..foreach_arg2print(ArgObj)..
            ""
        );]]

        local MissionType = vt("MissionType",ArgObj);
        local JJBXAppLoginToken = vt("JJBXAppLoginToken",ArgObj);
        if MissionType=="ToBudgetPageOpenByOtherApp" and JJBXAppLoginToken~="" then
            debug_alert("其他APP通过PC认证后，使用token登录极简报销并进行后续操作"..foreach_arg2print(ArgObj));
            LoadLoginArg["JJBXAppLoginToken"] = JJBXAppLoginToken;
        end;
    end;
    --加载登录
    lua_login.load_login(LoadLoginArg);
end;

--[[登录后参数初始化]]
function lua_jjbx.arg_init_after_login(resParams)
    --记录初始化标志
    companyTable["ArgInitAfterLoginFlag"] = "true";

    --系统参数查询
    if formatNull(resParams) == "" then
        --debug_alert("登录后参数初始化-请求");
        invoke_trancode_donot_checkRepeat(
            "jjbx_service",
            "app_service",
            {
                TranCode="QrySysArg"
            },
            lua_jjbx.arg_init_after_login,
            {},
            all_callback,
            {CloseLoading="false"}
        );
    else
        local res = json2table(resParams["responseBody"]);
        --debug_alert("登录后参数初始化-响应\n"..foreach_arg2print(res));

        --储存极简大事记h5地址
        local JJBXAnnualEventUrl = vt("JJBXAnnualEventUrl",res);
        globalTable["JJBXAnnualEventUrl"] = JJBXAnnualEventUrl;

        --登录后参数初始化完成回调
        lua_jjbx.arg_init_after_login_call();
    end;
end;

--[[登录后参数初始化完成回调]]
function lua_jjbx.arg_init_after_login_call()
    --关闭loading
    close_loading();
end;

--[[结算明细检测当前字段审批人是否可以编辑]]
function jjbx_checkTagEnableToApprover_js(elementName)
    local pageConfig = globalTable["pageConfig_jsmx"];
    local fieldName = "";
    local enableFlag = "false";
    for key,value in pairs(pageConfig) do
        fieldName = value["fieldAppId"];
        fieldName = splitUtils(fieldName,"_")[1];
        if fieldName == elementName and value["modelType"] == "3" and value["editable"] == "1" then
            enableFlag = "true";
            break
        end;
    end;
    return enableFlag;
end;

function changeEditStateByPageConfigToJsmx(type)
    local pageConfig = globalTable["pageConfig_jsmx"];
    for i=1,#pageConfig do
        if pageConfig[i]["modelType"] == "3" then
            local fieldAppId = pageConfig[i]["fieldAppId"];
            local fieldName = string.gsub(fieldAppId,"_div","");
            if pageConfig[i]["editable"] == "0" then
                changeProperty(fieldName,"enable","false");
                if fieldName == "jsfs" then
                    changeStyle("jsfs_img","display","none");
                    changeStyle("jsfs","right","13px");
                end;
                if fieldName == "skr" then
                    if type == "xjzf" then
                        changeProperty("xjzf_skr","enable","false");
                        changeStyle("xjzf_skr_img","display","none");
                    else
                        changeStyle("skr_img","display","none");
                        changeStyle("skr","right","13px");
                    end;
                end;
                if fieldName == "khyh" then
                    changeStyle("khyh_img","display","none");
                    changeStyle("khyh","right","13px");
                end;
                if fieldName == "je" then
                    if type == "zxzf" then
                        changeProperty("zfje","enable","false");
                    elseif type == "zjgc" then
                        changeProperty("zjgc_zfje","enable","false");
                        changeStyle("zjgc_img","display","none");
                    elseif type == "xjzf" then
                        changeProperty("xjzf_zfje","enable","false");
                    elseif type == "gyf" then
                        changeProperty("gyf_zfje","enable","false");
                    elseif type == "cjk" then
                        changeProperty("cjk_zfje","enable","false");
                        changeStyle("cjk_img","display","none");
                    end;
                end;
            end;
        end;
    end;
end;

--[[根据后台返回的配置来加载页面元素]]
function jjbx_utils_reloadPageElement(pageConfig, modelType)
    local debug_alert_msg = "根据配置加载：\n";

    --指定查看的内容
    local modelType = formatNull(modelType);
    local pageConfig = formatNull(pageConfig,{});
    for key,value in pairs(pageConfig) do
        --是否遍历
        local DoLoop = "true";
        if modelType ~= "" then
            --外层指定查看内容层级时，只有匹配才进行内容遍历
            if value["modelType"] ~= modelType then
                DoLoop = "false";
            end;
        end;

        if value["modelType"] == "2" and value["fieldName"] == "zdy2" then
            globalTable["zdy2Title"] = value["fieldDispName"];
            globalTable["zdy2Display"] = value["fieldVisible"];
        end;

        if DoLoop == "true" then
            local fieldAppId = formatNull(value["fieldAppId"]);
            --信息1里已经统一将_div删除，信息2信息3信息4还需要复用原有逻辑
            fieldAppId = string.gsub(fieldAppId,"_div","");
            local divEleName = fieldAppId.."_div";
            --默认显示
            local displayFlag = formatNull(value["fieldVisible"],"1");
            --默认非必输
            local requiredFlag = formatNull(value["fieldRequired"],"0");
            --文字显示默认为空
            local labelValue = formatNull(value["fieldDispName"]);
            --div对象
            local devEleObj = formatNull(document:getElementsByName(divEleName)[1]);
            --label对象
            local elementName = formatNull(splitUtils(divEleName,"_")[1]);
            local labelEleName = elementName.."_title";
            --*号对象
            local RequiredEleName = elementName.."_required";
            local RequiredEleValue = "";

            if devEleObj ~= "" and elementName ~= "" then
                --控制div是否显示，并且更新label文字
                if displayFlag == "1" then
                    --显示div
                    show_ele(divEleName);
                    --更新文字
                    changeProperty(labelEleName,"value",labelValue);
                    --必输项添加星号
                    if requiredFlag == "1" then
                        RequiredEleValue = "*";
                    else
                        RequiredEleValue = "";
                    end;
                    --更新必输
                    changeProperty(RequiredEleName,"value",RequiredEleValue);
                else
                    hide_ele(divEleName);
                    --隐藏表单还是需要更新必输
                    changeProperty(RequiredEleName,"value","");
                end;
            end;

            debug_alert_msg = debug_alert_msg..
                "fieldAppId:"..fieldAppId.."\n"..
                "displayFlag:"..displayFlag.."\n"..
                "divEleName:"..divEleName.."\n"..
                "requiredFlag:"..requiredFlag.."\n"..
                "RequiredEleName:"..RequiredEleName.."\n"..
                "labelEleName:"..labelEleName.."\n"..
                "labelValue:"..labelValue.."\n"..
                "\n";
        end;
    end;
    --弹出调试信息
    --debug_alert(debug_alert_msg);
end;

--[[业务错误处理]]
function jjbx_show_business_err(errcode, errmsg)
    close_loading();
    if errcode ~= "SKIP_ErrorNo" then
        alert(errmsg);
    end;
end;

--[[结算页面决定跳转到哪个页面]]
function to_jiesuan(responseBodyBill,jsdData)
    history:clear(1);
    local params ={
        responseBodyBill=responseBodyBill,
        JumpStyle="none",
        AddPage="true",
        JsdData=jsdData
    };
    if string.find(globalTable["jsd"].jsfsbm,"FIN%-011%-1") then
        --现金支付
        invoke_page_noloading_checkRepeat("jjbx_process_bill/xhtml/process_bill_jiesuan_xjzf.xhtml",page_callback,params);
    elseif string.find(globalTable["jsd"].jsfsbm,"FIN%-011%-203") then
        --在建工程转出
        globalTable["jsd"].zfje = "";
        params["CloseLoading"] = "false";
        invoke_page("jjbx_process_bill/xhtml/process_bill_jiesuan_zjgc.xhtml",page_callback,params);
    elseif string.find(globalTable["jsd"].jsfsbm,"FIN%-011%-202") then
        --冲借款
        globalTable["jsd"].zfje = "";
        params["CloseLoading"] = "false";
        invoke_page("jjbx_process_bill/xhtml/process_bill_jiesuan_cjk.xhtml",page_callback,params);
    elseif string.find(globalTable["jsd"].jsfsbm,"FIN%-011%-0") then
        --在线支付
        invoke_page_noloading_checkRepeat("jjbx_process_bill/xhtml/process_bill_jiesuan_zxzf.xhtml",page_callback,params);
    elseif string.find(globalTable["jsfsbmDetail"],"FIN%-011%-201") then
        --挂应付
        invoke_page_noloading_checkRepeat("jjbx_process_bill/xhtml/process_bill_jiesuan_gyf.xhtml",page_callback,params);
    else
        invoke_page_noloading_checkRepeat("jjbx_process_bill/xhtml/process_bill_jiesuan_other.xhtml",page_callback,params);
    end;
end;

--[[新建/编辑结算时，决定跳转到哪个页面（区别是是否压栈）]]
function to_jiesuan2(responseBodyBill,jsdData)
    --新增结算的话，跳转到选项页；否则，跳转到各自页面
    if globalTable["ifEditBillP"] == "false" then
        invoke_page("jjbx_process_bill/xhtml/process_bill_jiesuan_zxzf.xhtml",page_callback,{responseBodyBill=responseBodyBill,JsdData=jsdData});
    else
        if string.find(globalTable["jsd"].jsfsbm,"FIN%-011%-1") then
            --现金支付
            invoke_page("jjbx_process_bill/xhtml/process_bill_jiesuan_xjzf.xhtml",page_callback,{responseBodyBill=responseBodyBill,JsdData=jsdData});
        elseif string.find(globalTable["jsd"].jsfsbm,"FIN%-011%-203") then
            --在建工程转出
            invoke_page("jjbx_process_bill/xhtml/process_bill_jiesuan_zjgc.xhtml",page_callback,{AddPage="true",CloseLoading="false",responseBodyBill=responseBodyBill,JsdData=jsdData});
        elseif string.find(globalTable["jsd"].jsfsbm,"FIN%-011%-202") then
            --冲借款
            invoke_page("jjbx_process_bill/xhtml/process_bill_jiesuan_cjk.xhtml",page_callback,{AddPage="true",CloseLoading="false",responseBodyBill=responseBodyBill,JsdData=jsdData});
        elseif string.find(globalTable["jsd"].jsfsbm,"FIN%-011%-0") then
            --在线支付
            invoke_page("jjbx_process_bill/xhtml/process_bill_jiesuan_zxzf.xhtml",page_callback,{responseBodyBill=responseBodyBill,JsdData=jsdData});
        elseif string.find(formatNull(globalTable["jsfsbmDetail"],""),"FIN%-011%-201") then
            --挂应付
            invoke_page("jjbx_process_bill/xhtml/process_bill_jiesuan_gyf.xhtml",page_callback,{responseBodyBill=responseBodyBill,JsdData=jsdData});
        else
            invoke_page("jjbx_process_bill/xhtml/process_bill_jiesuan_other.xhtml",page_callback,{responseBodyBill=responseBodyBill,JsdData=jsdData});
        end;
    end;
end;

--[[跳转结算查看页面，冲借款的结算页面要单独跳转]]
function to_jiesuan_look(pageConfig,responseBodyBill,jsdData)
    local fileCode = "";
    globalTable["pageConfig_jsmx"] = pageConfig;
    local pageConfig = formatNull(pageConfig,globalTable["pageConfig"]);
    globalTable["pageConfig"] = formatNull(globalTable["pageConfig"],pageConfig);
    for key,value in pairs(pageConfig) do
        if value["fieldAppId"] == "zdy2_div" then
            fileCode = value["fileCode"];
            break
        end;
    end;
    globalTable["fileCode"] = fileCode;
    invoke_trancode_donot_checkRepeat(
        "jjbx_process_query",
        "process_bill",
        {
            BusinessType="bill_index",
            TranCode="InitAddJieSuanInfo",
            billType=globalTable["receiptsType"],
            fileCode=fileCode,
            ifEditBillP=globalTable["ifEditBillP"],
            jsfsbm=globalTable["jsd"].jsfsbm,
            pkCorp=globalTable["pkCorp"]
        },
        initAddJieSuanInfoCallBack,
        {
            flag="look",
            responseBodyBill=responseBodyBill,
            jsdData=jsdData
        }
    );
end;

--[[添加/编辑结算回调]]
function initAddJieSuanInfoCallBack(params)
    local responseBody = json2table(params["responseBody"]);
    local responseBodyBill = params["responseBodyBill"];
    if #responseBody["billDictQueryList"] < 1 then
        alert("无可选择的结算方式");
        return;
    end;
    
    local djlxbm = vt("receiptsType",globalTable);
    local bill = "";
    if #responseBodyBill["bill"] > 0 then
        bill = responseBodyBill["bill"][1];
    else
        bill = responseBodyBill["bill"];
    end;
    djlxbm = vt("djlxbm",bill);
    
    if vt("ifApproverEdit",globalTable) == "true" and djlxbm == billTypeList_utils.bzd then
        --报账单审批人编辑单独查询计算方式
    else
        globalTable["jsfsList"] = responseBody["billDictQueryList"];
    end;
    globalTable["zdyList2"] = responseBody["zdyList"];
    if globalTable["ifEditBillP"] == "false" then
        globalTable["jsd"].billPid = responseBody["billPId"];
    else
    end;

    globalTable["jsfsbmDetail"] = formatNull(responseBody["jsfsbm2"]["supContent"],"");
    
    globalTable["gyf_zfje"] = "";
    globalTable["cjk_zfje"] = "请选择";
    globalTable["zjgc_zfje"] = "请选择";

    local jsdData = params["jsdData"];
    if params["flag"] == "look" then
        if string.find(globalTable["jsd"].jsfsbm,"FIN%-011%-202") then
            --冲借款
            invoke_page("jjbx_process_bill/xhtml/process_bill_jiesuan_cjk_look.xhtml",page_callback,{AddPage="true",CloseLoading="false",responseBodyBill=responseBodyBill,JsdData=jsdData});
        elseif string.find(globalTable["jsd"].jsfsbm,"FIN%-011%-203") then
            --在建工程转出
            invoke_page("jjbx_process_bill/xhtml/process_bill_jiesuan_zjgc_look.xhtml",page_callback,{AddPage="true",CloseLoading="false",responseBodyBill=responseBodyBill,JsdData=jsdData});
        else
            invoke_page("jjbx_process_bill/xhtml/process_bill_jiesuan_look.xhtml",page_callback,{responseBodyBill=responseBodyBill,JsdData=jsdData});
        end;
    else
        to_jiesuan2(responseBodyBill,jsdData);
    end;
end;

--[[新建/编辑结算单]]
function initJieSuan(pageConfig,responseBodyBill,jsdData)
    local fileCode = "";
    globalTable["pageConfig_jsmx"] = pageConfig;
    local pageConfig = formatNull(pageConfig,globalTable["pageConfig"]);
    globalTable["pageConfig"] = formatNull(globalTable["pageConfig"],pageConfig);
    for key,value in pairs(pageConfig) do
        if value["fieldAppId"] == "zdy2_div" then
            fileCode = value["fileCode"];
            break
        end;
    end;
    globalTable["fileCode"] = fileCode;
    local bill = vt("bill",responseBodyBill);
    globalTable["billSource"] = responseBodyBill["bill"][1]["billSource"];

    --新增结算单或者结算方式选项内容不全时，先进行查询操作
    if globalTable["ifEditBillP"] == "false" or globalTable["jsfsbmDetail"] == nil then
        local editFlag = "";
        if jsdData["sy"] == "往来确认" then
            editFlag = "look";
        else
            editFlag = "edit"
        end;
        invoke_trancode_donot_checkRepeat(
            "jjbx_process_query",
            "process_bill",
            {
                BusinessType="bill_index",
                TranCode="InitAddJieSuanInfo",
                billType=globalTable["receiptsType"],
                fileCode=fileCode,
                ifEditBillP=globalTable["ifEditBillP"],
                jsfsbm=globalTable["jsd"].jsfsbm,
                pkCorp=globalTable["pkCorp"]
            },
            initAddJieSuanInfoCallBack,
            {
                flag=editFlag,
                responseBodyBill=responseBodyBill,
                jsdData=jsdData
            }
        );
    else
        -- 往来确认结算不可编辑
        if jsdData["sy"] == "往来确认" then
            if string.find(jsdData.jsfsbm,"FIN%-011%-202") then
                --冲借款
                invoke_page("jjbx_process_bill/xhtml/process_bill_jiesuan_cjk_look.xhtml",page_callback,{AddPage="true",CloseLoading="false",responseBodyBill=responseBodyBill,JsdData=jsdData});
            elseif string.find(jsdData.jsfsbm,"FIN%-011%-203") then
                --在建工程转出
                invoke_page("jjbx_process_bill/xhtml/process_bill_jiesuan_zjgc_look.xhtml",page_callback,{AddPage="true",CloseLoading="false",responseBodyBill=responseBodyBill,JsdData=jsdData});
            else
                invoke_page("jjbx_process_bill/xhtml/process_bill_jiesuan_look.xhtml",page_callback,{responseBodyBill=responseBodyBill,JsdData=jsdData});
            end;
        else
            to_jiesuan2(responseBodyBill,jsdData);
        end;
    end;
end;

--[[选择结算方式]]
function jjbx_getJSFSValue(params)
    if formatNull(params,"") == "" then
        alert("请选择结算方式");
        return;
    end;
    globalTable["jsfsbmDetail"] = params;
    --jjbx_hideContent();
    jjbx_utils_hideContent();
    local codeAndName = splitUtils(params,",");
    local jsfstree = "";
    local jsfsbm = "";
    local jsfs = "";
    local listLen = #codeAndName;
    for i=1,listLen do
        if i ~= listLen then
            if jsfstree == "" then
                jsfstree = codeAndName[i];
            else
                jsfstree = jsfstree..","..codeAndName[i];
            end;
            if i == listLen - 1 then
                jsfsbm = codeAndName[i];
            end;
        else
            jsfs = codeAndName[i];
        end;
    end;
    globalTable["jsd"].jsfs = jsfs;
    globalTable["jsd"].jsfsbm = jsfsbm;
    getContent();
    local CurrentPageInfo = lua_page.current_page_info();
    local responseBody = vt("responseBodyBill",CurrentPageInfo);
    local jsdData = vt("jsdData",CurrentPageInfo);
    to_jiesuan(responseBody,jsdData);
end;

--[[判断单据返回的流水类型是否存在已定义的类型列表里]]
function orderTypeIsIncludes(orderTypeList,orderType)
    --流水类型
    local orderTypeList = orderTypeList;
    local includFlag = "fasle";
    for i=1,#orderTypeList do
        if orderType == orderTypeList[i] then
            includFlag = "true";
            break
        end;
    end;
    return includFlag;
end;

--[[提交、批准right；驳回close；审批中point；待审批more；流程结束end；流程强制结束slash；单据作废void]]
function jjbx_formatSPLC(splcStatus,opinion)
    if splcStatus == "right" then
        if opinion == "提交申请" then
            return "已提交";
        else
            return "已批准";
        end;
    elseif splcStatus == "close" then
        return "已驳回";
    elseif splcStatus == "point" then
        if opinion == "待提交" then
            return "待提交";
        elseif opinion == "待回复" then
            return "待回复";
        else
            return "审批中";
        end;
    elseif splcStatus == "more" then
        return "待审批";
    elseif splcStatus == "end" then
        return "流程结束";
    elseif splcStatus == "slash" then
        return "流程强制结束";
    elseif splcStatus == "void" then
        return "单据作废";
    elseif splcStatus == "revoke" then
        return "已撤回";
    elseif splcStatus == "turn" then
        return "已转办";
    elseif splcStatus == "reply" then
        return "已回复";
    elseif splcStatus == "turnBack" then
        return "撤回转办";
    elseif splcStatus == "handover" then
        return "移交";
    else
        return "未定义";
    end;
end;

--[[检测当前字段审批人是否可以编辑]]
function jjbx_utils_checkTagEnableToApprover(tagName,config)
    local pageConfig = formatNull(formatNull(config,globalTable["pageConfig"]),{});
    local fieldName = "";
    local enableFlag = "false";
    for key,value in pairs(pageConfig) do
        fieldName = value["fieldAppId"];
        fieldName = splitUtils(fieldName,"_")[1];
        if fieldName == tagName then
            if formatNull(value["editable"],"") ~= "1" then
                changeProperty(fieldName,"enable","false");
            else
                enableFlag = "true";
                changeProperty(fieldName,"enable","true");
            end;
            break
        end;
    end;
    if vt("ifApproverEdit",globalTable) == "true" then
        return enableFlag;
    else
        --制单人默认可编辑
        return "true";
    end;
end;

--[[审批流程的右侧文字自适应]]
function setoperate_text_labelTimeRight()
    local elements = document:getElementsByName("operate_stop_time_label");
    local elementValue = elements[1]:getPropertyByName("value");
    if elementValue ~= "" then
        local valueLen = ryt:getLengthByStr(elementValue);
        local elementWidth = tonumber(valueLen) * 8;
        elements[1]:setStyleByName("width",tostring(elementWidth).."px");
        local selfElment = document:getElementsByName("operate_text_label");
        selfElment[1]:setStyleByName("right",tostring(elementWidth).."px");
        page_reload();
    end;
end;

--[[发送验证码成功的提示]]
function show_SMS_alertMsg(mobileNo)
    alert("验证码已发送至手机尾号"..string.sub(mobileNo,string.len(mobileNo)-3,string.len(mobileNo)));
end;

--[[商旅展示发起预订菜单]]
function apply_order(applicationNo)
    --预订渠道展示
    --0 -无参数/ 1- 携程商旅 /2 -同程商旅 /3 -阿里
    local TravelChannelFlag = globalTable["TravelChannelFlag"];
    if #TravelChannelFlag > 0 then
        --跳转选择渠道页面（公务预订）
        invoke_page("jjbx_travel_service/xhtml/travel_service_channel.xhtml",page_callback,{CloseLoading="fasle",flag="0",billNo=applicationNo});
    else
        --未查询到已开通的渠道
        alert(ApplyTravelChannelCheckMsg);
    end;
end;

--[[商旅预订菜单点击]]
function apply_menu_click(reserve_type)
    init_travel_reserve_h5_page(reserve_type);
end;

--[[商旅初始化预订链接]]
function init_travel_reserve_h5_page(reserve_type)
    --涉嫌电信诈骗提示
    local UserRiskCheckMsg = vt("UserRiskCheckMsg",globalTable);
    if UserRiskCheckMsg ~= "" then
        alert(UserRiskCheckMsg);
    else
        globalTable["webView_reserve_type"] = reserve_type;
        --预订渠道展示
        --1- 携程商旅 /2 -同程商旅 /3 -阿里
        local TravelChannelFlag = globalTable["TravelChannelFlag"];
        if reserve_type == "xiecheng" then
            --携程商旅
            local flag = "false";
            for i=1,#TravelChannelFlag do
                if tonumber(TravelChannelFlag[i]) == 1 then
                    flag = "true";
                    break
                end;
            end;
            if flag == "true" then
                globalTable["webview_back2jjbx"] = "返回极简";
                globalTable["isShowBackBut"] = "false";
                invoke_trancode("jjbx_page","webview_page",{TranCode="InitXCReservelUrl",pkCorp=globalTable["selectOrgList"][1]["pkCorp"]},to_reserve_h5_page,{});
            else
                alert(ApplyTravelChannelXieChengCheckMsg);
            end;
        elseif reserve_type == "tongcheng" then
            --同程商旅
            local flag = "false";
            for i=1,#TravelChannelFlag do
                if tonumber(TravelChannelFlag[i]) == 2 then
                    flag = "true";
                    break
                end;
            end;
            if flag == "true" then
                globalTable["isShowBackBut"] = "true";
                invoke_trancode("jjbx_page","webview_page",{TranCode="InitTCReservelUrl",tripappno=globalTable["select_tripNo"]},to_reserve_h5_page,{});
            else
                alert(ApplyTravelChannelTongchengCheckMsg);
            end;
        elseif reserve_type == "aLi" then
            local flag = "false";
            for i=1,#TravelChannelFlag do
                if tonumber(TravelChannelFlag[i]) == 3 then
                    flag = "true";
                    break
                end;
            end;
            if flag == "true" then
                --跳转阿里商旅
                invoke_trancode("jjbx_page","webview_page",{TranCode="InitALiReserveUrl",tripappno=globalTable["select_tripNo"]},to_reserve_h5_page,{});
            else
                alert(ApplyTravelChannelALiCheckMsg);
            end;
        else
            alert("不支持的预订渠道。")
        end;
    end;
end;

--[[商旅前往预订页面]]
function to_reserve_h5_page(params)
    local jsonData = params["responseBody"];
    local responseBody = json2table(params["responseBody"]);
    if responseBody["errorNo"] == "000000" then
        --清空保存的单据号
        globalTable["select_tripNo"] = "";
        globalTable["toReserveH5ResponseBody"] = responseBody;
        if vt("promptFlag",responseBody) == "0" then
            local labelStyleCss = "style='font-size: 14px;'";
            local divStyleCss = "style='left: 20px; width: 275px;'";
            lua_format.split_str("",{str=vt("promptInf",responseBody),labelStyleCss=labelStyleCss,divStyleCss=divStyleCss,elementName="alertTextDiv"});
            changeStyle("alert_page","display","block");
            --alertTip("提示",vt("promptInf",responseBody),"不再提示","","知道了","lua_jjbx.to_reserve_h5_page","");
        else
            lua_jjbx.to_reserve_h5_page("","","");
        end;
    else
        jjbx_show_business_err(responseBody["errorNo"],responseBody["errorMsg"]);
    end;
end;

function lua_jjbx.to_reserve_h5_page(sureFlag,checkFlag,responseBody)
    local responseBody = globalTable["toReserveH5ResponseBody"];
    if tonumber(formatNull(checkFlag,"0")) == 1 then
        if globalTable["webView_reserve_type"] == "xiecheng" then
            lua_travel.update_tip_status("",{flag="8",value=responseBody["promptInf"]});
        elseif globalTable["webView_reserve_type"] == "tongcheng" then
            lua_travel.update_tip_status("",{flag="9",value=responseBody["promptInf"]});
        else
            lua_travel.update_tip_status("",{flag="7",value=responseBody["promptInf"]});
        end;
    end;
    globalTable["webview_url"] = formatNull(responseBody["webview_url"]);
    globalTable["webview_page_title"] = formatNull(responseBody["webview_page_title"]);
    globalTable["webview_upBody"] = formatNull(responseBody["webview_upBody"]);
    if globalTable["webview_upBody"] ~= "" then
        globalTable["webview_method"] = "post";
    else
        globalTable["webview_method"] = "";
    end;
    if globalTable["webView_reserve_type"] == "aLi" then
        lua_system.alert_webview(
            {
                title = "阿里商旅",
                visit_url = responseBody["webview_url"],
                close_call_func="",
                back_type = "BACK",
                listen_url = "http://app_h5_callback_url",
                listen_call = "lua_system.webview_h5_callback"
            }
        );
    else
        invoke_page("jjbx_page/xhtml/webview_page.xhtml",page_callback,nil);
    end;
    globalTable["toReserveH5ResponseBody"] = nil;
end;

--[[单据页面路由]]
function bill_page_router(params)
    local params = formatNull(params,"");
    local mealType = "";
    if type(params) == "string" then
        params = lua_format.table_arg_unpack(params);
        --用以区分美团和饿了么（0：饿了么、1：美团）
        mealType = vt("mealType",params);
        --非请求封装的参数，用完后理解清空（判断单据状态会用到这个入参）
        params = "";
    end;
    --默认进入编辑页面
    local BillPageStyle = "EditPage";
    local iSRejectBill = "";
    --清空申请部门缓存
    globalTable["zdrbmInfo"] = nil;
    
    if params ~= "" then
        local responseBody = json2table(params["responseBody"]);
        --单据列表跳转过来的，如果mealChannel不为空，这取mealChannel为用餐申请单类型（0：饿了么、1：美团）
        if vt("mealChannel",params) ~= "" then
            mealType = vt("mealChannel",params);
        end;
        local BillHaveProcessInfo = responseBody["BillHaveProcessInfo"];
        --根据结果判断是否被驳回单据
        globalTable["BillPageStyle"] = BillPageStyle;
        if responseBody["status"] == "1" and BillHaveProcessInfo == "true" then
            --当单据状态为待提交且有流转信息时，认为是被驳回状态，进入详情页面
            BillPageStyle = "DetailPage";
            globalTable["iSRejectBill"] = "true";
            iSRejectBill = "true";
        elseif responseBody["status"] == "1" then
            BillPageStyle = "EditPage";
            --重新发起申请的单据，重置审批人状态
            globalTable["ifApproverEdit"] = nil;
            globalTable["iSRejectBill"] = "";
        else
            BillPageStyle = "DetailPage";
            globalTable["iSRejectBill"] = "";
        end;
    end;

    --[[debug_alert(
        "默认页面类型:"..BillPageStyle.."\n"..
        "单据类型:"..globalTable['billTypeCode'].."\n"..
        "单据状态:"..globalTable['billState'].."\n"..
        "配置的单据类型:"..billTypeList_utils.sxsq.."\n"..
        "是否被驳回单据:"..iSRejectBill.."\n"..
        "查询的页面类型:"..BillPageStyle;
    );]]

    local billnumber = globalTable["billCode"];
    local billState = globalTable["billState"];
    local PageUrl = "";
    local PageCallArg = {CloseLoading="false"};

    if globalTable["billTypeCode"] == billTypeList_utils.clbx then
        --差旅报销单
        if BillPageStyle == "EditPage" then
            PageUrl = "jjbx_proccess_travel_process_bill/xhtml/travel_process_bill_index.xhtml";
        else
            PageUrl = "jjbx_proccess_travel_process_bill/xhtml/travel_process_bill_applyDetail.xhtml";
        end;
    elseif globalTable["billTypeCode"] == billTypeList_utils.sxsq then
        --事项申请单
        if BillPageStyle == "EditPage" then
            PageUrl = "jjbx_proccess_matter_apply_bill/xhtml/matter_apply_bill_index.xhtml";
        else
            PageUrl = "jjbx_proccess_matter_apply_bill/xhtml/matter_apply_bill_applyDetail.xhtml";
        end;
    elseif globalTable["billTypeCode"] == billTypeList_utils.bzd then
        --报账单
        globalTable["billNo"] = billnumber;
        globalTable["billState"] = billState;
        if BillPageStyle == "EditPage" then
            PageUrl = "jjbx_proccess_reimbursement_bill/xhtml/reimbursement_bill_index.xhtml";
        else
            PageCallArg["reimbursement_billNo"] = billnumber;
            PageUrl = "jjbx_proccess_reimbursement_bill/xhtml/reimbursement_bill_detail.xhtml";
        end;
    elseif globalTable["billTypeCode"] == billTypeList_utils.jk then
        --借垫款单
        globalTable["JKDbillNo"] = billnumber;
        if BillPageStyle == "EditPage" then
            PageUrl = "jjbx_process_borrow_bill/xhtml/borrow_bill_edit.xhtml";
        else
            PageUrl = "jjbx_process_borrow_bill/xhtml/borrow_bill_applyDetail.xhtml";
        end;
    elseif globalTable["billTypeCode"] == billTypeList_utils.hk then
        --还款单
        globalTable["hkBillNo"] = billnumber;
        if BillPageStyle == "EditPage" then
            PageUrl = "jjbx_proccess_repayment_bill/xhtml/repayment_bill_index.xhtml";
        else
            PageUrl = "jjbx_proccess_repayment_bill/xhtml/repayment_bill_applyDetail.xhtml";
        end;
    elseif globalTable["billTypeCode"] == billTypeList_utils.ycsq then
        --用车出行
        globalTable["carService_billNo"] = billnumber;
        globalTable["shenpi"] = "true";
        if BillPageStyle == "EditPage" then
            PageUrl = "jjbx_car_service/xhtml/car_service_travelApply_edit.xhtml";
        else
            PageUrl = "jjbx_car_service/xhtml/car_service_detail.xhtml";
        end;
    elseif globalTable["billTypeCode"] == billTypeList_utils.eatServer then
        --用餐申请
        globalTable["eatServer_djh"] = billnumber;
        globalTable["shenpi"] = "true";
        if BillPageStyle == "EditPage" then
            if mealType == "1" then
                PageCallArg["billNo"] = billnumber;
                PageUrl = "jjbx_eat_service/apply.xhtml";
            else
                PageUrl = "jjbx_eat_service/xhtml/eatServer_limitApply_edit.xhtml";
            end;
        else
            PageUrl = "jjbx_eat_service/apply_detail.xhtml";
        end;
    elseif globalTable["billTypeCode"] == billTypeList_utils.yfkzf then
        --应付款支付单
        globalTable["YFKZFbillNo"] = billnumber;
        globalTable["YFKZFbillNo2"] = billnumber;
        if BillPageStyle == "EditPage" then
            PageUrl = "jjbx_proccess_pay_bill/xhtml/pay_bill_index.xhtml";
        else
            PageUrl = "jjbx_proccess_pay_bill/xhtml/pay_bill_detail.xhtml";
        end;
    elseif globalTable["billTypeCode"] == billTypeList_utils.xcbx then
        --行程报销单
        globalTable["ifNewXCBX"] = "false";
        if BillPageStyle == "EditPage" then
            PageUrl = "jjbx_travel_reimbursement/xhtml/travel_service_reimbursement_submit_process.xhtml";
        else
            PageUrl = "jjbx_travel_reimbursement/xhtml/travel_service_reimbursement_applyDetail.xhtml";
        end;
    elseif globalTable["billTypeCode"] == billTypeList_utils.xcsq then
        --行程申请单
        globalTable["XCSQ_billNo"] = billnumber;
        globalTable["detailNo"] = billnumber;
        --判断是否是第一次进入编辑页面
        globalTable["firstPage"] = "true";
        --[[debug_alert(
            "行程申请单:\n"..
            "XCSQ_billNo:"..globalTable["XCSQ_billNo"].."\n"..
            "detailNo:"..globalTable["detailNo"].."\n"..
            ""
        );]]
        if BillPageStyle == "EditPage" then
            PageUrl = "jjbx_travel_service/xhtml/travel_service_apply_edit.xhtml";
        else
            PageUrl = "jjbx_travel_service/xhtml/travel_service_proccess_bill_detail.xhtml";
        end;
    elseif globalTable["billTypeCode"] == billTypeList_utils.cgsq then
        --采购申请单
        globalTable["purchaseNo"] = billnumber;
        --初始化列表，默认加载一项
        globalTable["categoryList"] = {};
        
        if BillPageStyle == "EditPage" then
            globalTable["onlineShoppingApply_params"] = {purchaseNo="",feeTakerPk="",feeTaker="",feeTakerDept="",feeTakerCode="",feeTakerDeptCode="",purchasecause="",corpName="",totalprice="",purchasetype="对公采购-公司支付",purchasetypecode="A",borrowflag="",unitprice="",purchasenum="",groupprice="",servicetype="",servicetypeCode="",purchasingcategory="",categorycode="",expenditureproject="",expenditureprojectcode="",TranCode="addPurchaseRequistion",saveFlag="save"};
            PageUrl = "jjbx_online_shopping/xhtml/onlineShopping_apply_edit.xhtml";
        else
            globalTable["shenpiFlag"] = 0;
            PageUrl = "jjbx_online_shopping/xhtml/onlineShopping_applyDetail.xhtml";
        end;
    elseif globalTable["billTypeCode"] == billTypeList_utils.cgsq_new then
        if BillPageStyle == "EditPage" then
            --新采购申请单

            --清理采购初始缓存参数
            lua_purchase.reset_onlineShopping_initParams()
            globalTable["onlineShopping_initParams"]["purchaseBillNo"] = billnumber;

            PageUrl = "jjbx_online_shopping/apply.xhtml";
        else
            globalTable["purchaseNo"] = billnumber;
            PageUrl = "jjbx_online_shopping/apply_detail.xhtml";
        end;
    elseif globalTable["billTypeCode"] == billTypeList_utils.sxjs then
        --事项调整单
        PageCallArg["billNo"] = billnumber;
        if BillPageStyle == "EditPage" then
            PageUrl = "jjbx_process_items_account/xhtml/items_account_index.xhtml";
        else
            PageUrl = "jjbx_process_items_account/xhtml/items_account_detail.xhtml";
        end;
    elseif globalTable["billTypeCode"] == billTypeList_utils.byjsq then
        --备用金申请单
        PageUrl = "jjbx_budget_info/xhtml/sparegold_show.xhtml";
    elseif globalTable["billTypeCode"] == billTypeList_utils.xtnzf then
        --系统内支付单
        PageUrl = "jjbx_budget_info/xhtml/syspayment_show.xhtml";
    elseif globalTable["billTypeCode"] == billTypeList_utils.cbft then
        --成本分摊单
        PageUrl = "jjbx_budget_info/xhtml/costsharing_show.xhtml";
    elseif globalTable["billTypeCode"] == billTypeList_utils.pzdj then
        --凭证单据
        PageUrl = "jjbx_budget_info/xhtml/voucher_show.xhtml";
    elseif globalTable["billTypeCode"] == billTypeList_utils.tyjs then
        --统一结算单
        PageUrl = "jjbx_budget_info/xhtml/settlement_show.xhtml";
    elseif globalTable["billTypeCode"] == billTypeList_utils.yfksq then
        --应付款申请单
        PageUrl = "jjbx_budget_info/xhtml/payApply_show.xhtml";
    elseif globalTable["billTypeCode"] == billTypeList_utils.kkd then
        --扣款单
        PageUrl = "jjbx_budget_info/xhtml/payIn_show.xhtml";
    elseif globalTable["billTypeCode"] == billTypeList_utils.xcsp then
        --薪酬审批单
        PageUrl = "jjbx_budget_info/xhtml/remuneration_show.xhtml";
    elseif globalTable["billTypeCode"] == billTypeList_utils.zybzd then
        --专业报账单
        PageCallArg["billNo"] = billnumber;
        PageUrl = "jjbx_budget_info/xhtml/specialty_reimbursement.xhtml";
    else
        
    end;

    if PageUrl == "" then
        alert("暂无详情");
    else
        invoke_page(PageUrl,page_callback,PageCallArg);
    end;
end;

--跳转单据详情
function jjbx_toBillDetail(billNo)
    local billNo = formatNull(billNo);
    if billNo ~= "" then
        globalTable["billCode"] = billNo;
        local billTypeCode = bill_no2type(billNo);
        globalTable["billTypeCode"] = billTypeCode;
        if billTypeCode == billTypeList_utils.clbx then
            --差旅报销单
            invoke_page("jjbx_proccess_travel_process_bill/xhtml/travel_process_bill_applyDetail.xhtml",page_callback,{CloseLoading="false"});
        elseif billTypeCode == billTypeList_utils.sxsq then
            --事项申请单
            invoke_page("jjbx_proccess_matter_apply_bill/xhtml/matter_apply_bill_applyDetail.xhtml",page_callback,{CloseLoading="false"});
        elseif billTypeCode == billTypeList_utils.bzd then
            --报账单
            globalTable["billNo"] = billNo;
            globalTable["isShowReApplyBtn"] = "false";
            invoke_page("jjbx_proccess_reimbursement_bill/xhtml/reimbursement_bill_detail.xhtml",page_callback,{reimbursement_billNo=billNo});
        elseif billTypeCode == billTypeList_utils.jk then
            --借垫款单
            globalTable["JKDbillNo"] = billNo;
            invoke_page("jjbx_process_borrow_bill/xhtml/borrow_bill_applyDetail.xhtml",page_callback,nil);
        elseif billTypeCode == billTypeList_utils.hk then
            --还款单
            globalTable["hkBillNo"] = billNo;
            invoke_page("jjbx_proccess_repayment_bill/xhtml/repayment_bill_applyDetail.xhtml",page_callback,nil);
        elseif billTypeCode == billTypeList_utils.ycsq then
            --用车出行
            globalTable["carService_billNo"] = billNo;
            globalTable["shenpi"] = "true";
            invoke_page("jjbx_car_service/xhtml/car_service_detail.xhtml",page_callback,nil);
        elseif billTypeCode == billTypeList_utils.eatServer then
            --用餐申请
            globalTable["eatServer_djh"] = billNo;
            globalTable["shenpi"] = "true";
            invoke_page("jjbx_eat_service/apply_detail.xhtml",page_callback,nil);
        elseif billTypeCode == billTypeList_utils.yfkzf then
            --应付款支付单
            globalTable["YFKZFbillNo2"] = billNo;
            invoke_page("jjbx_proccess_pay_bill/xhtml/pay_bill_detail.xhtml",page_callback,nil);
        elseif billTypeCode == billTypeList_utils.xcbx then
            --行程报销单
            globalTable["ifNewXCBX"] = "false";
            invoke_page("jjbx_travel_reimbursement/xhtml/travel_service_reimbursement_applyDetail.xhtml",page_callback,{CloseLoading="false"});
        elseif billTypeCode == billTypeList_utils.xcsq then
            --行程申请单
            globalTable["XCSQ_billNo"] = billNo;
            globalTable["detailNo"] = billNo;
            lua_travel.to_ts_page("xcsqxq");
        elseif billTypeCode == billTypeList_utils.cgsq then
            --采购申请单
            globalTable["purchaseNo"] = billNo;
            --[[初始化列表，默认加载一项]]
            globalTable["categoryList"] = {};
            globalTable["shenpiFlag"] = 0;
            invoke_page("jjbx_online_shopping/xhtml/onlineShopping_applyDetail.xhtml",page_callback,{CloseLoading="false"});
        elseif billTypeCode == billTypeList_utils.byjsq then
            --备用金申请单
            invoke_page("jjbx_budget_info/xhtml/sparegold_show.xhtml",page_callback,nil);
        elseif billTypeCode == billTypeList_utils.xtnzf then
            --系统内支付单
            invoke_page("jjbx_budget_info/xhtml/syspayment_show.xhtml",page_callback,nil);
        elseif billTypeCode == billTypeList_utils.cbft then
            --成本分摊单
            invoke_page("jjbx_budget_info/xhtml/costsharing_show.xhtml",page_callback,nil);
        elseif billTypeCode == billTypeList_utils.pzdj then
            --凭证单据
            invoke_page("jjbx_budget_info/xhtml/voucher_show.xhtml",page_callback,nil);
        elseif billTypeCode == billTypeList_utils.tyjs then
            --统一结算单
            invoke_page("jjbx_budget_info/xhtml/settlement_show.xhtml",page_callback,nil);
        elseif billTypeCode == billTypeList_utils.yfksq then
            --应付款申请单
            invoke_page("jjbx_budget_info/xhtml/payApply_show.xhtml",page_callback,nil);
        elseif billTypeCode == billTypeList_utils.cgsq_new then
            --新采购申请单
            globalTable["purchaseNo"] = billNo;
            PageUrl = "jjbx_online_shopping/apply_detail.xhtml";
        elseif billTypeCode == billTypeList_utils.xcsp then
            --薪酬审批单
            invoke_page("jjbx_budget_info/xhtml/remuneration_show.xhtml",page_callback,nil);
        else
            debug_alert(billTypeCode);
            alert("暂不支持该单据类型");
        end;
    else
        alert("单据号为空");
    end;
end;
--[[查看发票规则]]
function show_invoice_rule()
    local tb = splitUtils(globalTable["hintInfo"],";");
    local noteInfo = "";
    for i=1,#tb do
        noteInfo = noteInfo..tb[i];
        if #tb > 1 and i ~= #tb then
            noteInfo = noteInfo.."\n";
        end;
    end;
    alert(noteInfo);
end;

--[[更新单据顶部的金额显示]]
function up_bill_tip_amount(amount)
    local amount = tostring(formatMoney(amount));
    local amount = formatNull(amount, "0.00");
    changeProperty("head_tip_content_label","value","单据金额："..amount);
end;

--[[用车类型转换]]
function jjbx_yccx(cartype)
    if cartype == "100" then
        return "专车舒适型";
    elseif cartype == "200" then
        return "专车行政型";
    elseif cartype == "400" then
        return "专车商务型";
    elseif cartype == "600" then
        return "普通快车";
    elseif cartype == "900" then
        return "快车优享";
    else
        return "";
    end;
end;

--[[服务权限设置]]
function lua_jjbx.set_auth(res)
    --debug_alert("服务权限设置"..foreach_arg2print(res));
    --用户类型
    local userType = vt("userType",globalTable);

    --用车是否开启（共享人不通过状态检查，通过场景检查）
    if vt("UseCarJDFlag",res)=="1" or userType=="2" then
        carServiceFlag = "enable";
    else
        carServiceFlag = "disenable";
    end;

    --商旅
    if vt("TravelJDFlag",res) == "1" then
        travelServiceFlag = "enable";
    else
        travelServiceFlag = "disenable";
    end;

    --用餐权限（共享人不通过状态检查，通过场景检查）
    if vt("EatAuthFlag",res)=="1" or userType=="2" then
        eatServiceFlag = "enable";
    else
        eatServiceFlag = "disenable";
    end;
    --公务用餐权限
    if vt("OBEatAuthFlag",res) == "1" then
        OBeatServiceFlag = "enable";
    else
        OBeatServiceFlag = "disenable";
    end;
    --自由用餐权限（共享人不通过状态检查，通过场景检查）
    if vt("OtherEatAuthFlag",res)=="1" or userType=="2" then
        OtherEatServiceFlag = "enable";
    else
        OtherEatServiceFlag = "disenable";
    end;
    --自由用餐2权限（共享人不通过状态检查，通过场景检查）
    if vt("OtherEat2AuthFlag",res)=="1" or userType=="2" then
        OtherEat2ServiceFlag = "enable";
    else
        OtherEat2ServiceFlag = "disenable";
    end;
    --自由用餐3权限（共享人不通过状态检查，通过场景检查）
    if vt("OtherEat3AuthFlag",res)=="1" or userType=="2" then
        OtherEat3ServiceFlag = "enable";
    else
        OtherEat3ServiceFlag = "disenable";
    end;
    --消息中心权限（共享人不通过状态检查，通过场景检查）
    if vt("MsgCenterAuthFlag",res)=="1" or userType=="2" then
        MsgCenterFlag = "enable";
    else
        MsgCenterFlag = "disenable";
    end;
    --杭口医院权限
    if vt("HKHospitalFlag",res)=="1" then
        HKHospitalFlag = "enable";
    else
        HKHospitalFlag = "disenable";
    end;
    --租房服务权限
    if vt("RenatalHourseFlag",res)=="1" then
        RenatalHourseFlag = "enable";
    else
        RenatalHourseFlag = "disenable";
    end;


    --自由用餐别名
    local EatServiceGrycName = vt("EatServiceGrycName",res);
    if EatServiceGrycName ~= "" then
        globalTable["EatServiceGrycName"] = EatServiceGrycName;
    else
        globalTable["EatServiceGrycName"] = "自由用餐";
    end;
    --自由用餐2别名
    local EatServiceGryc2Name = vt("EatServiceGryc2Name",res);
    if EatServiceGryc2Name ~= "" then
        globalTable["EatServiceGryc2Name"] = EatServiceGryc2Name;
    else
        globalTable["EatServiceGryc2Name"] = "自由用餐2";
    end;
    --自由用餐3别名（共享人不通过状态检查，通过场景检查）
    local EatServiceGryc3Name = vt("EatServiceGryc3Name",res);
    if EatServiceGryc3Name ~= "" then
        globalTable["EatServiceGryc3Name"] = EatServiceGryc3Name;
    else
        globalTable["EatServiceGryc3Name"] = "自由用餐3";
    end;

    --报销
    if vt("ProcessBillFlag",res) == "1" then
        processBillFlag = "enable";
    else
        processBillFlag = "disenable";
    end;

    --保存用户功能权限列表
    companyTable["viewauthority"] = vt("Viewauthority",res);

    --保存用户第三方服务信息
    companyTable["thirdPartyServiceStatus"] = json2table(vt("ThirdPartyServiceStatus",res));

    --设置商旅预订渠道
    lua_travel.set_channel(res);
end;

--[[根据快捷登录标志获取登录页面]]
function login_page(loginType)
    --默认进入账号密码登录界面
    local DefaultPageUrl = "jjbx_login/xhtml/jjbx_login.xhtml";
    local PageUrl = "";
    local loginType = formatNull(loginType, "0");

    if loginType =="0" then
        --账号密码
        PageUrl = DefaultPageUrl;
    elseif loginType =="1" then
        --手势
        PageUrl = "jjbx_login/xhtml/jjbx_gestureLogin.xhtml";
    elseif loginType =="2" then
        --指纹
        if systemTable["SupportLoginType"] == "TouchID" then
            PageUrl = "jjbx_login/xhtml/jjbx_touchIDLogin.xhtml";
        else
            PageUrl = DefaultPageUrl;
        end;
    elseif loginType =="3" then
        --人脸
        if systemTable["SupportLoginType"] == "FaceID" then
            PageUrl = "jjbx_login/xhtml/jjbx_faceIDLogin.xhtml";
        else
            PageUrl = DefaultPageUrl;
        end;
    elseif "mobile_login" then
        --手机号
        PageUrl = "jjbx_login/xhtml/jjbx_mobileLogin.xhtml";
    else
        --默认账号密码
        PageUrl = DefaultPageUrl;
    end;

    return PageUrl;
end;

--[[检查是否是未来的月份]]
function check_feature_month(checkMonth)
    local checkMonth = formatNull(checkMonth);
    local checkMonthRes = "false";
    if checkMonth == "" then
        alert("日期格式错误");
        checkMonthRes = "false";
    else
        --待检查月份的第一天
        local CheckDayTS = dateToTime(checkMonth.."01");
        --当前月份的第一天
        local NowMonthFirstDayTS = dateToTime(string.sub(os.date("%Y-%m-%d",os.time()),1,7).."01");

        if CheckDayTS > NowMonthFirstDayTS then
            if platform == "iPhone OS" then
                window:alert("不能选择未来的时间","确定");
            else
                alert("不能选择未来的时间");
            end;
            checkMonthRes = "false";
        else
            checkMonthRes = "true";
        end;
    end;

    return checkMonthRes;
end;

--[[实物附件提示语]]
function showFJZSFlagTip()
    alert(formatNull(globalTable["fjzsTip"],""));
end;

--[[是否有实物附件]]
function submitAttachment(submitAttachment,billType)
    if submitAttachment == "1" then
        changeProperty("SWFJImg","src","local:dj_ico_radioed.png");
        changeProperty("noSWFJImg","src","local:dj_ico_radio.png");
        --globalTable["submitAttachment".."_"..billType] = submitAttachment;
        --changeStyle("SWFJ_label","color","4A4A4A");
        --changeStyle("noSWFJ_label","color","919191");
    elseif submitAttachment == "0" then
        changeProperty("noSWFJImg","src","local:dj_ico_radioed.png");
        changeProperty("SWFJImg","src","local:dj_ico_radio.png");
        --globalTable["submitAttachment".."_"..billType] = submitAttachment;
        --changeStyle("SWFJ_label","color","919191");
        --changeStyle("noSWFJ_label","color","4A4A4A");
    else
        changeProperty("noSWFJImg","src","local:dj_ico_radio.png");
        changeProperty("SWFJImg","src","local:dj_ico_radio.png");
        --changeStyle("SWFJ_label","color","919191");
        --changeStyle("noSWFJ_label","color","919191");
    end;
    page_reload();
    globalTable["submitAttachment".."_"..billType] = submitAttachment;
    return "";
end;

function qryBillFJZSTipCallback(params)
    --查不到参数默认就不显示，不提示错误
    local responseBody = json2table(params["responseBody"]);
    globalTable["fjzsTip"] = responseBody["value"];
    if formatNull(globalTable["fjzsTip"],"") == "" then
        changeStyle("fjzs_tip_div","display","none");
        changeProperty("fjzsFlag_title","enable","false");
    else
        changeStyle("fjzs_tip_div","display","block");
    end;
    page_reload();
end;

function qryBillFJZSTip()
    invoke_trancode_noloading("jjbx_process_query","process_bill",{BusinessType="matter_apply_bill",TranCode="QryBillFJZSTip"},qryBillFJZSTipCallback,{CloseLoading="false"});
end;

--[[选择审批节点]]
function chooseOneJd(index)
    local elements = document:getElementsByName("check_img");
    for i=1,#elements do
        if i~=index then
            elements[i]:setPropertyByName("src","local:select.png");
        else
            local bacImg = elements[index]:getPropertyByName("src");
            if bacImg == "local:select.png" then
                document:getElementsByName("check_img")[index]:setPropertyByName("src","local:selected_round.png");
                globalTable["spjdData"] = globalTable["selectNodelist"][index]["nodeId"];
            else
                document:getElementsByName("check_img")[index]:setPropertyByName("src","local:select.png");
                globalTable["spjdData"] = nil;
            end;
        end;
    end;
end;

--[[判断审批节点是否选择]]
function checkChoose()
    if nil ~= globalTable["spjdData"] and globalTable["spjdData"] ~= ""then
        return 1;
    else
        return 0;
    end;
end;

--[[批准前判断是否选择了节点]]
function agreeJuger()
    if globalTable["spjdFlag"] == "1" then
        local check = checkChoose();
        if check == 0 then
            alert("请选择下个审批流程");
            return 0;
        else
            return 1;
        end;
    else
        return 1;
    end;
end;

--[[
    弹出页面
    arg json数据
    pageTag : 页面标识
]]
function alert_page(arg)
    --debug_alert("alert_page arg:"..arg);
    local argObj = json2table(arg);
    local pageTag = formatNull(argObj["pageTag"]);

    if pageTag == "upload_pic" then
        local appSupportInfo = lua_ota.version_support("upload_enclosure_page");
        local appSupport = vt("appSupport",appSupportInfo);
        local appSupportTipMsg = vt("appSupportTipMsg",appSupportInfo);

        --版本支持判断
        if appSupport == "false" then
            --更新提示
            local upverArg = {
                updateType="OPTION",
                updateMsg=appSupportTipMsg
            };
            lua_ota.show_upvsr_view(upverArg);
        else
            local invokeArg = {
                ShowPageStyle="showContent",
                AddPage="false",
                JumpStyle=""
            };
            invoke_page("jjbx_page/xhtml/upload_enclosure_pic_page.xhtml",page_callback,invokeArg);
        end;
    else
        alert("页面请求失败！");
    end;
end;

--[[####################银行网点选择-Begin####################]]

--[[银行控件初始数据]]
function do_put_bank_data(params)
    --debug_alert("do_put_bank_data");
    local responseBody = json2table(params["responseBody"]);

    if responseBody["bankCounts"] == "0" then
        hide_banknetwork_widget();
        alert("查询银行信息失败");
    else
        --银行
        --debug_alert(responseBody["bankList"]);
        local bankList = responseBody["bankList"];
        local bankValue = "";
        for key,value in pairs(bankList) do
            bankValue =
                bankValue ..
                "{"..
                    "\"bankType\":\""..value["bankcode"].."\","..
                    "\"bankName\":\""..value["bankname"].."\","..
                    "\"bankCode\":\""..value["bankcode"].."\","..
                    "\"headChar\":\""..value["firstPinYinPro"].."\","..
                    "\"fullChars\":\""..value["pinYin"].."\","..
                    "\"fullHeadChars\":\""..value["firstPinYin"].."\""..
                "},";
        end;
        
        --处理后的银行数据
        bankValue = string.sub(bankValue,1,string.len(bankValue)-1);
        --debug_alert(bankValue);

        --热门银行
        --debug_alert(responseBody["hotBankList"]);
        local hotBankList = responseBody["hotBankList"];
        local hotBankValue = "";
        for key,value in pairs(hotBankList) do
            hotBankValue =
                hotBankValue ..
                "{"..
                    "\"bankType\":\""..value["bankcode"].."\","..
                    "\"bankName\":\""..value["bankname"].."\","..
                    "\"bankCode\":\""..value["bankcode"].."\","..
                    "\"bankLogo\":\"czb_zjsyyh.png\","..
                    "\"hotNo\":\"1\""..
                "},";
        end;

        --处理后的热门银行数据
        hotBankValue = string.sub(hotBankValue,1,string.len(hotBankValue)-1);
        --debug_alert(hotBankValue);

        --拼装银行数据给到客户端
        local changeBankSelectValue = "";
        changeBankSelectValue =
            "{"..
                "\"ebankList\":"..
                "["..
                    "{"..
                        "\"hotBankList\":["..hotBankValue.."],"..
                        "\"bankList\":["..bankValue.."]"..
                    "}"..
                "]"..
            "}";
        --debug_alert("changeBankSelectValue : "..changeBankSelectValue);
        --初始化数据并显示控件，将物理键改为隐藏控件
        changeProperty("bank_widget", "value", changeBankSelectValue);
        show_ele("bank_bg_div");
        set_android_Physical_back("hide_banknetwork_widget");

        --银行信息存储缓存
        globalTable["BankData"] = params;
    end;
end;

--[[显示控件]]
function show_banknetwork_widget(index)
    show_ele("bank_network_widget_div");
    --changeProperty("top_search_text","value","交通银行上海高桥社区支行");
    changeProperty("top_search_text","value","");

    if index == "bank" then
        --显示银行控件，有缓存的情况下加载缓存
        local BankData = formatNull(globalTable["BankData"]);
        if BankData == "" then
            invoke_trancode_noloading(
                "jjbx_myInfo",
                "cardManagement",
                {TranCode="GetBankList"},
                do_put_bank_data,
                {}
            );
        else
            do_put_bank_data(BankData);
        end;
    elseif index == "network" then
        --判断是否已经选择了银行
        if globalTable["bank_code"] == "" then
            alert_confirm("温馨提示","您尚未选择开户行，请选择","确定","搜索网点","show_search_network");
        else
            --显示网点控件
            --初始化时加载省份数据
            get_network_data("GetProvenceList","","");
        end;
    end;
end;

--[[显示网点搜索]]
function show_search_network(index)
    if index == 1 then
        show_ele("search_network_bg_div");
        changeProperty("top_search_text","focus","true");
        set_android_Physical_back("hide_banknetwork_widget");
    else
        hide_ele("bank_network_widget_div");
    end;
end;

--[[隐藏全部控件]]
function hide_banknetwork_widget()
    --debug_alert("hide_banknetwork_widget");
    --隐藏网点和银行控件、清空初数据，并将物理键改回返回事件
    changeProperty("bank_widget", "value", "");
    changeProperty("network_widget", "value", "");
    hide_ele("bank_bg_div");
    hide_ele("network_bg_div");
    hide_ele("search_network_bg_div");
    hide_ele("bank_network_widget_div");

    page_reload();
    set_android_Physical_back();
end;

--[[隐藏网点控件]]
function hide_network_widget()
    hide_ele("network_widget_div");
end;

--[[
    网点控件初始数据
    TranCode : GetProvenceList 查省份 GetCityList 查城市 GetNetworkList 查网点
    Code     : 银行编码
    Name     : 银行名称
]]
function get_network_data(TranCode, Code, Name)
    --debug_alert("get_network_data TranCode:"..TranCode.." Code:"..Code.." Name:"..Name);
    local ProvinceData = formatNull(globalTable["ProvinceData"]);
    if TranCode=="GetProvenceList" and ProvinceData~="" then
        --省份信息优先加载缓存
        do_put_network_data(ProvinceData);
    else
        invoke_trancode_donot_checkRepeat(
            "jjbx_myInfo",
            "cardManagement",
            {TranCode=TranCode,Code=Code,Name=Name,BankCode=globalTable["bank_code"]},
            do_put_network_data,
            {}
        );
    end;
end;

--[[网点控件初始数据]]
function do_put_network_data(params)
    local responseBody = json2table(params["responseBody"]);
    local dataCounts = formatNull(responseBody["dataCounts"]);

    --[[debug_alert(
        "do_put_network_data\n"..
        "dataCounts : "..dataCounts.."\n"..
        ""
    );]]

    if dataCounts == "0" then
        --没有记录
        hide_banknetwork_widget();
        alertToast("0",C_NoneMsg,"","","");
    else
        --debug_alert(responseBody["dataList"]);

        --返回数据类型 province 省份 city 城市 network 网点
        local resType = responseBody["dataType"];
        --定义往哪个里面塞数据
        local dataType = "0";
        if resType == "city" then
            dataType = "1";
        elseif resType == "network" then
            dataType = "2";
        elseif resType == "province" then
            --省份信息存缓存
            globalTable["ProvinceData"] = params;
            dataType = "0";
        else
            dataType = "0";
        end;
        --debug_alert("dataType "..dataType);

        --客户端显示已选择信息
        --只有一条数据时，会自动进行联动查询，默认设置该信息，其他情况显示请选择
        local networkKey = formatNull(responseBody["dataFrom"],"请选择");
        if dataCounts~="1" or resType~="city" then
            networkKey = "请选择";
        end;

        local dataList = responseBody["dataList"];
        local dataValue = "";
        for key,value in pairs(dataList) do
            dataValue = dataValue .. "{\"name\":\""..value["name"].."\",\"code\":\""..value["code"].."\"},";
        end;
        dataValue = string.sub(dataValue,1,string.len(dataValue)-1);
        --debug_alert(dataValue);

        local changeDataValue = "";
        changeDataValue =
            "{"..
                "\"type\":\""..dataType.."\","..
                "\"networkKey\":\""..networkKey.."\","..
                "\"isOver\":\"F\","..
                "\"success\":\"T\","..
                "\"list\":["..dataValue.."]"..
            "}";
        --debug_alert("changeDataValue: "..changeDataValue);
        --初始化数据并显示控件，将物理键改为隐藏控件
        show_ele("network_bg_div");
        changeProperty("network_widget", "value", changeDataValue);
        set_android_Physical_back("hide_banknetwork_widget");
        page_reload();

        --城市只有一条记录自动进行下一级查询
        if dataCounts=="1" and resType=="city" then
            local qryName = formatNull(dataList[1]["name"]);
            local qryCode = formatNull(dataList[1]["code"]);
            --[[debug_alert(
                "只有一条记录\n"..
                "城市名称:"..qryName.."\n"..
                "城市编码:"..qryCode.."\n"..
                "数据类型:"..resType.."\n"..
                "选择信息:"..networkKey.."\n"..
                "\n"..
                "说明:数据来源是放到json的networkKey里的，应该是取这个值设置到title上，你俩确认下处理要一致。\n"..
                ""
            );]]
            --select_network("1",qryCode,qryName)
            get_network_data("GetNetworkList",qryCode,qryName);
        end;
    end;
end;

--[[
    网点控件点击事件
    type 0省1市2网点
]]
function select_network(type,code,name)
    --debug_alert("name:"..name.." code:"..code.." type:"..type);
    local TranCode = "";
    --从0点击过来说明要请求市的信息
    if type =="0" then
        get_network_data("GetCityList",code,name);
    --从1点击过来说明要请求网点的信息
    elseif type =="1" then
        get_network_data("GetNetworkList",code,name);
    --type为2的时候已经选择完毕，要更新数据
    else
        --控件显示修改
        choose_banknetwork_widget("network",name);
        --存值
        globalTable["network_name"] = name;
        globalTable["network_code"] = code;
        hide_banknetwork_widget();
    end;
end;

--[[银行控件点击事件]]
function select_bank(ishotbank,bankname,bankcode)
    --debug_alert("ishotbank:"..ishotbank.." bankname:"..bankname.." bankcode:"..bankcode);
    --存值
    globalTable["bank_name"] = bankname;
    globalTable["bank_code"] = bankcode;

    --控件显示修改
    choose_banknetwork_widget("bank",bankname);

    --如果是浙商银行卡，不用再选择网点
    if bankname == "浙商银行" and bankcode =="316" then
        hide_ele("network_container_div");
    else
        --切换其他银行时候清空下网点号和网点名
        globalTable["network_name"] = "";
        globalTable["network_code"] = "";
        --显示网点控件
        show_ele("network_container_div");
        --清空网点控件数据
        choose_banknetwork_widget("network","请选择");
        changeProperty("network_widget", "value", "");
    end;

    --关闭控件
    hide_banknetwork_widget();
end;

--[[搜索网点]]
function search_network(index)
    local searchText = formatNull(document:getElementsByName("top_search_text")[tonumber(index)]:getPropertyByName("value"));
    --debug_alert(searchText);
    if searchText ~= "" then
        invoke_trancode(
            "jjbx_myInfo",
            "cardManagement",
            {TranCode="SearchNetwork",NetWorkName=searchText},
            show_search_network_result,
            {}
        );
    else
        alert("请输入要搜索的网点名称");
    end;
end;

--[[显示网点搜索结果]]
function show_search_network_result(params)
    local responseBody = json2table(params["responseBody"]);
    if responseBody["errorNo"] == "000000" then
        local network_code = formatNull(responseBody["hh"]);
        local network_name = formatNull(responseBody["qcname"]);
        local bank_code = formatNull(responseBody["hbdm"]);
        local bank_name = formatNull(responseBody["bankName"]);
        globalTable["network_code"] = network_code;
        globalTable["network_name"] = network_name;
        globalTable["bank_code"] = bank_code;
        globalTable["bank_name"] = bank_name;

        --[[debug_alert(
            "显示网点搜索结果\n"..
            "网点号:"..globalTable["network_code"].."\n"..
            "网点名:"..globalTable["network_name"].."\n"..
            "行号:"..globalTable["bank_code"].."\n"..
            "行名:"..globalTable["bank_name"].."\n"..
            ""
        );]]

        choose_banknetwork_widget("network",network_name);
        choose_banknetwork_widget("bank",bank_name);
        hide_banknetwork_widget();
    else
        alertToast("0",C_NoneMsg,"","","");
    end;
end;

--[[搜索网点文字变更回调]]
function search_network_onChange(index)
    local searchText = formatNull(document:getElementsByName("top_search_text")[tonumber(index)]:getPropertyByName("value"));
    if searchText == "" then
        show_ele("network_widget_div");
        show_ele("radius_bg_div");
    else
        hide_ele("network_widget_div");
        hide_ele("radius_bg_div");
    end;
end;

--[[选择回调]]
function choose_banknetwork_widget(widget,value)
    local value = formatNull(value);
    if widget == "bank" then
        changeProperty("bank_name","value",jjbx_utils_setStringLength(value,16));
    else
        changeProperty("network_name","value",jjbx_utils_setStringLength(value,16));
    end;
end;

--[[####################银行网点选择-End####################]]

--[[通过单据号查询pdf封面，跳转下载链接]]
function lua_jjbx.get_bill_cover_pdf(params)
    local params = formatNull(params);
    if params == "" then
        invoke_trancode(
            "jjbx_service",
            "app_service",
            {TranCode="printBill",billNo=globalTable["billNo_download"],qryAllBillB = vt("qryAllBillB",globalTable)},
            lua_jjbx.get_bill_cover_pdf,
            {},
            all_callback,
            {CloseLoading="false"}
        );
    else
        local responseBody = json2table(params["responseBody"]);
        if responseBody["errorNo"] == "000000" then
            --清空点击记录
            globalTable["qryAllBillB"] = "";
            --关闭加载动画
            close_loading();
            --调用文件下载
            lua_system.download_file(responseBody["CacheFileDLUrl"]);
        else
            alert(responseBody["errorMsg"]);
        end;
    end;
end;

--[[查询链接并前往消息h5页面]]
function lua_jjbx.qry_msg_h5_link(qryArg)
    local qryArg = formatNull(qryArg);
    local PkMsgPublishList = formatNull(qryArg["PkMsgPublishList"]);
    local NeedBase64 = formatNull(qryArg["NeedBase64"],"false");
    local MsgType = formatNull(qryArg["MsgType"]);
    local PopupFlag = formatNull(qryArg["PopupFlag"]);

    --[[debug_alert(
        "lua_jjbx.qry_msg_h5_link\n"..
        "PkMsgPublishList : "..PkMsgPublishList.."\n"..
        "NeedBase64 : "..NeedBase64.."\n"..
        "MsgType : "..MsgType.."\n"..
        "PopupFlag : "..PopupFlag.."\n"..
        ""
    );]]

    invoke_trancode_donot_checkRepeat(
        "jjbx_page",
        "webview_page",
        {
            TranCode="InitPublishMsgUrl",
            PkMsgPublishList=PkMsgPublishList,
            NeedBase64=NeedBase64,
            MsgType=MsgType,
            popupFlag=PopupFlag
        },
        lua_jjbx.open_msg_h5_page,
        {},
        all_callback,
        {CloseLoading="false"}
    );
end;

--[[打开消息h5页面]]
function lua_jjbx.open_msg_h5_page(params)
    local data = json2table(params["responseBody"]);
    globalTable["webview_url"] = data["webview_url"];
    --debug_alert("打开消息h5页面，链接地址 : "..globalTable["webview_url"]);

    --打开h5页面，访问时后台会将该消息置为已读，前端无需发已读接口
    invoke_page("jjbx_page/xhtml/webview_page.xhtml",page_callback,{CloseLoading="false"});
end;

--[[消息默认弹出]]
function lua_jjbx.msg_default_alert(Arg)
    local content = vt("content",Arg);
    local readFlag = vt("readFlag",Arg);

    --弹出消息内容，在回调里标记已读
    if readFlag ~= "true" then
        alert_confirm("消息内容",content,"","确定","lua_jjbx.updMarkunreadFlag","");
    else
        alert_confirm("消息内容",content,"","确定","","");
    end;
end;

--[[标记消息为已读]]
function lua_jjbx.updMarkunreadFlag(params)
    local params = formatNull(params);

    --为空和1(对话框点击确定)认为是请求，其他是响应
    if params == "" or params == 1 then
        local pkNotimsg = formatNull(globalTable["DelpkNotimsg"]);
        local pkMsgPublishList = formatNull(globalTable["DelpkMsgPublishList"]);
        local popupFlag = formatNull(globalTable["popupFlag"]);

        --清理缓存数据
        globalTable["DelpkMsgPublishList"] = "";
        globalTable["DelpkNotimsg"] = "";
        globalTable["popupFlag"] = "";

        --[[debug_alert(
            "标记消息为已读\n"..
            "pkNotimsg : "..pkNotimsg.."\n"..
            "pkMsgPublishList : "..pkMsgPublishList.."\n"..
            "popupFlag : "..popupFlag.."\n"..
            ""
        );]]

        --已读发起
        invoke_trancode_noloading(
            "jjbx_index",
            "query_msg",
            {
                TranCode="UpdMarkunreadFlag",
                pkNotimsg=pkNotimsg,
                pkMsgPublishList=pkMsgPublishList,
                popupFlag=popupFlag
            },
            lua_jjbx.updMarkunreadFlag,
            {}
        );
    else
        --结果处理
        local jsonData = params["responseBody"];
        local data = json2table(jsonData);
        if data["errorNo"] == "000000" then
            --查询消息未读数量
            qryMsgMarkUnReadCount();
            isClean = "true";
        else
            alert(data["errorMsg"]);
        end;
    end;
end;

--[[打开新手指南页面]]
function lua_jjbx.open_guide_page(url)
    globalTable["webview_url"] = url;
    globalTable["webview_page_title"] = "新手指南";
    globalTable["webview_back2jjbx"] = "返回首页";
    --存储URL
    globalTable["GuidePageUrl"] = url;
    invoke_page_noloading_checkRepeat("jjbx_page/xhtml/webview_page.xhtml",page_callback,nil);
end;

--[[检查菜单是否需要添加]]
function lua_jjbx.invoice_menu_enable_ctrl(MenuEnableConfig,MenuConfigId)
    local needCheck = formatNull(configTable["add_invoice_menu_config"]);
    --debug_alert("添加发票的菜单是否走后台配置 : "..needCheck);
    if needCheck == "false" then
        return "true";
    else
        if string.find(MenuEnableConfig, MenuConfigId) then
            return "true";
        else
            return "false";
        end;
    end;
end;

--[[弹出菜单发票添加菜单]]
function lua_jjbx.alert_add_invoice_menu(menuType)
    --获取配置信息
    local PCConfigListsTable = vt("PCConfigListsTable",globalTable);
    --debug_alert(foreach_arg2print(PCConfigListsTable));

    --获取菜单开关配置参数
    local MenuEnableConfig = vt("INV0012",PCConfigListsTable);
    --debug_alert("菜单开关配置参数 : "..MenuEnableConfig);

    local menuType = formatNull(menuType);
    --debug_alert("lua_jjbx.alert_add_invoice_menu menuType : "..menuType);
    --菜单路由函数
    local router_fun = "lua_menu.app_alert_menu_action";
    --菜单关闭函数
    local close_fun = "lua_jjbx.close_add_invoice_menu";

    --单据发票关联
    --通过发票池关联
    local menu_relate_by_fpc = {
        title="从发票池选择",
        tip=vt("INV0005",PCConfigListsTable),
        fun=router_fun,
        arg="invoice_relate_by_fpc"
    };
    --通过上传关联
    local menu_relate_by_upload = {
        title="添加电票",
        tip=vt("INV0008",PCConfigListsTable),
        fun=router_fun,
        arg="invoice_relate_by_filesystem"
    };
    --通过手工录入后保存关联
    local menu_relate_by_input = {
        title="添加纸票",
        tip=vt("INV0009",PCConfigListsTable),
        fun=router_fun,
        arg="invoice_relate_by_input"
    };

    --发票添加
    --通过上传添加
    local menu_add_by_upload = {
        title="添加电票",
        tip=vt("INV0025",PCConfigListsTable),
        fun=router_fun,
        arg="invoice_add_by_filesystem"
    };
    --通过手工录入添加
    local menu_add_by_input = {
        title="添加纸票",
        tip=vt("INV0009",PCConfigListsTable),
        fun=router_fun,
        arg="invoice_add_by_input"
    };
    --火车票识别
    --通过相机拍照后OCR识别火车票
    local menu_scan_train_ticket_by_camera = {
        title="拍照识别",
        tip="",
        fun=router_fun,
        arg="scan_train_ticket_by_camera"
    };
    --通过相册选择后OCR识别火车票
    local menu_scan_train_ticket_by_album = {
        title="上传火车票图片",
        tip="",
        fun=router_fun,
        arg="scan_train_ticket_by_album"
    };
    --通过选择上传文件识别火车票
    local menu_scan_train_ticket_by_filesystem = {
        title="从文件选择",
        tip="",
        fun=router_fun,
        arg="scan_train_ticket_by_filesystem"
    };

    --通过相机拍照后OCR识别行程单
    local menu_scan_air_ticket_by_camera = {
        title="拍照识别",
        tip="",
        fun=router_fun,
        arg="scan_air_ticket_by_camera"
    };
    --通过相册选择后OCR识别行程单
    local menu_scan_air_ticket_by_album = {
        title="上传行程单图片",
        tip="",
        fun=router_fun,
        arg="scan_air_ticket_by_album"
    };
    --通过上传文件识别机票
    local menu_scan_air_ticket_by_filesystem = {
        title="从文件选择",
        tip="",
        fun=router_fun,
        arg="scan_air_ticket_by_filesystem"
    };
    --通过上传文件识别凭证
    local menu_pension_voucher_by_filesystem = {
        title="从文件选择",
        tip="",
        fun=router_fun,
        arg="pension_voucher_by_filesystem"
    };

    --添加菜单
    local menu_info_list = {};
    if menuType == "relate" then
        --添加并且关联至单据
        if lua_jjbx.invoice_menu_enable_ctrl(MenuEnableConfig,"INVADD01") == "true" then
            table.insert(menu_info_list, menu_relate_by_fpc);
        end;
        if lua_jjbx.invoice_menu_enable_ctrl(MenuEnableConfig,"INVADD04") == "true" then
            table.insert(menu_info_list, menu_relate_by_upload);
        end;
        if lua_jjbx.invoice_menu_enable_ctrl(MenuEnableConfig,"INVADD05") == "true" then
            table.insert(menu_info_list, menu_relate_by_input);
        end;
    elseif menuType == "add" then
        --添加至发票池，菜单不走配置
        table.insert(menu_info_list, menu_add_by_upload);
        table.insert(menu_info_list, menu_add_by_input);
    elseif menuType == "scan_train_ticket" then
        --识别火车票
        table.insert(menu_info_list, menu_scan_train_ticket_by_camera);
        table.insert(menu_info_list, menu_scan_train_ticket_by_album);
        table.insert(menu_info_list, menu_scan_train_ticket_by_filesystem);
    elseif menuType == "scan_air_ticket" then
        --识别行程单
        table.insert(menu_info_list, menu_scan_air_ticket_by_camera);
        table.insert(menu_info_list, menu_scan_air_ticket_by_album);
        table.insert(menu_info_list, menu_scan_air_ticket_by_filesystem);
    elseif menuType == "pension_voucher" then
        --个人养老金企业申报
        table.insert(menu_info_list, menu_pension_voucher_by_filesystem);
    end;

    --debug_alert("菜单数 : "..#menu_info_list);
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
    --debug_alert(jsonArg);
    lua_system.app_alert_menu(jsonArg);
end;

--[[关闭菜单发票添加菜单]]
function lua_jjbx.close_add_invoice_menu(arg)
    lua_system.close_app_alert_menu();
end;

--[[
    上传发票识别回调（用于添加发票）
    ·totalcounts   : 总张数
    ·successcounts : 成功张数
    ·resmsg        : 返回的message error
    ·resinfoJson   : 返回的res 上传失败，错误信息未定义
]]
function lua_jjbx.upload_invoice_to_add_call(totalcounts, successcounts, resmsg, resinfoJson)
    local totalcounts = formatNull(totalcounts);
    local successcounts = formatNull(successcounts);
    local resmsg = formatNull(resmsg);
    local resinfoJson = formatNull(resinfoJson);

    --[[debug_alert(
        "上传发票识别回调（用于添加发票）\n"..
        "总张数:"..totalcounts.."\n"..
        "成功张数: "..successcounts.."\n"..
        "返回结果: "..resmsg.."\n"..
        "返回信息: "..resinfoJson.."\n"..
        ""
    );]]
    local appSupportInfo = lua_ota.version_support("invoiceUpload");
    local appSupport = vt("appSupport",appSupportInfo);
    local invoiceUploadCtrl = vt("invoiceUploadCtrl",globalTable);
    if (invoiceUploadCtrl == "invoice_add_by_filesystem" or invoiceUploadCtrl == "invoice_add_by_album") and appSupport == "true" then
        local resinfoTable = json2table(resinfoJson);
        local res = vt("res",resinfoTable);
        local errorNo = vt("errorNo",res);
        local errorMsg = vt("errorMsg",res,"识别失败");
        local FileID = vt("FileID",res);

        --根据返回的文件名来修改上传列表中文件的识别状态
        local uploadingFile = vt("uploadingFile",globalTable,{});
        for key,value in pairs(uploadingFile) do
            if FileID == value["fileID"] then
                if errorNo == "000000" then
                    uploadingFile[key]["uploadState"] = "待保存";
                else
                    uploadingFile[key]["uploadState"] = "上传失败";
                end;
            end;
        end;

        if vt("UploadInvoiceToAddRes",globalTable) == "" then
            globalTable["UploadInvoiceToAddRes"] = {};
        end;

        --识别结果信息
        local UploadResultMsg = "";
        if errorNo == "000000" then
            --识别成功追加信息
            table.insert(globalTable["UploadInvoiceToAddRes"],res);
            --识别完成时调用保存接口
            lua_upload.saveCheckSuccessInvoice("",{});
        else
            local AddErrorMsg = errorMsg.."，文件名："..FileName.."\n";
            UploadResultMsg = UploadResultMsg..AddErrorMsg;
            --debug_alert(UploadResultMsg);
        end;
    else
        if tonumber(totalcounts) == tonumber(successcounts) then
            local resinfoTable = json2table(resinfoJson);
            local res = vt("res",resinfoTable);
            local resCounts = #res;

            local UploadInvoiceToAddRes = {};

            --识别结果信息
            local UploadResultMsg = "";
            for i=1,resCounts do
                local LoopData = formatNull(res[i]);
                local errorNo = vt("errorNo",LoopData);
                local errorMsg = vt("errorMsg",LoopData,"识别失败");
                local FileName = vt("FileName",LoopData);
                if errorNo == "000000" then
                    --识别成功追加信息
                    table.insert(UploadInvoiceToAddRes,LoopData);
                else
                    local AddErrorMsg = errorMsg.."，文件名："..FileName.."\n";
                    UploadResultMsg = UploadResultMsg..AddErrorMsg;
                end;
            end;

            --错误信息弹出
            if UploadResultMsg ~= "" then
                alert(UploadResultMsg);
            end;

            --正确识别1条以上时跳转页面
            if #UploadInvoiceToAddRes > 0 then
                local InvokePageArg = {
                    UploadInvoiceToAddRes=UploadInvoiceToAddRes,
                    CloseLoading="false"
                };
                invoke_page("jjbx_fpc/xhtml/jjbx_invoice_upload_save.xhtml",page_callback,InvokePageArg);
            else
                alert("发票识别失败");
            end;
        else
            alert("发票识别失败");
        end;
    end;
end;

--[[
    上传发票识别回调（用于关联发票）
    ·totalcounts   : 总张数
    ·successcounts : 成功张数
    ·resmsg        : 返回的message error
    ·resinfoJson   : 返回的res 上传失败，错误信息未定义
]]
function lua_jjbx.upload_invoice_to_relate_call(totalcounts, successcounts, resmsg, resinfoJson)
    local totalcounts = formatNull(totalcounts);
    local successcounts = formatNull(successcounts);
    local resmsg = formatNull(resmsg);
    local resinfoJson = formatNull(resinfoJson);

    --[[debug_alert(
        "上传发票识别回调（用于关联发票）\n"..
        "总张数:"..totalcounts.."\n"..
        "成功张数: "..successcounts.."\n"..
        "返回信息: "..resmsg.."\n"..
        "返回结果:"..resinfoJson.."\n"..
        ""
    );]]

    --上传成功张数和总张数一致认为上传成功
    if tonumber(totalcounts) == tonumber(successcounts) then
        local resinfoTable = json2table(resinfoJson);
        local res = vt("res",resinfoTable);
        local resCounts = #res;

        local UploadInvoiceToAddRes = {};

        --识别结果信息
        local UploadResultMsg = "";
        for i=1,resCounts do
            local LoopData = formatNull(res[i]);
            local errorNo = vt("errorNo",LoopData);
            local errorMsg = vt("errorMsg",LoopData,"识别失败");
            local FileName = vt("FileName",LoopData);
            if errorNo == "000000" then
                --识别成功追加信息
                table.insert(UploadInvoiceToAddRes,LoopData);
            else
                local AddErrorMsg = errorMsg.."，文件名："..FileName.."\n";
                UploadResultMsg = UploadResultMsg..AddErrorMsg;
            end;
        end;

        --错误信息弹出
        if UploadResultMsg ~= "" then
            alert(UploadResultMsg);
        end;

        --正确识别1条以上时跳转页面
        if #UploadInvoiceToAddRes > 0 then
            local InvokePageArg = {
                UploadInvoiceToAddRes=UploadInvoiceToAddRes,
                CloseLoading="false"
            };
            globalTable["invoiceFlag"] = "upload";
            globalTable["scfpTip"] = "false";
            invoke_page("jjbx_proccess_reimbursement_bill/xhtml/reimbursement_bill_invoice_upload_save.xhtml",page_callback,InvokePageArg);
        else
            alert("发票识别失败");
        end;
    else
        alert("发票识别失败");
    end;
end;

--[[
    上传火车票并返回识别结果
    ·totalcounts   : 总张数
    ·successcounts : 成功张数
    ·resmsg        : 返回的message error
    ·resinfoJson   : 返回的res 上传失败，错误信息未定义
]]
function lua_jjbx.upload_train_ticket_to_scan_call(totalcounts, successcounts, resmsg, resinfoJson)
    local totalcounts = formatNull(totalcounts);
    local successcounts = formatNull(successcounts);
    local resmsg = formatNull(resmsg);
    local resinfoJson = formatNull(resinfoJson);

    --[[debug_alert(
        "上传火车票并返回识别结果\n"..
        "总张数:"..totalcounts.."\n"..
        "成功张数: "..successcounts.."\n"..
        "返回结果: "..resmsg.."\n"..
        "返回信息: "..resinfoJson.."\n"..
        ""
    );]]

    --上传成功张数和总张数一致认为上传成功
    if tonumber(totalcounts) == tonumber(successcounts) then
        local resinfoTable = json2table(resinfoJson);
        local res = vt("res",resinfoTable);
        local errorNo = vt("errorNo",res[1]);
        local errorMsg = vt("errorMsg",res[1]);

        if errorNo == "000000" then
            globalTable["UploadInvoiceInfo"] = res[1];
            --在页面里实现回调完成业务操作
            train_ticket_info_call(res[1]);
        else
            alert(errorMsg);
        end;
    else
        alert("火车票识别失败");
    end;
end;

--[[
    上传行程单并返回识别结果
    ·totalcounts   : 总张数
    ·successcounts : 成功张数
    ·resmsg        : 返回的message error
    ·resinfoJson   : 返回的res 上传失败，错误信息未定义
]]
function lua_jjbx.upload_air_ticket_to_scan_call(totalcounts, successcounts, resmsg, resinfoJson)
    local totalcounts = formatNull(totalcounts);
    local successcounts = formatNull(successcounts);
    local resmsg = formatNull(resmsg);
    local resinfoJson = formatNull(resinfoJson);

    --[[debug_alert(
        "上传行程单并返回识别结果\n"..
        "总张数:"..totalcounts.."\n"..
        "成功张数: "..successcounts.."\n"..
        "返回结果: "..resmsg.."\n"..
        "返回信息: "..resinfoJson.."\n"..
        ""
    );]]

    --上传成功张数和总张数一致认为上传成功
    if tonumber(totalcounts) == tonumber(successcounts) then
        local resinfoTable = json2table(resinfoJson);
        local res = vt("res",resinfoTable);
        local errorNo = vt("errorNo",res[1]);
        local errorMsg = vt("errorMsg",res[1]);

        if errorNo == "000000" then
            globalTable["UploadInvoiceInfo"] = res[1];
            --在页面里实现回调完成业务操作
            air_ticket_info_call(res[1]);
        else
            alert(errorMsg);
        end;
    else
        alert("行程单识别失败");
    end;
end;

--[[
    上传文件并返回识别结果
    ·totalcounts   : 总张数
    ·successcounts : 成功张数
    ·resmsg        : 返回的message error
    ·resinfoJson   : 返回的res 上传失败，错误信息未定义
]]
function lua_jjbx.upload_pension_voucher_call(totalcounts, successcounts, resmsg, resinfoJson)
    local totalcounts = formatNull(totalcounts);
    local successcounts = formatNull(successcounts);
    local resmsg = formatNull(resmsg);
    local resinfoJson = formatNull(resinfoJson);

    --[[debug_alert(
        "上传文件并返回识别结果\n"..
        "总张数:"..totalcounts.."\n"..
        "成功张数: "..successcounts.."\n"..
        "返回结果: "..resmsg.."\n"..
        "返回信息: "..resinfoJson.."\n"..
        ""
    );]]

    --上传成功张数和总张数一致认为上传成功
    if tonumber(totalcounts) == tonumber(successcounts) then
        local resinfoTable = json2table(resinfoJson);
        local res = vt("res",resinfoTable);
        local errorNo = vt("errorNo",res[1]);
        local errorMsg = vt("errorMsg",res[1]);

        if errorNo == "000000" then
            globalTable["UploadInvoiceInfo"] = res[1];
            --在页面里实现回调完成业务操作
            pension_voucher_info_call(res[1]);
        else
            alert(errorMsg);
        end;
    else
        alert("行程单识别失败");
    end;
end;

--[[设置发票录必填/显示要素]]
function lua_jjbx.load_invoice_content(necessaryInvElements,showContentList)
    --必填项配置
    local necessaryInvElements = formatNull(necessaryInvElements);
    --申请人查看要素
    local showContentList = formatNull(showContentList);

    --配置
    local Config = formatNull(JJBX_InvoiceContentList);
    local ConfigCounts = #Config;

    if necessaryInvElements=="" or showContentList=="" then
        --没有配置时，默认不显示且非必填
        for i=1,ConfigCounts do
            local ConfigData = formatNull(Config[i]);
            local tagName = vt("tagName",ConfigData);
            changeProperty(tagName.."_required","value","");
            changeStyle(tagName.."_div","display","none");
        end;
    else
        local debug_alert_msg = "";
        for i=1,ConfigCounts do
            local ConfigData = formatNull(Config[i]);
            local code = vt("code",ConfigData);
            local tagName = vt("tagName",ConfigData);
            local name = vt("name",ConfigData);

            --查找发票字段列表中的字段是否存在必填项中
            local requiredFlag = string.find(necessaryInvElements,code);
            requiredFlag = formatNull(requiredFlag,0);
            --查找发票字段列表中的字段是否存在显示项中
            local showFlag = string.find(showContentList,code);
            showFlag = formatNull(showFlag,0);

            local rmsg = "";
            local smsg = "";

            --渲染必填效果
            if tonumber(requiredFlag) > 0 then
                rmsg = "r-"..requiredFlag;
                --如果存在,则显示必填
                changeProperty(tagName.."_required","value","*");
            else
                --如果不存在,清空必填项
                changeProperty(tagName.."_required","value","");
            end;

            --渲染显示效果
            if tonumber(showFlag) > 0 then
                smsg = "s-"..showFlag;
                --如果存在,则显示
                changeStyle(tagName.."_div","display","block");
            else
                --如果不存在,则隐藏
                changeStyle(tagName.."_div","display","none");
            end;

            if rmsg~="" or smsg~="" then
                debug_alert_msg = debug_alert_msg..rmsg.." "..smsg.." "..name.." "..code.." "..tagName.."\n";
            end;
        end;

        --[[debug_alert(
            "必填要素 : "..necessaryInvElements.."\n"..
            "申请要素 : "..showContentList.."\n\n"..
            debug_alert_msg.."\n"..
            ""
        );]]
    end;
    page_reload();
end;

--[[密码加密初始化]]
function lua_jjbx.pwd_encrypt_init(resParams,reqParams,initCallBackArg)
    if formatNull(resParams) == "" then
        --debug_alert("获取密码加密偏移量-请求");

        --回调参数存缓存
        globalTable["PwdEncryptInitCallBackArg"] = initCallBackArg;
        --debug_alert(foreach_arg2print(initCallBackArg));

        --查询密码偏移量
        invoke_trancode_donot_checkRepeat(
            "jjbx_service",
            "app_service",
            {TranCode="PwdEncryptVi"},
            lua_jjbx.pwd_encrypt_init,
            {},
            all_callback,
            {CloseLoading="true"}
        );
    else
        local res = json2table(resParams["responseBody"]);
        --debug_alert("获取密码加密偏移量-响应\n"..foreach_arg2print(res));

        --密码加密偏移量
        local viKey = vt("ViKey",res);
        if viKey == "" then
            alertToast1("服务异常");
        else
            --取缓存里的回调参数
            local PwdEncryptInitCallBackArg = formatNull(globalTable["PwdEncryptInitCallBackArg"],{});
            --清理缓存
            globalTable[PwdEncryptInitCallBackArg] = "";
            --回调参数添加偏移量
            PwdEncryptInitCallBackArg["EncryptViKey"]=viKey;

            --页面上需要自行实现回调pwd_encrypt_call
            lua_system.do_function("pwd_encrypt_call",PwdEncryptInitCallBackArg);
        end;
    end;
end;

--[[密码加密]]
function lua_jjbx.encyrpt_password(pwd,encryptViKey)
    --加密类型
    local pwdEncType = vt("PwdEncType",configTable);
    --密码原文
    local pwd = formatNull(pwd);
    --加密结果
    local encyrptPwd = "";

    if pwdEncType == "SM" then
        --debug_alert("sm加密");

        --sm2密钥
        local sm2Key = vt("PwdEncSm2Key",configTable);
        --sm4密钥
        local sm4Key = vt("PwdEncSm4Key",configTable);
        --偏移量
        local viKey = formatNull(encryptViKey);

        --空参校验
        local argListTable = {
            pwd,
            sm2Key,
            sm4Key,
            viKey
        };
        if lua_form.arglist_check_empty(argListTable) == "true" then
            --加密密码
            local encryptArgTable = {
                sm2Key=sm2Key,
                sm4Key=sm4Key,
                viKey=viKey,
                pwd=pwd
            };
            local encryptArgJson = table2json(encryptArgTable);
            encyrptPwd = ryt:encrypt_password(encryptArgJson);

            --[[debug_alert(
                "密码国密加密\n"..foreach_arg2print(encryptArgTable)..
                "密文 : "..encyrptPwd.."\n"..
                ""
            );]]
        else
            alertToast1("加密失败");
        end;
    elseif pwdEncType == "RSA" then
        encyrptPwd = ryt:doEncyrptInput(pwd);

        --debug_alert("rsa加密结果 : "..encyrptPwd);
    else
        alert("加密方式未配置，请检查");
    end;

    return encyrptPwd;
end;

--[[####################承担人搜索-Begin####################]]
--[[搜索承担人]]
function lua_jjbx.search_cdr(cdrEleName)
    --承担人搜索文本框search_cdr_text，可以传递
    local cdrEleName = formatNull(cdrEleName,"search_cdr_text");
    local cdrName = getValue(cdrEleName);

    if cdrName ~= "" then
        --执行搜索
        local ReqParams = {
            peoplename=cdrName,
            searchFlag="authDept"
        };
        lua_jjbx.do_search_cdr("",ReqParams);
    else
        --alert("承担人为空");
    end;
end;

--[[搜索承担人默认回调（搜索结果更新到页面）]]
function lua_jjbx.do_search_cdr(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams);
        ReqParams["TranCode"] = "forPsnApp";
        invoke_trancode_noloading(
            "jjbx_process_query",
            "consumption_serial",
            ReqParams,
            lua_jjbx.do_search_cdr,
            {}
        );
    else
        local res = json2table(ResParams["responseBody"]);
        local htmlOption = "";

        --承担人搜索结果
        local cdrSearchResList = vt("list",res);
        --承担人搜索结果条目数
        local cdrSearchCounts = #cdrSearchResList;

        if cdrSearchCounts > 0 then
            --存缓存
            globalTable["cdrSearchResList"] = cdrSearchResList;

            --遍历承担人生成选择列表
            for key,value in pairs(cdrSearchResList) do
                --显示的工号
                local showCdrWrokId = vt("workid",value);
                --显示的人员信息
                local showCdrInfo = vt("name",value).."　"..vt("deptName",value);

                htmlOption = htmlOption..[[
                    <div class="search_people_option_div" border="0" onclick="lua_jjbx.select_cdr(]]..key..[[)">
                        <label class="search_people_res_info1_label" name="workID">]]..showCdrWrokId..[[</label>
                        <label class="search_people_res_info2_label" name="nameAndDept">]]..showCdrInfo..[[</label>
                        <div class="space_05_div" border="0"/>
                        <line class="search_people_line" />
                    </div>
                ]];
            end;
        else
            --没有承担人
            htmlOption = [[
                <div class="search_people_none_div" border="0">
                    <label class="search_people_none_label" value="查无此人"></label>
                </div>
            ]];
        end;

        local htmlContent = [[
            <div class="search_people_list_div" border="0" name="search_people_list_div">
                ]]..htmlOption..[[
            </div>
        ]];
        document:getElementsByName("search_people_list_div")[1]:setInnerHTML(htmlContent);

        --高度限制为3行
        local cdrOptionHeight = 72;
        local cdrListDivHeight = cdrOptionHeight*3;
        changeStyle("search_people_list_div","height",tostring(cdrListDivHeight));
    end;
end;

--[[选择承担人]]
function lua_jjbx.select_cdr(index)
    --承担人信息
    local cdrInfo = "";

    --承担人为自己
    if index == "cdr_by_self" then
        cdrInfo = "cdr_by_self";
    else
        --获取选中的承担人信息
        cdrInfo = globalTable["cdrSearchResList"][index];
    end;

    --debug_alert("选择承担人"..foreach_arg2print(cdrInfo));

    --关闭弹出界面
    lua_page.div_page_ctrl();
    --页面自行实现select_cdr_call回调，完成后续业务逻辑处理
    lua_system.do_function("select_cdr_call",cdrInfo);
end;

--[[####################承担人搜索-End####################]]

--[[根据功能编号查询功能权限]]
function lua_jjbx.check_authority_by_funcode(ResParams,ReqParams)
    local ResParams = formatNull(ResParams);
    if ResParams == "" then
        local ReqParams = formatNull(ReqParams);
        ReqParams["TranCode"] = "CheckFuncAuthorityByFuncode";

        invoke_trancode_noloading(
            "jjbx_service",
            "app_service",
            ReqParams,
            lua_jjbx.check_authority_by_funcode,
            {},
            all_callback,
            {CloseLoading="true"}
        );
    else
        local res = json2table(ResParams["responseBody"]);
        local errorNo = vt("errorNo",res);
        local ReqFunCode = vt("ReqFunCode",res);
        local cacheArgName = "Authority_"..ReqFunCode;
        local CallFun = vt("CallFun",res);
        local CallArg = vt("CallArg",res);

        if errorNo == "000000" then
            --有权限
            globalTable[cacheArgName] = "1";
        else
            --无权限
            globalTable[cacheArgName] = "0";
            --隐藏特殊情况说明模块
            changeStyle("tsqksm_div","display","none");
        end;
        if CallFun ~= "" then
            lua_system.do_function(CallFun,CallArg);
        end;
    end;
end;

--[[服务端受保护文件下载]]
function lua_jjbx.sp_file_dl(FileSeq)
    local FileSeq = formatNull(FileSeq);
    if FileSeq == "" then
        alert("下载失败");
        return;
    else
        local DlUrl = systemTable["ServerProtectFileDlUrl"]..FileSeq;
        lua_system.download_file(DlUrl);
    end;
end;

--[[更新已上传的文件个数信息显示]]
function lua_jjbx.update_upload_counts_show(uploadedcounts)
    local uploadedcounts = formatNull(uploadedcounts,"0");
    changeProperty("fj_title","value","已上传"..uploadedcounts.."个");
end;

--[[前往转办页面]]
function jjbx_transfer(billNo)
    globalTable["billNo_djzb"] = billNo;
    invoke_page("jjbx_process_bill/xhtml/process_bill_transfer_verify.xhtml",page_callback,nil);
end;

--[[前往撤回转办页面]]
function jjbx_unTransfer(billNo)
    globalTable["billNo_djzb"] = billNo;
    invoke_page("jjbx_process_bill/xhtml/process_bill_transfer_cancel.xhtml",page_callback,nil);
end;

--[[转办回复上传附件事件]]
function jjbx_answerTransfer_upload()
    --标志转办上传附件
    globalTable["UploadEnclosurePicReloadFlag"] = "1";
    --存储单据号和单据类型作为查询条件
    globalTable["UploadEnclosurePicBillNo"] = globalTable["billNo_djzb"];
    globalTable["UploadEnclosurePicBillType"] = globalTable["djlxbm"];
    local alertPageArg =
        "{"..
            "\"pageTag\":\"upload_pic\""..
            ""..
        "}";
    alert_page(alertPageArg);
end;

 --[[更新转办附件信息]]
function lua_jjbx.update_answer_transfer_enclosure_call(params)
    close_loading();
    local responseBody = json2table(params["responseBody"]);
    if responseBody["BillFileQryErrorNo"] == "000000" then
        --更新附件显示张数
        lua_jjbx.update_upload_counts_show(formatNull(responseBody["PcEnclosureTotalCounts"],"0"));
    else
        alert(responseBody["BillFileQryErrorMsg"]);
    end;
end;

--[[点击转办事件响应]]
function jjbx_showAnswerTransfer(billNo)
    globalTable["billNo_djzb"] = billNo;
    local ReqParams = {
        billNo=billNo
    };
    --显示转办回复窗口
    lua_jjbx.show_answer_transfer_window("",ReqParams);
end;

--[[显示转办回复窗口]]
function lua_jjbx.show_answer_transfer_window(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams);
        ReqParams["BusinessType"] = "bill_index";
        ReqParams["TranCode"] = "getYXSCFlagAnswer";
        invoke_trancode_donot_checkRepeat(
            "jjbx_process_query",
            "process_bill",
            ReqParams,
            lua_jjbx.show_answer_transfer_window,
            {},
            all_callback,
            {CloseLoading="false"}
        );
    else
        local responseBody = json2table(ResParams["responseBody"]);
        --yxscFlagAnswer: 等于1的时候，显示上传附件的按钮
        globalTable["djlxbm"] = responseBody["bill"][1]["djlxbm"];
        local yxscFlagAnswer = formatNull(responseBody["yxscFlagAnswer"]);
        --调试转办附件上传
        --yxscFlagAnswer = "1";

        if yxscFlagAnswer == "1" then
            --获取转办附件数量
            local QueryEnclosureArg = {
                billNo=globalTable["billNo_djzb"],
                ReloadFlag="1",
                callback="lua_jjbx.update_answer_transfer_enclosure_call"
            };
            --缓存临时标志（当前为转办回复），用于附件变动后的查询条件
            globalTable["temp_reloadFlag"] = "1";
            lua_upload.query_enclosure_pic(QueryEnclosureArg);
        end;

        --清空输入
        changeProperty("do_operate_input_textarea","value","");
        --渲染弹窗并显示
        local RenderArg = {
            title="转办回复",
            inputhold="请输入",
            inputmax="50",
            btntext="确定",
            btnfun="lua_jjbx.answerTransfer()",
            showUploadButton=yxscFlagAnswer,
            uploadBtnFun="jjbx_answerTransfer_upload()"
        };

        do_render_input_alert_window(RenderArg);
        show_do_operate_window("do_operate_bg_div");
        close_loading();
    end;
end;

--[[转办回复]]
function lua_jjbx.answerTransfer(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local msg = getValue("do_operate_input_textarea");
        if msg == "" then
            alert("请输入转办回复内容");
            return;
        end;
        invoke_trancode_noloading(
            "jjbx_process_query",
            "process_bill",
            {
                BusinessType="bill_index",
                TranCode="answerTransferMsg",
                billNo=globalTable["billNo_djzb"],
                msg=msg
            },
            lua_jjbx.answerTransfer,
            {}
        );
    else
        local responseBody = json2table(ResParams["responseBody"]);
        if responseBody["errorNo"] == "000000" then
            --确认回复后，清空标志为转办回复的缓存变量
            globalTable["temp_reloadFlag"] = "";
            close_do_operate_window("do_operate_bg_div");
            --初始化函数名
            local InitCallFuncName = vt("InitCallFuncName",globalTable,"init");
            globalTable["InitCallFuncName"] = "";
            alertToast("0",C_Toast_SuccessedMsg,"",InitCallFuncName,"");
        else
            alert(responseBody["errorMsg"]);
        end;
    end;
end;

--[[获取最新转办内容]]
function getTransferMsg(processList)
    for i=1,#processList do
        if processList[i]["status"] == "turn" then
            local msg = processList[i]["opinion"];
            return msg;
        end;
    end;
    return "";
end;

--[[获取跳转至京东采购的链接]]
function lua_jjbx.getJdTrustedLoginUrl(ResParams,ReqParams)
    local PCConfigListsTable = vt("PCConfigListsTable",globalTable);
    --debug_alert(foreach_arg2print(PCConfigListsTable));
    local cgSwitch = vt("SYS0017",PCConfigListsTable);
    --cgSwitch = "是";

    --采购开关开启或用户为被共享账户时
    if cgSwitch=="是" or globalTable["userType"]=="2" then
        if formatNull(ResParams) == "" then
            local ReqParams = formatNull(ReqParams);
            ReqParams["TranCode"] = "getJdTrustedLoginUrl";
            invoke_trancode(
                "jjbx_service",
                "online_shopping",
                ReqParams,
                lua_jjbx.getJdTrustedLoginUrl,
                {}
            );
        else
            local responseBody = json2table(ResParams["responseBody"]);
            if responseBody["errorNo"] == "000000" then
                if responseBody["url"] == "" then
                    alert("当前用户暂无权限");
                else
                    globalTable["webview_url"] = responseBody["url"];
                    globalTable["webview_page_title"] = "京东采购";
                    globalTable["webview_back2jjbx"] = "返回极简";
                    invoke_page("jjbx_page/xhtml/webview_page.xhtml",page_callback,nil);
                end;
            else
                alert(responseBody["errorMsg"]);
            end;
        end;
    else
        alert("系统升级中，暂不支持使用");
    end;
end;

function lua_jjbx.alert_zdy()
    local title = formatNull(globalTable["zdy2Title"]);
    local content = formatNull(globalTable["zdy2_value"]);
    if content ~= "" then
        if ryt:getLengthByStr(content) > 12 then
            alert_confirm(title,content,"","确定","");
        end;
    end;
end;

function lua_jjbx.alert_zdy2(title,content,cutNum,flag)
    local title = formatNull(title);
    local content = formatNull(content);
    if content ~= "" then
        if flag == "1" then
            if ryt:getLengthByStr(content) > cutNum then
                alert_confirm(title,content,"","确定","");
            end;
        else
            if ryt:getLengthByStr(title.."："..content) > cutNum then
                alert_confirm(title,content,"","确定","");
            end;
        end;
    end;
end;

function lua_jjbx.getZdy2TitleByConfig(queryConfig)
    for i=1,#queryConfig do
        if queryConfig[i]["modelType"] == "2" and queryConfig[i]["fieldName"] == "zdy2" then
            globalTable["zdy2Title"] = queryConfig[i]["fieldDispName"];
            globalTable["zdy2Display"] = queryConfig[i]["fieldVisible"];
            return;
        end;
    end;
end;

--[[获取查询单据配置时的状态]]
function lua_jjbx.getPageType()
    if globalTable["pageType"] == "approve" or vt("ifApproverEdit",globalTable) == "true" then
        --[[审批人查看]]
        return "3";
    elseif globalTable["pageType"] == "look" then
        --[[制单人查看]]
        return "1";
    else
        --[[新增、编辑]]
        return "2";
    end;
end;

--[[重置配置参数]]
function lua_jjbx.reset_config_arg(ResetArgName)
    --分页查询参数
    if ResetArgName == "JJBX_AppPageListQryArg" then
        --查询页码
        JJBX_AppPageListQryArg.AppQryPageNum=1;
        --每页查询记录数
        JJBX_AppPageListQryArg.AppQryPageSize=10;
        --客户端最后一次查看的列表下标，用于返回时候页面数据查询
        JJBX_AppPageListQryArg.ClientLastItemIndex=1;
        --已经加载的数据量
        JJBX_AppPageListQryArg.LoadedCounts=0;
        --是否初始化查询
        JJBX_AppPageListQryArg.ReloadAppQryPage="true"
    end;
end;

--[[PC参数设置和获取]]
function lua_jjbx.pc_cache_arg_ctrl(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams);
        --回调方法
        local CtrlCallBackFunc = vt("CtrlCallBackFunc",ReqParams);
        ReqParams["TranCode"] = "PcCacheArgCtrl";

        invoke_trancode(
            "jjbx_service",
            "app_service",
            ReqParams,
            lua_jjbx.pc_cache_arg_ctrl,
            {
                CtrlCallBackFunc=CtrlCallBackFunc
            },
            all_callback,
            {CloseLoading="false"}
        );
    else
        --自定义回调
        local CtrlCallBackFunc = vt("CtrlCallBackFunc",ResParams);

        --响应报文
        local res = json2table(ResParams["responseBody"]);
        local value = vt("value",res);

        --回调
        lua_system.do_function(CtrlCallBackFunc,{ArgValue=value});
    end;
end;

--[[用户功能权限匹配]]
function lua_jjbx.user_fun_match(MatchArg)
    local MatchArg = formatNull(MatchArg);
    local FunCode = vt("FunCode",MatchArg);
    local MatchRes = {};

    if FunCode ~= "" then
        local viewauthority = vt("viewauthority",companyTable);
        local FunCounts = #viewauthority;
        local Matched = "false";
        for i=1, FunCounts do
            if FunCode == viewauthority[i] then
                Matched = "true";
                break
            end;
        end;

        MatchRes["Matched"] = Matched;
    end;

    return MatchRes;
end;

--[[通用请求]]
function lua_jjbx.common_req(ReqParams)
    local ReqParams = formatNull(ReqParams);
    --请求接口
    ReqParams["TranCode"] = "CommonInterfaceReq";
    --业务回调
    local BusinessCall = vt("BusinessCall",ReqParams);
    ReqParams.BusinessCall = "";
    --业务参数
    local BusinessParams = vt("BusinessParams",ReqParams);
    --业务参数编码方式
    local BusinessParamsEncodeType = vt("BusinessParamsEncodeType",ReqParams);
    if BusinessParamsEncodeType == "base64" then
        --Base64编码
        ReqParams["BusinessParams"] = lua_format.base64_encode(BusinessParams);
    elseif BusinessParamsEncodeType == "url" then
        --Url编码
        ReqParams["BusinessParams"] = lua_format.url_encode(BusinessParams);
    else
        --原参数
    end;
    --默认不主动关闭loading
    local CloseLoading = vt("CloseLoading",ReqParams,"false");
    ReqParams.CloseLoading = "";
    --可以在外层指定请求方法
    local ReqFuncName = vt("ReqFuncName",ReqParams,"invoke_trancode_donot_checkRepeat");
    ReqParams.ReqFuncName = "";

    local ReqUrlExplain = vt("ReqUrlExplain",ReqParams);
    local ReqAddr = vt("ReqAddr",ReqParams);
    if ReqUrlExplain == "" then
        debug_alert("通用请求未对接口（"..ReqAddr.."）进行说明");
    end;

    local dofunction = lua_format.str2fun(ReqFuncName);
    if dofunction then
        dofunction(
            "jjbx_service",
            "app_service",
            ReqParams,
            BusinessCall,
            {
                ResCallFunc=vt("ResCallFunc",ReqParams),
                ArgStr=vt("ArgStr",ReqParams)
            },
            all_callback,
            {CloseLoading=CloseLoading}
        );
    else
        debug_alert("请求函数未定义，函数名"..funName);
    end;
end;

--[[通用日志记录注册]]
function lua_jjbx.common_log_register(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams);
        --请求接口
        ReqParams["TranCode"] = "CommonLogRegister";
        invoke_trancode_noloading(
            "jjbx_service",
            "app_service",
            ReqParams,
            lua_jjbx.common_log_register,
            {}
        );
    else
        --debug_alert("通用日志记录注册完成");
    end;
end;

--[[首页底部按钮渲染]]
function lua_jjbx.render_jjbx_banner(BannerIndex)
    local BannerIndex = formatNull(BannerIndex,1);
    local Banner1Html = "";
    local Banner2Html = "";
    --我的页面banner的gif播放状态
    local homeGifFlag = vt("homeGifFlag",globalTable,"false");
    --首页页面banner的gif播放状态
    local myselfGifFlag = vt("myselfGifFlag",globalTable,"false");
    local Banner1ClickFun = "";
    local Banner2ClickFun = "";

    --[[debug_alert(
        "homeGifFlag : "..homeGifFlag.."\n"..
        "myselfGifFlag : "..myselfGifFlag.."\n"..
        ""
    );]]

    if BannerIndex == 1 then
        if configTable["lua_debug"] == "true" then
            --调试开启时候当前页面支持刷新
            Banner1ClickFun = "lua_jjbx.banner_switch(1)";
        end;
        Banner2ClickFun = "lua_jjbx.banner_switch(2)";

        local Banner1ImgHtml = "";
        if homeGifFlag == "false" then
            Banner1ImgHtml = [[
                <jsonGIFView src="homedata" loop="no" loopCount="1" class="home_icon" height="28" width="28" onclick="]]..Banner1ClickFun..[[" />
            ]];
        else
            Banner1ImgHtml = [[
                <img src="ico_home_red.png" class="home_icon" onclick="]]..Banner1ClickFun..[[" />
            ]];
        end
        Banner1Html = [[
            <div class="home_button_div" name="home_button_div" border="0" onclick="]]..Banner1ClickFun..[[">
                ]]..Banner1ImgHtml..[[
                <label class="home_btn_selected_label" value="首页" name="home" onclick="]]..Banner1ClickFun..[["></label>
            </div>
        ]];
        Banner2Html = [[
            <div class="myself_button_div" border="0" onclick="]]..Banner2ClickFun..[[">
                <img src="ico_mine.png" class="home_icon" onclick="]]..Banner2ClickFun..[[" />
                <label class="home_btn_label" value="我的" name="myself" onclick="]]..Banner2ClickFun..[[" />
            </div>
        ]];

        --更新首页页面banner的gif播放状态
        globalTable["homeGifFlag"] = "true";
    else
        Banner1ClickFun = "lua_jjbx.banner_switch(1)";
        if configTable["lua_debug"] == "true" then
            --调试开启时候当前页面支持刷新
            Banner2ClickFun = "lua_jjbx.banner_switch(2)";
        end;

        Banner1Html = [[
            <div class="home_button_div" name="home_button_div" border="0" onclick="]]..Banner1ClickFun..[[">
                <img src="ico_home.png" class="home_icon" onclick="]]..Banner1ClickFun..[[" />
                <label class="home_btn_label" value="首页" name="home" onclick="]]..Banner1ClickFun..[[" />
            </div>
        ]];
        local Banner2ImgHtml = "";
        if myselfGifFlag == "false" then
            Banner2ImgHtml = [[
                <jsonGIFView src="minedata" loop="no" loopCount="1" class="home_icon" height="28" width="28" onclick="]]..Banner2ClickFun..[[" />
            ]];
        else
            Banner2ImgHtml = [[
                <img src="ico_mine_red.png" class="home_icon" onclick="]]..Banner2ClickFun..[[" />
            ]];
        end
        Banner2Html = [[
            <div class="myself_button_div" border="0" onclick="]]..Banner2ClickFun..[[">
                ]]..Banner2ImgHtml..[[
                <label class="home_btn_selected_label" value="我的" name="myself" onclick="]]..Banner2ClickFun..[[" />
            </div>
        ]];

        --更新我的页面banner的gif播放状态
        globalTable["myselfGifFlag"] = "true";
    end;

    local BannerHtml = [[
        <div class="bottom_button_div" border="0" name="bottom_button_div">
            ]]..Banner1Html..[[
            <div class="line_bottom_icon_div" border="0">
                <img src="local:line_bottom.png" class="line_bottom_icon" />
            </div>
            ]]..Banner2Html..[[
        </div>
    ]];
    document:getElementsByName("bottom_button_div")[1]:setInnerHTML(BannerHtml);
    page_reload();
end;

--[[banner切换]]
function lua_jjbx.banner_switch(BannerIndex)
    if BannerIndex == 2 then
        globalTable["homeGifFlag"] = "false";
        local PageUrl = "jjbx_myInfo/xhtml/myInfo.xhtml";
        --只有第一次加载的时候有loading
        if globalTable["MyinfoHeadFinish"] ~= "true" then
            invoke_page(PageUrl,page_callback,{CloseLoading="false"});
        else
            invoke_page_noloading_checkRepeat(PageUrl,page_callback,nil);
        end;
    else
        globalTable["myselfGifFlag"] = "false";
        lua_menu.to_index_page("back");
    end;
end;

--[[拨打客服电话]]
function lua_jjbx.call_service(Type)
    if Type == "1" then
        tel_call(JJBX_COMPANY_INFO.service_number);
    elseif Type == "2" then
        mail_call(JJBX_COMPANY_INFO.service_mail)
    else

    end;
end;

--[[查询是否允许添加他行卡]]
function lua_jjbx.allow_add_other_bank_card(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams);
        ReqParams["ReqAddr"] = "uap/psn/getAddNoCzFlag";
        ReqParams.BusinessCall = lua_jjbx.allow_add_other_bank_card;
        local ResCallFunc = vt("ResCallFunc",ReqParams);
        if ResCallFunc == "" then
            debug_alert("查询是否允许添加他行卡回调未指定");
        else
            --debug_alert("查询是否允许添加他行卡参数"..foreach_arg2print(json2table(vt("BusinessParams",ReqParams))));
            lua_jjbx.common_req(ReqParams);
        end;
    else
        local res = json2table(ResParams["responseBody"]);
        local addNoCzFlag = vt("addNoCzFlag",res);
        local AllowAddOtherBankCard = "0";
        if addNoCzFlag == "是" then
            AllowAddOtherBankCard = "1";
        end;
        local ResCallFunc = vt("ResCallFunc",ResParams);
        --debug_alert("查询是否允许添加他行卡调用回调 ResCallFunc: "..ResCallFunc);
        lua_system.do_function(ResCallFunc,{AllowAddOtherBankCard=AllowAddOtherBankCard});
    end;
end;

--[[查询城市]]
function lua_jjbx.qry_city(ResParams,ReqParams)
    local cityList = vt("cityList",globalTable);
    if cityList == "" then
        lua_jjbx.do_qry_city(ResParams,ReqParams);
    else
        --回调方法
        local ResCallFunc = vt("ResCallFunc",ReqParams);
        lua_system.do_function(ResCallFunc);
    end;
end;

function lua_jjbx.do_qry_city(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        --debug_alert("查询城市列表");
        local ReqParams = formatNull(ReqParams,{});
        invoke_trancode_donot_checkRepeat(
            "jjbx_process_query",
            "process_bill",
            {
                BusinessType="travel_process_bill",
                TranCode="Cityquery"
            },
            lua_jjbx.do_qry_city,
            {
                --回调方法
                ResCallFunc=vt("ResCallFunc",ReqParams)
            },
            all_callback,
            {CloseLoading="false"}
        );
    else
        local res = json2table(ResParams["responseBody"]);
        if res["errorNo"] == "000000" then
            --debug_alert("城市列表存缓存");
            globalTable["cityList"] = vt("list",res);
        else
            alert(res["errorMsg"]);
        end;
        local ResCallFunc = vt("ResCallFunc",ResParams);
        lua_system.do_function(ResCallFunc);
    end;
end;

--[[获取发票元素名称]]
function lua_jjbx.get_invoice_tag_name(Code)
    local res = {};
    for i=1,#JJBX_InvoiceContentList do
        local ItemData = formatNull(JJBX_InvoiceContentList[i]);
        local codeC = vt("code",ItemData);
        if Code == codeC then
            res = ItemData;
            break
        end;
    end;
    return res;
end;

--[[截取字符串]]
function lua_jjbx.split_str(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        invoke_trancode_donot_checkRepeat(
            "jjbx_service",
            "app_service",
            {
                TranCode="strSplit",
                str = ReqParams["str"]
            },
            lua_jjbx.split_str,
            {callFunName=vt("callFunName",ReqParams)},
            all_callback,
            {CloseLoading="false"}
        );
    else
        close_loading();
        local res = json2table(ResParams["responseBody"]);
        --debug_alert("响应\n"..foreach_arg2print(res));

        local callFunName = ResParams["callFunName"];
        local callFunArg = res["list"];

        --执行回调
        if callFunName ~= "" then
            lua_system.do_function(callFunName,callFunArg);
        end;
    end;
end;