const lua_form = require('./form');
const lua_system = require('./system');
const lua_page = require('./page');
const lua_utils = require('./utils');
const lua_jjbx = require('./jjbx');
const lua_format = require('./format');
lua_travel = {};
lua_travel.arg_init_qry = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var travelXmdaData = vt('travelXmdaData', companyTable);
        var argListTable = [travelXmdaData];
        var checkArgRes = lua_form.arglist_check_empty(argListTable);
        var ReqParams = formatNull(ReqParams);
        var InitCallFun = vt('InitCallFun', ReqParams);
        if (checkArgRes === 'true') {
            lua_system.do_function(InitCallFun, '');
        } else {
            ReqParams['BusinessType'] = 'apply_travel';
            ReqParams['TranCode'] = 'ArgInitQry';
            invoke_trancode_donot_checkRepeat('jjbx_service', 'travel_service', ReqParams, lua_travel.arg_init_qry, {}, all_callback, { CloseLoading: 'false' });
        }
    } else {
        companyTable['TravelServiceArgInitStatus'] = 'true';
        var res = json2table(ResParams['responseBody']);
        if (res['TravelXmdaErrorNo'] === '000000') {
            var travelXmdaData = vt('TravelXmdaData', res);
            if (travelXmdaData === '') {
            } else {
                companyTable['travelXmdaData'] = travelXmdaData;
            }
        } else {
        }
        var InitCallFun = vt('InitCallFun', res);
        lua_system.do_function(InitCallFun, '');
    }
};
lua_travel.render_travel_style = function () {
    var tripTypeList = vt('tripTypeList', globalTable);
    if (tripTypeList != '') {
        var tripTypeListCounts = tripTypeList.length;
        if (tripTypeListCounts > 0) {
            var selectEleArg = {};
            for (var [key, value] in pairs(tripTypeList)) {
                var selectEleArgItem = {
                    labelName: vt('contentname', value),
                    clickFunc: 'lua_travel.travel_select_xclx',
                    clickFuncArg: tostring(key)
                };
                table.insert(selectEleArg, selectEleArgItem);
            }
            var renderSelectArg = {
                bgName: 'xclx_page',
                topEleName: 'top_xclx_div',
                topTitleName: '选择行程类型',
                selectEleName: 'xclx_content',
                selectEleArg: selectEleArg,
                renderCallBackFun: 'lua_travel.render_select_xclx_page_call'
            };
            lua_page.render_select_page(renderSelectArg);
            var TravelSelectXclxCacheArg = vt('TravelSelectXclxCacheArg', globalTable);
            if (TravelSelectXclxCacheArg != '') {
                if (vt('matchTripTypeIndex', TravelSelectXclxCacheArg) != '') {
                    lua_page.set_item_selected(vt('matchSetXclxSelectArg', TravelSelectXclxCacheArg));
                }
            }
        }
        close_loading();
    } else {
        alert('查询行程类型失败');
    }
};
lua_travel.render_select_xclx_page_call = function (Arg) {
};
lua_travel.travel_select_xclx = function (index) {
    var tripTypeList = vt('tripTypeList', globalTable);
    var tripTypeListCounts = tripTypeList.length;
    var selectXclx = formatNull(tripTypeList[parseFloat(index)]);
    var selectXclxContentcode = vt('contentcode', selectXclx);
    var selectXclxContentname = vt('contentname', selectXclx);
    var selectXclxFlag = vt('flag', selectXclx);
    var LastSelectContentcode = vt('contentcode', globalTable);
    if (selectXclxContentcode === LastSelectContentcode) {
        lua_page.div_page_ctrl();
    } else {
        var matchTripTypeIndex = lua_utils.table_data_match(tripTypeList, 'contentcode', selectXclxContentcode);
        globalTable['TravelSelectXclxCacheArg'] = {
            selectXclxContentcode: selectXclxContentcode,
            selectXclxContentname: selectXclxContentname,
            selectXclxFlag: selectXclxFlag,
            matchTripTypeIndex: matchTripTypeIndex,
            matchSetXclxSelectArg: { showIndex: matchTripTypeIndex }
        };
        var selectAlertMsg = '';
        if (formatNull(globalTable['xcmxList']).length === 0 || formatNull(globalTable['typechoose']) === '') {
            selectAlertMsg = '请确认已正确选择\uFF0C如后续返回修改\uFF0C将会清空已填写的行程明细信息\u3002';
        } else {
            selectAlertMsg = '如行程类型修改\uFF0C已填写行程明细信息将清空\uFF0C请确认是否修改\u3002';
        }
        alert_confirm('', selectAlertMsg, '取消', '确定', 'lua_travel.select_xclx_call');
    }
};
lua_travel.checkParam = function (ResParams, ReqParams) {
    if (ResParams === '') {
        ReqParams['ReqAddr'] = 'btTripApl/checkParam';
        ReqParams['ReqUrlExplain'] = '行程申请单提交前的参数校验';
        ReqParams['BusinessCall'] = lua_travel.checkParam;
        var checkParam_params = {
            appno: globalTable['XCSQbillNo'],
            flag: '1'
        };
        ReqParams['BusinessParams'] = table2json(checkParam_params);
        lua_jjbx.common_req(ReqParams);
    } else {
        var res = json2table(ResParams['responseBody']);
        if (vt('strParam', res) != '') {
            alert_confirm('温馨提示', res['strParam'], '取消', '确认', 'confirmCheckParam');
        } else {
            travel_apply_send('submit');
        }
    }
};
confirmCheckParam = function (index) {
    if (index === 1) {
        travel_apply_send('submit');
    }
};
lua_travel.do_travel_apply_send = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['BusinessType'] = 'apply_travel';
        ReqParams['TranCode'] = 'TravelapplySaveApplicationA';
        invoke_trancode_donot_checkRepeat('jjbx_service', 'travel_service', ReqParams, lua_travel.do_travel_apply_send, { checkParam: vt('checkParam', ReqParams, 'false') }, all_callback, { CloseLoading: 'false' });
    } else {
        var res = json2table(ResParams['responseBody']);
        var errorNo = vt('errorNo', res);
        var errorMsg = vt('errorMsg', res);
        var checkParam = ResParams['checkParam'];
        if (errorNo === '000000') {
            var submitFlag = vt('submitFlag', res);
            var submitErrorNo = vt('submitErrorNo', res);
            var submitErrorMsg = vt('submitErrorMsg', res);
            if (submitFlag === 'save') {
                if (checkParam != 'true') {
                    alertToast0(C_SavedMsg);
                } else {
                    lua_travel.checkParam('', {});
                }
            } else {
                if (submitErrorNo === '000000') {
                    if (vt('resultMessage', res) != '') {
                        alert(res['resultMessage']);
                    }
                    invoke_page('jjbx_travel_service/xhtml/travel_service_applySuccess.xhtml', page_callback, null);
                } else if (submitErrorNo === '300229') {
                    alert(submitErrorMsg);
                    invoke_page('jjbx_travel_service/xhtml/travel_service_applySuccess.xhtml', page_callback, null);
                } else {
                    alert(submitErrorMsg);
                }
            }
        } else {
            alert(errorMsg);
        }
    }
};
lua_travel.to_add_xcmx_page = function () {
    invoke_page('jjbx_travel_service/xhtml/travel_service_xcmx.xhtml', page_callback, { CloseLoading: 'false' });
};
lua_travel.do_delete_xcmx = function (ResParams) {
    if (formatNull(ResParams) === '') {
        invoke_trancode_donot_checkRepeat('jjbx_service', 'travel_service', {
            TranCode: 'TravelapplyDeleteDetail',
            BusinessType: 'apply_travel',
            tripappno: globalTable['XCSQbillNo'],
            pktripApplicationB: globalTable['pk_delete_B'],
            flag: '0'
        }, lua_travel.do_delete_xcmx, {});
    } else {
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            lua_travel.load_xcmx_list(ResParams);
        } else {
            alert(res['errorMsg']);
        }
        close_loading();
    }
};
lua_travel.do_delete_all_xcmx = function (ResParams) {
    if (formatNull(ResParams) === '') {
        invoke_trancode('jjbx_service', 'travel_service', {
            TranCode: 'TravelapplyDeleteDetail',
            BusinessType: 'apply_travel',
            tripappno: globalTable['XCSQbillNo'],
            flag: '1',
            pkCorp: globalTable['selectOrgList'][1]['pkCorp'],
            deptCode: globalTable['XCSQ_responseBody']['deptcode'],
            tripTypeCode: globalTable['contentcode']
        }, lua_travel.do_delete_all_xcmx, {}, all_callback, { CloseLoading: 'true' });
    } else {
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            changeProperty('xclx', 'value', globalTable['contentname']);
            changeStyle('xclx', 'color', '#4A4A4A');
            lua_travel.load_xcmx_list(ResParams);
        } else {
            alert(res['errorMsg']);
        }
    }
};
lua_travel.load_xcmx_list = function (ResParams) {
    var res = json2table(ResParams['responseBody']);
    if (res['errorNo'] === '000000') {
        globalTable['responseBody'] = res;
        globalTable['annexaddr'] = res['annexaddr'];
        var xcmxList = {};
        var list = formatNull(res['list'], {});
        if (list.length > 0) {
            for (var [key, value] in pairs(list)) {
                var xcmx = {
                    pkTripapplicationB: value['pkTripapplicationB'],
                    tripappno: value['tripappno'],
                    pkTripapplication: value['pkTripapplication'],
                    costundertaker: value['costundertaker'],
                    departuredate: value['departuredate'],
                    arrivaldate: value['arrivaldate'],
                    departurecity: value['departurecity'],
                    arrivalcity: value['arrivalcity'],
                    transportation: value['transportation'],
                    roomno: value['roomno'],
                    roomnight: value['roomnight'],
                    passenger: value['passenger'],
                    tripRule: value['tripRule'],
                    expenditureProject: value['expenditureProject'],
                    expenditureProjectCode: value['expenditureProjectCode'],
                    travelerList: {}
                };
                if (vt('tripRule', value) === '') {
                    xcmx.tripRule = '';
                }
                if (vt('expenditureProject', value) === '') {
                    xcmx.expenditureProject = '';
                }
                if (vt('expenditureProjectCode', value) === '') {
                    xcmx.expenditureProjectCode = '';
                }
                if (vt('passenger', value) === '') {
                    var travelerList = {};
                    var temp = '';
                    var flag = 'false';
                    for (var [key1, value1] in pairs(value['travelers'])) {
                        var traveler = {
                            employeeName: value1['travelername'],
                            workid: value1['travelercode'],
                            pkpsndoc: value1['pkPsndoc'],
                            pkCorp: value1['pkCorp'],
                            pkDept: value1['pkDept'],
                            corpCode: value1['corpCode'],
                            corpName: value1['corpName'],
                            deptCode: value1['deptCode'],
                            deptName: value1['deptName'],
                            borrowflag: value1['borrowflag']
                        };
                        table.insert(travelerList, traveler);
                        temp = temp + (value1['travelername'] + '\u3001');
                    }
                    xcmx.travelerList = travelerList;
                    xcmx.passenger = ryt.getSubstringValue(temp, 0, ryt.getLengthByStr(temp) - 1);
                }
                table.insert(xcmxList, xcmx);
            }
        }
        globalTable['xcmxList'] = xcmxList;
        lua_travel.render_xcmx_list();
    } else {
        alert(res['errorMsg']);
    }
};
lua_travel.render_xcmx_list = function () {
    var xcmxList = formatNull(globalTable['xcmxList'], {});
    var xcmxListCounts = xcmxList.length;
    var htmlOption = '';
    if (xcmxListCounts > 0) {
        changeStyle('add_xcmx', 'display', 'none');
        changeStyle('travel_list', 'display', 'block');
        for (var [key, value] in pairs(xcmxList)) {
            var arrowStyle = 'arrow_android_css';
            if (platform === 'iPhone OS') {
                arrowStyle = 'arrow_ios_css';
            }
            htmlOption = htmlOption + ('[[\n                <horiTableViewControl class="xcmx_delete" width=\'355\' divwidth=\'355\' divheight=\'210\' divwidth2=\'42\' value=\'0\'>\n                    <div class="blank200_css" border="1" onclick="jjbx_edit_xcmx(]]' + (key + ('[[)">\n                        <div class="blank40_css1" border="1"  onclick="jjbx_edit_xcmx(]]' + (key + ('[[)">\n                            <label class="blank40_title" value="行程]]' + (lua_format.an2cn(key) + ('[["></label>\n                            <label class="xcqx" value="]]' + (formatdate(1, value['departuredate']) + (' \u2014 ' + (formatdate(1, value['arrivaldate']) + ('[["></label>\n                            <img src="local:arrow_common.png" class="]]' + (arrowStyle + ('[[" />\n                        </div>\n                        <line class="line_css" />\n                        <div class="blank70_css"  onclick="jjbx_edit_xcmx(]]' + (key + ('[[)">\n                            <div class="height15" border="0"></div>\n                            <img src="local:sl_ico_13.png" class="sl_ico2" />\n                            <label class="blank18_css1" value="]]' + (cutStr(value['departurecity'], 17) + (' \u2014 ' + (cutStr(value['arrivalcity'], 17) + ('[["></label>\n                            <img src="local:sl_ico_14.png" class="sl_ico1" />\n                            <label class="blank18_css2" value="]]' + (cutStr(value['passenger'], 20) + ('[["></label>\n                            <img src="local:sl_ico_15.png" class="sl_ico3" />\n                            <label class="blank18_css3" value="]]' + (cutStr(value['transportation'], 20) + ('[["></label>\n                            <div class="cl_rule" border="0" onclick="jjbx_edit_xcmx(]]' + (key + ('[[)">\n                                <label class="card_ruleTitle">差旅标准\uFF1A</label>\n                                <label class="card_ruleDetail_hotel">]]' + ('酒店\u2014' + (cutStr(value['expenditureProject'], 30) + ('[[</label>\n                                <label class="card_ruleDetail_transport">]]' + ('交通\u2014' + (cutStr(value['expenditureProjectCode'], 47) + ('[[</label>\n                            </div>\n                        </div>\n                    </div>\n\n                    <div class="divRight_css" border="1" name="divRight" onclick="lua_travel.delete_xcmx_confirm(]]' + (key + '[[)">\n                        <label class="delete_msg">删除</label>\n                    </div>\n                </horiTableViewControl>\n                <div class="space_10_div" border="0"/>\n            ]]'))))))))))))))))))))))))))))))));
            if (key === xcmxListCounts && xcmxListCounts < 5) {
                htmlOption = htmlOption + '[[\n                    <div class="jk_msg_none" name=\'add_jk\' border="1" onclick="add_xcmx()">\n                        <img class="add_img" src="local:sl_ico_add.png" onclick="add_xcmx()" />\n                        <label class="center_label" onclick="add_xcmx()">添加行程明细</label>\n                    </div>\n                ]]';
            }
        }
    } else {
        changeStyle('add_xcmx', 'display', 'block');
        changeStyle('travel_list', 'display', 'none');
    }
    var htmlContent = '[[\n        <div class="contentDiv_css" name="travel_list" border="0">\n        ]]' + (htmlOption + '[[\n        </div>\n    ]]');
    document.getElementsByName('travel_list')[1].setInnerHTML(htmlContent);
    page_reload();
    close_loading();
};
lua_travel.delete_xcmx_confirm = function (index) {
    globalTable['pk_delete_B'] = globalTable['xcmxList'][parseFloat(index)].pkTripapplicationB;
    alert_confirm('', '当前操作会将该条已添加的行程明细删除,请谨慎操作!', '取消', '确定', 'lua_travel.delete_xcmx_button_call');
};
lua_travel.delete_xcmx_button_call = function (index) {
    if (tostring(index) === '1') {
        lua_travel.do_delete_xcmx();
    }
};
lua_travel.clear_travel_page_cache = function (flag) {
    if (flag === 'add_travel_apply') {
        globalTable['XCSQbillNo'] = '';
        globalTable['ts_xclx'] = '';
        globalTable['pktripApplicationB'] = '';
        globalTable['photoNum'] = '';
        globalTable['sy'] = '';
        globalTable['zdy'] = '';
        globalTable['pka'] = '';
        globalTable['xmdaName'] = '';
        globalTable['employeeInfoList'] = {};
        globalTable['usercode'] = null;
        globalTable['endCity'] = null;
        globalTable['startCity'] = null;
        globalTable['select_typechoose'] = null;
        globalTable['cdf'] = null;
        globalTable['servicetype'] = null;
        globalTable['serviceTypeCode'] = null;
        globalTable['startDate'] = null;
        globalTable['endDate'] = null;
        globalTable['roomno'] = null;
        globalTable['roomnight'] = null;
        globalTable['tranList'] = {};
        globalTable['budget'] = '';
        globalTable['typechoose'] = null;
        globalTable['fjzs'] = null;
        globalTable['uploadFlag'] = null;
        globalTable['XCSQ_responseBody'] = null;
        globalTable['pageConfig'] = null;
        globalTable['tripTypeList'] = null;
        globalTable['xcsq_deptcode'] = null;
        globalTable['oid'] = null;
        globalTable['isFkEm'] = null;
        globalTable['contentname'] = null;
        globalTable['contentcode'] = null;
        globalTable['triptypeName'] = null;
        globalTable['xcmx'] = null;
        globalTable['changePage'] = null;
    } else if (flag === 'edit_travel_apply') {
        globalTable['XCSQbillNo'] = '';
        globalTable['xclx'] = '';
        globalTable['ts_xclx'] = '';
        globalTable['firstPage'] = '';
        globalTable['pktripApplicationB'] = '';
        globalTable['photoNum'] = '';
        globalTable['sy'] = '';
        globalTable['zdy'] = '';
        globalTable['pka'] = '';
        globalTable['xmdaName'] = '';
        globalTable['employeeInfoList'] = {};
        globalTable['usercode'] = null;
        globalTable['endCity'] = null;
        globalTable['startCity'] = null;
        globalTable['select_typechoose'] = null;
        globalTable['cdf'] = null;
        globalTable['budget'] = '';
        globalTable['itembm'] = null;
        globalTable['servicetype'] = null;
        globalTable['serviceTypeCode'] = null;
        globalTable['startDate'] = null;
        globalTable['endDate'] = null;
        globalTable['roomno'] = null;
        globalTable['roomnight'] = null;
        globalTable['tranList'] = null;
        globalTable['typechoose'] = null;
        globalTable['fjzs'] = null;
        globalTable['uploadFlag'] = null;
        globalTable['XCSQ_responseBody'] = null;
        globalTable['pageConfig'] = null;
        globalTable['tripTypeList'] = null;
        globalTable['oid'] = null;
        globalTable['isFkEm'] = null;
        globalTable['contentname'] = null;
        globalTable['contentcode'] = null;
        globalTable['triptypeName'] = null;
        globalTable['xcmx'] = null;
        globalTable['sy_new'] = '';
        globalTable['zdy_new'] = '';
        globalTable['xmdaName_new'] = '';
        globalTable['xmdabm_new'] = '';
        globalTable['servicetype_new'] = '';
        globalTable['budget_new'] = '';
        globalTable['contentcode_new'] = '';
        globalTable['contentname_new'] = '';
        globalTable['changePage'] = null;
    } else {
    }
    globalTable['TravelSelectXclxCacheArg'] = null;
    globalTable['travelApplyCxrCtrl'] = null;
    globalTable['travelApplyYdjlInit'] = null;
    globalTable['travelApplyCdrUseSelfList'] = null;
    globalTable['travelApplyCdrModify'] = null;
    lua_format.reset_table(JJBX_BillApplyCdrParams);
    globalTable['travelApplyShowCdrInfo'] = null;
};
lua_travel.apply_form_check = function () {
    var sy = getValue('sy');
    var zdy = getValue('zdy');
    var triptypeName = getValue('xclx');
    var budget = getValue('budget');
    var servicetype = getValue('servicetype');
    var xmda = getValue('xmda');
    var cdrDisplay = getStyle('cdr_div', 'display');
    var cdrName = vt('feeTakerName', JJBX_BillApplyCdrParams);
    var checkRes = false;
    if (sy === '' && getValue('sy_required') === '*') {
        alert('请输入事由');
        checkRes = false;
    } else if (getValue('zdy_required') === '*' && (zdy === '' || zdy === '请输入')) {
        alert('请输入' + getValue('zdy_title'));
        checkRes = false;
    } else if (getValue('xclx_required') === '*' && (triptypeName === '' || triptypeName === '请选择')) {
        alert('请输入行程类型');
        checkRes = false;
    } else if (cdrDisplay === 'block' && cdrName === '') {
        alert('请选择承担人');
        checkRes = false;
    } else if (getValue('ywlx_required') === '*' && servicetype === '') {
        alert('请输入业务类型');
        checkRes = false;
    } else if (getValue('ygje_required') === '*' && budget === '') {
        alert('请输入' + getValue('ygje_title'));
        checkRes = false;
    } else if (getValue('xmda_required') === '*' && (xmda === '' || xmda === '请选择')) {
        alert('请输入项目档案');
        checkRes = false;
    } else if (parseFloat(globalTable['xcmxList'].length) === 0) {
        alert('请添加行程明细');
        checkRes = false;
    } else {
        checkRes = true;
    }
    return checkRes;
};
lua_travel.select_tarvel_xmda = function (params) {
    lua_page.div_page_ctrl();
    var codeAndName = splitUtils(params, ',');
    var xmdabm = '';
    var xmdaName = '';
    var listLen = codeAndName.length;
    if (listLen > 0) {
        for (let i = 1; listLen; i++) {
            if (i != listLen) {
                if (i === listLen - 1) {
                    xmdabm = codeAndName[i];
                }
            } else {
                xmdaName = codeAndName[i];
            }
        }
    }
    xmda.xmdaName = xmdaName;
    xmda.xmdabm = xmdabm;
    changeStyle('xmda', 'color', '#4A4A4A');
    changeProperty('xmda', 'value', formatNull(xmdaName, '请选择'));
    page_reload();
};
lua_travel.show_cdr_select_info = function () {
    var travelApplyShowSqrInfo = vt('travelApplyShowSqrInfo', globalTable);
    var travelApplyShowCdrInfo = vt('travelApplyShowCdrInfo', globalTable);
    var selectXclxContentcode = vt('contentcode', globalTable);
    var selectXclxContentname = vt('contentname', globalTable);
    var travelApplyCdrUseSelfList = vt('travelApplyCdrUseSelfList', globalTable);
    var travelApplyCdrModify = 'false';
    if (selectXclxContentcode != '' && string.find(travelApplyCdrUseSelfList, selectXclxContentcode)) {
        travelApplyCdrModify = 'true';
    }
    var res = vt('XCSQ_responseBody', globalTable);
    var CreateSearchPeoplePageArg = {
        ShowUser: 'false',
        DefaultShowCdrWrokId: vt('usercode', res),
        DefaultShowCdrInfo: vt('createUser', res) + ('\u3000' + vt('deptName', res)),
        TitleName: '选择承担人'
    };
    lua_page.create_search_people_page(CreateSearchPeoplePageArg);
    if (travelApplyCdrModify === 'true') {
        lua_travel.cdr_by_self();
        changeProperty('cdr', 'value', cutStr(globalTable['travelApplyShowCdrInfo'], 21));
        setEleLocation('cdr', 'right', '13');
        changeStyle('cdr', 'width', '300px');
        hide_ele('cdr_arrow_icon');
        globalTable['travelApplyCdrModify'] = 'false';
    } else {
        if (globalTable['travelApplyCdrModify'] === 'false' || vt('feeTakerName', JJBX_BillApplyCdrParams) === '') {
            changeProperty('cdr', 'value', '请选择');
            lua_format.reset_table(JJBX_BillApplyCdrParams);
        } else {
            changeProperty('cdr', 'value', cutStr(travelApplyShowCdrInfo, 19));
        }
        changeStyle('cdr', 'width', '270px');
        setEleLocation('cdr', 'right', '26');
        show_ele('cdr_arrow_icon');
        globalTable['travelApplyCdrModify'] = 'true';
    }
    page_reload();
};
lua_travel.cdr_by_self = function () {
    var res = vt('XCSQ_responseBody', globalTable);
    JJBX_BillApplyCdrParams.feeTakerName = vt('createUser', res);
    JJBX_BillApplyCdrParams.feeTakerCode = vt('usercode', res);
    JJBX_BillApplyCdrParams.feeTakerPk = vt('pkuser', res);
    JJBX_BillApplyCdrParams.feeTakerDeptName = vt('deptName', res);
    JJBX_BillApplyCdrParams.feeTakerDeptCode = vt('deptcode', res);
    JJBX_BillApplyCdrParams.feeTakerDeptPk = vt('corpcode', res);
    var travelApplyShowCdrInfo = vt('createUser', res) + ('\u3000' + vt('deptName', res));
    globalTable['travelApplyShowCdrInfo'] = travelApplyShowCdrInfo;
};
lua_travel.select_xclx_call = function (TouchIndex) {
    if (tostring(TouchIndex) === '1') {
        var TravelSelectXclxCacheArg = vt('TravelSelectXclxCacheArg', globalTable);
        globalTable['contentcode'] = vt('selectXclxContentcode', TravelSelectXclxCacheArg);
        globalTable['contentname'] = vt('selectXclxContentname', TravelSelectXclxCacheArg);
        globalTable['select_typechoose'] = vt('selectXclxFlag', TravelSelectXclxCacheArg);
        globalTable['typechoose'] = globalTable['select_typechoose'];
        if (vt('matchTripTypeIndex', TravelSelectXclxCacheArg) != '') {
            lua_page.set_item_selected(vt('matchSetXclxSelectArg', TravelSelectXclxCacheArg));
        }
        var travelApplyCxrCtrl = 'true';
        if (string.find(globalTable['travelApplyYdjlInit'], globalTable['contentcode'])) {
            travelApplyCxrCtrl = 'false';
        }
        globalTable['travelApplyCxrCtrl'] = travelApplyCxrCtrl;
        if (travelApplyCxrCtrl === 'true') {
            hide_ele('cdr_div');
            hide_ele('cdr_space_div');
            page_reload();
        } else {
            show_ele('cdr_div');
            show_ele('cdr_space_div');
            page_reload();
            lua_travel.show_cdr_select_info();
        }
        if (formatNull(globalTable['xcmxList']).length === 0 || formatNull(globalTable['typechoose']) === '') {
        } else {
            lua_travel.do_delete_all_xcmx();
        }
        var ywlx_display = document.getElementsByName('ywlx_div')[1].getStyleByName('display');
        if (ywlx_display === 'none') {
            lua_page.div_page_ctrl();
            globalTable['servicetype'] = '';
            globalTable['serviceTypeCode'] = '';
            changeProperty('xclx', 'value', globalTable['contentname']);
            changeStyle('xclx', 'color', '#4A4A4A');
            page_reload();
        } else {
            lua_travel.query_YWLX();
        }
    } else {
    }
};
lua_travel.query_YWLX = function (ResParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = {
            TranCode: 'QueryYWLX',
            BusinessType: 'apply_travel',
            pkCorp: globalTable['selectOrgList'][1]['pkCorp'],
            deptCode: globalTable['XCSQ_responseBody']['deptcode'],
            tripTypeCode: globalTable['contentcode']
        };
        invoke_trancode_donot_checkRepeat('jjbx_service', 'travel_service', ReqParams, lua_travel.query_YWLX, {}, all_callback, { CloseLoading: 'false' });
    } else {
        close_loading();
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            lua_page.div_page_ctrl();
            globalTable['servicetype'] = res['serviceType'];
            globalTable['serviceTypeCode'] = res['serviceTypeCode'];
            changeProperty('xclx', 'value', globalTable['contentname']);
            changeStyle('xclx', 'color', '#4A4A4A');
            changeProperty('servicetype', 'value', globalTable['servicetype']);
        } else {
            if (getValue('ywlx_required') === '*') {
                alert(res['errorMsg']);
            } else {
                lua_page.div_page_ctrl();
                globalTable['servicetype'] = formatNull(res['serviceType']);
                globalTable['serviceTypeCode'] = formatNull(res['serviceTypeCode']);
                changeProperty('servicetype', 'value', globalTable['servicetype']);
                changeProperty('xclx', 'value', globalTable['contentname']);
                changeStyle('xclx', 'color', '#4A4A4A');
                page_reload();
            }
        }
    }
};
lua_travel.show_search_people_page = function () {
    if (globalTable['travelApplyCdrModify'] != 'false' && globalTable['travelApplyCxrCtrl'] === 'false') {
        lua_page.div_page_ctrl('search_people_page_div', 'true', 'true');
    }
};
changeCDR = function (index) {
    if (index === 1) {
        var callArg = vt('cdrCallArg', globalTable);
        globalTable['cdrCallArg'] = null;
        lua_travel.select_cdr_call(callArg);
    }
};
lua_travel.select_cdr_call = function (callArg) {
    if (callArg === 'cdr_by_self') {
        lua_travel.cdr_by_self();
    } else {
        var name = vt('name', callArg);
        var deptName = vt('deptName', callArg);
        JJBX_BillApplyCdrParams.feeTakerName = name;
        JJBX_BillApplyCdrParams.feeTakerCode = vt('workid', callArg);
        JJBX_BillApplyCdrParams.feeTakerPk = vt('pkUser', callArg);
        JJBX_BillApplyCdrParams.feeTakerDeptName = deptName;
        JJBX_BillApplyCdrParams.feeTakerDeptCode = vt('deptCode', callArg);
        JJBX_BillApplyCdrParams.feeTakerDeptPk = vt('pkDept', callArg);
        globalTable['travelApplyShowCdrInfo'] = name + ('\u3000' + deptName);
    }
    changeProperty('cdr', 'value', globalTable['travelApplyShowCdrInfo']);
    lua_travel.updateTripStandardByFeeTaker('', {});
};
lua_travel.updateTripStandardByFeeTaker = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams, {});
        ReqParams['ReqAddr'] = 'btTripApply/updateTripStandardByFeeTaker';
        ReqParams['ReqUrlExplain'] = '更新差标';
        ReqParams['BusinessCall'] = lua_travel.updateTripStandardByFeeTaker;
        var BusinessParams = {
            tripNo: globalTable['XCSQbillNo'],
            feeTakerName: formatNull(JJBX_BillApplyCdrParams.feeTakerName),
            feeTakerCode: formatNull(JJBX_BillApplyCdrParams.feeTakerCode),
            feeTakerPk: formatNull(JJBX_BillApplyCdrParams.feeTakerPk),
            feeTakerDeptName: formatNull(JJBX_BillApplyCdrParams.feeTakerDeptName),
            feeTakerDeptCode: formatNull(JJBX_BillApplyCdrParams.feeTakerDeptCode),
            feeTakerDeptPk: formatNull(JJBX_BillApplyCdrParams.feeTakerDeptPk)
        };
        ReqParams['BusinessParams'] = table2json(BusinessParams);
        ReqParams['CloseLoading'] = 'false';
        lua_jjbx.common_req(ReqParams);
    } else {
        close_loading();
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            JJBX_BillApplyCdrParams.feeTakerNameTemp = JJBX_BillApplyCdrParams.feeTakerName;
            JJBX_BillApplyCdrParams.feeTakerCodeTemp = JJBX_BillApplyCdrParams.feeTakerCode;
            JJBX_BillApplyCdrParams.feeTakerPkTemp = JJBX_BillApplyCdrParams.feeTakerPk;
            JJBX_BillApplyCdrParams.feeTakerDeptNameTemp = JJBX_BillApplyCdrParams.feeTakerDeptName;
            JJBX_BillApplyCdrParams.feeTakerDeptCodeTemp = JJBX_BillApplyCdrParams.feeTakerDeptCode;
            JJBX_BillApplyCdrParams.feeTakerDeptPkTemp = JJBX_BillApplyCdrParams.feeTakerDeptPk;
            invoke_trancode_donot_checkRepeat('jjbx_service', 'travel_service', {
                BusinessType: 'apply_travel',
                TranCode: 'TravelapplyQueryDetail',
                billType: billTypeList_utils.xcsq,
                tripappno: globalTable['XCSQbillNo']
            }, lua_travel.load_xcmx_list, {}, all_callback, { CloseLoading: 'true' });
        } else {
            if (res['errorNo'] === '002223') {
                alert('该承担人未匹配到差标值\uFF0C请联系系统管理员维护后再修改\u3002');
            } else {
                alert(res['errorMsg']);
            }
            JJBX_BillApplyCdrParams.feeTakerName = JJBX_BillApplyCdrParams.feeTakerNameTemp;
            JJBX_BillApplyCdrParams.feeTakerCode = JJBX_BillApplyCdrParams.feeTakerCodeTemp;
            JJBX_BillApplyCdrParams.feeTakerPk = JJBX_BillApplyCdrParams.feeTakerPkTemp;
            JJBX_BillApplyCdrParams.feeTakerDeptName = JJBX_BillApplyCdrParams.feeTakerDeptNameTemp;
            JJBX_BillApplyCdrParams.feeTakerDeptCode = JJBX_BillApplyCdrParams.feeTakerDeptCodeTemp;
            JJBX_BillApplyCdrParams.feeTakerDeptPk = JJBX_BillApplyCdrParams.feeTakerDeptPkTemp;
            globalTable['travelApplyShowCdrInfo'] = JJBX_BillApplyCdrParams.feeTakerName + ('\u3000' + JJBX_BillApplyCdrParams.feeTakerDeptName);
            changeProperty('cdr', 'value', globalTable['travelApplyShowCdrInfo']);
        }
    }
};
lua_travel.to_ts_page = function (PageTag) {
    if (PageTag === 'xcsqxq') {
        invoke_page('jjbx_travel_service/xhtml/travel_service_proccess_bill_detail.xhtml', page_callback, { CloseLoading: 'false' });
    }
};
lua_travel.to_checkIn_record_page = function (XCSQBillNo, workID) {
    var XCSQBillNo = formatNull(XCSQBillNo);
    if (XCSQBillNo === '') {
        alert('行程申请单号为空');
    } else {
        var ReqParams = {
            CheckInBillNo: XCSQBillNo,
            QryPageType: 'CheckInRecordList',
            WorkID: workID
        };
        lua_travel.qry_checkin_record('', ReqParams);
    }
};
lua_travel.qry_checkin_record = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['TranCode'] = 'QryCheckinCity';
        ReqParams['BusinessType'] = 'travel_checkin';
        invoke_trancode('jjbx_service', 'travel_service', ReqParams, lua_travel.qry_checkin_record, {}, all_callback, { CloseLoading: 'false' });
    } else {
        var res = json2table(ResParams['responseBody']);
        var QueryCityErrorNo = vt('QueryCityErrorNo', res);
        var QueryCityErrorMsg = vt('QueryCityErrorMsg', res);
        if (QueryCityErrorNo != '000000') {
            alert(QueryCityErrorMsg);
        }
        var QueryClockInErrorNo = vt('QueryClockInErrorNo', res);
        var QueryClockInErrorMsg = vt('QueryClockInErrorMsg', res);
        if (QueryClockInErrorNo != '000000') {
            alert(QueryClockInErrorMsg);
        }
        if (QueryCityErrorNo === '000000' && QueryClockInErrorNo === '000000') {
            var CheckInAllCounts = formatNull(vt('CheckInAllCounts', res), 0);
            if (parseFloat(CheckInAllCounts) > 0) {
                globalTable['CheckInRecordInfoData'] = res;
                show_ele('checkInRecord_label');
            } else {
                hide_ele('checkInRecord_label');
            }
        }
    }
};
lua_travel.cityName_match = function (CityName1, CityName2) {
    var res = 'false';
    if (string.find(CityName1, CityName2)) {
        res = 'true';
    } else if (string.find(CityName2, CityName1)) {
        res = 'true';
    }
    return res;
};
lua_travel.show_checkin_locationInfo = function (LocationInfo) {
    var LocationInfoWidth = parseFloat(calculate_text_width(LocationInfo, '14'));
    setEleLocation('checkin_add_icon', 'right', tostring(18 + LocationInfoWidth));
    changeProperty('checkin_city_label', 'value', LocationInfo);
};
lua_travel.distance_m2km = function (meter) {
    var res = '';
    var meter = formatNull(meter, '0');
    res = tostring(float(meter / 1000, '1'));
    return res;
};
lua_travel.get_clockin_mode = function () {
    var travelClockInMode = vt('travelClockInMode', globalTable);
    if (travelClockInMode === '') {
        var PCConfigListsTable = vt('PCConfigListsTable', globalTable);
        var travelClockInMsg = vt('0457', PCConfigListsTable);
        if (travelClockInMsg === '定位打卡') {
            travelClockInMode = '1';
        } else if (travelClockInMsg === '定位+拍照打卡') {
            travelClockInMode = '2';
        } else {
            travelClockInMode = '0';
        }
        globalTable['travelClockInMode'] = travelClockInMode;
    }
    return travelClockInMode;
};
lua_travel.to_checkInRecordPage = function () {
    invoke_page('jjbx_travel_checkin/xhtml/checkin_record_list.xhtml', page_callback, {});
};
lua_travel.show_location_map = function (Arg) {
    var Arg = formatNull(Arg);
    var longitude = vt('longitude', Arg);
    var latitude = vt('latitude', Arg);
    var mapType = '';
    if (platform === 'iPhone OS') {
    } else if (platform === 'Android') {
    }
    if (longitude != '' && latitude != '') {
        var url = systemTable['JJBXH5_Addr'] + ('/clock-in-travel?' + ('longitude=' + (longitude + ('&latitude=' + (latitude + ('&mapType=' + (mapType + '')))))));
        lua_system.alert_webview({
            title: '打卡地点',
            visit_url: url
        });
    } else {
        alert('地点信息异常\uFF0C无法查看');
    }
    close_loading();
};
lua_travel.set_channel = function (Arg) {
    if (vt('TravelChannelFlag', globalTable) === '') {
        var Arg = formatNull(Arg);
        var btService = formatNull(companyTable['thirdPartyServiceStatus']['btService']);
        var TravelChannelFlag = vt('TravelChannelFlag', Arg);
        var channelList = splitUtils(TravelChannelFlag, ',');
        var xieChengFlag = 'false';
        var tongChengFlag = 'false';
        var aLiFlag = 'false';
        for (let i = 1; channelList.length; i++) {
            if (channelList[i] === '携程商旅') {
                xieChengFlag = 'true';
            } else if (channelList[i] === '同程商旅') {
                tongCheng = 'true';
            } else if (channelList[i] === '阿里商旅') {
                aLiFlag = 'true';
            }
        }
        var travelChannelList = {};
        if (configTable['ThirdServiceConfigSwitch'] === 'false') {
            for (let i = 1; 3; i++) {
                table.insert(travelChannelList, i);
            }
        } else {
            if (string.find(btService, '1') && xieChengFlag === 'true') {
                table.insert(travelChannelList, 1);
            }
            if (string.find(btService, '2') && tongCheng === 'true') {
                table.insert(travelChannelList, 2);
            }
            if (string.find(btService, '3') && aLiFlag === 'true') {
                table.insert(travelChannelList, 3);
            }
        }
        globalTable['TravelChannelFlag'] = travelChannelList;
    }
};
lua_travel.query_common_hint = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        ReqParams['ReqAddr'] = 'pubUserHint/queryCommonHint';
        ReqParams['ReqUrlExplain'] = '获取报销模式';
        ReqParams['BusinessCall'] = lua_travel.query_common_hint;
        var queryCommonHint_params = { channal: ReqParams['channal'] };
        ReqParams['BusinessParams'] = table2json(queryCommonHint_params);
        var Arg = {
            ProcessInvoiceIdListJson: vt('ProcessInvoiceIdListJson', ReqParams),
            billNo: vt('billNo', ReqParams)
        };
        ReqParams['ArgStr'] = lua_format.table_arg_pack(Arg);
        lua_jjbx.common_req(ReqParams);
    } else {
        close_loading();
        var responseBody = json2table(vt('responseBody', ResParams));
        if (responseBody['errorNo'] === '000000') {
            var ArgStr = vt('ArgStr', ResParams);
            ArgStr = lua_format.table_arg_unpack(ArgStr);
            ArgStr['value'] = vt('value', responseBody);
            ArgStr = lua_format.table_arg_pack(ArgStr);
            lua_travel.new_apply(ArgStr);
        } else {
            alert(responseBody['errorMsg']);
        }
    }
};
lua_travel.add_common_hint = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        ReqParams['ReqAddr'] = 'pubUserHint/addCommonHint';
        ReqParams['ReqUrlExplain'] = '切换报销模式';
        ReqParams['BusinessCall'] = lua_travel.add_common_hint;
        var addCommonHint_params = {
            channal: '010',
            value: ReqParams['value']
        };
        ReqParams['BusinessParams'] = table2json(addCommonHint_params);
        var Arg = {
            value: vt('value', ReqParams),
            billNo: vt('billNo', ReqParams),
            ProcessInvoiceIdListJson: vt('ProcessInvoiceIdListJson', ReqParams)
        };
        ReqParams['ArgStr'] = lua_format.table_arg_pack(Arg);
        lua_jjbx.common_req(ReqParams);
    } else {
        var responseBody = json2table(vt('responseBody', ResParams));
        if (responseBody['errorNo'] === '000000') {
            var ArgStr = vt('ArgStr', ResParams);
            lua_travel.new_apply(ArgStr);
        } else {
            alert(responseBody['errorMsg']);
        }
    }
};
lua_travel.new_apply = function (Arg) {
    var Arg = formatNull(Arg, {});
    Arg = lua_format.table_arg_unpack(Arg);
    Arg['CloseLoading'] = 'false';
    if (vt('value', Arg) === '0') {
        if (vt('billNo', Arg) != '') {
            globalTable['ifNewXCBX'] = 'false';
        } else {
            globalTable['ifNewXCBX'] = 'true';
        }
        globalTable['zdrbmInfo'] = null;
        invoke_page('jjbx_travel_reimbursement/xhtml/travel_service_reimbursement_submit_process.xhtml', page_callback, Arg);
    } else {
        globalTable['billNo_fbbx'] = '';
        globalTable['savePageCode'] = '';
        globalTable['temp_pageElement'] = {};
        globalTable['billSaveFlag'] = 'false';
        globalTable['btExpenditureDetailsListLength'] = 0;
        invoke_page('jjbx_travel_reimbursement/jjbx_travel_fbbx_001.xhtml', page_callback, Arg);
    }
};
lua_travel.update_tip_status = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['ReqAddr'] = 'ctripReqController/saveCtripPromptInfo';
        ReqParams['ReqUrlExplain'] = '设置商旅请求提示语不在显示';
        ReqParams.BusinessCall = lua_travel.update_tip_status;
        var params = {
            flag: ReqParams['flag'],
            value: ReqParams['value']
        };
        ReqParams['BusinessParams'] = table2json(params);
        lua_jjbx.common_req(ReqParams);
    } else {
        close_loading();
        var res = json2table(ResParams['responseBody']);
        if (vt('errorNo', res) != '000000') {
            alert(res['errorMsg']);
        }
    }
};
module.exports = { lua_travel: lua_travel };