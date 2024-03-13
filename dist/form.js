lua_form = {};
checkPasswordLevel = function () {
    var password = getValue('pwd1');
    if (string.find(password, '%d') && string.find(password, '%l') && string.find(password, '%u') && string.len(password) >= 6) {
        pwdFlag = 'true';
        return true;
    } else {
        pwdFlag = 'false';
        alert('密码不能少于6位,请包含大小写字母\u3001数字\u3002');
        return false;
    }
};
lua_form.check_pwd_level = function (password) {
    var password = formatNull(password);
    if (string.find(password, '%d') && string.find(password, '%l') && string.find(password, '%u') && string.len(password) >= 6) {
        return 'true';
    } else {
        return 'false';
    }
};
checkMoneyNum = function (inputName) {
    var money = formatNull(getValue(inputName), '0');
    if (money === null || money === '' || money === '-' || money === ' ' || money === '请选择') {
        return;
    }
    money = string.gsub(money, ',', '');
    if (parseFloat(money) > (10 ^ 13)) {
        money = '9999999999999.99';
        changeProperty(inputName, 'value', money);
    }
};
check_loginUserAcc = function (userAcc, checkTipMsg) {
    var checkTipMsg = formatNull(checkTipMsg, '请输入用户名');
    if (userAcc === '') {
        alert(checkTipMsg);
        return false;
    } else {
        userAcc = string.gsub(userAcc, '\\n', '');
        return userAcc;
    }
};
check_loginUserPwd = function (userPwd, checkTipMsg) {
    var checkTipMsg = formatNull(checkTipMsg, '请输入密码');
    if (userPwd === '') {
        alert(checkTipMsg);
        return false;
    } else {
        return userPwd;
    }
};
lua_form.check_mobileNo = function (mobileNo, tipMsg) {
    if (mobileNo === '') {
        var tipMsg = formatNull(tipMsg, '请输入手机号码');
        alert(tipMsg);
        return false;
    } else if (string.len(mobileNo) != 11) {
        var tipMsg = formatNull(tipMsg, '请输入正确的11位手机号码');
        alert(tipMsg);
        return false;
    } else {
        return mobileNo;
    }
};
lua_form.check_smsCode = function (smsCode, tipMsg) {
    var tipMsg = formatNull(tipMsg, '请输入6位动态码');
    if (smsCode === '') {
        alert(tipMsg);
        return false;
    } else if (string.len(smsCode) != 6) {
        alert(tipMsg);
        return false;
    } else {
        return smsCode;
    }
};
check_color = function (Color) {
    var CheckColor = formatNull(Color);
    var CheckColorResult = 'false';
    var FineStr = find_str_counts(CheckColor, '#');
    var ColorLength = string.len(CheckColor);
    if (FineStr === 1) {
        if (ColorLength === 7 || ColorLength === 9) {
            CheckColorResult = 'true';
        } else {
            CheckColorResult = 'false';
        }
    } else {
        CheckColorResult = 'false';
    }
    return CheckColorResult;
};
lua_form.nil_table = function (tableArg) {
    var tableArg = formatNull(tableArg);
    var res = 'true';
    if (tableArg != '') {
        if (next(tableArg) != null) {
            res = 'false';
        }
    }
    return res;
};
lua_form.force_check_date = function (dateStr) {
    var elementValue = formatNull(dateStr);
    var dateValue = '';
    if (ryt.getLengthByStr(elementValue) === 8) {
        if (parseFloat(elementValue)) {
            var yyyy = ryt.getSubstringValue(elementValue, 0, 4);
            var mm = ryt.getSubstringValue(elementValue, 4, 6);
            var dd = ryt.getSubstringValue(elementValue, 6, 8);
            dateValue = yyyy + ('-' + (mm + ('-' + dd)));
        }
    } else if (ryt.getLengthByStr(elementValue) === 10) {
        var index = string.find(elementValue, '-');
        if (index && index === 5) {
            var str = ryt.getSubstringValue(elementValue, index, ryt.getLengthByStr(elementValue));
            index = string.find(str, '-');
            if (index && index === 3) {
                dateValue = elementValue;
            }
        }
    } else {
        dateValue = '';
    }
    return dateValue;
};
lua_form.arglist_check_empty = function (argListTable) {
    var res = 'true';
    for (let i = 1; argListTable.length; i++) {
        if (formatNull(argListTable[i]) === '') {
            res = 'false';
            break;
        }
    }
    return res;
};
module.exports = { lua_form: lua_form };