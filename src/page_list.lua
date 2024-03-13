--[[列表分页]]

lua_page_list = {};

--分页查询参数
JJBX_AppPageListQryArg = {
    --参数加载页面
    LoadedPageName="",
    --查询页码
    AppQryPageNum=1,
    --每页查询记录数
    AppQryPageSize=10,
    --客户端最后一次查看的列表下标，用于返回时候页面数据查询
    ClientLastItemIndex=1,
    --已经加载的数据量
    LoadedCounts=0,
    --是否初始化查询
    ReloadAppQryPage="true"
};

--客户端列表选择参数
C_ClientListSelectListArg ={
    --选中的列表ID编号
    SelectedIdListStr = "",
    --搜索关键字
    SearchKeyWords = "",
    --全选类型 0不全选 1全选
    SelectAllType = ""
};

--[[列表分页参数初始化]]
function lua_page_list.init_qry_arg(PageName,InitType)
    --加载页面名称
    local PageName = formatNull(PageName);
    --已加载的页面名称
    local LoadedPageName = vt("LoadedPageName",JJBX_AppPageListQryArg);
    --加载类型
    --Auto:已经加载的情况下不覆盖
    --Force:强制覆盖
    local InitType = formatNull(InitType,"Auto");

    --[[debug_alert(
        "列表分页参数初始化\n"..
        "PageName : "..PageName.."\n"..
        "LoadedPageName : "..LoadedPageName.."\n"..
        "InitType : "..InitType.."\n"..
        ""
    );]]

    --重置分页查询参数
    if InitType=="Force" or LoadedPageName~=PageName then
        --debug_alert("当前页面未加载分页参数，或指定了为强制加载时重置分页查询参数");
        lua_jjbx.reset_config_arg("JJBX_AppPageListQryArg");
    end;

    --设置分页参数加载页面
    JJBX_AppPageListQryArg.LoadedPageName = PageName;
end;

--[[更新参数]]
function lua_page_list.update_qry_arg(UpdateArg)
    local UpdateArgName = vt("UpdateArgName",UpdateArg);
    local UpdateArgValue = vt("UpdateArgValue",UpdateArg);

    if UpdateArgName == "LoadedCounts" then
        --更新已经加载的数据量
        local TotalCountsNow = 0;
        if JJBX_AppPageListQryArg.AppQryPageNum == 1 then
            --查询为第一页（初始查询、点击条目后的全量查询）的时候，直接设置
            TotalCountsNow = tonumber(UpdateArgValue);
        elseif JJBX_AppPageListQryArg.AppQryPageNum > 1 then
            --查询其他页码时，根据页码和条目数进行计算
            TotalCountsNow = (JJBX_AppPageListQryArg.AppQryPageNum-1)*JJBX_AppPageListQryArg.AppQryPageSize+tonumber(UpdateArgValue);
        end;
        JJBX_AppPageListQryArg.LoadedCounts = TotalCountsNow;
    end;

    --[[debug_alert(
        "更新参数\n"..
        foreach_arg2print(JJBX_AppPageListQryArg)..
        ""
    );]]
end;

--[[查询参数准备]]
function lua_page_list.qry_arg_prepare(ClientIndexInput,QryType)
    local ClientIndex = formatNull(ClientIndexInput);
    local QryType = formatNull(QryType,"NormalQry");

    --参数准备前
    local ArgPirntStrBefore = foreach_arg2print(JJBX_AppPageListQryArg);

    if QryType == "NormalQry" then
        --[[
            （点击详情、删除）操作场景会在返回时查询全量数据
            比如当前查询条目总数为30条，分3次查询，页码为123，查询条目为10，即3X10。操作条目为27条，返回到列表时需要将30条一次性查询完成，页码为1，查询条目为30，即1X30。
            上拉刷新完成后需要将页码还原
        ]]
        if tonumber(JJBX_AppPageListQryArg.AppQryPageSize) > 10 then
            JJBX_AppPageListQryArg.AppQryPageNum = (JJBX_AppPageListQryArg.AppQryPageSize/10)+1;
            JJBX_AppPageListQryArg.AppQryPageSize = 10;
        else
            JJBX_AppPageListQryArg.AppQryPageNum = JJBX_AppPageListQryArg.AppQryPageNum + 1;
        end;
        JJBX_AppPageListQryArg.ClientLastItemIndex = ClientIndex;
    else
        if QryType=="QryAfterDetail" or QryType=="QryAfterClick" then
            --查看详情和元素点击时，将锚定下标改为操作的下标
            JJBX_AppPageListQryArg.ClientLastItemIndex = ClientIndex;
        elseif QryType == "QryAfterDelete" then
            --删除后需要将锚定下标改为前一个
            JJBX_AppPageListQryArg.ClientLastItemIndex = "";
            if ClientIndex > 1 then
                JJBX_AppPageListQryArg.ClientLastItemIndex = ClientIndex - 1;
            else
                JJBX_AppPageListQryArg.ClientLastItemIndex = 1;
            end;
        end;

        --一页查询出已经加载过的全部数据
        JJBX_AppPageListQryArg.AppQryPageNum = 1;
        --默认一页查10条
        JJBX_AppPageListQryArg.AppQryPageSize = 10;
        --已加载条目数
        local calculateLoadedCounts = tonumber(JJBX_AppPageListQryArg.LoadedCounts);
        if calculateLoadedCounts > 10 then
            local paddingCounts = 0;
            --除以10取余，获取需要填充的数值
            local lastNum = calculateLoadedCounts%10;
            if lastNum > 0 then
                paddingCounts = 10-lastNum;
            end;

            --[[debug_alert(
                "calculateLoadedCounts : "..calculateLoadedCounts.."\n"..
                "lastNum : "..lastNum.."\n"..
                "paddingCounts : "..paddingCounts.."\n"..
                ""
            );]]

            --计算出已经加载的条目数所对应的pagesize
            JJBX_AppPageListQryArg.AppQryPageSize = calculateLoadedCounts+paddingCounts;
        end;
    end;

    --参数准备后
    local ArgPirntStrAfter = foreach_arg2print(JJBX_AppPageListQryArg);

    --[[debug_alert(
        "分页参数准备\n"..
        "ClientIndexInput : "..ClientIndexInput.."\n"..
        "QryType : "..QryType.."\n"..
        "修改后"..ArgPirntStrAfter.."\n"..
        --"修改前"..ArgPirntStrBefore.."\n\n"..
        ""
    );]]
end;

--[[生成客户端列表控件数据]]
function lua_page_list.gen_app_list_widget_data(PageData,WidgetCtrlArg,ListItemArg)
    --页面数据
    local PageData = formatNull(PageData);
    --控件操作数据
    local WidgetCtrlArg = formatNull(WidgetCtrlArg);
    --列表条目数据
    local ListItemArg = formatNull(ListItemArg);
    --列表条目数量
    local ListItemCounts = #ListItemArg;

    --当前页号
    local ResPageNum = vt("pagenum",PageData);
    --当前页记录数
    local ResPageCnt = vt("pagecnt",PageData);
    --总页数
    local ResTotalPage = vt("totalpage",PageData);
    --总记录数
    local ResTotalCnt = vt("totalcnt",PageData);

    --上拉方法
    local upFuncName = "";
    --是否允许上拉控件
    local AllowUpCtrlWidget = vt("AllowUpCtrlWidget",WidgetCtrlArg,"Auto");
    if AllowUpCtrlWidget == "Auto" then
        --根据页码自动计算是否还有内容可以上拉追加
        if ResPageNum == ResTotalPage then
            --当前页码等于总页数时，不允许上拉
            upFuncName = "";
        else
            --其他情况允许上拉
            upFuncName = "lua_page_list.upFunc";
        end;
    elseif AllowUpCtrlWidget == "false" then
        --强制修改为不允许上拉
        upFuncName = "";
    elseif AllowUpCtrlWidget == "true" then
        --强制修改为允许上拉
        upFuncName = "lua_page_list.upFunc";
    else
        --其他情况不允许上拉
        upFuncName = "";
    end;

    --下拉方法
    local downFuncName="";
    --是否允许下拉控件
    local AllowDownCtrlWidget = vt("AllowDownCtrlWidget",WidgetCtrlArg,"true");
    if AllowDownCtrlWidget == "true" then
        --允许下拉
        downFuncName="lua_page_list.downFunc";
    else
        --不允许下拉
        downFuncName="";
    end;

    --单选回调
    local singleSelectCallFun = vt("singleSelectCallFun",WidgetCtrlArg);
    --多选回调
    local multipleSelectCallFun = vt("multipleSelectCallFun",WidgetCtrlArg);

    --选择类型
    local selectType = "";
    --选择方法
    local selectFunc = "";
    --选择方法回调
    local selectCallFun = "";
    if singleSelectCallFun=="" and multipleSelectCallFun=="" then
        --debug_alert("没有指定单选或多选");
    elseif singleSelectCallFun~="" and multipleSelectCallFun~="" then
        --debug_alert("只能指定单选或多选");
    else
        if singleSelectCallFun ~= "" then
            --debug_alert("单选");
            selectType = "single";
            --指定为单选选择的回调
            selectCallFun = singleSelectCallFun;
        else
            --debug_alert("多选");
            selectType = "multiple";
            --指定为多选选择的回调
            selectCallFun = multipleSelectCallFun;
        end;
        selectFunc = "lua_page_list.itemSelectFunc";
    end;

    --控件操作参数（table格式，客户端会转为json回传）
    local widgetCtrlTableArg = {
        --上拉回调函数
        upFunCallFun=vt("upFunCallFun",WidgetCtrlArg),
        --下拉回调函数
        downFunCallFun=vt("downFunCallFun",WidgetCtrlArg),
        --选择回调函数
        selectCallFun=selectCallFun
    };

    --客户端列表控件数据
    local AppListWidgetTableData = {
        --上拉方法
        upFunc=upFuncName,
        --上拉方法参数，客户端调用时回传
        upFuncArg=widgetCtrlTableArg,
        --下拉方法
        downFunc=downFuncName,
        --下拉方法参数，客户端调用时回传
        downFuncArg=widgetCtrlTableArg,
        --选择类型 单选:single 多选:multiple
        selectType=selectType,
        --选择方法，为空时不调用，入参1:点击的json节点数据，入参2:点击的下标
        selectFunc=selectFunc,
        --选择方法参数，客户端调用时回传
        selectFuncArg=widgetCtrlTableArg,
        --是否允许从右往左滑动
        slipRight2Left=vt("slipRight2Left",WidgetCtrlArg),
        --客户端默认追加列表至缓存中，true值客户端会先清理现有缓存
        listReload=JJBX_AppPageListQryArg.ReloadAppQryPage,
        --列表锚点下标
        anchorPointIndex=JJBX_AppPageListQryArg.ClientLastItemIndex,
        --列表集合数据
        listData={}
    };

    --[[debug_alert(
        "生成客户端列表控件数据\n"..
        "当前页号 : "..ResPageNum.."\n"..
        "当前页记录数 : "..ResPageCnt.."\n"..
        "总页数 : "..ResTotalPage.."\n"..
        "总记录数 : "..ResTotalCnt.."\n"..
        "允许上拉"..AllowUpCtrlWidget.."\n"..
        "允许下拉"..AllowDownCtrlWidget.."\n"..
        "上拉方法"..upFuncName.."\n"..
        "下拉方法"..downFuncName.."\n"..
        "选择类型"..selectType.."\n"..
        "选择方法"..selectFunc.."\n"..
        "条目数量"..tostring(ListItemCounts).."\n\n"..
        --"页面数据"..foreach_arg2print(PageData).."\n\n"..
        --"控件参数"..foreach_arg2print(WidgetCtrlArg).."\n\n"..
        --"条目数据"..foreach_arg2print(ListItemArg).."\n\n"..
        "客户端列表控件数据"..foreach_arg2print(AppListWidgetTableData).."\n\n"..
        ""
    );]]

    --客户端列表控件单条数据
    local AppListItemTableData = {};
    for i=1, ListItemCounts do
        --当前条目参数
        local ListItem = ListItemArg[i];

        --条目回调参数
        local iTemCallBackArg = vt("iTemCallBackArg",ListItem);
        --debug_alert("条目回调参数"..foreach_arg2print(iTemCallBackArg));

        --是否允许删除，不传回调认为不可删除
        local delFun = "lua_page_list.delFun";
        if vt("deleteCallFunc",iTemCallBackArg) == "" then
            delFun = "";
        end;

        --是否允许点击查看详情，不传回调认为不可查看详情
        local detailFun = "lua_page_list.detailFun";
        if vt("detailCallFun",iTemCallBackArg) == "" then
            detailFun = "";
        end;

        --是否允许点击条目，不传回调认为不可点击条目
        local clickFun = "lua_page_list.itemClickFun";
        if vt("clickCallFun",iTemCallBackArg) == "" then
            clickFun="";
        end;

        local addItemData = {
            --删除方法，为空时不调用，入参1:当前json节点数据
            delFun=delFun,
            --整个条目点击方法，为空时不调用，入参1:当前json节点数据
            detailFun=detailFun,
            --条目元素点击方法，为空时不调用，入参1:点击的json节点数据和点击参数，点击参数用来区分点击的哪个区域
            clickFun=clickFun,
            --页面布局参数
            layOutArg=vt("layOutArg",ListItem),
            --条目回调参数
            iTemCallBackArg=iTemCallBackArg,
            --业务回调参数
            BusinessCallBackArg=vt("BusinessCallBackArg",ListItem)
        };
        table.insert(AppListItemTableData,addItemData)
    end;
    --客户端客户端列表控件数据集合
    AppListWidgetTableData.listData = AppListItemTableData;

    --debug_alert("客户端客户端列表控件数据Table"..foreach_arg2print(AppListWidgetTableData));
    local AppListWidgetJsonData = table2json(AppListWidgetTableData)
    --debug_alert("客户端客户端列表控件数据Json\n"..AppListWidgetJsonData);

    return AppListWidgetJsonData;
end;

--[[列表方法-上拉]]
function lua_page_list.upFunc(UpFuncJsonArg)
    local UpFuncJsonArg = formatNull(UpFuncJsonArg);
    local UpFuncTableArg = json2table(UpFuncJsonArg);
    --debug_alert("列表上拉方法"..foreach_arg2print(UpFuncTableArg));
    local upFunCallFun = vt("upFunCallFun",UpFuncTableArg);

    --上拉不刷新列表
    JJBX_AppPageListQryArg.ReloadAppQryPage = "false";

    --上拉时计算下标，设置为下一页的第一条
    local ClientIndex = (JJBX_AppPageListQryArg.AppQryPageSize*JJBX_AppPageListQryArg.AppQryPageNum)+1;

    --将查询参数初始化为正常查询
    lua_page_list.qry_arg_prepare(ClientIndex,"NormalQry");

    --上拉的时候不锚定位置，给0即可
    JJBX_AppPageListQryArg.ClientLastItemIndex = 0;

    --debug_alert("分页参数准备：列表上拉"..foreach_arg2print(JJBX_AppPageListQryArg));

    --调用上拉回调
    lua_system.do_function(upFunCallFun,"");
end;

--[[列表方法--下拉]]
function lua_page_list.downFunc(DownFuncJsonArg)
    local DownFuncJsonArg = formatNull(DownFuncJsonArg);
    local DownFuncTableArg = json2table(DownFuncJsonArg);
    --debug_alert("列表下拉方法"..foreach_arg2print(DownFuncTableArg));
    local downFunCallFun = vt("downFunCallFun",DownFuncTableArg);

    --重置分页查询参数
    lua_jjbx.reset_config_arg("JJBX_AppPageListQryArg");

    --debug_alert("分页参数准备：列表下拉"..foreach_arg2print(JJBX_AppPageListQryArg));

    --调用下拉回调
    lua_system.do_function(downFunCallFun,"");
end;

--[[列表方法-条目选择]]
function lua_page_list.itemSelectFunc(JsonData,SelectFuncJsonArg,SelectType,ClientIndex)
    --当前点击的条目信息
    local JsonData = formatNull(JsonData);
    --当前点击的条目下标
    local ClientIndex = tonumber(formatNull(ClientIndex,"1"));
    --控件传递的参数
    local SelectFuncJsonArg = formatNull(SelectFuncJsonArg);
    local SelectFuncTableArg = json2table(SelectFuncJsonArg);
    --选中状态 0未选中 1选中
    local SelectType = formatNull(SelectType,"1");
    local TableData = json2table(JsonData);

    --[[debug_alert(
        "列表条目元素选择方法\n"..
        "客户端下标 : "..ClientIndex.."\n"..
        "选中状态 : "..SelectType.."\n"..
        --"Json数据 : "..JsonData.."\n"..
        "Table数据 : "..foreach_arg2print(TableData).."\n"..
        ""
    );]]

    --选择回调
    local selectCallFun = vt("selectCallFun",SelectFuncTableArg);
    --debug_alert("选择回调方法"..selectCallFun);

    --将查询参数初始化为全量查询
    lua_page_list.qry_arg_prepare(ClientIndex,"QryAfterClick");

    --debug_alert("分页参数准备：列表元素选择"..foreach_arg2print(JJBX_AppPageListQryArg));

    local BusinessCallBackArg = vt("BusinessCallBackArg",TableData);
    --追加选择状态
    BusinessCallBackArg["SelectType"] = SelectType;
    --追加客户端下标
    BusinessCallBackArg["ClientIndex"] = ClientIndex;

    --调用元素点击回调
    lua_system.do_function(selectCallFun,BusinessCallBackArg);
end;

--[[卡片方法-查看详情]]
function lua_page_list.detailFun(JsonData,ClientIndex)
    local ClientIndex = tonumber(formatNull(ClientIndex,"1"));
    local JsonData = formatNull(JsonData);
    local TableData = json2table(JsonData);

    --将查询参数初始化为全量查询
    lua_page_list.qry_arg_prepare(ClientIndex,"QryAfterDetail");

    --[[debug_alert(
        "列表查看详情方法\n"..
        "客户端下标 : "..ClientIndex.."\n"..
        "分页参数准备：列表详情查看"..foreach_arg2print(JJBX_AppPageListQryArg).."\n"..
        "Json数据 : "..JsonData.."\n"..
        "Table数据 : "..foreach_arg2print(TableData).."\n"..
        ""
    );]]

    local iTemCallBackArg = vt("iTemCallBackArg",TableData);
    local detailCallFun = vt("detailCallFun",iTemCallBackArg);
    local BusinessCallBackArg = vt("BusinessCallBackArg",TableData);

    --调用详情回调（此处已经更新过分页参数，一定要保证页面成功跳转）
    lua_system.do_function(detailCallFun,BusinessCallBackArg);
end;

--[[卡片方法-点击]]
function lua_page_list.itemClickFun(JsonData,ClickArg,ClientIndex)
    local ClientIndex = tonumber(formatNull(ClientIndex,"1"));
    local ClickArg = formatNull(ClickArg);
    local JsonData = formatNull(JsonData);
    local TableData = json2table(JsonData);

    --[[debug_alert(
        "列表条目点击方法\n"..
        "客户端下标 : "..ClientIndex.."\n"..
        "Json数据 : "..JsonData.."\n"..
        "点击参数 : "..ClickArg.."\n"..
        "Table数据 : "..foreach_arg2print(TableData).."\n"..
        ""
    );]]

    --将查询参数初始化为全量查询
    lua_page_list.qry_arg_prepare(ClientIndex,"QryAfterClick");

    --debug_alert("分页参数准备：列表元素点击"..foreach_arg2print(JJBX_AppPageListQryArg));

    local iTemCallBackArg = vt("iTemCallBackArg",TableData);
    local clickCallFun = vt("clickCallFun",iTemCallBackArg);
    --debug_alert(clickCallFun);
    local BusinessCallBackArg = vt("BusinessCallBackArg",TableData);

    --追加点击参数
    BusinessCallBackArg["itemClickArg"] = ClickArg;

    --调用元素点击回调
    lua_system.do_function(clickCallFun,BusinessCallBackArg);
end;

--[[卡片方法-删除]]
function lua_page_list.delFun(JsonData,ClientIndex)
    local ClientIndex = tonumber(formatNull(ClientIndex,"1"));
    local JsonData = formatNull(JsonData);
    local TableData = json2table(JsonData);

    --[[debug_alert(
        "列表删除方法\n"..
        "客户端下标 : "..ClientIndex.."\n"..
        "Json数据 : "..JsonData.."\n"..
        "Table数据 : "..foreach_arg2print(TableData).."\n"..
        ""
    );]]

    local iTemCallBackArg = vt("iTemCallBackArg",TableData);
    local deleteCallFunc = vt("deleteCallFunc",iTemCallBackArg);
    --debug_alert(deleteCallFunc);
    local BusinessCallBackArg = vt("BusinessCallBackArg",TableData);

    --将查询参数初始化为全量查询
    lua_page_list.qry_arg_prepare(ClientIndex,"QryAfterDelete");

    --debug_alert("分页参数准备：列表删除"..foreach_arg2print(JJBX_AppPageListQryArg));

    --删除后的查询需要刷新列表
    JJBX_AppPageListQryArg.ReloadAppQryPage = "true";

    --调用删除回调
    lua_system.do_function(deleteCallFunc,BusinessCallBackArg);
end;

--#################### 列表全选方法集合 Begin ####################

--[[渲染操作全选控件]]
function lua_page_list.render_process_multiple_select_div(EncodeRenderArg)
    local EncodeRenderArg = formatNull(EncodeRenderArg);
    local RenderArg = lua_format.table_arg_unpack(EncodeRenderArg);
    --debug_alert("渲染操作全选控件"..foreach_arg2print(RenderArg));
    local RenderArg = formatNull(RenderArg);

    --控件名称
    local WidgetEleName = vt("WidgetEleName",RenderArg,"process_multiple_select_div");
    --控件确定方法
    local SubmitFunc = vt("SubmitFunc",RenderArg);
    if SubmitFunc == "" then
        debug_alert("确定方法未指定");
        return;
    else
        SubmitFunc = SubmitFunc.."()";
    end;
    --按钮2的回调方法
    local Btn2CallFunc = vt("btn2CallFunc",RenderArg);
    if vt("CancelFunc",RenderArg) ~= "" then
        Btn2CallFunc = vt("CancelFunc",RenderArg).."()";
    else
        Btn2CallFunc = Btn2CallFunc.."()";
    end;

    --按钮3的回调方法
    local Btn3CallFunc = vt("btn3CallFunc",RenderArg);
    if Btn3CallFunc ~= "" then
        Btn3CallFunc = Btn3CallFunc.."()";
    end;

    --控件确定按钮文字
    local SubmitBtnText = vt("SubmitBtnText",RenderArg,"确定");
    --按钮2文字
    local Btn2Text = vt("btn2Text",RenderArg);
    if vt("CancelBtnText",RenderArg) ~= "" then
        Btn2Text = vt("CancelBtnText",RenderArg);
    end;
    --按钮2文字
    local Btn3Text = vt("btn3Text",RenderArg);
    --控件全选、不全选控制
    local SelectFunc = vt("SelectFunc",RenderArg,"lua_page_list.select_all_ctrl('"..EncodeRenderArg.."')");
    --控件全选、不全选按钮文字
    local SelectBtnText = vt("SelectBtnText",RenderArg,"全选");

    --控件全选、不全选控制调用后的回调
    local SelectCallFunc = vt("SelectCallFunc",RenderArg);

    --按钮数量
    local btnNumber = vt("BtnNumber",RenderArg,"1");
    local html = "";
    if btnNumber == "1" then
        html = [[
            <div class="checkBox_bottom_div" name="]]..WidgetEleName..[[" border="0">
                <div class="checkBox_img_div" border="0" onclick="]]..SelectFunc..[[" name="select_all_btn_div">
                    <img src="local:checkBox.png" class="checkBox_btn_img" name="select_all_icon" onclick="]]..SelectFunc..[[" />
                </div>
                <div class="checkBox_label_div" border="0" onclick="]]..SelectFunc..[[" name="select_all_label_div">
                    <label class="checkBox_label" onclick="]]..SelectFunc..[[" value="]]..SelectBtnText..[[" />
                </div>
                <div class="checkBox_todo_div" border="0" onclick="]]..SubmitFunc..[[">
                    <label class="checkBox_todo_label" onclick="]]..SubmitFunc..[[" value="]]..SubmitBtnText..[[" />
                </div>
            </div>
        ]];
    elseif btnNumber == "2" then
        html = [[
            <div class="checkBox_bottom_2btn_div" name="]]..WidgetEleName..[[" border="0">
                <div class="checkBox_img_div" border="0" onclick="]]..SelectFunc..[[" name="select_all_btn_div">
                    <img src="local:checkBox.png" class="checkBox_btn_img" name="select_all_icon" onclick="]]..SelectFunc..[[" />
                </div>
                <div class="checkBox_label_div" border="0" onclick="]]..SelectFunc..[[" name="select_all_label_div">
                    <label class="checkBox_label" onclick="]]..SelectFunc..[[" value="]]..SelectBtnText..[[" />
                </div>
                <div class="checkBox_btn1_div" border="0" onclick="]]..Btn2CallFunc..[[">
                    <label class="checkBox_btn1_label" onclick="]]..Btn2CallFunc..[[" value="]]..Btn2Text..[[" />
                </div>
                <div class="checkBox_btn2_div" border="0" onclick="]]..SubmitFunc..[[">
                    <label class="checkBox_btn2_label" onclick="]]..SubmitFunc..[[" value="]]..SubmitBtnText..[[" />
                </div>
            </div>
        ]];
    elseif btnNumber == "3" then
        html = [[
            <div class="checkBox_bottom_3btn_div" name="]]..WidgetEleName..[[" border="0">
                <div class="checkBox_img_div" border="0" onclick="]]..SelectFunc..[[" name="select_all_btn_div">
                    <img src="local:checkBox.png" class="checkBox_btn_img" name="select_all_icon" onclick="]]..SelectFunc..[[" />
                </div>
                <div class="checkBox_label_div" border="0" onclick="]]..SelectFunc..[[" name="select_all_label_div">
                    <label class="checkBox_label" onclick="]]..SelectFunc..[[" value="]]..SelectBtnText..[[" />
                </div>
                <div class="checkBox_btn31_div" border="0" onclick="]]..Btn2CallFunc..[[">
                    <label class="checkBox_btn31_label" onclick="]]..Btn2CallFunc..[[" value="]]..Btn2Text..[[" />
                </div>
                <div class="checkBox_btn32_div" border="0" onclick="]]..Btn3CallFunc..[[">
                    <label class="checkBox_btn32_label" onclick="]]..Btn3CallFunc..[[" value="]]..Btn3Text..[[" />
                </div>
                <div class="checkBox_btn33_div" border="0" onclick="]]..SubmitFunc..[[">
                    <label class="checkBox_btn33_label" onclick="]]..SubmitFunc..[[" value="]]..SubmitBtnText..[[" />
                </div>
            </div>
        ]];
    else
        html = "";
    end;
    document:getElementsByName(WidgetEleName)[1]:setInnerHTML(html);
    page_reload();
end;

--[[全选、不全选方法]]
function lua_page_list.select_all_ctrl(EncodeRenderArg)
    local EncodeRenderArg = formatNull(EncodeRenderArg);
    local RenderArg = lua_format.table_arg_unpack(EncodeRenderArg);
    --debug_alert("全选方法"..foreach_arg2print(RenderArg));
    local RenderArg = formatNull(RenderArg);

    show_loading();

    --全选后的查询需要刷新列表
    JJBX_AppPageListQryArg.ReloadAppQryPage = "true";

    --全选操作前先清空已选择列表
    C_ClientListSelectListArg.SelectedIdListStr = "";

    --修改默认选中状态
    if C_ClientListSelectListArg.SelectAllType == "0" then
        --全选
        C_ClientListSelectListArg.SelectAllType = "1";
        changeProperty("select_all_icon","src","checked.png");
    else
        --不全选
        
        --还原全选
        lua_page_list.revert_select_all({RevertType="all"});
    end;

    --将查询参数初始化为全量查询
    lua_page_list.qry_arg_prepare(JJBX_AppPageListQryArg.LoadedCounts,"QryAfterClick");

    --debug_alert(foreach_arg2print(JJBX_AppPageListQryArg))

    --调用回调
    local SelectCallFunc = vt("SelectCallFunc",RenderArg);
    lua_system.do_function(SelectCallFunc,"")
end;

--[[多选、单选实现]]
function lua_page_list.do_select(SelectArg)
    local SelectArg = formatNull(SelectArg);
    --选择编号
    local SelectId = vt("SelectId",SelectArg);
    --选择类型
    local SelectType = vt("SelectType",SelectArg);
    --追加的选择ID
    local AddSelectId = "";
    if SelectId ~= "" then
        --用单引号做全词分隔
        AddSelectId = "'"..SelectId.."'"..","
    end;

    if SelectType == "0" then
        --取消勾选

        --删除已经选择的内容
        C_ClientListSelectListArg.SelectedIdListStr = string.gsub(C_ClientListSelectListArg.SelectedIdListStr,AddSelectId,"");

        --设置全选类型为不全选
        C_ClientListSelectListArg.SelectAllType = "0";
        changeProperty("select_all_icon","src","checkBox.png");
    elseif SelectType == "1" then
        --勾选

        --追加已经选择的内容
        C_ClientListSelectListArg.SelectedIdListStr = C_ClientListSelectListArg.SelectedIdListStr..AddSelectId;
    else
        debug_alert("选择类型未定义");
    end;

    --debug_alert("选中的编号"..C_ClientListSelectListArg.SelectedIdListStr);
end;

--[[还原全选]]
function lua_page_list.revert_select_all(RevertArg)
    local RevertArg = formatNull(RevertArg);
    local RevertType = vt("RevertType",RevertArg,"all");
    if RevertType == "all" then
        --清空已经选择的数据
        C_ClientListSelectListArg.SelectedIdListStr = "";
    elseif RevertType == "show" then
        --只还原显示
    else

    end;

    --还原为不全选
    C_ClientListSelectListArg.SelectAllType = "0";
    --修改图标还原为不全选
    changeProperty("select_all_icon","src","checkBox.png");
end;

--#################### 列表全选方法集合 End ####################
