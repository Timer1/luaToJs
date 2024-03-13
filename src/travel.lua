--[[商旅相关lua]]
lua_travel = {};

--[[商旅参数初始化]]
function lua_travel.arg_init_qry(ResParams,ReqParams)
    --系统参数查询
    if formatNull(ResParams) == "" then
        --商旅（项目档案）
        local travelXmdaData = vt("travelXmdaData",companyTable);

        --为空时查询
        local argListTable = {
            travelXmdaData
        };
        local checkArgRes = lua_form.arglist_check_empty(argListTable);
        --debug_alert(checkArgRes);

        local ReqParams = formatNull(ReqParams);
        local InitCallFun = vt("InitCallFun",ReqParams);
        if checkArgRes == "true" then
            --debug_alert("商旅参数已初始化");

            lua_system.do_function(InitCallFun,"");
        else
            --debug_alert("商旅参数初始化-请求");

            ReqParams["BusinessType"]="apply_travel";
            ReqParams["TranCode"]="ArgInitQry";
            invoke_trancode_donot_checkRepeat(
                "jjbx_service",
                "travel_service",
                ReqParams,
                lua_travel.arg_init_qry,
                {},
                all_callback,
                {CloseLoading="false"}
            );
        end;
    else
        --debug_alert("商旅参数初始化-响应");

        --记录初始化标志
        companyTable["TravelServiceArgInitStatus"] = "true";

        local res = json2table(ResParams["responseBody"]);

        --存储商旅项目档案列表
        if res["TravelXmdaErrorNo"] == "000000" then
            local travelXmdaData = vt("TravelXmdaData",res);
            --debug_alert("商旅项目档案列表\n"..foreach_arg2print(travelXmdaData));
            
            if travelXmdaData == "" then
                --alert("没有查询到商旅场景信息");
            else
                --项目档案数据存缓存
                companyTable["travelXmdaData"] = travelXmdaData;
            end;
        else
            --alert(res["TravelXmdaErrorMsg"]);
        end;

        --参数初始化完成回调
        local InitCallFun = vt("InitCallFun",res);
        lua_system.do_function(InitCallFun,"");
    end;
end;

--[[渲染行程申请行程类型]]
function lua_travel.render_travel_style()
    --行程类型数据
    local tripTypeList = vt("tripTypeList",globalTable);
    if tripTypeList ~= "" then
        --行程类型条目数
        local tripTypeListCounts = #tripTypeList;
        --debug_alert(tripTypeListCounts);

        --业务场景存在时创建
        if tripTypeListCounts > 0 then
            local selectEleArg = {};
            for key,value in pairs(tripTypeList) do
                local selectEleArgItem = {
                    --显示文字
                    labelName=vt("contentname",value),
                    --点击函数
                    clickFunc="lua_travel.travel_select_xclx",
                    --点击函数入参
                    clickFuncArg=tostring(key)
                };
                table.insert(selectEleArg,selectEleArgItem);
            end;

            --渲染select页面
            local renderSelectArg = {
                bgName="xclx_page",
                topEleName="top_xclx_div",
                topTitleName="选择行程类型",
                selectEleName="xclx_content",
                selectEleArg=selectEleArg,
                renderCallBackFun="lua_travel.render_select_xclx_page_call"
            };
            --debug_alert("渲染select页面\n"..foreach_arg2print(renderSelectArg));
            lua_page.render_select_page(renderSelectArg);

            --是否有选择过行程类型
            local TravelSelectXclxCacheArg = vt("TravelSelectXclxCacheArg",globalTable);
            if TravelSelectXclxCacheArg ~= "" then
                --更新业务场景选中效果
                if vt("matchTripTypeIndex",TravelSelectXclxCacheArg) ~= "" then
                    lua_page.set_item_selected(vt("matchSetXclxSelectArg",TravelSelectXclxCacheArg));
                end;
            end;
        end;
        close_loading();
    else
        alert("查询行程类型失败");
    end;
end;

--[[渲染行程申请行程类型回调]]
function lua_travel.render_select_xclx_page_call(Arg)
    --debug_alert("lua_travel.render_select_xclx_page_call\n"..foreach_arg2print(Arg));
    --无操作
end;

--[[选择行程类型]]
function lua_travel.travel_select_xclx(index)
    local tripTypeList = vt("tripTypeList",globalTable);
    local tripTypeListCounts = #tripTypeList;
    local selectXclx = formatNull(tripTypeList[tonumber(index)]);

    local selectXclxContentcode = vt("contentcode",selectXclx);
    local selectXclxContentname = vt("contentname",selectXclx);
    local selectXclxFlag = vt("flag",selectXclx);
    local LastSelectContentcode = vt("contentcode",globalTable);

    --[[debug_alert(
        "选择行程类型\n"..
        "当前点击下标 : "..index.."\n"..
        "当前参数包"..foreach_arg2print(selectXclx).."\n"..
        "前次保存的Code : "..LastSelectContentcode.."\n"..
        ""
    );]]

    if selectXclxContentcode == LastSelectContentcode then
        --未变更的情况下不处理，关闭行程类型选择界面
        lua_page.div_page_ctrl();
    else
        --匹配已经选择的行程
        local matchTripTypeIndex = lua_utils.table_data_match(tripTypeList,"contentcode",selectXclxContentcode);

        --[[debug_alert(
            "选择行程类型\n"..
            "contentcode : "..selectXclxContentcode.."\n"..
            "contentname : "..selectXclxContentname.."\n"..
            "flag : "..selectXclxFlag.."\n"..
            "travelApplyYdjlInit : "..globalTable["travelApplyYdjlInit"].."\n"..
            "index : "..index.."\n"..
            "matchTripTypeIndex : "..matchTripTypeIndex.."\n"..
            ""
        );]]

        --保存选择的数据
        globalTable["TravelSelectXclxCacheArg"] = {
            selectXclxContentcode = selectXclxContentcode,
            selectXclxContentname = selectXclxContentname,
            selectXclxFlag = selectXclxFlag,
            matchTripTypeIndex = matchTripTypeIndex,
            matchSetXclxSelectArg = {
                showIndex=matchTripTypeIndex
            };
        };

        local selectAlertMsg = "";
        if #formatNull(globalTable["xcmxList"])==0 or formatNull(globalTable["typechoose"])=="" then
            --客户没有填写行程明细的情况下，第一次选择行程类型，提示
            selectAlertMsg = "请确认已正确选择，如后续返回修改，将会清空已填写的行程明细信息。";
        else
            --客户填写了行程明细后切换行程类型
            selectAlertMsg = "如行程类型修改，已填写行程明细信息将清空，请确认是否修改。";
        end;
        alert_confirm("",selectAlertMsg,"取消","确定","lua_travel.select_xclx_call");
    end;
end;

function lua_travel.checkParam(ResParams,ReqParams)
    if ResParams == "" then
        ReqParams["ReqAddr"] = "btTripApl/checkParam";
        ReqParams["ReqUrlExplain"] = "行程申请单提交前的参数校验";
        ReqParams["BusinessCall"] = lua_travel.checkParam;
        local checkParam_params = {
            appno=globalTable["XCSQbillNo"],
            flag = "1"
        };
        ReqParams["BusinessParams"] = table2json(checkParam_params);
        lua_jjbx.common_req(ReqParams);
    else
        local res = json2table(ResParams["responseBody"]);
        if vt("strParam",res) ~= "" then
            alert_confirm("温馨提示",res["strParam"],"取消","确认","confirmCheckParam");
        else
            travel_apply_send('submit');
        end;
    end;
end;

function confirmCheckParam(index)
    if index == 1 then
        travel_apply_send('submit');
    end;
end;

--[[执行行程申请单提交]]
function lua_travel.do_travel_apply_send(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        --debug_alert("执行行程申请单提交-请求");

        local ReqParams = formatNull(ReqParams);
        ReqParams["BusinessType"] = "apply_travel";
        ReqParams["TranCode"] = "TravelapplySaveApplicationA";
        --debug_alert("执行行程申请单提交参数"..foreach_arg2print(JJBX_BillApplyCdrParams));

        invoke_trancode_donot_checkRepeat(
            "jjbx_service",
            "travel_service",
            ReqParams,
            lua_travel.do_travel_apply_send,
            {checkParam=vt("checkParam",ReqParams,"false")},
            all_callback,
            {CloseLoading="false"}
        );
    else
        --debug_alert("执行行程申请单提交-响应");

        local res = json2table(ResParams["responseBody"]);
        local errorNo = vt("errorNo",res);
        local errorMsg = vt("errorMsg",res);
        local checkParam = ResParams["checkParam"];
        if errorNo == "000000" then
            local submitFlag = vt("submitFlag",res);
            local submitErrorNo = vt("submitErrorNo",res);
            local submitErrorMsg = vt("submitErrorMsg",res);

            if submitFlag == "save" then
                --是否新建提交，新建提交的申请单需先保存后再调用查验
                if checkParam ~= "true" then
                    alertToast0(C_SavedMsg);
                else
                    lua_travel.checkParam("",{});
                end;
            else
                if submitErrorNo == "000000" then
                    if vt("resultMessage",res) ~= "" then
                        alert(res["resultMessage"]);
                    end;
                    invoke_page("jjbx_travel_service/xhtml/travel_service_applySuccess.xhtml",page_callback,nil);
                elseif submitErrorNo == "300229" then
                    alert(submitErrorMsg);
                    invoke_page("jjbx_travel_service/xhtml/travel_service_applySuccess.xhtml",page_callback,nil);
                else
                    alert(submitErrorMsg);
                end;
            end;
        else
            alert(errorMsg);
        end;
    end;
end;

--[[前往行程明细页面]]
function lua_travel.to_add_xcmx_page()
    invoke_page("jjbx_travel_service/xhtml/travel_service_xcmx.xhtml",page_callback,{CloseLoading="false"});
end;

--[[执行单条行程明细删除]]
function lua_travel.do_delete_xcmx(ResParams)
    if formatNull(ResParams) == "" then
        invoke_trancode_donot_checkRepeat(
            "jjbx_service",
            "travel_service",
            {
                TranCode="TravelapplyDeleteDetail",
                BusinessType="apply_travel",
                tripappno=globalTable["XCSQbillNo"],
                pktripApplicationB=globalTable["pk_delete_B"],
                flag="0"
            },
            lua_travel.do_delete_xcmx,
            {}
        );
    else
        local res = json2table(ResParams["responseBody"]);
        if res["errorNo"] == "000000" then
            lua_travel.load_xcmx_list(ResParams);
        else
            alert(res["errorMsg"]);
        end;
        close_loading();
    end;
end;

--[[删除全部行程明细]]
function lua_travel.do_delete_all_xcmx(ResParams)
    if formatNull(ResParams) == "" then
        invoke_trancode(
            "jjbx_service",
            "travel_service",
            {
                TranCode="TravelapplyDeleteDetail",
                BusinessType="apply_travel",
                tripappno=globalTable["XCSQbillNo"],
                flag="1",
                pkCorp=globalTable["selectOrgList"][1]["pkCorp"],
                deptCode=globalTable["XCSQ_responseBody"]["deptcode"],
                tripTypeCode=globalTable["contentcode"]
            },
            lua_travel.do_delete_all_xcmx,
            {},
            all_callback,
            {CloseLoading="true"}
        );
    else
        local res = json2table(ResParams["responseBody"]);
        if res["errorNo"] == "000000" then
            --行程类型回显
            changeProperty("xclx","value",globalTable["contentname"]);
            changeStyle("xclx","color","#4A4A4A");
            --已有行程明细修改行程类型重新加载页面
            lua_travel.load_xcmx_list(ResParams);
        else
            alert(res["errorMsg"]);
        end;
    end;
end;

--[[加载行程明细列表数据]]
function lua_travel.load_xcmx_list(ResParams)
    local res = json2table(ResParams["responseBody"]);
    --debug_alert("加载行程明细列表数据\n"..foreach_arg2print(res));

    if res["errorNo"] == "000000" then
        globalTable["responseBody"] = res;
        globalTable["annexaddr"] = res["annexaddr"];
        local xcmxList = {}; 
        local list = formatNull(res["list"],{});

        if #list > 0 then
            for key,value in pairs(list) do
                local xcmx ={
                    pkTripapplicationB=value["pkTripapplicationB"],
                    tripappno=value["tripappno"],
                    pkTripapplication=value["pkTripapplication"],
                    costundertaker=value["costundertaker"],
                    departuredate=value["departuredate"],
                    arrivaldate=value["arrivaldate"],
                    departurecity=value["departurecity"],
                    arrivalcity=value["arrivalcity"],
                    transportation=value["transportation"],
                    roomno=value["roomno"],
                    roomnight=value["roomnight"],
                    passenger=value["passenger"],
                    tripRule=value["tripRule"],
                    expenditureProject=value["expenditureProject"],
                    expenditureProjectCode=value["expenditureProjectCode"],
                    travelerList={}
                };
                if vt("tripRule",value) == "" then
                    xcmx.tripRule = "";
                end;
                if vt("expenditureProject",value) == "" then
                    xcmx.expenditureProject = "";
                end;
                if vt("expenditureProjectCode",value) == "" then
                    xcmx.expenditureProjectCode = "";
                end;

                if vt("passenger",value) == "" then
                    local travelerList = {};
                    --[[出行人临时变量]]
                    local temp = "";
                    local flag = "false";
                    for key1,value1 in pairs(value["travelers"]) do
                        local traveler ={ 
                            employeeName=value1["travelername"],
                            workid=value1["travelercode"],
                            pkpsndoc=value1["pkPsndoc"],
                            pkCorp=value1["pkCorp"],
                            pkDept=value1["pkDept"],
                            corpCode=value1["corpCode"],
                            corpName=value1["corpName"],
                            deptCode=value1["deptCode"],
                            deptName=value1["deptName"],
                            borrowflag=value1["borrowflag"]
                        };
                        table.insert(travelerList,traveler);
                        --姓名拼接
                        temp = temp..value1["travelername"].."、";
                    end;
                    xcmx.travelerList = travelerList;
                    --删除最后一个"、"
                    xcmx.passenger = ryt:getSubstringValue(temp,0,ryt:getLengthByStr(temp)-1);
                end;
                table.insert(xcmxList,xcmx);
            end;
        end;

        globalTable["xcmxList"] = xcmxList;
        
        --渲染行程明细列表界面
        lua_travel.render_xcmx_list();
    else
        alert(res["errorMsg"]);
    end;
end;

--[[渲染行程明细列表界面]]
function lua_travel.render_xcmx_list()
    local xcmxList = formatNull(globalTable["xcmxList"],{});
    local xcmxListCounts = #xcmxList;
    --debug_alert("渲染行程明细列表界面，条目数 : "..tostring(xcmxListCounts));

    local htmlOption = "";
    if xcmxListCounts > 0 then 
        changeStyle("add_xcmx","display","none");
        changeStyle("travel_list","display","block");
        for key,value in pairs(xcmxList) do
            local arrowStyle = "arrow_android_css";
            if platform == "iPhone OS" then
                arrowStyle = "arrow_ios_css";
            end;
            htmlOption = htmlOption..[[
                <horiTableViewControl class="xcmx_delete" width='355' divwidth='355' divheight='210' divwidth2='42' value='0'>
                    <div class="blank200_css" border="1" onclick="jjbx_edit_xcmx(]]..key..[[)">
                        <div class="blank40_css1" border="1"  onclick="jjbx_edit_xcmx(]]..key..[[)">
                            <label class="blank40_title" value="行程]]..lua_format.an2cn(key)..[["></label>
                            <label class="xcqx" value="]]..formatdate(1,value['departuredate']).." — "..formatdate(1,value['arrivaldate'])..[["></label>
                            <img src="local:arrow_common.png" class="]]..arrowStyle..[[" />
                        </div>
                        <line class="line_css" />
                        <div class="blank70_css"  onclick="jjbx_edit_xcmx(]]..key..[[)">
                            <div class="height15" border="0"></div>
                            <img src="local:sl_ico_13.png" class="sl_ico2" />
                            <label class="blank18_css1" value="]]..cutStr(value['departurecity'],17).." — "..cutStr(value['arrivalcity'],17)..[["></label>
                            <img src="local:sl_ico_14.png" class="sl_ico1" />
                            <label class="blank18_css2" value="]]..cutStr(value['passenger'],20)..[["></label>
                            <img src="local:sl_ico_15.png" class="sl_ico3" />
                            <label class="blank18_css3" value="]]..cutStr(value['transportation'],20)..[["></label>
                            <div class="cl_rule" border="0" onclick="jjbx_edit_xcmx(]]..key..[[)">
                                <label class="card_ruleTitle">差旅标准：</label>
                                <label class="card_ruleDetail_hotel">]].."酒店—"..cutStr(value['expenditureProject'],30)..[[</label>
                                <label class="card_ruleDetail_transport">]].."交通—"..cutStr(value['expenditureProjectCode'],47)..[[</label>
                            </div>
                        </div>
                    </div>

                    <div class="divRight_css" border="1" name="divRight" onclick="lua_travel.delete_xcmx_confirm(]]..key..[[)">
                        <label class="delete_msg">删除</label>
                    </div>
                </horiTableViewControl>
                <div class="space_10_div" border="0"/>
            ]];

            if key==xcmxListCounts and xcmxListCounts<5 then
                htmlOption = htmlOption..[[
                    <div class="jk_msg_none" name='add_jk' border="1" onclick="add_xcmx()">
                        <img class="add_img" src="local:sl_ico_add.png" onclick="add_xcmx()" />
                        <label class="center_label" onclick="add_xcmx()">添加行程明细</label>
                    </div>
                ]];
            end;
        end;
    else
        changeStyle("add_xcmx","display","block");
        changeStyle("travel_list","display","none");
    end;

    local htmlContent = [[
        <div class="contentDiv_css" name="travel_list" border="0">
        ]]..htmlOption..[[
        </div>
    ]];
    document:getElementsByName("travel_list")[1]:setInnerHTML(htmlContent);
    page_reload();
    close_loading();
end;

--[[删除行程明细(单条)-提醒]]
function lua_travel.delete_xcmx_confirm(index)
    globalTable["pk_delete_B"]= globalTable["xcmxList"][tonumber(index)].pkTripapplicationB;
    alert_confirm("","当前操作会将该条已添加的行程明细删除,请谨慎操作!","取消","确定","lua_travel.delete_xcmx_button_call");
end;

--[[删除行程明细(单条)]]
function lua_travel.delete_xcmx_button_call(index)
    if tostring(index) == "1" then
        --执行单条行程明细删除
        lua_travel.do_delete_xcmx();
    end;
end;

--[[清理商旅页面缓存]]
function lua_travel.clear_travel_page_cache(flag)
    if flag == "add_travel_apply" then
        --新建行程申请单
        globalTable["XCSQbillNo"] = "";
        globalTable["ts_xclx"] = "";
        globalTable["pktripApplicationB"] = "";
        globalTable["photoNum"] = "";
        globalTable["sy"] = "";
        globalTable["zdy"] = "";
        globalTable["pka"] = "";
        globalTable["xmdaName"] = "";
        globalTable["employeeInfoList"] = {};
        globalTable["usercode"] = nil;
        globalTable["endCity"] = nil;
        globalTable["startCity"] = nil;
        globalTable["select_typechoose"] = nil;
        globalTable["cdf"] = nil;
        globalTable["servicetype"] = nil;
        globalTable["serviceTypeCode"] = nil;
        globalTable["startDate"] = nil;
        globalTable["endDate"] = nil;
        globalTable["roomno"] = nil;
        globalTable["roomnight"] = nil;
        globalTable["tranList"] = {};
        globalTable["budget"] = "";
        globalTable["typechoose"] = nil;
        globalTable["fjzs"] = nil;
        globalTable["uploadFlag"] = nil;
        globalTable["XCSQ_responseBody"] = nil;
        globalTable["pageConfig"] = nil;
        globalTable["tripTypeList"] = nil;
        globalTable["xcsq_deptcode"] = nil;
        globalTable["oid"] = nil;
        globalTable["isFkEm"] = nil;
        globalTable["contentname"] = nil;
        globalTable["contentcode"] = nil;
        globalTable["triptypeName"]  = nil;
        globalTable["xcmx"] = nil;
        globalTable["changePage"] = nil;
    elseif flag == "edit_travel_apply" then
        --编辑/查看行程申请单
        globalTable["XCSQbillNo"] = "";
        globalTable["xclx"] = "";
        globalTable["ts_xclx"] = "";
        globalTable["firstPage"] = "";
        globalTable["pktripApplicationB"] = "";
        globalTable["photoNum"] = "";
        globalTable["sy"] = "";
        globalTable["zdy"] = "";
        globalTable["pka"] = "";
        globalTable["xmdaName"] = "";
        globalTable["employeeInfoList"] = {};
        globalTable["usercode"] = nil;
        globalTable["endCity"] = nil;
        globalTable["startCity"] = nil;
        globalTable["select_typechoose"] = nil;
        globalTable["cdf"] = nil;
        globalTable["budget"] = "";
        globalTable["itembm"] = nil;
        globalTable["servicetype"] = nil;
        globalTable["serviceTypeCode"] = nil;
        globalTable["startDate"] = nil;
        globalTable["endDate"] = nil;
        globalTable["roomno"] = nil;
        globalTable["roomnight"] = nil;
        globalTable["tranList"] = nil;
        globalTable["typechoose"] = nil;
        globalTable["fjzs"] = nil;
        globalTable["uploadFlag"] = nil;
        globalTable["XCSQ_responseBody"] = nil;
        globalTable["pageConfig"] = nil;
        globalTable["tripTypeList"] = nil;
        globalTable["oid"] = nil;
        globalTable["isFkEm"] = nil;
        globalTable["contentname"] = nil;
        globalTable["contentcode"] = nil;
        globalTable["triptypeName"]  = nil;
        globalTable["xcmx"] = nil;
        globalTable["sy_new"] = "";
        globalTable["zdy_new"] = "";
        globalTable["xmdaName_new"] = "";
        globalTable["xmdabm_new"] = "";
        globalTable["servicetype_new"]="";
        globalTable["budget_new"] = "";
        globalTable["contentcode_new"] = "";
        globalTable["contentname_new"] = "";
        globalTable["changePage"] = nil;
    else
    end;

    --行程类型选择的缓存
    globalTable["TravelSelectXclxCacheArg"] = nil;
    --是否管控
    globalTable["travelApplyCxrCtrl"] = nil;
    --不管控集合
    globalTable["travelApplyYdjlInit"] = nil;
    --自行承担类型集合
    globalTable["travelApplyCdrUseSelfList"] = nil;
    --承担人是否可修改
    globalTable["travelApplyCdrModify"] = nil;
    --承担人参数列表重置
    lua_format.reset_table(JJBX_BillApplyCdrParams);
    --承担人显示信息清空
    globalTable["travelApplyShowCdrInfo"] = nil;
end;

--[[行程申请单表单校验]]
function lua_travel.apply_form_check()
    --事由
    local sy = getValue("sy");
    --自定义字段
    local zdy = getValue("zdy");
    --行程类型
    local triptypeName = getValue("xclx");
    --预估金额
    local budget = getValue("budget");
    --业务类型
    local servicetype = getValue("servicetype");
    --项目档案
    local xmda = getValue("xmda");
    --承担人
    local cdrDisplay = getStyle("cdr_div","display");
    local cdrName = vt("feeTakerName",JJBX_BillApplyCdrParams);
    --debug_alert(cdrDisplay.." "..cdrName);

    local checkRes = false;
    
    if sy == "" and getValue("sy_required") == "*" then 
        alert("请输入事由");
        checkRes = false;
    elseif getValue("zdy_required") == "*" and (zdy == "" or zdy=="请输入") then
        alert("请输入"..getValue("zdy_title"));
        checkRes = false;
    elseif getValue("xclx_required") == "*" and (triptypeName == "" or triptypeName=="请选择") then
        alert("请输入行程类型");
        checkRes = false;
    elseif cdrDisplay == "block" and cdrName == "" then
        alert("请选择承担人");
        checkRes = false;
    elseif getValue("ywlx_required") == "*" and servicetype == "" then
        alert("请输入业务类型");
        checkRes = false;
    elseif getValue("ygje_required") == "*" and budget == "" then
        alert("请输入"..getValue("ygje_title"));
        checkRes = false;
    elseif getValue("xmda_required") == "*" and (xmda == "" or xmda=="请选择") then
        alert("请输入项目档案");
        checkRes = false;
    elseif tonumber(#globalTable["xcmxList"]) == 0 then
        alert("请添加行程明细");
        checkRes = false;
    else
        checkRes = true;
    end;

    return checkRes;
end;

--[[选择项目档案]]
function lua_travel.select_tarvel_xmda(params)
    --关闭选择项目档案界面
    lua_page.div_page_ctrl();

    local codeAndName = splitUtils(params,",");
    local xmdabm = "";
    local xmdaName = "";
    local listLen = #codeAndName;
    if listLen > 0 then
        for i=1,listLen do
            if i ~= listLen then
                if i == listLen - 1 then
                    xmdabm = codeAndName[i];
                end;
            else
                xmdaName = codeAndName[i];
            end;
        end;
    end;
    xmda.xmdaName = xmdaName;
    xmda.xmdabm = xmdabm;
    changeStyle("xmda","color","#4A4A4A");
    changeProperty("xmda","value",formatNull(xmdaName,"请选择"));
    page_reload();
end;

--[[显示承担人选择界面]]
function lua_travel.show_cdr_select_info()
    --显示的申请人信息
    local travelApplyShowSqrInfo = vt("travelApplyShowSqrInfo",globalTable);
    --显示的承担人信息
    local travelApplyShowCdrInfo = vt("travelApplyShowCdrInfo",globalTable)
    --已经选择的行程类型信息
    local selectXclxContentcode = vt("contentcode",globalTable);
    local selectXclxContentname = vt("contentname",globalTable);
    --申请人为自己的类型列表
    local travelApplyCdrUseSelfList = vt("travelApplyCdrUseSelfList",globalTable);
    --是否自行承担
    local travelApplyCdrModify = "false";
    if selectXclxContentcode ~= "" and string.find(travelApplyCdrUseSelfList, selectXclxContentcode) then
        travelApplyCdrModify = "true";
    end;

    --[[debug_alert(
        "更新承担人选择信息\n"..
        "显示的承担人信息 : "..travelApplyShowCdrInfo.."\n"..
        "已经选择的行程类型信息 : "..selectXclxContentcode.."-"..selectXclxContentname.."\n"..
        "是否允许修改 : "..tostring(travelApplyCdrModify).."\n"..
        "申请人为自己的类型列表 : "..travelApplyCdrUseSelfList.."\n"..
        "参数列表 : "..foreach_arg2print(JJBX_BillApplyCdrParams).."\n"..
        ""
    );]]

    --创建选择承担人界面
    local res = vt("XCSQ_responseBody",globalTable);
    local CreateSearchPeoplePageArg = {
        ShowUser="false",
        DefaultShowCdrWrokId=vt("usercode",res),
        DefaultShowCdrInfo=vt("createUser",res).."　"..vt("deptName",res),
        TitleName="选择承担人"
    };
    lua_page.create_search_people_page(CreateSearchPeoplePageArg);

    if travelApplyCdrModify == "true" then
        --承担方为申请人
        lua_travel.cdr_by_self();
        changeProperty("cdr","value",cutStr(globalTable["travelApplyShowCdrInfo"],21));
        setEleLocation("cdr","right","13");
        changeStyle("cdr","width","300px");
        hide_ele("cdr_arrow_icon");

        --b、当行程类型选择自助福利时，承担人默认为申请人且不可修改
        globalTable["travelApplyCdrModify"] = "false";
    else
        --从自行承担切换为选择承担人，或没有选择过承担人时，不自动回填信息
        if globalTable["travelApplyCdrModify"] == "false" or vt("feeTakerName",JJBX_BillApplyCdrParams) == "" then
            changeProperty("cdr","value","请选择");
            lua_format.reset_table(JJBX_BillApplyCdrParams);
        else
            changeProperty("cdr","value",cutStr(travelApplyShowCdrInfo,19));
        end;

        changeStyle("cdr","width","270px");
        setEleLocation("cdr","right","26");
        show_ele("cdr_arrow_icon");

        --允许修改承担人
        globalTable["travelApplyCdrModify"] = "true";
    end;

    page_reload();
end;

--[[自行承担]]
function lua_travel.cdr_by_self()
    local res = vt("XCSQ_responseBody",globalTable);
    JJBX_BillApplyCdrParams.feeTakerName = vt("createUser",res);
    JJBX_BillApplyCdrParams.feeTakerCode = vt("usercode",res);
    JJBX_BillApplyCdrParams.feeTakerPk = vt("pkuser",res);
    JJBX_BillApplyCdrParams.feeTakerDeptName = vt("deptName",res);
    JJBX_BillApplyCdrParams.feeTakerDeptCode = vt("deptcode",res);
    JJBX_BillApplyCdrParams.feeTakerDeptPk = vt("corpcode",res);
    --debug_alert("自行承担"..foreach_arg2print(JJBX_BillApplyCdrParams));

    --显示的承担人信息
    local travelApplyShowCdrInfo = vt("createUser",res).."　"..vt("deptName",res);
    globalTable["travelApplyShowCdrInfo"] = travelApplyShowCdrInfo;
end;

--[[选择业务类型后的回调]]
function lua_travel.select_xclx_call(TouchIndex)
    if tostring(TouchIndex) == "1" then
        --debug_alert("确定");

        --处理选择的数据
        local TravelSelectXclxCacheArg = vt("TravelSelectXclxCacheArg",globalTable);
        --debug_alert("选择业务类型后的回调，数据 : "..foreach_arg2print(TravelSelectXclxCacheArg));

        globalTable["contentcode"] = vt("selectXclxContentcode",TravelSelectXclxCacheArg);
        globalTable["contentname"] = vt("selectXclxContentname",TravelSelectXclxCacheArg);
        globalTable["select_typechoose"] = vt("selectXclxFlag",TravelSelectXclxCacheArg);

        --保存选择行程类型内容，作为是否已有选择的依据
        globalTable["typechoose"] = globalTable["select_typechoose"];

        --更新业务场景选中效果
        if vt("matchTripTypeIndex",TravelSelectXclxCacheArg) ~= "" then
            lua_page.set_item_selected(vt("matchSetXclxSelectArg",TravelSelectXclxCacheArg));
        end;

        --出行人默认管控
        local travelApplyCxrCtrl = "true";
        if string.find(globalTable["travelApplyYdjlInit"], globalTable["contentcode"]) then
            --后台配置确认出行人不管控
            travelApplyCxrCtrl = "false";
        end;
        --存缓存
        globalTable["travelApplyCxrCtrl"] = travelApplyCxrCtrl;

        --[[debug_alert(
            "选择的行程类型编码 : "..globalTable["contentcode"].."\n"..
            "选择的行程类型名称 : "..globalTable["contentname"].."\n"..
            "保存选择行程类型内容 : "..globalTable["typechoose"].."\n"..
            "不管控编码集合 : "..globalTable["travelApplyYdjlInit"].."\n"..
            "是否管控 : "..globalTable["travelApplyCxrCtrl"].."\n"..
            ""
        );]]

        if travelApplyCxrCtrl == "true" then
            --debug_alert("出行人管控情况不修改");

            --隐藏承担人输入域
            hide_ele("cdr_div");
            hide_ele("cdr_space_div");
            page_reload();
        else
            --[[debug_alert(
                "出行人不管控情况修改\n"..
                "a、添加承担人搜索和上送\n"..
                "b、当行程类型选择自助福利时，承担人默认为申请人且不可修改\n"..
                "c、当行程类型选择自助福利时，行程明细中的出行人为自行输入\n"..
                "d、明细费用承担方删除\n"..
                ""
            );]]

            --显示承担人输入域
            show_ele("cdr_div");
            show_ele("cdr_space_div");
            page_reload();

            --显示承担人选择界面
            lua_travel.show_cdr_select_info();
        end;

        if #formatNull(globalTable["xcmxList"])==0 or formatNull(globalTable["typechoose"])=="" then
        else
            --客户填写行程明细后，切换行程类型时，删除全部行程明细
            --删除全部行程明细
            lua_travel.do_delete_all_xcmx();
        end;

        --业务类型是否展示
        local ywlx_display = document:getElementsByName("ywlx_div")[1]:getStyleByName("display");
        if ywlx_display == "none" then
            --关闭行程类型选择界面
            lua_page.div_page_ctrl();

            --行程类型回显
            globalTable["servicetype"] = "";
            globalTable["serviceTypeCode"] = "";
            changeProperty("xclx","value",globalTable["contentname"]);
            changeStyle("xclx","color","#4A4A4A");
            page_reload();
        else
            --查询业务类型
            lua_travel.query_YWLX();
        end;
    else
        --debug_alert("取消");
    end;
end;

--[[查询业务类型]]
function lua_travel.query_YWLX(ResParams)
    if formatNull(ResParams) == "" then
        local ReqParams = {
            TranCode="QueryYWLX",
            BusinessType="apply_travel",
            pkCorp=globalTable["selectOrgList"][1]["pkCorp"],
            deptCode=globalTable["XCSQ_responseBody"]["deptcode"],
            tripTypeCode=globalTable["contentcode"]
        };

        invoke_trancode_donot_checkRepeat(
            "jjbx_service",
            "travel_service",
            ReqParams,
            lua_travel.query_YWLX,
            {},
            all_callback,
            {CloseLoading="false"}
        );
    else
        --debug_alert("业务类型回调");
        close_loading();

        local res = json2table(ResParams["responseBody"]);
        if res["errorNo"] == "000000" then
            --关闭行程类型选择界面
            lua_page.div_page_ctrl();

            --查询业务类型
            globalTable["servicetype"] = res["serviceType"];
            globalTable["serviceTypeCode"] = res["serviceTypeCode"];
            --行程类型回显
            changeProperty("xclx","value",globalTable["contentname"]);
            changeStyle("xclx","color","#4A4A4A");
            changeProperty("servicetype","value",globalTable["servicetype"]);
        else
            if getValue("ywlx_required") == "*" then
                alert(res["errorMsg"]);
            else
                --关闭行程类型选择界面
                lua_page.div_page_ctrl();

                --行程类型回显
                globalTable["servicetype"] = formatNull(res["serviceType"]);
                globalTable["serviceTypeCode"] = formatNull(res["serviceTypeCode"]);
                changeProperty("servicetype","value",globalTable["servicetype"]);
                changeProperty("xclx","value",globalTable["contentname"]);
                changeStyle("xclx","color","#4A4A4A");
                page_reload();
            end;
        end;
    end;
end;

--[[展示人员搜索界面]]
function lua_travel.show_search_people_page()
    if globalTable["travelApplyCdrModify"]~="false" and globalTable["travelApplyCxrCtrl"]=="false" then
        --承担人允许修改且行程类型为不管控时显示界面
        lua_page.div_page_ctrl("search_people_page_div","true","true");
    end;
end;

function changeCDR(index)
    if index == 1 then
        local callArg = vt("cdrCallArg",globalTable);
        globalTable["cdrCallArg"] = nil;
        lua_travel.select_cdr_call(callArg);
    end;
end;

--[[选择承担人回调]]
function lua_travel.select_cdr_call(callArg)
    if callArg == "cdr_by_self" then
        --自行承担
        lua_travel.cdr_by_self();
    else
        --从选择的信息里取参
        local name = vt("name",callArg);
        local deptName = vt("deptName",callArg);

        JJBX_BillApplyCdrParams.feeTakerName = name;
        JJBX_BillApplyCdrParams.feeTakerCode = vt("workid",callArg);
        JJBX_BillApplyCdrParams.feeTakerPk = vt("pkUser",callArg);
        JJBX_BillApplyCdrParams.feeTakerDeptName = deptName;
        JJBX_BillApplyCdrParams.feeTakerDeptCode = vt("deptCode",callArg);
        JJBX_BillApplyCdrParams.feeTakerDeptPk = vt("pkDept",callArg);

        --[[debug_alert(
            "选择承担人回调\n"..
            "参数信息"..foreach_arg2print(JJBX_BillApplyCdrParams).."\n"..
            "返回信息"..foreach_arg2print(callArg).."\n"..
            ""
        );]]

        --存储显示的承担人信息
        globalTable["travelApplyShowCdrInfo"] = name.."　"..deptName;
    end;

    --更新页面显示文字信息
    changeProperty("cdr","value",globalTable["travelApplyShowCdrInfo"]);

    --更换承担人需调用同步修改差标的请求
    lua_travel.updateTripStandardByFeeTaker("",{});
end;

function lua_travel.updateTripStandardByFeeTaker(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams,{});
        ReqParams["ReqAddr"] = "btTripApply/updateTripStandardByFeeTaker";
        ReqParams["ReqUrlExplain"] = "更新差标";
        ReqParams["BusinessCall"] = lua_travel.updateTripStandardByFeeTaker;
        
        local BusinessParams = {
            tripNo = globalTable["XCSQbillNo"],
            feeTakerName = formatNull(JJBX_BillApplyCdrParams.feeTakerName),
            feeTakerCode = formatNull(JJBX_BillApplyCdrParams.feeTakerCode),
            feeTakerPk = formatNull(JJBX_BillApplyCdrParams.feeTakerPk),
            feeTakerDeptName = formatNull(JJBX_BillApplyCdrParams.feeTakerDeptName),
            feeTakerDeptCode = formatNull(JJBX_BillApplyCdrParams.feeTakerDeptCode),
            feeTakerDeptPk = formatNull(JJBX_BillApplyCdrParams.feeTakerDeptPk)
        };
        ReqParams["BusinessParams"] = table2json(BusinessParams);
        ReqParams["CloseLoading"] = "false";
        lua_jjbx.common_req(ReqParams);
    else
        close_loading();
        local res = json2table(ResParams["responseBody"]);
        if res["errorNo"] == "000000" then
            --缓存承担人信息，更新差标失败时，还原承担人
            JJBX_BillApplyCdrParams.feeTakerNameTemp = JJBX_BillApplyCdrParams.feeTakerName;
            JJBX_BillApplyCdrParams.feeTakerCodeTemp = JJBX_BillApplyCdrParams.feeTakerCode;
            JJBX_BillApplyCdrParams.feeTakerPkTemp = JJBX_BillApplyCdrParams.feeTakerPk;
            JJBX_BillApplyCdrParams.feeTakerDeptNameTemp = JJBX_BillApplyCdrParams.feeTakerDeptName;
            JJBX_BillApplyCdrParams.feeTakerDeptCodeTemp = JJBX_BillApplyCdrParams.feeTakerDeptCode;
            JJBX_BillApplyCdrParams.feeTakerDeptPkTemp = JJBX_BillApplyCdrParams.feeTakerDeptPk;

            --查询行程明细
            invoke_trancode_donot_checkRepeat(
                "jjbx_service",
                "travel_service",
                {
                    BusinessType="apply_travel",
                    TranCode="TravelapplyQueryDetail",
                    billType=billTypeList_utils.xcsq,
                    tripappno=globalTable["XCSQbillNo"]
                },
                lua_travel.load_xcmx_list,
                {},
                all_callback,
                {CloseLoading="true"}
            );
        else
            if res["errorNo"] == "002223" then
                alert("该承担人未匹配到差标值，请联系系统管理员维护后再修改。");
            else
                alert(res["errorMsg"]);
            end;
            
            --更新失败，还原承担人信息
            JJBX_BillApplyCdrParams.feeTakerName = JJBX_BillApplyCdrParams.feeTakerNameTemp;
            JJBX_BillApplyCdrParams.feeTakerCode = JJBX_BillApplyCdrParams.feeTakerCodeTemp;
            JJBX_BillApplyCdrParams.feeTakerPk = JJBX_BillApplyCdrParams.feeTakerPkTemp;
            JJBX_BillApplyCdrParams.feeTakerDeptName = JJBX_BillApplyCdrParams.feeTakerDeptNameTemp;
            JJBX_BillApplyCdrParams.feeTakerDeptCode = JJBX_BillApplyCdrParams.feeTakerDeptCodeTemp;
            JJBX_BillApplyCdrParams.feeTakerDeptPk = JJBX_BillApplyCdrParams.feeTakerDeptPkTemp;

            --存储显示的承担人信息
            globalTable["travelApplyShowCdrInfo"] = JJBX_BillApplyCdrParams.feeTakerName.."　"..JJBX_BillApplyCdrParams.feeTakerDeptName;
            --更新页面显示文字信息
            changeProperty("cdr","value",globalTable["travelApplyShowCdrInfo"]);
        end;
    end;
end;

--[[差旅页面跳转管理]]
function lua_travel.to_ts_page(PageTag)
    if PageTag == "xcsqxq" then
        --行程申请详情
        invoke_page("jjbx_travel_service/xhtml/travel_service_proccess_bill_detail.xhtml",page_callback,{CloseLoading="false"});
    end;
end;

--[[前往打卡记录页面]]
function lua_travel.to_checkIn_record_page(XCSQBillNo,workID)
    local XCSQBillNo = formatNull(XCSQBillNo);
    if XCSQBillNo == "" then
        alert("行程申请单号为空");
    else
        local ReqParams = {
            CheckInBillNo=XCSQBillNo,
            QryPageType="CheckInRecordList",
            WorkID = workID
        };
        lua_travel.qry_checkin_record("",ReqParams);
    end;
end;

--[[查询打卡记录并跳转]]
function lua_travel.qry_checkin_record(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams);
        ReqParams["TranCode"] = "QryCheckinCity";
        ReqParams["BusinessType"] = "travel_checkin";

        invoke_trancode(
            "jjbx_service",
            "travel_service",
            ReqParams,
            lua_travel.qry_checkin_record,
            {},
            all_callback,
            {CloseLoading="false"}
        );
    else
        local res = json2table(ResParams["responseBody"]);
        --debug_alert(foreach_arg2print(res));

        local QueryCityErrorNo = vt("QueryCityErrorNo",res);
        local QueryCityErrorMsg = vt("QueryCityErrorMsg",res);
        if QueryCityErrorNo ~= "000000" then
            alert(QueryCityErrorMsg);
        end;

        local QueryClockInErrorNo = vt("QueryClockInErrorNo",res);
        local QueryClockInErrorMsg = vt("QueryClockInErrorMsg",res);
        if QueryClockInErrorNo ~= "000000" then
            alert(QueryClockInErrorMsg);
        end;

        if QueryCityErrorNo=="000000" and QueryClockInErrorNo=="000000" then
            --打卡数据总数
            local CheckInAllCounts = formatNull(vt("CheckInAllCounts",res),0);
            if tonumber(CheckInAllCounts) > 0 then
                --debug_alert("有打卡记录");
                --打卡数据存缓存
                globalTable["CheckInRecordInfoData"] = res;
                show_ele("checkInRecord_label");
            else
                --debug_alert("无打卡记录");
                hide_ele("checkInRecord_label");
            end;
        end;
    end;
end;

--[[差旅城市匹配]]
function lua_travel.cityName_match(CityName1,CityName2)
    local res = "false";
    if string.find(CityName1,CityName2) then
        res = "true";
    elseif string.find(CityName2,CityName1) then
        res = "true";
    end;

    --[[debug_alert(
        "差旅城市匹配\n"..
        "CityName1 : "..CityName1.."\n"..
        "CityName2 : "..CityName2.."\n"..
        "res : "..res.."\n"..
        ""
    );]]

    return res;
end;

--[[设置出差打卡定位信息显示]]
function lua_travel.show_checkin_locationInfo(LocationInfo)
    local LocationInfoWidth = tonumber(calculate_text_width(LocationInfo,"14"));
    setEleLocation("checkin_add_icon","right",tostring(18+LocationInfoWidth));
    changeProperty("checkin_city_label","value",LocationInfo);
end;

--[[米转千米]]
function lua_travel.distance_m2km(meter)
    local res = "";
    local meter = formatNull(meter,"0");
    res = tostring(float(meter/1000,"1"));
    return res;
end;

--[[获取出差打卡配置]]
function lua_travel.get_clockin_mode()
    --打卡模式，1 定位打卡 2 定位拍照打卡
    local travelClockInMode = vt("travelClockInMode",globalTable);

    --优先取缓存
    if travelClockInMode == "" then
        --根据配置显示出差打卡按钮
        local PCConfigListsTable = vt("PCConfigListsTable",globalTable);
        --debug_alert(foreach_arg2print(PCConfigListsTable));

        --配置信息
        local travelClockInMsg = vt("0457",PCConfigListsTable);
        if travelClockInMsg == "定位打卡" then
            travelClockInMode = "1";
        elseif travelClockInMsg == "定位+拍照打卡" then
            travelClockInMode = "2";
        else
            travelClockInMode = "0";
        end;
        --存缓存
        globalTable["travelClockInMode"] = travelClockInMode;
    end;

    return travelClockInMode;
end;

--[[前往打卡记录]]
function lua_travel.to_checkInRecordPage()
    invoke_page("jjbx_travel_checkin/xhtml/checkin_record_list.xhtml",page_callback,{});
end;

--[[展示打卡地点地图]]
function lua_travel.show_location_map(Arg)
    local Arg = formatNull(Arg);
    --经纬度信息
    local longitude = vt("longitude",Arg);
    local latitude = vt("latitude",Arg);
    --坐标系判断（现在统一用高德）
    local mapType = "";
    if platform == "iPhone OS" then
        --iPhone使用gps坐标系
        --mapType = "gps";
    elseif platform == "Android" then
        --Android使用百度坐标系
        --mapType = "baidu";
    end;

    if longitude~="" and latitude~="" then
        local url =
            systemTable["JJBXH5_Addr"]..
            "/clock-in-travel?"..
            "longitude="..longitude..
            "&latitude="..latitude..
            "&mapType="..mapType..
            "";

        lua_system.alert_webview(
            {
                title = "打卡地点",
                visit_url = url
            }
        );
    else
        alert("地点信息异常，无法查看");
    end;

    close_loading();
end;

--[[设置商旅的渠道]]
function lua_travel.set_channel(Arg)
    if vt("TravelChannelFlag",globalTable) == "" then
        local Arg = formatNull(Arg);

        --商旅服务(优先级高) 0-不启用 1-携程 2-同程 3-阿里 1,2,3/3,2,1-携程同程阿里
        local btService = formatNull(companyTable["thirdPartyServiceStatus"]["btService"]);
        --商旅预订渠道(携程商旅、同程商旅、阿里商旅)
        local TravelChannelFlag = vt("TravelChannelFlag",Arg);
        local channelList = splitUtils(TravelChannelFlag,",");
        local xieChengFlag = "false";
        local tongChengFlag = "false";
        local aLiFlag = "false";
        for i=1,#channelList do
            if channelList[i] == "携程商旅" then
                xieChengFlag = "true";
            elseif channelList[i] == "同程商旅" then
                tongCheng = "true";
            elseif channelList[i] == "阿里商旅" then
                aLiFlag = "true";
            end;
        end;
        --已开通的商旅服务渠道
        local travelChannelList = {};
        if configTable["ThirdServiceConfigSwitch"] == "false" then
            --配置关闭的时候，设置所有渠道可用
            for i=1,3 do
                table.insert(travelChannelList,i);
            end;
        else
            if string.find(btService,"1") and xieChengFlag == "true" then
                table.insert(travelChannelList,1);
            end;

            if string.find(btService,"2") and tongCheng == "true" then
                table.insert(travelChannelList,2);
            end;

            if string.find(btService,"3") and aLiFlag == "true" then
                table.insert(travelChannelList,3);
            end;
        end;

        --[[debug_alert(
            "APP商旅渠道设置\n\n"..
            "第三方渠道是否走配置 :\n"..configTable['ThirdServiceConfigSwitch']..
            "内管配置 :\n"..btService.."(0禁用 1携程 2同程 3阿里)\n"..
            "机构配置 :\n"..TravelChannelFlag.."(0禁用 1携程 2同程 3阿里 99全部渠道)\n\n"..
            "可预订渠道数量 :\n"..tostring(#travelChannelList)..
            ""
        );]]

        --设置商旅预订渠道
        globalTable["TravelChannelFlag"] = travelChannelList;
    end;
end;

--获取报销模式
function lua_travel.query_common_hint(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        ReqParams["ReqAddr"] = "pubUserHint/queryCommonHint";
        ReqParams["ReqUrlExplain"] = "获取报销模式";
        ReqParams["BusinessCall"] = lua_travel.query_common_hint;
        local queryCommonHint_params = {channal=ReqParams["channal"]};
        ReqParams["BusinessParams"] = table2json(queryCommonHint_params);
        local Arg = {
            ProcessInvoiceIdListJson = vt("ProcessInvoiceIdListJson",ReqParams),
            billNo = vt("billNo",ReqParams)
        };
        ReqParams["ArgStr"] = lua_format.table_arg_pack(Arg);
        lua_jjbx.common_req(ReqParams);
    else
        close_loading();
        local responseBody = json2table(vt("responseBody",ResParams));
        if responseBody["errorNo"] == "000000" then
            local ArgStr = vt("ArgStr",ResParams);
            ArgStr = lua_format.table_arg_unpack(ArgStr);
            ArgStr["value"] = vt("value",responseBody);
            ArgStr = lua_format.table_arg_pack(ArgStr);
            --发起报销
            lua_travel.new_apply(ArgStr);
        else
            alert(responseBody["errorMsg"]);
        end;
    end;
end;

--切换报销模式
function lua_travel.add_common_hint(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        ReqParams["ReqAddr"] = "pubUserHint/addCommonHint";
        ReqParams["ReqUrlExplain"] = "切换报销模式";
        ReqParams["BusinessCall"] = lua_travel.add_common_hint;
        --value: 0-普通模式、1-分步模式
        local addCommonHint_params = {channal = "010",value=ReqParams["value"]};
        ReqParams["BusinessParams"] = table2json(addCommonHint_params);
        local Arg = {
            value = vt("value",ReqParams),
            billNo = vt("billNo",ReqParams),
            ProcessInvoiceIdListJson = vt("ProcessInvoiceIdListJson",ReqParams)
        };
        ReqParams["ArgStr"] = lua_format.table_arg_pack(Arg);
        lua_jjbx.common_req(ReqParams);
    else
        local responseBody = json2table(vt("responseBody",ResParams));
        if responseBody["errorNo"] == "000000" then
            local ArgStr = vt("ArgStr",ResParams);
            lua_travel.new_apply(ArgStr);
        else
            alert(responseBody["errorMsg"]);
        end;
    end;
end;

--发起报销
function lua_travel.new_apply(Arg)
    local Arg = formatNull(Arg,{});
    Arg = lua_format.table_arg_unpack(Arg);
    Arg["CloseLoading"] = "false";
    if vt("value",Arg) == "0" then
        if vt("billNo",Arg) ~= "" then
            globalTable["ifNewXCBX"] = "false";
        else
            globalTable["ifNewXCBX"] = "true";
        end;
        globalTable["zdrbmInfo"] = nil;
        invoke_page("jjbx_travel_reimbursement/xhtml/travel_service_reimbursement_submit_process.xhtml",page_callback,Arg);
    else
        --缓存单据号
        globalTable["billNo_fbbx"] = "";
        --已操作过的页面高亮显示
        globalTable["savePageCode"] = "";
        --缓存页面输入的元素，在未保存的情况下，用作回显
        globalTable["temp_pageElement"] = {};
        --判断单据是否已保存
        globalTable["billSaveFlag"] = "false";
        --缓存已添加的行程明细，用以判断是否可查看行程
        globalTable["btExpenditureDetailsListLength"] = 0;
        invoke_page("jjbx_travel_reimbursement/jjbx_travel_fbbx_001.xhtml",page_callback,Arg);
    end;
end;

function lua_travel.update_tip_status(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams);
        --flag 7-阿里提示 8-携程提示 9-同程提示
        ReqParams["ReqAddr"] = "ctripReqController/saveCtripPromptInfo";
        ReqParams["ReqUrlExplain"] = "设置商旅请求提示语不在显示";
        ReqParams.BusinessCall = lua_travel.update_tip_status;
        local params = {
            flag = ReqParams["flag"],
            value = ReqParams["value"]
        }
        ReqParams["BusinessParams"] = table2json(params);
        lua_jjbx.common_req(ReqParams);
    else
        close_loading();
        local res = json2table(ResParams["responseBody"]);
        if vt("errorNo",res) ~= "000000" then
            alert(res["errorMsg"]);
        end;
    end;
end;