const lua_jjbx = require('./jjbx');
const lua_page = require('./page');
const lua_ota = require('./ota');
const lua_format = require('./format');
const lua_message = require('./message');
const lua_index_mission = require('./index_mission');
const lua_mission = require('./mission');
const lua_upload = require('./upload');
const lua_car = require('./car');
const lua_debug = require('./debug');
const lua_form = require('./form');
lua_system = {};
FingerprintCheckCount = 5;
lua_system.init_system = function () {
    lua_system.start_timer();
    if (systemTable['LoadAppConfigRes'] != 'true') {
        lua_system.load_app_config();
    }
    lua_jjbx.init();
};
getInfoPlatForm = function () {
    var platform = system.getInfo('platform');
    if (platform === 'iPhone OS' || platform === 'iOS') {
        return 'iPhone OS';
    } else {
        return 'Android';
    }
};
lua_system.is_iPhoneX = function () {
    var platform = getInfoPlatForm();
    var res = 'true';
    if (platform === 'iPhone OS') {
        var PhoneType = get_phone_type();
        if (PhoneType === 'iPhone X') {
        } else if (PhoneType === 'iPhone XS') {
        } else if (PhoneType === 'iPhone XS Max') {
        } else if (PhoneType === 'iPhone XR') {
        } else if (PhoneType === 'iPhone 11') {
        } else if (PhoneType === 'iPhone 11 Pro') {
        } else if (PhoneType === 'iPhone 11 Pro Max') {
        } else if (PhoneType === 'iPhone 12') {
        } else if (PhoneType === 'iPhone 12 mini') {
        } else if (PhoneType === 'iPhone 12 Pro') {
        } else if (PhoneType === 'iPhone 12 Pro Max') {
        } else {
            if (systemTable['phoneInfo'].screenStyle === 'full') {
            } else {
                res = 'false';
            }
        }
    } else {
        res = 'false';
    }
    return res;
};
get_phone_type = function () {
    var platform = getInfoPlatForm();
    var PhoneType = '';
    if (platform === 'iPhone OS') {
        PhoneType = formatNull(ryt.getIPhoneType());
    } else {
        PhoneType = formatNull(system.getInfo('model'));
    }
    return PhoneType;
};
lua_system.start_timer = function (Arg) {
    var TimerSwith = vt('TimerSwith', appTable);
    if (TimerSwith === 'OPEN') {
    } else {
        if (platform === 'iPhone OS') {
            appTable['SystemTimer'] = timer.startTimer(1, 1, lua_system.system_timer_call);
        } else {
            appTable['SystemTimer'] = mtimer.startTimer(1, 1, 'lua_system.system_timer_call');
        }
    }
    appTable['TimerSwith'] = 'OPEN';
};
lua_system.stop_timer = function () {
    var TimerSwith = vt('TimerSwith', appTable);
    if (TimerSwith === 'OPEN') {
        if (platform === 'iPhone OS') {
            timer.stopTimer(appTable['SystemTimer']);
        } else {
            mtimer.stopTimer(1);
        }
    } else {
    }
    appTable['TimerSwith'] = 'CLOSE';
};
lua_system.timer_register = function (Arg) {
    var SystemTimerMission = vt('SystemTimerMission', globalTable);
    if (SystemTimerMission === '') {
        globalTable['SystemTimerMission'] = {};
    }
    var MissionID = vt('ID', Arg);
    var DoStartTimer = vt('DoStartTimer', Arg, 'false');
    if (DoStartTimer === 'true') {
        lua_system.start_timer();
    }
    var AddMission = {
        Name: vt('Name', Arg),
        PageUrl: vt('PageUrl', Arg),
        CallFunc: vt('CallFunc', Arg),
        CallArg: vt('CallArg', Arg)
    };
    globalTable['SystemTimerMission'][MissionID] = AddMission;
};
lua_system.timer_unregister = function () {
    globalTable['SystemTimerMission'] = '';
};
lua_system.system_timer_call = function () {
    var SystemTimerMission = vt('SystemTimerMission', globalTable);
    if (SystemTimerMission != '' && type(SystemTimerMission) === 'table') {
        var CurrentPageInfo = lua_page.current_page_info();
        var PageFilePath = vt('page_file_path', CurrentPageInfo);
        for (var [MissionID, Data] in pairs(SystemTimerMission)) {
            var Name = vt('Name', Data);
            var PageUrl = vt('PageUrl', Data);
            var CallFunc = vt('CallFunc', Data);
            var CallArg = vt('CallArg', Data);
            var TimerCallArg = {
                TimeStamp: os.time(),
                BusinessArg: CallArg
            };
            if (PageUrl === PageFilePath) {
                lua_system.do_function(CallFunc, TimerCallArg);
            } else {
            }
        }
    } else {
    }
};
lua_system.checkStatusFinger_callBack = function (checkCode) {
    if (checkCode === '1') {
        systemTable['SupportLoginType'] = 'TouchID';
    }
};
lua_system.checkStatusFinger = function () {
    var nowVersion = vt('nowVersion', systemTable);
    var appSupport = lua_ota.version_ctrl(nowVersion, '2.11.3');
    if (appSupport === 'true') {
        var checkStatusFingerBackFun = '{\\"func\\":\\"lua_system.checkStatusFinger_callBack\\"}';
        eSand.checkStatusFinger(checkStatusFingerBackFun);
    }
};
iOS_start_fingerID = function (callbackname) {
    globalTable['iOSIDType'] = 'Touch ID';
    iOS_start_fingerOrFaceID(callbackname);
};
iOS_start_faceID = function (callbackname) {
    globalTable['iOSIDType'] = 'Face ID';
    iOS_start_fingerOrFaceID(callbackname);
};
iOS_start_fingerOrFaceID = function (callbackname) {
    globalTable['iOSFingerOrFaceIDCallBack'] = callbackname;
    fingerprint.startvalidate('iOS_validate_fingerOrFaceID');
};
iOS_validate_fingerOrFaceID = function (p1, p2) {
    systemTable['fingerPrintStatus'] = 'cancel';
    var iOSIDType = formatNull(globalTable['iOSIDType']);
    globalTable['iOSIDType'] = '';
    var validateCallback = formatNull(globalTable['iOSFingerOrFaceIDCallBack']);
    if (p1 === '1') {
        if (platform != 'iPhone OS') {
            FingerprintCheckCount = 5;
            changeStyle('fingerprint_page', 'display', 'none');
            changeProperty('fingerprintText', 'value', '请按压指纹');
        }
        globalTable['iOSFingerOrFaceIDCallBack'] = '';
        lua_system.do_function(validateCallback, p1);
    } else {
        if (p2 === '-1') {
            FingerprintCheckCount = FingerprintCheckCount - 1;
            if (FingerprintCheckCount > 0) {
                changeProperty('fingerprintText', 'value', '指纹不匹配\uFF0C再试一次');
            } else {
                if (platform != 'iPhone OS') {
                    FingerprintCheckCount = 5;
                    if (systemTable['fingerprintStratType'] === 'login') {
                        changeProperty('fingerprintText', 'value', '指纹已关闭\uFF0C如需指纹登陆请点击指纹图片重新启动');
                        changeStyle('fingerprintText', 'font-size', '14px');
                        changeStyle('cancelFingerprint', 'display', 'none');
                        changeStyle('changeLoginType', 'display', 'block');
                    } else {
                        changeProperty('fingerprintText', 'value', '请按压指纹');
                        changeStyle('fingerprint_page', 'display', 'none');
                    }
                }
            }
        } else {
            FingerprintCheckCount = 5;
            if (systemTable['fingerprintStratType'] === 'login') {
                changeProperty('fingerprintText', 'value', '指纹已关闭\uFF0C如需指纹登陆请点击指纹图片重新启动');
                changeStyle('fingerprintText', 'font-size', '14px');
                changeStyle('cancelFingerprint', 'display', 'none');
                changeStyle('changeLoginType', 'display', 'block');
            } else {
                changeProperty('fingerprintText', 'value', '请按压指纹');
                changeStyle('fingerprint_page', 'display', 'none');
            }
            if (platform != 'iPhone OS') {
                changeStyle('fingerprint_page', 'display', 'none');
            }
            if (p2 === '-2' || p2 === '-4') {
                globalTable['AutoQuickLogin'] = 'false';
                if (platform != 'iPhone OS') {
                    eSand.cancelFinger();
                    systemTable['fingerPrintStatus'] = 'cancel';
                    changeProperty('fingerprintText', 'value', '指纹已关闭\uFF0C如需指纹登陆请点击指纹图片重新启动');
                    changeStyle('fingerprintText', 'font-size', '14px');
                    changeStyle('cancelFingerprint', 'display', 'none');
                    changeStyle('changeLoginType', 'display', 'block');
                }
                alertToast('1', C_CancelMsg, '', '', '');
            } else if (p2 === '-5') {
                alert('未设置' + (iOSIDType + '\uFF0C请在系统中设置'));
            } else if (p2 === '-6') {
                alert('未启用' + (iOSIDType + '\uFF0C请在系统中修改'));
            } else if (p2 === '-7') {
                alert('未录入' + (iOSIDType + '\uFF0C请在系统中录入'));
            } else if (p2 === '-8') {
                alert(iOSIDType + '已锁定\uFF0C请在系统中解除锁定');
            } else {
                changeProperty('fingerprintText', 'value', formatNull(p2, '系统异常'));
                alert(formatNull(p2, '系统异常'));
            }
        }
    }
};
do_closeApp = function (index) {
    if (index === 1) {
        window.close();
    }
};
closeApp = function () {
    alert_confirm('温馨提示', '您确定要退出极简报销吗\uFF1F', '取消', '确定', 'do_closeApp');
};
set_db_value = function (key, value) {
    var Dbkey = formatNull(key);
    var DbValue = formatNull(value);
    if (Dbkey != '') {
        var OldDbValue = get_db_value(Dbkey);
        if (OldDbValue === '') {
            database.addData(Dbkey, DbValue);
        } else {
            database.updateData(Dbkey, DbValue);
        }
    }
};
get_db_value = function (key) {
    var Dbkey = formatNull(key);
    var DbValue = '';
    if (Dbkey != '') {
        DbValue = formatNull(database.getData(Dbkey));
    } else {
        DbValue = '';
    }
    return DbValue;
};
del_db_value = function (key) {
    var Dbkey = formatNull(key);
    if (Dbkey != '') {
        database.deleteData(Dbkey);
    }
};
lua_system.app_alert = function (Arg) {
    if (type(Arg) === 'table') {
        lua_system.do_app_alert(Arg);
    } else {
        Arg = lua_format.table_arg_unpack(Arg);
    }
    lua_system.do_app_alert(Arg);
};
lua_system.do_app_alert = function (Arg) {
    var titleMsg = vt('titleMsg', Arg);
    var alertMsg = vt('alertMsg', Arg);
    var msgEncodeType = vt('msgEncodeType', Arg);
    var leftbtnText = vt('leftbtnText', Arg);
    var rightbtnText = vt('rightbtnText', Arg);
    var ClickFun = vt('ClickFun', Arg);
    var ClickParams = vt('ClickParams', Arg);
    if (msgEncodeType === 'url_encode') {
        alertMsg = lua_format.url_decode(alertMsg);
    }
    alert_confirm(titleMsg, alertMsg, leftbtnText, rightbtnText, ClickFun, ClickParams);
};
alert = function (alertMsg) {
    close_loading();
    var alertMsg = formatNull(alertMsg);
    if (alertMsg != '') {
        if (alertMsg === '网络请求失败') {
            alertToast1('网络异常');
        } else {
            alert_confirm('温馨提示', alertMsg, '', '确定', '', '');
        }
    } else {
        alertToast0(C_Toast_DefaultMsg);
    }
};
alert_confirm = function (titleMsg, alertMsg, leftbtnText, rightbtnText, ClickFun, ClickParams) {
    var Arg = {
        titleMsg: titleMsg,
        alertMsg: alertMsg,
        leftbtnText: leftbtnText,
        rightbtnText: rightbtnText,
        ClickFun: ClickFun,
        ClickParams: ClickParams
    };
    lua_system.alert_confirm(Arg);
};
lua_system.alert_confirm = function (Arg) {
    var Arg = formatNull(Arg);
    if (type(Arg) === 'string') {
        Arg = lua_format.table_arg_unpack(Arg);
    }
    close_loading();
    var titleMsg = vt('titleMsg', Arg, C_Default_Title_Msg);
    var alertMsg = vt('alertMsg', Arg, C_Default_Alert_Msg);
    var leftbtnText = vt('leftbtnText', Arg);
    var rightbtnText = vt('rightbtnText', Arg);
    var ClickFun = vt('ClickFun', Arg);
    var ClickParams = vt('ClickParams', Arg);
    if (alertMsg != '') {
        var reportArg = {
            Event: 'JJBXAppAlertMsg',
            AlertMsg: alertMsg
        };
        lua_system.sensors_report(reportArg);
        if (leftbtnText === '') {
            ryt.alert(titleMsg, alertMsg, rightbtnText, ClickFun, ClickParams);
        } else {
            ryt.alert(titleMsg, alertMsg, leftbtnText, rightbtnText, ClickFun, ClickParams);
        }
    }
};
alert_confirm_call = function (TouchIndex, CallArg) {
    if (tostring(TouchIndex) === '1') {
        var CallArg = formatNull(CallArg);
        if (CallArg != '') {
            var CallArgTable = string_to_table(CallArg);
            var DoCallFun = vt('CallFun', CallArgTable);
            var DoCallArg = vt('CallArg', CallArgTable);
            lua_system.do_function(DoCallFun, DoCallArg);
        }
    }
};
alertTip = function (titleMsg, alertMsg, tipMsg, leftbtnText, rightbtnText, ClickFun, ClickParams) {
    close_loading();
    var titleMsg = formatNull(titleMsg, C_Default_Title_Msg);
    var alertMsg = formatNull(alertMsg, C_Default_Alert_Msg);
    var tipMsg = formatNull(tipMsg);
    var leftbtnText = formatNull(leftbtnText);
    var rightbtnText = formatNull(rightbtnText);
    var ClickFun = formatNull(ClickFun);
    var ClickParams = formatNull(ClickParams);
    if (alertMsg != '') {
        ryt.tip_alert(titleMsg, alertMsg, tipMsg, leftbtnText, rightbtnText, ClickFun, ClickParams);
    }
};
alertToast0 = function (msg) {
    alertToast('0', msg, '', '', '');
};
alertToast1 = function (msg) {
    alertToast('1', msg, '', '', '');
};
alertToast = function (style, alertMsg, time, removecall, removecallparam) {
    close_loading();
    var style = formatNull(style);
    var alertMsg = formatNull(alertMsg, C_Toast_DefaultMsg);
    var time = formatNull(time, '1000');
    var removecall = formatNull(removecall);
    var removecallparam = formatNull(removecallparam);
    if (platform === 'iPhone OS') {
        ryt.showToast(style, alertMsg, time, removecall, removecallparam);
    } else {
        if (removecall === 'back_fun' || removecall === 'back_fun_noloading' || removecall === 'back_fun_loading') {
            ryt.showToast(style, alertMsg, time, '', '');
            back_fun_noloading();
        } else {
            ryt.showToast(style, alertMsg, time, removecall, removecallparam);
        }
    }
};
check_repeat_do_request_erl = function () {
    var isRepeatClick = ryt.isRepeatClick();
    if (isRepeatClick === 'false') {
        return false;
    } else {
        return true;
    }
};
check_repeat_do_request_page = function () {
    var isRepeatClick = ryt.noLoadRepeatClick();
    if (isRepeatClick === 'false') {
        return false;
    } else {
        return true;
    }
};
show_loading = function (Arg) {
    if (configTable['lua_debug'] === 'true') {
        var Msg = vt('Msg', Arg);
        if (Msg != '') {
            debug_alert(Msg + '\uFF0C打开加载框');
        }
    }
    picker.showLoadingView('open');
};
close_loading = function (Arg) {
    if (configTable['lua_debug'] === 'true') {
        var Msg = vt('Msg', Arg);
        if (Msg != '') {
            debug_alert(Msg + '\uFF0C关闭加载框');
        }
    }
    picker.showLoadingView('close');
};
page_reload = function () {
    ryt.reload();
};
push_register = function (uuid, func) {
    var uuid = formatNull(uuid);
    var callbackfun = formatNull(func, 'push_register_callback');
    var regId = get_db_value('PUSH_REGISTERID_DB');
    if (uuid != '') {
        if (platform === 'iPhone OS') {
            push.setAlias(uuid, callbackfun);
        } else if (platform === 'Android') {
            if (regId === '') {
                push.pushRegister(uuid, callbackfun);
            } else {
                push.setAlias(uuid, callbackfun);
            }
        } else {
        }
    }
};
push_register_callback = function (registerToken) {
};
showPushMessage = function (msgcontent) {
    if (msgcontent != '') {
        var MsgContent = lua_format.base64_decode(msgcontent);
        var detail = json2table(MsgContent);
        var pkNotimsg = vt('pkNotimsg', detail);
        lua_message.qry_mess_info_ByPk('', { pkNotimsg: pkNotimsg });
    } else {
        alert('暂无详情');
    }
};
clear_past_push_msg = function () {
    if (platform === 'Android') {
        picker.setAllMessageAsRead();
    }
};
setBadgeNum = function (flag) {
    var appSupportInfo = lua_ota.version_support('setBadgeNum');
    var appSupport = vt('appSupport', appSupportInfo);
    if (appSupport === 'true' && platform === 'iPhone OS') {
        var setValue = '{\\"flag\\":\\"' + (flag + '\\"}');
        picker.setBadgeNum(setValue);
    }
};
set_android_Physical_back = function (funName, funArg) {
    var funName = formatNull(funName);
    funName = string.gsub(funName, '%(%)', '');
    var funArg = formatNull(funArg);
    if (platform === 'Android') {
        globalTable['ADPhysicalBackFun'] = funName;
        globalTable['ADPhysicalBackArg'] = funArg;
        window.setPhysicalkeyListener('backspace', backspace_call);
    }
};
backspace_call = function (funName, funArg) {
    var ADPhysicalBackFun = formatNull(globalTable['ADPhysicalBackFun']);
    var ADPhysicalBackArg = formatNull(globalTable['ADPhysicalBackArg']);
    if (ADPhysicalBackFun === '') {
        back_fun();
    } else {
        if (platform === 'Android') {
            lua_system.do_function(ADPhysicalBackFun, ADPhysicalBackArg);
        }
    }
};
set_longtap_listener = function (eleName, funName, funArg) {
    var eleName = formatNull(eleName);
    var funName = formatNull(funName);
    var funArg = formatNull(funArg);
    if (eleName != '') {
        var eleobjs = document.getElementsByName(eleName);
        for (let i = 1; eleobjs.length; i++) {
            var eleobj = eleobjs[i];
            globalTable['LongTapFun'] = funName;
            globalTable['LongTapArg'] = funArg;
            gesture.setLongTapListener(eleobj, longtap_call);
        }
    }
};
longtap_call = function (Arg) {
    var LongTapFun = formatNull(globalTable['LongTapFun']);
    var LongTapArg = formatNull(globalTable['LongTapArg']);
    lua_system.do_function(LongTapFun, LongTapArg);
};
do_onclick = function () {
    close_loading();
    debug_alert('响应点击');
};
lua_system.copy_to_paste = function (content) {
    var content = formatNull(content);
    if (content != '') {
        RYTL.copyPasteTargetStr(content);
    }
};
lua_system.read_paste = function () {
    var content = '';
    var MatchRes = lua_system.check_app_func('RYTL_readPasteTargetStr');
    if (MatchRes === 'true') {
        content = RYTL.readPasteTargetStr();
    } else {
        content = '';
    }
    return content;
};
lua_system.copy_and_toast = function (content, toastMsg) {
    alertToast0(formatNull(toastMsg, C_CopyMsg));
    lua_system.copy_to_paste(content);
};
lua_system.do_function = function (funName, FunArg) {
    var funName = formatNull(funName);
    var FunArg = formatNull(FunArg);
    var res = '';
    if (funName != '') {
        var dofunction = lua_format.str2fun(funName);
        if (dofunction) {
            if (FunArg === '') {
                res = dofunction();
            } else {
                res = dofunction(FunArg);
            }
        } else {
            debug_alert('函数未定义\uFF0C函数名' + funName);
        }
    }
    return res;
};
set_common_title = function () {
    set_android_top_bar_image('topBar_Bg.png');
    iPhoneX_bottom_ctrl('show', '#FFFFFF', '', '');
};
set_android_top_bar_image = function (barImageName) {
    var barImageName = formatNull(barImageName, 'topBar_Bg.png');
    if (platform === 'Android') {
        picker.changeIphoneXTopColor('', '', '', barImageName);
    } else {
    }
};
set_android_top_bar_color = function (barColor) {
    var barColor = formatNull(barColor);
    if (platform === 'Android') {
        var CheckColorResult = check_color(barColor);
        if (CheckColorResult === 'true') {
            picker.changeIphoneXTopColor(barColor, '', '', '');
        } else {
        }
    } else {
    }
};
iPhoneX_bottom_ctrl = function (CtrlStyle, bottomColor, callbackFun, callbackArg) {
    var CtrlStyle = formatNull(CtrlStyle, 'show');
    var CtrlStyleArg = '2';
    if (CtrlStyle === 'show') {
        CtrlStyleArg = '2';
        globalTable['iPhoneXBottomStyle'] = 'show';
    } else if (CtrlStyle === 'hide') {
        CtrlStyleArg = '1';
        globalTable['iPhoneXBottomStyle'] = 'hide';
    } else {
        CtrlStyleArg = '2';
    }
    var bottomColor = formatNull(bottomColor);
    if (systemTable['is_iPhoneX'] === 'true') {
        var CheckColorResult = check_color(bottomColor);
        if (bottomColor != '' && CheckColorResult === 'false') {
        } else {
            picker.changeIphoneXTopColor('', CtrlStyleArg, bottomColor, '');
            lua_system.do_function(callbackFun, callbackArg);
        }
    } else {
    }
};
lua_system.save_location = function (flag, longitude, latitude, cityName, addr) {
    var locationInfoTable = {
        ResFlag: flag,
        Longitude: longitude,
        Latitude: latitude,
        City: cityName,
        Address: addr
    };
    lua_system.save_location_json(table2json(locationInfoTable));
};
lua_system.save_location_json = function (locationInfoJson) {
    var locationInfoJson = formatNull(locationInfoJson);
    var locationInfo = json2table(locationInfoJson);
    var ResFlag = vt('ResFlag', locationInfo);
    var Longitude = vt('Longitude', locationInfo);
    var Latitude = vt('Latitude', locationInfo);
    var Province = vt('Province', locationInfo);
    var City = vt('City', locationInfo);
    var District = vt('District', locationInfo);
    var Street = vt('Street', locationInfo);
    var Address = vt('Address', locationInfo);
    Address = string.gsub(Address, Province, '');
    Address = string.gsub(Address, City, '');
    Address = string.gsub(Address, District, '');
    var AddressName = vt('AddressName', locationInfo);
    var Map = vt('Map', locationInfo);
    var lastCityCode = vt('location_cityCode', systemTable);
    var lastCityName = vt('location_cityName', systemTable);
    var nowCityCode = '';
    if (lastCityName === cityName) {
        nowCityCode = lastCityCode;
    } else {
        nowCityCode = '';
    }
    if (ResFlag === '0') {
        systemTable['location_longitude'] = Longitude;
        systemTable['location_latitude'] = Latitude;
        systemTable['location_provinceName'] = Province;
        systemTable['location_cityName'] = City;
        systemTable['location_cityCode'] = nowCityCode;
        systemTable['location_districtName'] = District;
        systemTable['location_street'] = Street;
        systemTable['location_addr'] = Address;
        systemTable['location_addrName'] = AddressName;
        systemTable['location_flag'] = 'successed';
    } else {
        systemTable['location_longitude'] = '';
        systemTable['location_latitude'] = '';
        systemTable['location_provinceName'] = '';
        systemTable['location_cityName'] = '';
        systemTable['location_cityCode'] = '';
        systemTable['location_districtName'] = '';
        systemTable['location_street'] = '';
        systemTable['location_addr'] = '';
        systemTable['location_addrName'] = '';
        systemTable['location_flag'] = 'failed';
    }
    var callbackFun = globalTable['start_location_call_fun'];
    var callbackArg = globalTable['start_location_call_arg'];
    globalTable['start_location_call_fun'] = '';
    globalTable['start_location_call_arg'] = '';
    lua_system.do_function(callbackFun, callbackArg);
};
lua_system.start_location = function (callbackFun, callbackArg) {
    globalTable['start_location_call_fun'] = callbackFun;
    globalTable['start_location_call_arg'] = callbackArg;
    var save_location_call = '';
    var appSupportInfo = lua_ota.version_support('save_location');
    var appSupport = vt('appSupport', appSupportInfo);
    if (appSupport === 'false') {
        save_location_call = 'lua_system.save_location';
    } else {
        save_location_call = 'lua_system.save_location_json';
    }
    RYTL.startLocation(save_location_call);
};
lua_system.view_file_by_webview = function (pdfarg) {
    var pdfLinkUrl = formatNull(pdfarg['pdfLinkUrl']);
    if (systemTable['EnvAllowDebug'] === 'true') {
        lua_system.copy_to_paste(pdfLinkUrl);
    }
    var pdfFileType = vt('pdfFileType', pdfarg, 'pdf');
    var pdfPageTitle = vt('pdfPageTitle', pdfarg, '查看文件');
    var pdfPageBackFun = vt('pdfPageBackFun', pdfarg, 'jjbx_utils_hideContent()');
    var pdfOpenStyle = vt('pdfOpenStyle', pdfarg, 'ClientWidget');
    var PCConfigListsTable = vt('PCConfigListsTable', globalTable);
    var IMG0015 = vt('IMG0015', PCConfigListsTable);
    var waterMarkValue = '';
    if (IMG0015 === '是') {
        var nowTime = os.time();
        var nowDate = os.date('%Y-%m-%d', nowTime);
        var workID = globalTable['workid'];
        var unitname = globalTable['selectOrgList'][1]['unitname'];
        waterMarkValue = unitname + (' ' + (nowDate + (' ' + workID)));
    }
    var IMG0016 = vt('IMG0016', PCConfigListsTable);
    if (pdfLinkUrl === '') {
        alert('文件不存在');
    } else {
        if (pdfOpenStyle === 'Webview') {
            globalTable['webview_page_title'] = pdfPageTitle;
            globalTable['webview_url'] = pdfLinkUrl;
            globalTable['webview_iPhoneX_bottom'] = 'show';
            globalTable['webview_back_fun'] = pdfPageBackFun;
            jjbx_utils_hideContent('true', 'false');
            var DefaultInvokePageArg = {
                ShowPageStyle: 'showContent',
                AddPage: 'false',
                JumpStyle: ''
            };
            var InvokePageArg = formatNull(pdfarg['InvokePageArg'], DefaultInvokePageArg);
            invoke_page('jjbx_page/xhtml/webview_page.xhtml', page_callback, InvokePageArg);
        } else if (pdfOpenStyle === 'ClientWidget') {
            var RightLabelText = vt('right_label_text', pdfarg, '下载');
            if (RightLabelText === 'NONE' || vt('downloadFlag', globalTable) != 'true') {
                RightLabelText = '';
            }
            var RightLabelFunc = vt('right_label_func', pdfarg, 'lua_system.download_file(\'' + (pdfLinkUrl + '\')'));
            if (RightLabelFunc === 'NONE' || vt('downloadFlag', globalTable) != 'true') {
                RightLabelFunc = '';
            }
            if (platform === 'iPhone OS') {
                var previewArg = {
                    webview_page_title: pdfPageTitle,
                    webview_page_url: pdfLinkUrl,
                    file_download_text: RightLabelText,
                    file_download_func: RightLabelFunc,
                    back_type: 'CLOSE',
                    progress_bar: 'true',
                    waterMarkValue: waterMarkValue,
                    waterMarkColor: '#8B8B8B'
                };
                ryt.h5_preview_file(table2json(previewArg));
            } else {
                var webviewCore = lua_system.webview_core();
                if (webviewCore === 'webviewX5' && pdfFileType === 'pdf') {
                    var previewArg = {
                        preview_page_title: pdfPageTitle,
                        preview_file_url: pdfLinkUrl,
                        preview_file_name: tostring(os.time()) + ('.' + pdfFileType),
                        file_download_text: RightLabelText,
                        file_download_func: RightLabelFunc,
                        back_type: 'CLOSE',
                        progress_bar: 'true',
                        waterMarkValue: waterMarkValue,
                        waterMarkColor: '#8B8B8B'
                    };
                    ryt.x5_preview_file(table2json(previewArg));
                } else {
                    var viewArg = {
                        FileDownloadLinkUrl: pdfLinkUrl,
                        FileName: tostring(os.time()) + ('.' + pdfFileType),
                        FileType: pdfFileType
                    };
                    czbank.view_file_by_phone_soft(table2json(viewArg));
                }
            }
        }
    }
};
app_to_backstage = function (timestamp) {
    save_app_switch_stage_TS(timestamp, 'back');
};
app_to_upstage = function (timestamp) {
    save_app_switch_stage_TS(timestamp, 'up');
    var app_backstage_timeout_switch = formatNull(systemTable['ClientBackstageTimeoutClean'], 'false');
    var app_timeout = formatNull(globalTable['AppTimeOut']);
    if (app_backstage_timeout_switch === 'true' && app_timeout === 'true') {
        lua_system.call_client_timeout();
    } else {
        analysis_app_backstage();
    }
};
save_app_switch_stage_TS = function (timestamp, switch) {
    var timestamp = parseFloat(formatNull(timestamp, '0'));
    if (switch === 'back') {
        globalTable['AppToBackstageTS'] = timestamp;
    } else if (switch === 'up') {
        globalTable['AppToUpstageTS'] = timestamp;
    } else {
    }
};
analysis_app_backstage = function (timestamp) {
    var app_to_backstage_ts = parseFloat(formatNull(globalTable['AppToBackstageTS'], '0'));
    var app_to_upstage_ts = parseFloat(formatNull(globalTable['AppToUpstageTS'], '0'));
    var app_backstage_run_secs = 0;
    if (app_to_backstage_ts != 0 && app_to_upstage_ts != 0) {
        var time_diff = app_to_upstage_ts - app_to_backstage_ts;
        if (time_diff > 0) {
            app_backstage_run_secs = time_diff;
        }
    }
    globalTable['AppBackstageRunSecs'] = app_backstage_run_secs;
    globalTable['AppToBackstageTS'] = 0;
    globalTable['AppToUpstageTS'] = 0;
    var app_backstage_timeout_switch = formatNull(systemTable['ClientBackstageTimeoutClean'], 'false');
    var client_backstage_timeout = parseFloat(formatNull(systemTable['ClientBackstageTimeout'], 0));
    if (globalTable['AppBackstageRunSecs'] > client_backstage_timeout) {
        globalTable['AppTimeOut'] = 'true';
    } else {
        globalTable['AppTimeOut'] = 'false';
    }
    var doAppTimeOut = 'false';
    if (app_backstage_timeout_switch === 'true' && globalTable['AppTimeOut'] === 'true') {
        doAppTimeOut = 'true';
    }
    if (doAppTimeOut === 'true') {
        lua_system.call_client_timeout();
    } else {
        lua_index_mission.deal_client_register_mission();
    }
};
lua_system.call_client_timeout = function () {
    jjbx_utils_hideContent('false', 'false');
    lua_system.batch_close_app_alert_window();
    ryt.timeoutAlert();
};
set_rslide_listener = function (eleName, funName, funArg) {
    if (platform === 'iPhone OS') {
        var eleName = formatNull(eleName);
        if (eleName != '') {
            var eleobj = document.getElementsByName(eleName)[1];
            globalTable['RslideFun'] = formatNull(funName, '');
            globalTable['RslideArg'] = formatNull(funArg, '');
            gesture.setSwipeListener(eleobj, rslide_call);
        }
    } else {
    }
};
rslide_call = function (params) {
    var direction = formatNull(params['direction']);
    var RslideFun = formatNull(globalTable['RslideFun']);
    var RslideArg = formatNull(globalTable['RslideArg']);
    if (direction === 'right') {
        lua_system.do_function(RslideFun, RslideArg);
    }
};
lua_system.set_single_swipe_listener = function (SetArg) {
    var eleName = vt('eleName', SetArg);
    if (eleName != '') {
        var eleobj = document.getElementsByName(eleName);
        if (eleobj.length >= 1) {
            globalTable['SingleSwipeListenerSetArg'] = SetArg;
            gesture.setSwipeListener(eleobj[1], lua_system.single_swipe_call);
        } else {
            debug_alert('未找到快速滑动监听控件');
        }
    } else {
        debug_alert('未指定快速滑动监听控件');
    }
};
lua_system.single_swipe_call = function (CallArg) {
    var direction = vt('direction', CallArg);
    var SetArg = vt('SingleSwipeListenerSetArg', globalTable);
    var DoCallFun = '';
    var DoCallArg = {
        direction: direction,
        setArg: ''
    };
    var defaultCall = vt('defaultCall', SetArg);
    if (defaultCall != '') {
        DoCallFun = defaultCall;
        DoCallArg['setArg'] = vt('defaultArg', SetArg);
    } else {
        if (direction === 'left') {
            DoCallFun = vt('leftFun', SetArg);
            DoCallArg['setArg'] = vt('leftArg', SetArg);
        } else if (direction === 'right') {
            DoCallFun = vt('rightFun', SetArg);
            DoCallArg['setArg'] = vt('rightArg', SetArg);
        } else if (direction === 'up') {
            DoCallFun = vt('upFun', SetArg);
            DoCallArg['setArg'] = vt('upArg', SetArg);
        } else if (direction === 'down') {
            DoCallFun = vt('downFun', SetArg);
            DoCallArg['setArg'] = vt('downArg', SetArg);
        }
    }
    if (DoCallFun === '') {
        debug_alert('未指定快速滑动监听回调\uFF0C滑动方向\uFF1A' + direction);
    } else {
        lua_system.do_function(DoCallFun, DoCallArg);
    }
};
file_sysapi_support = function () {
    if (platform === 'iPhone OS') {
        var iPhoneOsVersion = system.getInfo('version');
        var OsVerArr = splitUtils(iPhoneOsVersion, '%.');
        var OsMainVer = formatNull(OsVerArr[1], '0');
        var OsMainVerNum = parseFloat(OsMainVer);
        if (OsMainVerNum >= 11) {
            return 'true';
        } else {
            return 'false';
        }
    } else {
        return 'true';
    }
};
screen_resolution_update = function (width, height) {
    var screen_width = formatNull(width, screen.width());
    var screen_height = formatNull(height, screen.height());
    var screen_dpi = formatNull(screen.dpi());
    var width_ratio = float(screen_width / C_screenBaseWidth, 4);
    var height_ratio = float(screen_height / C_screenBaseHeight, 4);
    var screen_configured = configured_screen_info(screen_width, screen_height);
    var screen_use_height = math.ceil(screen_height / width_ratio);
    systemTable['phoneInfo'].screenWidth = screen_width;
    systemTable['phoneInfo'].widthRatio = width_ratio;
    systemTable['phoneInfo'].screenHeight = screen_height;
    systemTable['phoneInfo'].screenUseHeight = screen_use_height;
    systemTable['phoneInfo'].heightRatio = height_ratio;
    systemTable['phoneInfo'].screenDpi = screen_dpi;
    systemTable['phoneInfo'].screenConfigured = screen_configured;
};
configured_screen_info = function (width, height) {
    var res = '';
    if (platform === 'iPhone OS') {
        res = 'true';
    } else {
        res = 'false';
    }
    return res;
};
tel_call = function (telno) {
    var telno = formatNull(telno);
    if (telno != '') {
        system.openURL('tel:' + telno);
    }
};
mail_call = function (mailaddr) {
    var mailaddr = formatNull(mailaddr);
    if (mailaddr != '') {
        system.openURL('mailto:' + mailaddr);
    }
};
lua_system.confirm_clear_app_cache = function () {
    alert_confirm('重要提示', '该操作会清理客户端所有已保存数据\uFF0C包括但不限于离线资源\u3001登录信息\u3001保存菜单\u3001本地文件等\uFF0C清理后客户端会关闭', '取消', '确定', 'alert_confirm_call', 'CallFun=lua_system.clear_app_cache&CallArg=');
};
lua_system.clear_app_cache = function () {
    if (systemTable['EnvAllowDebug'] === 'true') {
        if (platform === 'iPhone OS') {
            ryt.clear_app_cache();
            alert_confirm('', '清理成功', '', '关闭程序', 'do_closeApp');
        } else {
            alert('Android设备请至系统设置-应用管理中清理缓存');
        }
    }
};
lua_system.webview_core = function () {
    var WebviewType = 'webviewLife';
    if (platform === 'Android') {
        if (systemTable['PublicNetHost'] === 'true') {
            var status = formatNull(ryt.get_X5Core_status());
            if (status === 'true') {
                WebviewType = 'webviewX5';
            }
        }
    }
    return WebviewType;
};
lua_system.download_file = function (dlurl) {
    var dlurl = formatNull(dlurl);
    if (dlurl != '') {
        system.openURL(dlurl);
    }
};
lua_system.open_by_browser = function (url) {
    var url = formatNull(url);
    if (url != '') {
        system.openURL(url);
    }
};
lua_system.image_preview = function (arg) {
    var arg = formatNull(arg);
    arg = json2table(arg);
    var PCConfigListsTable = vt('PCConfigListsTable', globalTable);
    var IMG0015 = vt('IMG0015', PCConfigListsTable);
    var waterMarkValue = '';
    if (IMG0015 === '是') {
        var nowTime = os.time();
        var nowDate = os.date('%Y-%m-%d', nowTime);
        var workID = globalTable['workid'];
        var unitname = globalTable['selectOrgList'][1]['unitname'];
        waterMarkValue = unitname + (' ' + (nowDate + (' ' + workID)));
    }
    arg['waterMarkValue'] = waterMarkValue;
    arg['waterMarkColor'] = '#8B8B8B';
    arg = table2json(arg);
    if (arg != '') {
        ryt.image_preview(arg);
    }
};
lua_system.view_single_image = function (dlLink) {
    var previewImageTableArg = {
        ImageCounts: '1',
        ImageLists: [{
                ImageSeq: '1',
                ImageDLUrl: dlLink
            }]
    };
    lua_system.image_preview(table2json(previewImageTableArg));
};
lua_system.open_msg_popup = function (popupJsonArg, backFunName) {
    var backFunName = formatNull(backFunName, 'lua_system.close_msg_popup');
    set_android_Physical_back(backFunName);
    msg_popup_status = 'open';
    var appSupportInfo = lua_ota.version_support('ryt:msg_popup_ctrl');
    var appSupport = vt('appSupport', appSupportInfo);
    var appSupportTipMsg = vt('appSupportTipMsg', appSupportInfo);
    if (appSupport === 'false') {
        lua_mission.index_handle();
    } else {
        ryt.msg_popup_ctrl('open', popupJsonArg);
    }
};
lua_system.close_msg_popup = function (backFunName) {
    var backFunName = formatNull(backFunName, 'back_fun');
    set_android_Physical_back(backFunName);
    msg_popup_status = 'close';
    ryt.msg_popup_ctrl('close', '');
    lua_mission.index_handle();
};
lua_system.msg_popup_call = function (ClickFlag, ClickArg) {
    var ClickFlag = formatNull(ClickFlag);
    var ClickArg = formatNull(ClickArg);
    var call_debug_msg = '发布消息弹窗点击回调\\n' + ('点击类型 : ' + (ClickFlag + ('\\n' + ('点击参数 : ' + (ClickArg + ('\\n' + ''))))));
    if (ClickFlag === 'Close') {
        lua_index_mission.msg_popup_close_call(ClickArg);
    } else if (ClickFlag === 'Detail') {
        lua_index_mission.msg_popup_click_call(ClickArg);
    } else if (ClickFlag === 'CheckBox') {
        lua_index_mission.msg_popup_checkbox_call(ClickArg);
    } else {
        debug_alert('未定义的操作类型');
    }
};
lua_system.app_alert_menu = function (jsonArg) {
    if (formatNull(jsonArg) != '') {
        menu_alert_status = 'open';
        picker.app_alert_menu(jsonArg);
    }
};
lua_system.close_app_alert_menu = function () {
    menu_alert_status = 'close';
    picker.close_app_alert_menu();
};
lua_system.open_camera = function (CallTableArg) {
    var doFlag = vt('doFlag', CallTableArg);
    if (doFlag === 'Upload') {
        lua_upload.clear_upload_cache_arg();
    }
    var UseTableArg = lua_system.pic_upload_arg_prepare(CallTableArg);
    var JsonArg = table2json(UseTableArg);
    if (formatNull(JsonArg) != '') {
        picker.open_camera(JsonArg);
    }
};
lua_system.open_album = function (CallTableArg) {
    var doFlag = vt('doFlag', CallTableArg);
    if (doFlag === 'Upload') {
        lua_upload.clear_upload_cache_arg();
    }
    var UseTableArg = lua_system.pic_upload_arg_prepare(CallTableArg);
    var JsonArg = table2json(UseTableArg);
    if (formatNull(JsonArg) != '') {
        picker.open_album(JsonArg);
    }
};
lua_system.open_camera_shoot = function (CallTableArg) {
    var doFlag = vt('doFlag', CallTableArg);
    if (doFlag === 'Upload') {
        lua_upload.clear_upload_cache_arg();
    }
    var MatchRes = lua_system.check_app_func('picker_open_camera_shoot');
    if (MatchRes === 'true') {
        var UseTableArg = CallTableArg;
        var JsonArg = table2json(UseTableArg);
        if (formatNull(JsonArg) != '') {
            picker.open_camera_shoot(JsonArg);
        }
    } else {
        var upverArg = {
            updateType: 'OPTION',
            updateMsg: '上传视频需要升级\uFF0C请更新后使用\u3002'
        };
        lua_ota.show_upvsr_view(upverArg);
    }
};
lua_system.open_album_video = function (CallTableArg) {
    var doFlag = vt('doFlag', CallTableArg);
    if (doFlag === 'Upload') {
        lua_upload.clear_upload_cache_arg();
    }
    var MatchRes = lua_system.check_app_func('picker_open_album_video');
    if (MatchRes === 'true') {
        var UseTableArg = CallTableArg;
        var JsonArg = table2json(UseTableArg);
        if (formatNull(JsonArg) != '') {
            picker.open_album_video(JsonArg);
        }
    } else {
        var upverArg = {
            updateType: 'OPTION',
            updateMsg: '上传视频需要升级\uFF0C请更新后使用\u3002'
        };
        lua_ota.show_upvsr_view(upverArg);
    }
};
lua_system.pic_upload_arg_prepare = function (CallTableArg) {
    var UploadTableArg = formatNull(CallTableArg);
    var splitsize = '';
    if (platform === 'iPhone OS') {
        splitsize = C_ClientUploadSplitSize_iPhone;
    } else {
        splitsize = C_ClientUploadSplitSize_Android;
    }
    if (vt('params1', UploadTableArg) === '') {
        UploadTableArg['params1'] = '';
    }
    if (vt('params2', UploadTableArg) === '') {
        UploadTableArg['params2'] = '';
    }
    if (vt('params3', UploadTableArg) === '') {
        UploadTableArg['params3'] = '';
    }
    if (vt('maxSize', UploadTableArg) === '') {
        UploadTableArg['maxSize'] = '10';
    }
    if (vt('maxSizeTip', UploadTableArg) === '') {
        UploadTableArg['maxSizeTip'] = '相片尺寸大于' + (vt('maxSize', UploadTableArg) + 'M\uFF0C不能上传');
    }
    if (vt('splitsize', UploadTableArg) === '') {
        UploadTableArg['splitsize'] = splitsize;
    }
    if (vt('uploadtimeout', UploadTableArg) === '') {
        UploadTableArg['uploadtimeout'] = '30';
    }
    return UploadTableArg;
};
lua_system.client_file_upload = function (UploadTableArg, SuccessCallFun, CheckFileSupport) {
    var UploadTableArg = formatNull(UploadTableArg);
    var splitsize = '';
    var maxlen = '';
    if (platform === 'iPhone OS') {
        splitsize = C_ClientUploadSplitSize_iPhone;
        maxlen = C_UploadMaxKbSize_iPhone;
    } else {
        splitsize = C_ClientUploadSplitSize_Android;
        maxlen = C_UploadMaxKbSize_Android;
    }
    if (vt('maxlen', UploadTableArg) === '') {
        UploadTableArg['maxlen'] = maxlen;
    }
    if (vt('maxlenmsg', UploadTableArg) === '') {
        UploadTableArg['maxlenmsg'] = C_UploadMaxTipMsg;
    }
    if (vt('splitsize', UploadTableArg) === '') {
        UploadTableArg['splitsize'] = splitsize;
    }
    if (vt('uploadtimeout', UploadTableArg) === '') {
        UploadTableArg['uploadtimeout'] = '30';
    }
    if (vt('params1', UploadTableArg) === '') {
        UploadTableArg['params1'] = '';
    }
    if (vt('params2', UploadTableArg) === '') {
        UploadTableArg['params2'] = '';
    }
    if (vt('params3', UploadTableArg) === '') {
        UploadTableArg['params3'] = '';
    }
    var fileSupport = formatNull(systemTable['phoneInfo'].fileSupport);
    var CheckFileSupport = formatNull(CheckFileSupport, 'true');
    if (CheckFileSupport === 'true' && platform === 'iPhone OS' && fileSupport === 'false') {
        alert('访问文件应用需要iOS11.0或更高系统版本\u3002');
    } else {
        globalTable['ClientFileUploadSuccessCallFun'] = SuccessCallFun;
        var UploadJsonArg = table2json(UploadTableArg);
        ryt.upload_client_file(UploadJsonArg);
    }
};
lua_system.file_preview = function (previewUrl, fileType) {
    if (fileType === 'png' || fileType === 'jpg' || fileType === 'jpeg') {
        var previewImageTableArg = {
            ImageCounts: '1',
            ImageLists: [{
                    ImageSeq: '1',
                    ImageDLUrl: previewUrl
                }]
        };
        lua_system.image_preview(table2json(previewImageTableArg));
    } else if (fileType === 'pdf') {
        var openPdfArg = {
            pdfLinkUrl: previewUrl,
            pdfPageTitle: '查看发票'
        };
        lua_system.view_file_by_webview(openPdfArg);
    } else if (fileType === 'ofd') {
        lua_system.alert_webview({
            title: '文件预览',
            visit_url: previewUrl,
            close_call_func: '',
            back_type: 'BACK',
            listen_url: 'http://app_h5_callback_url',
            listen_call: 'lua_system.webview_h5_callback'
        });
    }
};
lua_system.batch_close_app_alert_window = function () {
    if (menu_alert_status === 'open') {
        lua_system.close_app_alert_menu();
    }
    if (msg_popup_status === 'open') {
        lua_system.close_msg_popup();
    }
};
lua_system.webview_h5_callback = function (url) {
    var callbackUrl = formatNull(url);
    if (callbackUrl != '') {
        var argTable = lua_format.url_arg2table(callbackUrl);
        var CallFlag = vt('CallFlag', argTable);
        if (CallFlag === 'UseCarSelectCity') {
            lua_car.use_car_selectCity(argTable);
        } else if (CallFlag === 'EJYH5Back2JJBX') {
            lua_system.do_function('ejy_h5_back2jjbx_call');
        } else if (CallFlag === 'EatMtH5OpenJJBXScanWidgetToPay') {
            lua_system.do_function('lua_eat.scan_to_pay', argTable);
        }
    } else {
    }
};
lua_system.select_interval_date = function (arg) {
    var startDate = formatNull(arg['startDate']);
    var endDate = formatNull(arg['endDate']);
    var maxDayCounts = formatNull(arg['maxDayCounts'], '365');
    var maxMonthCounts = formatNull(arg['maxMonthCounts'], '12');
    var callbackFunc = formatNull(arg['callbackFunc']);
    var title = formatNull(arg['title'], '请选择时间');
    jjbx.showMealTime(startDate, endDate, maxDayCounts, maxMonthCounts, callbackFunc, title);
};
lua_system.alert_webview = function (alertWebviewArg) {
    var alertWebviewArg = formatNull(alertWebviewArg);
    var title = vt('title', alertWebviewArg);
    var visit_url = vt('visit_url', alertWebviewArg);
    var listen_url = vt('listen_url', alertWebviewArg);
    var listen_call = vt('listen_call', alertWebviewArg);
    var close_call_func = vt('close_call_func', alertWebviewArg);
    var close_call_arg = vt('close_call_arg', alertWebviewArg);
    var back_type = vt('back_type', alertWebviewArg, 'CLOSE');
    var progress_bar = vt('progress_bar', alertWebviewArg, 'true');
    var RightLabelText = vt('RightLabelText', alertWebviewArg);
    var RightLabelFunc = vt('RightLabelFunc', alertWebviewArg);
    var RightLabelClickClose = vt('RightLabelClickClose', alertWebviewArg, 'false');
    var preview_file_name = vt('preview_file_name', alertWebviewArg);
    var OpenBrowserCloseWebview = vt('OpenBrowserCloseWebview', alertWebviewArg);
    var AddUserAgent = vt('AddUserAgent', alertWebviewArg);
    var location = vt('location', alertWebviewArg, 'false');
    if (systemTable['EnvAllowDebug'] === 'true') {
        lua_system.copy_to_paste(visit_url);
        var DebugReqParams = {
            DebugFlag: 'CacheH5Url',
            H5Url: visit_url
        };
        lua_debug.app_debug('', DebugReqParams);
    }
    var reportArg = {
        Event: 'JJBXAppOpenHtml',
        PageUrl: visit_url,
        PageName: title
    };
    lua_system.sensors_report(reportArg);
    var previewArg = {
        listen_call_url: listen_url,
        listen_call_fun: listen_call,
        close_call_func: close_call_func,
        close_call_arg: close_call_arg,
        back_type: back_type,
        progress_bar: 'true',
        file_download_text: RightLabelText,
        file_download_func: RightLabelFunc,
        file_download_close: RightLabelClickClose,
        AddUserAgent: AddUserAgent,
        location: location
    };
    if (platform === 'iPhone OS') {
        previewArg['webview_page_title'] = title;
        previewArg['webview_page_url'] = visit_url;
        previewArg['OpenBrowserCloseWebview'] = OpenBrowserCloseWebview;
        ryt.h5_preview_file(table2json(previewArg));
    } else {
        previewArg['preview_page_title'] = title;
        previewArg['preview_file_url'] = visit_url;
        previewArg['preview_file_name'] = preview_file_name;
        ryt.x5_preview_file(table2json(previewArg));
    }
};
lua_system.select_widget_parent_data = function (dataArg) {
    var tableArg = {};
    for (var [key, value] in pairs(dataArg)) {
        var dataCode = dataArg[key]['dataCode'];
        var dataName = dataArg[key]['dataName'];
        var addTable = {
            parent: [dataCode],
            contentcode: dataCode,
            supContent: '-1',
            channels: '',
            channel: {
                parent: [dataCode],
                contentcode: dataCode,
                hasChildren: '0',
                supContent: '-1',
                contentname: dataName
            }
        };
        table.insert(tableArg, addTable);
    }
    return table2json(tableArg);
};
lua_system.load_app_config = function () {
    var serverInfoTable = {
        textarea_disenable_input_char: lua_format.base64_encode('[]`~!#$%^*+=|{}\'\'\\\\[\\\\]<>~#\uFFE5%\u2026&*\u2014\u2014+|{}\u3010\u3011\u2018\u2019\uFF5E\uFF03\uFF05\uFF0A\uFF08\uFF09\uFF0D\uFF1D\uFF0B\u3001\uFF5C\uFF3B\uFF3D\uFF5B\uFF5D\uFF1B\uFF1A\u201D\u201C\u300A\u300B/'),
        upload_file_view_icon_info: {
            pdf: 'file_pdf_icon.png',
            ofd: 'file_ofd_icon.png',
            xls: 'file_excel_icon.png',
            xlsx: 'file_excel_icon.png',
            doc: 'file_word_icon.png',
            docx: 'file_word_icon.png',
            ppt: 'file_ppt_icon.png',
            pptx: 'file_ppt_icon.png',
            eml: 'file_eml_icon.png',
            zip: 'file_zip_icon.png',
            rar: 'file_rar_icon.png',
            other: 'file_other_icon.png'
        },
        webview_download_support_file: 'ofd,eml,zip,rar,mp4,png',
        webview_view_support_file: 'pdf,doc,docx,xls,xlsx,ppt,pptx,txt,xml'
    };
    var serverInfoJson = table2json(serverInfoTable);
    ryt.load_app_config(serverInfoJson);
    systemTable['LoadAppConfigRes'] = 'true';
};
lua_system.get_device_name = function () {
    var DeviceName = '';
    if (platform === 'iPhone OS') {
        DeviceName = system.getInfo('name');
    } else {
        DeviceName = ryt.getDeviceName();
    }
    systemTable['phoneInfo']['deviceName'] = DeviceName;
    return formatNull(DeviceName);
};
lua_system.hide_keyboard = function (arg) {
    var CallFun = vt('CallFun', arg, 'undefined_fun');
    var DelayTime = vt('DelayTime', arg, '100');
    var appSupportInfo = lua_ota.version_support('ryt:hideKeyBoard');
    var appSupport = vt('appSupport', appSupportInfo);
    if (appSupport === 'false') {
        lua_system.do_function(CallFun, '');
    } else {
        ryt.hideKeyBoard(CallFun, DelayTime);
    }
};
lua_system.get_deviceId = function () {
    var deviceIDRes = '';
    var LocalDeviceID = get_db_value('SaveDeviceId');
    if (LocalDeviceID === '') {
        var AppDeviceID = formatNull(system.getInfo('deviceID'));
        if (AppDeviceID === '') {
            var timestampStr = tostring(os.time());
            var randomStr = tostring(math.random(0, 10000000));
            var AddLocalDeviceID = timestampStr + randomStr;
            set_db_value('SaveDeviceId', AddLocalDeviceID);
            deviceIDRes = AddLocalDeviceID;
        } else {
            set_db_value('SaveDeviceId', AppDeviceID);
            deviceIDRes = AppDeviceID;
        }
    } else {
        deviceIDRes = LocalDeviceID;
    }
    return deviceIDRes;
};
lua_system.get_map_mark_pic_dlurl = function (Arg) {
    var mark_pic_dlurl = '';
    var WebMapApiUrl = vt('WebMapApiUrl', configTable);
    var Longitude = formatNull(vt('Longitude', Arg), vt('location_longitude', systemTable));
    var Latitude = formatNull(vt('Latitude', Arg), vt('location_latitude', systemTable));
    var MapPicWidth = vt('MapPicWidth', Arg);
    var MapPicHeight = vt('MapPicHeight', Arg);
    var MapCoordType = vt('MapCoordType', Arg);
    var MapUrlArgTable = [
        WebMapApiUrl,
        Longitude,
        Latitude,
        MapPicWidth,
        MapPicHeight
    ];
    var argCheckRes = lua_form.arglist_check_empty(MapUrlArgTable);
    if (argCheckRes === 'true') {
        var AutoCoordType = '';
        if (platform === 'iPhone OS') {
            AutoCoordType = 'wgs84ll';
        } else {
            AutoCoordType = 'bd09ll';
        }
        mark_pic_dlurl = WebMapApiUrl + ('&location=' + (Longitude + (',' + (Latitude + ('&zoom=17' + ('&size=' + (MapPicWidth + ('*' + (MapPicHeight + ('&markers=mid,,A:' + (Longitude + (',' + (Latitude + ('&scale=2' + ''))))))))))))));
    }
    return mark_pic_dlurl;
};
lua_system.get_client_dbvalue = function (DBKey) {
    var GetArg = {
        Ctrl: 'GET',
        Key: DBKey
    };
    var res = ryt.client_database_ctrl(table2json(GetArg));
    return res;
};
lua_system.set_client_dbvalue = function (DBKey, DBValue) {
    var SetArg = {
        Ctrl: 'SET',
        Key: DBKey,
        Value: DBValue
    };
    var res = ryt.client_database_ctrl(table2json(SetArg));
    return res;
};
lua_system.start_app_listener = function (Arg) {
    var listenerTableArg = {
        listenerName: vt('listenerName', Arg),
        listenerType: vt('listenerType', Arg),
        listenerCtrlType: 'START',
        listenerCtrlCallFun: 'lua_system.AppListenerCtrlCall',
        listenerCtrlCallArg: { listenerCtrlType: 'START' },
        listenerCallFun: 'lua_system.AppListenerCall',
        listenerCallArg: {
            listenerCallFunc: vt('listenerCallFunc', Arg),
            listenerCallArg: vt('listenerCallArg', Arg)
        }
    };
    lua_system.app_listener_ctrl(listenerTableArg);
};
lua_system.stop_app_listener = function (Arg) {
    var listenerTableArg = {
        listenerName: vt('listenerName', Arg),
        listenerType: vt('listenerType', Arg),
        listenerCtrlType: 'STOP',
        listenerCtrlCallFun: 'lua_system.AppListenerCtrlCall',
        listenerCtrlCallArg: { listenerCtrlType: 'STOP' },
        listenerCallFun: 'lua_system.AppListenerCall',
        listenerCallArg: {
            listenerCallFunc: vt('listenerCallFunc', Arg),
            listenerCallArg: vt('listenerCallArg', Arg)
        }
    };
    lua_system.app_listener_ctrl(listenerTableArg);
};
lua_system.app_listener_ctrl = function (listenerTableArg) {
    var appSupportInfo = lua_ota.version_support('ryt:app_listener_ctrl');
    var appSupport = vt('appSupport', appSupportInfo);
    if (appSupport === 'false') {
    } else {
        var listenerJsonArg = table2json(listenerTableArg);
        ryt.app_listener_ctrl(listenerJsonArg);
    }
};
lua_system.AppListenerCall = function (CallArgJson) {
    var TableArg = json2table(CallArgJson);
    listenerCallFunc = vt('listenerCallFunc', TableArg);
    listenerCallArg = vt('listenerCallArg', TableArg);
    lua_system.do_function(listenerCallFunc, listenerCallArg);
};
lua_system.AppListenerCtrlCall = function (CallArgJson) {
};
lua_system.check_app_func = function (luaID) {
    var appSupportInfo = lua_ota.version_support('ryt:app_project_info');
    var appSupport = vt('appSupport', appSupportInfo);
    var MatchRes = 'false';
    if (appSupport === 'true') {
        var AppProjectInfoJson = ryt.app_project_info('');
        var AppProjectInfoTable = json2table(AppProjectInfoJson);
        var LuaFunction = vt('LuaFunction', AppProjectInfoTable);
        var LoopCounts = LuaFunction.length;
        var luaID = formatNull(luaID);
        for (let i = 1; LoopCounts; i++) {
            var InfoData = formatNull(LuaFunction[i]);
            var AppFuncName = vt('FuncName', InfoData);
            var ServerFuncName = vt('FuncName', C_SYSTEM_LUA_INFO[luaID]);
            if (AppFuncName === ServerFuncName) {
                MatchRes = 'true';
                break;
            }
        }
    }
    return MatchRes;
};
lua_system.user_data_report = function (Arg) {
    var Receiver = vt('Receiver', Arg);
    if (Receiver === 'SensorsData') {
        if (vt('SensorsInstallFlag', systemTable) === '') {
            var MatchRes1 = lua_system.check_app_func('picker_sensorsAnalyticsLogin');
            var MatchRes2 = lua_system.check_app_func('picker_sensorsAnalyticsPointTrack');
            if (MatchRes1 === 'true' || MatchRes2 === 'true') {
                systemTable['SensorsInstallFlag'] = 'true';
            } else {
                systemTable['SensorsInstallFlag'] = 'false';
            }
        }
        if (systemTable['SensorsInstallFlag'] === 'true') {
            var Event = vt('Event', Arg);
            var Data = vt('Data', Arg);
            if (Event === 'JJBXAppLoginRegister') {
                var SensorsLoginId = vt('SensorsLoginId', Data);
                globalTable['SensorsLoginFlag'] = 'true';
                picker.sensorsAnalyticsLogin(SensorsLoginId);
            } else {
                var JsonData = table2json(Data);
                picker.sensorsAnalyticsPointTrack(Event, JsonData);
            }
        } else {
        }
    }
};
lua_system.sensors_login = function () {
    if (vt('SensorsLoginFlag', globalTable) != 'true') {
        var SensorsLoginId = lua_system.sensors_login_id();
        if (SensorsLoginId != '') {
            var UserDataReportLoginArg = {
                Receiver: 'SensorsData',
                Event: 'JJBXAppLoginRegister',
                Data: { SensorsLoginId: SensorsLoginId }
            };
            lua_system.user_data_report(UserDataReportLoginArg);
        } else {
        }
    } else {
    }
};
lua_system.sensors_login_id = function () {
    var SensorsLoginId = vt('SensorsLoginId', globalTable);
    if (SensorsLoginId === '') {
        var orgFlag = vt('orgFlag', globalTable);
        var workid = vt('workid', globalTable);
        if (orgFlag != '' && workid != '') {
            if (orgFlag === '001') {
                SensorsLoginId = workid;
            } else {
                SensorsLoginId = orgFlag + ('-' + workid);
            }
        }
    }
    return SensorsLoginId;
};
lua_system.sensors_report = function (Arg) {
    var SensorsReportStyle = vt('sensors_report_style', configTable);
    if (SensorsReportStyle != '') {
        var Data = {
            SensorsLoginId: lua_system.sensors_login_id(),
            UserName: vt('userName', globalTable),
            WorkId: vt('workid', globalTable)
        };
        var Event = vt('Event', Arg);
        if (Event === 'JJBXAppOpenHtml' && string.find(SensorsReportStyle, '01')) {
            Data['ReportExplain'] = '打开网页';
            Data['PageUrl'] = vt('PageUrl', Arg);
            Data['PageName'] = vt('PageName', Arg);
        } else if (Event === 'JJBXAppOpenAppPage' && string.find(SensorsReportStyle, '01')) {
            Data['ReportExplain'] = '打开APP页面';
            Data['PageUrl'] = vt('PageUrl', Arg);
            Data['PageName'] = vt('PageName', Arg);
        } else if (Event === 'JJBXAppAlertMsg' && string.find(SensorsReportStyle, '02')) {
            Data['ReportExplain'] = 'APP提示消息';
            Data['AlertMsg'] = vt('AlertMsg', Arg);
        } else {
            return;
        }
        var UserDataReportArg = {
            Receiver: 'SensorsData',
            Event: Event,
            Data: Data
        };
        lua_system.user_data_report(UserDataReportArg);
    } else {
    }
};
lua_system.open_scan_by_camera = function (Arg) {
    var MatchRes = lua_system.check_app_func('picker_open_scan_by_camera');
    if (MatchRes === 'true') {
        var Arg = formatNull(Arg);
        var OpenArg = {
            BackFunc: vt('BackFunc', Arg),
            BackFuncArg: vt('BackFuncArg', Arg),
            ScanCallFunc: vt('ScanCallFunc', Arg),
            ScanCallFuncSetArg: vt('ScanCallFuncSetArg', Arg),
            ScanByAlbumTipText: vt('ScanByAlbumTipText', Arg, '从相册中导入二维码'),
            ScanTip1Text: vt('ScanTip1Text', Arg, '请对准二维码进行扫描'),
            ScanTip2Text: vt('ScanTip2Text', Arg, '放入框内\uFF0C自动扫描')
        };
        debug_alert('打开摄像头扫码参数' + foreach_arg2print(OpenArg));
        picker.open_scan_by_camera(table2json(OpenArg));
    } else {
        debug_alert('未安装扫码功能');
    }
};
lua_system.show_electronic_invoice_detail = function (ResParams) {
    var res = json2table(vt('responseBody', ResParams));
    close_loading();
    if (res['errorNo'] === '000000') {
        var InvoiceType = vt('InvoiceType', globalTable);
        if (InvoiceType === '0133' || InvoiceType === '0135') {
            invoke_page_donot_checkRepeat('jjbx_fpc/xhtml/jjbx_invoice_fileDetail_train.xhtml', page_callback, {
                invoiceFileDetail: res,
                InvoiceType: InvoiceType
            });
        } else if (InvoiceType === '0134') {
            invoke_page_donot_checkRepeat('jjbx_fpc/xhtml/jjbx_invoice_fileDetail_air.xhtml', page_callback, {
                invoiceFileDetail: res,
                InvoiceType: InvoiceType
            });
        } else {
            alert('未定义发票文件类型');
        }
    } else {
        alert(res['errorMsg']);
    }
};
lua_system.query_invoiceFile_detail = function (InvoiceType, FileOriginalPath) {
    var ReqParams = {};
    globalTable['InvoiceType'] = InvoiceType;
    ReqParams['ReqAddr'] = 'electronicInvoice/showElectronicInvoiceDetail';
    ReqParams['ReqUrlExplain'] = '根据发票号码和文件路劲查询文件信息';
    ReqParams['BusinessCall'] = lua_system.show_electronic_invoice_detail;
    var searchBillNo_params = {
        invoiceType: InvoiceType,
        path: FileOriginalPath
    };
    ReqParams['BusinessParams'] = table2json(searchBillNo_params);
    lua_jjbx.common_req(ReqParams);
};
lua_system.msgMarsRegister = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        ReqParams['ReqAddr'] = 'pubMessageService/msgMarsRegister';
        ReqParams['ReqUrlExplain'] = '消息推送注册成功后通知后台';
        ReqParams['BusinessCall'] = lua_system.msgMarsRegister;
        var MatchRes = lua_system.check_app_func('RYTL_get_push_token');
        var registerToken = '';
        if (MatchRes === 'true') {
            registerToken = RYTL.get_push_token();
        } else {
        }
        var msgMarsRegister_params = { appToken: registerToken };
        ReqParams['BusinessParams'] = table2json(msgMarsRegister_params);
        lua_jjbx.common_req(ReqParams);
    } else {
        var responseBody = json2table(vt('responseBody', ResParams));
        if (responseBody['errorNo'] === '000000') {
        } else {
            alert(responseBody['errorMsg']);
        }
    }
};
lua_system.checkSystemAuthority = function () {
    var MatchRes = lua_system.check_app_func('RYTL_open_system_settings');
    if (MatchRes === 'true') {
        RYTL.openSystemSettings();
    } else {
        var upverArg = {
            updateType: 'OPTION',
            updateMsg: '查看系统设置需要升级\uFF0C请更新后使用\u3002'
        };
        lua_ota.show_upvsr_view(upverArg);
    }
};
module.exports = { lua_system: lua_system };