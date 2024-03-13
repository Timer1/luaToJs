lua_utils = {};
splitUtils = function (str, separator) {
    var nFindStartIndex = 1;
    var nSplitIndex = 1;
    var nSplitArr = {};
    while (true) {
        var nFindLastIndex = string.find(str, separator, nFindStartIndex);
        if (!nFindLastIndex) {
            nSplitArr[nSplitIndex] = string.sub(str, nFindStartIndex, string.len(str));
            break;
        }
        nSplitArr[nSplitIndex] = string.sub(str, nFindStartIndex, nFindLastIndex - 1);
        nFindStartIndex = nFindLastIndex + string.len(string.gsub(separator, '%%', ''));
        nSplitIndex = nSplitIndex + 1;
    }
    return nSplitArr;
};
string_to_table = function (params, concatstr) {
    var concatstr = formatNull(concatstr, '&');
    t = {};
    for (var [k, v] in string.gmatch(params, '(%w+)=([^%' + (concatstr + ']+)'))) {
        t[k] = v;
    }
    return t;
};
tableToString = function (tab) {
    var str = '';
    if (tab === null) {
        return str;
    }
    for (let i = 1; tab.length; i++) {
        if (i != 1) {
            str = str + '#';
        }
        str = str + (i + ('=' + tab[i]));
    }
    return str;
};
timestamp_to_date = function (timestamp, type) {
    var dateTime = '';
    if (timestamp === '' || timestamp === null || timestamp === null || timestamp === 'nil') {
        return '';
    } else {
        if (type === 'date') {
            dateTime = os.date('%Y-%m-%d', timestamp / 1000);
            return dateTime;
        } else if (type === 'time') {
            dateTime = os.date('%Y-%m-%d  %H:%M:%S', timestamp / 1000);
            return dateTime;
        }
    }
};
to_date_timestamp = function (date) {
    var Y = string.sub(date, 1, 4);
    var M = string.sub(date, 6, 7);
    var D = string.sub(date, 9, 10);
    var timestamp;
    return timestamp;
};
cutStr = function (str, len) {
    return jjbx_utils_setStringLength(str, len);
};
jjbx_utils_setStringLength = function (str, len) {
    if (formatNull(str) != '') {
        var elementLen = ryt.getLengthByStr(str);
        if (elementLen > parseFloat(len)) {
            return ryt.getSubstringValue(str, 0, parseFloat(len)) + '...';
        } else {
            return str;
        }
    } else {
        return '';
    }
};
lua_utils.strCut = function (str, len) {
    if (formatNull(str) != '') {
        var elementLen = ryt.getLengthByStr(str);
        if (elementLen > parseFloat(len)) {
            return ryt.getSubstringValue(str, 0, parseFloat(len));
        } else {
            return str;
        }
    } else {
        return '';
    }
};
millisecondTotime = function (timestamp) {
    var stopTime = parseFloat(timestamp);
    var hours = (stopTime - stopTime % (1000 * 60 * 60)) / (1000 * 60 * 60);
    var minmills = stopTime % (1000 * 60 * 60);
    var minutes = (minmills - minmills % (1000 * 60)) / (1000 * 60);
    var seconds = math.modf(minmills % (1000 * 60) / 1000), seconds2 = math.modf(minmills % (1000 * 60) / 1000);
    var times = '';
    if (minutes < 10) {
        minutes = '0' + minutes;
    }
    if (seconds < 10) {
        seconds = '0' + seconds;
    }
    if (hours < 10) {
        hours = '0' + hours;
    }
    times = hours + (':' + (minutes + (':' + seconds)));
    return times;
};
adaptStringLength = function (str, length) {
    var res = str;
    if (str.length > length) {
        res = string.sub(str, 0, length) + '...';
    }
    return res;
};
getStringCharCount = function (str) {
    var charCount = ryt.getLengthByStr(str);
    return charCount;
};
px2num = function (pxstr) {
    var pxstr = string.gsub(pxstr, 'px', '');
    var pxnum = parseFloat(pxstr);
    return pxnum;
};
dateToTime = function (v) {
    var Y = string.sub(v, 1, 4);
    var M = string.sub(v, 6, 7);
    var D = string.sub(v, 9, 10);
    var dt;
    return dt;
};
dateToTimeNoDay = function (v) {
    var Y = string.sub(v, 1, 4);
    var M = string.sub(v, 6, 7);
    var dt;
    return dt;
};
dateToMonthTime = function (v) {
    var Y = string.sub(v, 1, 4);
    var M = string.sub(v, 6, 7);
    var D = '01';
    var dt;
    return dt;
};
getPropertyList = function (elementName, propertyType, index) {
    var valueList = {};
    if (index && index != '') {
        if (string.find(index, '^%d+$')) {
            var elements = document.getElementsByName(elementName)[parseFloat(index)];
            table.insert(valueList, elements.getPropertyByName(propertyType));
            return valueList;
        } else {
            debug_alert('index类型有误');
        }
    } else {
        var elements = document.getElementsByName(elementName);
        if (elements.length > 0) {
            for (let i = 1; elements.length; i++) {
                table.insert(valueList, elements[i].getPropertyByName(propertyType));
            }
            return valueList;
        } else {
            debug_alert('标签\uFF1A' + (elementName + '不存在'));
            return valueList;
        }
    }
};
getStyleList = function (elementName, styleType, index) {
    var valueList = {};
    if (index && index != '') {
        if (string.find(index, '^%d+$')) {
            var elements = document.getElementsByName(elementName)[parseFloat(index)];
            table.insert(valueList, elements.getStyleByName(styleType));
            return valueList;
        } else {
            debug_alert('index类型有误');
        }
    } else {
        var elements = document.getElementsByName(elementName);
        if (elements.length > 0) {
            for (let i = 1; elements.length; i++) {
                table.insert(valueList, elements[i].getStyleByName(styleType));
            }
            return valueList;
        } else {
            debug_alert('标签\uFF1A' + (elementName + '不存在'));
            return valueList;
        }
    }
};
undefined_fun = function () {
};
jjbx_allDate_formatDate = function (dateTime, resultType) {
    if (dateTime === '' || dateTime === null || dateTime === null || dateTime === 'nil') {
        return '';
    } else {
        if (resultType === 'date') {
            dateTime = os.date('%Y-%m-%d', dateTime / 1000);
            return dateTime;
        } else if (resultType === 'time') {
            dateTime = os.date('%Y-%m-%d  %H:%M:%S', dateTime / 1000);
            return dateTime;
        }
    }
};
jjbx_checkInputText = function (elementValue) {
    var repStr = '<>&';
    var flag = true;
    for (let i = 1; string.len(repStr); i++) {
        var str = string.sub(repStr, i, i);
        if (string.find(elementValue, str)) {
            alert('输入的文本不可包含特殊字符\'<\'\u3001\'>\'\u3001\'&\'');
            flag = false;
            break;
        }
    }
    return flag;
};
find_str_counts = function (str, tag) {
    var str = formatNull(str);
    var tag = formatNull(tag);
    var counts = 0;
    if (str != '' && tag != '') {
        for (var [k, v] in string.gfind(str, tag)) {
            counts = counts + 1;
        }
    }
    return counts;
};
lua_utils.table_data_match = function (DataList, MatchArgName, MatchArgValue) {
    var DataList = formatNull(DataList);
    var MatchArgName = formatNull(MatchArgName);
    var MatchArgValue = formatNull(MatchArgValue);
    var DataListCounts = DataList.length;
    var MatchIndexRes = '';
    for (let i = 1; DataListCounts; i++) {
        var DataItemInfo = formatNull(DataList[i]);
        var DataItemArgValue = vt(MatchArgName, DataItemInfo);
        if (DataItemArgValue === MatchArgValue) {
            MatchIndexRes = tostring(i);
            break;
        }
    }
    return MatchIndexRes;
};
getInputMaxLen = function (eleName, defualtMaxLen, pageConfig) {
    var inputMaxLen = defualtMaxLen;
    var pageConfig = formatNull(pageConfig, {});
    for (var [key, value] in pairs(pageConfig)) {
        if (eleName === value['fieldName'] || eleName === value['fieldAppId'] || eleName + '_div' === value['fieldAppId']) {
            inputMaxLen = formatNull(value['limitNum'], defualtMaxLen);
            break;
        }
    }
    return inputMaxLen;
};
jjbx_getPageConfigDetail = function (tagName, pageConfig, elementValue) {
    var pageConfig = formatNull(pageConfig, {});
    var tagName = formatNull(tagName);
    var pageConfigDetail = {};
    var matchFlag = 'false';
    for (var [key, value] in pairs(pageConfig)) {
        if (tagName === value['fieldName'] || tagName + '_div' === value['fieldAppId'] || tagName === value['fieldAppId']) {
            pageConfigDetail = pageConfig[key];
            matchFlag = 'true';
            break;
        }
    }
    if (formatNull(elementValue) != '') {
        if (matchFlag === 'true') {
            var eValue = vt(elementValue, pageConfigDetail);
            return eValue;
        } else {
            return '';
        }
    } else {
        return pageConfigDetail;
    }
};
jjbx_changeInputMaxleng = function (tagName, maxleng) {
    var elements = document.getElementsByName(tagName);
    var maxleng = formatNull(maxleng, '0');
    if (elements.length > 0) {
        if (maxleng === '0') {
            alert('参数maxleng为空');
            return;
        }
        if (platform === 'iPhone OS') {
            elements[1].setCustomPropertyByName('maxleng', maxleng);
        } else {
            elements[1].setPropertyByName('maxleng', maxleng);
        }
        page_reload();
    } else {
        alert('元素标签' + (tagName + '不存在'));
    }
};
lua_utils.day_before_today = function (daysAgoTypeName) {
    var daysAgoTypeName = formatNull(daysAgoTypeName);
    var StartDate = '';
    var EndDate = '';
    if (daysAgoTypeName != '') {
        var days = '';
        if (daysAgoTypeName === '近一周') {
            days = 7;
        } else if (daysAgoTypeName === '近一月') {
            days = 30;
        } else if (daysAgoTypeName === '近三月') {
            days = 91;
        } else if (daysAgoTypeName === '近半年') {
            days = 182;
        } else {
        }
        if (days != '') {
            var EndTime = os.time();
            var StartTime = EndTime - days * 24 * 60 * 60;
            StartDate = os.date('%Y-%m-%d', StartTime);
            EndDate = os.date('%Y-%m-%d', EndTime);
        }
    }
    return {
        StartDate: StartDate,
        EndDate: EndDate
    };
};
len = function (Arg) {
    var Arg = formatNull(Arg);
    if (type(Arg) === 'string') {
        return ryt.getLengthByStr(Arg);
    } else if (type(Arg) === 'table') {
        return Arg.length;
    } else {
        return 0;
    }
};
module.exports = { lua_utils: lua_utils };