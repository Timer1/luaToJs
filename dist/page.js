const lua_system = require('./system');
const lua_menu = require('./menu');
const lua_form = require('./form');
const lua_format = require('./format');
lua_page = {};
create_page_title = function (bar_back_fun, bar_center_type_arg, bar_center_text, bar_center_fun, bar_right_type, bar_right_text, bar_right_fun, bar_top_name, bar_close_fun) {
    var createArg = {
        bar_back_fun: bar_back_fun,
        bar_center_type_arg: bar_center_type_arg,
        bar_center_text: bar_center_text,
        bar_center_fun: bar_center_fun,
        bar_right_type: bar_right_type,
        bar_right_text: bar_right_text,
        bar_right_fun: bar_right_fun,
        bar_top_name: bar_top_name,
        bar_close_fun: bar_close_fun
    };
    lua_page.do_create_top(createArg);
};
lua_page.create_top = function (createArg) {
    lua_page.do_create_top(createArg);
};
lua_page.do_create_top = function (createArg) {
    var bar_back_fun = vt('bar_back_fun', createArg, 'back_fun()');
    var bar_close_fun = vt('bar_close_fun', createArg);
    var bar_center_type_arg = vt('bar_center_type_arg', createArg, 'title_bar');
    var bar_center_type_arg_split = splitUtils(bar_center_type_arg, '-');
    var bar_center_type = bar_center_type_arg_split[1];
    var bar_center_input_style = bar_center_type_arg_split[2];
    var bar_center_name = vt('bar_center_name', createArg, 'JJBX_titleName');
    var bar_center_text = vt('bar_center_text', createArg);
    var bar_center_fun = vt('bar_center_fun', createArg);
    if (bar_center_type === 'search_bar') {
        bar_center_text = formatNull(bar_center_text, C_SearchKeyWords);
    } else {
        bar_center_text = formatNull(bar_center_text);
        bar_center_fun = '';
        if (configTable['lua_debug'] === 'true') {
            bar_center_fun = 'lua_debug.reload_page()';
        }
    }
    var bar_right_type = vt('bar_right_type', createArg);
    var bar_right_text = vt('bar_right_text', createArg);
    if (bar_right_type === 'label_bar') {
        bar_right_text = bar_right_text;
    } else if (bar_right_type === 'filt_bar') {
        bar_right_text = formatNull(bar_right_text, '筛选');
    } else if (bar_right_type === 'search_bar') {
        bar_right_text = '';
    } else if (bar_right_type === 'icon_bar') {
    } else {
        bar_right_text = '';
    }
    var bar_right_fun = vt('bar_right_fun', createArg);
    var bar_top_name = vt('bar_top_name', createArg, 'top_all_div');
    var border = '0';
    var htmlBegin = '[[\n        <div class="top_div_]]' + (systemTable['SysLayoutStyle'] + ('[[" border="]]' + (border + ('[[" name="]]' + (bar_top_name + ('[[">\n            <div class="top_div" border="]]' + (border + '[[">\n    ]]')))))));
    var htmlEnd = '[[\n            </div>\n        </div>\n    ]]';
    var htmlContent = '';
    var titleHtmlLeft = '';
    var titleHtmlCenter = '';
    var titleHtmlRight = '';
    var titleCloseHtml = '';
    if (bar_close_fun != '') {
        titleCloseHtml = '[[\n            <div class="closebtn_click_div" name="closebtn_click_div" border="]]' + (border + ('[[" onclick="]]' + (bar_close_fun + ('[[">\n                <img class="closebtn_click_img" name="closebtn_click_img" src="local:close_topBar.png" onclick="]]' + (bar_close_fun + '[[" />\n            </div>\n        ]]')))));
    }
    if (bar_back_fun != 'none') {
        titleHtmlLeft = '[[\n            <div class="backbtn_div" name="common_titile_backbtn_div" border="]]' + (border + ('[[" onclick="]]' + (bar_back_fun + ('[[">\n                <div class="backbtn_click_div" name="backbtn_click_div" border="]]' + (border + ('[[" onclick="]]' + (bar_back_fun + ('[[">\n                    <img class="backbtn_click_img" name="backbtn_click_img" src="local:arrow_topBar.png" onclick="]]' + (bar_back_fun + ('[[" />\n                </div>\n                ]]' + (titleCloseHtml + ('[[\n                <label class="backbtn_click_label" name="backbtn_click_label" value="" onclick="]]' + (bar_back_fun + '[[" />\n            </div>\n        ]]')))))))))))));
    }
    var TopSearchTextDivStyle = 'top_search_text_div';
    var TopSearchTextStyle = 'top_search_text';
    var TopSearchDivStyle = 'top_search_div';
    var TopSearchRightLabelDivStyle = 'head_right_label4_div';
    if (bar_center_type === 'search_bar') {
        var InputStyle = '';
        if (bar_center_input_style === 'N') {
            InputStyle = 'style=\\"-wap-input-format:\'N\'\\"';
        } else if (bar_center_input_style === 'n') {
            InputStyle = 'style=\\"-wap-input-format:\'n\'\\"';
        }
        if (bar_right_type === '') {
            TopSearchTextDivStyle = 'top_search_full_text_div';
            TopSearchTextStyle = 'top_search_full_text';
            TopSearchDivStyle = 'top_search_full_div';
            TopSearchRightLabelDivStyle = 'head_right_label4_div';
        } else if (bar_right_type === 'label_bar') {
            var labelLength = ryt.getLengthByStr(bar_right_text);
            if (labelLength === 2) {
                TopSearchTextDivStyle = 'top_search_label2_text_div';
                TopSearchTextStyle = 'top_search_label2_text';
                TopSearchDivStyle = 'top_search_label2_div';
                TopSearchRightLabelDivStyle = 'head_right_label2_div';
            } else if (labelLength === 3) {
                TopSearchTextDivStyle = 'top_search_label3_text_div';
                TopSearchTextStyle = 'top_search_label3_text';
                TopSearchDivStyle = 'top_search_label3_div';
                TopSearchRightLabelDivStyle = 'head_right_label3_div';
            } else {
            }
        } else if (bar_right_type === 'menu_bar') {
            TopSearchTextDivStyle = 'top_search_label2_text_div';
            TopSearchTextStyle = 'top_search_label2_text';
            TopSearchDivStyle = 'top_search_label2_div';
            TopSearchRightLabelDivStyle = 'head_right_label2_div';
        } else {
        }
        titleHtmlCenter = '[[\n            <div class="]]' + (TopSearchDivStyle + ('[[" name="top_search_div" border="1" cornerRadius="16">\n                <img src="local:search_icon.png" class="top_search_icon" name="top_search_icon" />\n                <div class="]]' + (TopSearchTextDivStyle + ('[[" border="]]' + (border + ('[[">\n                    <input type="text" class="]]' + (TopSearchTextStyle + ('[[" name="top_search_text" ]]' + (InputStyle + ('[[ holdColor="#9B9B9B" hold="]]' + (C_SearchContextBegin + (bar_center_text + (C_SearchContextEnd + ('[[" border="]]' + (border + ('[[" value="" onchange="]]' + (bar_center_fun + '[[" />\n                </div>\n            </div>\n        ]]')))))))))))))))));
    } else {
        var bar_center_icon_fun = vt('bar_center_icon_fun', createArg);
        var bar_center_icon = vt('bar_center_icon', createArg);
        var bar_center_icon_html = '';
        if (bar_center_icon != '') {
            bar_center_icon_html = '[[\n                <div class="head_title_icon_div" name="head_title_icon_div" border="]]' + (border + ('[[" onclick="]]' + (bar_center_icon_fun + ('[[">\n                    <img class="head_title_icon_]]' + (systemTable['SysLayoutStyle'] + ('[[" name="head_title_icon" src="local:]]' + (bar_center_icon + ('[[" onclick="]]' + (bar_center_icon_fun + '[[" />\n                </div>\n            ]]')))))))));
        }
        titleHtmlCenter = '[[\n            <div class="head_title_div" name="head_title_div" border="]]' + (border + ('[[" onclick="]]' + (bar_center_fun + ('[[">\n                <label class="head_title_label" value="]]' + (bar_center_text + ('[[" name="]]' + (bar_center_name + ('[["/>\n                ]]' + (bar_center_icon_html + '[[\n            </div>\n        ]]')))))))));
    }
    if (bar_right_type === 'label_bar') {
        titleHtmlRight = '[[\n            <div class="]]' + (TopSearchRightLabelDivStyle + ('[[" name="head_right_label_div" border="]]' + (border + ('[[" onclick="]]' + (bar_right_fun + ('[[">\n                <label class="head_right_label" name="head_right_label" value="]]' + (bar_right_text + ('[[" onclick="]]' + (bar_right_fun + '[[" />\n            </div>\n        ]]')))))))));
    } else if (bar_right_type === 'filt_bar') {
        titleHtmlRight = '[[\n            <div class="head_filt_div" name="head_filt_div" onclick="]]' + (bar_right_fun + ('[[" border="]]' + (border + ('[[">\n                <img class="head_filt_img" name="head_filt_img" src="local:filter.png" onclick="]]' + (bar_right_fun + ('[[" />\n                <label class="head_filt_label" name="head_filt_label" onclick="]]' + (bar_right_fun + ('[[" value="]]' + (bar_right_text + '[["/>\n            </div>\n        ]]')))))))));
    } else if (bar_right_type === 'search_bar') {
        titleHtmlRight = '[[\n            <div class="head_search_div" name="head_search_div" onclick="]]' + (bar_right_fun + ('[[" border="]]' + (border + ('[[">\n                <img class="head_search_img" name="head_search_img" src="local:search.png" onclick="]]' + (bar_right_fun + '[[" />\n            </div>\n        ]]')))));
    } else if (bar_right_type === 'menu_bar') {
        if (formatNull(globalTable['rightMenuFlag'], 'true') === 'true') {
            titleHtmlRight = '[[\n                <div class="head_menu_div" name="head_menu_div" onclick="]]' + (bar_right_fun + ('[[" border="]]' + (border + ('[[">\n                    <img class="head_menu_img" name="head_menu_img" src="local:menu_bar_white.png" onclick="]]' + (bar_right_fun + '[[" />\n                </div>\n            ]]')))));
        } else {
            titleHtmlRight = '';
        }
        globalTable['rightMenuFlag'] = 'true';
    } else if (bar_right_type === 'icon_bar') {
        var bar_right_icon = vt('bar_right_icon', createArg);
        titleHtmlRight = '[[\n            <div class="head_rt_icon_div" name="head_rt_icon_div" onclick="]]' + (bar_right_fun + ('[[" border="]]' + (border + ('[[">\n                <img class="head_rt_icon_img_]]' + (systemTable['SysLayoutStyle'] + ('[[" name="head_rt_icon_img" src="local:]]' + (bar_right_icon + ('[[" onclick="]]' + (bar_right_fun + ('[[" />\n                <label class="head_rt_icon_label" name="head_rt_icon_label" onclick="]]' + (bar_right_fun + ('[[" value="]]' + (bar_right_text + '[["/>\n            </div>\n        ]]')))))))))))));
    } else if (bar_right_type === 'image_bar') {
        var bar_right_image = vt('bar_right_image', createArg);
        titleHtmlRight = '[[\n            <div class="head_rt_icon_div" name="head_rt_image_div" onclick="]]' + (bar_right_fun + ('[[" border="]]' + (border + ('[[">\n                <img class="head_rt_image_]]' + (systemTable['SysLayoutStyle'] + ('[[" name="head_rt_image" src="local:]]' + (bar_right_image + ('[[" onclick="]]' + (bar_right_fun + '[[" />\n            </div>\n        ]]')))))))));
    } else {
        titleHtmlRight = '';
    }
    htmlContent = titleHtmlLeft + (titleHtmlCenter + titleHtmlRight);
    var top_div_elements = document.getElementsByName(bar_top_name);
    if (top_div_elements.length < 1) {
        debug_alert('标题未定义 : ' + bar_top_name);
        return;
    } else {
        for (let i = 1; top_div_elements.length; i++) {
            top_div_elements[i].setInnerHTML(htmlBegin + (htmlContent + htmlEnd));
        }
        page_reload();
        var page_explain = vt('page_explain', createArg);
        var ReportPageName = '';
        if (page_explain != '') {
            if (page_explain === 'None') {
            } else {
                ReportPageName = page_explain;
            }
        } else {
            if (bar_center_type === 'title_bar') {
                var prepare_center_text = string.gsub(bar_center_text, ' ', '');
                if (prepare_center_text != '') {
                    ReportPageName = prepare_center_text;
                }
            }
        }
        if (ReportPageName != '') {
            var CurrentPageInfo = lua_page.current_page_info();
            var PageFilePath = vt('page_file_path', CurrentPageInfo);
            var reportArg = {
                Event: 'JJBXAppOpenAppPage',
                PageUrl: PageFilePath,
                PageName: ReportPageName
            };
            lua_system.sensors_report(reportArg);
        }
        if (configTable['lua_debug'] === 'true') {
            if (history.length() > 2) {
                set_longtap_listener('common_titile_backbtn_div', 'lua_debug.alert_menu', '');
            }
        }
    }
};
lua_page.update_top = function (updateArg) {
    var updateTarget = vt('updateTarget', updateArg);
    if (updateTarget === 'title_icon') {
        var headTitleLabelContent = formatNull(getValue('JJBX_titleName', '0'), '消息中心');
        var headTitleLabelWidth = parseFloat(calculate_text_width(headTitleLabelContent, '17'));
        var headTitleDivWidth = 235;
        var headTitleIconDivWidth = 40;
        var headTitleIconRightTrim = 5;
        var headTitleIconRight = tostring((headTitleDivWidth - headTitleLabelWidth) / 2 - headTitleIconDivWidth + headTitleIconRightTrim);
        changeStyle('head_title_icon_div', 'right', headTitleIconRight);
        page_reload();
    }
};
title_head = function (titletext, backfun, topname) {
    create_page_title(backfun, 'title_bar', titletext, '', '', '', '', topname);
};
search_head = function (titletext, serachfun, topname) {
    create_page_title('', 'search_bar', titletext, serachfun, '', '', '', topname);
};
right_label_head = function (titletext, righttext, rightfun, topname) {
    create_page_title('', 'title_bar', titletext, '', 'label_bar', righttext, rightfun, topname);
};
right_search_head = function (titletext, rightfun, topname) {
    create_page_title('', 'title_bar', titletext, '', 'search_bar', '', rightfun, topname);
};
right_filt_head = function (titletext, righttext, rightfun, topname) {
    create_page_title('', 'title_bar', titletext, '', 'filt_bar', righttext, rightfun, topname);
};
isShowContent = false;
showContentIndex = 1;
jjbx_utils_showContent = function (index, elementName, refreshpage) {
    var refreshpage = formatNull(refreshpage, 'true');
    showContentIndex = parseFloat(index);
    if (isShowContent) {
        isShowContent = false;
        window.hide(showContentIndex);
        if (refreshpage === 'true') {
            height_adapt('body', 0, 0);
        }
    } else {
        isShowContent = true;
        var showDiv = document.getElementsByName(elementName);
        if (refreshpage === 'true') {
            height_adapt(elementName, 0, 0);
        }
        window.showControl(showDiv[1], showContentIndex);
    }
};
jjbx_utils_hideContent = function (refreshpage, doback) {
    var refreshpage = formatNull(refreshpage, 'true');
    var doback = formatNull(doback, 'true');
    if (isShowContent) {
        window.hide(showContentIndex);
        isShowContent = false;
        if (refreshpage === 'true') {
            height_adapt('body', 0, 0);
            page_reload();
        }
    } else {
        if (doback === 'true') {
            back_fun();
        }
    }
    lua_system.hide_keyboard();
};
height_adapt = function (name, fixheight, topheight, doflag) {
    var fixheight = formatNull(fixheight, C_TopHeight);
    var topheight = formatNull(topheight, get_top_diff());
    var doflag = formatNull(doflag, 'adapt');
    var res = prepare2do_height(name, fixheight, topheight, doflag);
    res = formatNull(res);
    return res;
};
prepare2do_height = function (name, fixheight, topheight, doflag) {
    var adapt_height = fixheight + topheight;
    var real_adapt_height = calculate_height_by_screen_ratio(adapt_height, name);
    if (doflag === 'calculate') {
        return real_adapt_height;
    } else {
        do_height_adapt(name, real_adapt_height);
    }
};
calculate_height_by_screen_ratio = function (fix_height, widget_name) {
    var fix_height = parseFloat(formatNull(fix_height, '0'));
    var bottomheight = parseFloat(get_bottom_diff());
    var use_fix_height = fix_height + bottomheight;
    var do_adapt_height = 0;
    var widget_name = formatNull(widget_name);
    var screen_width = systemTable['phoneInfo'].screenWidth;
    var width_ratio = systemTable['phoneInfo'].widthRatio;
    var screen_height = systemTable['phoneInfo'].screenHeight;
    var height_ratio = systemTable['phoneInfo'].heightRatio;
    var screen_configured = systemTable['phoneInfo'].screenConfigured;
    var base_msg = '高度适配-通过比例转换计算过程\\n' + ('适配控件:' + (widget_name + ('\\n' + ('\\n' + ('基本信息\\n' + ('\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\\n' + ('已知高度:' + (use_fix_height + ('px\\n' + ('底部高度:' + (bottomheight + ('px\\n' + ('屏宽:' + (screen_width + (' ' + ('屏高:' + (screen_height + ('\\n' + ('屏宽比:' + (width_ratio + (' ' + ('屏高比:' + (height_ratio + ('\\n' + ('是否已知:' + (screen_configured + ('\\n' + '\\n')))))))))))))))))))))))))));
    var cal_adapt_msg = '';
    if (parseFloat(fix_height) === 0) {
        var adapt_screen_height = float((screen_height - bottomheight) / width_ratio, 4);
        cal_adapt_msg = '全屏适配不计算\\n' + ('屏幕高度:' + (screen_height + ('\\n' + ('底部高度:' + (bottomheight + ('\\n' + ('适配高度/屏宽比:' + (adapt_screen_height + ('\\n' + '\\n')))))))));
        do_adapt_height = adapt_screen_height;
    } else {
        var real_height = float(screen_height / width_ratio, 4);
        var adapt_height = float(real_height - use_fix_height, 4);
        cal_adapt_msg = '计算信息\\n' + ('\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\\n' + ('全屏高度(屏高*屏宽比):' + (real_height + ('\\n' + ('剩余屏高:' + (adapt_height + ('\\n' + '\\n')))))));
        do_adapt_height = adapt_height;
    }
    var do_adapt_msg = '执行适配\\n' + '\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\\n';
    if (do_adapt_height <= 0) {
        do_adapt_height = 1;
        do_adapt_msg = do_adapt_msg + '高度为0\uFF0C适配为1个像素';
    } else {
        if (screen_configured === 'true') {
            do_adapt_height = math.ceil(do_adapt_height);
        } else {
            do_adapt_height = math.floor(do_adapt_height);
        }
        do_adapt_msg = do_adapt_msg + ('执行修改高度:' + do_adapt_height);
    }
    if (globalTable['ShowAdaptMsg'] === 'true') {
        debug_alert(base_msg + (cal_adapt_msg + do_adapt_msg));
    }
    return do_adapt_height;
};
do_height_adapt = function (widget_name, real_adapt_height) {
    var widget_name = formatNull(widget_name);
    var real_adapt_height = formatNull(real_adapt_height);
    changeStyle(widget_name, 'height', real_adapt_height);
    location.reload();
};
getEleLocation = function (element, locTag) {
    var element = formatNull(element);
    var locTag = formatNull(locTag);
    var res = '';
    if (element != '' && locTag != '') {
        var element = formatNull(document.getElementsByName(element)[1]);
        if (element != '') {
            var location = element.getStyleByName(locTag);
            res = px2num(location);
        }
    }
    return res;
};
setEleLocation = function (element, locTag, locValue) {
    var element = formatNull(element);
    var locTag = formatNull(locTag);
    var locValue = formatNull(locValue);
    if (element != '' && locTag != '' && locValue != '') {
        var element = document.getElementsByName(element)[1];
        element.setStyleByName(locTag, tostring(locValue) + 'px');
    }
};
getParentWidget = function (childrenWidgetName) {
    var childrenWidgetName = formatNull(childrenWidgetName);
    var parentWidget = '';
    if (childrenWidgetName != '') {
        childrenEle = document.getElementsByName(childrenWidgetName)[1];
        parentWidget = childrenEle.getParent();
    }
    return parentWidget;
};
getChildrenWidgetList = function (parentWidgetName) {
    var parentWidgetName = formatNull(parentWidgetName);
    var childrenWidgetList = '';
    if (parentWidgetName != '') {
        parentEle = document.getElementsByName(parentWidgetName)[1];
        childrenWidgetList = parentEle.getChildren();
    }
    return childrenWidgetList;
};
getValue = function (name, debugFlag) {
    var element = document.getElementsByName(name)[1];
    if (element === '' || element === null) {
        var debugFlag = formatNull(debugFlag, '1');
        if (debugFlag != '0') {
            debug_alert('name=' + (name + '的控件不存在!'));
        }
        return '';
    } else {
        var res = element.getPropertyByName('value');
        return formatNull(res);
    }
};
changePropertyReload = function (name, property, newValue, index) {
    changeProperty(name, property, newValue, index);
    page_reload();
};
changeProperty = function (name, property, newValue, index) {
    var ctrl = document.getElementsByName(name);
    if (ctrl && ctrl.length > 0) {
        var index = formatNull(index, '1');
        ctrl[parseFloat(index)].setPropertyByName(property, newValue);
    }
};
changeAllProperty = function (name, property, newValue) {
    var ctrl = document.getElementsByName(name);
    if (ctrl && ctrl.length > 0) {
        for (let i = 1; ctrl.length; i++) {
            ctrl[i].setPropertyByName(property, newValue);
        }
    }
};
getStyle = function (widgetName, styleName) {
    var res = '';
    var widgetName = formatNull(widgetName);
    var styleName = formatNull(styleName);
    if (widgetName != '' && styleName != '') {
        var StyleValue = document.getElementsByName(widgetName)[1].getStyleByName(styleName);
        res = formatNull(StyleValue);
    }
    return res;
};
changeStyleReload = function (name, style, value) {
    changeStyle(name, style, value);
    page_reload();
};
changeStyle = function (name, style, value) {
    var ctrl = document.getElementsByName(name);
    if (ctrl && ctrl.length > 0) {
        ctrl[1].setStyleByName(style, value);
    }
};
changeAllStyle = function (name, style, value) {
    var ctrl = document.getElementsByName(name);
    if (ctrl && ctrl.length > 0) {
        for (let i = 1; ctrl.length; i++) {
            ctrl[i].setStyleByName(style, value);
        }
    }
};
changeStyleByIndex = function (name, Index, style, value) {
    var ctrl = document.getElementsByName(name);
    if (ctrl && ctrl.length >= parseFloat(Index)) {
        ctrl[parseFloat(Index)].setStyleByName(style, value);
    }
};
show_ele = function (name) {
    changeStyle(name, 'display', 'block');
};
batch_show_ele = function (namelist) {
    var namelist = formatNull(namelist);
    if (namelist === '') {
        debug_alert('参数为空');
    } else {
        var array = splitUtils(namelist, ',');
        if (array.length < 1) {
            debug_alert('控件集合为空');
        } else {
            for (let i = 1; array.length; i++) {
                var name = formatNull(array[i]);
                show_ele(name);
            }
        }
    }
};
show_eles = function (name) {
    changeAllStyle(name, 'display', 'block');
};
hide_ele = function (name) {
    changeStyle(name, 'display', 'none');
};
batch_hide_ele = function (namelist) {
    var namelist = formatNull(namelist);
    if (namelist === '') {
        debug_alert('参数为空');
    } else {
        var array = splitUtils(namelist, ',');
        if (array.length < 1) {
            debug_alert('控件集合为空');
        } else {
            for (let i = 1; array.length; i++) {
                var name = formatNull(array[i]);
                hide_ele(name);
            }
        }
    }
};
hide_eles = function (name) {
    changeAllStyle(name, 'display', 'none');
};
jjbx_utils_getRadioButtonState = function (elementName, imageName) {
    var elements = document.getElementsByName(elementName);
    var imageName = formatNull(imageName, 'btn_apply.png');
    var bacImage = '';
    var tempIndex = '';
    for (let i = 1; elements.length; i++) {
        bacImage = elements[i].getStyleByName('background-image');
        if (bacImage === imageName) {
            tempIndex = tostring(i);
        }
    }
    return tempIndex;
};
back_fun = function (index, LoadingFlag, JumpStyle) {
    var index = formatNull(index);
    var LoadingFlag = formatNull(LoadingFlag, '2');
    var JumpStyle = formatNull(JumpStyle, 'left');
    var HistoryLength = parseFloat(history.length());
    if (isShowContent) {
        jjbx_utils_hideContent();
    } else {
        page_sys_init();
        if (HistoryLength === 1) {
            lua_menu.to_index_page('back');
        } else {
            if (LoadingFlag === '1' || LoadingFlag === '2') {
                show_loading();
            } else {
                close_loading();
            }
            var page = '';
            if (index != '') {
                page = history.get(parseFloat(index));
            } else {
                page = history.get(-1);
            }
            var afterpage = slt2.render(slt2.loadstring(page), null);
            var CloseLoading = 'false';
            if (LoadingFlag === '1' || LoadingFlag === '3') {
                CloseLoading = 'true';
            }
            var UseJumpStyle = page_jump_style(JumpStyle);
            location.replace(afterpage, UseJumpStyle, replace_callback, { CloseLoading: CloseLoading });
        }
    }
};
page_jump_style = function (JumpStyle) {
    var UseJumpStyle = {};
    if (JumpStyle === 'left') {
        UseJumpStyle = transitionType.slideFromLeft;
    } else if (JumpStyle === 'right') {
        UseJumpStyle = transitionType.slideFromRight;
    } else if (JumpStyle === 'up') {
        UseJumpStyle = transitionType.curlUp;
    } else if (JumpStyle === 'down') {
        UseJumpStyle = transitionType.curlDown;
    } else if (JumpStyle === 'none') {
        UseJumpStyle = {};
    }
    return UseJumpStyle;
};
back_fun_noloading = function (index) {
    back_fun(index, '3');
};
back_fun_loading = function (index) {
    back_fun(index, '2');
};
back_fun_getHistory = function (historyIndex) {
    var historyIndex = formatNull(historyIndex);
    if (historyIndex === '') {
        historyIndex = history.length() - 1;
    }
    if (isShowContent) {
        jjbx_utils_hideContent();
    } else {
        page_sys_init();
        show_loading();
        var page = history.get(historyIndex);
        var afterpage = slt2.render(slt2.loadstring(page), null);
        location.replace(afterpage, transitionType.slideFromLeft, replace_callback, { CloseLoading: 'true' });
    }
};
count_containers_height = function (containerlists, toppx) {
    var heightall = 0;
    var debug_alert_msg = '';
    var containerlists = formatNull(containerlists);
    if (containerlists === '') {
        debug_alert('参数为空');
    } else {
        var array = splitUtils(containerlists, ',');
        if (array.length < 1) {
            debug_alert('控件集合为空');
        } else {
            for (let i = 1; array.length; i++) {
                var heightstr = formatNull(getEleLocation(array[i], 'height'), '0');
                debug_alert_msg = debug_alert_msg + (array[i] + (':' + (heightstr + '\\n')));
                var height = px2num(heightstr);
                heightall = heightall + height;
            }
        }
    }
    if (heightall != 0) {
        var toppx = formatNull(toppx, get_top_diff());
        var bottompx = 0;
        heightall = heightall - toppx - bottompx;
    }
    return heightall;
};
get_noraRegularWidth = function (elementName, elementValue) {
    var noraregular = document.getElementsByName(elementName)[1];
    var noraregularValue = formatNull(elementValue);
    if (noraregularValue === '') {
        noraregularValue = noraregular.getPropertyByName('value');
    }
    var noraregularValueLen = '';
    noraregularValueLen = ryt.getLengthByStr(noraregularValue);
    var elementWidth = '';
    var lenpx = '';
    if (noraregularValueLen < 3) {
        lenpx = C_noraregular_ShortWidth;
    } else {
        lenpx = C_noraregular_LongWidth;
    }
    elementWidth = parseFloat(noraregularValueLen) * lenpx;
    noraregular.setStyleByName('width', tostring(elementWidth) + 'px');
    return tostring(elementWidth);
};
adapt_right_locateion = function (reference, referenceFont, interval, oldInterval) {
    var labelLen = ryt.getLengthByStr(reference);
    var imgRight = 0;
    imgRight = oldInterval + interval + labelLen * referenceFont / 2;
    return imgRight;
};
get_top_diff = function (height) {
    var height = formatNull(height, 0);
    if (height === 0) {
        var topDiffValue = 0;
        if (platform === 'iPhone OS') {
            if (systemTable['is_iPhoneX'] === 'true') {
                topDiffValue = C_iPhone_TopHeightDiff + C_iPX_SpecialtopHeight;
            } else {
                var PhoneType = ryt.getIPhoneType();
                var LowerPhoneTypeStr = string.lower(PhoneType);
                var LoweriPhonePlusDevices = string.lower(C_iPhonePlusDevices);
                if (string.find(LoweriPhonePlusDevices, LowerPhoneTypeStr)) {
                    topDiffValue = C_iPhone_TopHeightDiff + 1;
                } else {
                    topDiffValue = C_iPhone_TopHeightDiff;
                }
            }
        } else {
            topDiffValue = C_Android_TopHeightDiff;
        }
        topDiffValue = topDiffValue;
        return topDiffValue;
    } else {
        return height;
    }
};
get_bottom_diff = function (height) {
    var height = formatNull(height, 0);
    if (height === 0) {
        var bottomDiffValue = 0;
        var iPhoneXBottomStyle = formatNull(globalTable['iPhoneXBottomStyle']);
        var iSiPhoneX = formatNull(systemTable['is_iPhoneX']);
        if (iSiPhoneX === 'true') {
            if (iPhoneXBottomStyle === 'show') {
                bottomDiffValue = C_iPX_SpecialbottomHeight;
            } else {
                bottomDiffValue = 0;
            }
        } else {
            bottomDiffValue = 0;
        }
        return bottomDiffValue;
    } else {
        return height;
    }
};
adapt_right_locateion = function (reference, referenceFont, interval, oldInterval) {
    var labelLen = ryt.getLengthByStr(reference);
    var imgRight = 0;
    imgRight = oldInterval + interval + labelLen * referenceFont / 2;
    return imgRight;
};
jjbx_utils_adaptFontSize = function (elementName) {
    if (ryt.getLengthByStr(getValue(elementName)) > 34) {
        changeStyle(elementName, 'font-size', '10px');
    }
};
jjbx_setStyleLeftOrRight = function (targetpostion, targetElemetName, selfpostion, selfElmentName, leftOrRight) {
    var leftOrRight = formatNull(leftOrRight, 'left');
    var targetElemet = document.getElementsByName(targetElemetName);
    var selfElment = document.getElementsByName(selfElmentName);
    var targetElemetWidht = '';
    for (let i = 1; targetElemet.length; i++) {
        targetElemetWidht = targetElemet[i].getStyleByName('width');
        targetElemetWidht = ryt.getSubstringValue(targetElemetWidht, 0, ryt.getLengthByStr(targetElemetWidht) - 2);
        selfElment[i].setStyleByName(leftOrRight, tostring(targetpostion + targetElemetWidht + selfpostion) + 'px');
    }
    page_reload();
};
jjbx_setStyleToLeft = function (targetLeft, targetElemetName, selfLeft, selfElmentName) {
    jjbx_setStyleLeftOrRight(targetLeft, targetElemetName, selfLeft, selfElmentName, 'left');
};
jjbx_setStyleToRight = function (targetRight, targetElemetName, selfLeft, selfElmentName) {
    jjbx_setStyleLeftOrRight(targetRight, targetElemetName, selfLeft, selfElmentName, 'right');
};
render_input_alert_window = function (title, inputhold, inputmax, btntext, btnfun) {
    var RenderArg = {
        title: title,
        inputhold: inputhold,
        inputmax: inputmax,
        btntext: btntext,
        btnfun: btnfun
    };
    do_render_input_alert_window(RenderArg);
};
do_render_input_alert_window = function (RenderArg) {
    var operateTitle = vt('title', RenderArg);
    var textareaHoldContent = vt('inputhold', RenderArg, '请输入');
    var inputMaxLength = vt('inputmax', RenderArg, '100');
    var btnText = vt('btntext', RenderArg, '确定');
    var btnFun = vt('btnfun', RenderArg);
    var SysLayoutStyle = vt('SysLayoutStyle', systemTable);
    var showUploadButton = vt('showUploadButton', RenderArg);
    var uploadBtnFun = vt('uploadBtnFun', RenderArg);
    var doOperateHtml = '[[\n        <div class="do_operate_bg_div" name="do_operate_bg_div" border="0" onclick="">\n            <div class="do_operate_div_]]' + (SysLayoutStyle + ('[[" border="1">\n                <div class="do_operate_title_label_div" border="0">\n                    <label class="do_operate_title_label" value="]]' + (operateTitle + '[["/>\n                </div>\n                <div class="do_operate_close_div" border="0" onclick="close_do_operate_window(\'do_operate_bg_div\')" >\n                    <img class="do_operate_close_icon" src="local:sl_ico_close.png" onclick="close_do_operate_window(\'do_operate_bg_div\')" />\n                </div>\n                <div class="do_operate_headline_div" border="0"/>\n                <div class="space_10_div" border="0"/>\n    ]]')));
    if (operateTitle === '转办回复') {
        doOperateHtml = doOperateHtml + ('[[\n            <div class="transferMsg_div" border="0">\n                <label class="transferMsg_title" value="转办内容"></label>\n                <label class="transferMsg_label" value="]]' + (globalTable['transferMsg'] + '[["></label>\n                <div class="space_10_div" border="0"/>\n                <label class="transferMsg_title2" value="回复内容"></label>\n            </div>  \n            <div class="space_10_div" border="0"/>\n        ]]'));
    }
    doOperateHtml = doOperateHtml + ('[[\n        <div class="do_operate_input_div" border="1">\n            <textarea class="do_operate_input_textarea" inputKeyboardDisapper="YES" inputScrollFitPage="inputScrollFitPage" disableEmoji="false" selection="3" inputTransparents="yes" name="do_operate_input_textarea" border="0" hold="]]' + (textareaHoldContent + ('[[" holdColor="#D9D9D9" maxleng="]]' + (inputMaxLength + '[[" />\n        </div>\n    ]]'))));
    if (btnText === '批准' && globalTable['spjdFlag'] === '1') {
        doOperateHtml = doOperateHtml + '[[\n            <div class="space_10_div" border="0"/>\n            <div class="do_operate_title_label_div2" border="0">\n                <label class="do_operate_title_label2" value="请选择下个审批流程"/>\n            </div>\n            <div class="do_operate_spjd_div" border="0" name="spjdList">\n        ]]';
        for (let i = 1; globalTable['selectNodelist'].length; i++) {
            doOperateHtml = doOperateHtml + ('[[\n                <div class="do_operate_spjd_name_div" border="0" onclick="chooseOneJd(]]' + (i + ('[[)">\n                    <img src="local:select.png" class="do_operate_spjd_check" name="check_img" onclick="chooseOneJd(]]' + (i + ('[[)"/>\n                    <label class="do_operate_spjd_name" value="]]' + (globalTable['selectNodelist'][i]['descDirection'] + ('[[" onclick="chooseOneJd(]]' + (i + '[[)"/>\n                </div>\n            ]]'))))))));
        }
        doOperateHtml = doOperateHtml + '[[\n            </div>\n        ]]';
    }
    if (showUploadButton === '1') {
        doOperateHtml = doOperateHtml + ('[[\n            <div class="space_10_div" border="0"/>\n            <div class="transferMsg_upload_div" border="1" name="fj_div">\n                <label class="transferMsg_upload_label_title" value="]]' + (C_UploadDefaultCountsTip + ('[[" name="fj_title"></label>\n                <label class="transferMsg_upload_label_value" value="上传附件" name="fj" onclick="]]' + (uploadBtnFun + '[["></label>\n                <img src="local:arrow_common.png" name="fj_img" class="transferMsg_upload_arrow" />\n            </div>\n        ]]'))));
    }
    doOperateHtml = doOperateHtml + ('[[\n                <div class="space_20_div" border="0"/>\n                <div class="do_operate_btn_div" border="0" onclick="]]' + (btnFun + ('[[">\n                    <div class="do_operate_btn_label_div" border="0" onclick="]]' + (btnFun + ('[[">\n                        <label class="do_operate_btn_label" name="do_operate_btn_label" border="2" onclick="]]' + (btnFun + ('[[" value="]]' + (btnText + '[[" />\n                    </div>\n                </div>\n                <div class="space_30_div" border="0"/>\n            </div>\n        </div>\n    ]]'))))))));
    document.getElementsByName('do_operate_bg_div')[1].setInnerHTML(doOperateHtml);
    page_reload();
};
render_selectNode_window = function (btnText, btnFun) {
    var SysLayoutStyle = systemTable['SysLayoutStyle'];
    var doOperateHtml = '[[\n        <div class="do_operate_bg_div" name="do_operate_bg_div" border="0" onclick="">\n            <div class="do_operate_div_]]' + (SysLayoutStyle + '[[" border="1">\n                <div class="do_operate_title_label_div" border="0">\n                    <label class="do_operate_title_label" value=""/>\n                </div>\n                <div class="do_operate_close_div" border="0">\n                    <img class="do_operate_close_icon" src="local:sl_ico_close.png" onclick="close_do_operate_window(\'do_operate_bg_div\')" />\n                </div>\n                <div class="space_10_div" border="0"/>\n                <div class="do_operate_title_label_div2" border="0">\n                    <label class="do_operate_title_label2" value="请选择流程"/>\n                </div>\n                <div class="do_operate_spjd_div" border="0" name="spjdList">\n    ]]');
    for (let i = 1; globalTable['selectNodelist'].length; i++) {
        doOperateHtml = doOperateHtml + ('[[\n            <div class="do_operate_spjd_name_div" border="0" onclick="chooseOneJd(]]' + (i + ('[[)">\n                <img src="local:select.png" class="do_operate_spjd_check" name="check_img" onclick="chooseOneJd(]]' + (i + ('[[)"/>\n                <label class="do_operate_spjd_name" value="]]' + (globalTable['selectNodelist'][i]['descDirection'] + ('[[" onclick="chooseOneJd(]]' + (i + '[[)"/>\n            </div>\n        ]]'))))))));
    }
    doOperateHtml = doOperateHtml + ('[[\n            </div>\n                <div class="space_20_div" border="0"/>\n                <div class="do_operate_btn_div" border="0" onclick="]]' + (btnFun + ('[[">\n                    <div class="do_operate_btn_label_div" border="0" onclick="]]' + (btnFun + ('[[">\n                        <label class="do_operate_btn_label" name="do_operate_btn_label" border="2" onclick="]]' + (btnFun + ('[[" value="]]' + (btnText + '[[" />\n                    </div>\n                </div>\n                <div class="space_30_div" border="0"/>\n            </div>\n        </div>\n    ]]'))))))));
    document.getElementsByName('do_operate_bg_div')[1].setInnerHTML(doOperateHtml);
    if (globalTable['selectNodelist'].length > 7) {
        height_adapt('spjdList', 450);
    }
    page_reload();
};
show_do_operate_window = function (windowname) {
    var windowname = formatNull(windowname, 'do_operate_bg_div');
    changeStyle(windowname, 'display', 'block');
};
close_do_operate_window = function (windowname) {
    globalTable['temp_reloadFlag'] = '';
    var windowname = formatNull(windowname, 'do_operate_bg_div');
    changeStyle(windowname, 'display', 'none');
};
lua_page.open_operate_fold = function () {
    show_eles('operate_info_fold_div');
    hide_ele('operate_fold_ctrl_div');
    page_reload();
};
render_operate_info = function (operateInfoList, elementName) {
    var border = '0';
    var operateInfoList = formatNull(operateInfoList);
    var operateInfoListCounts = operateInfoList.length;
    var elementName = formatNull(elementName);
    var OperateFoldCtrlHtml = '';
    if (C_Operate_Show_Counts != '' && operateInfoListCounts > C_Operate_Show_Counts) {
        OperateFoldCtrlHtml = '[[\n            <div class="operate_fold_ctrl_div" name="operate_fold_ctrl_div" border="]]' + (border + '[[" onclick="lua_page.open_operate_fold()">\n                <label class="operate_fold_ctrl_label" name="operate_fold_ctrl_label" value="展开全部审批历史" onclick="lua_page.open_operate_fold()" />\n                <img class="operate_fold_ctrl_icon" name="operate_fold_ctrl_icon" src="local:arrow_down_blue.png" onclick="lua_page.open_operate_fold()" />\n            </div>\n        ]]');
    }
    var OperateHtmlsContent = '';
    var operate_node_stopTime_style = '';
    for (let i = 1; operateInfoListCounts; i++) {
        var operateItem = formatNull(operateInfoList[i]);
        var classValue = '';
        var status = vt('status', operateItem);
        if (status === 'point') {
            classValue = 'operate_status_doing_label';
        } else {
            classValue = 'operate_status_done_label';
        }
        var operater_name = vt('name', operateItem);
        operater_name = string.gsub(operater_name, '<', '');
        operater_name = string.gsub(operater_name, '>', '');
        var show_operater_name = cutStr(operater_name, 6);
        var operate_node_opinion = vt('opinion', operateItem);
        var operate_induty_name = vt('nodeName', operateItem);
        var opinionlinecounts = 0;
        var opinionlength = ryt.getLengthByStr(operate_node_opinion);
        if (opinionlength < 20) {
            opinionlinecounts = 1;
        } else if (opinionlength < 40) {
            opinionlinecounts = 2;
        } else if (opinionlength < 60) {
            opinionlinecounts = 3;
        } else if (opinionlength < 80) {
            opinionlinecounts = 4;
        } else {
            opinionlinecounts = 5;
        }
        var opinion_classValue = 'operate_opinion_div';
        if (opinionlinecounts > 4) {
            opinion_classValue = 'operate_opinion_div_more';
        }
        var operate_info_div_class = 'operate_info_div_' + parseFloat(opinionlinecounts);
        var show_operate_node_status = jjbx_formatSPLC(status, operate_node_opinion);
        var operate_node_stopTime = vt('stopTime', operateItem);
        var operate_node_stopDays = vt('stopDays', operateItem);
        var isRobotFlag = vt('isRobot', operateItem, '0');
        var operate_node_stopTime_show = '';
        if (operate_node_stopTime === '' && operate_node_stopDays === '') {
            operate_node_stopTime_show = '';
        } else {
            if (parseFloat(operate_node_stopDays) < 1) {
                operate_node_stopTime_show = '已停留0个工作日';
                operate_node_stopTime_style = 'stopDays';
            } else {
                operate_node_stopTime_show = '已停留' + (operate_node_stopDays + '个工作日');
                operate_node_stopTime_style = 'stopDays';
            }
        }
        var operate_node_dealTime = formatNull(operateItem['dealTime']);
        var operate_onclick_fun = 'alert_operater_name(\'' + (operater_name + ('\',\'' + (show_operate_node_status + '\')')));
        if (operate_node_opinion === '待审批' || operate_node_opinion === '审批中') {
            operate_node_opinion = '';
        }
        var induty_name_html = '';
        if (operate_induty_name != '') {
            induty_name_html = '[[\n                <div class="induty_name_div" border="]]' + (border + ('[[">\n                    <label class="induty_name_label">]]' + (operate_induty_name + '[[</label>\n                </div>\n            ]]')));
        }
        var operate_info_div_name = '';
        if (C_Operate_Show_Counts != '' && i > C_Operate_Show_Counts) {
            operate_info_div_name = 'operate_info_fold_div';
        } else {
            operate_info_div_name = 'operate_info_base_div';
        }
        var concatSpace = ' ';
        var isSkip = vt('isSkip', operateItem);
        if (isSkip === '1') {
            isSkip = '\uFF08基建\uFF09';
        } else {
            isSkip = '';
        }
        OperateHtmlsContent = OperateHtmlsContent + ('[[\n                <div name="]]' + (operate_info_div_name + ('[[" class="operate_info_content_div" border="]]' + (border + ('[[">\n                    ]]' + (induty_name_html + ('[[\n                    <div class="]]' + (operate_info_div_class + ('[[" border="]]' + (border + ('[[" onclick="]]' + (operate_onclick_fun + ('[[">\n                        <div class="operate_info_div" border="]]' + (border + ('[[" onclick="]]' + (operate_onclick_fun + '[[">\n            ]]'))))))))))))))));
        if (isRobotFlag === '1') {
            OperateHtmlsContent = OperateHtmlsContent + '[[\n                            <img src="local:robot.png" class="robot_img"/>\n                            ]]';
        } else {
            OperateHtmlsContent = OperateHtmlsContent + ('[[\n                            <label class="operate_name_label" onclick="]]' + (operate_onclick_fun + ('[[">]]' + (show_operater_name + '[[</label>\n                            ]]'))));
        }
        OperateHtmlsContent = OperateHtmlsContent + ('[[\n                            <label class="]]' + (classValue + ('[[" value="]]' + (concatSpace + (show_operate_node_status + ('   ' + ('[[" onclick="]]' + (operate_onclick_fun + ('[["></label>\n                            <label class="operate_isSkip_label" value="]]' + (isSkip + ('   ' + ('[[" onclick="]]' + (operate_onclick_fun + ('[["></label>\n                            <div class="]]' + (opinion_classValue + ('[[" border="]]' + (border + ('[[" onclick="]]' + (operate_onclick_fun + ('[[">\n                                <label class="operate_opinion_label" onclick="]]' + (operate_onclick_fun + ('[[">]]' + (operate_node_opinion + '[[</label>\n                            </div>\n        ]]')))))))))))))))))))))));
        if (operate_node_dealTime != '') {
            OperateHtmlsContent = OperateHtmlsContent + ('[[\n                <label class="operate_done_time_label">]]' + (operate_node_dealTime + '[[</label>\n            ]]'));
        } else {
            if (operate_node_stopTime != '') {
                OperateNodeStopTimes = parseFloat(operate_node_stopTime);
                if (operate_node_stopTime_style === 'stopTime') {
                    OperateHtmlsContent = OperateHtmlsContent + ('[[\n                        <label class="operate_text_label" name="operate_text_label">已停留</label>\n                        <label class="operate_stop_time_label" name="operate_stop_time_label">]]' + (operate_node_stopTime_show + '[[</label>\n                    ]]'));
                } else {
                    OperateHtmlsContent = OperateHtmlsContent + ('[[\n                        <label class="operate_stop_days_label" name="operate_stop_days_label">]]' + (operate_node_stopTime_show + '[[</label>\n                    ]]'));
                }
            }
        }
        OperateHtmlsContent = OperateHtmlsContent + '[[\n                    </div>\n                </div>\n            </div>\n        ]]';
    }
    OperateHtmls = '[[\n        <div class="]]' + (elementName + ('[[" border="]]' + (border + ('[[" name="]]' + (elementName + ('[[">\n            <div class="operate_msginfo_div" border="]]' + (border + ('[[" name="operate_msginfo_div">\n                <div class="space_10_div" border="]]' + (border + ('[[" />\n                ]]' + (OperateHtmlsContent + ('[[\n                <div class="space_10_div" border="]]' + (border + ('[[" />\n            </div>\n            ]]' + (OperateFoldCtrlHtml + '[[\n        </div>\n    ]]')))))))))))))));
    document.getElementsByName(elementName)[1].setInnerHTML(OperateHtmls);
    hide_eles('operate_info_fold_div');
    page_reload();
    for (let k = 1; operateInfoListCounts; k++) {
        if (operateInfoList[k]['status'] === 'point') {
            if (operate_node_stopTime_style === 'stopTime') {
                setoperate_text_labelTimeRight();
                var CurrentPageInfo = lua_page.current_page_info();
                var PageFilePath = vt('page_file_path', CurrentPageInfo);
                var MissionRegisterArg = {
                    ID: 'ApplyDetailStopTimer',
                    Name: '单据详情页面\uFF0C已停留审批时间倒计时',
                    PageUrl: PageFilePath,
                    CallFunc: 'update_operate_stopTime_label',
                    CallArg: ''
                };
                lua_system.timer_register(MissionRegisterArg);
            }
        }
    }
};
alert_operater_name = function (name, status) {
    var name = formatNull(name);
    if (name != '') {
        if (string.find(name, '审批')) {
        } else {
            if (ryt.getLengthByStr(name) > 6) {
                if (status === '待回复' || status === '已回复') {
                    alert_confirm('转办对象', name, '', '确定', '');
                } else {
                    alert_confirm('审批人', name, '', '确定', '');
                }
            } else {
            }
        }
    }
};
update_operate_stopTime_label = function () {
    OperateNodeStopTimes = OperateNodeStopTimes + 1000;
    var codeTimerelement = 'operate_stop_time_label';
    changeProperty(codeTimerelement, 'value', millisecondTotime(OperateNodeStopTimes));
};
load_operate_button = function (operate_style, operate_arg) {
    var operate_arg = json2table(operate_arg);
    var optionDiv = '';
    if (operate_style === 'four_btn') {
        optionDiv = '[[\n            <div class="operate_btn_div" border="0" name="operate_btn_div">\n                <div class="four_btn_div" border="0">\n                    <div class="four_btn1_div" border="0" onclick="]]' + (operate_arg['btn1_onclick'] + ('[[">\n                        <label class="four_btn1_label">]]' + (operate_arg['btn1_text'] + ('[[</label>\n                    </div>\n                    <div class="four_btn2_div" border="0" onclick="]]' + (operate_arg['btn2_onclick'] + ('[[">\n                        <label class="four_btn2_label">]]' + (operate_arg['btn2_text'] + ('[[</label>\n                    </div>\n                    <div class="four_btn3_div" border="0" onclick="]]' + (operate_arg['btn3_onclick'] + ('[[">\n                        <label class="four_btn3_label">]]' + (operate_arg['btn3_text'] + ('[[</label>\n                    </div>\n                    <div class="four_btn4_div" border="0" onclick="]]' + (operate_arg['btn4_onclick'] + ('[[">\n                        <label class="four_btn4_label">]]' + (operate_arg['btn4_text'] + '[[</label>\n                    </div>\n                </div>\n            </div>\n        ]]')))))))))))))));
    } else if (operate_style === 'three_btn') {
        optionDiv = '[[\n            <div class="operate_btn_div" border="0" name="operate_btn_div">\n                <div class="three_btn_div" border="0">\n                    <div class="three_btn1_div" border="0" onclick="]]' + (operate_arg['btn1_onclick'] + ('[[">\n                        <label class="three_btn1_label">]]' + (operate_arg['btn1_text'] + ('[[</label>\n                    </div>\n                    <div class="three_btn2_div" border="0" onclick="]]' + (operate_arg['btn2_onclick'] + ('[[">\n                        <label class="three_btn2_label">]]' + (operate_arg['btn2_text'] + ('[[</label>\n                    </div>\n                    <div class="three_btn3_div" border="0" onclick="]]' + (operate_arg['btn3_onclick'] + ('[[">\n                        <label class="three_btn3_label">]]' + (operate_arg['btn3_text'] + '[[</label>\n                    </div>\n                </div>\n            </div>\n        ]]')))))))))));
    } else if (operate_style === 'two_btn') {
        optionDiv = '[[\n            <div class="operate_btn_div" border="0" name="operate_btn_div">\n                <div class="two_btn_div" name="two_btn_div" border="0">\n                    <div class="two_btn1_div" border="0" onclick="]]' + (operate_arg['btn1_onclick'] + ('[[">\n                        <label class="two_btn1_label">]]' + (operate_arg['btn1_text'] + ('[[</label>\n                    </div>\n                    <div class="two_btn2_div" border="0" onclick="]]' + (operate_arg['btn2_onclick'] + ('[[">\n                        <label class="two_btn2_label">]]' + (operate_arg['btn2_text'] + '[[</label>\n                    </div>\n                </div>\n            </div>\n        ]]')))))));
    } else if (operate_style === 'one_btn') {
        optionDiv = '[[\n            <div class="operate_btn_div" border="0" name="operate_btn_div">\n                <div class="btn_single_full_screen_div" border="0" onclick="]]' + (operate_arg['btn1_onclick'] + ('[[">\n                    <label class="btn_single_full_screen_label" border="0" value="]]' + (operate_arg['btn1_text'] + '[[" />\n                </div>\n            </div>\n        ]]')));
    } else if (operate_style === 'one_btn2') {
        optionDiv = '[[\n            <div class="operate_btn_div" border="0" name="operate_btn_div">\n                <div class="btn_single_full_screen_div" border="0" onclick="]]' + (operate_arg['btn1_onclick'] + ('[[">\n                    <img src="local:share.png" class="btn_single_img_gx" />\n                    <label class="btn_single_text_gx" border="0" value="]]' + (operate_arg['btn1_text'] + '[[" />\n                </div>\n            </div>\n        ]]')));
    } else if (operate_style === 'one_btn3') {
        optionDiv = '[[\n            <div class="operate_btn_div" border="0" name="operate_btn_div">\n                <div class="btn_single_full_screen_div" border="0">\n                    <label class="btn_single_full_screen_label2" border="0" value="]]' + (operate_arg['btn1_text'] + '[[" />\n                </div>\n            </div>\n        ]]');
    } else if (operate_style === 'three_btn2') {
        optionDiv = '[[\n            <div class="operate_btn_div" border="0" name="operate_btn_div">\n                <div class="three_btn_div" border="0">\n                    <div class="three_btn1_div" border="0" onclick="]]' + (operate_arg['btn1_onclick'] + ('[[">\n                        <img src="local:share.png" class="three_btn1_label_img" />\n                        <label class="three_btn1_label_text">]]' + (operate_arg['btn1_text'] + ('[[</label>\n                    </div>\n                    <div class="three_btn2_div" border="0" onclick="]]' + (operate_arg['btn2_onclick'] + ('[[">\n                        <label class="three_btn2_label">]]' + (operate_arg['btn2_text'] + ('[[</label>\n                    </div>\n                    <div class="three_btn3_div" border="0" onclick="]]' + (operate_arg['btn3_onclick'] + ('[[">\n                        <label class="three_btn3_label">]]' + (operate_arg['btn3_text'] + '[[</label>\n                    </div>\n                </div>\n            </div>\n        ]]')))))))))));
    } else if (operate_style === 'two_btn2') {
        optionDiv = '[[\n            <div class="operate_btn_div" border="0" name="operate_btn_div">\n                <div class="two_btn_div" name="two_btn_div" border="0">\n                    <div class="two_btn1_div" border="0" onclick="]]' + (operate_arg['btn1_onclick'] + ('[[">\n                        <img src="local:share.png" class="two_btn1_label_img" />\n                        <label class="two_btn1_label_text">]]' + (operate_arg['btn1_text'] + ('[[</label>\n                    </div>\n                    <div class="two_btn2_div" border="0" onclick="]]' + (operate_arg['btn2_onclick'] + ('[[">\n                        <label class="two_btn2_label">]]' + (operate_arg['btn2_text'] + '[[</label>\n                    </div>\n                </div>\n            </div>\n        ]]')))))));
    } else if (operate_style === 'three_btn3') {
        optionDiv = '[[\n            <div class="operate_btn_div" border="0" name="operate_btn_div">\n                <div class="three_btn_div" border="0">\n                    <div class="three_btn1_div" border="0">\n                        <label class="three_btn1_label2">]]' + (operate_arg['btn1_text'] + ('[[</label>\n                    </div>\n                    <div class="three_btn2_div" border="0" onclick="]]' + (operate_arg['btn2_onclick'] + ('[[">\n                        <label class="three_btn2_label">]]' + (operate_arg['btn2_text'] + ('[[</label>\n                    </div>\n                    <div class="three_btn3_div" border="0" onclick="]]' + (operate_arg['btn3_onclick'] + ('[[">\n                        <label class="three_btn3_label">]]' + (operate_arg['btn3_text'] + '[[</label>\n                    </div>\n                </div>\n            </div>\n        ]]')))))))));
    } else if (operate_style === 'two_btn3') {
        optionDiv = '[[\n            <div class="operate_btn_div" border="0" name="operate_btn_div">\n                <div class="two_btn_div" name="two_btn_div" border="0">\n                    <div class="two_btn1_div" border="0">\n                        <label class="two_btn1_label2">]]' + (operate_arg['btn1_text'] + ('[[</label>\n                    </div>\n                    <div class="two_btn2_div" border="0" onclick="]]' + (operate_arg['btn2_onclick'] + ('[[">\n                        <label class="two_btn2_label">]]' + (operate_arg['btn2_text'] + '[[</label>\n                    </div>\n                </div>\n            </div>\n        ]]')))));
    } else {
        changeStyle('operate_btn_div', 'display', 'none');
    }
    if (optionDiv != '') {
        document.getElementsByName('operate_btn_div')[1].setInnerHTML(optionDiv);
    }
};
create_bill_detal_baseinfo = function (detailItem, baseinfodivname) {
    var detailItem = formatNull(detailItem);
    var baseinfodivname = formatNull(baseinfodivname);
    var itemhtmls = '';
    var debug_alert_msg = '';
    for (let i = 1; detailItem.length; i++) {
        var style = formatNull(detailItem[i]['style']);
        var value_label_style = '';
        if (style === 'orange') {
            value_label_style = 'bill_basedetail_value_orange_label';
        } else if (style === 'blue') {
            value_label_style = 'bill_basedetail_value_blue_label';
        } else {
            value_label_style = 'bill_basedetail_value_label';
        }
        var topname = formatNull(detailItem[i]['topname']);
        var topvalue = formatNull(detailItem[i]['topvalue']);
        var downname = formatNull(detailItem[i]['downname']);
        var downvalue = formatNull(detailItem[i]['downvalue']);
        var func = formatNull(detailItem[i]['func']);
        debug_alert_msg = debug_alert_msg + ('topname:' + (topname + ('\\n' + ('topvalue:' + (topvalue + ('\\n' + ('downname:' + (downname + ('\\n' + ('downvalue:' + (downvalue + ('\\n' + ('func:' + (func + ('\\n' + '\\n')))))))))))))));
        var setcontent = '[[\n            <div class=\'bill_basedetail_item_div\' border=\'0\' onclick=\']]' + (func + ('[[\'>\n                <label class=\'bill_basedetail_key_label\' value=\']]' + (topvalue + ('[[\'></label>\n                <label class=\']]' + (value_label_style + ('[[\' name=\']]' + (downname + ('[[\' value=\']]' + (downvalue + ('[[\' onclick=\']]' + (func + '[[\'></label>\n            </div>\n        ]]')))))))))));
        if (downname === 'xcsq_shared' && globalTable['createUserCode'] === globalTable['workid_xcsq']) {
            setcontent = '[[\n                <div class=\'bill_basedetail_item_div\' border=\'0\' onclick=\']]' + (func + ('[[\'>\n                    <label class=\'bill_basedetail_key_label\' value=\']]' + (topvalue + ('[[\'></label>\n                    <label class=\']]' + (value_label_style + ('[[\' name=\']]' + (downname + ('[[\' value=\']]' + (downvalue + ('[[\' onclick=\']]' + (func + '[[\'></label>\n                    <label class=\'bill_basedetail_value_label2\' border=\'0\' onclick=\'cancelShared()\' name=\'cancel\'>取消</label>\n                </div>\n            ]]')))))))))));
        } else if (downname === 'xcsq_shared' && globalTable['createUserCode'] != globalTable['workid_xcsq']) {
            setcontent = '[[\n                <div class=\'bill_basedetail_item_div\' border=\'0\' onclick=\']]' + (func + ('[[\'>\n                    <label class=\'bill_basedetail_key_label\' value=\']]' + (topvalue + ('[[\'></label>\n                    <label class=\']]' + (value_label_style + ('[[\' name=\']]' + (downname + ('[[\' value=\']]' + (downvalue + ('[[\' onclick=\']]' + (func + '[[\'></label>\n                </div>\n            ]]')))))))))));
        }
        var rem = i % 2;
        var mod = i / 2;
        if (rem === 1) {
            itemhtmls = itemhtmls + ('[[\n                <div class="bill_basedetail_div" border="0">\n                    <div class="bill_basedetail_left_div" border="0">\n                        ]]' + (setcontent + '[[\n                    </div>\n            ]]'));
            if (i === detailItem.length) {
                itemhtmls = itemhtmls + '[[\n                    </div>\n                ]]';
            }
        } else if (rem === 0) {
            itemhtmls = itemhtmls + ('[[\n                    <img src="local:line_v.png" class="line_v_icon"/>\n                    <div class="bill_basedetail_right_div" border="0">\n                        ]]' + (setcontent + '[[\n                    </div>\n                </div>\n                <div class="space_05_div" border="0"/>\n            ]]'));
        }
    }
    var htmls = '[[\n        <div class="bill_baseinfo_div" border="0" name="]]' + (baseinfodivname + ('[[">\n            <div class="bill_baseline_div" border="0"/>\n            ]]' + itemhtmls));
    var PcEnclosureTotalCounts = parseFloat(globalTable['PcEnclosureTotalCounts']);
    globalTable['PcEnclosureTotalCounts'] = '';
    if (parseFloat(formatNull(PcEnclosureTotalCounts, '0')) > 0) {
        htmls = htmls + '[[\n            <img src="local:seeAnnex.png" class="fujian_button" name="seeAnnex" onclick="seeAnnex()" />\n        ]]';
    } else {
        htmls = htmls + '[[\n            <img src="local:seeAnnex.png" class="fujian_button,displayNone" name="seeAnnex" onclick="seeAnnex()" />\n        ]]';
    }
    htmls = htmls + '[[\n            <div class="space_30_div" border="0"/>\n        </div>\n    ]]';
    document.getElementsByName(baseinfodivname)[1].setInnerHTML(htmls);
};
credit_bill_base_info_by_config = function (itemContentEleName, billConfigData, billTypeCode, billInfoData) {
    var itemContentEleName = formatNull(itemContentEleName);
    var billConfigData = formatNull(billConfigData);
    var billTypeCode = formatNull(billTypeCode);
    var billInfoData = formatNull(billInfoData);
    if (itemContentEleName != '' && billConfigData != '') {
        var detailItem = {};
        var fieldAppId = '';
        var billInfoDataValue = '';
        var fieldVisible = '';
        var fieldDispName = '';
        var modelType = '';
        var debug_alert_msg = '详情页面配置:\\n';
        var insertBillInfo = 'false';
        for (let i = 1; billConfigData.length; i++) {
            fieldAppId = formatNull(billConfigData[i]['fieldAppId']);
            fieldVisible = formatNull(billConfigData[i]['fieldVisible'], '0');
            fieldDispName = formatNull(billConfigData[i]['fieldDispName']);
            modelType = formatNull(billConfigData[i]['modelType']);
            insertBillInfo = insert_bill_info(fieldAppId, fieldVisible, modelType, billTypeCode);
            if (insertBillInfo === 'true') {
                var billInfoDataType = '';
                var billInfoDataKey = '';
                var itemStyle = '';
                var useFunc = '';
                if (billTypeCode != '') {
                    AppConfigIdInfo = formatNull(bill_config['level1'][billTypeCode][fieldAppId]);
                    AppConfigIdInfoSplitResult = splitUtils(AppConfigIdInfo, ',');
                    billInfoDataType = formatNull(AppConfigIdInfoSplitResult[1]);
                    billInfoDataKey = formatNull(AppConfigIdInfoSplitResult[2]);
                    itemStyle = formatNull(AppConfigIdInfoSplitResult[3]);
                    useFunc = formatNull(AppConfigIdInfoSplitResult[4]);
                    if (billInfoData.length < 1) {
                        billInfoDataValue = formatNull(billInfoData[billInfoDataKey]);
                    } else {
                        for (let i = 1; billInfoData.length; i++) {
                            billInfoDataValue = formatNull(billInfoData[i][billInfoDataKey]);
                            if (billInfoDataValue != '') {
                                break;
                            }
                        }
                    }
                    if (billInfoDataType === 'date') {
                        billInfoDataValue = timestamp_to_date(billInfoDataValue, 'date');
                    } else if (billInfoDataType === 'bool') {
                        if (parseFloat(billInfoDataValue) === 1) {
                            billInfoDataValue = '是';
                        } else {
                            billInfoDataValue = '否';
                        }
                    } else if (billInfoDataType === 'cartype') {
                        billInfoDataValue = jjbx_yccx(billInfoDataValue);
                    } else if (billInfoDataType === 'yclx') {
                        if (parseFloat(billInfoDataValue) === 0) {
                            billInfoDataValue = '外卖';
                        } else if (parseFloat(billInfoDataValue) === 1) {
                            billInfoDataValue = '到店';
                        } else {
                            billInfoDataValue = '外卖\u3001到店';
                        }
                    } else if (billInfoDataType === 'rjcb') {
                        if (parseFloat(formatNull(billInfoDataValue, '0')) > 0) {
                            billInfoDataValue = billInfoDataValue + '/人';
                        } else {
                            billInfoDataValue = '*/人';
                        }
                    } else if (billInfoDataType === 'djzt') {
                        billInfoDataValue = bill_statecode2text(billInfoDataValue);
                    } else if (billInfoDataType === 'ycsj') {
                        if (formatNull(billInfoData['diditripdate']) != '' && formatNull(billInfoData['usecartime']) != '') {
                            billInfoDataValue = billInfoData['diditripdate'] + (' 至 ' + billInfoData['usecartime']);
                        } else {
                            billInfoDataValue = billInfoData['diditripdate'];
                        }
                    } else if (billInfoDataType === 'eatServiceTime') {
                        if (formatNull(billInfoData[2]['xcrqst']) != '' && formatNull(billInfoData[2]['xcrqed']) != '') {
                            billInfoDataValue = timestamp_to_date(billInfoData[2]['xcrqst'], 'date') + (' 至 ' + timestamp_to_date(billInfoData[2]['xcrqed'], 'date'));
                        } else {
                            billInfoDataValue = timestamp_to_date(billInfoData[2]['xcrqed'], 'date');
                        }
                    } else if (billInfoDataType === 'fjzsFlag') {
                        if (billInfoDataValue && parseFloat(billInfoDataValue) === 1) {
                            billInfoDataValue = '有';
                        } else if (billInfoDataValue && parseFloat(billInfoDataValue) === 0) {
                            billInfoDataValue = '无';
                        } else {
                            billInfoDataValue = '';
                        }
                    } else {
                    }
                    if (billInfoDataKey === 'lsje') {
                        if (parseFloat(billInfoDataValue) === 0) {
                            useFunc = '';
                        } else {
                            billInfoDataValue = C_ShowAmountMsg;
                        }
                    }
                }
                table.insert(detailItem, {
                    style: itemStyle,
                    topname: '',
                    topvalue: fieldDispName,
                    downname: fieldAppId,
                    downvalue: billInfoDataValue,
                    func: useFunc
                });
                debug_alert_msg = debug_alert_msg + ('配置接口返回ID:' + (fieldAppId + ('\\n' + ('取值Key:' + (billInfoDataKey + ('\\n' + ('取值Value:' + (billInfoDataValue + ('\\n' + ('值类型:' + (billInfoDataType + ('\\n' + ('显示名称:' + (fieldDispName + ('\\n' + ('显示样式:' + (itemStyle + ('\\n' + ('事件函数:' + (useFunc + ('\\n' + '\\n')))))))))))))))))))));
            }
        }
        create_bill_detal_baseinfo(detailItem, itemContentEleName);
    } else {
        alert('单据基本信息查询失败');
    }
};
insert_bill_info = function (fieldAppId, fieldVisible, modelType, billTypeCode) {
    var insert = 'false';
    if (billTypeCode === 'eatServer') {
        if (modelType === '1' || modelType === '2' || modelType === '3') {
            if (fieldAppId === 'sykycs_div' || fieldAppId === 'sykyje_div') {
                insert = 'false';
            } else {
                if (fieldVisible === '1') {
                    insert = 'true';
                } else {
                    insert = 'false';
                }
            }
        } else {
            insert = 'false';
        }
    } else if (billTypeCode === 'cgsq_new') {
        if (fieldAppId === 'zdy' || fieldAppId === 'xmda') {
            insert = 'false';
        } else {
            if (modelType === '1' && fieldVisible === '1') {
                insert = 'true';
            } else {
                insert = 'false';
            }
        }
    } else {
        if (modelType === '1' && fieldVisible === '1') {
            insert = 'true';
        } else {
            insert = 'false';
        }
    }
    return insert;
};
calculate_text_width = function (textStr, textFontSize) {
    var textStr = formatNull(textStr);
    var textFontSize = formatNull(textFontSize);
    if (textStr != '' && textFontSize != '') {
        var text_width = RYTL.getWidthByStr(textStr, textFontSize);
        text_width = formatNull(text_width);
        return tostring(text_width);
    } else {
        return '0';
    }
};
page_sys_init = function () {
    lua_system.timer_unregister();
    globalTable['iPhoneXBottomStyle'] = 'show';
};
click_head_option = function (optionIndex, optionEleName, callFunName, callFunArg) {
    var optionIndex = formatNull(optionIndex);
    var optionEleName = formatNull(optionEleName);
    var callFunName = formatNull(callFunName);
    var callFunArg = formatNull(callFunArg);
    var optionElements = document.getElementsByName(optionEleName);
    var optionElementsCounts = optionElements.length;
    for (let i = 1; optionElementsCounts; i++) {
        if (i === parseFloat(optionIndex)) {
            optionElements[i].setStyleByName('display', 'block');
        } else {
            optionElements[i].setStyleByName('display', 'none');
        }
    }
    lua_system.do_function(callFunName, callFunArg);
};
batch_height_adapt = function (containerlists, adaptSetUp) {
    var containerlists = formatNull(containerlists);
    var adaptSetUp = formatNull(adaptSetUp, 'common');
    if (containerlists === '') {
        debug_alert('参数为空');
    } else {
        var array = splitUtils(containerlists, ',');
        if (array.length < 1) {
            debug_alert('控件集合为空');
        } else {
            for (let i = 1; array.length; i++) {
                var containername = formatNull(array[i]);
                if (containername != '') {
                    if (adaptSetUp === 'screen') {
                        height_adapt(containername, 0, 0);
                    } else if (adaptSetUp === 'common') {
                        height_adapt(containername);
                    } else {
                        if (type(adaptSetUp) === 'number') {
                            height_adapt(containername, adaptSetUp);
                        }
                    }
                }
            }
        }
    }
};
lua_page.create_network_widget = function (elename) {
    globalTable['bank_code'] = '';
    globalTable['bank_name'] = '';
    globalTable['network_code'] = '';
    globalTable['network_name'] = '';
    var elename = formatNull(elename, 'bank_network_widget_div');
    var html = '[[\n        <div name="]]' + (elename + ('[[" class="bank_network_widget_div" border="0">\n            <div class="bank_bg_div" border="0" name="bank_bg_div">\n                <bankSelectBasicInfoManage name="bank_widget" class="bank_widget" function="select_bank" hidefun="hide_banknetwork_widget" value="" />\n            </div>\n\n            <div class="network_bg_div" border="0" name="network_bg_div" onclick="">\n                <div class="top_div_]]' + (systemTable['SysLayoutStyle'] + ('[[" border="0" name="top_search_network_and_check_div" />\n\n                <div name="radius_bg_div" class="radius_bg_div" border="0" />\n\n                <div name="network_widget_div" class="network_widget_div" border="1">\n                    <bankBranch name="network_widget" class="network_widget" width="375" height="321" function="select_network" hidefun="hide_banknetwork_widget" value="" />\n                </div>\n            </div>\n\n            <div class="search_network_bg_div" border="0" name="search_network_bg_div" onclick="">\n                <div class="top_div_]]' + (systemTable['SysLayoutStyle'] + '[[" border="0" name="top_search_network_div" />\n            </div>\n        </div>\n    ]]')))));
    document.getElementsByName(elename)[1].setInnerHTML(html);
    batch_height_adapt('containerlists,bank_network_widget_div,bank_bg_div,bank_widget,network_bg_div,search_network_bg_div,network_widget', 'screen');
    create_page_title('hide_banknetwork_widget()', 'search_bar', '网点名称精确', 'search_network_onChange(1)', 'label_bar', '确定', 'search_network(1)', 'top_search_network_and_check_div');
    create_page_title('hide_banknetwork_widget()', 'search_bar', '网点名称精确', 'search_network_onChange(2)', 'label_bar', '确定', 'search_network(2)', 'top_search_network_div');
    page_reload();
};
lua_page.render_bill_top_right_menu = function (add_menu_list) {
    var add_menu_list = formatNull(add_menu_list, {});
    var menu_list = {};
    var bill_print_menu = {
        menu_name: '单据下载',
        menu_click: 'lua_page.top_right_menu_router(\'get_bill_cover_pdf\')',
        menu_icon: 'menu_bar_pdf.png'
    };
    if (lua_form.nil_table(add_menu_list) === 'false') {
        for (var [i, add_menu] in pairs(add_menu_list)) {
            table.insert(menu_list, add_menu);
        }
    } else {
    }
    var PCConfigListsTable = vt('PCConfigListsTable', globalTable);
    var djzt = globalTable['djzt_download'];
    if (vt('BILL0019', PCConfigListsTable) != '' && vt('BILL0019', PCConfigListsTable) === '审批结束') {
        if (djzt === '3' || djzt === '4' || djzt === '5' || djzt === '6' || djzt === '7' || djzt === '98') {
            table.insert(menu_list, bill_print_menu);
        }
    } else {
        table.insert(menu_list, bill_print_menu);
    }
    if (menu_list.length > 0) {
        globalTable['rightMenuFlag'] = 'true';
    } else {
        globalTable['rightMenuFlag'] = 'false';
    }
    var renderArg = { menu_list: menu_list };
    lua_page.render_top_right_menu(renderArg);
};
lua_page.render_top_right_menu = function (arg) {
    var arg = formatNull(arg);
    var menu_bg_name = formatNull(arg['menu_bg_name'], 'top_menu_bg_div');
    var menu_parent_name = formatNull(arg['menu_parent_name'], 'top_menu_page_content_div');
    var menu_child_name = formatNull(arg['menu_child_name'], 'top_menu_content_div');
    var menu_child_fun = formatNull(arg['menu_child_fun'], 'lua_page.top_right_menu_ctrl()');
    var menu_title = formatNull(arg['menu_title'], '选择操作');
    var menu_right_style = formatNull(arg['menu_right_style'], 'default');
    var menu_list = formatNull(arg['menu_list']);
    var menu_back_fun = formatNull(arg['menu_back_fun'], 'lua_page.top_right_menu_ctrl()');
    var menu_counts = menu_list.length;
    var menu_item_html = '';
    if (menu_list.length > 0) {
        for (var [key, value] in pairs(menu_list)) {
            var menu_name = formatNull(menu_list[key]['menu_name']);
            var menu_click = formatNull(menu_list[key]['menu_click']);
            var menu_icon = formatNull(menu_list[key]['menu_icon']);
            var menu_icon_name = formatNull(menu_list[key]['menu_icon_name']);
            var menu_icon_style = formatNull(menu_list[key]['menu_icon_style']);
            var menu_div_name = formatNull(menu_list[key]['menu_div_name']);
            var menu_label_name = formatNull(menu_list[key]['menu_label_name']);
            var menu_icon_html = '';
            var menu_label_class = '';
            if (menu_icon != '') {
                menu_icon_html = '[[<img src="local:]]' + (menu_icon + ('[[" class="top_menu_icon" name="]]' + (menu_icon_name + '[[" />]]')));
                menu_label_class = 'top_menu_icon_label';
            } else {
                if (menu_icon_style === 'sign') {
                    menu_icon_html = '[[<img src="local:right_menu_untouch.png" class="top_menu_status_icon" name="]]' + (menu_icon_name + '[[" />]]');
                    menu_label_class = 'top_menu_label';
                } else {
                    menu_icon_html = '';
                    menu_label_class = 'top_menu_label';
                }
            }
            menu_item_html = menu_item_html + ('[[\n                <div class="top_menu_item_div" border="1" name="]]' + (menu_div_name + ('[[" onclick="]]' + (menu_click + ('[[">\n                    ]]' + (menu_icon_html + ('[[\n                    <label class="]]' + (menu_label_class + ('[[" name="]]' + (menu_label_name + ('[[">]]' + (menu_name + '[[</label>\n                </div>\n            ]]'))))))))))));
            if (key != menu_counts) {
                menu_item_html = menu_item_html + '[[<line class="line_css" />]]';
            }
        }
        menu_item_html = '[[\n            <div class="top_menu_item_list_div" border="1">]]' + (menu_item_html + '[[\n            </div>\n        ]]');
        var top_menu_bg_div = document.getElementsByName(menu_bg_name)[1];
        var html = '[[\n            <div class="top_menu_bg_div" name="]]' + (menu_bg_name + ('[[" border="0" onclick="]]' + (menu_child_fun + ('[[">\n                <div class="top_div_]]' + (systemTable['SysLayoutStyle'] + ('[[" border="0" name="menu_top_div" />\n\n                <div class="top_menu_page_content_div" name="]]' + (menu_parent_name + ('[[" border="0" onclick="]]' + (menu_child_fun + ('[[">\n                    <div class="top_menu_content_div" name="]]' + (menu_child_name + ('[[" border="0" onclick="]]' + (menu_child_fun + ('[[">\n                        <div class="top_menu_div" name="top_menu_div" border="0" onclick="">\n                            <div class="top_menu_padding_top_div" border="0">\n                                <img src="local:menu_bg_bubble.png" class="top_menu_bubble_icon" />\n                            </div>]]' + (menu_item_html + '[[\n                        </div>\n                    </div>\n                </div>\n            </div>\n        ]]')))))))))))))));
        top_menu_bg_div.setInnerHTML(html);
        if (menu_right_style === 'default') {
            create_page_title(menu_back_fun, 'title_bar', menu_title, '', 'menu_bar', '', menu_back_fun, 'menu_top_div');
        } else if (menu_right_style === 'none') {
            create_page_title(menu_back_fun, 'title_bar', menu_title, '', '', '', '', 'menu_top_div');
        }
        height_adapt(menu_parent_name);
        height_adapt(menu_bg_name, 0, 0);
    }
    page_reload();
};
lua_page.top_right_menu_ctrl = function (arg) {
    var arg = formatNull(arg);
    var menu_bg_name = formatNull(arg['menu_bg_name'], 'top_menu_bg_div');
    var menu_child_name = formatNull(arg['menu_child_name'], 'top_menu_content_div');
    var menu_ctrl_call = formatNull(arg['menu_ctrl_call']);
    var menu_ctrl_call_arg = formatNull(arg['menu_ctrl_call_arg']);
    var DisplayFlag = getStyle(menu_bg_name, 'display');
    var animation_fun = '';
    if (DisplayFlag === 'block') {
        set_android_Physical_back();
        animation_fun = 'lua_animation.hide_screen_page';
        changeAllProperty('head_menu_img', 'src', 'local:menu_bar_white.png');
    } else {
        set_android_Physical_back('lua_page.top_right_menu_ctrl()');
        animation_fun = 'lua_animation.show_screen_page';
        changeAllProperty('head_menu_img', 'src', 'local:menu_bar_black.png');
    }
    lua_format.str2fun(animation_fun)(menu_bg_name, menu_child_name, 'right', menu_ctrl_call, menu_ctrl_call_arg);
};
lua_page.top_right_menu_router = function (ctrl, type) {
    var ctrl = formatNull(ctrl);
    var type = formatNull(type, 'release');
    var menu_ctrl_call = '';
    var menu_ctrl_call_arg = '';
    if (ctrl != '') {
        if (type === 'release') {
            menu_ctrl_call = 'lua_menu.top_right_menu_action';
        } else {
            if (systemTable['EnvAllowDebug'] === 'true') {
                menu_ctrl_call = 'top_right_menu_debug_action';
            }
        }
        menu_ctrl_call_arg = ctrl;
    }
    var menu_ctrl_arg = {
        menu_ctrl_call: menu_ctrl_call,
        menu_ctrl_call_arg: menu_ctrl_call_arg
    };
    lua_page.top_right_menu_ctrl(menu_ctrl_arg);
};
lua_page.render_alert_menu = function (arg) {
    var menu_info = formatNull(arg['menu_list']);
    var menu_item_html = '';
    for (var [key, value] in pairs(menu_info)) {
        var menu_name = menu_info[key]['menu_name'];
        var menu_click = menu_info[key]['menu_click'];
        menu_item_html = menu_item_html + ('[[\n            <div class="alert_menu_item_div" border="1" onclick="]]' + (menu_click + ('[[">\n                <label class="alert_menu_label">]]' + (menu_name + '[[</label>\n            </div>\n        ]]'))));
        if (key != menu_info.length) {
            menu_item_html = menu_item_html + '[[<line class="line_css" />]]';
        }
    }
    var html = '[[\n        <div class="alert_menu_bg_div" name="alert_menu_bg_div" border="0" onclick="lua_page.alert_menu_bg_ctrl(\'alert_menu_bg_div\')">\n            <div class="alert_menu_div" name="alert_menu_div" border="1" onclick="">\n                <div class="alert_menu_item_list_div" name="alert_menu_item_list_div" border="1">]]' + (menu_item_html + '[[\n                </div>\n            </div>\n        </div>\n    ]]');
    var alert_menu_bg_div = document.getElementsByName('alert_menu_bg_div')[1];
    alert_menu_bg_div.setInnerHTML(html);
    height_adapt('alert_menu_bg_div', 0, 0);
    lua_page.widget_center_adapt('alert_menu_div', 'x/y');
};
lua_page.alert_menu_bg_ctrl = function (bgwidgetName) {
    var bgwidgetName = formatNull(bgwidgetName);
    if (bgwidgetName != '') {
        var DisplayFlag = getStyle(bgwidgetName, 'display');
        if (DisplayFlag === 'block') {
            set_android_top_bar_image('topBar_Bg.png');
            hide_ele(bgwidgetName);
        } else {
            set_android_top_bar_color('#4C4B59');
            show_ele(bgwidgetName);
        }
    } else {
        debug_alert('未找到遮罩背景');
    }
};
lua_page.widget_center_adapt = function (widgetName, direction, parentWidgetName) {
    var widgetName = formatNull(widgetName);
    var widgetHeight = parseFloat(getEleLocation(widgetName, 'height'));
    var widgetWidth = parseFloat(getEleLocation(widgetName, 'width'));
    var direction = formatNull(direction);
    var parentWidgetName = formatNull(parentWidgetName);
    var parentWidgetHeight = parseFloat(formatNull(getEleLocation(parentWidgetName, 'height'), 0));
    var parentWidgetWidth = parseFloat(formatNull(getEleLocation(parentWidgetName, 'width'), 0));
    var screenSurHeight = '';
    var screenSurWidth = '';
    var centerAdaptStyle = '';
    if (parentWidgetName != '') {
        centerAdaptStyle = '基于父控件';
        screenSurHeight = parseFloat(parentWidgetHeight - widgetHeight);
        screenSurWidth = parseFloat(parentWidgetWidth - widgetWidth);
    } else {
        centerAdaptStyle = '基于屏幕';
        screenSurHeight = height_adapt(widgetName, 0, 0, 'calculate') - widgetHeight;
        screenSurWidth = C_screenBaseWidth - widgetWidth;
    }
    var top = float(screenSurHeight / 2, 0);
    var left = float(screenSurWidth / 2, 0);
    if (direction === 'y' && top != '') {
        setEleLocation(widgetName, 'top', top);
    } else if (direction === 'x' && left != '') {
        setEleLocation(widgetName, 'left', left);
    } else if (direction === 'x/y' && top != '' && left != '') {
        setEleLocation(widgetName, 'top', top);
        setEleLocation(widgetName, 'left', left);
    } else {
        debug_alert('不支持的方向');
        return;
    }
};
lua_page.div_page_ctrl = function (pageDivEleName, pageDivNeedAdapt, bodyNeedAdapt) {
    var pageDivEleName = formatNull(pageDivEleName);
    var ShowPageDivEleName = formatNull(globalTable['ShowPageDivEleName']);
    var pageDivNeedAdapt = formatNull(pageDivNeedAdapt, 'false');
    var bodyNeedAdapt = formatNull(bodyNeedAdapt, 'false');
    if (ShowPageDivEleName != '') {
        lua_system.hide_keyboard();
        hide_ele(ShowPageDivEleName);
        globalTable['ShowPageDivEleName'] = '';
        var ADPhysicalBackFunBeforeDivPageShow = formatNull(globalTable['ADPhysicalBackFunBeforeDivPageShow']);
        var ADPhysicalBackArgBeforeDivPageShow = formatNull(globalTable['ADPhysicalBackArgBeforeDivPageShow']);
        set_android_Physical_back(ADPhysicalBackFunBeforeDivPageShow, ADPhysicalBackArgBeforeDivPageShow);
        if (bodyNeedAdapt === 'true') {
            height_adapt('body', 0, 0);
        }
    } else {
        if (pageDivEleName != '') {
            if (pageDivNeedAdapt === 'true') {
                height_adapt(pageDivEleName, 0, 0);
            }
            show_ele(pageDivEleName);
            globalTable['ShowPageDivEleName'] = pageDivEleName;
            var ADPhysicalBackFunBeforeDivPageShow = formatNull(globalTable['ADPhysicalBackFun']);
            var ADPhysicalBackArgBeforeDivPageShow = formatNull(globalTable['ADPhysicalBackArg']);
            globalTable['ADPhysicalBackFunBeforeDivPageShow'] = ADPhysicalBackFunBeforeDivPageShow;
            globalTable['ADPhysicalBackArgBeforeDivPageShow'] = ADPhysicalBackArgBeforeDivPageShow;
            set_android_Physical_back('lua_page.div_page_ctrl');
        } else {
            var ADPhysicalBackFunBeforeDivPageShow = formatNull(globalTable['ADPhysicalBackFunBeforeDivPageShow']);
            var ADPhysicalBackArgBeforeDivPageShow = formatNull(globalTable['ADPhysicalBackArgBeforeDivPageShow']);
            set_android_Physical_back(ADPhysicalBackFunBeforeDivPageShow, ADPhysicalBackArgBeforeDivPageShow);
        }
    }
};
lua_page.render_invoice_img_by_path = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var UploadInvoiceInfo = vt('UploadInvoiceInfo', globalTable);
        var path = vt('path', UploadInvoiceInfo);
        var absolutePath = vt('absolutePath', UploadInvoiceInfo);
        var FileAbsPath = '';
        if (absolutePath != '') {
            FileAbsPath = absolutePath;
        } else {
            FileAbsPath = path;
        }
        if (FileAbsPath != '') {
            invoke_trancode_noloading('jjbx_process_query', 'jjbx_fpc', {
                TranCode: 'GetRelatedInvImg',
                FileAbsPath: FileAbsPath,
                ofdFileKey: vt('fileKey', UploadInvoiceInfo),
                OFD2PDF: 'false',
                netFlag: '1'
            }, lua_page.render_invoice_img_by_path, {});
        } else {
            batch_hide_ele('invoice_preview_space_div,invoice_preview_div');
        }
    } else {
        var res = json2table(vt('responseBody', ResParams));
        var isInvoiceFile = vt('isInvoiceFile', res);
        var PCInvoiceFileType = vt('FileOriginalType', res);
        var PCInvoiceFileDlUrl = vt('PCInvoiceFileDlUrl', res);
        var FileOriginalType = vt('FileOriginalType', res);
        var doReplace = vt('DoReplace', res);
        if (PCInvoiceFileDlUrl != '') {
            var preview_div_html = '';
            var onclick_html = '';
            if (isInvoiceFile === 'true') {
                onclick_html = 'onclick=\\"lua_system.file_preview(\'' + (PCInvoiceFileDlUrl + ('\',\'' + (PCInvoiceFileType + '\')\\"')));
            } else {
                var UploadInvoiceInfo = vt('UploadInvoiceInfo', globalTable);
                var InvoiceType = vt('fplxbm', UploadInvoiceInfo);
                var FileOriginalPath = vt('filePath', UploadInvoiceInfo);
                var fileKey = vt('fileKey', UploadInvoiceInfo);
                var invoiceId = vt('invoiceId', UploadInvoiceInfo);
                onclick_html = 'onclick=\\"lua_upload.get_related_inv_img(\'' + (fileKey + ('\',\'' + (FileOriginalPath + '\')\\"')));
            }
            if (string.lower(FileOriginalType) === 'png' || string.lower(FileOriginalType) === 'jpg' || string.lower(FileOriginalType) === 'jpeg') {
                preview_div_html = '[[<imageView width="80" height="80" class="invoice_image" name="invoice_image" radius="6" ]]' + (onclick_html + ('[[ value="]]' + (PCInvoiceFileDlUrl + '[[" />]]')));
            } else {
                var AppUploadOriginalFileName = formatNull(globalTable['UploadInvoiceInfo']['AppUploadOriginalFileName']);
                var PCInvoiceFileName = formatNull(jjbx_utils_setStringLength(AppUploadOriginalFileName, 12));
                var fileIconName = '';
                var fileTip = PCInvoiceFileName;
                if (FileOriginalType === 'ofd') {
                    fileIconName = 'file_ofd_icon.png';
                } else if (FileOriginalType === 'pdf') {
                    if (doReplace === 'true') {
                        fileIconName = 'file_ofd_icon.png';
                    } else {
                        fileIconName = 'file_pdf_icon.png';
                    }
                    fileIconName = 'file_pdf_icon.png';
                } else {
                    fileIconName = 'file_other_icon.png';
                }
                preview_div_html = '[[\n                    <div class="file_icon_div" border="0" ]]' + (onclick_html + ('[[>\n                        <img src="local:]]' + (fileIconName + ('[[" class="file_icon" ]]' + (onclick_html + ('[[/>\n                    </div>\n                    <div class="file_tip_div" border="0" ]]' + (onclick_html + ('[[>\n                        <label class="file_tip_label" value="]]' + (fileTip + ('[[" ]]' + (onclick_html + '[[ />\n                    </div>\n                ]]')))))))))));
            }
            preview_div_html = '[[\n                <div class="invoice_preview_div" border="1" name="invoice_preview_div" ]]' + (onclick_html + ('[[>\n                    ]]' + (preview_div_html + '[[\n                </div>\n            ]]')));
            document.getElementsByName('invoice_preview_div')[1].setInnerHTML(preview_div_html);
            batch_show_ele('invoice_preview_space_div,invoice_preview_div');
        } else {
            batch_hide_ele('invoice_preview_space_div,invoice_preview_div');
        }
        page_reload();
    }
};
SetGestureDisplayWidgetArg = {
    setKey: '',
    outCycleNormal: '#CCCCCC',
    holloColor: '#979797',
    solidColor: '#979797',
    display: 'true',
    innerCycleTouched: '#979797',
    width: '29',
    height: '29'
};
SetGestureTipWidgetArg = {
    textColor: '',
    textSize: '15',
    textContent: '',
    isShake: '',
    height: '21',
    width: '375'
};
SetGestureWidgetArg = {
    setKey: '',
    func: 'gesture_set_widget_call',
    outCycleNormal: '',
    outCycleOntouch: '',
    innerCycleTouched: '',
    innerCycleNoTouch: '',
    lineColor: '',
    errorlineColor: '',
    innerCycleErrorColor: '',
    innerCycleOnTouchBgColor: ''
};
lua_page.init_gesture_set_widgets = function () {
    height_adapt('gesture_set_body_div');
    SetGestureDisplayWidgetArg.setKey = '';
    SetGestureDisplayWidgetArg.holloColor = '#979797';
    SetGestureDisplayWidgetArg.solidColor = '#979797';
    var lockDisplayJson = table2json(SetGestureDisplayWidgetArg);
    SetGestureTipWidgetArg.textColor = '#A5A5A5';
    SetGestureTipWidgetArg.isShake = 'false';
    var tipContentJson = table2json(SetGestureTipWidgetArg);
    SetGestureWidgetArg.outCycleNormal = '#FE6F14';
    SetGestureWidgetArg.outCycleOntouch = '#FE6F14';
    SetGestureWidgetArg.innerCycleTouched = '#FE6F14';
    SetGestureWidgetArg.innerCycleNoTouch = '#FFFFFF';
    SetGestureWidgetArg.lineColor = '#FE6F14';
    SetGestureWidgetArg.errorlineColor = '#E70012';
    SetGestureWidgetArg.innerCycleErrorColor = '#E70012';
    SetGestureWidgetArg.innerCycleOnTouchBgColor = '#FFFFFFF';
    var gestureLockJson = table2json(SetGestureWidgetArg);
    var gesture_set_body_div_html = '[[\n        <div class="gesture_set_body_div" name="gesture_set_body_div" border="0">\n            <div class="space_80_div" border="0" />\n\n            <!-- 手势密码缩略图 -->\n            <div class="gesture_set_display_div" name="gesture_set_display_div" border="0">\n                <gestureLockDisplay border="0" name="gestureLockDisplay_widget" class="gesture_set_display_widget_]]' + (systemTable['SysLayoutStyle'] + ('[[" width="39" value=\']]' + (lockDisplayJson + ('[[\'/>\n            </div>\n\n            <!-- 手势密码提示文字 -->\n            <div class="gesture_set_text_shake_div" name="gesture_set_text_shake_div" border="0">\n                <textShake border="0" name="gesture_set_text_shake_widget" class="gesture_set_text_shake_widget" value=\']]' + (tipContentJson + ('[[\'/>\n            </div>\n\n            <div class="space_40_div" border="0" />\n\n            <!-- 手势密码操作区域 -->\n            <div class="gesture_set_div" name="gesture_set_div" border="0">\n                <gestureLock border="0" name="gesture_set_widget" class="gesture_set_widget" width="271" value=\']]' + (gestureLockJson + '[[\'/>\n            </div>\n        </div>\n    ]]')))))));
    document.getElementsByName('gesture_set_body_div')[1].setInnerHTML(gesture_set_body_div_html);
    page_reload();
};
lua_page.render_select_page = function (renderSelectArg) {
    var bgName = vt('bgName', renderSelectArg);
    var topEleName = vt('topEleName', renderSelectArg);
    var topTitleName = vt('topTitleName', renderSelectArg);
    var selectEleName = vt('selectEleName', renderSelectArg);
    var selectEleArg = vt('selectEleArg', renderSelectArg);
    var selectEleCounts = selectEleArg.length;
    var renderCallBackFun = vt('renderCallBackFun', renderSelectArg);
    var renderCallBackFunArg = { selectItemCounts: selectEleCounts };
    var selectType = vt('selectType', renderSelectArg);
    var finishCall = vt('finishCall', renderSelectArg, 'lua_page.div_page_ctrl()');
    var finishBtnStyle = vt('finishBtnStyle', renderSelectArg, 'TopRightBtn');
    var CreateTopArg = {
        bar_center_text: topTitleName,
        bar_top_name: topEleName
    };
    var backCall = vt('backCall', renderSelectArg, 'lua_page.div_page_ctrl()');
    var selectedIcon = '';
    var selectDivClass = '';
    if (selectType === 'multiple') {
        selectedIcon = 'sl_ico_checkBox.png';
        selectDivClass = 'common_select_item_select_icon_sdiv';
        CreateTopArg['bar_back_fun'] = backCall;
        if (finishBtnStyle === 'TopRightBtn') {
            CreateTopArg['bar_right_type'] = 'label_bar';
            CreateTopArg['bar_right_text'] = '完成';
            CreateTopArg['bar_right_fun'] = finishCall;
        }
    } else {
        selectedIcon = 'start_pCircle_icon.png';
        selectDivClass = 'common_select_item_select_icon_hdiv';
        CreateTopArg['bar_back_fun'] = backCall;
    }
    lua_page.create_top(CreateTopArg);
    height_adapt(bgName, 0, 0);
    if (selectType === 'multiple' && finishBtnStyle === 'BottomFullBtn') {
        height_adapt(selectEleName, 45 + 50);
    } else {
        height_adapt(selectEleName);
    }
    var divBorder = '0';
    var selectItemHtml = '';
    for (let i = 1; selectEleCounts; i++) {
        var selectEleArgItem = selectEleArg[i];
        var labelName = vt('labelName', selectEleArgItem);
        var tipName = vt('tipName', selectEleArgItem);
        var clickFunc = vt('clickFunc', selectEleArgItem);
        var clickFuncArg = vt('clickFuncArg', selectEleArgItem);
        var onclickFun = clickFunc + ('(\'' + (clickFuncArg + '\')'));
        if (i === 1) {
            renderCallBackFunArg['selectFirstFuncName'] = clickFunc;
            renderCallBackFunArg['selectFirstFuncArg'] = clickFuncArg;
        }
        var labelNameClass = '';
        var tipNameClass = '';
        if (tipName != '') {
            labelNameClass = 'common_select_item_name_label';
            tipNameClass = 'common_select_item_tip_label';
        } else {
            labelNameClass = 'common_select_item_label';
        }
        var renderItemFunc = vt('renderItemFunc', selectEleArgItem);
        var selectItemIconDiv = vt('selectItemIconDiv', renderSelectArg, 'common_select_item_select_icon_div');
        var selectItemIcon = vt('selectItemIcon', renderSelectArg, 'common_select_item_select_icon');
        var renderItemHtml = '';
        if (renderItemFunc === '') {
            renderItemHtml = '[[\n                <div class="common_select_item_div" border="]]' + (divBorder + ('[[" onclick="]]' + (onclickFun + ('[[">\n                    <div class="common_select_item_label_div" border="]]' + (divBorder + ('[[" onclick="]]' + (onclickFun + ('[[">\n                        <label class="]]' + (labelNameClass + ('[[" onclick="]]' + (onclickFun + ('[[">]]' + (labelName + ('[[</label>\n                        <label class="]]' + (tipNameClass + ('[[" onclick="]]' + (onclickFun + ('[[">]]' + (tipName + ('[[</label>\n                    </div>\n                    <div class="]]' + (selectDivClass + ('[[" name="]]' + (selectItemIconDiv + ('[[" border="]]' + (divBorder + ('[[" onclick="]]' + (onclickFun + ('[[">\n                        <img src="local:]]' + (selectedIcon + ('[[" class="common_select_item_select_icon" name="]]' + (selectItemIcon + ('[[" onclick="]]' + (onclickFun + '[["/>\n                    </div>\n                </div>\n                <line class="line_css" />\n            ]]')))))))))))))))))))))))))))))))));
        } else {
            renderItemHtml = lua_system.do_function(renderItemFunc, selectEleArgItem);
        }
        selectItemHtml = selectItemHtml + renderItemHtml;
    }
    var selectListHtml = '[[\n        <div class="common_select_list_div" border="]]' + (divBorder + ('[[" name="]]' + (selectEleName + ('[[">\n            ]]' + (selectItemHtml + '[[\n        </div>\n    ]]')))));
    document.getElementsByName(selectEleName)[1].setInnerHTML(selectListHtml);
    page_reload();
    lua_system.do_function(renderCallBackFun, renderCallBackFunArg);
};
lua_page.set_item_selected = function (setArg) {
    var selected = 'false';
    var showIndex = vt('showIndex', setArg);
    var selectDivEleName = vt('eleName', setArg, 'common_select_item_select_icon_div');
    var selectIconEleName = vt('iconEleName', setArg, 'common_select_item_select_icon');
    var selectTyle = vt('selectTyle', setArg, 'single');
    var divCtrlEles = document.getElementsByName(selectDivEleName);
    var iconCtrlEles = document.getElementsByName(selectIconEleName);
    if (selectTyle === 'single') {
        for (let i = 1; divCtrlEles.length; i++) {
            divCtrlEles[i].setStyleByName('display', 'none');
        }
    }
    for (let i = 1; divCtrlEles.length; i++) {
        if (i === parseFloat(showIndex)) {
            if (selectTyle === 'single') {
                selected = 'true';
                divCtrlEles[i].setStyleByName('display', 'block');
            } else {
                var nowIcon = iconCtrlEles[i].getPropertyByName('src');
                if (nowIcon === 'sl_ico_checkBoxOrange.png') {
                    selected = 'false';
                    iconCtrlEles[i].setPropertyByName('src', 'sl_ico_checkBox.png');
                } else {
                    selected = 'true';
                    iconCtrlEles[i].setPropertyByName('src', 'sl_ico_checkBoxOrange.png');
                }
            }
        }
    }
    return selected;
};
lua_page.create_search_people_page = function (Arg) {
    var ShowUser = vt('ShowUser', Arg, 'false');
    var UserNameKey = vt('UserNameKey', Arg, '申请人');
    var UserNameValue = vt('UserNameValue', Arg, '*** ***');
    var DefaultShowCdrWrokId = vt('DefaultShowCdrWrokId', Arg);
    var DefaultShowCdrInfo = vt('DefaultShowCdrInfo', Arg);
    var Border = '0';
    var ShowUserHtml = '';
    if (ShowUser === 'true') {
        ShowUserHtml = '[[\n            <div class="space_05_div" border="]]' + (Border + ('[["/>\n            <div class="search_people_content_div" border="]]' + (Border + ('[[">\n                <label class="search_people_klabel" name="search_people_klabel" value="]]' + (UserNameKey + ('[[" />\n                <label class="search_people_vlabel" name="search_people_vlabel" value="]]' + (UserNameValue + ('[[" />\n            </div>\n            <div class="space_05_div" border="]]' + (Border + ('[[" />\n\n            <div class="search_people_content_space_div" border="]]' + (Border + '[[" />\n        ]]')))))))))));
    }
    var DefaultShowCdrHtml = '';
    if (DefaultShowCdrWrokId != '' && DefaultShowCdrInfo != '') {
        DefaultShowCdrHtml = '[[\n            <div class="search_people_option_div" border="]]' + (Border + ('[[" onclick="lua_jjbx.select_cdr(\'cdr_by_self\')">\n                <label class="search_people_res_info1_label" name="workID">]]' + (DefaultShowCdrWrokId + ('[[</label>\n                <label class="search_people_res_info2_label" name="nameAndDept">]]' + (DefaultShowCdrInfo + ('[[</label>\n                <div class="space_05_div" border="]]' + (Border + '[[" />\n                <line class="search_people_line" />\n            </div>\n        ]]')))))));
    }
    var SearchPeoplePageHtml = '[[\n        <div class="search_people_page_div" border="]]' + (Border + ('[[" name="search_people_page_div" onclick="lua_page.div_page_ctrl()">\n            <div class="top_div_]]' + (systemTable['SysLayoutStyle'] + ('[[" border="]]' + (Border + ('[[" name="top_search_people_page_div" />\n\n            <div class="search_people_body_div" border="]]' + (Border + ('[[" onclick="">\n                ]]' + (ShowUserHtml + ('[[\n                <div class="space_05_div" border="]]' + (Border + ('[[" />\n                <div class="search_people_content_div" border="]]' + (Border + ('[[" >\n                    <label class="search_people_klabel">承担人</label>\n                    <input type="text" class="search_people_vtext" name="search_cdr_text" value="" hold="请搜索" holdColor="#9B9B9B" onchange="lua_jjbx.search_cdr(\'search_cdr_text\')" border="]]' + (Border + ('[[" />\n                    <img src="local:arrow_common.png" class="search_people_arrow_icon" />\n                </div>\n                <line class="search_people_line" />\n            </div>\n\n            <!-- 显示可选承担人 -->\n            <div class="search_people_list_div" border="]]' + (Border + ('[[" name="search_people_list_div" onclick="">\n                ]]' + (DefaultShowCdrHtml + '[[\n            </div>\n        </div>\n    ]]')))))))))))))))))));
    document.getElementsByName('search_people_page_div')[1].setInnerHTML(SearchPeoplePageHtml);
    page_reload();
    title_head(Arg['TitleName'], 'lua_page.div_page_ctrl()', 'top_search_people_page_div');
};
lua_page.set_filt_content = function (tagName, index) {
    var tagNameDiv = document.getElementsByName(tagName + 'Div');
    var selectOrange = document.getElementsByName('select_orange_' + tagName);
    for (let i = 1; tagNameDiv.length; i++) {
        if (i === parseFloat(index)) {
            tagNameDiv[i].setStyleByName('background-color', '#F5F5F5');
            selectOrange[i].setStyleByName('display', 'block');
        } else {
            tagNameDiv[i].setStyleByName('background-color', '#FFFFFF');
            selectOrange[i].setStyleByName('display', 'none');
        }
    }
};
lua_page.current_page_info = function (Arg) {
    return formatNull(pageinfoTable[parseFloat(history.length())]);
};
lua_page.set_current_page_arg = function (key, value) {
    var key = formatNull(key);
    var value = formatNull(value);
    if (key != '') {
        var HistoryLength = parseFloat(history.length());
        pageinfoTable[HistoryLength][key] = value;
    }
};
lua_page.reload_page = function () {
    var CurrentPageInfo = lua_page.current_page_info();
    CurrentPageInfo = formatNull(CurrentPageInfo, {});
    var PageFilePath = vt('page_file_path', CurrentPageInfo);
    CurrentPageInfo['CloseLoading'] = 'false';
    CurrentPageInfo['JumpStyle'] = 'none';
    CurrentPageInfo['AddPage'] = 'true';
    if (PageFilePath != '') {
        invoke_page_donot_checkRepeat(PageFilePath, page_callback, CurrentPageInfo);
    } else {
        debug_alert('请求页面为空');
    }
};
lua_page.info = function (QryPath) {
    var QryPath = formatNull(QryPath);
    var PageName = '';
    if (QryPath != '') {
        for (let i = 1; JJBX_PAGE_INFO.length; i++) {
            var PageInfo = formatNull(JJBX_PAGE_INFO[i]);
            var Name = vt('Name', PageInfo);
            var Path = vt('Path', PageInfo);
            if (Path === QryPath) {
                PageName = Name;
                break;
            }
        }
    }
    return {
        PageFilePath: QryPath,
        PageName: PageName
    };
};
lua_page.check_display = function (elementName) {
    var elementName = formatNull(elementName);
    var displayFlag = '';
    var ele = document.getElementsByName(elementName);
    var eleCounts = ele.length;
    if (eleCounts > 0) {
        displayFlag = ele[1].getStyleByName('display');
    } else {
        displayFlag = '';
    }
    return displayFlag;
};
lua_page.show_ele_text = function (elementName) {
    var elementName = formatNull(elementName);
    if (elementName != '') {
        alert(getValue(elementName));
    }
};
lua_page.calculate_widget_height = function (Arg) {
    var widgetNames = vt('widgetNames', Arg);
    var checkDisplay = vt('checkDisplay', Arg);
    var widgetNameList = splitUtils(widgetNames, ',');
    var SumPx = 0;
    for (let i = 1; widgetNameList.length; i++) {
        var widgetName = widgetNameList[i];
        if (widgetName != '') {
            var widgetHeight = parseFloat(getEleLocation(widgetName, 'height'));
            var displayFlag = lua_page.check_display(widgetName);
            if (checkDisplay === 'true') {
                if (displayFlag === 'block') {
                } else {
                    widgetHeight = 0;
                }
            } else {
            }
            SumPx = SumPx + widgetHeight;
        }
    }
    return SumPx;
};
lua_page.formatText_to_R_B = function (divName, str, styleCss) {
    var styleCss = formatNull(styleCss);
    str = string.gsub(str, 'RB{', '\' /><label class=\'label_red_bold_css\' ' + (styleCss + ' value=\''));
    str = string.gsub(str, 'BR{', '\' /><label class=\'label_red_bold_css\' ' + (styleCss + ' value=\''));
    str = string.gsub(str, 'R{', '\' /><label class=\'label_red_css\' ' + (styleCss + ' value=\''));
    str = string.gsub(str, 'B{', '\' /><label class=\'label_bold_css\' ' + (styleCss + ' value=\''));
    str = string.gsub(str, '}', '\' /><label class=\'label_css\' ' + (styleCss + ' value=\''));
    str = '<div class=\'contentDiv_css\' border=\'0\' name=\'' + (divName + ('\'><label class=\'label_css\' ' + (styleCss + (' value=\'' + (str + '\' /></div>')))));
    document.getElementsByName(divName)[1].setInnerHTML(str);
    page_reload();
};
module.exports = { lua_page: lua_page };