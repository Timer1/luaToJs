--[[用餐服务相关lua]]

lua_eat = {};

--用餐参数设置
EatArgSet = {
    --个人制度卡片滚动位置
    PRuleScrollIndex=""
};

--用餐申请单列表查询参数(EatApplyRecordListQryArg)
EARLQArg = {
    --标志位 0：查询可用申请单，1：查询失效申请单 其他：查询全部非失效申请单
    qryFlag="",

    --根据单据号搜索
    billNo="",

    --申请状态编码 有效[0：未提交，1：已提交，2：审批中，3：审批通过] 失效：[0 已完结 1 已失效 2 审批失败 3 已撤回]
    aplStatus="",
    --申请状态名称
    aplStatusName="",
    --复核状态下标 0：待补录、1：补录提交、2：复核通过、3：复核驳回
    aplReviewStatusOptionIndex="",
    --申请页面选项下标
    aplStatusOptionIndex="",

    --开始日期
    aplDateStart="",
    --结束日期
    aplDateEnd="",
    --日期区间名称
    aplDateName="",
    --日期区间选项下标
    aplDateOptionIndex="",

    --最低金额
    minAplMoney="",
    --最高金额
    maxAplMoney="",
    --金额区间名称
    AplMoneyName="",
    --金额区间选项下标
    AplMoneyOptionIndex=""
};

--用餐订单列表查询(EatOrderListQryArg)
EOLQArg = {
    --订单类型 1全部 2外卖 3到店 接口入参orderType 1全部 2外卖 3到店
    orderType="",
    --订单类型名称
    orderTypeName="",
    --订单类型选项下标
    orderTypeOptionIndex="",

    --开始日期 接口入参startCreateTime
    startTime="",
    --结束日期 接口入参endCreateTime
    endTime="",
    --时间区间名称
    TimeSectionName="",
    --时间区间选项下标
    TimeSectionOptionIndex="",

    --用餐场景 1全部 2公务 3自由  接口入参djhType 单据类型 1全部 2公务 3自由
    dinnerType="",
    --用餐场景名称
    dinnerTypeName="",
    --用餐场景选项下标
    dinnerTypeOptionIndex="",

    --排序方式 1：顺序 2：倒序 接口入参sequenceType 1顺序 2倒序 空值默认倒序
    timeOrder="",
    --排序方式名称
    timeOrderName="",
    --排序方式选项下标
    timeOrderOptionIndex=""
};

--[[页面路由]]
function lua_eat.page_router(PageName,RouterArg)
    local PageUrl = "";

    if PageName == "index" then
        --首页
        PageUrl = "jjbx_eat_service/index.xhtml";
        --重置卡片滚动位置
        EatArgSet.PRuleScrollIndex = "";
    elseif PageName == "apply" then
        --申请
        globalTable["pageType"] = "newBill";
        PageUrl = "jjbx_eat_service/apply.xhtml";
    elseif PageName == "apply_edit" then
        --申请编辑
        PageUrl = "jjbx_eat_service/apply_edit.xhtml";
    elseif PageName == "apply_detail" then
        --申请详情
        PageUrl = "jjbx_eat_service/apply_detail.xhtml";
    elseif PageName == "apply_result" then
        --申请结果
        PageUrl = "jjbx_eat_service/apply_result.xhtml";
    elseif PageName == "apply_record_list" then
        --申请单（有效）
        local EatServiceBusinessApplyListInstall = lua_system.check_app_func("EatServiceBusinessApplyList");
        if EatServiceBusinessApplyListInstall == "true" then
            PageUrl = "jjbx_eat_service/apply_record_list.xhtml";
            --分页参数初始化
            lua_page_list.init_qry_arg("eat_apply_record_list");
            --查询参数初始化
            lua_format.reset_table(EARLQArg);
            --debug_alert("前往申请单页面，初始化分页参数和查询参数");
        else
            close_loading();
            --更新提示
            local upverArg = {
                updateType="OPTION",
                updateMsg="申请单服务已经升级，请更新后使用。"
            };
            lua_ota.show_upvsr_view(upverArg);
            return;
        end;
    elseif PageName == "apply_invalid_record_list" then
        --申请单（失效）
        local EatServiceBusinessApplyListInstall = lua_system.check_app_func("EatServiceBusinessApplyList");
        if EatServiceBusinessApplyListInstall == "true" then
            PageUrl = "jjbx_eat_service/apply_invalid_record_list.xhtml";
            --分页参数初始化
            lua_page_list.init_qry_arg("eat_apply_invalid_record_list");
            --查询参数初始化（失效）
            lua_format.reset_table(EARLQArg);
            --debug_alert("前往申请单（失效）页面，初始化分页参数和查询参数");
        else
            close_loading();
            --更新提示
            local upverArg = {
                updateType="OPTION",
                updateMsg="申请单服务已经升级，请更新后使用。"
            };
            lua_ota.show_upvsr_view(upverArg);
            return;
        end;
    elseif PageName == "apply_record_use_list" then
        --公务申请单可用列表
        local EatServiceBusinessUseListInstall = lua_system.check_app_func("EatServiceBusinessUseList");
        if EatServiceBusinessUseListInstall == "true" then
            PageUrl = "jjbx_eat_service/apply_record_use_list.xhtml";
            --分页参数初始化
            lua_page_list.init_qry_arg("eat_apply_record_use_list");
            --查询参数初始化
            lua_format.reset_table(EARLQArg);
            --debug_alert("前往公务申请单可用列表页面，初始化分页参数和查询参数");
        else
            close_loading();
            --更新提示
            local upverArg = {
                updateType="OPTION",
                updateMsg="申请单服务已经升级，请更新后使用。"
            };
            lua_ota.show_upvsr_view(upverArg);
            return;
        end;
    elseif PageName=="order_list" or PageName=="budget_order_list" then
        local EatServiceOrderListInstall = lua_system.check_app_func("EatServiceOrderList");
        if EatServiceOrderListInstall == "true" then
            if PageName == "order_list" then
                --订单列表

                PageUrl = "jjbx_eat_service/order_list.xhtml";
                --分页参数初始化
                lua_page_list.init_qry_arg("eat_order_list");
                --查询参数初始化
                lua_format.reset_table(EOLQArg);
                --debug_alert("前往订单页面，初始化分页参数和查询参数");
            elseif PageName=="budget_order_list" then
                --福利预算订单列表

                PageUrl = "jjbx_eat_service/budget_order_list.xhtml";
                --分页参数初始化
                lua_page_list.init_qry_arg("budget_eat_order_list");
                --查询参数初始化
                lua_format.reset_table(EOLQArg);
                --debug_alert("前往订单页面，初始化分页参数和查询参数");
            end;
        else
            close_loading();
            --更新提示
            local upverArg = {
                updateType="OPTION",
                updateMsg="订单服务已经升级，请更新后使用。"
            };
            lua_ota.show_upvsr_view(upverArg);
            return;
        end;
    elseif PageName == "elm_order_list" then
        --饿了么订单列表
        globalTable["getElmOrderList"] = {
            TranCode="",
            orderType="0",
            timeOrder="2",
            timeOrderbm="1",
            startTime="",
            startTimebm="1",
            endTime=nowDate,
            dinnerType="0",
            dinnerTypebm="1",
            pagenum="1",
            pagesize="10",
            isClear="true",
            isLastPage="false"
        };
        globalTable["pageIndex"] = "1";
        PageUrl = "jjbx_eat_service/xhtml/eatServer_myOrder.xhtml";
    elseif PageName == "choose_receiver_addr" then
        --选择收货人
        PageUrl = "jjbx_eat_service/choose_receiver_addr.xhtml";
    elseif PageName == "receiver_addr" then
        --新增收货人
        PageUrl = "jjbx_eat_service/receiver_addr.xhtml";
    elseif PageName == "complaint_shop" then
        --投诉商店
        PageUrl = "jjbx_eat_service/complaint_shop.xhtml";
    else
        alertToast1("页面异常");
    end;

    if PageUrl ~= "" then
        local RouterArg = formatNull(RouterArg,{});
        RouterArg["CloseLoading"] = vt("CloseLoading",RouterArg,"false");
        invoke_page(PageUrl, page_callback, RouterArg);
    end;
end;

--[[查询用餐申请列表]]
function lua_eat.qry_apply_list(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams);
        ReqParams["ReqAddr"] = "mtController/queryMtMealBillList";
        ReqParams.BusinessCall = lua_eat.qry_apply_list;
        local ResCallFunc = vt("ResCallFunc",ReqParams);
        if ResCallFunc == "" then
            debug_alert("查询用餐申请列表回调未指定");
        else
            --debug_alert("查询用餐申请列表参数"..foreach_arg2print(json2table(vt("BusinessParams",ReqParams))));
            lua_jjbx.common_req(ReqParams);
        end;
    else
        local res = json2table(ResParams["responseBody"]);
        local ListData = vt("billList",res);
        --debug_alert(foreach_arg2print(ListData));
        local ListDataCounts = #ListData;
        --debug_alert(ListDataCounts);
        --更新已经加载的记录数
        local UpdateArg = {
            UpdateArgName="LoadedCounts",
            UpdateArgValue=ListDataCounts
        };
        lua_page_list.update_qry_arg(UpdateArg);
        --debug_alert("分页记录查询参数\n"..foreach_arg2print(JJBX_AppPageListQryArg));

        local ResCallFunc = vt("ResCallFunc",ResParams);
        --debug_alert("查询用餐申请列表调用回调 ResCallFunc: "..ResCallFunc);
        lua_system.do_function(ResCallFunc,res);
    end;
end;

--[[生成用餐申请单列表项数据]]
function lua_eat.gen_apply_list_item(ItemData)
    --debug_alert("生成用餐申请单列表项数据"..foreach_arg2print(ItemData));
    --卡片数据
    local ItemData = formatNull(ItemData);
    --卡片类型，可用Apply 不可用InvalidApply 默认可用
    local CardItemType = vt("CardItemType",ItemData,"Apply");

    --卡片参数
    local layOutArg = {
        --卡片整体样式 1正常 2灰显
        CardStyle="",
        --标题
        CardTitleText="单据号: "..vt("billNo",ItemData),
        --提示文字1
        CardUseText1="",
        --提示文字1样式 橘色Orange 绿色Green
        CardUseText1Class="",
        --提示文字2
        CardUseText2="",
        --提示文字2样式 橘色Orange 绿色Green
        CardUseText2Class="",
        --金额文字
        AmountText=vt("aplMoney",ItemData),
        --金额说明
        AmountTipText="申请金额(元)",
        --提示文字1
        CardTipText1="",
        --提示文字2
        CardTipText2="有效期至"..vt("availEndDate",ItemData),
        --提示文字3
        CardTipText3=vt("cause",ItemData),
        --提示文字4
        CardTipText4="",
        --提示文字4点击参数
        CardTipText4ClickArg="show_use_msg",
        --提示文字4右侧箭头图标，没有就不显示
        CardTipText4ArrowIcon="",
        --提示文字5
        CardTipText5="",
        --提示文字5点击参数
        CardTipText5ClickArg="",
        --提示文字5颜色
        CardTipText5Color="",
        --状态图标
        CardStatusIcon=""
    };

    --是否可用
    local availFlag = vt("availFlag",ItemData);
    if availFlag == "0" then
        layOutArg["CardUseText1"] = "可使用";
        layOutArg["CardUseText1Class"] = "Orange";
    end;

    --单据状态
    local billStatus = vt("billStatus",ItemData);
    local billStatusIconKey = "";
    if CardItemType == "Apply" then
        layOutArg["CardStyle"] = "1";
        --单据状态图片
        if     billStatus == "0" then billStatusIconKey = "dtj";
        elseif billStatus == "1" then billStatusIconKey = "ytj";
        elseif billStatus == "2" then billStatusIconKey = "spz";
        elseif billStatus == "3" then billStatusIconKey = "sptg";
        end;
    elseif CardItemType == "InvalidApply" then
        --失效
        layOutArg["CardStyle"] = "2";
        layOutArg["CardUseText1"] = "";
        layOutArg["CardUseText2"] = "";
        local reviewStatus = vt("reviewStatus",ItemData);
        --单据状态图片
        if reviewStatus ~= "" then
            --补录复核状态,0-未复核，1-复核提交，2-复核通过，3-复核驳回
            if     reviewStatus == "0" then billStatusIconKey = "dbl";
            elseif reviewStatus == "1" then billStatusIconKey = "bltj";
            elseif reviewStatus == "2" then billStatusIconKey = "fhtg";
            elseif reviewStatus == "3" then billStatusIconKey = "fhbh";
            end;
        else
            if     billStatus == "0" then billStatusIconKey = "ywj";
            elseif billStatus == "1" then billStatusIconKey = "ygq";
            elseif billStatus == "2" then billStatusIconKey = "spsb";
            elseif billStatus == "3" then billStatusIconKey = "ych";
            end;
        end;
    end;
    layOutArg["CardStatusIcon"] = status_icon(billStatusIconKey);

    --使用时间信息
    if CardItemType == "Apply" then
        local timeInfoList = vt("timeInfoList",ItemData);
        local timeInfoCounts = #timeInfoList;
        --debug_alert(foreach_arg2print(timeInfoList));
        if timeInfoCounts == 0 then
            --没有维护使用信息时，显示缺省信息，不可点击
            layOutArg["CardTipText4"] = "使用时间不限制";
        elseif timeInfoCounts == 1 then
            --维护使用信息只有一条时，显示该信息，不可点击
            layOutArg["CardTipText4"] = vt("timeString",timeInfoList[1]);
        else
            --维护使用信息多于一条时，显示按钮
            layOutArg["CardTipText4"] = "使用说明";
            layOutArg["CardTipText4ArrowIcon"] = "arrow_mine.png";
        end;
    end;

    local mealType = vt("mealType",ItemData);
    if mealType == "0" then
        mealType = "外卖";
    elseif mealType == "1" then
        mealType = "到店";
    elseif mealType == "2" then
        mealType = "到店、外卖通用";
    else
        mealType = "-";
    end;
    layOutArg["CardTipText1"] = mealType;

    --共享人逻辑处理
    if CardItemType == "Apply" then
        --被共享人pkUser
        local sharePkUser = vt("sharePkUser",ItemData);
        --被共享人姓名
        local shareName = vt("shareName",ItemData);
        --共享他人使用限制 0-允许 1-不允许
        local shareFlag = vt("shareFlag",ItemData);

        --可用且可共享
        if shareFlag=="0" and availFlag=="0" then
            --已共享时，显示名字
            if shareName~="" and sharePkUser~="" then
                layOutArg["CardTipText5"] = "已共享给："..cutStr(shareName,4).."　取消共享";
                layOutArg["CardTipText5Color"] = "#427EE4";
            else
                layOutArg["CardTipText5"] = "共享";
            end;
            layOutArg["CardTipText5ClickArg"] = "share_ctrl";
            layOutArg["CardTipText5Color"] = "#427EE4";
        end;
    end;

    --返回
    return layOutArg;
end;

--[[查询用餐订单列表]]
function lua_eat.qry_order_list(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams);
        local ReqAddr = vt("ReqAddr",ReqParams,"mtController/queryMtOrderList")
        ReqParams["ReqAddr"] = ReqAddr;
        ReqParams.BusinessCall = lua_eat.qry_order_list;
        local ResCallFunc = vt("ResCallFunc",ReqParams);
        if ResCallFunc == "" then
            debug_alert("查询用餐订单列表回调未指定");
        else
            --debug_alert("查询用餐订单列表参数"..foreach_arg2print(json2table(vt("BusinessParams",ReqParams))));
            lua_jjbx.common_req(ReqParams);
        end;
    else
        local res = json2table(ResParams["responseBody"]);
        local ListData = vt("mtOrderList",res);
        --debug_alert(foreach_arg2print(ListData));
        local ListDataCounts = #ListData;
        --debug_alert(ListDataCounts);
        --更新已经加载的记录数
        local UpdateArg = {
            UpdateArgName="LoadedCounts",
            UpdateArgValue=ListDataCounts
        };
        lua_page_list.update_qry_arg(UpdateArg);
        --debug_alert("分页记录查询参数\n"..foreach_arg2print(JJBX_AppPageListQryArg));

        local ResCallFunc = vt("ResCallFunc",ResParams);
        --debug_alert("查询用餐订单列表调用回调 ResCallFunc: "..ResCallFunc);
        lua_system.do_function(ResCallFunc,res);
    end;
end;

--[[美团h5登录]]
function lua_eat.mt_h5_login(Arg)
    local MTH5LoginBusinessParams = vt("MTH5LoginBusinessParams",Arg);
    local ReqParams = {
        ReqUrlExplain="获取用餐登陆H5地址（美团）",
        BusinessParams=table2json(MTH5LoginBusinessParams)
    };
    lua_eat.h5_open_ctrl("",ReqParams);
end;

--[[用餐H5跳转处理]]
function lua_eat.h5_open_ctrl(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams);
        ReqParams["ReqAddr"] = "mtController/fetchMtLoginUrl";
        ReqParams.BusinessCall = lua_eat.h5_open_ctrl;
        ReqParams.ArgStr = ReqParams.BusinessParams;

        --debug_alert("用餐H5跳转处理参数"..foreach_arg2print(json2table(vt("BusinessParams",ReqParams))));
        lua_jjbx.common_req(ReqParams);
    else
        local res = json2table(ResParams["responseBody"]);

        local ResCallFunc = vt("ResCallFunc",ResParams);
        if ResCallFunc ~= "" then
            --debug_alert("用餐H5跳转处理调用回调 ResCallFunc: "..ResCallFunc);
            lua_system.do_function(ResCallFunc,res);
        else
            local errorNo = vt("errorNo",res);
            local errorMsg = vt("errorMsg",res);
            if errorNo ~= "000000" then
                if errorMsg == "" then
                    alert("获取用餐页面失败");
                else
                    alert(errorMsg);
                end;
            else
                --获取请求数据
                local ReqArg = json2table(vt("ArgStr",ResParams));
                --公务校验提示
                local tipMsg = vt("tipMsg",res);
                local AlertWebviewArg = {
                    title = "美团",
                    visit_url = vt("url",res),
                    back_type = "BACK",
                    close_call_func = "eat_h5_close_call",
                    listen_url = "http://app_h5_callback_url",
                    listen_call = "lua_system.webview_h5_callback",
                    AddUserAgent = "/CZBANK/JJBXAPP"
                };
                local EncodeTable = {
                    --H5控件打开参数
                    AlertWebviewArg=AlertWebviewArg,
                    --业务控制参数
                    BusinessCtrlArg={
                        --跳转入口
                        entrance=vt("entrance",ReqArg),
                        --跳转是否提示 0提示 1不提示
                        promptFlag=vt("promptFlag",res),
                        --跳转提示
                        promptInf=vt("promptInf",res)
                    }
                };
                local EncodeArg = lua_format.table_arg_pack(EncodeTable);
                if tipMsg ~= "" then
                    alert_confirm("",tipMsg,"","确定","alert_confirm_call","CallFun=lua_eat.open_mt_page&CallArg="..EncodeArg);
                else
                    lua_eat.open_mt_page(EncodeArg);
                end;
            end;
        end;
    end;
end;

--[[打开美团页面]]
function lua_eat.open_mt_page(EncodeArg)
    local DecodeArg = lua_format.table_arg_unpack(EncodeArg);
    --页面打开参数
    local AlertWebviewArg = vt("AlertWebviewArg",DecodeArg);
    --业务控制参数
    local BusinessCtrlArg = vt("BusinessCtrlArg",DecodeArg);
    --debug_alert(foreach_arg2print(BusinessCtrlArg));

    --跳转是否提示 0提示 1不提示
    local promptFlag = vt("promptFlag",BusinessCtrlArg);
    --跳转提示
    local promptInf = vt("promptInf",BusinessCtrlArg,"未获取到提示信息");

    if promptFlag == "0" then
        alertTip("",promptInf,"不再提示","","知道了","lua_eat.open_mt_page_tip_call",EncodeArg);
    else
        close_loading();
        lua_system.alert_webview(AlertWebviewArg);
    end;
end;

--[[打开美团页面提示框回调]]
function lua_eat.open_mt_page_tip_call(sureFlag,checkFlag,EncodeArg)
    --[[debug_alert(
        "打开美团页面提示框回调:".."\n"..
        "sureFlag : "..sureFlag.."\n"..
        "checkFlag : "..checkFlag.."\n"..
        "EncodeArg : "..EncodeArg.."\n"..
        ""
    );]]

    local DecodeArg = lua_format.table_arg_unpack(EncodeArg);
    --页面打开参数
    local AlertWebviewArg = vt("AlertWebviewArg",DecodeArg);
    --业务控制参数
    local BusinessCtrlArg = vt("BusinessCtrlArg",DecodeArg);
    --debug_alert(foreach_arg2print(BusinessCtrlArg));
    --跳转入口
    local entrance = vt("entrance",BusinessCtrlArg);
    --状态更新类型
    local upFlag = "";
    if entrance=="A" or entrance=="B" then
        --公务可用、个人制度提示
        upFlag = "5";
    else
        --订单详情提示
        upFlag = "6";
    end;

    if upFlag~="" and tonumber(checkFlag)==1 then
        local BusinessParams = {
            flag=upFlag,
            --消息内容也送给后台进行版本控制判断
            value=vt("promptInf",BusinessCtrlArg)
        };
        --更新提示状态
        local ReqParams = {
            ReqUrlExplain="更新用餐不再提示状态",
            BusinessParams=table2json(BusinessParams)
        };
        lua_eat.update_tip_status("",ReqParams);
    end;

    close_loading();
    lua_system.alert_webview(AlertWebviewArg);
end;

--[[用餐订单状态转换]]
function lua_eat.order_status_info(OrderData)
    --debug_alert("用餐订单状态转换"..foreach_arg2print(OrderData));
    --支付状态(payStatus) 10：未支付 20：已支付 31：部分退款 32：全额退款
    local payStatus = vt("payStatus",OrderData);
    --配送状态(logisticsStatus) 0：默认值 1：已推送给配送方(骑手未接单) 10：已抢单 20：已取餐 40：已送达 100：已取消
    local logisticsStatus = vt("logisticsStatus",OrderData);
    --订单状态(orderStatus) 1：提交订单 2：向餐厅推单 4：已接单 8：已完成 9：已取消
    local orderStatus = vt("orderStatus",OrderData);
    --4外卖 其他到店
    local orderType = vt("orderType",OrderData);

    local OrderStatusName = "订单状态未知";
    if orderType == "4" then
        if orderStatus == "1" then
            if payStatus == "10" then
                OrderStatusName = "未支付";
            end;
        elseif orderStatus == "2" then OrderStatusName = "等待商家接单";
        elseif orderStatus == "4" then
            if logisticsStatus == "20" then OrderStatusName = "已取餐";
            elseif logisticsStatus == "40" then OrderStatusName = "已送达";
            else OrderStatusName = "已接单";
            end;
        elseif orderStatus == "8" then OrderStatusName = "已完成";
        elseif orderStatus == "9" then OrderStatusName = "已取消";
        end;
    else
        --到店取支付状态
        --支付状态(payStatus) 10：未支付 20：已支付 31：部分退款 32：全额退款
        if     payStatus == "10" then OrderStatusName = "未支付";
        elseif payStatus == "20" then OrderStatusName = "已支付";
        elseif payStatus == "31" then OrderStatusName = "部分退款";
        elseif payStatus == "32" then OrderStatusName = "全额退款";
        end;
    end;

    return OrderStatusName;
end;

--[[查看用餐订单详情]]
function lua_eat.order_detail(OrderData)
    --单据类型 0公务 1自由
    local djType = vt("djType",OrderData);
    --订单号
    local orderNo = vt("orderNo",OrderData);
    --订单手机号
    local phone = vt("phone",OrderData);
    local budgetKey = vt("budgetkey",OrderData);
    if orderNo=="" or phone=="" then
        alert("订单信息不完整");
    else
        local BusinessParams = {
            loginFlag="1",
            sqtOrderId=orderNo,
            staffNo=phone,
            budgetKey=budgetKey
        };
        --debug_alert(foreach_arg2print(BusinessParams));
        local ReqParams = {
            ReqUrlExplain="获取用餐订单详情H5地址（美团）",
            BusinessParams=table2json(BusinessParams)
        };
        lua_eat.h5_open_ctrl("",ReqParams);
    end;
end;

--[[更新提示状态]]
function lua_eat.update_tip_status(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams);
        --flag 3-服务费提示 4-定位提示 5-公务可用、个人制度提示 6-订单详情提示
        ReqParams["ReqAddr"] = "mtController/saveMtPromptInfo";
        ReqParams.BusinessCall = lua_eat.update_tip_status;
        lua_jjbx.common_req(ReqParams);
    else
        close_loading();
        local res = json2table(ResParams["responseBody"]);
        local errorNo = vt("errorNo",res);
        local errorMsg = vt("errorMsg",res);
        if errorNo ~= "000000" then
            alert(errorMsg);
        end;
    end;
end;

--[[显示使用说明]]
function lua_eat.show_use_msg(ItemEncodeData)
    --条目数据解码
    local ItemDecodeData = lua_format.table_arg_unpack(ItemEncodeData);
    local ShowUseMsg = "";
    local timeInfoList = vt("UseTimeInfo",ItemDecodeData);
    local timeInfoCounts = #timeInfoList;
    --debug_alert(foreach_arg2print(timeInfoList));
    if timeInfoCounts > 1 then
        --维护使用信息多于一条时，循环拼接
        for i=1, timeInfoCounts do
            ShowUseMsg = ShowUseMsg.."\n"..vt("timeString",timeInfoList[i]);
        end;
    else
        --没有维护使用信息或只有一条时，不弹窗显示
        ShowUseMsg = "";
    end;

    if ShowUseMsg ~= "" then
        local AlertArg = {
            titleMsg="使用说明",
            alertMsg=lua_format.url_encode(ShowUseMsg),
            msgEncodeType="url_encode"
        };
        lua_system.app_alert(AlertArg);
    else
        if timeInfoCounts > 1 then
            --大于1条时才提供点击事件
            alert("没有使用说明信息");
        else
            debug_alert("没有使用说明信息");
        end;
    end;
end;

--[[查询管控地址]]
function lua_eat.qry_ctrl_addr(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams);
        ReqParams["ReqAddr"] = "mtController/qryMtAdress";
        ReqParams.BusinessCall = lua_eat.qry_ctrl_addr;
        local ResCallFunc = vt("ResCallFunc",ReqParams);
        if ResCallFunc == "" then
            debug_alert("查询管控地址回调未指定");
        else
            --debug_alert("查询管控地址参数"..foreach_arg2print(json2table(vt("BusinessParams",ReqParams))));
            lua_jjbx.common_req(ReqParams);
        end;
    else
        local res = json2table(ResParams["responseBody"]);
        local ResCallFunc = vt("ResCallFunc",ResParams);
        local ArgStr = vt("ArgStr",ResParams);
        local errorNo = vt("errorNo",res);
        local errorMsg = vt("errorMsg",res);
        if errorNo ~= "000000" then
            alert(errorMsg);
        else
            --debug_alert("查询管控地址调用回调 ResCallFunc: "..ResCallFunc);
            res["ResCallArgStr"] = ArgStr;
            lua_system.do_function(ResCallFunc,res);
        end;
    end;
end;

--[[订单金额信息处理]]
function lua_eat.order_fee_text_deal(OrderData)
    local OrderData = formatNull(OrderData);
    local AmountText = "";
    local AmountTipText = "";

    if OrderData ~= "" then
        local wmTotal = tonumber(vt("wmTotal",OrderData,"0"));
        local ddTotal = tonumber(vt("ddTotal",OrderData,"0"));
        --服务费
        local serviceFeeByPay = tonumber(vt("serviceFeeByPay",OrderData,"0"));
        --后结算服务费(退款服务费)
        local serviceRefundFee = tonumber(vt("serviceFee",OrderData,"0"));
        --企业支付
        local entPayFee = tonumber(vt("entPayFee",OrderData,"0"));
        --个人支付
        local empPayFee = tonumber(vt("empPayFee",OrderData,"0"));
        --企业退款
        local entRefundFee = tonumber(vt("entRefundFee",OrderData,"0"));
        --个人退款
        local empRefundFee = tonumber(vt("empRefundFee",OrderData,"0"));
        --服务费随单扣标志
        local withorderfeeFlag = vt("withorderfeeFlag",OrderData,"0");

        --4外卖取外卖金额
        local orderType = vt("orderType",OrderData);
        if orderType == "4" then
            AmountText = wmTotal;
        else
            AmountText = ddTotal;
        end;

        --支付状态
        local payStatus = vt("payStatus",OrderData);

        if withorderfeeFlag == "0" then
            --服务费随单扣标志为0：不随单扣
            AmountText = formatMoney(AmountText);
            if payStatus=="31" or payStatus=="32" then
                if formatMoney(empRefundFee)=="0.00" then
                    --个人支付为0,不显示
                    AmountTipText = "含企业退款:"..formatMoney(entRefundFee).."元";
                else    
                    --显示企业/个人退款
                    AmountTipText = "含企业退款:"..formatMoney(entRefundFee).."元 个人退款:"..formatMoney(empRefundFee).."元";
                end;
            elseif payStatus=="10" then
                --支付状态为10：未支付
                AmountTipText = "";
            else
                if formatMoney(empPayFee)=="0.00" then
                    AmountTipText = "含企业支付"..formatMoney(entPayFee).."元";
                else
                    AmountTipText = "含企业支付:"..formatMoney(entPayFee).."元 个人支付:"..formatMoney(empPayFee).."元";
                end;
            end;
        else
            --服务费随单扣标志为1：随单扣
            AmountText = formatMoney(AmountText + serviceFeeByPay);
            if payStatus=="31" or payStatus=="32" then
                if formatMoney(empRefundFee)=="0.00" then
                    --支付状态为31：部分退款 32：全额退款
                    AmountTipText = "含服务费退款:"..formatMoney(serviceRefundFee).."元 企业退款:"..formatMoney(entRefundFee).."元";
                else
                     AmountTipText = "含服务费退款:"..formatMoney(serviceRefundFee).."元 企业退款:"..formatMoney(entRefundFee).."元 个人退款:"..formatMoney(empRefundFee).."元";            
                end;
            elseif payStatus=="10" then
                --支付状态为10：未支付
                AmountTipText = "";
            else
                AmountTipText = "含服务费"..formatMoney(serviceFeeByPay).."元 企业支付"..formatMoney(entPayFee).."元 个人支付"..formatMoney(empPayFee).."元";
            end;    
        end;
    end;

    local Res = {
        AmountText = AmountText,
        AmountTipText = AmountTipText
    };
    return Res;
end;

--[[扫码支付]]
function lua_eat.scan_to_pay(Arg)
    local Arg = formatNull(Arg);

    --打开摄像头扫码
    local OpenArg = {
        --扫描回调方法
        ScanCallFunc="lua_eat.scan_call",
        --扫描回调方法入参
        ScanCallFuncSetArg="eat to pay",
    };
    --[[debug_alert(
        "用餐调起扫码控件\n"..
        "H5通过接口传递给APP的参数："..foreach_arg2print(Arg).."\n"..
        "打开摄像头调用扫码的参数："..foreach_arg2print(OpenArg).."\n"..
        ""
    );]]
    lua_system.open_scan_by_camera(OpenArg);
end;

--[[扫码回调]]
function lua_eat.scan_call(ScanArg,CallArg)
    --扫码结果，已编码
    local ScanArg = formatNull(ScanArg);
    --扫码回调传参
    local CallArg = formatNull(CallArg);
    --结果解码
    local ScanRes = lua_format.base64_decode(ScanArg);

    --[[debug_alert(
        "扫码回调\n"..
        "扫码结果 : "..ScanArg.."\n"..
        "结果解码 : "..ScanRes.."\n"..
        "回调参数 : "..CallArg.."\n"..
        ""..
        "查找http  : "..tostring(string.find(ScanRes,"http://")).."\n"..
        "查找https : "..tostring(string.find(ScanRes,"https://")).."\n"..
        ""
    );]]

    if ScanRes ~= "" then
        if string.find(ScanRes,"http://")==1 or string.find(ScanRes,"https://")==1 then
            local EncodeTable = {
                --H5控件打开参数
                AlertWebviewArg = {
                    title = "用餐服务",
                    visit_url = ScanRes,
                    back_type = "BACK",
                    close_call_func = "eat_h5_close_call"
                }
            };
            local EncodeArg = lua_format.table_arg_pack(EncodeTable);
            lua_eat.open_mt_page(EncodeArg);
        else
            alert("非美团二维码");
        end;
    else
        alert("未获取到扫描结果");
    end;
end;
