const lua_system = require('./system');
const lua_page = require('./page');
lua_widget = {};
C_ScrollIndexNow = 1;
C_ScrollIndexMax = 0;
lua_widget.init_scroll_pointer = function (InitArg) {
    if (C_ScrollIndexMax > 1) {
        var InitArg = formatNull(InitArg);
        var FixedHeight = parseFloat(vt('FixedHeight', InitArg, '0'));
        var pointerArg = {
            MaxIndex: C_ScrollIndexMax,
            NowIndex: C_ScrollIndexNow
        };
        lua_widget.render_pointer(pointerArg);
        var SetArg = {
            eleName: 'scroll_content_div',
            defaultCall: 'lua_widget.scroll_listener_call',
            defaultArg: ''
        };
        if (platform === 'Android') {
            var ScrollHeight = parseFloat(getEleLocation('scroll_show_content_div', 'height'));
            var ScreenHeight = parseFloat(systemTable['phoneInfo']['screenUseHeight']);
            var UseHeight = FixedHeight + ScrollHeight + 45;
            var SurHeight = ScreenHeight - UseHeight;
            if (SurHeight > 0) {
            } else {
                return;
            }
        }
        lua_system.set_single_swipe_listener(SetArg);
    } else {
        hide_ele('scroll_index_div');
    }
};
lua_widget.render_pointer = function (PointerArg) {
    var ScrollEle = document.getElementsByName('scroll_index_div');
    if (ScrollEle.length >= 1) {
        var setBorder = '0';
        var MaxIndex = vt('MaxIndex', PointerArg);
        var NowIndex = vt('NowIndex', PointerArg);
        var containerWidth = tostring(MaxIndex * 21 + 5);
        var pointerItemHtml = '';
        for (let i = 1; MaxIndex; i++) {
            var Icon = 'pointer_icon.png';
            if (i === 1) {
                Icon = 'pointer_light_icon.png';
            }
            var PointerTouch = 'scroll_content_fill(' + (i + ')');
            pointerItemHtml = pointerItemHtml + ('[[\n                <div class="scroll_pointer_icon_div" border="]]' + (setBorder + ('[[" onclick="]]' + (PointerTouch + ('[[">\n                    <img src="local:]]' + (Icon + ('[[" class="scroll_pointer_icon" name="scroll_pointer_icon" onclick="]]' + (PointerTouch + '[[" />\n                </div>\n            ]]'))))))));
        }
        var html = '[[\n            <div class="scroll_index_div" name="scroll_index_div" border="]]' + (setBorder + ('[[">\n                <div class="scroll_pointer_div" style="width:]]' + (containerWidth + ('[[px;" name="scroll_pointer_div" border="]]' + (setBorder + ('[[">\n                    ]]' + (pointerItemHtml + '[[\n                </div>\n            </div>\n        ]]')))))));
        ScrollEle[1].setInnerHTML(html);
        lua_page.widget_center_adapt('scroll_pointer_div', 'x', 'scroll_index_div');
        lua_system.do_function('scroll_height_adapt', '');
        show_ele('scroll_index_div');
        page_reload();
    } else {
        hide_ele('scroll_index_div');
    }
};
lua_widget.scroll_pointer = function (DoScrollIndex) {
    C_ScrollIndexNow = DoScrollIndex;
    var pointer = document.getElementsByName('scroll_pointer_icon');
    var pointerCounts = pointer.length;
    for (let i = 1; pointerCounts; i++) {
        if (i === C_ScrollIndexNow) {
            pointer[i].setPropertyByName('src', 'local:pointer_light_icon.png');
        } else {
            pointer[i].setPropertyByName('src', 'local:pointer_icon.png');
        }
    }
    page_reload();
};
lua_widget.scroll_listener_call = function (Arg) {
    if (C_ScrollIndexMax > 1) {
        var direction = vt('direction', Arg);
        lua_system.do_function('save_now_form', C_ScrollIndexNow);
        if (direction === 'right') {
            scroll_last_page();
        } else if (direction === 'left') {
            scroll_next_page();
        } else {
            return;
        }
    } else {
    }
};
lua_widget.create_process_bar = function (CreateArg) {
    var BarType = vt('BarType', CreateArg);
    var CFunc = vt('ClickFunc', CreateArg);
    var CFuncArg = vt('ClickFuncArg', CreateArg);
    var SetHtml = '';
    if (BarType === 'ReimbursementByStep') {
        SetHtml = '[[\n            <div class="process_bar_div" name="process_bar_div" border="0">\n                <!-- 灰色背景 -->\n                <div class="process_bar_bg_div" border="0" />\n\n                <div class="process_bar_item_div" style="width:51px; left: 8px;" border="0" onclick="]]' + (CFunc + ('[[(\']]' + (CFuncArg + ('[[\',\'001\')">\n                    <div class="process_bar_icon_div" name="process_bar_icon_div" style="left: 18px;" border="0" />\n                    <label class="process_bar_label" name="process_bar_label" value="出行信息" />\n                </div>\n                <div class="process_bar_item_div" style="width:51px; left: 82px;" border="0" onclick="]]' + (CFunc + ('[[(\']]' + (CFuncArg + ('[[\',\'002\')">\n                    <div class="process_bar_icon_div" name="process_bar_icon_div" style="left: 18px;" border="0" />\n                    <label class="process_bar_label" name="process_bar_label" style="" value="补贴信息" />\n                </div>\n                <div class="process_bar_item_div" style="width:89px; left: 156px;" border="0" onclick="]]' + (CFunc + ('[[(\']]' + (CFuncArg + ('[[\',\'003\')">\n                    <div class="process_bar_icon_div" name="process_bar_icon_div" style="left: 38px;" border="0" />\n                    <label class="process_bar_label" name="process_bar_label" value="基本及结算信息" />\n                </div>\n                <div class="process_bar_item_div" style="width:51px; left: 259px;" border="0" onclick="]]' + (CFunc + ('[[(\']]' + (CFuncArg + ('[[\',\'004\')">\n                    <div class="process_bar_icon_div" name="process_bar_icon_div" style="left: 18px;" border="0" />\n                    <label class="process_bar_label" name="process_bar_label" value="补充信息" />\n                </div>\n                <div class="process_bar_item_div" style="width:26px; right: 20px;" border="0" onclick="]]' + (CFunc + ('[[(\']]' + (CFuncArg + '[[\',\'005\')">\n                    <div class="process_bar_icon_div" name="process_bar_icon_div" style="left: 6px;" border="0" />\n                    <label class="process_bar_label" name="process_bar_label" value="提交" />\n                </div>\n            </div>\n        ]]')))))))))))))))))));
        document.getElementsByName('process_bar_div')[1].setInnerHTML(SetHtml);
    }
    if (SetHtml != '') {
        var OptionIndexNow = parseFloat(vt('OptionIndexNow', CreateArg, '0'));
        if (OptionIndexNow > 0) {
            changeStyleByIndex('process_bar_label', OptionIndexNow, 'color', '#FE6F14');
        }
        var OptionSavedIndexs = vt('OptionSavedIndexs', CreateArg);
        var array = splitUtils(OptionSavedIndexs, ',');
        if (array.length > 0) {
            for (let i = 1; array.length; i++) {
                var setIndex = array[i];
                var setIndexMax = 0;
                if (BarType === 'ReimbursementByStep') {
                    setIndexMax = 5;
                }
                if (setIndex != '' && setIndex != ',' && parseFloat(setIndex) <= setIndexMax) {
                    changeStyleByIndex('process_bar_icon_div', parseFloat(setIndex), 'background-image', 'process_bar_finish_icon.png');
                }
            }
        }
        page_reload();
    } else {
        debug_alert('状态栏未渲染');
    }
};
module.exports = { lua_widget: lua_widget };