const lua_system = require('./system');
lua_ota = {};
do_up_vsr = function (params) {
    var update_download_url = formatNull(systemTable['UpdateDownloadUrl']);
    if (update_download_url === '') {
        alert('下载失败\uFF0C找不到更新文件\u3002');
    } else {
        if (platform === 'iPhone OS') {
            system.openURL(update_download_url);
        } else {
            update.openDownLoad(update_download_url);
        }
    }
};
do_skip_up_vsr = function () {
    globalTable['skip_up_vsr'] = 'true';
    var SkipVersionUpdateCallFuc = vt('SkipVersionUpdateCallFuc', globalTable);
    var SkipVersionUpdateCallArg = vt('SkipVersionUpdateCallArg', globalTable);
    globalTable['SkipVersionUpdateCallFuc'] = '';
    globalTable['SkipVersionUpdateCallArg'] = '';
    lua_system.do_function(SkipVersionUpdateCallFuc, SkipVersionUpdateCallArg);
};
lua_ota.show_upvsr_view = function (Arg) {
    var updateType = vt('updateType', Arg);
    var updateMsg = vt('updateMsg', Arg, '已经发布新版本\uFF0C请及时更新\uFF01');
    var updateBtnText = vt('updateBtnText', Arg, '立即升级');
    var cancelBtnText = vt('cancelBtnText', Arg, '稍后提醒');
    var SkipVersionUpdateCallFuc = vt('SkipVersionUpdateCallFuc', Arg);
    var SkipVersionUpdateCallArg = vt('SkipVersionUpdateCallArg', Arg);
    globalTable['SkipVersionUpdateCallFuc'] = SkipVersionUpdateCallFuc;
    globalTable['SkipVersionUpdateCallArg'] = SkipVersionUpdateCallArg;
    var vsrCanSkip = '';
    if (updateType === 'MUST') {
        vsrCanSkip = '1';
    } else {
        vsrCanSkip = '0';
    }
    picker.updateAPPDialog(updateMsg, updateBtnText, cancelBtnText, vsrCanSkip, 'do_up_vsr', 'do_skip_up_vsr');
};
check_app_update = function () {
    var need_update = '';
    if (globalTable['skip_up_vsr'] != 'true') {
        if (systemTable['updateStatus'] === 'MUST') {
            need_update = 'MUST';
            var upverArg = { updateType: 'MUST' };
            lua_ota.show_upvsr_view(upverArg);
        } else if (systemTable['updateStatus'] === 'OPTION') {
            need_update = 'OPTION';
            var upverArg = { updateType: 'OPTION' };
            lua_ota.show_upvsr_view(upverArg);
        } else {
            need_update = '';
        }
    }
    return need_update;
};
lua_ota.version_ctrl = function (nowVersion, supportVersion) {
    var nowVersion = formatNull(nowVersion);
    var supportVersion = formatNull(supportVersion);
    var nowVersionPointLen = find_str_counts(nowVersion, '%.');
    var supportVersionPointLen = find_str_counts(supportVersion, '%.');
    var result = 'true';
    if (nowVersionPointLen === 2 && supportVersionPointLen === 2) {
        var nowVersionList = splitUtils(nowVersion, '%.');
        var supportVersionList = splitUtils(supportVersion, '%.');
        nowX = parseFloat(nowVersionList[1]);
        nowY = parseFloat(nowVersionList[2]);
        nowZ = parseFloat(nowVersionList[3]);
        supportX = parseFloat(supportVersionList[1]);
        supportY = parseFloat(supportVersionList[2]);
        supportZ = parseFloat(supportVersionList[3]);
        var XRes = '';
        var YRes = '';
        var ZRes = '';
        if (nowX > supportX) {
            XRes = 'false';
            result = 'true';
        } else if (supportX === nowX && nowY > supportY) {
            YRes = 'false';
            result = 'true';
        } else if (supportX === nowX && supportY === nowY && nowZ >= supportZ) {
            ZRes = 'false';
            result = 'true';
        } else {
            result = 'false';
        }
    }
    return result;
};
lua_ota.version_support = function (AppFunId) {
    var AppFunId = formatNull(AppFunId);
    var appSupport = 'true';
    var appSupportTipMsg = '';
    var nowVersion = systemTable['nowVersion'];
    var supportVersion = '';
    var VersionSupportConfig = vt('version_support_obj', globalTable);
    if (VersionSupportConfig != '') {
        var appSupportConf = vt(AppFunId, VersionSupportConfig);
        if (appSupportConf != '') {
            var appSupportConfVerName = '';
            var appSupportConfMsgName = '';
            if (platform === 'iPhone OS') {
                appSupportConfVerName = 'iPhone_ver';
                appSupportConfMsgName = 'iPhone_msg';
            } else {
                appSupportConfVerName = 'Android_ver';
                appSupportConfMsgName = 'Android_msg';
            }
            var appSupportConfVerValue = formatNull(appSupportConf[1][appSupportConfVerName]);
            supportVersion = appSupportConfVerValue;
            var appSupportConfMsgValue = formatNull(appSupportConf[1][appSupportConfMsgName]);
            appSupport = lua_ota.version_ctrl(nowVersion, appSupportConfVerValue);
            appSupportTipMsg = appSupportConfMsgValue;
        }
    }
    return {
        appSupport: appSupport,
        appSupportTipMsg: appSupportTipMsg,
        nowVersion: nowVersion,
        supportVersion: supportVersion
    };
};
module.exports = { lua_ota: lua_ota };