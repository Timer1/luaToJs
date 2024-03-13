const lua_format = require('./format');
const lua_system = require('./system');
const lua_page = require('./page');
const lua_jjbx = require('./jjbx');
lua_components = {};
lua_components.add_element = function (pageElement) {
    var pageElement = formatNull(pageElement, {});
    var tagName = vt('tagName', pageElement);
    var tagRequired = vt('tagRequired', pageElement);
    tagRequired = formatNull(tagRequired, 'true');
    if (tagRequired === 'true') {
        tagRequired = '*';
    } else {
        tagRequired = '';
    }
    var enable = vt('enable', pageElement, 'true');
    var tagTitle = vt('tagTitle', pageElement);
    var tagValue = vt('tagValue', pageElement);
    var tagArrow = vt('tagArrow', pageElement, 'true');
    var labelValueCss = vt('valueClass', pageElement, '');
    if (tagArrow === 'true') {
        labelValueCss = formatNull(labelValueCss, 'label_value_arrow');
        tagArrow = 'arrow_common_css';
    } else {
        labelValueCss = formatNull(labelValueCss, 'label_value');
        tagArrow = 'arrow_common_css,displayNone';
    }
    var valueStyle = vt('valueStyle', pageElement, '');
    if (enable === 'false' && valueStyle === '') {
        valueStyle = 'color: #cccccc;';
    }
    var tagOnClick = vt('tagOnClick', pageElement);
    var onClickArg = vt('onClickArg', pageElement);
    if (tagOnClick != '') {
        onClickArg = lua_format.table_arg_pack(onClickArg);
        tagOnClick = 'onclick=\\"' + (tagOnClick + ('(\'' + (onClickArg + '\')\\"')));
    }
    var htmlContent = '';
    var tagType = vt('tagType', pageElement);
    var lineDisplay = vt('lineDisplay', pageElement, 'true');
    if (lineDisplay === 'true') {
        lineDisplay = 'displayBlock';
    } else {
        lineDisplay = 'displayNone';
    }
    var divDisplay = vt('display', pageElement, 'none');
    if (divDisplay === 'none') {
        divDisplay = 'displayNone';
    } else {
        divDisplay = '';
    }
    var style = vt('style', pageElement);
    var explain = vt('explain', pageElement);
    var alertExplainClick = '';
    var explainHtml = '';
    if (explain != '') {
        explain = lua_format.base64_encode(explain);
        alertExplainClick = 'onclick=\\"alert_explain(\'' + (explain + '\')\\"');
        explainHtml = '[[\n\t\t\t<div class="inline-block,height-50,top-0" style="width: 15px;" border="0" ]]' + (alertExplainClick + ('[[>\n\t            <img src="local:unknown.png" class="unknown_css" ]]' + (alertExplainClick + '[[/>\n\t        </div>\n    \t]]')));
    }
    var tagTitleLen = ryt.getLengthByStr(tagTitle);
    var tempTagTitle = '';
    if (tagTitleLen > 7) {
        tempTagTitle = ryt.getSubstringValue(tagTitle, 0, 7);
    } else {
        tempTagTitle = tagTitle;
    }
    var textWidth = calculate_text_width(tempTagTitle, '14');
    var fontSize = '';
    if (platform === 'iPhone OS') {
        textWidth = textWidth + 5;
        if (tagTitleLen > 14) {
            fontSize = 'font-size: 13px;';
        }
    } else {
        textWidth = textWidth + 8;
    }
    var divWidth = parseFloat(textWidth) + 5 + 15;
    if (explain != '') {
        divWidth = divWidth + 20;
    }
    var tagTitleWidth = 'width: ' + (tostring(textWidth) + 'px');
    var tagTitleDivWidth = 'width: ' + (tostring(divWidth) + 'px');
    if (tagType === 'label' || tagType === 'select') {
        htmlContent = '[[\n\t            <div class="option_div,]]' + (divDisplay + ('[[" style="]]' + (style + ('[[" border="1" name="]]' + (tagName + ('[[_div" ]]' + (tagOnClick + ('[[ enable="]]' + (enable + ('[[">\n\t            \t<div class="inline-block,height-50,top-0" style="]]' + (tagTitleDivWidth + ('[[" border="0">\n\t                    <div class="inline-block,height-50,top-0" style="width: 15px;" border="0"> \n\t\t                \t<label class="ifRequired_css" name="]]' + (tagName + ('[[_required" value="]]' + (tagRequired + ('[[" />\n\t\t                </div>\n\t\t                <div class="inline-block,height-50,top-0" style="]]' + (tagTitleWidth + ('[[" border="0">\n\t\t                \t<label class="label_title,left-0" style="]]' + (fontSize + ('[[" name="]]' + (tagName + ('[[_title" value="]]' + (tagTitle + ('[[" ]]' + (alertExplainClick + ('[[ />\n\t\t                </div>]]' + (explainHtml + ('[[\n\t\t            </div>\n\t                <label class="]]' + (labelValueCss + ('[[" style="]]' + (valueStyle + ('[["  name="]]' + (tagName + ('[[" value="]]' + (tagValue + ('[[" />\n\t                <img src="local:arrow_common.png" class="]]' + (tagArrow + ('[[" name="arrow_common_]]' + (tagName + ('[[" />\n\t            \t<line class="line_css,]]' + (lineDisplay + '[[" />\n\t            </div>\n\t        ]]')))))))))))))))))))))))))))))))))))))))));
    } else if (tagType === 'input') {
        var hold = formatNull(vt('hold', pageElement), '请输入');
        var holdColor = formatNull(vt('holdColor', pageElement), '#9B9B9B');
        var inputBorder = formatNull(vt('inputBorder', pageElement), '0');
        var maxLength = vt('maxLength', pageElement);
        if (maxLength != '') {
            maxLength = 'maxleng=\\"' + (maxLength + '\\"');
        }
        var inputStyle = vt('inputStyle', pageElement);
        var pointValue = vt('pointValue', pageElement, '2');
        var onChange = vt('onchange', pageElement);
        if (onChange != '') {
            onChange = 'onchange=\\"' + (onChange + '()\\"');
        }
        var onBlur = vt('onblur', pageElement);
        if (onBlur != '') {
            onBlur = 'onblur=\\"' + (onBlur + '()\\"');
        }
        var disableEmoji = vt('disableEmoji', pageElement, 'false');
        if (inputStyle === 'int') {
            htmlContent = '[[\n\t            <div class="option_div,]]' + (divDisplay + ('[[" style="]]' + (style + ('[[" border="1" name="]]' + (tagName + ('[[_div" ]]' + (tagOnClick + ('[[ enable="]]' + (enable + ('[[">\n\t                <div class="inline-block,height-50,top-0" style="]]' + (tagTitleDivWidth + ('[[" border="0">\n\t                    <div class="inline-block,height-50,top-0" style="width: 15px;" border="0"> \n\t\t                \t<label class="ifRequired_css" name="]]' + (tagName + ('[[_required" value="]]' + (tagRequired + ('[[" />\n\t\t                </div>\n\t\t                <div class="inline-block,height-50,top-0" style="]]' + (tagTitleWidth + ('[[" border="0">\n\t\t                \t<label class="label_title,left-0" style="]]' + (fontSize + ('[[" name="]]' + (tagName + ('[[_title" value="]]' + (tagTitle + ('[[" ]]' + (alertExplainClick + ('[[ />\n\t\t                </div>]]' + (explainHtml + ('[[\n\t\t            </div>\n\t                <input type="text" style="-wap-input-format:\'N\']]' + (valueStyle + ('[[" border="]]' + (inputBorder + ('[[" pointValue="]]' + (pointValue + ('[[" hold="]]' + (hold + ('[[" holdColor="]]' + (holdColor + ('[[" class="input_text_css" name="]]' + (tagName + ('[[" value="]]' + (tagValue + ('[[" ]]' + (maxLength + ('[[ ]]' + (onChange + ('[[ ]]' + (onBlur + ('[[ disableEmoji="]]' + (disableEmoji + ('[[" />\n\t                <line class="line_css,]]' + (lineDisplay + '[[" />\n\t            </div>\n\t        ]]')))))))))))))))))))))))))))))))))))))))))))))))))));
        } else if (inputStyle === 'float') {
            htmlContent = '[[\n\t            <div class="option_div,]]' + (divDisplay + ('[[" style="]]' + (style + ('[[" border="1" name="]]' + (tagName + ('[[_div" ]]' + (tagOnClick + ('[[ enable="]]' + (enable + ('[[">\n\t                <div class="inline-block,height-50,top-0" style="]]' + (tagTitleDivWidth + ('[[" border="0">\n\t                    <div class="inline-block,height-50,top-0" style="width: 15px;" border="0"> \n\t\t                \t<label class="ifRequired_css" name="]]' + (tagName + ('[[_required" value="]]' + (tagRequired + ('[[" />\n\t\t                </div>\n\t\t                <div class="inline-block,height-50,top-0" style="]]' + (tagTitleWidth + ('[[" border="0">\n\t\t                \t<label class="label_title,left-0" style="]]' + (fontSize + ('[[" name="]]' + (tagName + ('[[_title" value="]]' + (tagTitle + ('[[" ]]' + (alertExplainClick + ('[[ />\n\t\t                </div>]]' + (explainHtml + ('[[\n\t\t            </div>\n\t                <input type="text" style="-wap-input-format:\'n\']]' + (valueStyle + ('[[" border="]]' + (inputBorder + ('[[" pointValue="]]' + (pointValue + ('[[" hold="]]' + (hold + ('[[" holdColor="]]' + (holdColor + ('[[" class="input_text_css" name="]]' + (tagName + ('[[" value="]]' + (tagValue + ('[[" ]]' + (maxLength + ('[[ ]]' + (onChange + ('[[ ]]' + (onBlur + ('[[ disableEmoji="]]' + (disableEmoji + ('[[" />\n\t                <line class="line_css,]]' + (lineDisplay + '[[" />\n\t            </div>\n\t        ]]')))))))))))))))))))))))))))))))))))))))))))))))))));
        } else if (inputStyle === 'date') {
            var showFormat = vt('showFormat', pageElement, 'yyyy-MM-dd');
            var valueFormat = vt('valueFormat', pageElement, 'yyyy-MM-dd');
            var picker = vt('picker', pageElement, '');
            htmlContent = '[[\n\t            <div class="option_div" style="]]' + (style + ('[[" border="1" name="]]' + (tagName + ('[[_div" ]]' + (tagOnClick + ('[[ enable="]]' + (enable + ('[[">\n\t                <div class="inline-block,height-50,top-0" style="]]' + (tagTitleDivWidth + ('[[" border="0">\n\t                    <div class="inline-block,height-50,top-0" style="width: 15px;" border="0"> \n\t\t                \t<label class="ifRequired_css" name="]]' + (tagName + ('[[_required" value="]]' + (tagRequired + ('[[" />\n\t\t                </div>\n\t\t                <div class="inline-block,height-50,top-0" style="]]' + (tagTitleWidth + ('[[" border="0">\n\t\t                \t<label class="label_title,left-0" style="]]' + (fontSize + ('[[" name="]]' + (tagName + ('[[_title" value="]]' + (tagTitle + ('[[" ]]' + (alertExplainClick + ('[[ />\n\t\t                </div>]]' + (explainHtml + ('[[\n\t\t            </div>\n\t                <input type="text" style="-wap-input-format:\'date\']]' + (valueStyle + ('[[" picker="]]' + (picker + ('[[" showFormat="]]' + (showFormat + ('[[" valueFormat="]]' + (valueFormat + ('[[" border="]]' + (inputBorder + ('[[" class="input_text_css" name="]]' + (tagName + ('[[" value="]]' + (tagValue + ('[[" disableEmoji="]]' + (disableEmoji + ('[[" />\n\t                <line class="line_css,]]' + (lineDisplay + '[[" />\n\t            </div>\n\t        ]]')))))))))))))))))))))))))))))))))))))))))));
        } else if (inputStyle === 'textarea') {
            var isShowButton = vt('isShowButton', pageElement, 'false');
            htmlContent = '[[\n\t\t\t\t<div class="option_div,]]' + (divDisplay + ('[[" style="]]' + (style + ('[[" border="1" name="]]' + (tagName + ('[[_div" ]]' + (tagOnClick + ('[[ enable="]]' + (enable + ('[[">\n\t                <div class="inline-block,height-50,top-0" style="]]' + (tagTitleDivWidth + ('[[" border="0">\n\t                    <div class="inline-block,height-50,top-0" style="width: 15px;" border="0"> \n\t\t                \t<label class="ifRequired_css" name="]]' + (tagName + ('[[_required" value="]]' + (tagRequired + ('[[" />\n\t\t                </div>\n\t\t                <div class="inline-block,height-50,top-0" style="]]' + (tagTitleWidth + ('[[" border="0">\n\t\t                \t<label class="label_title,left-0" style="]]' + (fontSize + ('[[" name="]]' + (tagName + ('[[_title" value="]]' + (tagTitle + ('[[" ]]' + (alertExplainClick + ('[[ />\n\t\t                </div>]]' + (explainHtml + ('[[\n\t\t            </div>\n\t                <textarea class="textarea_css" style="]]' + (valueStyle + ('[[" border="]]' + (inputBorder + ('[[" name="]]' + (tagName + ('[[" hold="]]' + (hold + ('[[" holdColor="]]' + (holdColor + ('[[" value="]]' + (tagValue + ('[[" disableEmoji="]]' + (disableEmoji + ('[[" isShowButton="]]' + (isShowButton + ('[[" ]]' + (maxLength + ('[[ ]]' + (onChange + ('[[ ]]' + (onBlur + ('[[ />\n\t                <div class="space_10_div" border="0" />\n\t                <line class="line_css,]]' + (lineDisplay + '[[" />\n\t            </div>\n\t        ]]')))))))))))))))))))))))))))))))))))))))))))))))))));
        } else {
            htmlContent = '[[\n\t            <div class="option_div,]]' + (divDisplay + ('[[" style="]]' + (style + ('[[" border="1" name="]]' + (tagName + ('[[_div" ]]' + (tagOnClick + ('[[ enable="]]' + (enable + ('[[">\n\t                <div class="inline-block,height-50,top-0" style="]]' + (tagTitleDivWidth + ('[[" border="0">\n\t                    <div class="inline-block,height-50,top-0" style="width: 15px;" border="0"> \n\t\t                \t<label class="ifRequired_css" name="]]' + (tagName + ('[[_required" value="]]' + (tagRequired + ('[[" />\n\t\t                </div>\n\t\t                <div class="inline-block,height-50,top-0" style="]]' + (tagTitleWidth + ('[[" border="0">\n\t\t                \t<label class="label_title,left-0" style="]]' + (fontSize + ('[[" name="]]' + (tagName + ('[[_title" value="]]' + (tagTitle + ('[[" ]]' + (alertExplainClick + ('[[ />\n\t\t                </div>]]' + (explainHtml + ('[[\n\t\t            </div>\n\t                <input type="text" border="]]' + (inputBorder + ('[[" hold="]]' + (hold + ('[[" holdColor="]]' + (holdColor + ('[[" class="input_text_css" style="]]' + (valueStyle + ('[[" name="]]' + (tagName + ('[[" value="]]' + (tagValue + ('[[" ]]' + (maxLength + ('[[ ]]' + (onChange + ('[[ ]]' + (onBlur + ('[[ disableEmoji="]]' + (disableEmoji + ('[[" />\n\t                <line class="line_css,]]' + (lineDisplay + '[[" />\n\t            </div>\n\t        ]]')))))))))))))))))))))))))))))))))))))))))))))))));
        }
    } else if (tagType === 'radio') {
        var radio_left_label = vt('leftLabel', pageElement, '是');
        var radio_right_label = vt('rightLabel', pageElement, '否');
        var call_back_fun = vt('callBackFun', pageElement);
        htmlContent = '[[\n            <div class="option_div,]]' + (divDisplay + ('[[" style="]]' + (style + ('[[" border="1" name="]]' + (tagName + ('[[_div" ]]' + (tagOnClick + ('[[ enable="]]' + (enable + ('[[">\n                <div class="inline-block,height-50,top-0" style="]]' + (tagTitleDivWidth + ('[[" border="0">\n                    <div class="inline-block,height-50,top-0" style="width: 15px;" border="0"> \n\t                \t<label class="ifRequired_css" name="]]' + (tagName + ('[[_required" value="]]' + (tagRequired + ('[[" />\n\t                </div>\n\t                <div class="inline-block,height-50,top-0" style="]]' + (tagTitleWidth + ('[[" border="0">\n\t                \t<label class="label_title,left-0" style="]]' + (fontSize + ('[[" name="]]' + (tagName + ('[[_title" value="]]' + (tagTitle + ('[[" ]]' + (alertExplainClick + ('[[ />\n\t                </div>]]' + (explainHtml + ('[[\n\t            </div>\n                <div class="radio_div" border="0">\n                \t<div class="leftRadio_div" border="0" onclick="lua_components.set_radio_select(\'0\',\']]' + (tagName + ('[[\',\']]' + (call_back_fun + ('[[\')">\n\t                \t<img class="radio_img" src="local:dj_ico_radio.png" name="]]' + (tagName + ('[[_leftRadio" onclick="lua_components.set_radio_select(\'0\',\']]' + (tagName + ('[[\',\']]' + (call_back_fun + ('[[\')" />\n\t                \t<label class="radio_label" style="]]' + (valueStyle + ('[[" value="]]' + (radio_left_label + ('[[" onclick="lua_components.set_radio_select(\'0\',\']]' + (tagName + ('[[\',\']]' + (call_back_fun + ('[[\')" />\n\t                </div>\n\t                <div class="rightRadio_div" border="0" onclick="lua_components.set_radio_select(\'1\',\']]' + (tagName + ('[[\',\']]' + (call_back_fun + ('[[\')">\n\t                \t<img class="radio_img" src="local:dj_ico_radio.png" name="]]' + (tagName + ('[[_rightRadio" onclick="lua_components.set_radio_select(\'1\',\']]' + (tagName + ('[[\',\']]' + (call_back_fun + ('[[\')" />\n\t                \t<label class="radio_label" style="]]' + (valueStyle + ('[[" value="]]' + (radio_right_label + ('[[" onclick="lua_components.set_radio_select(\'1\',\']]' + (tagName + ('[[\',\']]' + (call_back_fun + ('[[\')" />\n\t                </div>\n                </div>\n                <line class="line_css,]]' + (lineDisplay + '[[" />\n            </div>\n        ]]')))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));
    } else {
        htmlContent = '[[\n            <div class="option_div,]]' + (divDisplay + ('[[" style="]]' + (style + ('[[" border="1" name="]]' + (tagName + ('[[_div" ]]' + (tagOnClick + ('[[ enable="]]' + (enable + ('[[">\n                <div class="inline-block,height-50,top-0" style="]]' + (tagTitleDivWidth + ('[[" border="0">\n                    <div class="inline-block,height-50,top-0" style="width: 15px;" border="0"> \n\t                \t<label class="ifRequired_css" name="]]' + (tagName + ('[[_required" value="]]' + (tagRequired + ('[[" />\n\t                </div>\n\t                <div class="inline-block,height-50,top-0" style="]]' + (tagTitleWidth + ('[[" border="0">\n\t                \t<label class="label_title,left-0" style="]]' + (fontSize + ('[[" name="]]' + (tagName + ('[[_title" value="]]' + (tagTitle + ('[[" ]]' + (alertExplainClick + ('[[ />\n\t                </div>]]' + (explainHtml + ('[[\n\t            </div>\n                <label class="label_value_arrow" style="]]' + (valueStyle + ('[["  name="]]' + (tagName + ('[[" value="]]' + (tagValue + ('[[" />\n                <img src="local:arrow_common.png" class="]]' + (tagArrow + ('[[" name="arrow_common_]]' + (tagName + ('[[" />\n                <line class="line_css,]]' + (lineDisplay + '[[" />\n            </div>\n        ]]')))))))))))))))))))))))))))))))))))))));
    }
    return htmlContent;
};
lua_components.incomeexpenditureView = function (pageElement) {
    var pageName = vt('pageName', pageElement);
    var viewName = vt('viewName', pageElement);
    var viewTitle = vt('viewTitle', pageElement);
    var viewValue = vt('viewValue', pageElement);
    var closeFun = vt('closeFun', pageElement, 'lua_page.div_page_ctrl');
    var clickFun = vt('clickFun', pageElement);
    var htmlContent = '[[\n\t\t<div class="lucencyBackground_css" border="0" name="]]' + (pageName + ('[[" >\n\t\t    <incomeexpenditureView class="view_css" value=\']]' + (viewValue + ('[[\' name="]]' + (viewName + ('[[" cancel="]]' + (closeFun + ('[[" confirm="]]' + (clickFun + ('[[" title="]]' + (viewTitle + '[["></incomeexpenditureView>\n\t\t</div>\n\t]]')))))))))));
    return htmlContent;
};
getSpace = function (spaceSize) {
    var size = formatNull(spaceSize, '10');
    var htmlContent = '[[\n\t\t<div class="space_]]' + (size + '[[_div" border="0" />\n\t]]');
    return htmlContent;
};
lua_components.set_radio_select = function (index, tagName, callBackFun) {
    var index = formatNull(index);
    var leftRadio = document.getElementsByName(tagName + '_leftRadio');
    var rightRadio = document.getElementsByName(tagName + '_rightRadio');
    if (leftRadio.length === 1 && rightRadio.length === 1) {
        if (index === '0') {
            leftRadio[1].setPropertyByName('src', 'local:sl_ico_radioOrange.png');
            rightRadio[1].setPropertyByName('src', 'local:sl_ico_radioGrey.png');
        } else if (index === '1') {
            leftRadio[1].setPropertyByName('src', 'local:sl_ico_radioGrey.png');
            rightRadio[1].setPropertyByName('src', 'local:sl_ico_radioOrange.png');
        } else {
            leftRadio[1].setPropertyByName('src', 'local:sl_ico_radioGrey.png');
            rightRadio[1].setPropertyByName('src', 'local:sl_ico_radioGrey.png');
        }
    } else if (leftRadio.length > 1 || rightRadio.length > 1) {
        debug_alert('指定radio数量大于1');
    } else {
        debug_alert('指定radio不存在');
    }
    if (formatNull(callBackFun) != '') {
        lua_system.do_function(callBackFun, index);
    } else {
        debug_alert('未指定回调方法');
    }
};
jjbx_select_people = function (ItemData) {
    lua_page.div_page_ctrl();
    var peopleInfo = lua_format.table_arg_unpack(ItemData);
    var backFunc = vt('search_people_back_fun', globalTable);
    globalTable['search_people_back_fun'] = null;
    if (backFunc != '') {
        lua_system.do_function(backFunc, peopleInfo);
    } else {
        alert('回调方法未定义');
    }
};
alert_explain = function (explain) {
    if (explain != '') {
        explain = lua_format.base64_decode(explain);
        alert(explain);
    }
};
jjbx_search_for_psn_app = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams, {});
        ReqParams['ReqAddr'] = 'fuzzySearchNew/forPsnApp';
        ReqParams['ReqUrlExplain'] = '搜索员工信息';
        ReqParams['BusinessCall'] = jjbx_search_for_psn_app;
        ReqParams['BusinessParams'] = table2json(ReqParams['BusinessParams']);
        ReqParams['ReqFuncName'] = 'invoke_trancode_noloading';
        lua_jjbx.common_req(ReqParams);
    } else {
        close_loading();
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            var peopleList = formatNull(res['list'], {});
            var htmlHead = '[[<div class="search_content_div" border="1" name="people_info_div">]]';
            var htmlContent = '';
            if (peopleList.length > 0) {
                for (var [key, value] in pairs(peopleList)) {
                    var ItemData = peopleList[key];
                    var EncodeItemData = lua_format.table_arg_pack(ItemData);
                    htmlContent = htmlContent + ('[[\n                        <div class="search_people_option" border="1" onclick="jjbx_select_people(\']]' + (EncodeItemData + ('[[\')">\n                            <label class="people_workId_css" value="]]' + (value['workid'] + ('[[" />\n                            <label class="people_nameAndDept_css" value="]]' + (value['name'] + ('[[ ]]' + (value['deptName'] + '[[" />\n                            <div style="height: 5px;" border="0"/>\n                            <line class="line_css_search_people" />\n                        </div>\n                    ]]'))))))));
                }
                htmlContent = htmlHead + (htmlContent + '[[</div>]]');
                document.getElementsByName('people_info_div')[1].setInnerHTML(htmlContent);
            } else {
                htmlContent = htmlHead + '[[<div class="search_people_option" border="1"><label class="label_noData" value="查无此人" /></div></div>]]';
                document.getElementsByName('people_info_div')[1].setInnerHTML(htmlContent);
            }
            page_reload();
        } else {
            alert(res['errorMsg']);
        }
    }
};
jjbx_search_people = function () {
    if (getValue('peopleName') != '') {
        var ReqParams = {
            searchFlag: 'corp',
            isContainsSeal: '1',
            keywords: getValue('peopleName'),
            pkCorp: ''
        };
        globalTable['search_people_back_fun'] = 'select_people_back';
        jjbx_search_for_psn_app('', { BusinessParams: ReqParams });
    }
};
search_people_info = function (Arg) {
    var Arg = formatNull(Arg);
    var labelTitle = vt('labelTitle', Arg, '员工姓名');
    var inputValue = vt('inputValue', Arg);
    var searchFunc = vt('searchFunc', Arg, 'jjbx_search_people()');
    var htmlContent = '[[\n        <div class="search_content_css" border="0">\n            <div class="space_05_div" border="0" />\n            <div class="search_data_css" border="0">\n                <div class="option_div" border="1">\n                    <div class="search_input_div" border="0">\n                        <label class="ifRequired_css" name="search_required">*</label>\n                        <label class="label_title" value="]]' + (labelTitle + ('[[" />\n                        <input type="text" class="input_text_css" value="]]' + (inputValue + ('[[" hold="请输入" maxleng="20" border="0" name="peopleName" onchange="]]' + (searchFunc + '[[" />\n                    </div>\n                </div>\n                <div style="height: 1px;" border="0"></div>\n                <div class="search_content_div" border="1" name="people_info_div">\n                    \n                </div>\n            </div>\n        </div>\n    ]]')))));
    return htmlContent;
};
show_div = function (elementArg) {
    var elementName = lua_format.table_arg_unpack(elementArg);
    lua_page.div_page_ctrl(elementName['pageName'], 'false', 'false');
};
jjbx_change_radio = function (flag, elementName) {
    var eName = formatNull(elementName, 'radio');
    var e = document.getElementsByName(eName);
    if (flag === '0') {
        e[1].setPropertyByName('src', 'local:sl_ico_radioOrange.png');
        e[2].setPropertyByName('src', 'local:sl_ico_radioGrey.png');
    } else {
        e[1].setPropertyByName('src', 'local:sl_ico_radioGrey.png');
        e[2].setPropertyByName('src', 'local:sl_ico_radioOrange.png');
    }
    return flag;
};
module.exports = { lua_components: lua_components };