--初始化报账单LUA
reimbursement = {};
--特殊情况说明标题/按钮名称
SPECIAL_EXPLAIN_TITLE = "情况说明";

function load_standingBook()
    local standingBookInfoList = vt("standingBookInfoList",globalTable);
    local htmlContent = "";
    if #standingBookInfoList > 0 then
        local delID = vt("id",standingBookInfoList[1]);
        htmlContent = htmlContent..[[
            <horiTableViewControl class='main_module_div2' width='355' divwidth='355' divheight='64' divwidth2='45' value='0' >
                <div class="invoiceInfo_div" border="0" onclick="standing_book_detail('1')" name="assetInfo">
                    <label class="label_value_productName" value="招待日期：]]..formatdate(2,standingBookInfoList[1].date)..[[" />
                    <label class="label_value_num" value="招待地点：]]..standingBookInfoList[1].location..[[" ></label>
                    <label class="label_value_szxm" value="招待人数：]]..standingBookInfoList[1].number..[[" ></label>
                    <div class="space_10_div" border="0" />
                </div>
                <div class="delete_div2" border="0" onclick="delete_standing_book_alert(']]..delID..[[')">
                    <label class="delete_value2" value="删除" />
                </div>
            </horiTableViewControl>
        ]];
    end;

    htmlContent = [[
        <div class="billList_div" border="0" name="standingBook_div">
            <div class="billList_option" border="1">
                <label class="ifRequired_css"></label>
                <label class="label_title" value="已录入]]..tostring(#standingBookInfoList)..[[条" />
                <label class="label_value" value="录入台账信息" onclick="standing_book_detail('0')" />
                <img src="local:arrow_common.png" class="arrow_common_css" />
            ]]..htmlContent;

    if #standingBookInfoList > 1 then
        htmlContent = htmlContent..[[
            <div class="billList_inoviceList_div" border="1" onclick="jjbx_all_standing_book_relevance()">
                <label class="label_button_findAll_css" value="查看全部" />
            </div>
        ]];
    end;
    htmlContent = htmlContent..[[</div></div>]];
    document:getElementsByName("standingBook_div")[1]:setInnerHTML(htmlContent);
    page_reload();
end;

--录入/编辑/查看台账信息
function standing_book_detail(index)
	jjbx_getPageElementValue();
	local standingBookInfoList = vt("standingBookInfoList",globalTable);
	local standingBookInfo = "";
	if tonumber(index) > 0 then
	    standingBookInfo = standingBookInfoList[tonumber(index)];
	end;
	local editFlag = "look";
	local djzt = globalTable["responseBody_bzd"]["bill"][1]["djzt"];
	local ifApproverEdit = vt("ifApproverEdit",globalTable);
	if djzt == "0" or djzt == "99" or ifApproverEdit == "true" then
		editFlag = "edit";
	else
		editFlag = "look";
	end;
    invoke_page("jjbx_proccess_reimbursement_bill/xhtml/reimbursement_bill_standing_book.xhtml", page_callback, {standingBookInfo=standingBookInfo,editFlag=editFlag});
end;

--查看台账信息
function jjbx_all_standing_book_relevance()
    jjbx_getPageElementValue();
    local editFlag = "look";
	local djzt = globalTable["responseBody_bzd"]["bill"][1]["djzt"];
	local ifApproverEdit = vt("ifApproverEdit",globalTable);
	if djzt == "0" or djzt == "99" or ifApproverEdit == "true" then
		editFlag = "edit";
	else
		editFlag = "look";
	end;
    invoke_page("jjbx_proccess_reimbursement_bill/xhtml/reimbursement_bill_standing_book_relevance.xhtml", page_callback, {editFlag=editFlag});
end;

--查询台账信息
function query_billB(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams,{});
        ReqParams["ReqAddr"] = "feeReim/queryBillB";
        ReqParams["ReqUrlExplain"] = "查询台账信息";
        ReqParams["BusinessCall"] = query_billB;
        local BusinessParams = {
            id = globalTable["bxd"].billBid,
            pkCorp = globalTable["responseBody_bzd"]["bill"][1]["ssjgPk"]
        };
        ReqParams["BusinessParams"] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    else
        close_loading();
        local res = json2table(ResParams["responseBody"]);
        if res["errorNo"] == "000000" then
            globalTable["standingBookInfoList"] = vt("standingBookInfoList",res);
            local loadStandingBookFunc = vt("loadStandingBookFunc",globalTable);
            --调用加载台账信息方法
            lua_system.do_function(loadStandingBookFunc,"");
        else
            alert(res["errorMsg"]);
        end;
    end;
end;

--台账信息删除
function delete_bill_standing_book_info(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams,{});
        ReqParams["ReqAddr"] = "feeReim/deleteBillStandingBookInfo";
        ReqParams["ReqUrlExplain"] = "台账信息删除";
        ReqParams["BusinessCall"] = delete_bill_standing_book_info;
        --获取需要删除的台账信息ID
        local standingBookInfoId = vt("standingBookInfoId",globalTable);
        --清空缓存
        globalTable["standingBookInfoId"] = nil;
        local BusinessParams = {
            standingBookInfoId = standingBookInfoId
        };
        ReqParams["BusinessParams"] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    else
        local res = json2table(ResParams["responseBody"]);
        if res["errorNo"] == "000000" then
            alertToast0("删除成功");
            query_billB("",{});
        else
            alert(res["errorMsg"]);
        end;
    end;
end;

--确认删除台账信息
function delete_standing_book_confirm(index)
    if index == 1 then
        delete_bill_standing_book_info("",{});
    end;
end;

--台账信息删除提示
function delete_standing_book_alert(deleteID)
    globalTable["standingBookInfoId"] = deleteID;
    alert_confirm("温馨提示","确认是否删除","取消","确认","delete_standing_book_confirm");
end;

--查询是否录入台账信息
function check_bill_standing_book_info(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams,{});
        ReqParams["ReqAddr"] = "feeReim/checkBillStandingBookInfo";
        ReqParams["ReqUrlExplain"] = "查询是否录入台账信息";
        ReqParams["BusinessCall"] = check_bill_standing_book_info;
        local BusinessParams = {
            billBId = globalTable["bxd"].billBid,
            billNo = globalTable["responseBody_bzd"]["bill"][1]["djh"],
            ywcjbm = ReqParams["ywcjbm"],
            pageType = lua_jjbx.getPageType()
        };
        ReqParams["BusinessParams"] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    else
        close_loading();
        local res = json2table(ResParams["responseBody"]);
        if res["errorNo"] == "000000" then
            local pageConfig = vt("pageConfig",globalTable);
            globalTable["pageConfig"] = nil;
            local fieldVisible = jjbx_getPageConfigDetail("standingBookInfo",pageConfig,"fieldVisible");
        	if res["checkResult"] == "1" and fieldVisible == "1" then
            	changeStyle("standingBook_div","display","block");
            else
                --非台账场景，不显示台账信息
                changeStyle("standingBook_div","display","none");
            end;
            page_reload();
        else
            alert(res["errorMsg"]);
        end;
    end;
end;

--查询当前登录机构可以使用的模板
function qry_detail_by_jg(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams,{});
        ReqParams["ReqAddr"] = "ruleCorrelation/qryDetailByJg";
        ReqParams["ReqUrlExplain"] = "查询当前登录机构可以使用的模板";
        ReqParams["BusinessCall"] = qry_detail_by_jg;
        
        local BusinessParams = {
            djlxbm = ReqParams["billTypeCode"],
            billNo = ReqParams["billNo"]
        };
        ReqParams["BusinessParams"] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    else
        close_loading();
        local res = json2table(ResParams["responseBody"]);
        if res["errorNo"] == "000000" then
            globalTable["specialExplainRules"] = vt("rules",res);
        else
            globalTable["specialExplainRules"] = {};
        end;
    end;
end;

--查看特殊说明
function get_view_pdf_url(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams,{});
        globalTable["tempBillNo"] = ReqParams["billNo"];
        globalTable["tempBillType"] = ReqParams["billType"];
        invoke_trancode_donot_checkRepeat(
            "jjbx_process_query",
            "process_bill",
            {
                BusinessType="reimbursement_bill",
                TranCode="getViewPdfUrl",
                billNo=ReqParams["billNo"],
                pageType = lua_jjbx.getPageType()
            },
            get_view_pdf_url,
            {},
            all_callback,
            {
                CloseLoading="false"
            }
        );
    else
        close_loading();
        local res = json2table(ResParams["responseBody"]);
        if res["errorNo"] == "000000" then
            local rulesList = vt("rulesList",res);
            globalTable["rulesList"] = vt("rulesList",res);
            if #rulesList > 0 then
                changeStyle("drag_ctrl_ele1","display","block");
                --初始化动画效果
                AniSetDragArg1["DragEleNames"] = "drag_ctrl_ele1";
                AniSetDragArg1["DragXStyleCtrl"] = "";
                AniSetDragArg1["DragYStyleCtrl"] = "CloseToRight";
                lua_animation.set_drag_listener(AniSetDragArg1);
            else
                changeStyle("drag_ctrl_ele1","display","none");
            end;
        else
            alert(res["errorMsg"]);
        end;
    end;
end;

--修改查看状态，标识当前节点已查看特殊说明
function updateStats(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams,{});
        invoke_trancode_donot_checkRepeat(
            "jjbx_process_query",
            "process_bill",
            {
                BusinessType="reimbursement_bill",
                TranCode="updateStats",
                billNo=ReqParams["billNo"],
                pageType = lua_jjbx.getPageType()
            },
            updateStats,
            {},
            all_callback,
            {
                CloseLoading="false"
            }
        );
    else
        close_loading();
    end;
end;

function look_special_img(index)
    --常规查看无入参，默认为1，审批查看带参，0关闭、1查看
    local i = formatNull(index,1);
    if i == 1 then
        local rulesList = vt("rulesList",globalTable);  
        if #rulesList > 0 then
            invoke_page("jjbx_proccess_reimbursement_bill/xhtml/reimbursement_bill_special_explain_look.xhtml",page_callback,{});
        else
            alert("暂无可查看的情况说明");
        end;
    end;
end;

function update_stats(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams,{});
        ReqParams["ReqAddr"] = "ruleCorrelation/updateStats";
        ReqParams["ReqUrlExplain"] = "更新特殊说明查看状态";
        ReqParams["BusinessCall"] = update_stats;
        local billNo = vt("tempBillNo",globalTable);
        globalTable["tempBillNo"] = nil;
        local BusinessParams = {
            billNo = billNo,
            approverPk = globalTable["nodeCode"]
        };
        ReqParams["BusinessParams"] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    else
        close_loading();
        local res = json2table(ResParams["responseBody"]);
        if res["errorNo"] == "000000" then

        else
            --不处理异常
        end;
    end;
end;

