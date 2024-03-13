const lua_jjbx = require('./jjbx');
const lua_system = require('./system');
const lua_format = require('./format');
lua_page_list = {};
JJBX_AppPageListQryArg = {
    LoadedPageName: '',
    AppQryPageNum: 1,
    AppQryPageSize: 10,
    ClientLastItemIndex: 1,
    LoadedCounts: 0,
    ReloadAppQryPage: 'true'
};
C_ClientListSelectListArg = {
    SelectedIdListStr: '',
    SearchKeyWords: '',
    SelectAllType: ''
};
lua_page_list.init_qry_arg = function (PageName, InitType) {
    var PageName = formatNull(PageName);
    var LoadedPageName = vt('LoadedPageName', JJBX_AppPageListQryArg);
    var InitType = formatNull(InitType, 'Auto');
    if (InitType === 'Force' || LoadedPageName != PageName) {
        lua_jjbx.reset_config_arg('JJBX_AppPageListQryArg');
    }
    JJBX_AppPageListQryArg.LoadedPageName = PageName;
};
lua_page_list.update_qry_arg = function (UpdateArg) {
    var UpdateArgName = vt('UpdateArgName', UpdateArg);
    var UpdateArgValue = vt('UpdateArgValue', UpdateArg);
    if (UpdateArgName === 'LoadedCounts') {
        var TotalCountsNow = 0;
        if (JJBX_AppPageListQryArg.AppQryPageNum === 1) {
            TotalCountsNow = parseFloat(UpdateArgValue);
        } else if (JJBX_AppPageListQryArg.AppQryPageNum > 1) {
            TotalCountsNow = (JJBX_AppPageListQryArg.AppQryPageNum - 1) * JJBX_AppPageListQryArg.AppQryPageSize + parseFloat(UpdateArgValue);
        }
        JJBX_AppPageListQryArg.LoadedCounts = TotalCountsNow;
    }
};
lua_page_list.qry_arg_prepare = function (ClientIndexInput, QryType) {
    var ClientIndex = formatNull(ClientIndexInput);
    var QryType = formatNull(QryType, 'NormalQry');
    var ArgPirntStrBefore = foreach_arg2print(JJBX_AppPageListQryArg);
    if (QryType === 'NormalQry') {
        if (parseFloat(JJBX_AppPageListQryArg.AppQryPageSize) > 10) {
            JJBX_AppPageListQryArg.AppQryPageNum = JJBX_AppPageListQryArg.AppQryPageSize / 10 + 1;
            JJBX_AppPageListQryArg.AppQryPageSize = 10;
        } else {
            JJBX_AppPageListQryArg.AppQryPageNum = JJBX_AppPageListQryArg.AppQryPageNum + 1;
        }
        JJBX_AppPageListQryArg.ClientLastItemIndex = ClientIndex;
    } else {
        if (QryType === 'QryAfterDetail' || QryType === 'QryAfterClick') {
            JJBX_AppPageListQryArg.ClientLastItemIndex = ClientIndex;
        } else if (QryType === 'QryAfterDelete') {
            JJBX_AppPageListQryArg.ClientLastItemIndex = '';
            if (ClientIndex > 1) {
                JJBX_AppPageListQryArg.ClientLastItemIndex = ClientIndex - 1;
            } else {
                JJBX_AppPageListQryArg.ClientLastItemIndex = 1;
            }
        }
        JJBX_AppPageListQryArg.AppQryPageNum = 1;
        JJBX_AppPageListQryArg.AppQryPageSize = 10;
        var calculateLoadedCounts = parseFloat(JJBX_AppPageListQryArg.LoadedCounts);
        if (calculateLoadedCounts > 10) {
            var paddingCounts = 0;
            var lastNum = calculateLoadedCounts % 10;
            if (lastNum > 0) {
                paddingCounts = 10 - lastNum;
            }
            JJBX_AppPageListQryArg.AppQryPageSize = calculateLoadedCounts + paddingCounts;
        }
    }
    var ArgPirntStrAfter = foreach_arg2print(JJBX_AppPageListQryArg);
};
lua_page_list.gen_app_list_widget_data = function (PageData, WidgetCtrlArg, ListItemArg) {
    var PageData = formatNull(PageData);
    var WidgetCtrlArg = formatNull(WidgetCtrlArg);
    var ListItemArg = formatNull(ListItemArg);
    var ListItemCounts = ListItemArg.length;
    var ResPageNum = vt('pagenum', PageData);
    var ResPageCnt = vt('pagecnt', PageData);
    var ResTotalPage = vt('totalpage', PageData);
    var ResTotalCnt = vt('totalcnt', PageData);
    var upFuncName = '';
    var AllowUpCtrlWidget = vt('AllowUpCtrlWidget', WidgetCtrlArg, 'Auto');
    if (AllowUpCtrlWidget === 'Auto') {
        if (ResPageNum === ResTotalPage) {
            upFuncName = '';
        } else {
            upFuncName = 'lua_page_list.upFunc';
        }
    } else if (AllowUpCtrlWidget === 'false') {
        upFuncName = '';
    } else if (AllowUpCtrlWidget === 'true') {
        upFuncName = 'lua_page_list.upFunc';
    } else {
        upFuncName = '';
    }
    var downFuncName = '';
    var AllowDownCtrlWidget = vt('AllowDownCtrlWidget', WidgetCtrlArg, 'true');
    if (AllowDownCtrlWidget === 'true') {
        downFuncName = 'lua_page_list.downFunc';
    } else {
        downFuncName = '';
    }
    var singleSelectCallFun = vt('singleSelectCallFun', WidgetCtrlArg);
    var multipleSelectCallFun = vt('multipleSelectCallFun', WidgetCtrlArg);
    var selectType = '';
    var selectFunc = '';
    var selectCallFun = '';
    if (singleSelectCallFun === '' && multipleSelectCallFun === '') {
    } else if (singleSelectCallFun != '' && multipleSelectCallFun != '') {
    } else {
        if (singleSelectCallFun != '') {
            selectType = 'single';
            selectCallFun = singleSelectCallFun;
        } else {
            selectType = 'multiple';
            selectCallFun = multipleSelectCallFun;
        }
        selectFunc = 'lua_page_list.itemSelectFunc';
    }
    var widgetCtrlTableArg = {
        upFunCallFun: vt('upFunCallFun', WidgetCtrlArg),
        downFunCallFun: vt('downFunCallFun', WidgetCtrlArg),
        selectCallFun: selectCallFun
    };
    var AppListWidgetTableData = {
        upFunc: upFuncName,
        upFuncArg: widgetCtrlTableArg,
        downFunc: downFuncName,
        downFuncArg: widgetCtrlTableArg,
        selectType: selectType,
        selectFunc: selectFunc,
        selectFuncArg: widgetCtrlTableArg,
        slipRight2Left: vt('slipRight2Left', WidgetCtrlArg),
        listReload: JJBX_AppPageListQryArg.ReloadAppQryPage,
        anchorPointIndex: JJBX_AppPageListQryArg.ClientLastItemIndex,
        listData: {}
    };
    var AppListItemTableData = {};
    for (let i = 1; ListItemCounts; i++) {
        var ListItem = ListItemArg[i];
        var iTemCallBackArg = vt('iTemCallBackArg', ListItem);
        var delFun = 'lua_page_list.delFun';
        if (vt('deleteCallFunc', iTemCallBackArg) === '') {
            delFun = '';
        }
        var detailFun = 'lua_page_list.detailFun';
        if (vt('detailCallFun', iTemCallBackArg) === '') {
            detailFun = '';
        }
        var clickFun = 'lua_page_list.itemClickFun';
        if (vt('clickCallFun', iTemCallBackArg) === '') {
            clickFun = '';
        }
        var addItemData = {
            delFun: delFun,
            detailFun: detailFun,
            clickFun: clickFun,
            layOutArg: vt('layOutArg', ListItem),
            iTemCallBackArg: iTemCallBackArg,
            BusinessCallBackArg: vt('BusinessCallBackArg', ListItem)
        };
        table.insert(AppListItemTableData, addItemData);
    }
    AppListWidgetTableData.listData = AppListItemTableData;
    var AppListWidgetJsonData = table2json(AppListWidgetTableData);
    return AppListWidgetJsonData;
};
lua_page_list.upFunc = function (UpFuncJsonArg) {
    var UpFuncJsonArg = formatNull(UpFuncJsonArg);
    var UpFuncTableArg = json2table(UpFuncJsonArg);
    var upFunCallFun = vt('upFunCallFun', UpFuncTableArg);
    JJBX_AppPageListQryArg.ReloadAppQryPage = 'false';
    var ClientIndex = JJBX_AppPageListQryArg.AppQryPageSize * JJBX_AppPageListQryArg.AppQryPageNum + 1;
    lua_page_list.qry_arg_prepare(ClientIndex, 'NormalQry');
    JJBX_AppPageListQryArg.ClientLastItemIndex = 0;
    lua_system.do_function(upFunCallFun, '');
};
lua_page_list.downFunc = function (DownFuncJsonArg) {
    var DownFuncJsonArg = formatNull(DownFuncJsonArg);
    var DownFuncTableArg = json2table(DownFuncJsonArg);
    var downFunCallFun = vt('downFunCallFun', DownFuncTableArg);
    lua_jjbx.reset_config_arg('JJBX_AppPageListQryArg');
    lua_system.do_function(downFunCallFun, '');
};
lua_page_list.itemSelectFunc = function (JsonData, SelectFuncJsonArg, SelectType, ClientIndex) {
    var JsonData = formatNull(JsonData);
    var ClientIndex = parseFloat(formatNull(ClientIndex, '1'));
    var SelectFuncJsonArg = formatNull(SelectFuncJsonArg);
    var SelectFuncTableArg = json2table(SelectFuncJsonArg);
    var SelectType = formatNull(SelectType, '1');
    var TableData = json2table(JsonData);
    var selectCallFun = vt('selectCallFun', SelectFuncTableArg);
    lua_page_list.qry_arg_prepare(ClientIndex, 'QryAfterClick');
    var BusinessCallBackArg = vt('BusinessCallBackArg', TableData);
    BusinessCallBackArg['SelectType'] = SelectType;
    BusinessCallBackArg['ClientIndex'] = ClientIndex;
    lua_system.do_function(selectCallFun, BusinessCallBackArg);
};
lua_page_list.detailFun = function (JsonData, ClientIndex) {
    var ClientIndex = parseFloat(formatNull(ClientIndex, '1'));
    var JsonData = formatNull(JsonData);
    var TableData = json2table(JsonData);
    lua_page_list.qry_arg_prepare(ClientIndex, 'QryAfterDetail');
    var iTemCallBackArg = vt('iTemCallBackArg', TableData);
    var detailCallFun = vt('detailCallFun', iTemCallBackArg);
    var BusinessCallBackArg = vt('BusinessCallBackArg', TableData);
    lua_system.do_function(detailCallFun, BusinessCallBackArg);
};
lua_page_list.itemClickFun = function (JsonData, ClickArg, ClientIndex) {
    var ClientIndex = parseFloat(formatNull(ClientIndex, '1'));
    var ClickArg = formatNull(ClickArg);
    var JsonData = formatNull(JsonData);
    var TableData = json2table(JsonData);
    lua_page_list.qry_arg_prepare(ClientIndex, 'QryAfterClick');
    var iTemCallBackArg = vt('iTemCallBackArg', TableData);
    var clickCallFun = vt('clickCallFun', iTemCallBackArg);
    var BusinessCallBackArg = vt('BusinessCallBackArg', TableData);
    BusinessCallBackArg['itemClickArg'] = ClickArg;
    lua_system.do_function(clickCallFun, BusinessCallBackArg);
};
lua_page_list.delFun = function (JsonData, ClientIndex) {
    var ClientIndex = parseFloat(formatNull(ClientIndex, '1'));
    var JsonData = formatNull(JsonData);
    var TableData = json2table(JsonData);
    var iTemCallBackArg = vt('iTemCallBackArg', TableData);
    var deleteCallFunc = vt('deleteCallFunc', iTemCallBackArg);
    var BusinessCallBackArg = vt('BusinessCallBackArg', TableData);
    lua_page_list.qry_arg_prepare(ClientIndex, 'QryAfterDelete');
    JJBX_AppPageListQryArg.ReloadAppQryPage = 'true';
    lua_system.do_function(deleteCallFunc, BusinessCallBackArg);
};
lua_page_list.render_process_multiple_select_div = function (EncodeRenderArg) {
    var EncodeRenderArg = formatNull(EncodeRenderArg);
    var RenderArg = lua_format.table_arg_unpack(EncodeRenderArg);
    var RenderArg = formatNull(RenderArg);
    var WidgetEleName = vt('WidgetEleName', RenderArg, 'process_multiple_select_div');
    var SubmitFunc = vt('SubmitFunc', RenderArg);
    if (SubmitFunc === '') {
        debug_alert('确定方法未指定');
        return;
    } else {
        SubmitFunc = SubmitFunc + '()';
    }
    var Btn2CallFunc = vt('btn2CallFunc', RenderArg);
    if (vt('CancelFunc', RenderArg) != '') {
        Btn2CallFunc = vt('CancelFunc', RenderArg) + '()';
    } else {
        Btn2CallFunc = Btn2CallFunc + '()';
    }
    var Btn3CallFunc = vt('btn3CallFunc', RenderArg);
    if (Btn3CallFunc != '') {
        Btn3CallFunc = Btn3CallFunc + '()';
    }
    var SubmitBtnText = vt('SubmitBtnText', RenderArg, '确定');
    var Btn2Text = vt('btn2Text', RenderArg);
    if (vt('CancelBtnText', RenderArg) != '') {
        Btn2Text = vt('CancelBtnText', RenderArg);
    }
    var Btn3Text = vt('btn3Text', RenderArg);
    var SelectFunc = vt('SelectFunc', RenderArg, 'lua_page_list.select_all_ctrl(\'' + (EncodeRenderArg + '\')'));
    var SelectBtnText = vt('SelectBtnText', RenderArg, '全选');
    var SelectCallFunc = vt('SelectCallFunc', RenderArg);
    var btnNumber = vt('BtnNumber', RenderArg, '1');
    var html = '';
    if (btnNumber === '1') {
        html = '[[\n            <div class="checkBox_bottom_div" name="]]' + (WidgetEleName + ('[[" border="0">\n                <div class="checkBox_img_div" border="0" onclick="]]' + (SelectFunc + ('[[" name="select_all_btn_div">\n                    <img src="local:checkBox.png" class="checkBox_btn_img" name="select_all_icon" onclick="]]' + (SelectFunc + ('[[" />\n                </div>\n                <div class="checkBox_label_div" border="0" onclick="]]' + (SelectFunc + ('[[" name="select_all_label_div">\n                    <label class="checkBox_label" onclick="]]' + (SelectFunc + ('[[" value="]]' + (SelectBtnText + ('[[" />\n                </div>\n                <div class="checkBox_todo_div" border="0" onclick="]]' + (SubmitFunc + ('[[">\n                    <label class="checkBox_todo_label" onclick="]]' + (SubmitFunc + ('[[" value="]]' + (SubmitBtnText + '[[" />\n                </div>\n            </div>\n        ]]')))))))))))))))));
    } else if (btnNumber === '2') {
        html = '[[\n            <div class="checkBox_bottom_2btn_div" name="]]' + (WidgetEleName + ('[[" border="0">\n                <div class="checkBox_img_div" border="0" onclick="]]' + (SelectFunc + ('[[" name="select_all_btn_div">\n                    <img src="local:checkBox.png" class="checkBox_btn_img" name="select_all_icon" onclick="]]' + (SelectFunc + ('[[" />\n                </div>\n                <div class="checkBox_label_div" border="0" onclick="]]' + (SelectFunc + ('[[" name="select_all_label_div">\n                    <label class="checkBox_label" onclick="]]' + (SelectFunc + ('[[" value="]]' + (SelectBtnText + ('[[" />\n                </div>\n                <div class="checkBox_btn1_div" border="0" onclick="]]' + (Btn2CallFunc + ('[[">\n                    <label class="checkBox_btn1_label" onclick="]]' + (Btn2CallFunc + ('[[" value="]]' + (Btn2Text + ('[[" />\n                </div>\n                <div class="checkBox_btn2_div" border="0" onclick="]]' + (SubmitFunc + ('[[">\n                    <label class="checkBox_btn2_label" onclick="]]' + (SubmitFunc + ('[[" value="]]' + (SubmitBtnText + '[[" />\n                </div>\n            </div>\n        ]]')))))))))))))))))))))));
    } else if (btnNumber === '3') {
        html = '[[\n            <div class="checkBox_bottom_3btn_div" name="]]' + (WidgetEleName + ('[[" border="0">\n                <div class="checkBox_img_div" border="0" onclick="]]' + (SelectFunc + ('[[" name="select_all_btn_div">\n                    <img src="local:checkBox.png" class="checkBox_btn_img" name="select_all_icon" onclick="]]' + (SelectFunc + ('[[" />\n                </div>\n                <div class="checkBox_label_div" border="0" onclick="]]' + (SelectFunc + ('[[" name="select_all_label_div">\n                    <label class="checkBox_label" onclick="]]' + (SelectFunc + ('[[" value="]]' + (SelectBtnText + ('[[" />\n                </div>\n                <div class="checkBox_btn31_div" border="0" onclick="]]' + (Btn2CallFunc + ('[[">\n                    <label class="checkBox_btn31_label" onclick="]]' + (Btn2CallFunc + ('[[" value="]]' + (Btn2Text + ('[[" />\n                </div>\n                <div class="checkBox_btn32_div" border="0" onclick="]]' + (Btn3CallFunc + ('[[">\n                    <label class="checkBox_btn32_label" onclick="]]' + (Btn3CallFunc + ('[[" value="]]' + (Btn3Text + ('[[" />\n                </div>\n                <div class="checkBox_btn33_div" border="0" onclick="]]' + (SubmitFunc + ('[[">\n                    <label class="checkBox_btn33_label" onclick="]]' + (SubmitFunc + ('[[" value="]]' + (SubmitBtnText + '[[" />\n                </div>\n            </div>\n        ]]')))))))))))))))))))))))))))));
    } else {
        html = '';
    }
    document.getElementsByName(WidgetEleName)[1].setInnerHTML(html);
    page_reload();
};
lua_page_list.select_all_ctrl = function (EncodeRenderArg) {
    var EncodeRenderArg = formatNull(EncodeRenderArg);
    var RenderArg = lua_format.table_arg_unpack(EncodeRenderArg);
    var RenderArg = formatNull(RenderArg);
    show_loading();
    JJBX_AppPageListQryArg.ReloadAppQryPage = 'true';
    C_ClientListSelectListArg.SelectedIdListStr = '';
    if (C_ClientListSelectListArg.SelectAllType === '0') {
        C_ClientListSelectListArg.SelectAllType = '1';
        changeProperty('select_all_icon', 'src', 'checked.png');
    } else {
        lua_page_list.revert_select_all({ RevertType: 'all' });
    }
    lua_page_list.qry_arg_prepare(JJBX_AppPageListQryArg.LoadedCounts, 'QryAfterClick');
    var SelectCallFunc = vt('SelectCallFunc', RenderArg);
    lua_system.do_function(SelectCallFunc, '');
};
lua_page_list.do_select = function (SelectArg) {
    var SelectArg = formatNull(SelectArg);
    var SelectId = vt('SelectId', SelectArg);
    var SelectType = vt('SelectType', SelectArg);
    var AddSelectId = '';
    if (SelectId != '') {
        AddSelectId = '\'' + (SelectId + ('\'' + ','));
    }
    if (SelectType === '0') {
        C_ClientListSelectListArg.SelectedIdListStr = string.gsub(C_ClientListSelectListArg.SelectedIdListStr, AddSelectId, '');
        C_ClientListSelectListArg.SelectAllType = '0';
        changeProperty('select_all_icon', 'src', 'checkBox.png');
    } else if (SelectType === '1') {
        C_ClientListSelectListArg.SelectedIdListStr = C_ClientListSelectListArg.SelectedIdListStr + AddSelectId;
    } else {
        debug_alert('选择类型未定义');
    }
};
lua_page_list.revert_select_all = function (RevertArg) {
    var RevertArg = formatNull(RevertArg);
    var RevertType = vt('RevertType', RevertArg, 'all');
    if (RevertType === 'all') {
        C_ClientListSelectListArg.SelectedIdListStr = '';
    } else if (RevertType === 'show') {
    } else {
    }
    C_ClientListSelectListArg.SelectAllType = '0';
    changeProperty('select_all_icon', 'src', 'checkBox.png');
};
module.exports = { lua_page_list: lua_page_list };