--[[公共函数]]

lua_utils = {};

--[[字符串分割函数]]
function splitUtils(str,separator)
    local nFindStartIndex = 1;
    local nSplitIndex = 1;
    local nSplitArr = {};
    while true do
        local nFindLastIndex = string.find(str,separator,nFindStartIndex);
        if not nFindLastIndex then 
            nSplitArr[nSplitIndex] = string.sub(str,nFindStartIndex,string.len(str));
            break
        end;
        nSplitArr[nSplitIndex] = string.sub(str,nFindStartIndex,nFindLastIndex-1);
        --通配符不作为长度计算 
        nFindStartIndex = nFindLastIndex + string.len(string.gsub(separator,"%%",""));
        nSplitIndex = nSplitIndex + 1;
    end;
    return nSplitArr;
end;

--[[
    将字符串转换成table
    "a=1&b=2&c=3" -> {a=1,b=2,c=3}
]]
function string_to_table(params,concatstr)
    local concatstr = formatNull(concatstr, "&");
    t = {};
    for k,v in string.gmatch(params,"(%w+)=([^%"..concatstr.."]+)") do
        --table.insert(t,v);
        t[k] = v;
    end;
    return t;
end;

--[[table转string]]
function tableToString(tab)
    local str = "";
    if tab == nil then
        return str;
    end;
    for i=1,#tab do
        if i ~= 1 then
            str = str.."#";
        end;
        str = str..i.."="..tab[i];
    end;
    return str;
end;

--[[
    timestamp: 时间戳
    resultType:返回的数据类型
    date: 返回的数据类型为日期  YYYY-MM-DD
    time：返回的数据类型为日期+时间 YYYY-MM-DD HH:MM:SS
]]
function timestamp_to_date(timestamp,type)
    local dateTime = "";
    if timestamp == "" or timestamp == null or timestamp == nil or timestamp == "nil" then
        return "";
    else
        if type == "date" then
            dateTime = os.date("%Y-%m-%d",timestamp/1000);
            return dateTime;
        elseif type == "time" then
            dateTime = os.date("%Y-%m-%d  %H:%M:%S",timestamp/1000);
            return dateTime;
        end;
    end;
end;

--[[把日期时间字符串转换成对应时间秒数]]
function to_date_timestamp(date)
    local Y = string.sub(date,1,4);
    local M = string.sub(date,6,7);
    local D = string.sub(date,9,10);
    local timestamp = os.time{year = Y, month = M, day = D, hour = 00, min = 00, sec = 00};
    return timestamp;
end;

--[[
    将字符串设置为指定长度,超过的长度用...代替
    str:需要设置长度的字符串,len:需要设置的字符串长度
]]
function cutStr(str,len)
    return jjbx_utils_setStringLength(str,len);
end;
function jjbx_utils_setStringLength(str,len)
    if formatNull(str) ~= "" then
        local elementLen = ryt:getLengthByStr(str);
        if elementLen > tonumber(len) then
            return ryt:getSubstringValue(str,0,tonumber(len)).."...";
        else
            return str;
        end;
    else
        return "";
    end;
end;

--[[字符串切割]]
function lua_utils.strCut(str,len)
    if formatNull(str) ~= "" then
        local elementLen = ryt:getLengthByStr(str);
        if elementLen > tonumber(len) then
            return ryt:getSubstringValue(str,0,tonumber(len));
        else
            return str;
        end;
    else
        return "";
    end;
end;

--[[毫秒转换hh:mm:ss]]
function millisecondTotime(timestamp)
    local stopTime = tonumber(timestamp);
    local hours = (stopTime-stopTime%(1000*60*60))/(1000*60*60);
    local minmills = stopTime%(1000*60*60);
    local minutes = (minmills-minmills%(1000*60))/(1000*60);
    local seconds,seconds2 = math.modf(minmills%(1000*60)/1000);
    local times = "";
    if minutes < 10 then
        minutes = "0"..minutes;
    end;
    if seconds < 10 then
        seconds = "0"..seconds;
    end;
    if hours < 10 then
        hours = "0"..hours;
    end;
    times = hours..":"..minutes..":"..seconds;
    return times;
end;

--[[调整字符串长度]]
function adaptStringLength(str,length)
    local res = str;
    if #str > length then
        res = string.sub(str,0,length).."...";
    end;
    return res;
end;

--[[获取含有中文的字符串长度]]
function getStringCharCount(str)
    local charCount = ryt:getLengthByStr(str);
    return charCount;
    --[[local lenInByte = #str
    local i = 1
    while (i <= lenInByte)
        do
            local curByte = string.byte(str, i)
            local byteCount = 1;
            if curByte > 0 and curByte <= 127 then
                byteCount = 1                                               --1字节字符
            elseif curByte >= 192 and curByte < 223 then
                byteCount = 2                                               --双字节字符
            elseif curByte >= 224 and curByte < 239 then
                byteCount = 3                                               --汉字
            elseif curByte >= 240 and curByte <= 247 then
                byteCount = 4                                               --4字节字符
            end

            local char = string.sub(str, i, i + byteCount - 1)
            i = i + byteCount                                               -- 重置下一字节的索引
            charCount = charCount + 1                                       -- 字符的个数（长度）
    end]]
end;

--[[像素px转为num]]
function px2num(pxstr)
    local pxstr = string.gsub(pxstr,"px","");
    local pxnum = tonumber(pxstr);
    return pxnum;
end;

--[[把时间符串转换成对应的时间]]
function dateToTime(v)
    local Y = string.sub(v,1,4);
    local M = string.sub(v,6,7);
    local D = string.sub(v,9,10);
    local dt = os.time{year = Y, month = M, day = D, hour = 00, min = 00, sec = 00};
    return dt;
end;

--[[把时间符串转换成对应的时间，日期不给]]
function dateToTimeNoDay(v)
    local Y = string.sub(v,1,4);
    local M = string.sub(v,6,7);
    local dt = os.time{year = Y, month = M, day = 28, hour = 00, min = 00, sec = 00};
    return dt;
end;

--[[把日期时间字符串转换成对应的日期时间]]
function dateToMonthTime(v)
    local Y = string.sub(v,1,4);
    local M = string.sub(v,6,7);
    local D = "01";
    local dt = os.time{year = Y, month = M, day = D, hour = 00, min = 00, sec = 00};
    return dt;
end;

function getPropertyList(elementName,propertyType,index)
    --获取指定标签的属性值列表
    --如果指定下标的话，则只获取指定下标的属性值,index可不传
    --返回值为table类型，可根据下标直接获取table中的值，例：table[index];
    --指定下标的情况下，返回值同样是table，取值 table[1] 即可

    local valueList = {};
    if index and index ~= "" then
        if string.find(index,"^%d+$") then
            local elements = document:getElementsByName(elementName)[tonumber(index)];
            table.insert(valueList,elements:getPropertyByName(propertyType));
            return valueList;
        else
            debug_alert("index类型有误");
        end;
    else
        local elements = document:getElementsByName(elementName);
        if #elements > 0 then
            for i=1,#elements do
                table.insert(valueList,elements[i]:getPropertyByName(propertyType));
            end;
            return valueList;
        else
            debug_alert("标签："..elementName.."不存在");
            return valueList;
        end;
    end;
end;

function getStyleList(elementName,styleType,index)
    --获取指定标签的样式值列表
    --如果指定下标的话，则只获取指定下标的样式值,index可不传
    --返回值为table类型，可根据下标直接获取table中的值，例：table[index];
    --指定下标的情况下，返回值同样是table，取值 table[1] 即可
    
    local valueList = {};
    if index and index ~= "" then
        if string.find(index,"^%d+$") then
            local elements = document:getElementsByName(elementName)[tonumber(index)];
            table.insert(valueList,elements:getStyleByName(styleType));
            return valueList;
        else
            debug_alert("index类型有误");
        end;
    else
        local elements = document:getElementsByName(elementName);
        if #elements > 0 then
            for i=1,#elements do
                table.insert(valueList,elements[i]:getStyleByName(styleType));
            end;
            return valueList;
        else
            debug_alert("标签："..elementName.."不存在");
            return valueList;
        end;
    end;
end;

--[[定义一个空方法]]
function undefined_fun()

end;

function jjbx_allDate_formatDate(dateTime,resultType)
    --[[
        dateTime: 时间戳
        resultType:返回的数据类型
        date: 返回的数据类型为日期  YYYY-MM-DD
        time：返回的数据类型为日期+时间 YYYY-MM-DD HH:MM:SS
    ]]
    if dateTime == "" or dateTime == null or dateTime == nil or dateTime == "nil" then
        return "";
    else
        if resultType == "date" then
            dateTime = os.date("%Y-%m-%d",dateTime/1000);
            return dateTime;
        elseif resultType == "time" then
            dateTime = os.date("%Y-%m-%d  %H:%M:%S",dateTime/1000);
            return dateTime;
        end;
    end;
end;

--[[检测输入的文本是否规范]]
function jjbx_checkInputText(elementValue)
    local repStr = "<>&";
    local flag = true;
    for i=1,string.len(repStr) do
        local str = string.sub(repStr,i,i);
        if string.find(elementValue,str) then
            alert("输入的文本不可包含特殊字符'<'、'>'、'&'");
            flag = false;
            break
        end;
    end;
    return flag;
end;

--[[查找string中指定字符个数]]
function find_str_counts(str,tag)
    local str = formatNull(str);
    local tag = formatNull(tag);

    --[[debug_alert(
        "find_str_counts\n"..
        "str:"..str.."\n"..
        "tag:"..tag.."\n"..
        ""
    );]]

    local counts = 0;
    if str ~= "" and tag ~= "" then
        for k,v in string.gfind(str,tag) do
            counts = counts + 1;
        end;
    end;
    return counts;
end;

--[[
    数据匹配
    DataList : 匹配的参数包
    MatchArgName : 匹配的参数名
    MatchArgValue : 匹配的参数值
]]
function lua_utils.table_data_match(DataList,MatchArgName,MatchArgValue)
    local DataList = formatNull(DataList);
    local MatchArgName = formatNull(MatchArgName);
    local MatchArgValue = formatNull(MatchArgValue);

    --参数包个数
    local DataListCounts = #DataList;
    --返回的匹配下标
    local MatchIndexRes = "";

    for i=1,DataListCounts do
        local DataItemInfo = formatNull(DataList[i]);
        local DataItemArgValue = vt(MatchArgName,DataItemInfo);

        if DataItemArgValue == MatchArgValue then
            MatchIndexRes = tostring(i);
            break
        end;
    end;

    return MatchIndexRes;
end;

--[[
    获取配置中当前字段可输入最大长度
    eleName: 元素name名称
    defualtMaxLen：默认最大长度
    pageConfig：配置列表
]]
function getInputMaxLen(eleName,defualtMaxLen,pageConfig)
    local inputMaxLen = defualtMaxLen;
    local pageConfig = formatNull(pageConfig,{});
    for key,value in pairs(pageConfig) do
        if eleName == value["fieldName"] or eleName == value["fieldAppId"] or eleName.."_div" == value["fieldAppId"] then
            inputMaxLen = formatNull(value["limitNum"],defualtMaxLen);
            break
        end;
    end;
    return inputMaxLen;
end;

--[[
    获取配置项详情
    tagName: 需要查询的配置项
    pageConfig: 配置列表,
    elementValue: 当前配置指定元素值
]]
function jjbx_getPageConfigDetail(tagName,pageConfig,elementValue)
    local pageConfig = formatNull(pageConfig,{});
    local tagName = formatNull(tagName);
    local pageConfigDetail = {};
    local matchFlag = "false";
    for key,value in pairs(pageConfig) do
        if tagName == value["fieldName"] or tagName.."_div" == value["fieldAppId"] or tagName == value["fieldAppId"] then
            pageConfigDetail = pageConfig[key];
            matchFlag = "true";
            break
        end;
    end;

    if formatNull(elementValue) ~= "" then
         --指定元素
        if matchFlag == "true" then
            --字段有分配的情况下返回指定元素值
            local eValue = vt(elementValue,pageConfigDetail);
            return eValue;
        else
            --字段未分配返回空字符串
            return "";
        end;
    else
        --未指定元素返回整个配置项
        return pageConfigDetail;
    end;
end;

--[[
    设置输入框最大可输入长度
    tagName: 元素Name名称
    maxleng：最大可输入长度
]]
function jjbx_changeInputMaxleng(tagName,maxleng)
    local elements = document:getElementsByName(tagName);
    local maxleng = formatNull(maxleng,"0");
    if #elements > 0 then
        if maxleng == "0" then
            alert("参数maxleng为空");
            return;
        end;
        if platform == "iPhone OS" then
            elements[1]:setCustomPropertyByName("maxleng",maxleng);
        else
            elements[1]:setPropertyByName("maxleng",maxleng);
        end;
        page_reload();
    else
        alert("元素标签"..tagName.."不存在");
    end;
end;

--[[获取和当天相隔的日期]]
function lua_utils.day_before_today(daysAgoTypeName)
    local daysAgoTypeName = formatNull(daysAgoTypeName);
    local StartDate = "";
    local EndDate = "";

    if daysAgoTypeName ~= "" then
        local days = "";
        if     daysAgoTypeName == "近一周" then days = 7;
        elseif daysAgoTypeName == "近一月" then days = 30;
        elseif daysAgoTypeName == "近三月" then days = 91;
        elseif daysAgoTypeName == "近半年" then days = 182;
        else
        end;

        if days ~= "" then
            local EndTime = os.time();
            local StartTime = EndTime-(days*24*60*60);
            StartDate = os.date("%Y-%m-%d",StartTime);
            EndDate = os.date("%Y-%m-%d",EndTime);
        end;
    end;

    return {
        StartDate=StartDate,
        EndDate=EndDate
    };
end;

--获取字符串或list的长度的
function len(Arg)
    local Arg = formatNull(Arg);
    if type(Arg) == "string" then
        return ryt:getLengthByStr(Arg);
    elseif type(Arg) == "table" then
        return  #Arg;
    else
        return 0;
    end
end;