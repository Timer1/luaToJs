const lua_page = require('./page');
const lua_format = require('./format');
const lua_system = require('./system');
const lua_ota = require('./ota');
lua_my = {};
lua_my.render_share_people_use_scene = function () {
    var SharePeopleUseSceneData = vt('SharePeopleUseSceneData', companyTable);
    var SharePeopleUseSceneDataCounts = SharePeopleUseSceneData.length;
    if (SharePeopleUseSceneDataCounts > 0) {
        var selectEleArg = {};
        for (var [key, value] in pairs(SharePeopleUseSceneData)) {
            var sycjContentcode = formatNull(value['sceneCode']);
            var sycjContentname = formatNull(value['label']);
            var sycjInfo = sycjContentcode + ('_' + sycjContentname);
            var selectEleArgItem = {
                labelName: sycjContentname,
                clickFunc: 'lua_my.select_share_people_scene',
                clickFuncArg: sycjInfo
            };
            table.insert(selectEleArg, selectEleArgItem);
        }
        var renderSelectArg = {
            bgName: 'sp_sycj_page_div',
            topEleName: 'top_sycj_div',
            topTitleName: '使用场景',
            selectEleName: 'sycj_list_div',
            selectEleArg: selectEleArg,
            renderCallBackFun: 'render_select_sycj_page_call',
            selectType: 'multiple',
            finishBtnStyle: 'BottomFullBtn',
            finishCall: 'select_sycj_finish_call()',
            backCall: 'none'
        };
        lua_page.render_select_page(renderSelectArg);
    }
    close_loading();
};
lua_my.select_share_people_scene = function (sycjInfo) {
    var sycjbm = '';
    var sycjname = '';
    var SharePeopleUseSceneData = vt('SharePeopleUseSceneData', companyTable);
    var SharePeopleUseSceneDataLen = SharePeopleUseSceneData.length;
    if (formatNull(sycjInfo) === '' || SharePeopleUseSceneData === '') {
        alert('无可用使用场景');
    } else {
        sycjbm = splitUtils(sycjInfo, '_')[1];
        sycjname = splitUtils(sycjInfo, '_')[2];
        var matchsycjIndex = '';
        for (let i = 1; SharePeopleUseSceneDataLen; i++) {
            var SharePeopleUseSceneData = formatNull(SharePeopleUseSceneData[i]);
            var sycjContentcode = vt('value', SharePeopleUseSceneData);
            if (sycjContentcode === sycjbm) {
                matchsycjIndex = tostring(i);
                break;
            }
        }
        if (matchsycjIndex != '') {
            var setsycjSelectArg = {
                showIndex: matchsycjIndex,
                selectTyle: 'multiple'
            };
            var selected = lua_page.set_item_selected(setsycjSelectArg);
            var saveIndex = tostring(matchsycjIndex);
            var saveInfo = '';
            if (selected === 'true') {
                saveInfo = sycjInfo;
            }
            globalTable['SelectSharePeopleSceneData'][saveIndex] = saveInfo;
            globalTable['SceneSelectFlag'] = '1';
            lua_my.update_selected_sycj();
        }
    }
};
lua_my.update_selected_sycj = function () {
    var sycj_selected_item_html = '';
    for (var [key, value] in pairs(globalTable['SelectSharePeopleSceneData'])) {
        if (value != '') {
            var info = splitUtils(value, '_');
            var sceneCode = formatNull(info[1]);
            var sceneName = formatNull(info[2]);
            sycj_selected_item_html = sycj_selected_item_html + ('[[\n                <div class="sycj_item_div" name="sycj_item_div" border="0">\n                    <label class="sycj_name_label" value="]]' + (sceneName + '[["></label>\n                </div>\n            ]]'));
        }
    }
    var sycj_selected_div_html = '[[\n        <div class="sycj_selected_div" name="sycj_selected_div" border="0" onclick="show_select_sharePeopleUseScene_page()">\n            ]]' + (sycj_selected_item_html + '[[\n        </div>\n    ]]');
    document.getElementsByName('sycj_selected_div')[1].setInnerHTML(sycj_selected_div_html);
    if (sycj_selected_item_html != '') {
        show_ele('sycj_selected_div');
        changeProperty('sycj', 'value', '');
    } else {
        hide_ele('sycj_selected_div');
        changeProperty('sycj', 'value', '请选择');
    }
    page_reload();
};
lua_my.format_send_share_people_scene = function () {
    var SelectSharePeopleSceneData = vt('SelectSharePeopleSceneData', globalTable);
    var sceneValue = '';
    if (SelectSharePeopleSceneData != '') {
        for (var [key, value] in pairs(SelectSharePeopleSceneData)) {
            if (value != '') {
                var info = splitUtils(value, '_');
                var sceneCode = formatNull(info[1]);
                if (sceneCode != '') {
                    if (sceneValue === '') {
                        sceneValue = sceneCode;
                    } else {
                        sceneValue = sceneValue + (',' + sceneCode);
                    }
                }
            }
        }
    }
    return sceneValue;
};
lua_my.confirm_del_share_people = function (ArgJson) {
    var Arg = json2table(lua_format.base64_decode(ArgJson));
    var ConfirmFlag = vt('ConfirmFlag', Arg);
    var UserPk = vt('UserPk', Arg);
    var DelCall = vt('DelCall', Arg);
    if (ConfirmFlag === '1') {
        lua_my.del_share_people('', {
            pkShareUser: UserPk,
            DelCall: DelCall
        });
    } else {
        Arg['ConfirmFlag'] = '1';
        var CallArgJson = lua_format.base64_encode(table2json(Arg));
        alert_confirm('', '是否确认删除共享人\uFF0C删除后将不可使用原账号密码登录极简报销', '取消', '确定', 'alert_confirm_call', 'CallFun=lua_my.confirm_del_share_people&CallArg=' + CallArgJson);
    }
};
lua_my.del_share_people = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['TranCode'] = 'delShareUser';
        invoke_trancode('jjbx_myInfo', 'share_people_manage', ReqParams, lua_my.del_share_people, { DelCall: vt('DelCall', ReqParams) }, all_callback, { CloseLoading: 'false' });
    } else {
        var res = json2table(ResParams['responseBody']);
        var DelCall = vt('DelCall', ResParams, 'back_fun');
        var errorNo = vt('errorNo', res);
        var errorMsg = vt('errorMsg', res);
        if (errorNo === '000000') {
            alertToast('0', C_DeleteMsg, '', DelCall, '');
        } else {
            alert(errorMsg);
        }
    }
};
lua_my.queryUserAuthInfo = function (ResParams, ReqParams) {
    var MatchRes = lua_system.check_app_func('ryt_relate_auth_manager');
    if (MatchRes === 'true') {
        if (JJBX_AliPayLoginRepeatAuth === 'PC') {
            if (formatNull(ResParams) === '') {
                var ReqParams = formatNull(ReqParams, {});
                ReqParams['TranCode'] = 'CommonInterfaceReq';
                ReqParams['ReqAddr'] = 'alipay/queryUserAuthInfo';
                ReqParams['ReqUrlExplain'] = '查询用户是否授权支付宝';
                invoke_trancode_donot_checkRepeat('jjbx_service', 'app_service', ReqParams, lua_my.queryUserAuthInfo, {}, all_callback, { CloseLoading: 'false' });
            } else {
                var res = json2table(ResParams['responseBody']);
                if (res['errorNo'] === '000000') {
                    var userAuth = vt('userAuth', res);
                    if (userAuth === '0') {
                        lua_my.generateAuthInfo();
                    } else {
                        alertToast0('已授权');
                    }
                } else {
                    alert(res['errorMsg']);
                }
            }
        } else {
            lua_my.generateAuthInfo();
        }
    } else {
        var upverArg = {
            updateType: 'OPTION',
            updateMsg: '授权服务已经升级\uFF0C请更新后使用\u3002'
        };
        lua_ota.show_upvsr_view(upverArg);
    }
};
lua_my.generateAuthInfo = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams, {});
        ReqParams['TranCode'] = 'CommonInterfaceReq';
        ReqParams['ReqAddr'] = 'alipay/generateAuthInfo';
        ReqParams['ReqUrlExplain'] = '生成支付宝授权authInfo';
        invoke_trancode_donot_checkRepeat('jjbx_service', 'app_service', ReqParams, lua_my.generateAuthInfo, {}, all_callback, { CloseLoading: 'false' });
    } else {
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            close_loading();
            var authInfo = vt('authInfo', res);
            var AuthArg = {
                CtrlType: 'AlipayLoginAuth',
                AuthInfo: authInfo,
                CtrlCall: 'alipay_login_auth_call',
                CtrlCallArg: ''
            };
            ryt.relate_auth_manager(table2json(AuthArg));
        } else {
            alert(res['errorMsg']);
        }
    }
};
module.exports = { lua_my: lua_my };