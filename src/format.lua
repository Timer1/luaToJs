--[[格式化]]

lua_format = {};

--[[格式化卡号]]
function formatHideAccountNo(account)
    local account1 = string.sub(account,1,6);
    local account2 = string.sub(account,string.len(account)-3,string.len(account));
    local account3 = account1.."****"..account2;
    return account3;
end;

--[[卡号显示格式化]]
function formatShowAccountNo(account)
    local value1 = string.sub(account,1,4);
    local value2 = string.sub(account,5,8);
    local value3 = string.sub(account,9,12);
    local value4 = string.sub(account,13,16);
    local value5 = string.sub(account,17,19);
    local accountValue = value1 .. "    " ..value2.."    "..value3.."    "..value4.."    "..value5;
    return accountValue;
end;

--[[手机号掩码]]
function lua_format.hide_mobile_no(mobileNo)
    local mobileNo = formatNull(mobileNo);
    if mobileNo ~= "" then
        local value1 = string.sub(mobileNo,1,3);
        local value2 = string.sub(mobileNo,8,11);
        local hideMobileNo = value1 .. "****" ..value2;
        return hideMobileNo;
    else
        return "";
    end;
end;

--[[格式化利率]]
function formatYield(yield)
    local yield = yield*100;
    local index = string.find(yield,"%.")
    if index == nil then
        print(yield..".0000");
    else
        local oldYieldLen = string.len(string.sub(yield,index+1,string.len(yield)))
        if tonumber(oldYieldLen) == 1 then
            yield = yield.."000";
            return yield;
        elseif tonumber(oldYieldLen) == 2 then
            yield = yield.."00";
            return yield;
        elseif tonumber(oldYieldLen) == 3 then
            yield = yield.."0";
            return yield;
        end;
        return yield;
    end;
end;

--[[千分位格式化金额]]
function formatMoney(money)
    local money = formatNull(money);
    if formatNull(tonumber(money)) == "" then
        return "0.00";
    else
        local resArr = {};
        local resMoney = "";
        local integerMoney1 = "";
        local integerMoney2 = "";
        if money == "" or money == nil then
            resMoney = ",0.00";
        else
            integerMoney1 = string.sub(money,0,1);
            if integerMoney1 =="-" then 
                integerMoney2 = string.sub(money,2,string.len(money));
            else
                integerMoney1 = "";
                integerMoney2 = money;
            end;
            local moneyf = string.format("%.2f",integerMoney2);
            local integerMoney = string.sub(moneyf,0,string.len(moneyf)-3);
            local decimalMoney = string.sub(moneyf,string.len(moneyf)-2,string.len(moneyf));
            local integerMoneyLen = string.len(integerMoney);
            local graphNum = math.floor(integerMoneyLen/3);
            if graphNum ~= integerMoneyLen/3 then 
                graphNum = graphNum + 1;
            end;
            if integerMoneyLen < 4 then
                resMoney = ","..integerMoney;
            else
                for i=1,graphNum do
                    if i~=graphNum then
                        resArr[i] = string.sub(integerMoney,string.len(integerMoney)-3*i+1,string.len(integerMoney)-3*(i-1));
                    else
                        resArr[i] = string.sub(integerMoney,0,string.len(integerMoney)-3*(i-1));
                    end;
                end;
                for i=graphNum,1,-1 do
                    resMoney = resMoney..","..resArr[i];
                end;
            end;
            resMoney = resMoney..decimalMoney;
        end;
        return integerMoney1..string.sub(resMoney,2,string.len(resMoney));
    end;
end;

--[[处理值为null/nil的情况,当str为null/nil时,返回默认值defValue]]
function formatNull(str, defValue)
    if defValue=="null" or defValue==null or defValue==nil or defValue=="" then
        defValue = ""
    end;

    if str=="null" or str==null or str==nil or str=="" or str=="undefined" then
        return defValue;
    else
        return str;
    end;
end;

--[[处理特殊字符，防止在拼接json的时候客户端获取的数据异常]]
function formatSpecialChar(str)
    if formatNull(str) == "" then 
        return "";
    else
        str = string.gsub(str,"\n","");
        str = string.gsub(str,"\t","");
        str = string.gsub(str,"<","");
        str = string.gsub(str,">","");
        str = string.gsub(str,"{","%{");
        str = string.gsub(str,"}","%}");
        str = string.gsub(str,"\\","\\\\");
        str = string.gsub(str,"\"","\\\"");
        return str;
    end;
end;

--[[根据年月日转换星期几]]
function dateFormatWeek(param)
    local param = formatNull(param);
    if param == "" then
        return "";
    else
        local y,m,d = string.match(param,"(%d%d%d%d)-(%d%d)-(%d%d)");
        local t = os.time({["year"]=y,["month"]=m,["day"]=d});
        local w = os.date("*t",t).wday;
        if tonumber(w) == 1 then
            return "周日";
        elseif tonumber(w) == 2 then
            return "周一";
        elseif tonumber(w) == 3 then
            return "周二";
        elseif tonumber(w) == 4 then
            return "周三";
        elseif tonumber(w) == 5 then
            return "周四";
        elseif tonumber(w) == 6 then
            return "周五";
        else
            return "周六";
        end;
    end;
end;

--[[时间格式化]]
function formatdate(flag,dateTime)
    if formatNull(dateTime) == "" then
        return "";
    else
        if flag == 1 then
            dateTime = os.date("%Y.%m.%d",dateTime/1000);
        elseif flag == 2 then
            dateTime = os.date("%Y-%m-%d",dateTime/1000);
        elseif flag == 3 then
            dateTime = os.date("%m月%d日",dateTime/1000);
        elseif flag == 4 then
            dateTime = os.date("%H:%M",dateTime/1000);
        elseif flag == 5 then
            dateTime = os.date("%Y%m%d",dateTime/1000);
        end;
        return dateTime;
    end;
end;

--[[
    日期格式化
    yyyy年mm月dd日 -> yyyy-mm-dd
]]
function date_delete_CN(date)
    local newDate = "";
    if string.len(date) == 17 then
        local y = string.sub(date,1,4);
        local m = string.sub(date,8,9);
        local d = string.sub(date,13,14);
        newDate = y.."-"..m.."-"..d;
    else
        newDate = date;
    end;
    return newDate;
end;

--[[
    日期格式化
    yyyy.mm.dd -> yyyy年mm月dd日
]]
function date_add_CN(date)
    local newDate = "";
    if string.len(date) == 10 then
        local y = string.sub(date,1,4);
        local m = string.sub(date,6,7);
        local d = string.sub(date,9,10);
        newDate = y.."年"..m.."月"..d.."日";
    else
        newDate = date;
    end;
    return newDate;
end;

--[[小数点保留]]
function float(data,lenAfterPoint)
    local data = formatNull(data);
    --默认保留两位
    local len = formatNull(lenAfterPoint,2);
    local res = tonumber(string.format("%."..len.."f",data));
    return res;
end;

--[[将json字符串解析为数组结构]]
function json2table(jsonData)
    local jsonData = formatNull(jsonData);
    local tableRes = {};
    tableRes = formatNull(json:objectFromJSON(jsonData));
    return tableRes;
end;

--[[将table类型的数组结构反向组装成json字符串]]
function table2json(tableData)
    local table = formatNull(tableData);
    local jsonRes = "";
    jsonRes = formatNull(json:jsonFromObject(tableData));
    return jsonRes;
end;

--[[
    遍历table类型的参数并整理成打印信息（支持遍历子节点）
    tableArg  : table类型的参数
    showTable : 子节点为table时是否遍历，默认开启遍历
    filtArg   : 过滤的参数（"name,phoneNo"，这样配置，会过滤掉这些内容的显示）
]]
function foreach_arg2print(tableArg, showTable, filtArg)
    --debug_alert("foreach_arg2print");
    local tableArg = formatNull(tableArg);
    local filtArg = formatNull(filtArg);

    if tableArg ~= "" then
        if type(tableArg) == "table" then
            local showTable = formatNull(showTable,"true");
            local tableValueMsg = do_foreach_arg2print(tableArg, showTable, filtArg, "", "");
            return tableValueMsg;
        else
            return tableArg;
        end;
    else
        return "null table arg";
    end;
end;
function do_foreach_arg2print(tableArg, showTable, filtArg, returnValue, parentDataType)
    --[[debug_alert(
        "do_foreach_arg2print\n"..
        "showTable : "..showTable.."\n"..
        "filtArg : "..filtArg.."\n"..
        "returnValue : "..returnValue.."\n"..
        "parentDataType : "..parentDataType.."\n"..
        ""
    );]]

    for key,value in pairs(tableArg) do
        --键
        local showKey = tostring(formatNull(key));
        --debug_alert(showKey);
        --值
        local showValue = "";
        --追加的返回信息
        local addReturnValue = "";

        --是否过滤
        local DoFilt = "false";
        if filtArg~="" and showKey~="" then
            if string.find(filtArg,showKey) then
                DoFilt = "true";
            end;
        end;
        --debug_alert(DoFilt);

        local ValueType = type(value);
        --debug_alert(ValueType);
        
        if DoFilt == "true" then
            --过滤掉
        else
            if ValueType == "table" then
                if showTable == "true" then
                    --table类型再执行递归
                    local tableValueMsg = do_foreach_arg2print(value, showTable, filtArg, "", "table");
                    if type(value[1]) == "table" then
                        showValue = "(table类型)"..tostring(tableValueMsg);
                        addReturnValue =
                            showKey.." : "..showValue..
                            "";
                    else
                        showValue = "(table类型)\n"..tostring(tableValueMsg);
                        addReturnValue =
                            showKey.." : "..showValue..
                            "";
                    end;
                else
                    showValue = "(table不显示)";

                    addReturnValue =
                        showKey.." : "..showValue.."\n"..
                        "";
                end;
            else
                showValue = tostring(formatNull(value));
                if parentDataType == "table" then
                    addReturnValue =
                        showKey.." : "..showValue.."\n"..
                        "";
                else
                    addReturnValue =
                        showKey.." : "..tostring(showValue).."\n"..
                        "－－－－－－－－－－－－－－－"..
                        "";
                end;
            end;
        end;

        if key ~= 1 then
            returnValue = returnValue.."\n"..addReturnValue;
        else
            returnValue = returnValue..addReturnValue;
        end;
    end;

    return returnValue;
end;

--[[table取参]]
function vt(key,table,defaultValue)
    local table = formatNull(table);
    local key = formatNull(key);
    if table~="" or key~="" then
        local value = formatNull(table[key],defaultValue);
        return value;
    else
        return "";
    end;
end;

--[[删除字符串的最后一位]]
function lua_format.delete_last_char(str)
    local str = formatNull(str);
    if str == "" then
        return "";
    else
        return string.sub(str, 1, string.len(str)-1);
    end;
end;

--[[sting转fun]]
function lua_format.str2fun(str)
    local str = formatNull(str);
    local fun = "";
    if str ~= "" then
        --根据.符号做切割
        local splitIndex = formatNull(string.find(str,"%."),0);
        if splitIndex > 0 then
            --分包存放的函数从对应的包里取
            local funTable = splitUtils(str,"%.");
            if #funTable == 2 then
                local funPack = funTable[1];
                local funName = funTable[2];

                --[[debug_alert(
                    "函数拆分\n"..
                    "包名 : "..funPack.."\n"..
                    "函数 : "..funName.."\n"..
                    ""
                );]]

                fun = _G[funPack][funName];
            else
                debug_alert("函数分包查找异常");
                return;
            end;
        else
            --没有分包存放的函数直接从全局里取
            fun = _G[str];
        end;
        return fun;
    else
        debug_alert("函数参数为空");
        return;
    end;
end;

--[[sting转参数]]
function lua_format.str2arg(str)
    local str = formatNull(str);
    local arg = "";
    if str ~= "" then
        arg = _G[str];
        return arg;
    else
        debug_alert("参数为空");
        return;
    end;
end;

--[[初始化table格式的参数列表]]
function lua_format.init_table_params(table)
    local table = formatNull(table);
    if table ~= "" then
        for key,value in pairs(table) do
            table[key] = "";
        end;
    end;
end;

--[[url参数转换]]
function lua_format.url_arg2table(url)
    local url = formatNull(url);
    local splitIndex = string.find(url,"?");
    --debug_alert("url切割位置 : "..tostring(splitIndex));

    local callbackArg = string.sub(url,splitIndex+1,string.len(url));
    --debug_alert("原始参数 : "..callbackArg);

    local argTable = splitUtils(callbackArg,"&");
    --debug_alert("argTable : "..foreach_arg2print(argTable));

    local returnArgTableItemJson = "";
    for i=1,#argTable do
        local argItem = formatNull(argTable[i]);
        local argSplitIndex = string.find(argItem,"=");
        local key = string.sub(argItem,1,argSplitIndex-1);
        local value = string.sub(argItem,argSplitIndex+1,string.len(argItem));

        --[[debug_alert(
            "参数 : "..argItem.."\n"..
            "切割位置 : "..tostring(argSplitIndex).."\n"..
            "key : "..key.."\n"..
            "value : "..value.."\n"..
            ""
        );]]

        returnArgTableItemJson = returnArgTableItemJson.."\""..key.."\":\""..value.."\",";
    end;

    returnArgTableItemJson = lua_format.delete_last_char(returnArgTableItemJson);
    local returnArgTableJson = "{"..
        returnArgTableItemJson..
    "}";
    --debug_alert("returnArgTableJson : "..returnArgTableJson);

    local returnArgTable = json2table(returnArgTableJson);
    --debug_alert("返回table : "..foreach_arg2print(returnArgTable));

    return returnArgTable;
end;

--[[Url参数编码]]
function lua_format.url_encode(decodeStr)
    local decodeStr = formatNull(decodeStr);
    if decodeStr ~= "" then
        return utility:escapeURI(decodeStr);
    else
        return "";
    end;
end;

--[[Url参数解码]]
function lua_format.url_decode(encodeStr)
    local encodeStr = formatNull(encodeStr);
    if encodeStr ~= "" then
        return utility:unescapeURI(encodeStr);
    else
        return "";
    end;
end;

--[[Base64编码]]
function lua_format.base64_encode(decodeStr)
    local decodeStr = formatNull(decodeStr);
    if decodeStr ~= "" then
        return utility:base64Encode(decodeStr);
    else
        return "";
    end;
end;

--[[Base64解码]]
function lua_format.base64_decode(encodeStr)
    local encodeStr = formatNull(encodeStr);
    if encodeStr ~= "" then
        return utility:base64Decode(encodeStr);
    else
        return "";
    end;
end;

--[[参数编码]]
function lua_format.arg_encode(decodeStr)
    local base64Res = lua_format.base64_encode(decodeStr);
    local urlRes = lua_format.url_encode(base64Res);

    --[[debug_alert(
        "参数编码\n"..
        "decodeStr : "..decodeStr.."\n"..
        "base64Res : "..base64Res.."\n"..
        "urlRes : "..urlRes.."\n"..
        ""
    );]]

    return urlRes;
end;

--[[参数解码]]
function lua_format.arg_decode(encodeStr)
    local urlRes = lua_format.url_decode(encodeStr);
    local base64Res = lua_format.base64_decode(urlRes);

    --[[debug_alert(
        "参数解码\n"..
        "encodeStr : "..encodeStr.."\n"..
        "urlRes : "..urlRes.."\n"..
        "base64Res : "..base64Res.."\n"..
        ""
    );]]

    return base64Res;
end;

--[[重置table数据 filterArg为需要过滤的参数，用,分隔]]
function lua_format.reset_table(table,filterArg)
    local table = formatNull(table);
    local filterArg = formatNull(filterArg);

    if table ~= "" then
        for key,value in pairs(table) do
            local filterRes = "";
            if filterArg ~= "" then
                filterRes = formatNull(string.find(filterArg,key));
            end;

            if filterRes == "" then
                table[key] = "";
            end;

            --[[debug_alert(
                "clear_table\n"..
                "key : "..key.."\n"..
                "value : "..value.."\n"..
                "filterArg : "..filterArg.."\n"..
                "filterRes : "..filterRes.."\n"..
                ""
            );]]
        end;
    end;
end;

--[[用当前table的数据新建一个table对象]]
function lua_format.new_table_by_table(data_table)
    --声明新对象
    local new_table = {};

    --循环将table的内容插入至new_table
    for i=1,#data_table do
        table.insert(new_table,data_table[i]);
    end;

    --[[debug_alert(
        "用当前table的数据新建一个table对象\n"..
        "table长度 : "..tostring(#table).."\n"..
        "data_table数据 : "..foreach_arg2print(data_table).."\n"..
        "new_table长度 : "..tostring(#new_table).."\n"..
        ""
    );]]

    --返回new_table
    return new_table;
end;

--[[当前时间秒转具体信息]]
function lua_format.daysec_to_time(Arg)
    local totalSec = vt("totalSec",Arg);
   --debug_alert("当前时间秒转具体信息"..foreach_arg2print(Arg));

    if totalSec ~= "" then
        local day = math.floor(totalSec/3600/24);
        day = lua_format.zero_padding(day);
        local hour = math.floor(totalSec%(3600*24)/3600);
        hour = lua_format.zero_padding(hour);
        local min = math.floor(totalSec%3600/60);
        min = lua_format.zero_padding(min);
        local sec = math.floor(totalSec%60);
        sec = lua_format.zero_padding(sec);

        local res = {
            day=day,
            hour=hour,
            min=min,
            sec=sec
        };
        --debug_alert("返回时间信息"..foreach_arg2print(res));
        return res;
    else
        return "";
    end;
end;

--[[数字0填充]]
function lua_format.zero_padding(num,paddings)
    local num = tostring(formatNull(num,0));
    local res = num;
    local numLen = string.len(num);
    local paddings = tonumber(formatNull(paddings,2));
    if numLen < paddings then
        res = "0"..num;
    end;

    --[[debug_alert(
        "数字0填充\n"..
        "num : "..num.."\n"..
        "numLen : "..numLen.."\n"..
        "paddings : "..paddings.."\n"..
        "res : "..res.."\n"..
        ""
    );]]

    return res;
end;

--[[序列式table反转]]
function lua_format.reverse_seq_table(oldT)
    --debug_alert(foreach_arg2print(oldT));
    local newT = {};
    local oldT = formatNull(oldT,{});
    local oldTCounts = #oldT;
    for i=1,oldTCounts do
        table.insert(newT,oldT[oldTCounts]);
        oldTCounts = oldTCounts-1;
    end;
    return newT;
end;

--[[key value table反转]]
function lua_format.reverse_kv_table(oldT)
    --debug_alert(foreach_arg2print(oldT));
    local newT = {};
    local newTTemp = {};
    local oldT = formatNull(oldT,{});
    local oldTCounts = 0;

    --算长度
    for key,value in pairs(oldT) do
        oldTCounts = oldTCounts+1;
    end;
    --debug_alert(oldTCounts);

    --按序列建中转table
    for key,value in pairs(oldT) do
        newTTemp[oldTCounts] = {
            key=key,
            value=value
        };
        --倒着存
        oldTCounts = oldTCounts-1;
    end;

    --组装key valuetable
    for i=1, #newTTemp do
        local newTTempItem = newTTemp[i];
        local newTTempItemKey = vt("key",newTTempItem);
        local newTTempItemValue = vt("value",newTTempItem);
        newT[newTTempItemKey] = newTTempItemValue;
    end;

    --debug_alert(foreach_arg2print(newTTemp));
    --debug_alert(foreach_arg2print(newT));

    return newT;
end;

--[[Http参数转table]]
function lua_format.http_params_to_table(params)
    local paramsTable = splitUtils(params,"&");
    --debug_alert("paramsTable\n"..foreach_arg2print(paramsTable));
    t = {};
    for i=1,#paramsTable do
        local paramsStr = paramsTable[i];
        local paramsStrT = splitUtils(paramsStr,"=");
        local pKey = paramsStrT[1];
        local pValue = paramsStrT[2];
        t[pKey] = pValue;
    end;
    return t;
end;

--[[阿拉伯数字转汉字]]
function lua_format.an2cn(anum)
    return lua_format.simple_an2cn(anum);
end;

--[[阿拉伯数字转汉字（简化版）]]
function lua_format.simple_an2cn(anum)
    local anum = formatNull(anum,"0");
    local equalNum = tonumber(anum);
    local res = "";
    if     equalNum == 0 then res = "零";
    elseif equalNum == 1 then res = "一";
    elseif equalNum == 2 then res = "二";
    elseif equalNum == 3 then res = "三";
    elseif equalNum == 4 then res = "四";
    elseif equalNum == 5 then res = "五";
    elseif equalNum == 6 then res = "六";
    elseif equalNum == 7 then res = "七";
    elseif equalNum == 8 then res = "八";
    elseif equalNum == 9 then res = "九";
    elseif equalNum == 10 then res = "十";
    else
        --其余数字走完整流程
        res = lua_format.complete_an2cn(equalNum);
    end;

    return res;
end;

local hzUnit = {"", "十", "百", "千", "万", "十", "百", "千", "亿","十", "百", "千", "万", "十", "百", "千"};
local hzNum = {"零", "一", "二", "三", "四", "五", "六", "七", "八", "九"};

--[[阿拉伯数字转汉字（完整版）]]
function lua_format.complete_an2cn(szNum)
    local szChMoney = "";
    local iLen = 0;
    local iNum = 0;
    local iAddZero = 0;
    if nil == tonumber(szNum) then
        return tostring(szNum);
    end;
    iLen =string.len(szNum);
    if iLen > 10 or iLen == 0 or tonumber(szNum) < 0 then
        return tostring(szNum);
    end;
    for i = 1, iLen do
        iNum = string.sub(szNum,i,i);
        if iNum == 0 and i ~= iLen then
            iAddZero = iAddZero + 1;
        else
            if iAddZero > 0 then
                szChMoney = szChMoney..hzNum[1];
            end;
            --转换为相应的数字
            szChMoney = szChMoney..hzNum[iNum + 1];
            iAddZero = 0;
        end;
        if (iAddZero < 4) and (0 == (iLen - i) % 4 or 0 ~= tonumber(iNum)) then
            szChMoney = szChMoney..hzUnit[iLen-i+1];
        end;
    end;
    return removeZero(szChMoney);
end;

--[[去掉末尾多余的零]]
function removeZero(num)
    num = tostring(num);
    local szLen = string.len(num);
    local zero_num = 0;
    for i = szLen, 1, -3 do
        szNum = string.sub(num,i-2,i);
        if szNum == hzNum[1] then
            zero_num = zero_num + 1;
        else
            break
        end;
    end;
    num = string.sub(num, 1,szLen - zero_num * 3);
    szNum = string.sub(num, 1,6);
    if szNum == hzNum[2]..hzUnit[2] then
        num = string.sub(num, 4, string.len(num));
    end;
    return num;
end;

--[[字符串末尾隐藏]]
function lua_format.hide_str_tail(Arg)
    local strContent = vt("strContent",Arg);
    if strContent ~= "" then
        local showFirstCounts = vt("showFirstCounts",Arg,0);
        showFirstCounts = tonumber(showFirstCounts);
        local replaceWords = vt("replaceWords",Arg,"*");

        local strContentLength = ryt:getLengthByStr(strContent);
        local paddingCounts = strContentLength-1;
        if strContentLength > showFirstCounts then
            --截取
            local firstStr = lua_utils.strCut(strContent,showFirstCounts);
            local lastStr = "";
            --按长度补全
            for i=1,paddingCounts do
                lastStr = lastStr..replaceWords;
            end;
            strContent = firstStr..lastStr;
        end;
    end;
    return strContent;
end;

--[[table参数封包]]
function lua_format.table_arg_pack(TableData)
    local TableData = formatNull(TableData);
    local TableDataEncodeStr = lua_format.base64_encode(table2json(TableData));
    return TableDataEncodeStr;
end;

--[[table参数解包]]
function lua_format.table_arg_unpack(TableDataEncodeStr)
    local TableDataEncodeStr = formatNull(TableDataEncodeStr);
    local TableData = json2table(lua_format.base64_decode(TableDataEncodeStr));
    return TableData;
end;

--[[数值向上按倍数取整]]
function lua_format.num_up_ceil(Num,ceilNum)
    --默认向10取整
    local ceilNum = tonumber(formatNull(ceilNum,10));
    local Num = tonumber(formatNull(Num,0));
    for i=1,10 do
        Num = Num + 1;
        if Num%ceilNum == 0 then
            break
        end;
    end;
    return Num;
end;

 function lua_format.format_text_to_R_B(list)
    --截取字符
    local Char = "";
    --记录字符类型（R：标红、B：加粗、RB：加粗标红）
    local textType ="N";
    --记录取值下标
    local index = 0;
    --是否匹配规则
    local match = "false";
    local strList = {};
    --截取字符，到最后一位时停止循环
    for i=1,#list+1 do
        --从上一次记录的位置开始截取字符
        Char = list[i];
        --这里用while循环来模拟continue，检测当前字符是否为规则匹配符，如是匹配符这跳过当前字符，进入下一个字符
        while i<=#list do
            --规则匹配的情况下，判断是否到达取值下标，如到达下标，则存储当前下标的值，且清空匹配状态
            if match == "true" then
                if i == index then
                    --存储当前位置的值
                    local tempTable = {
                        type = textType,
                        text = Char
                    };
                    --存储已匹配的字符
                    table.insert(strList,tempTable);
                    match = "false";
                else
                    --未达到指定下标，跳出当前字符，进入下一个字符逻辑
                    break
                end;
            else
                --检测到规则字符
                if Char == "R" or Char == "B" then
                    index = i;
                    local tempChar = list[i]..list[i+1];
                    --判断是否符合规则还是单纯只是个字母
                    if tempChar == "R{" or tempChar == "B{" then
                        --记录取值下标
                        index = i + 2;
                        match = "true";
                        --标注字符样式
                        if tempChar == "R{" then
                            textType = "R";
                        else
                            textType = "B";
                        end;
                        --当前为规则匹配符，无需再做逻辑处理
                        break
                    elseif tempChar == "RB" or tempChar == "BR" then
                        tempChar = list[i]..list[i+1]..list[i+2];
                        --判断是否符合规则还是单纯只是个字母
                        if tempChar == "RB{" or tempChar == "BR{" then
                            --记录取值下标
                            index = i + 3;
                            match = "true";
                            --标注字符样式
                            textType = "RB";
                            --当前为规则匹配符，无需再做逻辑处理
                            break
                        else
                            match = "false";
                            --单纯只是个字母时存储字符
                            --存储当前位置的值
                            local tempTable = {
                                type = textType,
                                text = Char
                            };
                            table.insert(strList,tempTable);
                        end;
                    else
                        match = "false";
                        --单纯只是个字母时存储字符
                        local tempTable = {
                            type = textType,
                            text = Char
                        };
                        table.insert(strList,tempTable);
                    end;
                elseif Char == "}" then
                    --检测到结束标记
                    match="false";
                    --清空字符样式
                    textType = "N";
                    --记录取值下标
                    index = i + 1;
                    --当前为规则匹配符，无需再做逻辑处理
                    break
                else
                    --存储当前位置的值
                    local tempTable = {
                        type = textType,
                        text = Char
                    };
                    table.insert(strList,tempTable);
                    match = "false";
                end;
            end;
            break
        end;
    end;
    return strList;
end;

--使用ewp服务器做字符截取处理
function lua_format.split_str(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        invoke_trancode_noloading(
            "jjbx_service",
            "app_service",
            {
                TranCode="strSplit",
                str = ReqParams["str"]
            },
            lua_format.split_str,
            {
                labelStyleCss = ReqParams["labelStyleCss"],
                divStyleCss = ReqParams["divStyleCss"],
                elementName = ReqParams["elementName"],
                isEnter=vt("isEnter",ReqParams,"true")
            },
            all_callback,
            {CloseLoading="false"}
        );
    else
        close_loading();
        local res = json2table(ResParams["responseBody"]);
        --debug_alert("响应\n"..foreach_arg2print(res));

        --补充样式
        local labelStyleCss = ResParams["labelStyleCss"];
        local divStyleCss = ResParams["divStyleCss"];
        --处理字符
        local list = lua_format.format_text_to_R_B(res["list"]);
        --渲染html
        local htmlContent = "";
        for key,value in pairs(list) do
            local type = value["type"];
            local textValue = value["text"];
            --是否执行/换行操作
            local isEnter = vt("isEnter",ResParams,"true");
            if value["type"] == "N" then
                if textValue == "/" and isEnter == "true" then
                    htmlContent = htmlContent.."<div style='height: 1px;' border='0' />";
                else
                    htmlContent = htmlContent.."<label class='label_css' "..labelStyleCss.." value='"..textValue.."' />";
                end;
            elseif value["type"] == "R" then
                htmlContent = htmlContent.."<label class='label_red_css' "..labelStyleCss.." value='"..textValue.."' />";
            elseif value["type"] == "B" then
                htmlContent = htmlContent.."<label class='label_bold_css' "..labelStyleCss.." value='"..textValue.."' />";
            elseif value["type"] == "RB" then
                htmlContent = htmlContent.."<label class='label_red_bold_css' "..labelStyleCss.." value='"..textValue.."' />";
            end;
        end;
        local elementName = ResParams["elementName"];
        htmlContent = "<div "..divStyleCss.." name='"..elementName.."' border='0'>"..htmlContent.."</div>";
        document:getElementsByName(elementName)[1]:setInnerHTML(htmlContent);
        page_reload();
    end;
end;