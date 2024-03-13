--[[表单验证]]

lua_form = {};

--[[检验密码复杂程度]]
function checkPasswordLevel()
    local password = getValue("pwd1");
    if string.find(password,"%d") and string.find(password,"%l") and string.find(password,"%u") and string.len(password) >= 6 then
        pwdFlag = "true";
        return true;
    else
        pwdFlag = "false";
        alert("密码不能少于6位,请包含大小写字母、数字。");

        return false;
    end;
end;

--[[检查密码强度]]
function lua_form.check_pwd_level(password)
    local password = formatNull(password);
    if string.find(password,"%d") and string.find(password,"%l") and string.find(password,"%u") and string.len(password) >= 6 then
        return "true";
    else
        return "false";
    end;
end;

--[[校验输入的金额，当金额超过10^13的时候，就改为最大金额]]
function checkMoneyNum(inputName)
    local money = formatNull(getValue(inputName),"0");
    --debug_alert("checkMoneyNum money : "..money);
    if money == nil or money == "" or money == "-" or money == " " or money == "请选择" then
        return;
    end;
    money = string.gsub(money,",","");
    if tonumber(money) > 10^13 then
        money = "9999999999999.99";
        changeProperty(inputName, "value", money);
    end;
end;

--[[检查登录账号]]
function check_loginUserAcc(userAcc,checkTipMsg)
    local checkTipMsg = formatNull(checkTipMsg,"请输入用户名");
    if userAcc == "" then
        alert(checkTipMsg);
        return false;
    else
        --去掉换行符
        userAcc = string.gsub(userAcc,"\n","");
        return userAcc;
    end;
end;

--[[检查登录密码]]
function check_loginUserPwd(userPwd,checkTipMsg)
    local checkTipMsg = formatNull(checkTipMsg,"请输入密码");
    if userPwd == "" then
        alert(checkTipMsg);
        return false;
    else
        return userPwd;
    end;
end;

--[[校验手机号]]
function lua_form.check_mobileNo(mobileNo,tipMsg)
    if mobileNo == "" then
        local tipMsg = formatNull(tipMsg,"请输入手机号码");
        alert(tipMsg);
        return false;
    elseif string.len(mobileNo) ~= 11 then
        local tipMsg = formatNull(tipMsg,"请输入正确的11位手机号码");
        alert(tipMsg);
        return false;
    else
        return mobileNo;
    end;
end;

--[[校验短信验证码]]
function lua_form.check_smsCode(smsCode,tipMsg)
    local tipMsg = formatNull(tipMsg,"请输入6位动态码");
    if smsCode == "" then
        alert(tipMsg);
        return false;
    elseif string.len(smsCode) ~= 6 then
        alert(tipMsg);
        return false;
    else
        return smsCode;
    end;
end;

--[[检查输入的颜色是否正确]]
function check_color(Color)
    local CheckColor = formatNull(Color);
    local CheckColorResult = "false";
    --检查有几个#号
    local FineStr = find_str_counts(CheckColor,"#");
    local ColorLength = string.len(CheckColor);

    --#号必输
    if FineStr == 1 then
        --颜色值目前支持6和8位
        if ColorLength == 7 or ColorLength == 9 then
            CheckColorResult = "true";
        else
            CheckColorResult = "false";
        end;
    else
        CheckColorResult = "false";
    end;

    --[[debug_alert(
        "检查颜色\n"..
        "CheckColor:"..CheckColor.."\n"..
        "FineStr:"..FineStr.."\n"..
        "ColorLength:"..ColorLength.."\n"..
        "CheckColorResult:"..CheckColorResult.."\n"..
        ""
    );]]

    return CheckColorResult;
end;

--[[判断table是否为空]]
function lua_form.nil_table(tableArg)
    local tableArg = formatNull(tableArg);
    local res = "true";
    if tableArg ~= "" then
        if next(tableArg) ~= nil then
            res = "false";
        end;
    end;

    return res;
end;

--[[日期格式强校验 yyyymmdd,yyyy-mm-dd]]
function lua_form.force_check_date(dateStr)
    local elementValue = formatNull(dateStr);
    local dateValue = "";
    if ryt:getLengthByStr(elementValue) == 8 then
        if tonumber(elementValue) then
            local yyyy = ryt:getSubstringValue(elementValue,0,4);
            local mm = ryt:getSubstringValue(elementValue,4,6);
            local dd = ryt:getSubstringValue(elementValue,6,8);
            dateValue = yyyy.."-"..mm.."-"..dd;
        end;
    elseif ryt:getLengthByStr(elementValue) == 10 then
        local index = string.find(elementValue,"-");
        if index and index == 5 then
            local str = ryt:getSubstringValue(elementValue,index,ryt:getLengthByStr(elementValue));
            index = string.find(str,"-");
            if index and index == 3 then
                dateValue = elementValue;
            end;
        end;
    else
        dateValue = "";
    end;
    return dateValue;
end;

--[[批量参数校验非空]]
function lua_form.arglist_check_empty(argListTable)
    local res = "true";
    for i=1,#argListTable do
        if formatNull(argListTable[i]) == "" then
            res = "false";
            break
        end;
    end;
    return res;
end;
