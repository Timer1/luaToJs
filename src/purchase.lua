--[[采购相关lua]]
lua_purchase = {};

--采购申请单记录查询参数(PurchaseApplyRecordListQryArg)
PARLQArg = {
    --查询状态 1待提交(默认) 2审批中 3待支付 4已支付 5已失效 6审批失败 7超时失效
    qryFlag="",

    --查询时间参数（已支付状态下提交）
    --开始时间
    qryStartDate="",
    --结束时间
    qryEndDate="",
    --时间区间类型编码 1 2 3 4 5
    qryDateFlag="",
    --时间区间类型名称 全部、近一周、近一月、近三月、近半年
    qryDateFlagName="",

    --查询单据状态（已失效状态下提交）
    --状态编码 1 2 3
    qryBillStatusFlag="",
    --状态名称 全部、审批失败、超时失效
    qryBillStatusName=""
};

--采购订单列表查询(PurchaseOrderListQryArg)
POLQArg = {
    --订单类型编码
    qryOrderTypeFlag="",
    --订单类型名称
    qryOrderTypeName="",
    --订单状态编码
    qryOrderStatusFlag="",
    --订单状态名称
    qryOrderStatusName="",
    --时间排序编码
    qryOrderSortFlag="",
    --时间排序名称
    qryOrderSortName=""
};

--访问商城链接为空错误信息
Visit_EjyH5_ErrorMsg = "获取商城地址失败";

--[[订单状态转码]]
function lua_purchase.order_status_name(StatusCode)
    local StatusName = "";
    if StatusCode == "1" then StatusName = "";
    elseif StatusCode == "2" then StatusName = "待审批";
    elseif StatusCode == "3" then StatusName = "待付款";
    elseif StatusCode == "4" then StatusName = "待收货";
    elseif StatusCode == "5" then StatusName = "已完成";
    elseif StatusCode == "6" then StatusName = "已取消";
    elseif StatusCode == "7" then StatusName = "退款中";
    elseif StatusCode == "8" then StatusName = "已退款";
    end;
    return StatusName;
end;

--[[订单状态转图片]]
function lua_purchase.order_status_pic(StatusName)
    local StatusPicName = "";
    if     StatusName == "待审批" then StatusPicName = "order_status_dsp.png";
    elseif StatusName == "待付款" then StatusPicName = "order_status_dfk.png";
    elseif StatusName == "待收货" then StatusPicName = "order_status_dsh.png";
    elseif StatusName == "已完成" then StatusPicName = "order_status_ywc.png";
    elseif StatusName == "已取消" then StatusPicName = "order_status_yqx.png";
    elseif StatusName == "退款中" then StatusPicName = "order_status_tkz.png";
    elseif StatusName == "已退款" then StatusPicName = "order_status_ytk.png";
    else StatusPicName = "" 
    end;
    return StatusPicName;
end;

--[[采购单据状态转换]]
function lua_purchase.apply_status_name(StatusCode)
    local StatusName = "";
    if     StatusCode == "1" then StatusName = "待提交";
    elseif StatusCode == "2" then StatusName = "审批中";
    elseif StatusCode == "3" then StatusName = "待支付";
    elseif StatusCode == "4" then StatusName = "已支付";
    elseif StatusCode == "5" then StatusName = "已失效";
    elseif StatusCode == "6" then StatusName = "审批失败";
    elseif StatusCode == "7" then StatusName = "超时失效";
    else StatusName = "状态未知" 
    end;

    return StatusName;
end;

--[[采购参数初始化]]
function lua_purchase.arg_init_qry(ResParams,ReqParams)
    --系统参数查询
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams);

        if vt("PurchaseQueryConfig1",companyTable) == "" then
            ReqParams["QryConfig1"] = "true";
        end;
        if vt("PurchaseQueryConfig2",companyTable) == "" then
            ReqParams["QryConfig2"] = "true";
        end;
        if vt("PurchaseQueryConfig3",companyTable) == "" then
            ReqParams["QryConfig3"] = "true";
        end;

        --debug_alert("采购参数初始化-请求"..foreach_arg2print(ReqParams));

        ReqParams["TranCode"] = "ArgInitQry";
        invoke_trancode_donot_checkRepeat(
            "jjbx_service",
            "online_shopping",
            ReqParams,
            lua_purchase.arg_init_qry,
            {},
            all_callback,
            {CloseLoading="false"}
        );
    else
        local res = json2table(ResParams["responseBody"]);
        --debug_alert("采购参数初始化-响应\n"..foreach_arg2print(res));

        -- 采购单据配置-制单人查看
        if vt("QryConfig1",res) == "true" then
            companyTable["PurchaseQueryConfig1"] = vt("queryConfig1",res);
        end;
        -- 采购单据配置-新增编辑
        if vt("QryConfig2",res) == "true" then
            companyTable["PurchaseQueryConfig2"] = vt("queryConfig2",res);
        end;
        -- 采购单据配置-审批人查看
        if vt("QryConfig3",res) == "true" then
            companyTable["PurchaseQueryConfig3"] = vt("queryConfig3",res);
        end;

        -- 公务采购制度
        globalTable["PurchaseBusinessRuleData"] = vt("PurchaseBusinessRuleData",res);

        --初始化回调
        local InitCallFun = vt("InitCallFun",res);
        lua_system.do_function(InitCallFun,"");
    end;
end;

--[[采购页面路由]]
function lua_purchase.page_router(PageName,RouterArg)
    local PageUrl = "";
    if PageName == "index" then
        --在线采购首页
        PageUrl = "index.xhtml";
    elseif PageName == "apply" then
        --采购申请
        PageUrl = "apply.xhtml";
    elseif PageName == "apply_edit" then
        --采购申请编辑
        PageUrl = "apply_edit.xhtml";
    elseif PageName == "apply_detail" then
        --采购申请详情
        PageUrl = "apply_detail.xhtml";
    elseif PageName == "apply_success" then
        --采购申请成功
        PageUrl = "apply_success.xhtml";
    elseif PageName == "apply_record_list" then
        --采购申请单（有效）
        PageUrl = "apply_record_list.xhtml";
        --分页参数初始化
        lua_page_list.init_qry_arg("purchase_apply_record_list");
        --查询参数初始化
        lua_format.reset_table(PARLQArg);
        --debug_alert("前往采购申请单页面，初始化分页参数和查询参数");
    elseif PageName == "apply_record_invalid_list" then
        --采购申请单（失效）
        PageUrl = "apply_record_invalid_list.xhtml";
        --分页参数初始化
        lua_page_list.init_qry_arg("purchase_apply_invalid_record_list");
        --查询参数初始化（失效）
        lua_format.reset_table(PARLQArg);
        --debug_alert("前往采购申请单（失效）页面，初始化分页参数和查询参数");
    elseif PageName == "assets_card_edit" then
        --资产卡片维护
        PageUrl = "assets_card_edit.xhtml";
    elseif PageName == "assets_card_look" then
        --资产卡片查看
        PageUrl = "assets_card_look.xhtml";
    elseif PageName == "assets_card_info" then
        --资产卡片信息
        PageUrl = "assets_card_info.xhtml";
    elseif PageName == "order_detail_business" then
        --采购订单详情（公务采购）
        PageUrl = "order_detail_business.xhtml";
    elseif PageName == "order_detail_personal" then
        --采购订单详情（个人采购）
        PageUrl = "order_detail_personal.xhtml";
    elseif PageName == "order_list" then
        --采购订单列表
        PageUrl = "order_list.xhtml";
        --分页参数初始化
        lua_page_list.init_qry_arg("purchase_order_list");
        --查询参数初始化
        lua_format.reset_table(POLQArg);
        --debug_alert("前往采购订单页面，初始化分页参数和查询参数");
    elseif PageName == "personal_rule_list" then
        --个人采购制度列表
        PageUrl = "personal_rule_list.xhtml";
    elseif PageName == "category_goods_info" then
        --采购品类商品信息
        PageUrl = "category_goods_info.xhtml";
    elseif PageName == "category_goods_info_look" then
        --采购品类商品信息查看
        PageUrl = "category_goods_info_look.xhtml";
    elseif PageName == "ask_info" then
        --采购常见问题
        PageUrl = "ask_info.xhtml";
    else
        alertToast1("页面异常");
    end;

    if PageUrl ~= "" then
        local RouterArg = formatNull(RouterArg,{});
        RouterArg["CloseLoading"] = vt("CloseLoading",RouterArg,"false");
        invoke_page("jjbx_online_shopping".."/"..PageUrl, page_callback, RouterArg);
    end;
end;

--[[前往资产信息页面]]
function lua_purchase.to_assets_card_info_page(CallArgEncodeStr)
    local CallArgEncodeStr = formatNull(CallArgEncodeStr);
    local CallArgDecodeStr = lua_format.base64_decode(CallArgEncodeStr);
    local CallArg = json2table(CallArgDecodeStr);

    --[[debug_alert(
        "前往资产信息页面\n"..
        "CallArgEncodeStr : "..CallArgEncodeStr.."\n"..
        "CallArgDecodeStr : "..CallArgDecodeStr.."\n"..
        "CallArg\n"..foreach_arg2print(CallArg).."\n"..
        ""
    );]]

    lua_purchase.page_router("assets_card_info",CallArg);
end;

--[[单据状态数量转换]]
function lua_purchase.show_status_counts(CountsNum)
    local CountsNum = tonumber(CountsNum);
    if type(CountsNum) ~= "number" then
        return "";
    else
        if CountsNum > 99 then
            return "(99+)";
        elseif CountsNum ~= 0 then
            return "("..CountsNum..")";
        else
            return "";
        end;
    end;
end;

--[[显示业务场景选择界面]]
function lua_purchase.show_ywcj_select_page()
    local ywcjData = formatNull(companyTable["PurchaseYWCJData"]);
    local element = document:getElementsByName("cgzd");
    local cgzd = "";
    if #element > 0 then
        cgzd = getValue("cgzd");
    end;
    if cgzd == "请选择" then
        alert("请选择采购制度");
    elseif ywcjData == "" then
        alert("当前无可用业务场景，请更换采购制度");
    elseif globalTable["ifApproverEdit"] == "true" then
        --审批人编辑时不校验订单时效
        lua_page.div_page_ctrl('ywcj_page_div','true','false');
    elseif formatNull(globalTable["onlineShopping_initParams"].flag) == "1" then
        alert("采购申请单的所有商品需在24h内下单，超过时间无法下单");
    else
        lua_page.div_page_ctrl('ywcj_page_div','true','false');
    end;
end;

--[[选择业务场景]]
function lua_purchase.select_business_scene(params)
    if formatNull(params,"") ~= "" then
        lua_page.div_page_ctrl();
        local codeAndName = splitUtils(params,",");
        local ywcjbm = "";
        local ywcj = "";
        local listLen = #codeAndName;
        for i=1,listLen do
            if i ~= listLen then
                if i == listLen - 1 then
                    ywcjbm = codeAndName[i];
                end;
            else
                ywcj = codeAndName[i];
            end;
        end;

        local element = document:getElementsByName("ywlx");
        if #element > 0 then
            changeProperty("ywlx","value",ywlx);
        end;

        local selectedYWCJList = formatNull(globalTable["onlineShopping_initParams"].selectedYWCJList,{});
        local flag = "false";
        --判断当前选择的品类是否已存在(审批人编辑时，不做品类重复校验)
        if formatNull(globalTable["ifApproverEdit"],"false") ~= "true" then
            for k,v in pairs(selectedYWCJList) do
                if ywcjbm == v["ywcjbm"] then
                    flag = "true";
                    break
                end;
            end;
        end;

        if flag == "false" or formatNull(globalTable["ifApproverEdit"],"false") == "true" then
            globalTable["onlineShopping_initParams"].businessScenarios = ywcjbm;
            globalTable["onlineShopping_initParams"].businessScenariosName = ywcj;
            --获取品类编码
            for key,value in pairs(companyTable["PurchaseYWCJData"]) do
                if ywcjbm == value["businessScenarios"] then
                    globalTable["onlineShopping_initParams"].idpurchaseInstitutionCategory = value["idpurchaseInstitutionCategory"];
                    break
                end;
            end;

            --选择业务场景后发起新建采购明细申请
            local reqParams = {
                purchaseBillNo=globalTable["onlineShopping_initParams"]["purchaseBillNo"],
                businessScenarios=ywcjbm,
                businessScenariosName=ywcj,
                idpurchaseInstitutionCategory=globalTable["onlineShopping_initParams"].idpurchaseInstitutionCategory;
            };
            if formatNull(globalTable["ifApproverEdit"],"false") ~= "true" then
                --制单人操作走新建流程
                onlineShopping_newBillB('',reqParams);
            else
                --审批人操作走编辑流程
                --根据业务场景获取收支项目、业务类型、项目档案
                qryBusinessScenarioForBFY("",{businessScenarios=globalTable["onlineShopping_initParams"].businessScenarios,flag="change"});
            end;
        else
            alert(ywcj.."已存在，不可重复添加，请重新选择");
        end;
    end;
end;

--[[显示采购制度选择界面]]
function lua_purchase.show_cgzd_select_page()
    local cgzdData = formatNull(globalTable["PurchaseBusinessRuleData"]);
    if cgzdData == "" then
        alert("无可用的采购制度");
    else
        lua_page.div_page_ctrl('cgzd_page_div','false','false');
    end;
end;

--根据业务场景编码获取完整的树形结构数据
function createContentTreeListForApp(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        ReqParams["TranCode"] = "createContentTreeListForApp";
        ReqParams["filecode"] = "FIN-010";
        ReqParams["applyBillTypeCode"] = billTypeList_utils.cgsq_new;
        ReqParams["pkCorp"] = globalTable["onlineShopping_initParams"].pkCorp;
        invoke_trancode_donot_checkRepeat(
            "jjbx_service",
            "online_shopping",
            ReqParams,
            createContentTreeListForApp,
            {},
            all_callback,
            {CloseLoading="true"}
        );
    else
        local responseBody = json2table(ResParams["responseBody"]);
        globalTable["ywcjList"] = table2json(vt("list",responseBody));
        if responseBody["errorNo"] == "000000" then
            --获取筛选后的业务场景列表
            changeProperty("bxcjView","value",globalTable["ywcjList"]);
        else
            alert(responseBody["errorMsg"]);
        end;
    end;
end;

--[[选择采购制度]]
function lua_purchase.select_business_scene_cgzd(index,flag)
    --用来判断是否是在div显示的情况下手动点击的还是在不显示的情况下脚本点击的
    --不显示的情况下，不执行该关闭操作，否则会导致开关状态异常
    local flag = formatNull(flag);
    if flag == "" then
        --关闭采购制度选择
        lua_page.div_page_ctrl();
    end;
    --debug_alert(index);
    if formatNull(index) ~= "" then
        local cgzdData = formatNull(globalTable["PurchaseBusinessRuleData"]);
        if cgzdData ~= "" then
            local cgzdDataLen = #cgzdData;
            local codeList = "";
            for i=1,cgzdDataLen do
                --debug_alert(foreach_arg2print(cgzdData[i]));
                if i == tonumber(index) then
                    if globalTable["onlineShopping_initParams"].institutionName ~= "" and globalTable["onlineShopping_initParams"].idpurchaseInstitution ~= vt("idpurchaseInstitution",cgzdData[i]) then
                        --[[切换采购制度时删除原来采购制度下的采购名明细及其订单]]
                        deleteCgAllBillBId("",{});
                    end;
                    --缓存已选择的采购制度
                    globalTable["onlineShopping_initParams"].institutionName = vt("institutionName",cgzdData[i]);
                    globalTable["onlineShopping_initParams"].institutionCode = vt("institutionCode",cgzdData[i]);
                    globalTable["onlineShopping_initParams"].idpurchaseInstitution = vt("idpurchaseInstitution",cgzdData[i]);
                    globalTable["onlineShopping_initParams"].confirmOrder = vt("confirmOrder",cgzdData[i]);
                    globalTable["onlineShopping_initParams"].maintenanceCard = vt("maintenanceCard",cgzdData[i]);
                    globalTable["onlineShopping_initParams"].maintenanceCardLimit = vt("maintenanceCardLimit",cgzdData[i]);

                    --获取当前采购制度下的业务场景编码
                    companyTable["PurchaseYWCJData"] = formatNull(vt("businessScenariosList",cgzdData[i]),{});
                    for key,value in pairs(companyTable["PurchaseYWCJData"]) do
                        if key == #companyTable["PurchaseYWCJData"] then
                            codeList = codeList..value["businessScenarios"];
                        else
                            codeList = codeList..value["businessScenarios"]..",";
                        end;
                    end;
                    break
                end;
            end;
            
            if codeList == "" then
                alert("当前制度下无可用采购场景，请重新选择");
            else
                --回显采购制度名称
                changeProperty("cgzd","value",globalTable["onlineShopping_initParams"].institutionName);

                --更新采购制度选中效果
                local setCGZDSelectArg = {
                    showIndex=index
                };
                lua_page.set_item_selected(setCGZDSelectArg);

                --根据编码查询可用业务场景列表
                createContentTreeListForApp("",{contentcode=codeList});
            end;
        else
            alert("无可用的采购制度");
        end;
    else
        alert("无可用的采购制度");
    end;
end;

--[[渲染采购制度]]
function lua_purchase.render_business_purchase_scene_cgzd()
    --采购制度数据
    local cgzdData = formatNull(globalTable["PurchaseBusinessRuleData"]);
    --采购制度条目数
    local cgzdDataCounts = #cgzdData;
    --debug_alert(cgzdDataCounts);

    --采购制度存在时创建
    if cgzdDataCounts > 0 then
        local selectEleArg = {};
        for key,value in pairs(cgzdData) do
            local institutionCode = formatNull(value["institutionCode"]);
            local institutionName = formatNull(value["institutionName"]);
            local institutionMarks = formatNull(value["remarks"]);
            local selectEleArgItem = {
                --显示文字
                labelName=institutionName,
                --备注文字
                tipName=institutionMarks,
                --点击函数
                clickFunc="lua_purchase.select_business_scene_cgzd",
                --点击函数入参
                clickFuncArg=tostring(key)
            };
            table.insert(selectEleArg,selectEleArgItem);
        end;

        --渲染select页面
        local renderSelectArg = {
            bgName="cgzd_page_div",
            topEleName="top_cgzd_div",
            topTitleName="选择采购制度",
            selectEleName="cgzd_list_div",
            selectEleArg=selectEleArg,
            renderCallBackFun="onlineShopping_render_select_cgzd_page_call"
        };
        lua_page.render_select_page(renderSelectArg);
    end;
    close_loading();
end;

--[[渲染订单图片列表]]
function lua_purchase.render_order_pic_list_html(Data,OnclickFun)
    local Data = formatNull(Data);
    local OnclickFun = formatNull(OnclickFun);

    --[[debug_alert(
        "渲染订单图片列表"..foreach_arg2print(Data).."\n"..
        "OnclickFun : "..OnclickFun.."\n"..
        ""
    );]]

    local res = "";
    --订单编号
    local orderId = vt("orderId",Data);
    --订单总额
    local goodsPrice = vt("goodsPrice",Data);
    --订单商品数量
    local goodsNum = vt("goodsNum",Data);

    --获取当前订单的商品列表
    local goodsInfo = vt("orderGoodsOut",Data);
    local goodsInfoCounts = #goodsInfo;
    --调试个数
    --goodsInfoCounts = 6;

    local order_pic_items_html = "";
    for i=1,goodsInfoCounts do
        local goodsItemData = formatNull(goodsInfo[i]);
        --debug_alert(foreach_arg2print(goodsItemData));

        local className = "px_order_pic_item"..tostring(i).."_div";
        --debug_alert(className);
        if i > 4 then
            --超出情况显示“更多”样式
            order_pic_items_html = order_pic_items_html..[[
                <div class="]]..className..[[" border="0" />
            ]];
            break
        else
            local picUrl = lua_purchase.order_pic_link_prepare(vt("pic",goodsItemData));
            order_pic_items_html = order_pic_items_html..[[
                <div class="]]..className..[[" border="0">
                    <imageView width="50" height="50" class="px_order_pic_image" radius="0" value="]]..picUrl..[[" />
                </div>
            ]];
        end;
    end;

    res = [[
        <div class="px_order_div" border="0">
            <label class="px_order_id_label" value="]]..orderId..[[" />
            <div class="px_order_pic_list_div" border="0">
                ]]..order_pic_items_html..[[
                <div class="px_order_list_info_div" border="0" onclick="]]..OnclickFun..[[">
                    <label class="px_order_counts_label" value="共]]..goodsNum..[[件" />
                    <label class="px_order_price_label" value="¥ ]]..goodsPrice..[[" />
                    <img src="local:arrow_common.png" class="px_order_info_arrow" />
                </div>
            </div>
        </div>
    ]];

    return res;
end;

--[[更新各状态单据数量显示]]
function lua_purchase.update_apply_status_counts_label(Data)
    --待提交
    local dtjText = "待提交"..lua_purchase.show_status_counts(vt("dtjNum",Data));
    changeProperty("b_status_dtj_label","value",dtjText);

    --审批中
    local shzText = "审批中"..lua_purchase.show_status_counts(vt("shzNum",Data));
    changeProperty("b_status_shz_label","value",shzText);

    --待支付
    local dzfText = "待支付"..lua_purchase.show_status_counts(vt("dzfNum",Data));
    changeProperty("b_status_dzf_label","value",dzfText);

    --已支付
    local yzfText = "已支付"..lua_purchase.show_status_counts(vt("yzfNum",Data));
    changeProperty("b_status_yzf_label","value",yzfText);

    local res = {
        dtjText=dtjText,
        shzText=shzText,
        dzfText=dzfText,
        yzfText=yzfText
    };
    return res;
end;

--[[获取采购登录链接]]
function lua_purchase.get_login_url(ResParams,ReqParams)
    --涉嫌电信诈骗提示
    local UserRiskCheckMsg = vt("UserRiskCheckMsg",globalTable);
    if UserRiskCheckMsg ~= "" then
        alert(UserRiskCheckMsg);
    else
        if formatNull(ResParams) == "" then
            local ReqParams = formatNull(ReqParams);
            ReqParams["TranCode"] = "GetPurchaseLoginUrl";
            local ResCallFunc = vt("ResCallFunc",ReqParams);
            invoke_trancode_donot_checkRepeat(
                "jjbx_service",
                "online_shopping",
                ReqParams,
                lua_purchase.get_login_url,
                {
                    ResCallFunc=ResCallFunc
                },
                all_callback,
                {CloseLoading="false"}
            );
        else
            local res = json2table(ResParams["responseBody"]);
            --debug_alert("获取采购登录链接-响应\n"..foreach_arg2print(res));

            local errorNo = vt("errorNo",res);
            local errorMsg = vt("errorMsg",res);
            --调用回调
            local ResCallFunc = vt("ResCallFunc",ResParams);
            lua_system.do_function(ResCallFunc,res);
        end;
    end;
end;

--[[订单图片链接预处理]]
function lua_purchase.order_pic_link_prepare(oldUrl)
    local AppEnvironment = vt("AppEnvironment",systemTable);
    local PublicNetHost = vt("PublicNetHost",systemTable);

    local newUrl = "";

    if oldUrl ~= "" then
        if string.find(oldUrl,"http") then
            newUrl = oldUrl;
        else
            if AppEnvironment=="dev" or AppEnvironment=="sit" then
                if PublicNetHost == "true" then
                    newUrl = "http://sccs.ejyshop.com";
                else
                    newUrl = "http://203.3.236.162:8100";
                end;
            elseif AppEnvironment == "uat" then
                if PublicNetHost == "true" then
                    newUrl = "http://scyz.ejyshop.com";
                else
                    newUrl = "http://x-sitemeshop.verify.com";
                end;
            else
                newUrl = "https://x-site.ejyshop.com";
            end;
        end;

        --链接被替换进行追加
        if oldUrl ~= newUrl then
            newUrl = newUrl..oldUrl;
        end;

        --[[debug_alert(
            "订单图片链接预处理\n"..
            "AppEnvironment : "..AppEnvironment.."\n"..
            "PublicNetHost : "..PublicNetHost.."\n"..
            "oldUrl : "..oldUrl.."\n"..
            "newUrl : "..newUrl.."\n"..
            ""
        );]]
    else
        newUrl = "";
    end;

    return newUrl;
end;

--[[采购订单支付]]
function lua_purchase.order_pay(ResParams,ReqParams)
    lua_page.div_page_ctrl();

    if formatNull(ResParams) == "" then
        --debug_alert("订单支付参数"..foreach_arg2print(ReqParams));
        local ReqParams = formatNull(ReqParams);
        ReqParams["TranCode"] = "PurchaseOrderPay";
        local ResCallFunc = vt("ResCallFunc",ReqParams);
        invoke_trancode_donot_checkRepeat(
            "jjbx_service",
            "online_shopping",
            ReqParams,
            lua_purchase.order_pay,
            {
                ResCallFunc=ResCallFunc
            },
            all_callback,
            {CloseLoading="false"}
        );
    else
        local res = json2table(vt("responseBody",ResParams));
        --debug_alert("采购订单支付-响应\n"..foreach_arg2print(res));
        local ResCallFunc = vt("ResCallFunc",ResParams);
        local ResCallArg = vt("ResCallArg",ResParams);

        local errorNo = vt("errorNo",res);
        local errorMsg = vt("errorMsg",res,"支付失败");

        if errorNo == "000000" then
            close_loading();

            --调用回调
            local ResCallFunc = vt("ResCallFunc",ResParams);
            lua_system.do_function(ResCallFunc,res);
        else
            alert(errorMsg);
        end;
    end;
end;

--[[查询申请单关联订单]]
function lua_purchase.qry_relate_order(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams);
        ReqParams["TranCode"] = "QryOrderListByApplyId";
        local ResCallFunc = vt("ResCallFunc",ReqParams);
        invoke_trancode_donot_checkRepeat(
            "jjbx_service",
            "online_shopping",
            ReqParams,
            lua_purchase.qry_relate_order,
            {
                ResCallFunc=ResCallFunc
            },
            all_callback,
            {CloseLoading="false"}
        );
    else
        local res = json2table(ResParams["responseBody"]);
        --debug_alert("查询申请单关联订单-响应\n"..foreach_arg2print(res));

        local errorNo = vt("errorNo",res);
        local errorMsg = vt("errorMsg",res);
        --查询的单据号
        local ReqBillNo = vt("ReqBillNo",res);

        if errorNo == "000000" then
            --调用回调
            local ResCallFunc = vt("ResCallFunc",ResParams);
            lua_system.do_function(ResCallFunc,res);
        else
            alert(errorMsg);
        end;
    end;
end;

--[[查询资产信息]]
function lua_purchase.qryCgGoodsList(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        --debug_alert("查询资产信息参数"..foreach_arg2print(ReqParams));
        local ReqParams = formatNull(ReqParams);
        local ResCallFunc = vt("ResCallFunc",ReqParams);
        ReqParams["TranCode"] = "qryCgGoodsList";
        invoke_trancode_donot_checkRepeat(
            "jjbx_service",
            "online_shopping",
            ReqParams,
            lua_purchase.qryCgGoodsList,
            {
                ResCallFunc = ResCallFunc
            },
            all_callback,
            {CloseLoading="false"}
        );
    else
        local res = json2table(vt("responseBody",ResParams));
        --debug_alert("查询资产信息-响应\n"..foreach_arg2print(res));
        local ResCallFunc = vt("ResCallFunc",ResParams);
        local ResCallArg = vt("ResCallArg",ResParams);

        local errorNo = vt("errorNo",res);
        local errorMsg = vt("errorMsg",res);

        if errorNo ~= "000000" then
            alert(errorMsg);
        end;

        --调用回调
        local ResCallFunc = vt("ResCallFunc",ResParams);
        lua_system.do_function(ResCallFunc,res);
    end;
end;

--[[前往京东订单列表]]
function lua_purchase.to_jd_order_list()
    globalTable["queryAllOrder_params"] = {
        TranCode = "getJdOrderFlow",
        pageNum="1",
        pageSize="10",
        listIndex="1",
        screenType="welfare",
        welfareIndex="1",
        statusIndex="1",
        descIndex="1",
        orderType="",
        orderStatus="0",
        sord=""
    };
    invoke_page("jjbx_online_shopping/xhtml/onlineShopping_allOrder.xhtml",page_callback,{CloseLoading="false"});
end;

--[[调试前往京东采购]]
function lua_purchase.debug_to_jdcg()
    --调试功能，不控制权限
    invoke_page("jjbx_online_shopping/xhtml/onlineShopping_home.xhtml", page_callback, RouterArg);
end;

--[[调试前往e家银给采购]]
function lua_purchase.debug_to_ejycg()
    lua_purchase.page_router("index");
end;

--[[跳转H5订单详情页面]]
function lua_purchase.to_order_detail(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams);
        ReqParams["ReqAddr"] = "purchaseReq/fetchOrderUrl";
        ReqParams["ReqUrlExplain"] = "获取商城订单详情链接";
        ReqParams.BusinessCall = lua_purchase.to_order_detail;
        lua_jjbx.common_req(ReqParams);
    else
        local res = json2table(ResParams["responseBody"]);
        if res["errorNo"] == "000000" then
            if vt("url",res) ~= "" then
                close_loading();
                lua_system.alert_webview(
                    {
                        title = "订单详情",
                        visit_url = res["url"],
                        back_type = "BACK",
                        close_call_func="order_list_h5_close_call"
                    }
                );
            else
                alert(Visit_EjyH5_ErrorMsg);
            end;
        else
            alert(res["errorMsg"]);
        end;
    end;
end;

--[[跳转H5订单物流页面]]
function lua_purchase.to_order_logistics(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams);
        ReqParams["ReqAddr"] = "purchaseReq/fetchOrderItemUrl";
        ReqParams["ReqUrlExplain"] = "获取商城订单物流链接";
        ReqParams.BusinessCall = lua_purchase.to_order_logistics;
        lua_jjbx.common_req(ReqParams);
    else
        local res = json2table(ResParams["responseBody"]);
        if res["errorNo"] == "000000" then
            if vt("url",res) ~= "" then
                close_loading();
                lua_system.alert_webview(
                    {
                        title = "物流详情",
                        visit_url = res["url"],
                        back_type = "BACK"
                    }
                );
            else
                alert(Visit_EjyH5_ErrorMsg);
            end;
        else
            alert(res["errorMsg"]);
        end;
    end;
end;

--[[跳转H5退款详情页面]]
function lua_purchase.to_order_refund_detail(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams);
        ReqParams["ReqAddr"] = "purchaseReq/fetchReturnOrderListUrl";
        ReqParams["ReqUrlExplain"] = "获取商城订单退款详情链接";
        ReqParams.BusinessCall = lua_purchase.to_order_refund_detail;
        lua_jjbx.common_req(ReqParams);
    else
        local res = json2table(ResParams["responseBody"]);
        if res["errorNo"] == "000000" then
            if vt("url",res) ~= "" then
                close_loading();
                lua_system.alert_webview(
                    {
                        title = "退货退款",
                        visit_url = res["url"],
                        back_type = "BACK"
                    }
                );
            else
                alert(Visit_EjyH5_ErrorMsg);
            end;
        else
            alert(res["errorMsg"]);
        end;
    end;
end;

--[[清理采购初始缓存参数]]
function lua_purchase.reset_onlineShopping_initParams()
    globalTable["onlineShopping_initParams"] = {
        purchaseBillNo = "",
        selectedYWCJList = {},
        cgsy = "",
        institutionName="",
        institutionCode = "",
        idpurchaseInstitution = "",
        businessScenarios = "",
        businessScenariosName = "",
        idpurchaseInstitutionCategory = "",
        confirmOrder = "",
        maintenanceCard = "",
        maintenanceCardLimit = ""
    };
end;

--[[在线采购消息]]
function lua_purchase.purchase_msg_call(CallArgEncodeStr)
    local CallArgEncodeStr = formatNull(CallArgEncodeStr);
    local CallArgDecodeStr = lua_format.base64_decode(CallArgEncodeStr);
    local CallArg = json2table(CallArgDecodeStr);
    --[[debug_alert(
        "在线采购资产卡片维护消息，跳转至订单列表\n"..
        foreach_arg2print(CallArg).."\n"..
        ""
    );]]

    local orderId = vt("orderId",CallArg);
    local messageSubclassEn = vt("messageSubclassEn",CallArg);

    if messageSubclassEn=="ImproveAssertCardInformation" then
        --资产卡片维护消息，跳转至订单列表
        lua_purchase.page_router('order_list',{QryOrderId=orderId});
    elseif messageSubclassEn=="CgPaymentAlertBusi" then
        --公务采购支付消息，跳转至采购申请单列表待支付页签
        lua_purchase.page_router("apply_record_list",{PurchaseApplyRecordInitStatusCode="3"});
    elseif messageSubclassEn == "CgPaymentAlertWelfare" then
        --个人采购支付消息，跳转至采购订单列表
        lua_purchase.page_router('order_list',{QryOrderId=orderId});
    end;
end;

--[[采购申请补录查询复核人]]
function lua_purchase.qryReviewUser(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams);
        ReqParams["ReqAddr"] = "purchaseReq/qryReviewUser";
        ReqParams["ReqUrlExplain"] = "采购申请补录查询复核人";
        ReqParams["BusinessParams"] = table2json(ReqParams["BusinessParams"]);
        ReqParams["CloseLoading"] = "false";
        ReqParams["BusinessCall"] = lua_purchase.qryReviewUser;
        lua_jjbx.common_req(ReqParams);
    else
        local res = json2table(ResParams["responseBody"]);
        local BusinessParamsJson = json2table(vt("BusinessParamsJson",res));
        if res["errorNo"] == "000000" then
            local BusinessParams = {
                reviewerCode = vt("reviewerCode",res),
                reviewerPk = vt("reviewerPk",res),
                reviewer = vt("reviewer",res),
                djh = vt("djh",BusinessParamsJson)
            };
            lua_purchase.supplySubmit("",{BusinessParams=BusinessParams});
        else
            alert(res["errorMsg"]);
        end;
    end;
end;

--[[采购申请单补录提交]]
function lua_purchase.supplySubmit(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams);
        ReqParams["ReqAddr"] = "purchaseReq/supplySubmit";
        ReqParams["ReqUrlExplain"] = "采购申请单补录提交";
        ReqParams["BusinessParams"] = table2json(ReqParams["BusinessParams"]);
        ReqParams["BusinessCall"] = lua_purchase.supplySubmit;
        lua_jjbx.common_req(ReqParams);
    else
        close_loading();
        local res = json2table(ResParams["responseBody"]);
        if res["errorNo"] == "000000" then
            alertToast("0",C_CommitMsg,"","back_fun","");
        else
            alert(res["errorMsg"]);
        end;
    end;
end;