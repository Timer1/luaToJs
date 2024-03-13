const lua_system = require('./system');
const lua_login = require('./login');
const lua_page = require('./page');
lua_net = {};
request_type = 'page';
loadingtag = 3;
tempTable = null;
var INVOKE_STATUS = {
    START: 0,
    SUCCESS: 1,
    FAILURE: 2,
    FINISH: 3
};
invoke_trancode = function (channelId, tranCode, postParams, busiCallback, callbackParams, pagecallback, pagecallbackParams) {
    if (check_repeat_do_request_erl()) {
        var pagecallback = formatNull(pagecallback, all_callback);
        show_loading();
        do_invoke_trancode(channelId, tranCode, postParams, busiCallback, callbackParams, pagecallback, pagecallbackParams);
    }
};
invoke_trancode_donot_checkRepeat = function (channelId, tranCode, postParams, busiCallback, callbackParams, pagecallback, pagecallbackParams) {
    var pagecallback = formatNull(pagecallback, all_callback);
    show_loading();
    do_invoke_trancode(channelId, tranCode, postParams, busiCallback, callbackParams, pagecallback, pagecallbackParams);
};
invoke_trancode_noloading = function (channelId, tranCode, postParams, busiCallback, callbackParams, pagecallback, pagecallbackParams) {
    var pagecallback = formatNull(pagecallback, all_callback);
    do_invoke_trancode(channelId, tranCode, postParams, busiCallback, callbackParams, pagecallback, pagecallbackParams);
};
invoke_trancode_noloading_checkRepeat = function (channelId, tranCode, postParams, busiCallback, callbackParams, pagecallback, pagecallbackParams) {
    if (check_repeat_do_request_erl()) {
        var pagecallback = formatNull(pagecallback, all_callback);
        do_invoke_trancode(channelId, tranCode, postParams, busiCallback, callbackParams, pagecallback, pagecallbackParams);
    }
};
do_invoke_trancode = function (channelId, tranCode, postParams, busiCallback, callbackParams, pagecallback, pagecallbackParams) {
    if (systemTable['EnvAllowDebug'] === 'true') {
        if (busiCallback === null) {
            debug_alert('回调未定义' + ('\\n' + ('频道编号 : ' + (formatNull(channelId) + ('\\n' + ('交易代码 : ' + (formatNull(tranCode) + ('\\n' + ('请求参数 : ' + (foreach_arg2print(postParams) + ('\\n' + '')))))))))));
        }
    }
    var params = {};
    postParams['id'] = channelId;
    postParams['tranCode'] = tranCode;
    params.channelId = channelId;
    params.tranCode = tranCode;
    params.postParams = postParams;
    params.busiCallback = busiCallback;
    params.callbackParams = callbackParams;
    params.app_callback = busiCallback;
    params.pagecallbackParams = pagecallbackParams;
    var client_post = to_post_body(postParams);
    http.postAsyn(null, 'channel_s/run', client_post, pagecallback, params);
};
all_callback = function (params) {
    var responseCode = formatNull(params['responseCode']);
    var responseBody = formatNull(params['responseBody']);
    if (responseCode === 1599) {
        location.replace(responseBody, replace_callback, null);
    } else if (responseCode === 200) {
        var data_type = formatNull(get_format(responseBody));
        if (data_type === 'xml') {
            var pageParams = formatNull(params['pagecallbackParams']);
            var CloseLoading = formatNull(pageParams['CloseLoading'], 'true');
            var AddPage = formatNull(pageParams['AddPage'], 'true');
            var bodyPage = string.find(responseBody, '<body');
            if (bodyPage != null) {
                if (AddPage === 'true') {
                    history.add(responseBody);
                }
            }
            location.replace(responseBody);
            if (CloseLoading === 'true') {
                close_loading();
            }
        } else if (data_type === 'json') {
            need_auth(params);
        } else {
            invoke_callback_extra(params, INVOKE_STATUS['FAILURE']);
            debug_alert('数据异常');
            close_loading();
        }
    } else {
        invoke_callback_extra(params, INVOKE_STATUS['FAILURE']);
        close_loading();
        if (configTable['lua_debug'] === 'true') {
            debug_alert('数据请求异常\uFF0C请检查网络');
        } else {
            alert('网络不可用\uFF0C请检查网络');
        }
    }
};
back = function () {
    var page = history.get(-1);
    var afterpage = slt2.render(slt2.loadstring(page), null);
    location.replace(afterpage, transitionType.slideFromLeft);
};
go_page = function (index) {
    show_loading();
    var page = history.get(index);
    if ('iPhone OS' === getInfoPlatForm()) {
        var afterpage = slt2.render(slt2.loadstring(page), null);
        location.replace(afterpage, transitionType.slideFromLeft);
        close_loading();
    } else {
        var afterpage = slt2.render(slt2.loadstring(page), null);
        location.replace(afterpage, '', back_callback, {});
    }
};
back_callback = function (params) {
    close_loading();
};
to_post_body = function (params) {
    var post = '';
    var ret_post;
    if (params) {
        for (var [key, value] in pairs(params)) {
            console.log(key);
            post = post + (key + ('=' + (utility.escapeURI(value) + '&')));
        }
        ret_post = string.sub(post, 1, string.len(post) - 1);
    } else {
        ret_post = '';
    }
    return ret_post;
};
get_format = function (paramsStr) {
    if (string.find(paramsStr, '^%s*%{') != null) {
        return 'json';
    } else if (string.find(paramsStr, '^<%?xml ') != null) {
        return 'xml';
    } else {
        return null;
    }
};
need_auth = function (params) {
    var pageParams = formatNull(params['pagecallbackParams']);
    var CloseLoading = formatNull(pageParams['CloseLoading'], 'true');
    var AddPage = formatNull(pageParams['AddPage'], 'true');
    var ret_data = params['responseBody'];
    var jsonObj = json2table(ret_data);
    var ret_code = jsonObj['errorStatus'];
    var errorMsg = '';
    var errorCode = '';
    if (jsonObj['errorMsg']) {
        errorMsg = jsonObj['errorMsg'];
        errorCode = jsonObj['errorNO'];
    }
    params.callbackParams['responseBody'] = params['responseBody'];
    params.callbackParams['responseCode'] = params['responseCode'];
    if (ret_code === '0') {
        if (errorCode === 'APP0000') {
            alert('请求失败\uFF1A' + errorMsg);
            close_loading();
        } else {
            alert(errorMsg);
            close_loading();
            height_adapt('body', 0, 0);
            return;
        }
    } else {
        if (CloseLoading === 'true') {
            close_loading();
        }
        params.app_callback(params.callbackParams);
    }
};
errorCodeJudge = function (errorCode, errorMsg) {
    var errCodeTable = { EC9999: alertError };
    var errorMsgTable = { EC9999: '对不起\uFF0C系统发生未知错误\uFF01' };
};
alertError = function (errMsg) {
    debug_alert(errMsg);
};
replace_callback = function (params) {
    var CloseLoading = vt('CloseLoading', params);
    if (CloseLoading === 'true') {
        close_loading();
    }
};
invoke_callback_extra = function (params, stauts) {
    if (params['sendMsgName'] != null) {
        params.app_callback(params.callbackParams, stauts);
    }
};
invoke_page = function (page_file_path, fun_callback, fun_params) {
    if (check_repeat_do_request_page()) {
        show_loading();
        do_invoke_page(page_file_path, fun_callback, fun_params);
    }
};
invoke_page_donot_checkRepeat = function (page_file_path, fun_callback, fun_params) {
    show_loading();
    do_invoke_page(page_file_path, fun_callback, fun_params);
};
invoke_page_noloading = function (page_file_path, fun_callback, fun_params) {
    do_invoke_page(page_file_path, fun_callback, fun_params);
};
invoke_page_noloading_checkRepeat = function (page_file_path, fun_callback, fun_params) {
    if (check_repeat_do_request_page()) {
        do_invoke_page(page_file_path, fun_callback, fun_params);
    }
};
do_invoke_page = function (page_file_path, fun_callback, fun_params) {
    var fun_callback = formatNull(fun_callback, page_callback);
    var page_file_path = formatNull(page_file_path);
    var fun_params = formatNull(fun_params, {});
    lua_system.timer_unregister();
    var HistoryLength = parseFloat(history.length());
    if (page_file_path === 'jjbx_index/xhtml/jjbx_index.xhtml' || page_file_path === 'jjbx_myInfo/xhtml/myInfo.xhtml') {
        history.clear(HistoryLength);
        if (vt('loginSessionid', globalTable) === '') {
            lua_login.exit_login();
            return;
        }
    }
    fun_params['page_file_path'] = page_file_path;
    if (request_type === 'page') {
        do_request_page(page_file_path, fun_callback, fun_params);
    } else {
        do_request_data(page_file_path, fun_callback, fun_params);
    }
};
do_request_page = function (page_file_path, fun_callback, fun_params) {
    var path = 'name=' + utility.escapeURI('channels/' + page_file_path);
    ryt.post(null, 'page_s/get_page', path, fun_callback, fun_params, false);
};
do_request_data = function (page_file_path, fun_callback, fun_params) {
    var response = {};
    var page = null;
    if (file.isExist(page_file_path)) {
        response['responseCode'] = 200;
        page = file.read(page_file_path, 'text');
        response['responseBody'] = page;
        fun_callback(response);
    } else {
        do_request_page(page_file_path, fun_callback, fun_params);
    }
};
page_callback = function (params) {
    var params = formatNull(params);
    var JumpStyle = vt('JumpStyle', params);
    var AddPage = vt('AddPage', params, 'true');
    var CloseLoading = vt('CloseLoading', params, 'true');
    var ShowPageStyle = vt('ShowPageStyle', params, 'replace');
    var responseCode = vt('responseCode', params);
    var responseBody = vt('responseBody', params);
    if (responseCode === 1599) {
        close_loading();
        location.replace(responseBody);
    } else if (responseCode === 200) {
        if (string.find(responseBody, 'invalid file path')) {
            close_loading();
            debug_alert('页面异常');
        } else {
            if (AddPage === 'true') {
                history.add(responseBody);
                var HistoryLength = parseFloat(history.length());
                params['responseBody'] = '未添加返回包';
                params['responseHeader'] = '未添加返回头';
                pageinfoTable[HistoryLength] = params;
                var PageFilePath = vt('page_file_path', params);
                var PageInfo = lua_page.info(PageFilePath);
                var PageName = vt('PageName', PageInfo);
                if (PageName != '') {
                    var reportArg = {
                        Event: 'JJBXAppOpenAppPage',
                        PageUrl: PageFilePath,
                        PageName: PageName + '\uFF08配置\uFF09'
                    };
                    lua_system.sensors_report(reportArg);
                }
            }
            var afterpage = slt2.render(slt2.loadstring(responseBody), null);
            if (ShowPageStyle === 'replace') {
                page_sys_init();
                var UseJumpStyle = 'right';
                if (JumpStyle === '') {
                    UseJumpStyle = page_jump_style('right');
                } else {
                    UseJumpStyle = page_jump_style(JumpStyle);
                }
                location.replace(afterpage, UseJumpStyle, replace_callback, { CloseLoading: CloseLoading });
            } else if (ShowPageStyle === 'showContent') {
                var UseJumpStyle = page_jump_style(JumpStyle);
                window.showContent(afterpage, showContentIndex, UseJumpStyle);
                isShowContent = true;
                if (CloseLoading === 'true') {
                    close_loading();
                }
            }
        }
    } else {
        close_loading();
        if (configTable['lua_debug'] === 'true') {
            debug_alert('页面请求异常\uFF0C请检查网络');
        } else {
            alert('网络不可用\uFF0C请检查网络');
        }
    }
};
module.exports = { lua_net: lua_net };