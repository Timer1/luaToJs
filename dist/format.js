const lua_utils = require('./utils');
lua_format = {};
formatHideAccountNo = function (account) {
    var account1 = string.sub(account, 1, 6);
    var account2 = string.sub(account, string.len(account) - 3, string.len(account));
    var account3 = account1 + ('****' + account2);
    return account3;
};
formatShowAccountNo = function (account) {
    var value1 = string.sub(account, 1, 4);
    var value2 = string.sub(account, 5, 8);
    var value3 = string.sub(account, 9, 12);
    var value4 = string.sub(account, 13, 16);
    var value5 = string.sub(account, 17, 19);
    var accountValue = value1 + ('    ' + (value2 + ('    ' + (value3 + ('    ' + (value4 + ('    ' + value5)))))));
    return accountValue;
};
lua_format.hide_mobile_no = function (mobileNo) {
    var mobileNo = formatNull(mobileNo);
    if (mobileNo != '') {
        var value1 = string.sub(mobileNo, 1, 3);
        var value2 = string.sub(mobileNo, 8, 11);
        var hideMobileNo = value1 + ('****' + value2);
        return hideMobileNo;
    } else {
        return '';
    }
};
formatYield = function (yield) {
    var yield = yield * 100;
    var index = string.find(yield, '%.');
    if (index === null) {
        console.log(yield + '.0000');
    } else {
        var oldYieldLen = string.len(string.sub(yield, index + 1, string.len(yield)));
        if (parseFloat(oldYieldLen) === 1) {
            yield = yield + '000';
            return yield;
        } else if (parseFloat(oldYieldLen) === 2) {
            yield = yield + '00';
            return yield;
        } else if (parseFloat(oldYieldLen) === 3) {
            yield = yield + '0';
            return yield;
        }
        return yield;
    }
};
formatMoney = function (money) {
    var money = formatNull(money);
    if (formatNull(parseFloat(money)) === '') {
        return '0.00';
    } else {
        var resArr = {};
        var resMoney = '';
        var integerMoney1 = '';
        var integerMoney2 = '';
        if (money === '' || money === null) {
            resMoney = ',0.00';
        } else {
            integerMoney1 = string.sub(money, 0, 1);
            if (integerMoney1 === '-') {
                integerMoney2 = string.sub(money, 2, string.len(money));
            } else {
                integerMoney1 = '';
                integerMoney2 = money;
            }
            var moneyf = string.format('%.2f', integerMoney2);
            var integerMoney = string.sub(moneyf, 0, string.len(moneyf) - 3);
            var decimalMoney = string.sub(moneyf, string.len(moneyf) - 2, string.len(moneyf));
            var integerMoneyLen = string.len(integerMoney);
            var graphNum = math.floor(integerMoneyLen / 3);
            if (graphNum != integerMoneyLen / 3) {
                graphNum = graphNum + 1;
            }
            if (integerMoneyLen < 4) {
                resMoney = ',' + integerMoney;
            } else {
                for (let i = 1; graphNum; i++) {
                    if (i != graphNum) {
                        resArr[i] = string.sub(integerMoney, string.len(integerMoney) - 3 * i + 1, string.len(integerMoney) - 3 * (i - 1));
                    } else {
                        resArr[i] = string.sub(integerMoney, 0, string.len(integerMoney) - 3 * (i - 1));
                    }
                }
                for (let i = graphNum; 1; i+=undefined) {
                    resMoney = resMoney + (',' + resArr[i]);
                }
            }
            resMoney = resMoney + decimalMoney;
        }
        return integerMoney1 + string.sub(resMoney, 2, string.len(resMoney));
    }
};
formatNull = function (str, defValue) {
    if (defValue === 'null' || defValue === null || defValue === null || defValue === '') {
        defValue = '';
    }
    if (str === 'null' || str === null || str === null || str === '' || str === 'undefined') {
        return defValue;
    } else {
        return str;
    }
};
formatSpecialChar = function (str) {
    if (formatNull(str) === '') {
        return '';
    } else {
        str = string.gsub(str, '\\n', '');
        str = string.gsub(str, '\\t', '');
        str = string.gsub(str, '<', '');
        str = string.gsub(str, '>', '');
        str = string.gsub(str, '{', '%{');
        str = string.gsub(str, '}', '%}');
        str = string.gsub(str, '\\\\', '\\\\\\\\');
        str = string.gsub(str, '\\"', '\\\\\\"');
        return str;
    }
};
dateFormatWeek = function (param) {
    var param = formatNull(param);
    if (param === '') {
        return '';
    } else {
        var y = string.match(param, '(%d%d%d%d)-(%d%d)-(%d%d)'), m = string.match(param, '(%d%d%d%d)-(%d%d)-(%d%d)'), d = string.match(param, '(%d%d%d%d)-(%d%d)-(%d%d)');
        var t = os.time({
            'year': y,
            'month': m,
            'day': d
        });
        var w = os.date('*t', t).wday;
        if (parseFloat(w) === 1) {
            return '周日';
        } else if (parseFloat(w) === 2) {
            return '周一';
        } else if (parseFloat(w) === 3) {
            return '周二';
        } else if (parseFloat(w) === 4) {
            return '周三';
        } else if (parseFloat(w) === 5) {
            return '周四';
        } else if (parseFloat(w) === 6) {
            return '周五';
        } else {
            return '周六';
        }
    }
};
formatdate = function (flag, dateTime) {
    if (formatNull(dateTime) === '') {
        return '';
    } else {
        if (flag === 1) {
            dateTime = os.date('%Y.%m.%d', dateTime / 1000);
        } else if (flag === 2) {
            dateTime = os.date('%Y-%m-%d', dateTime / 1000);
        } else if (flag === 3) {
            dateTime = os.date('%m月%d日', dateTime / 1000);
        } else if (flag === 4) {
            dateTime = os.date('%H:%M', dateTime / 1000);
        } else if (flag === 5) {
            dateTime = os.date('%Y%m%d', dateTime / 1000);
        }
        return dateTime;
    }
};
date_delete_CN = function (date) {
    var newDate = '';
    if (string.len(date) === 17) {
        var y = string.sub(date, 1, 4);
        var m = string.sub(date, 8, 9);
        var d = string.sub(date, 13, 14);
        newDate = y + ('-' + (m + ('-' + d)));
    } else {
        newDate = date;
    }
    return newDate;
};
date_add_CN = function (date) {
    var newDate = '';
    if (string.len(date) === 10) {
        var y = string.sub(date, 1, 4);
        var m = string.sub(date, 6, 7);
        var d = string.sub(date, 9, 10);
        newDate = y + ('年' + (m + ('月' + (d + '日'))));
    } else {
        newDate = date;
    }
    return newDate;
};
float = function (data, lenAfterPoint) {
    var data = formatNull(data);
    var len = formatNull(lenAfterPoint, 2);
    var res = parseFloat(string.format('%.' + (len + 'f'), data));
    return res;
};
json2table = function (jsonData) {
    var jsonData = formatNull(jsonData);
    var tableRes = {};
    tableRes = formatNull(json.objectFromJSON(jsonData));
    return tableRes;
};
table2json = function (tableData) {
    var table = formatNull(tableData);
    var jsonRes = '';
    jsonRes = formatNull(json.jsonFromObject(tableData));
    return jsonRes;
};
foreach_arg2print = function (tableArg, showTable, filtArg) {
    var tableArg = formatNull(tableArg);
    var filtArg = formatNull(filtArg);
    if (tableArg != '') {
        if (type(tableArg) === 'table') {
            var showTable = formatNull(showTable, 'true');
            var tableValueMsg = do_foreach_arg2print(tableArg, showTable, filtArg, '', '');
            return tableValueMsg;
        } else {
            return tableArg;
        }
    } else {
        return 'null table arg';
    }
};
do_foreach_arg2print = function (tableArg, showTable, filtArg, returnValue, parentDataType) {
    for (var [key, value] in pairs(tableArg)) {
        var showKey = tostring(formatNull(key));
        var showValue = '';
        var addReturnValue = '';
        var DoFilt = 'false';
        if (filtArg != '' && showKey != '') {
            if (string.find(filtArg, showKey)) {
                DoFilt = 'true';
            }
        }
        var ValueType = type(value);
        if (DoFilt === 'true') {
        } else {
            if (ValueType === 'table') {
                if (showTable === 'true') {
                    var tableValueMsg = do_foreach_arg2print(value, showTable, filtArg, '', 'table');
                    if (type(value[1]) === 'table') {
                        showValue = '(table类型)' + tostring(tableValueMsg);
                        addReturnValue = showKey + (' : ' + (showValue + ''));
                    } else {
                        showValue = '(table类型)\\n' + tostring(tableValueMsg);
                        addReturnValue = showKey + (' : ' + (showValue + ''));
                    }
                } else {
                    showValue = '(table不显示)';
                    addReturnValue = showKey + (' : ' + (showValue + ('\\n' + '')));
                }
            } else {
                showValue = tostring(formatNull(value));
                if (parentDataType === 'table') {
                    addReturnValue = showKey + (' : ' + (showValue + ('\\n' + '')));
                } else {
                    addReturnValue = showKey + (' : ' + (tostring(showValue) + ('\\n' + ('\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D' + ''))));
                }
            }
        }
        if (key != 1) {
            returnValue = returnValue + ('\\n' + addReturnValue);
        } else {
            returnValue = returnValue + addReturnValue;
        }
    }
    return returnValue;
};
vt = function (key, table, defaultValue) {
    var table = formatNull(table);
    var key = formatNull(key);
    if (table != '' || key != '') {
        var value = formatNull(table[key], defaultValue);
        return value;
    } else {
        return '';
    }
};
lua_format.delete_last_char = function (str) {
    var str = formatNull(str);
    if (str === '') {
        return '';
    } else {
        return string.sub(str, 1, string.len(str) - 1);
    }
};
lua_format.str2fun = function (str) {
    var str = formatNull(str);
    var fun = '';
    if (str != '') {
        var splitIndex = formatNull(string.find(str, '%.'), 0);
        if (splitIndex > 0) {
            var funTable = splitUtils(str, '%.');
            if (funTable.length === 2) {
                var funPack = funTable[1];
                var funName = funTable[2];
                fun = _G[funPack][funName];
            } else {
                debug_alert('函数分包查找异常');
                return;
            }
        } else {
            fun = _G[str];
        }
        return fun;
    } else {
        debug_alert('函数参数为空');
        return;
    }
};
lua_format.str2arg = function (str) {
    var str = formatNull(str);
    var arg = '';
    if (str != '') {
        arg = _G[str];
        return arg;
    } else {
        debug_alert('参数为空');
        return;
    }
};
lua_format.init_table_params = function (table) {
    var table = formatNull(table);
    if (table != '') {
        for (var [key, value] in pairs(table)) {
            table[key] = '';
        }
    }
};
lua_format.url_arg2table = function (url) {
    var url = formatNull(url);
    var splitIndex = string.find(url, '?');
    var callbackArg = string.sub(url, splitIndex + 1, string.len(url));
    var argTable = splitUtils(callbackArg, '&');
    var returnArgTableItemJson = '';
    for (let i = 1; argTable.length; i++) {
        var argItem = formatNull(argTable[i]);
        var argSplitIndex = string.find(argItem, '=');
        var key = string.sub(argItem, 1, argSplitIndex - 1);
        var value = string.sub(argItem, argSplitIndex + 1, string.len(argItem));
        returnArgTableItemJson = returnArgTableItemJson + ('\\"' + (key + ('\\":\\"' + (value + '\\",'))));
    }
    returnArgTableItemJson = lua_format.delete_last_char(returnArgTableItemJson);
    var returnArgTableJson = '{' + (returnArgTableItemJson + '}');
    var returnArgTable = json2table(returnArgTableJson);
    return returnArgTable;
};
lua_format.url_encode = function (decodeStr) {
    var decodeStr = formatNull(decodeStr);
    if (decodeStr != '') {
        return utility.escapeURI(decodeStr);
    } else {
        return '';
    }
};
lua_format.url_decode = function (encodeStr) {
    var encodeStr = formatNull(encodeStr);
    if (encodeStr != '') {
        return utility.unescapeURI(encodeStr);
    } else {
        return '';
    }
};
lua_format.base64_encode = function (decodeStr) {
    var decodeStr = formatNull(decodeStr);
    if (decodeStr != '') {
        return utility.base64Encode(decodeStr);
    } else {
        return '';
    }
};
lua_format.base64_decode = function (encodeStr) {
    var encodeStr = formatNull(encodeStr);
    if (encodeStr != '') {
        return utility.base64Decode(encodeStr);
    } else {
        return '';
    }
};
lua_format.arg_encode = function (decodeStr) {
    var base64Res = lua_format.base64_encode(decodeStr);
    var urlRes = lua_format.url_encode(base64Res);
    return urlRes;
};
lua_format.arg_decode = function (encodeStr) {
    var urlRes = lua_format.url_decode(encodeStr);
    var base64Res = lua_format.base64_decode(urlRes);
    return base64Res;
};
lua_format.reset_table = function (table, filterArg) {
    var table = formatNull(table);
    var filterArg = formatNull(filterArg);
    if (table != '') {
        for (var [key, value] in pairs(table)) {
            var filterRes = '';
            if (filterArg != '') {
                filterRes = formatNull(string.find(filterArg, key));
            }
            if (filterRes === '') {
                table[key] = '';
            }
        }
    }
};
lua_format.new_table_by_table = function (data_table) {
    var new_table = {};
    for (let i = 1; data_table.length; i++) {
        table.insert(new_table, data_table[i]);
    }
    return new_table;
};
lua_format.daysec_to_time = function (Arg) {
    var totalSec = vt('totalSec', Arg);
    if (totalSec != '') {
        var day = math.floor(totalSec / 3600 / 24);
        day = lua_format.zero_padding(day);
        var hour = math.floor(totalSec % (3600 * 24) / 3600);
        hour = lua_format.zero_padding(hour);
        var min = math.floor(totalSec % 3600 / 60);
        min = lua_format.zero_padding(min);
        var sec = math.floor(totalSec % 60);
        sec = lua_format.zero_padding(sec);
        var res = {
            day: day,
            hour: hour,
            min: min,
            sec: sec
        };
        return res;
    } else {
        return '';
    }
};
lua_format.zero_padding = function (num, paddings) {
    var num = tostring(formatNull(num, 0));
    var res = num;
    var numLen = string.len(num);
    var paddings = parseFloat(formatNull(paddings, 2));
    if (numLen < paddings) {
        res = '0' + num;
    }
    return res;
};
lua_format.reverse_seq_table = function (oldT) {
    var newT = {};
    var oldT = formatNull(oldT, {});
    var oldTCounts = oldT.length;
    for (let i = 1; oldTCounts; i++) {
        table.insert(newT, oldT[oldTCounts]);
        oldTCounts = oldTCounts - 1;
    }
    return newT;
};
lua_format.reverse_kv_table = function (oldT) {
    var newT = {};
    var newTTemp = {};
    var oldT = formatNull(oldT, {});
    var oldTCounts = 0;
    for (var [key, value] in pairs(oldT)) {
        oldTCounts = oldTCounts + 1;
    }
    for (var [key, value] in pairs(oldT)) {
        newTTemp[oldTCounts] = {
            key: key,
            value: value
        };
        oldTCounts = oldTCounts - 1;
    }
    for (let i = 1; newTTemp.length; i++) {
        var newTTempItem = newTTemp[i];
        var newTTempItemKey = vt('key', newTTempItem);
        var newTTempItemValue = vt('value', newTTempItem);
        newT[newTTempItemKey] = newTTempItemValue;
    }
    return newT;
};
lua_format.http_params_to_table = function (params) {
    var paramsTable = splitUtils(params, '&');
    t = {};
    for (let i = 1; paramsTable.length; i++) {
        var paramsStr = paramsTable[i];
        var paramsStrT = splitUtils(paramsStr, '=');
        var pKey = paramsStrT[1];
        var pValue = paramsStrT[2];
        t[pKey] = pValue;
    }
    return t;
};
lua_format.an2cn = function (anum) {
    return lua_format.simple_an2cn(anum);
};
lua_format.simple_an2cn = function (anum) {
    var anum = formatNull(anum, '0');
    var equalNum = parseFloat(anum);
    var res = '';
    if (equalNum === 0) {
        res = '零';
    } else if (equalNum === 1) {
        res = '一';
    } else if (equalNum === 2) {
        res = '二';
    } else if (equalNum === 3) {
        res = '三';
    } else if (equalNum === 4) {
        res = '四';
    } else if (equalNum === 5) {
        res = '五';
    } else if (equalNum === 6) {
        res = '六';
    } else if (equalNum === 7) {
        res = '七';
    } else if (equalNum === 8) {
        res = '八';
    } else if (equalNum === 9) {
        res = '九';
    } else if (equalNum === 10) {
        res = '十';
    } else {
        res = lua_format.complete_an2cn(equalNum);
    }
    return res;
};
var hzUnit = [
    '',
    '十',
    '百',
    '千',
    '万',
    '十',
    '百',
    '千',
    '亿',
    '十',
    '百',
    '千',
    '万',
    '十',
    '百',
    '千'
];
var hzNum = [
    '零',
    '一',
    '二',
    '三',
    '四',
    '五',
    '六',
    '七',
    '八',
    '九'
];
lua_format.complete_an2cn = function (szNum) {
    var szChMoney = '';
    var iLen = 0;
    var iNum = 0;
    var iAddZero = 0;
    if (null === parseFloat(szNum)) {
        return tostring(szNum);
    }
    iLen = string.len(szNum);
    if (iLen > 10 || iLen === 0 || parseFloat(szNum) < 0) {
        return tostring(szNum);
    }
    for (let i = 1; iLen; i++) {
        iNum = string.sub(szNum, i, i);
        if (iNum === 0 && i != iLen) {
            iAddZero = iAddZero + 1;
        } else {
            if (iAddZero > 0) {
                szChMoney = szChMoney + hzNum[1];
            }
            szChMoney = szChMoney + hzNum[iNum + 1];
            iAddZero = 0;
        }
        if (iAddZero < 4 && (0 === (iLen - i) % 4 || 0 != parseFloat(iNum))) {
            szChMoney = szChMoney + hzUnit[iLen - i + 1];
        }
    }
    return removeZero(szChMoney);
};
removeZero = function (num) {
    num = tostring(num);
    var szLen = string.len(num);
    var zero_num = 0;
    for (let i = szLen; 1; i+=undefined) {
        szNum = string.sub(num, i - 2, i);
        if (szNum === hzNum[1]) {
            zero_num = zero_num + 1;
        } else {
            break;
        }
    }
    num = string.sub(num, 1, szLen - zero_num * 3);
    szNum = string.sub(num, 1, 6);
    if (szNum === hzNum[2] + hzUnit[2]) {
        num = string.sub(num, 4, string.len(num));
    }
    return num;
};
lua_format.hide_str_tail = function (Arg) {
    var strContent = vt('strContent', Arg);
    if (strContent != '') {
        var showFirstCounts = vt('showFirstCounts', Arg, 0);
        showFirstCounts = parseFloat(showFirstCounts);
        var replaceWords = vt('replaceWords', Arg, '*');
        var strContentLength = ryt.getLengthByStr(strContent);
        var paddingCounts = strContentLength - 1;
        if (strContentLength > showFirstCounts) {
            var firstStr = lua_utils.strCut(strContent, showFirstCounts);
            var lastStr = '';
            for (let i = 1; paddingCounts; i++) {
                lastStr = lastStr + replaceWords;
            }
            strContent = firstStr + lastStr;
        }
    }
    return strContent;
};
lua_format.table_arg_pack = function (TableData) {
    var TableData = formatNull(TableData);
    var TableDataEncodeStr = lua_format.base64_encode(table2json(TableData));
    return TableDataEncodeStr;
};
lua_format.table_arg_unpack = function (TableDataEncodeStr) {
    var TableDataEncodeStr = formatNull(TableDataEncodeStr);
    var TableData = json2table(lua_format.base64_decode(TableDataEncodeStr));
    return TableData;
};
lua_format.num_up_ceil = function (Num, ceilNum) {
    var ceilNum = parseFloat(formatNull(ceilNum, 10));
    var Num = parseFloat(formatNull(Num, 0));
    for (let i = 1; 10; i++) {
        Num = Num + 1;
        if (Num % ceilNum === 0) {
            break;
        }
    }
    return Num;
};
lua_format.format_text_to_R_B = function (list) {
    var Char = '';
    var textType = 'N';
    var index = 0;
    var match = 'false';
    var strList = {};
    for (let i = 1; list.length + 1; i++) {
        Char = list[i];
        while (i <= list.length) {
            if (match === 'true') {
                if (i === index) {
                    var tempTable = {
                        type: textType,
                        text: Char
                    };
                    table.insert(strList, tempTable);
                    match = 'false';
                } else {
                    break;
                }
            } else {
                if (Char === 'R' || Char === 'B') {
                    index = i;
                    var tempChar = list[i] + list[i + 1];
                    if (tempChar === 'R{' || tempChar === 'B{') {
                        index = i + 2;
                        match = 'true';
                        if (tempChar === 'R{') {
                            textType = 'R';
                        } else {
                            textType = 'B';
                        }
                        break;
                    } else if (tempChar === 'RB' || tempChar === 'BR') {
                        tempChar = list[i] + (list[i + 1] + list[i + 2]);
                        if (tempChar === 'RB{' || tempChar === 'BR{') {
                            index = i + 3;
                            match = 'true';
                            textType = 'RB';
                            break;
                        } else {
                            match = 'false';
                            var tempTable = {
                                type: textType,
                                text: Char
                            };
                            table.insert(strList, tempTable);
                        }
                    } else {
                        match = 'false';
                        var tempTable = {
                            type: textType,
                            text: Char
                        };
                        table.insert(strList, tempTable);
                    }
                } else if (Char === '}') {
                    match = 'false';
                    textType = 'N';
                    index = i + 1;
                    break;
                } else {
                    var tempTable = {
                        type: textType,
                        text: Char
                    };
                    table.insert(strList, tempTable);
                    match = 'false';
                }
            }
            break;
        }
    }
    return strList;
};
lua_format.split_str = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        invoke_trancode_noloading('jjbx_service', 'app_service', {
            TranCode: 'strSplit',
            str: ReqParams['str']
        }, lua_format.split_str, {
            labelStyleCss: ReqParams['labelStyleCss'],
            divStyleCss: ReqParams['divStyleCss'],
            elementName: ReqParams['elementName'],
            isEnter: vt('isEnter', ReqParams, 'true')
        }, all_callback, { CloseLoading: 'false' });
    } else {
        close_loading();
        var res = json2table(ResParams['responseBody']);
        var labelStyleCss = ResParams['labelStyleCss'];
        var divStyleCss = ResParams['divStyleCss'];
        var list = lua_format.format_text_to_R_B(res['list']);
        var htmlContent = '';
        for (var [key, value] in pairs(list)) {
            var type = value['type'];
            var textValue = value['text'];
            var isEnter = vt('isEnter', ResParams, 'true');
            if (value['type'] === 'N') {
                if (textValue === '/' && isEnter === 'true') {
                    htmlContent = htmlContent + '<div style=\'height: 1px;\' border=\'0\' />';
                } else {
                    htmlContent = htmlContent + ('<label class=\'label_css\' ' + (labelStyleCss + (' value=\'' + (textValue + '\' />'))));
                }
            } else if (value['type'] === 'R') {
                htmlContent = htmlContent + ('<label class=\'label_red_css\' ' + (labelStyleCss + (' value=\'' + (textValue + '\' />'))));
            } else if (value['type'] === 'B') {
                htmlContent = htmlContent + ('<label class=\'label_bold_css\' ' + (labelStyleCss + (' value=\'' + (textValue + '\' />'))));
            } else if (value['type'] === 'RB') {
                htmlContent = htmlContent + ('<label class=\'label_red_bold_css\' ' + (labelStyleCss + (' value=\'' + (textValue + '\' />'))));
            }
        }
        var elementName = ResParams['elementName'];
        htmlContent = '<div ' + (divStyleCss + (' name=\'' + (elementName + ('\' border=\'0\'>' + (htmlContent + '</div>')))));
        document.getElementsByName(elementName)[1].setInnerHTML(htmlContent);
        page_reload();
    }
};
module.exports = { lua_format: lua_format };