const lua_form = require('./form');
const lua_system = require('./system');
const lua_format = require('./format');
const lua_page = require('./page');
lua_car = {};
C_CFSelectUseCarCompanyTip = '请选择出发公司';
C_CFSelectUseCarAddrTip = '请选择出发地点';
C_DDSelectUseCarCompanyTip = '请选择到达公司';
C_DDSelectUseCarAddrTip = '请选择到达地点';
C_SelectUseCarRuleTip = '请选择用车场景';
C_NoneUseCarRuleTip = '无可用的用车场景';
C_NoneUseCarYWCJTip = '无可用的业务场景';
C_QryAddrByCompanyTip = '当前公司暂未维护地址';
showDefaultUseExplain = '无使用说明';
businessUseCarTitle = '公务用车';
businessUseCarTip = '';
personalUseCarTitle = '自由出行';
personalUseCarTip = '';
defaultUseExplainTip = '使用说明';
defaultUseExplainPC = '不限';
defaultUseExplainAPP = '使用时段不限制';
defaultUseExplainAPP_geRen = '仅限支付宝个人支付';
useCarDebugBorder = '0';
useCarCardMsgDebug = 'false';
defaultDateStart = os.date('%Y-%m-%d', os.time());
defaultDateEnd = os.date('%Y-%m-%d', os.time() + 24 * 60 * 60);
businessCheckRuleTimeFlag = 'false';
personalCheckRuleTimeFlag = 'false';
useCarH5PageInitStyle = 'alert';
useCarSelectAddrH5PageInitStyle = 'alert';
useCarInitCfAddr = 'true';
addUseCarBillRes = '';
selectFirstOption = 'false';
selectUseCarRuleId = '';
chooseCompanyPkCorp = '';
useCarAddrFlag = '';
applicationYc = '';
applicationYcInitFlag = '';
showUseExplainLength = 20;
applyListCacheData = {};
useCarIndexCardCache = {
    BusinessCardIndex: '',
    BusinessCardRuleId: '',
    PersonalCardIndex: '',
    PersonalCardRuleId: ''
};
useCarLocationParams = {
    cf_addr_longitude: '',
    cf_addr_latitude: '',
    cf_addr_address: '',
    cf_addr_cityName: '',
    cf_addr_cityCode: '',
    cf_company_name: '',
    cf_company_code: '',
    cf_company_addrlist: '',
    dd_addr_longitude: '',
    dd_addr_latitude: '',
    dd_addr_address: '',
    dd_addr_cityName: '',
    dd_addr_cityCode: '',
    dd_company_name: '',
    dd_company_code: '',
    dd_company_addrlist: ''
};
SCBP = {
    TranCode: 'submitCarApplyBill',
    submitFlag: '',
    billType: '',
    didibillno: '',
    createuser: '',
    createdate: '',
    pkcorp: '',
    pkdept: '',
    dept: '',
    deptname: '',
    corpname: '',
    billstatusNo: '0',
    pkuser: '',
    locationstart: '',
    locationend: '',
    corpcode: '',
    createusercode: '',
    pkpsndoc: '',
    dateStart: defaultDateStart,
    reason: '',
    dateEnd: defaultDateEnd,
    tripDetail_ruleId: '',
    tripDetail_carScene: '',
    tripDetail_carSceneCode: '',
    tripDetail_businessScene: '',
    tripDetail_businessSceneCode: '',
    tripDetail_companyNameFrom: '',
    tripDetail_companyCodeFrom: '',
    tripDetail_lngFrom: '',
    tripDetail_latFrom: '',
    tripDetail_cityId: '',
    tripDetail_companyNameTo: '',
    tripDetail_companyCodeTo: '',
    tripDetail_lngTo: '',
    tripDetail_latTo: '',
    tripDetail_toCityId: '',
    tripDetail_ycfs: '0',
    tripDetail_yccs: '',
    tripDetail_carUseLimitCounts: ''
};
lua_car.arg_init_qry = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var useCarYWCJData = vt('useCarYWCJData', companyTable);
        var useCarYCCJData = vt('useCarYCCJData', companyTable);
        var CompanyListWidgetData = vt('CompanyListWidgetData', companyTable);
        var UseCarEnableChannels = vt('UseCarEnableChannels', companyTable);
        var argListTable = [
            useCarYWCJData,
            useCarYCCJData,
            CompanyListWidgetData,
            UseCarEnableChannels
        ];
        var checkArgRes = lua_form.arglist_check_empty(argListTable);
        var ReqParams = formatNull(ReqParams);
        var InitCallFun = vt('InitCallFun', ReqParams);
        if (checkArgRes === 'true') {
            lua_system.do_function(InitCallFun, '');
        } else {
            ReqParams['TranCode'] = 'ArgInitQry';
            invoke_trancode_donot_checkRepeat('jjbx_service', 'car_service', ReqParams, lua_car.arg_init_qry, {}, all_callback, { CloseLoading: 'false' });
        }
    } else {
        companyTable['CarServiceArgInitStatus'] = 'true';
        lua_format.reset_table(useCarIndexCardCache);
        var res = json2table(ResParams['responseBody']);
        if (res['YwcjDataErrorNo'] === '000000') {
            var useCarYWCJData = vt('YwcjData', res);
            if (useCarYWCJData === '') {
            } else {
                companyTable['useCarYWCJData'] = useCarYWCJData;
            }
        } else {
        }
        if (res['YccjDataErrorNo'] === '000000') {
            var useCarYCCJData = vt('YccjData', res);
            if (useCarYCCJData === '') {
            } else {
                companyTable['useCarYCCJData'] = useCarYCCJData;
            }
        } else {
        }
        if (res['CompanyDataErrorNo'] === '000000') {
            var CompanyData = vt('CompanyData', res);
            if (CompanyData === '') {
            } else {
                companyTable['CompanyListWidgetData'] = CompanyData;
            }
        } else {
        }
        var UseCarSelectMapUrl = vt('UseCarSelectMapUrl', res);
        var UseCarSelectMapDemoUrl = vt('UseCarSelectMapDemoUrl', res);
        if (systemTable['AppEnvironment'] != 'pro' && systemTable['PublicNetHost'] === 'false') {
            UseCarSelectMapUrl = UseCarSelectMapDemoUrl;
        }
        globalTable['UseCarSelectMapUrl'] = UseCarSelectMapUrl;
        lua_car.set_channel(res);
        var InitCallFun = vt('InitCallFun', res);
        lua_system.do_function(InitCallFun, '');
    }
};
lua_car.set_channel = function (Arg) {
    var Arg = formatNull(Arg);
    var DiDiEnable = 'false';
    var CaoCaoEnable = 'false';
    var SetUseCarEnableChannels = '03';
    var carService = formatNull(companyTable['thirdPartyServiceStatus']['carService']);
    var UseCarEnableChannels = vt('UseCarEnableChannels', Arg, '03');
    if (configTable['ThirdServiceConfigSwitch'] === 'false') {
        SetUseCarEnableChannels = '02';
    } else {
        if (string.find(carService, '1')) {
            if (string.find(UseCarEnableChannels, '01') || string.find(UseCarEnableChannels, '02')) {
                DiDiEnable = 'true';
            }
        }
        if (string.find(carService, '2')) {
            if (string.find(UseCarEnableChannels, '00') || string.find(UseCarEnableChannels, '02')) {
                CaoCaoEnable = 'true';
            }
        }
        if (DiDiEnable === 'true' && CaoCaoEnable === 'true') {
            SetUseCarEnableChannels = '02';
        } else if (DiDiEnable === 'true' && CaoCaoEnable === 'false') {
            SetUseCarEnableChannels = '01';
        } else if (DiDiEnable === 'false' && CaoCaoEnable === 'true') {
            SetUseCarEnableChannels = '00';
        }
    }
    companyTable['UseCarEnableChannels'] = SetUseCarEnableChannels;
};
lua_car.insert_apply_list_cache_data = function (key, value) {
    if (formatNull(key) != '') {
        var addItem = {
            key: key,
            value: value
        };
        table.insert(applyListCacheData, addItem);
    }
};
lua_car.reset_apply_list_cache_data = function () {
    applyListCacheData = {};
};
lua_car.find_apply_data = function (billNo) {
    var res = '';
    if (formatNull(billNo) != '') {
        for (var [key, value] in pairs(applyListCacheData)) {
            var dataKey = vt('key', value);
            if (billNo === dataKey) {
                var dataValue = vt('value', value);
                res = dataValue;
            }
        }
    }
    return res;
};
lua_car.render_select_addr_div = function () {
    var addressCtrlFlag = vt('addressCtrlFlag', globalTable);
    var select_addr_div_html = '';
    if (addressCtrlFlag === '01' || addressCtrlFlag === '02') {
        var start_location_type_switch_div_html = '';
        var end_location_type_switch_div_html = '';
        if (addressCtrlFlag === '01') {
            start_location_type_switch_div_html = '[[\n                <div class="choose_location_item_div" name="cfdd_div">\n                    <label class="ifRequired_css" name="cfdd_required">*</label>\n                    <label class="cfdd_title_label" name="cfdd_title" value="出发地点"></label>\n                    <div class="choose_location_type_div" border="0">\n                        <input type="button" class="choose_location_company_btn" value="公司" name="ycdd_type_btn" onclick="lua_car.location_type_switch(1)"/>\n                        <input type="button" class="choose_location_customer_btn" value="自定义" name="ycdd_type_btn" onclick="lua_car.location_type_switch(2)"/>\n                    </div>\n                </div>\n            ]]';
            end_location_type_switch_div_html = '[[\n                <div class="choose_location_item_div" name="dddd_div">\n                    <label class="ifRequired_css" name="dddd_required">*</label>\n                    <label class="dddd_title_label" name="dddd_title" value="到达地点"></label>\n                    <div class="choose_location_type_div" border="0">\n                        <input type="button" class="choose_location_company_btn" value="公司" name="ycdd_type_btn" onclick="lua_car.location_type_switch(3)"/>\n                        <input type="button" class="choose_location_customer_btn" value="自定义" name="ycdd_type_btn" onclick="lua_car.location_type_switch(4)"/>\n                    </div>\n                </div>\n            ]]';
        } else {
        }
        select_addr_div_html = start_location_type_switch_div_html + ('[[\n            <div class="choose_location_item_div" name="choose_cfdd_company_div" onclick="lua_car.choose_cfdd_company()">\n                <label class="ifRequired_css" name="company_required">*</label>\n                <label class="cfdd_choose_label" value="]]' + (C_CFSelectUseCarCompanyTip + ('[[" name="choose_cfdd_company_label" onclick="lua_car.choose_cfdd_company()" />\n                <img src="local:arrow_common.png" class=\'arrow_icon\'/>\n            </div>\n            <div class="choose_location_item_div" name="choose_cfdd_div" onclick="lua_car.choose_cfdd_addr()">\n                <label class="ifRequired_css" name="cfdd_required">*</label>\n                <label class="cfdd_choose_label" value="]]' + (C_CFSelectUseCarAddrTip + ('[[" name="choose_cfdd_addr_label" onclick="lua_car.choose_cfdd_addr()" />\n                <img src="local:arrow_common.png" class=\'arrow_icon\'/>\n            </div>\n            <line class="line_css" />\n\n            ]]' + (end_location_type_switch_div_html + ('[[\n            <div class="choose_location_item_div" name="choose_dddd_company_div" onclick="lua_car.choose_dddd_company()">\n                <label class="ifRequired_css" name="company_required">*</label>\n                <label class="cfdd_choose_label" value="]]' + (C_DDSelectUseCarCompanyTip + ('[[" name="choose_dddd_company_label" onclick="lua_car.choose_dddd_company()" />\n                <img src="local:arrow_common.png" class=\'arrow_icon\'/>\n            </div>\n            <div class="choose_location_item_div" name="choose_dddd_div" onclick="lua_car.choose_dddd_addr()">\n                <label class="ifRequired_css" name="dddd_required">*</label>\n                <label class="dddd_choose_label" value="]]' + (C_DDSelectUseCarAddrTip + '[[" name="choose_dddd_addr_label" onclick="lua_car.choose_dddd_addr()" />\n                <img src="local:arrow_common.png" class=\'arrow_icon\'/>\n            </div>\n        ]]'))))))))));
    } else {
        select_addr_div_html = '[[\n            <div class="choose_location_item_div" name="choose_cfdd_div" onclick="lua_car.choose_cfdd_addr()">\n                <label class="ifRequired_css" name="cfdd_required">*</label>\n                <label class="cfdd_choose_label" value="]]' + (C_CFSelectUseCarAddrTip + ('[[" name="choose_cfdd_addr_label" onclick="lua_car.choose_cfdd_addr()" />\n                <img src="local:arrow_common.png" class=\'arrow_icon\'/>\n            </div>\n            <line class="line_css" />\n\n            <div class="choose_location_item_div" name="choose_dddd_div" onclick="lua_car.choose_dddd_addr()">\n                <label class="ifRequired_css" name="dddd_required">*</label>\n                <label class="dddd_choose_label" value="]]' + (C_DDSelectUseCarAddrTip + '[[" name="choose_dddd_addr_label" onclick="lua_car.choose_dddd_addr()" />\n                <img src="local:arrow_common.png" class=\'arrow_icon\'/>\n            </div>\n        ]]')));
    }
    select_addr_div_html = '[[\n        <div class="choose_location_div" name="choose_location_div" border="1">\n            ]]' + (select_addr_div_html + '[[\n        </div>\n    ]]');
    document.getElementsByName('choose_location_div')[1].setInnerHTML(select_addr_div_html);
    page_reload();
    globalTable['useCarLocationTypeSwitchIndex'] = '';
    if (addressCtrlFlag === '01') {
        lua_car.location_type_switch(1);
    } else if (addressCtrlFlag === '02') {
        lua_car.select_current_company('all');
    } else {
    }
};
lua_car.init_cfdd_addr = function (params) {
    if (useCarInitCfAddr === 'true') {
        if (formatNull(params) === '' && systemTable['location_cityCode'] === '') {
            var cityName = vt('location_cityName', systemTable);
            if (cityName != '') {
                invoke_trancode_donot_checkRepeat('jjbx_service', 'app_service', {
                    TranCode: 'QryCityInfoByCityName',
                    cityName: cityName
                }, lua_car.init_cfdd_addr, {}, all_callback, { CloseLoading: 'false' });
            } else {
                close_loading();
            }
        } else {
            var cityName = '';
            var cityCode = '';
            if (formatNull(params) === '' && systemTable['location_cityCode'] != '') {
                cityName = vt('location_cityName', systemTable);
                cityCode = vt('location_cityCode', systemTable);
            } else {
                var res = json2table(params['responseBody']);
                var cityInfo = vt('cityInfo', res);
                cityName = vt('cityName', cityInfo);
                cityCode = vt('cityCode', cityInfo);
                systemTable['location_cityCode'] = cityCode;
            }
            var longitude = vt('location_longitude', systemTable);
            var latitude = vt('location_latitude', systemTable);
            var addr = vt('location_addr', systemTable);
            var cfddCtrlCityCodes = formatNull(globalTable['cfddCtrlCityCodes']);
            var cityCodeCheckRes = formatNull(parseFloat(cityCode));
            changeProperty('choose_cfdd_addr_label', 'value', C_CFSelectUseCarAddrTip);
            lua_format.reset_table(useCarLocationParams);
            if (cityCodeCheckRes != '') {
                if (cfddCtrlCityCodes === '' || cfddCtrlCityCodes != '' && string.find(cfddCtrlCityCodes, cityCode)) {
                    var argListTable = [
                        longitude,
                        latitude,
                        addr,
                        cityName,
                        cityCode
                    ];
                    if (lua_form.arglist_check_empty(argListTable) === 'true') {
                        useCarLocationParams.cf_addr_longitude = longitude;
                        useCarLocationParams.cf_addr_latitude = latitude;
                        useCarLocationParams.cf_addr_address = addr;
                        useCarLocationParams.cf_addr_cityName = cityName;
                        useCarLocationParams.cf_addr_cityCode = cityCode;
                        changeProperty('choose_cfdd_addr_label', 'value', addr);
                    }
                } else {
                }
            } else {
            }
            close_loading();
        }
    } else {
        close_loading();
    }
};
lua_car.location_type_switch = function (index) {
    var useCarLocationTypeSwitchIndex = vt('useCarLocationTypeSwitchIndex', globalTable);
    var index = formatNull(index);
    if (useCarLocationTypeSwitchIndex != '' && string.find(useCarLocationTypeSwitchIndex, tostring(index))) {
    } else {
        var locationTypeEles = document.getElementsByName('ycdd_type_btn');
        var addressCtrlFlag = vt('addressCtrlFlag', globalTable);
        if (addressCtrlFlag === '01') {
            if (index === 1 || index === 4) {
                globalTable['useCarLocationTypeSwitchIndex'] = '14';
                useCarAddrFlag = 1;
                show_ele('choose_cfdd_company_div');
                changeProperty('choose_cfdd_company_label', 'value', C_CFSelectUseCarCompanyTip);
                changeProperty('choose_cfdd_addr_label', 'value', C_CFSelectUseCarAddrTip);
                hide_ele('choose_dddd_company_div');
                changeProperty('choose_dddd_addr_label', 'value', C_DDSelectUseCarAddrTip);
                locationTypeEles[1].setStyleByName('background-image', 'car_checked.png');
                locationTypeEles[1].setStyleByName('color', '#FE6F14');
                locationTypeEles[4].setStyleByName('background-image', 'car_checked.png');
                locationTypeEles[4].setStyleByName('color', '#FE6F14');
                locationTypeEles[2].setStyleByName('background-image', 'car_checkBg.png');
                locationTypeEles[2].setStyleByName('color', '#999999');
                locationTypeEles[3].setStyleByName('background-image', 'car_checkBg.png');
                locationTypeEles[3].setStyleByName('color', '#999999');
            } else if (index === 2 || index === 3) {
                globalTable['useCarLocationTypeSwitchIndex'] = '23';
                useCarAddrFlag = 2;
                show_ele('choose_dddd_company_div');
                changeProperty('choose_dddd_company_label', 'value', C_DDSelectUseCarCompanyTip);
                changeProperty('choose_dddd_addr_label', 'value', C_DDSelectUseCarAddrTip);
                hide_ele('choose_cfdd_company_div');
                changeProperty('choose_cfdd_addr_label', 'value', C_CFSelectUseCarAddrTip);
                locationTypeEles[2].setStyleByName('background-image', 'car_checked.png');
                locationTypeEles[2].setStyleByName('color', '#FE6F14');
                locationTypeEles[3].setStyleByName('background-image', 'car_checked.png');
                locationTypeEles[3].setStyleByName('color', '#FE6F14');
                locationTypeEles[1].setStyleByName('background-image', 'car_checkBg.png');
                locationTypeEles[1].setStyleByName('color', '#999999');
                locationTypeEles[4].setStyleByName('background-image', 'car_checkBg.png');
                locationTypeEles[4].setStyleByName('color', '#999999');
            } else {
            }
        } else {
        }
        changeProperty('choose_cfdd_company_label', 'value', C_CFSelectUseCarCompanyTip);
        changeProperty('choose_cfdd_addr_label', 'value', C_CFSelectUseCarAddrTip);
        changeProperty('choose_dddd_company_label', 'value', C_DDSelectUseCarCompanyTip);
        changeProperty('choose_dddd_addr_label', 'value', C_DDSelectUseCarAddrTip);
        lua_format.reset_table(useCarLocationParams);
        if (formatNull(SCBP) != '') {
            SCBP.tripDetail_lngFrom = '';
            SCBP.tripDetail_latFrom = '';
            SCBP.locationstart = '';
            SCBP.tripDetail_lngTo = '';
            SCBP.tripDetail_latTo = '';
            SCBP.locationend = '';
        }
        if (index === 1 || index === 4) {
            lua_car.select_current_company('cfdd');
        }
        page_reload();
    }
};
lua_car.choose_cfdd_company = function () {
    if (globalTable['setCityCtrlType'] != 'index') {
        if (SCBP.tripDetail_ruleId === '') {
            alert(C_SelectUseCarRuleTip);
            return;
        }
    }
    lua_page.div_page_ctrl('cfdd_company_page_bg_div', 'true', 'true');
};
lua_car.choose_dddd_company = function () {
    if (globalTable['setCityCtrlType'] != 'index') {
        if (SCBP.tripDetail_ruleId === '') {
            alert(C_SelectUseCarRuleTip);
            return;
        }
    }
    var checkCfddArgTable = [
        useCarLocationParams.cf_addr_longitude,
        useCarLocationParams.cf_addr_latitude,
        useCarLocationParams.cf_addr_address,
        useCarLocationParams.cf_addr_cityCode
    ];
    if (lua_form.arglist_check_empty(checkCfddArgTable) != 'true') {
        alert('请先选择出发地点');
        return;
    }
    lua_page.div_page_ctrl('dddd_company_page_bg_div', 'true', 'true');
};
lua_car.choose_cfdd_addr = function () {
    if (globalTable['setCityCtrlType'] != 'index') {
        if (SCBP.tripDetail_ruleId === '') {
            alert(C_SelectUseCarRuleTip);
            return;
        }
    }
    var addressCtrlFlag = formatNull(globalTable['addressCtrlFlag']);
    var useCarAddrFlagNow = formatNull(useCarAddrFlag);
    var useCfddAddrList = formatNull(useCarLocationParams.cf_company_addrlist);
    var chooseCfddAddrTip = '无可选出发地点\uFF0C请重新选择公司';
    if (addressCtrlFlag === '01') {
        if (useCarAddrFlagNow === 1) {
            if (useCfddAddrList.length > 0) {
                lua_page.div_page_ctrl('cfdd_addr_list_page_div', 'true', 'true');
            } else {
                alert(chooseCfddAddrTip);
            }
        } else {
            lua_car.select_use_car_city_by_h5('cfdd');
        }
    } else if (addressCtrlFlag === '02') {
        if (useCfddAddrList.length > 0) {
            lua_page.div_page_ctrl('cfdd_addr_list_page_div', 'true', 'true');
        } else {
            alert(chooseCfddAddrTip);
        }
    } else {
        lua_car.select_use_car_city_by_h5('cfdd');
    }
};
lua_car.choose_dddd_addr = function () {
    if (globalTable['setCityCtrlType'] != 'index') {
        if (SCBP.tripDetail_ruleId === '') {
            alert(C_SelectUseCarRuleTip);
            return;
        }
    }
    var checkCfddArgTable = [
        useCarLocationParams.cf_addr_longitude,
        useCarLocationParams.cf_addr_latitude,
        useCarLocationParams.cf_addr_address,
        useCarLocationParams.cf_addr_cityCode
    ];
    if (lua_form.arglist_check_empty(checkCfddArgTable) != 'true') {
        alert('请先选择出发地点');
        return;
    }
    var useCarAddrFlagNow = formatNull(useCarAddrFlag);
    var useDdddAddrList = formatNull(useCarLocationParams.dd_company_addrlist);
    var addressCtrlFlag = formatNull(globalTable['addressCtrlFlag']);
    var crossCityCtrlFlag = formatNull(globalTable['crossCityCtrlFlag'], '01');
    if (crossCityCtrlFlag === '00') {
        globalTable['ddddCtrlCityCodes'] = formatNull(useCarLocationParams.cf_addr_cityCode);
        globalTable['ddddCtrlCityNames'] = formatNull(useCarLocationParams.cf_addr_cityName);
    } else {
    }
    var chooseDdddAddrTip = '无可选到达地点\uFF0C请重新选择公司';
    if (addressCtrlFlag === '01') {
        if (useCarAddrFlagNow === 2) {
            if (useDdddAddrList.length > 0) {
                lua_page.div_page_ctrl('dddd_addr_list_page_div', 'true', 'true');
            } else {
                alert(chooseDdddAddrTip);
            }
        } else {
            lua_car.select_use_car_city_by_h5('dddd');
        }
    } else if (addressCtrlFlag === '02') {
        if (useDdddAddrList.length > 0) {
            lua_page.div_page_ctrl('dddd_addr_list_page_div', 'true', 'true');
        } else {
            alert(chooseDdddAddrTip);
        }
    } else {
        lua_car.select_use_car_city_by_h5('dddd');
    }
};
lua_car.select_use_car_addr = function (companyType, index) {
    lua_page.div_page_ctrl();
    var companyType = formatNull(companyType);
    var addrInfo = '';
    if (companyType === 'cfdd') {
        addrInfo = formatNull(useCarLocationParams.cf_company_addrlist[parseFloat(index)]);
    } else if (companyType === 'dddd') {
        addrInfo = formatNull(useCarLocationParams.dd_company_addrlist[parseFloat(index)]);
    } else {
    }
    var addrLongitude = vt('lng', addrInfo);
    var addrLatitude = vt('lat', addrInfo);
    var address = vt('address', addrInfo);
    var building = vt('building', addrInfo);
    var cityCode = vt('city', addrInfo);
    var cityName = '';
    var addressCtrlFlag = formatNull(globalTable['addressCtrlFlag']);
    var crossCityCtrlFlag = formatNull(globalTable['crossCityCtrlFlag']);
    var cfddCtrlCityCodes = formatNull(globalTable['cfddCtrlCityCodes']);
    var cfddCtrlCityNames = formatNull(globalTable['cfddCtrlCityNames']);
    var ddddCtrlCityCodes = formatNull(globalTable['ddddCtrlCityCodes']);
    var ddddCtrlCityNames = formatNull(globalTable['ddddCtrlCityNames']);
    var useChooseCompanyPkCorp = formatNull(chooseCompanyPkCorp);
    if (crossCityCtrlFlag === '00' && companyType === 'cfdd') {
        globalTable['cfddCtrlCityCodes'] = cityCode;
        globalTable['cfddCtrlCityNames'] = cityName;
    }
    if (companyType === 'cfdd') {
        useCarLocationParams.cf_addr_longitude = addrLongitude;
        useCarLocationParams.cf_addr_latitude = addrLatitude;
        useCarLocationParams.cf_addr_address = address;
        useCarLocationParams.cf_addr_cityCode = cityCode;
        if (address != '') {
            changeProperty('choose_cfdd_addr_label', 'value', address);
        }
        if (globalTable['crossCityCtrlFlag'] === '00') {
            lua_car.clear_use_addr_info('dddd', 'all');
        }
    } else if (companyType === 'dddd') {
        useCarLocationParams.dd_addr_longitude = addrLongitude;
        useCarLocationParams.dd_addr_latitude = addrLatitude;
        useCarLocationParams.dd_addr_address = address;
        useCarLocationParams.dd_addr_cityCode = cityCode;
        if (address != '') {
            changeProperty('choose_dddd_addr_label', 'value', address);
        }
    }
};
lua_car.qry_addr_by_company = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var companyType = vt('companyType', ReqParams);
        var companyName = vt('companyName', ReqParams);
        var companyPkCorp = vt('companyPkCorp', ReqParams);
        var clearFlag = vt('clearFlag', ReqParams, 'true');
        var addressCtrlFlag = formatNull(globalTable['addressCtrlFlag']);
        var crossCityCtrlFlag = formatNull(globalTable['crossCityCtrlFlag']);
        var cfddCtrlCityCodes = formatNull(globalTable['cfddCtrlCityCodes']);
        var cfddCtrlCityNames = formatNull(globalTable['cfddCtrlCityNames']);
        var ddddCtrlCityCodes = formatNull(globalTable['ddddCtrlCityCodes']);
        var ddddCtrlCityNames = formatNull(globalTable['ddddCtrlCityNames']);
        var useChooseCompanyPkCorp = formatNull(chooseCompanyPkCorp, companyPkCorp);
        var useQryCityCodes = '';
        var useQryCityNames = '';
        if (crossCityCtrlFlag === '00') {
            if (companyType === 'dddd') {
                useQryCityCodes = cfddCtrlCityCodes;
                useQryCityNames = cfddCtrlCityNames;
            } else if (companyType === 'cfdd') {
                if (addressCtrlFlag === '01' || addressCtrlFlag === '02') {
                } else {
                    useQryCityCodes = cfddCtrlCityCodes;
                    useQryCityNames = cfddCtrlCityNames;
                }
            } else {
            }
        } else {
            if (companyType === 'cfdd') {
                useQryCityCodes = cfddCtrlCityCodes;
                useQryCityNames = cfddCtrlCityNames;
            } else if (companyType === 'dddd') {
                useQryCityCodes = ddddCtrlCityCodes;
                useQryCityNames = ddddCtrlCityNames;
            } else {
            }
        }
        if (useChooseCompanyPkCorp != '') {
            invoke_trancode_donot_checkRepeat('jjbx_service', 'app_service', {
                TranCode: 'qryAddress',
                pkCorp: useChooseCompanyPkCorp,
                cityCodes: useQryCityCodes,
                cityNames: useQryCityNames,
                companyType: companyType,
                companyName: companyName,
                companyPkCorp: companyPkCorp,
                clearFlag: clearFlag
            }, lua_car.qry_addr_by_company, {}, all_callback, { CloseLoading: 'false' });
        } else {
            alert('请先选择公司');
        }
    } else {
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            close_loading();
            var crossCityCtrlFlag = formatNull(globalTable['crossCityCtrlFlag']);
            var addressList = vt('addressList', res);
            var cityCodes = vt('cityCodes', res);
            var cityNames = vt('cityNames', res);
            var companyType = vt('companyType', res);
            var companyName = vt('companyName', res);
            var companyPkCorp = vt('companyPkCorp', res);
            var clearFlag = vt('clearFlag', res);
            if (addressList.length > 0) {
                lua_page.div_page_ctrl();
                if (companyType === 'cfdd') {
                    useCarLocationParams.cf_company_name = companyName;
                    useCarLocationParams.cf_company_code = companyPkCorp;
                    useCarLocationParams.cf_company_addrlist = addressList;
                    if (clearFlag === 'true') {
                        lua_car.clear_use_addr_info('cfdd', 'addr');
                        if (crossCityCtrlFlag === '00') {
                            lua_car.clear_use_addr_info('dddd', 'all');
                        }
                    }
                } else if (companyType === 'dddd') {
                    useCarLocationParams.dd_company_name = companyName;
                    useCarLocationParams.dd_company_code = companyPkCorp;
                    useCarLocationParams.dd_company_addrlist = addressList;
                    if (clearFlag === 'true') {
                        lua_car.clear_use_addr_info('dddd', 'addr');
                    }
                }
                lua_car.render_select_addr_page(companyType, addressList);
            } else {
                if (companyType === 'cfdd') {
                    lua_car.clear_use_addr_info('cfdd', 'all');
                    lua_car.clear_use_addr_info('dddd', 'all');
                } else if (companyType === 'dddd') {
                    lua_car.clear_use_addr_info('dddd', 'all');
                }
                if (companyType === 'cfdd') {
                    alert(C_QryAddrByCompanyTip);
                } else if (companyType === 'dddd') {
                    if (crossCityCtrlFlag === '00') {
                        if (cityCodes === '' || cityNames === '') {
                            alert('不允许跨城用车\uFF0C出发地点为' + (useCarLocationParams.cf_addr_address + '\uFF0C请选择与出发地相同城市的公司'));
                        } else {
                            alert('不允许跨城用车\uFF0C出发地点为' + (useCarLocationParams.cf_addr_address + ('\uFF0C管控城市为' + (cityNames + '\uFF0C请选择与出发地相同城市的公司'))));
                        }
                    } else {
                        alert(C_QryAddrByCompanyTip);
                    }
                }
            }
        } else {
            alert(res['errorMsg']);
        }
    }
};
lua_car.render_select_addr_page = function (companyType, addressList) {
    var companyType = formatNull(companyType);
    var htmlOption = '';
    if (addressList.length > 0) {
        for (var [key, value] in pairs(addressList)) {
            var addrIndex = tostring(key);
            var building = vt('building', value);
            var address = vt('address', value);
            htmlOption = htmlOption + ('[[\n                <div class="addr_list_option_div" border="0" onclick="lua_car.select_use_car_addr(\']]' + (companyType + ('[[\',\']]' + (addrIndex + ('[[\')">\n                    <label class="addr_title_label" value="]]' + (building + ('[[" />\n                    <label class="addr_detail_label" value="]]' + (address + '[[" />\n                    <line class="addr_line_css" />\n                </div>\n            ]]'))))))));
        }
        var addrListDivName = '';
        if (companyType === 'cfdd') {
            addrListDivName = 'cfdd_addr_list_div';
        } else if (companyType === 'dddd') {
            addrListDivName = 'dddd_addr_list_div';
        }
        var htmlContent = '[[\n            <div class="content_div" border="0" name="]]' + (addrListDivName + ('[[">\n            ]]' + (htmlOption + '[[\n            </div>\n        ]]')));
        document.getElementsByName(addrListDivName)[1].setInnerHTML(htmlContent);
        page_reload();
    } else {
        alert('当前公司暂未维护地址\uFF0C请联系管理员或切换公司再试');
    }
};
lua_car.select_current_company = function (selectType) {
    var selectOrgInfo = formatNull(globalTable['selectOrgList'][1]);
    var DefalutOrgFlag = vt('unitcode', selectOrgInfo);
    var DefaultCorp = vt('pkCorp', selectOrgInfo);
    var DefaultCorpName = vt('unitname', selectOrgInfo);
    var DefaultArgListTable = [
        DefalutOrgFlag,
        DefaultCorp,
        DefaultCorpName
    ];
    var argCheckRes = lua_form.arglist_check_empty(DefaultArgListTable);
    if (argCheckRes === 'true') {
        var defaultSelectCompanyArg = DefalutOrgFlag + (',' + (DefaultCorp + (',' + DefaultCorpName)));
        var doSelectCfdd = '';
        var doSelectDddd = '';
        if (selectType === 'cfdd') {
            doSelectCfdd = 'true';
        } else if (selectType === 'dddd') {
            doSelectDddd = 'true';
        } else if (selectType === 'all') {
            doSelectCfdd = 'true';
            doSelectDddd = 'true';
        } else {
        }
        if (doSelectCfdd === 'true') {
            document.getElementsByName('cfdd_company_list')[1].setCustomPropertyByName('defaultChecked', DefaultCorp);
            lua_car.select_cfdd_company(defaultSelectCompanyArg);
        }
        if (doSelectDddd === 'true') {
            document.getElementsByName('dddd_company_list')[1].setCustomPropertyByName('defaultChecked', DefaultCorp);
            lua_car.select_dddd_company(defaultSelectCompanyArg);
        }
    }
};
lua_car.select_cfdd_company = function (params) {
    lua_car.select_company(params, 'cfdd');
};
lua_car.select_dddd_company = function (params) {
    lua_car.select_company(params, 'dddd');
};
lua_car.select_company = function (params, companyType) {
    var addressCtrlFlag = formatNull(globalTable['addressCtrlFlag']);
    var companyType = formatNull(companyType);
    if (formatNull(params) != '') {
        var codeAndName = splitUtils(params, ',');
        var companyInfo = '';
        var companyName = '';
        var listLen = codeAndName.length;
        for (let i = 1; listLen; i++) {
            if (i != listLen) {
                if (companyInfo === '') {
                    companyInfo = codeAndName[i];
                } else {
                    companyInfo = companyInfo + (',' + codeAndName[i]);
                }
                if (i === listLen - 1) {
                    chooseCompanyPkCorp = codeAndName[i];
                }
            } else {
                companyName = codeAndName[i];
            }
        }
        if (addressCtrlFlag === '01') {
            if (useCarAddrFlag === 1) {
                changeProperty('choose_cfdd_company_label', 'value', companyName);
                changeProperty('choose_cfdd_addr_label', 'value', C_CFSelectUseCarAddrTip);
            } else if (useCarAddrFlag === 2) {
                changeProperty('choose_dddd_company_label', 'value', companyName);
                changeProperty('choose_dddd_addr_label', 'value', C_DDSelectUseCarAddrTip);
            } else {
            }
        } else if (addressCtrlFlag === '02') {
            if (companyType === 'cfdd') {
                changeProperty('choose_cfdd_company_label', 'value', companyName);
            } else if (companyType === 'dddd') {
                changeProperty('choose_dddd_company_label', 'value', companyName);
            }
        } else {
        }
        var qryAddrReqParams = {
            companyType: companyType,
            companyName: companyName,
            companyPkCorp: chooseCompanyPkCorp
        };
        lua_car.qry_addr_by_company('', qryAddrReqParams);
    } else {
        if (useCarAddrFlag === 1) {
            changeProperty('choose_cfdd_company_label', 'value', C_CFSelectUseCarCompanyTip);
            changeProperty('choose_cfdd_addr_label', 'value', C_CFSelectUseCarAddrTip);
        } else if (useCarAddrFlag === 2) {
            changeProperty('choose_dddd_company_label', 'value', C_DDSelectUseCarCompanyTip);
            changeProperty('choose_dddd_addr_label', 'value', C_DDSelectUseCarAddrTip);
        } else {
        }
    }
};
lua_car.render_company_page = function () {
    var CompanyListWidgetData = vt('CompanyListWidgetData', companyTable);
    if (CompanyListWidgetData === '') {
        alert('查询公司失败');
    } else {
        title_head('选择出发地点', 'lua_page.div_page_ctrl()', 'top_cfdd_addr_div');
        title_head('选择到达地点', 'lua_page.div_page_ctrl()', 'top_dddd_addr_div');
        changeProperty('cfdd_company_list', 'value', CompanyListWidgetData + '&');
        changeProperty('dddd_company_list', 'value', CompanyListWidgetData + '&');
        page_reload();
    }
};
lua_car.select_use_car_city_by_h5 = function (addrType) {
    var addrType = formatNull(addrType);
    var callBackArg = formatNull(addrType);
    var pageTitle = '选择地址';
    var ctrlCityCodes = '';
    var ctrlCityNames = '';
    if (addrType === 'cfdd') {
        pageTitle = '出发地点';
        ctrlCityCodes = vt('cfddCtrlCityCodes', globalTable);
        ctrlCityNames = vt('cfddCtrlCityNames', globalTable);
    } else if (addrType === 'dddd') {
        pageTitle = '到达地点';
        ctrlCityCodes = vt('ddddCtrlCityCodes', globalTable);
        ctrlCityNames = vt('ddddCtrlCityNames', globalTable);
    } else {
    }
    var UseCarSelectMapUrl = vt('UseCarSelectMapUrl', globalTable);
    if (UseCarSelectMapUrl != '') {
        var longitude = vt('location_longitude', systemTable);
        var latitude = vt('location_latitude', systemTable);
        var mapType = '';
        if (platform === 'iPhone OS') {
        } else if (platform === 'Android') {
        }
        var visit_url = UseCarSelectMapUrl + ('longitude=' + (longitude + ('&latitude=' + (latitude + ('&mapType=' + (mapType + ('&ctrlCityCodes=' + (ctrlCityCodes + ('&CallBackArg=' + (callBackArg + ''))))))))));
        var ReqParams = {
            H5InitStyle: useCarSelectAddrH5PageInitStyle,
            PageTitle: pageTitle,
            VisitUrl: visit_url
        };
        lua_car.show_use_car_city_by_h5('', ReqParams);
    } else {
        alert('获取地图异常');
    }
};
lua_car.show_use_car_city_by_h5 = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['TranCode'] = 'CarServiceLogRegister';
        invoke_trancode('jjbx_service', 'car_service', ReqParams, lua_car.show_use_car_city_by_h5, {}, all_callback, { CloseLoading: 'false' });
    } else {
        close_loading();
        var res = json2table(ResParams['responseBody']);
        var H5InitStyle = vt('H5InitStyle', res);
        var PageTitle = vt('PageTitle', res);
        var VisitUrl = vt('VisitUrl', res);
        if (H5InitStyle === 'alert') {
            var AlertWebviewArg = {
                title: PageTitle,
                visit_url: VisitUrl,
                listen_url: 'http://app_h5_callback_url',
                listen_call: 'lua_system.webview_h5_callback',
                location: 'true'
            };
            lua_system.alert_webview(AlertWebviewArg);
        } else {
            globalTable['webview_url'] = VisitUrl;
            globalTable['webview_page_title'] = PageTitle;
            invoke_page('jjbx_page/xhtml/webview_page.xhtml', page_callback, { CloseLoading: 'false' });
        }
    }
};
lua_car.use_car_selectCity = function (argTable) {
    var longitude = vt('longitude', argTable);
    var latitude = vt('latitude', argTable);
    var cityName = vt('cityName', argTable);
    var cityCode = vt('cityCode', argTable);
    var addr = vt('addr', argTable);
    var callbackArg = vt('CallBackArg', argTable);
    var addressCtrlFlag = vt('addressCtrlFlag', globalTable);
    var argListTable = [
        longitude,
        latitude,
        addr,
        cityCode
    ];
    var argCheckRes = lua_form.arglist_check_empty(argListTable);
    if (callbackArg === 'cfdd') {
        if (argCheckRes === 'true') {
            useCarLocationParams.cf_addr_longitude = longitude;
            useCarLocationParams.cf_addr_latitude = latitude;
            useCarLocationParams.cf_addr_address = addr;
            useCarLocationParams.cf_addr_cityName = cityName;
            useCarLocationParams.cf_addr_cityCode = cityCode;
            if (addr != '') {
                var e = document.getElementsByName('choose_cfdd_addr_label');
                for (let i = 1; e.length; i++) {
                    e[i].setPropertyByName('value', addr);
                }
            }
            if (globalTable['crossCityCtrlFlag'] === '00') {
                lua_car.clear_use_addr_info('dddd', 'all');
            }
            if (addressCtrlFlag === '01') {
                lua_car.select_current_company('dddd');
            }
        } else {
            alert('出发地点信息不完整\uFF0C请重新选择');
        }
    } else if (callbackArg === 'dddd') {
        if (argCheckRes === 'true') {
            useCarLocationParams.dd_addr_longitude = longitude;
            useCarLocationParams.dd_addr_latitude = latitude;
            useCarLocationParams.dd_addr_address = addr;
            useCarLocationParams.dd_addr_cityName = cityName;
            useCarLocationParams.dd_addr_cityCode = cityCode;
            if (addr != '') {
                var e = document.getElementsByName('choose_dddd_addr_label');
                for (let i = 1; e.length; i++) {
                    e[i].setPropertyByName('value', addr);
                }
            }
        } else {
            alert('到达地点信息不完整\uFF0C请重新选择');
        }
    } else {
        alert('获取地点信息异常');
    }
};
lua_car.to_use_car_h5_page = function (useCarPageArg) {
    var useCarPageArg = formatNull(useCarPageArg);
    var useCarChannel = vt('useCarChannel', useCarPageArg);
    var useCarType = vt('useCarType', useCarPageArg);
    var UseCarOrderId = '';
    var useCarRuleId = vt('useCarRuleId', useCarPageArg);
    var useCarBillNo = vt('useCarBillNo', useCarPageArg);
    var useCarTripStyle = vt('useCarTripStyle', useCarPageArg);
    var useCarPassengerPhone = vt('useCarPassengerPhone', useCarPageArg);
    var longitudeStart = vt('longitudeStart', useCarPageArg);
    var latitudeStart = vt('latitudeStart', useCarPageArg);
    var addrStart = vt('addrStart', useCarPageArg);
    var cityCodeStart = vt('cityCodeStart', useCarPageArg);
    var cityNameStart = vt('cityNameStart', useCarPageArg);
    var longitudeEnd = vt('longitudeEnd', useCarPageArg);
    var latitudeEnd = vt('latitudeEnd', useCarPageArg);
    var addrEnd = vt('addrEnd', useCarPageArg);
    var cityCodeEnd = vt('cityCodeEnd', useCarPageArg);
    var cityNameEnd = vt('cityNameEnd', useCarPageArg);
    if (useCarType === '' || useCarChannel === '') {
        alert('未知用车渠道');
    } else {
        var useCarH5Arg = {
            useCarType: useCarType,
            useCarRuleId: useCarRuleId,
            useCarBillNo: useCarBillNo,
            useCarTripStyle: useCarTripStyle,
            useCarPassengerPhone: useCarPassengerPhone,
            longitudeStart: longitudeStart,
            latitudeStart: latitudeStart,
            addrStart: addrStart,
            cityCodeStart: cityCodeStart,
            longitudeEnd: longitudeEnd,
            latitudeEnd: latitudeEnd,
            addrEnd: addrEnd,
            cityCodeEnd: cityCodeEnd
        };
        lua_car.qry_use_car_h5_link(useCarChannel, UseCarOrderId, useCarH5Arg);
    }
};
lua_car.qry_use_car_h5_link = function (orderChannel, orderId, useCarH5Arg) {
    var orderChannel = formatNull(orderChannel);
    var orderId = formatNull(orderId);
    var linkTag = '';
    if (orderId != '') {
        linkTag = 'OrderDetail';
        useCarH5Arg = '';
    } else {
        linkTag = 'ApplyOrder';
    }
    var useCarType = vt('useCarType', useCarH5Arg);
    var useCarBillNo = vt('useCarBillNo', useCarH5Arg);
    var useCarRuleId = vt('useCarRuleId', useCarH5Arg);
    var ApplyInfo = lua_car.find_apply_data(useCarBillNo);
    var useCarTripStyle = vt('useCarTripStyle', useCarH5Arg, '0');
    var useCarPassengerPhone = vt('useCarPassengerPhone', useCarH5Arg);
    var longitudeStart = '';
    var latitudeStart = '';
    var addrStart = '';
    var cityCodeStart = '';
    var cityNameStart = '';
    var longitudeEnd = '';
    var latitudeEnd = '';
    var addrEnd = '';
    var cityCodeEnd = '';
    var cityNameEnd = '';
    if (useCarType === 'personal') {
        longitudeStart = vt('longitudeStart', useCarH5Arg);
        latitudeStart = vt('latitudeStart', useCarH5Arg);
        addrStart = vt('addrStart', useCarH5Arg);
        cityCodeStart = vt('cityCodeStart', useCarH5Arg);
        cityNameStart = '';
        longitudeEnd = vt('longitudeEnd', useCarH5Arg);
        latitudeEnd = vt('latitudeEnd', useCarH5Arg);
        addrEnd = vt('addrEnd', useCarH5Arg);
        cityCodeEnd = vt('cityCodeEnd', useCarH5Arg);
        cityNameEnd = '';
    } else if (useCarType === 'business') {
        useCarTripStyle = useCarTripStyle;
        longitudeStart = vt('lngFrom', ApplyInfo);
        latitudeStart = vt('latFrom', ApplyInfo);
        addrStart = vt('addrS', ApplyInfo);
        cityCodeStart = vt('cityId', ApplyInfo);
        cityNameStart = '';
        longitudeEnd = vt('lngTo', ApplyInfo);
        latitudeEnd = vt('latTo', ApplyInfo);
        addrEnd = vt('addrE', ApplyInfo);
        cityCodeEnd = vt('toCityId', ApplyInfo);
        cityNameEnd = '';
    }
    var reqParams = {
        useCarChannel: orderChannel,
        useCarLinkTag: linkTag,
        useCarOrderId: orderId,
        useCarBillNo: useCarBillNo,
        useCarRuleId: useCarRuleId,
        useCarTripStyle: useCarTripStyle,
        useCarPassengerPhone: useCarPassengerPhone,
        longitudeStart: longitudeStart,
        latitudeStart: latitudeStart,
        addrStart: addrStart,
        cityCodeStart: cityCodeStart,
        cityNameStart: cityNameStart,
        longitudeEnd: longitudeEnd,
        latitudeEnd: latitudeEnd,
        addrEnd: addrEnd,
        cityCodeEnd: cityCodeEnd,
        cityNameEnd: cityNameEnd
    };
    var CheckRuleTimeFlag = '';
    if (linkTag === 'OrderDetail') {
        CheckRuleTimeFlag = 'false';
    } else {
        if (useCarType === 'personal' && personalCheckRuleTimeFlag === 'false') {
            CheckRuleTimeFlag = 'false';
        } else if (useCarType === 'business' && businessCheckRuleTimeFlag === 'false') {
            CheckRuleTimeFlag = 'false';
        } else {
            CheckRuleTimeFlag = 'true';
        }
    }
    if (CheckRuleTimeFlag === 'true') {
        globalTable['openUseCarH5LinkArg'] = reqParams;
        lua_car.check_rule_time('', useCarRuleId);
    } else {
        lua_car.open_use_car_h5_link('', reqParams);
    }
};
lua_car.check_rule_time = function (resParams, useCarRuleId) {
    if (formatNull(resParams) === '') {
        invoke_trancode_donot_checkRepeat('jjbx_service', 'car_service', {
            TranCode: 'checkInstitutionTime',
            useCarRuleId: useCarRuleId
        }, lua_car.check_rule_time, {}, all_callback, { CloseLoading: 'false' });
    } else {
        var res = json2table(resParams['responseBody']);
        if (res['errorNo'] === '000000') {
            var sign = vt('sign', res);
            if (sign === 'true') {
                close_loading();
                var openUseCarH5LinkArg = formatNull(globalTable['openUseCarH5LinkArg']);
                globalTable['openUseCarH5LinkArg'] = '';
                lua_car.open_use_car_h5_link('', openUseCarH5LinkArg);
            } else {
                alert('未到用车时间\uFF0C无法用车');
            }
        } else {
            var errorMsg = vt('errorMsg', res);
            alert(errorMsg);
        }
    }
};
lua_car.open_use_car_h5_link = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['TranCode'] = 'getUseCarH5Link';
        invoke_trancode_donot_checkRepeat('jjbx_service', 'car_service', ReqParams, lua_car.open_use_car_h5_link, {}, all_callback, { CloseLoading: 'false' });
    } else {
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            var useCarOrderId = vt('useCarOrderId', res);
            var useCarChannel = vt('useCarChannel', res);
            var useCarLinkTag = vt('useCarLinkTag', res);
            var useCarH5LinkUrl = vt('useCarH5LinkUrl', res);
            var useCarH5PageTitle = '打开页面';
            if (useCarLinkTag === 'OrderDetail') {
                useCarH5PageTitle = '订单详情';
            } else if (useCarLinkTag === 'ApplyOrder') {
                if (useCarChannel === 'dd') {
                    useCarH5PageTitle = '滴滴打车';
                } else if (useCarChannel === 'cc') {
                    useCarH5PageTitle = '曹操专车';
                } else {
                }
            } else {
            }
            if (useCarH5LinkUrl != '') {
                var UserRiskCheckMsg = vt('UserRiskCheckMsg', globalTable);
                if (UserRiskCheckMsg != '') {
                    alert(UserRiskCheckMsg);
                } else {
                    if (useCarH5PageInitStyle === 'alert') {
                        if (useCarChannel === 'dd') {
                            lua_system.alert_webview({
                                title: useCarH5PageTitle,
                                visit_url: useCarH5LinkUrl,
                                listen_url: 'http://app_h5_callback_url',
                                listen_call: 'lua_system.webview_h5_callback',
                                AddUserAgent: '/CZBANK/JJBXAPP'
                            });
                        } else {
                            lua_system.alert_webview({
                                title: useCarH5PageTitle,
                                visit_url: useCarH5LinkUrl,
                                listen_url: 'http://app_h5_callback_url',
                                listen_call: 'lua_system.webview_h5_callback',
                                back_type: 'BACK'
                            });
                        }
                    } else {
                        globalTable['webview_url'] = useCarH5LinkUrl;
                        globalTable['webview_page_title'] = useCarH5PageTitle;
                        globalTable['webview_close_fun'] = 'back_fun()';
                        globalTable['url_encode'] = 'false';
                        invoke_page('jjbx_page/xhtml/webview_page.xhtml', page_callback, { CloseLoading: 'false' });
                    }
                }
            } else {
                alert('获取用车地址为空');
            }
            close_loading();
        } else {
            alert(res['errorMsg']);
        }
    }
};
lua_car.rule_msg_width_adapter = function (Arg) {
    var initLeft = vt('initLeft', Arg);
    var counts = vt('counts', Arg);
    var label1Content = vt('label1Content', Arg);
    var label1FontSize = vt('label1FontSize', Arg, '10');
    var label1AutoHide = vt('label1AutoHide', Arg, 'true');
    var label2Content = vt('label2Content', Arg);
    var label2FontSize = vt('label2FontSize', Arg, '10');
    var label2AutoHide = vt('label2AutoHide', Arg, 'true');
    var label3Content = vt('label3Content', Arg);
    var label3FontSize = vt('label3FontSize', Arg, '10');
    var label3AutoHide = vt('label3AutoHide', Arg, 'true');
    for (let i = 1; counts; i++) {
        var initLeft = parseFloat(formatNull(initLeft, '15'));
        var paddingWidth = 6;
        var spaceWidth = 4;
        var index = tostring(i);
        var label1Name = label1Content + ('_' + index);
        var label2Name = label2Content + ('_' + index);
        var label3Name = label3Content + ('_' + index);
        var label1Value = getValue(label1Name, '0');
        var label1Width = formatNull(calculate_text_width(label1Value, label1FontSize), '0');
        var label1SetWidth = '';
        if (label1Width != '0') {
            label1SetWidth = parseFloat(label1Width) + paddingWidth;
        } else {
            if (label1AutoHide === 'true') {
                hide_ele(label1Name);
            }
            label1SetWidth = 0;
        }
        var label1Left = initLeft;
        var label2Value = getValue(label2Name, '0');
        var label2Width = formatNull(calculate_text_width(label2Value, label2FontSize), '0');
        var label2SetWidth = '';
        if (label2Width != '0') {
            label2SetWidth = parseFloat(label2Width) + paddingWidth;
        } else {
            if (label2AutoHide === 'true') {
                hide_ele(label2Name);
            }
            label2SetWidth = 0;
        }
        var label2Left = '';
        if (label1SetWidth != 0) {
            label2Left = label1Left + spaceWidth + label1SetWidth;
        } else {
            label2Left = label1Left;
        }
        var label3Value = getValue(label3Name, '0');
        var label3Width = formatNull(calculate_text_width(label3Value, label3FontSize), '0');
        var label3SetWidth = '';
        if (label3Width != '0') {
            label3SetWidth = parseFloat(label3Width) + paddingWidth;
        } else {
            if (label3AutoHide === 'true') {
                hide_ele(label3Name);
            }
            label3SetWidth = 0;
        }
        var label3Left = '';
        if (label2SetWidth != 0) {
            label3Left = label2Left + spaceWidth + label2SetWidth;
        } else {
            label2Left = label2Left;
        }
        if (label1SetWidth != 0) {
            changeStyle(label1Name, 'width', tostring(label1SetWidth));
        }
        if (label2SetWidth != 0) {
            changeStyle(label2Name, 'width', tostring(label2SetWidth));
        }
        if (label3SetWidth != 0) {
            changeStyle(label3Name, 'width', tostring(label3SetWidth));
        }
        changeStyle(label1Name, 'left', tostring(label1Left));
        changeStyle(label2Name, 'left', tostring(label2Left));
        changeStyle(label3Name, 'left', tostring(label3Left));
        page_reload();
    }
};
lua_car.bill_form_check = function () {
    var addressCtrlFlag = formatNull(globalTable['addressCtrlFlag']);
    var submitFlag = '';
    if (SCBP.submitFlag === 'save') {
        submitFlag = 'save';
    } else {
        submitFlag = 'submit';
    }
    if (SCBP.tripDetail_ruleId === '') {
        alert(C_SelectUseCarRuleTip);
        return 'false';
    }
    if (submitFlag === 'submit') {
        if (SCBP.tripDetail_businessSceneCode === '') {
            alert('请选择业务场景');
            return 'false';
        }
        if (SCBP.reason === '') {
            if (getStyle('ycsy_div', 'display') === 'block' && getValue('ycsy_required') === '*') {
                alert('请填写用车事由');
                return 'false';
            }
        }
    }
    if (SCBP.tripDetail_ycfs === '2') {
        if (SCBP.tripDetail_yccs === '') {
            alert('请填写用车次数');
            return 'false';
        } else {
            if (SCBP.tripDetail_carUseLimitCounts === '') {
                alert(C_SelectUseCarRuleTip);
                return 'false';
            } else if (SCBP.tripDetail_carUseLimitCounts === 'unlimited') {
            } else {
                if (parseFloat(SCBP.tripDetail_yccs) > parseFloat(SCBP.tripDetail_carUseLimitCounts)) {
                    alert('用车次数超过制度限制');
                    return 'false';
                }
            }
        }
    } else {
        SCBP.tripDetail_yccs = '';
    }
    if (submitFlag === 'submit') {
        if (addressCtrlFlag === '01' && useCarAddrFlag === 1 || addressCtrlFlag === '02') {
            if (SCBP.tripDetail_companyNameFrom === '' || SCBP.tripDetail_companyCodeFrom === '') {
                alert(C_CFSelectUseCarCompanyTip);
                return 'false';
            }
        }
        if (SCBP.tripDetail_lngFrom === '' || SCBP.tripDetail_latFrom === '' || SCBP.tripDetail_cityId === '') {
            alert(C_CFSelectUseCarAddrTip);
            return 'false';
        }
    } else if (submitFlag === 'save') {
        if (SCBP.tripDetail_lngFrom != '' && SCBP.tripDetail_latFrom != '' || SCBP.tripDetail_cityId != '') {
            if (addressCtrlFlag === '01' && useCarAddrFlag === 1 || addressCtrlFlag === '02') {
                if (SCBP.tripDetail_companyNameFrom === '' || SCBP.tripDetail_companyCodeFrom === '') {
                    alert(C_CFSelectUseCarCompanyTip);
                    return 'false';
                }
            }
        }
    }
    if (submitFlag === 'submit') {
        if (addressCtrlFlag === '01' && useCarAddrFlag === 2 || addressCtrlFlag === '02') {
            if (SCBP.tripDetail_companyNameTo === '' || SCBP.tripDetail_companyCodeTo === '') {
                alert(C_DDSelectUseCarCompanyTip);
                return 'false';
            }
        }
        if (SCBP.tripDetail_lngTo === '' || SCBP.tripDetail_latTo === '' || SCBP.tripDetail_toCityId === '') {
            alert(C_DDSelectUseCarAddrTip);
            return 'false';
        }
    } else if (submitFlag === 'save') {
        if (SCBP.tripDetail_lngTo != '' && SCBP.tripDetail_latTo != '' && SCBP.tripDetail_toCityId != '') {
            if (addressCtrlFlag === '01' && useCarAddrFlag === 2 || addressCtrlFlag === '02') {
                if (SCBP.tripDetail_companyNameTo === '' || SCBP.tripDetail_companyCodeTo === '') {
                    alert(C_DDSelectUseCarCompanyTip);
                    return 'false';
                }
            }
        }
    }
    return 'true';
};
lua_car.do_submit_car_bill = function (params) {
    if (formatNull(params) === '') {
        var checkBillRes = lua_car.bill_form_check();
        if (checkBillRes != 'true') {
            return;
        }
        invoke_trancode('jjbx_service', 'car_service', SCBP, lua_car.do_submit_car_bill, {}, all_callback, { CloseLoading: 'false' });
    } else {
        var doSubmitCarBillRes = json2table(params['responseBody']);
        var errorNo = vt('errorNo', doSubmitCarBillRes);
        var errorMsg = vt('errorMsg', doSubmitCarBillRes);
        var budgetPrompts = vt('budgetPrompts', doSubmitCarBillRes);
        var SubmitFlag = vt('SubmitFlag', doSubmitCarBillRes);
        if (SubmitFlag === 'save') {
            if (errorNo === '000000') {
                alertToast('0', C_SavedMsg, '', '', '');
            } else {
                alert(errorMsg);
            }
        } else {
            globalTable['CarServiceApplyResErrorNo'] = errorNo;
            globalTable['CarServiceApplyResErrorMsg'] = errorMsg;
            globalTable['CarServiceApplyResBudgetPrompts'] = budgetPrompts;
            invoke_page('jjbx_car_service/xhtml/car_service_ApplyRes.xhtml', page_callback, { CloseLoading: 'false' });
        }
    }
};
lua_car.set_city_ctrl = function (ruleInfo, type) {
    globalTable['setCityCtrlType'] = type;
    var crossCityCtrlFlag = vt('crossCity', ruleInfo);
    globalTable['crossCityCtrlFlag'] = crossCityCtrlFlag;
    var vehicleCityControlEnable = vt('vehicleCityControlEnable', ruleInfo);
    var vehicleCityControlCode = vt('vehicleCityControlCode', ruleInfo);
    var vehicleCityControlName = vt('vehicleCityControlName', ruleInfo);
    var destinationCityControlEnable = vt('destinationCityControlEnable', ruleInfo);
    var destinationCityControlCode = vt('destinationCityControlCode', ruleInfo);
    var destinationCityControlName = vt('destinationCityControlName', ruleInfo);
    var addressCtrlFlag = formatNull(globalTable['addressCtrlFlag']);
    globalTable['cfddCtrlCityCodes'] = '';
    globalTable['cfddCtrlCityNames'] = '';
    globalTable['ddddCtrlCityCodes'] = '';
    globalTable['ddddCtrlCityNames'] = '';
    if (crossCityCtrlFlag === '00') {
        if (addressCtrlFlag === '01' || addressCtrlFlag === '02') {
        } else {
            if (vehicleCityControlEnable === '00') {
                globalTable['cfddCtrlCityCodes'] = vehicleCityControlCode;
                globalTable['cfddCtrlCityNames'] = vehicleCityControlName;
                globalTable['ddddCtrlCityCodes'] = vehicleCityControlCode;
                globalTable['ddddCtrlCityNames'] = vehicleCityControlName;
            }
        }
    } else {
        if (vehicleCityControlEnable === '00') {
            globalTable['cfddCtrlCityCodes'] = vehicleCityControlCode;
            globalTable['cfddCtrlCityNames'] = vehicleCityControlName;
        }
        if (destinationCityControlEnable === '00') {
            globalTable['ddddCtrlCityCodes'] = destinationCityControlCode;
            globalTable['ddddCtrlCityNames'] = destinationCityControlName;
        }
    }
    if (type === 'apply') {
        if (addressCtrlFlag != '01' && addressCtrlFlag != '02') {
            lua_car.init_cfdd_addr();
        }
    }
};
lua_car.render_choose_trip_style_page = function (Arg) {
    var pageBgName = vt('pageBgName', Arg);
    var cfddAddr = vt('cfddAddr', Arg);
    var ddddAddr = vt('ddddAddr', Arg);
    var hiddenArg = vt('hiddenArg', Arg);
    var title = vt('title', Arg);
    var btnContent = vt('btnContent', Arg);
    var btnClickFun = vt('btnClickFun', Arg);
    var showSwitch = vt('showSwitch', Arg);
    var bgClickFun = vt('bgClickFun', Arg);
    var mobileInput = vt('mobileInput', Arg);
    var cfddDivClass = '';
    var ddddDivClass = '';
    var addrLabelClass = '';
    var addrLabelMaxLen = 0;
    var car_trip_switch_div = '';
    if (showSwitch === 'true') {
        cfddDivClass = 'car_trip_cfdd_div';
        ddddDivClass = 'car_trip_dddd_div';
        addrLabelClass = 'trip_style_vlabel';
        addrLabelMaxLen = 15;
        car_trip_switch_div = '[[\n            <div class="car_trip_switch_div" name="car_trip_switch_div" border="]]' + (useCarDebugBorder + '[[" onclick="lua_car.choose_trip_style(\'switch\')">\n                <img src="local:car_trip_switch.png" class="car_trip_switch_icon" onclick="lua_car.choose_trip_style(\'switch\')"/>\n            </div>\n        ]]');
    } else {
        cfddDivClass = 'car_trip_cfdd_full_div';
        ddddDivClass = 'car_trip_dddd_full_div';
        addrLabelClass = 'trip_style_full_vlabel';
        addrLabelMaxLen = 20;
        car_trip_switch_div = '';
    }
    var mobileInputHtml = '';
    if (mobileInput === 'true') {
        mobileInputHtml = '[[\n            <div class="car_trip_mobile_div" border="]]' + (useCarDebugBorder + '[[">\n                <label class="car_trip_mobile_lable" name="car_trip_mobile_lable">乘车人手机号</label>\n                <input type="text" class="car_trip_mobile_text" value="" name="car_trip_mobile_text" style="-wap-input-format: \'N\';" border="0" hold="请输入" maxleng="11" DivInputAccessoryView="YES"/>\n            </div>\n            <div class="space_10_div" border="0"/>\n        ]]');
    }
    var page_html = '[[\n        <div class="full_screen_widget_bg_div" name="]]' + (pageBgName + ('[[" border="0" onclick="]]' + (bgClickFun + ('[[">\n            <div class="trip_style_switch_div" name="trip_style_switch_div" border="1" onclick="">\n                <label class="trip_style_hidden_label" name="useCarPageArg_hidden_label" value="" />\n\n                <!-- 标题 -->\n                <div class="trip_style_title_div" border="]]' + (useCarDebugBorder + ('[[">\n                    <label class="trip_style_title_label" name="trip_style_title_label">]]' + (title + ('[[</label>\n                </div>\n\n                <!-- 切换层 -->\n                <div class="car_trip_info_div" border="]]' + (useCarDebugBorder + ('[[">\n                    <!-- 出发地点 -->\n                    <div class="]]' + (cfddDivClass + ('[[" border="]]' + (useCarDebugBorder + ('[[">\n                        <img src="local:car_cfdd_point.png" class="car_addr_point_icon"/>\n                        <label class="trip_style_klabel">出发</label>\n                        <label class="]]' + (addrLabelClass + ('[[" name="car_trip_cfdd_addr_label">请确认出发地点</label>\n                    </div>\n\n                    <!-- 到达地点 -->\n                    <div class="]]' + (ddddDivClass + ('[[" border="]]' + (useCarDebugBorder + ('[[">\n                        <img src="local:car_dddd_point.png" class="car_addr_point_icon"/>\n                        <label class="trip_style_klabel">到达</label>\n                        <label class="]]' + (addrLabelClass + ('[[" name="car_trip_dddd_addr_label">请确认到达地点</label>\n                    </div>\n\n                    <!-- 切换按钮 -->\n                    ]]' + (car_trip_switch_div + ('[[\n                </div>\n                <div class="space_10_div" border="0"/>\n\n                <!-- 乘车人手机号 -->\n                ]]' + (mobileInputHtml + ('[[\n\n                <!-- 按钮 -->\n                <div class="car_trip_btn_div" border="]]' + (useCarDebugBorder + ('[[">\n                    <img src="local:car_trip_btn.png" class="car_trip_btn_icon" onclick="]]' + (btnClickFun + ('[["/>\n                    <label class="car_trip_btn_label" name="car_trip_btn_label" onclick="]]' + (btnClickFun + ('[[">]]' + (btnContent + '[[</label>\n                </div>\n\n                <div class="space_10_div" border="0"/>\n            </div>\n        </div>\n    ]]')))))))))))))))))))))))))))))))));
    document.getElementsByName(pageBgName)[1].setInnerHTML(page_html);
    lua_page.widget_center_adapt('trip_style_switch_div', 'x/y');
    lua_page.div_page_ctrl(pageBgName, 'false', 'false');
    changeProperty('useCarPageArg_hidden_label', 'value', hiddenArg);
    changeProperty('car_trip_cfdd_addr_label', 'value', cutStr(cfddAddr, addrLabelMaxLen));
    changeProperty('car_trip_dddd_addr_label', 'value', cutStr(ddddAddr, addrLabelMaxLen));
};
lua_car.choose_trip_style = function (type) {
    var type = formatNull(type);
    if (type === 'switch') {
        var cfddNowValue = getValue('car_trip_cfdd_addr_label');
        var ddddNowValue = getValue('car_trip_dddd_addr_label');
        changeProperty('car_trip_cfdd_addr_label', 'value', cutStr(ddddNowValue, 15));
        changeProperty('car_trip_dddd_addr_label', 'value', cutStr(cfddNowValue, 15));
        if (globalTable['useCarTripStyle'] === '0') {
            globalTable['useCarTripStyle'] = '1';
        } else {
            globalTable['useCarTripStyle'] = '0';
        }
    } else if (type === 'submit') {
        var useCarPageJsonArg = getValue('useCarPageArg_hidden_label');
        var useCarPageTableArg = json2table(useCarPageJsonArg);
        var useCarTripStyle = globalTable['useCarTripStyle'];
        globalTable['useCarTripStyle'] = '0';
        var useCarChannel = vt('useCarChannel', useCarPageTableArg);
        var taxiAgentControl = vt('taxiAgentControl', useCarPageTableArg);
        if (taxiAgentControl === '00' && useCarChannel === 'dd') {
            var useCarPassengerPhone = getValue('car_trip_mobile_text');
            if (useCarPassengerPhone === '') {
                alert('请输入乘车人手机号');
                return;
            } else {
                useCarPageTableArg['useCarPassengerPhone'] = useCarPassengerPhone;
            }
        }
        useCarPageTableArg['useCarTripStyle'] = useCarTripStyle;
        lua_page.div_page_ctrl();
        lua_car.to_use_car_h5_page(useCarPageTableArg);
    } else {
        globalTable['useCarTripStyle'] = '0';
        lua_page.div_page_ctrl();
    }
};
lua_car.select_business_scene = function (ywcjInfo) {
    lua_page.div_page_ctrl();
    var ywcjbm = '';
    var ywcjname = '';
    if (formatNull(ywcjInfo) != '') {
        ywcjbm = splitUtils(ywcjInfo, '_')[1];
        ywcjname = splitUtils(ywcjInfo, '_')[2];
        var matchYWCJIndex = '';
        var useCarYWCJData = formatNull(companyTable['useCarYWCJData']);
        if (useCarYWCJData != '') {
            var useCarYWCJDataLen = useCarYWCJData.length;
            for (let i = 1; useCarYWCJDataLen; i++) {
                var useCarYWCJData = formatNull(useCarYWCJData[i]);
                var ywcjContentcode = vt('businessCode', useCarYWCJData);
                if (ywcjContentcode === ywcjbm) {
                    matchYWCJIndex = tostring(i);
                    break;
                }
            }
            if (matchYWCJIndex != '') {
                SCBP.tripDetail_businessScene = ywcjname;
                SCBP.tripDetail_businessSceneCode = ywcjbm;
                changeProperty('ywcj', 'value', ywcjname);
                var setYWCJSelectArg = { showIndex: matchYWCJIndex };
                lua_page.set_item_selected(setYWCJSelectArg);
            } else {
                alert(C_NoneUseCarYWCJTip);
            }
        } else {
            alert(C_NoneUseCarYWCJTip);
        }
    } else {
        alert(C_NoneUseCarYWCJTip);
    }
};
lua_car.choose_business_car_rule = function (ruleId) {
    var ruleId = formatNull(ruleId);
    lua_page.div_page_ctrl();
    if (ruleId != '') {
        if (ruleId != selectUseCarRuleId) {
            var matchRuleIndex = '';
            var matchRuleId = '';
            var matchRuleName = '';
            var matchRuleCode = '';
            var numberVehiclesUsed = '';
            var business_use_car_rule = formatNull(companyTable['useCarYCCJData']);
            if (business_use_car_rule != '') {
                var business_rule_len = business_use_car_rule.length;
                for (let i = 1; business_rule_len; i++) {
                    var BusinessUseCarRule = formatNull(business_use_car_rule[i]);
                    var idusecarInstitution = vt('idusecarInstitution', BusinessUseCarRule);
                    if (idusecarInstitution === ruleId) {
                        matchRuleIndex = tostring(i);
                        matchRuleId = idusecarInstitution;
                        matchRuleName = vt('institutionName', BusinessUseCarRule);
                        matchRuleCode = vt('institutionCode', BusinessUseCarRule);
                        numberVehiclesUsed = vt('numberVehiclesUsed', BusinessUseCarRule);
                        break;
                    }
                }
            }
            SCBP.tripDetail_ruleId = matchRuleId;
            SCBP.tripDetail_carScene = matchRuleName;
            SCBP.tripDetail_carSceneCode = matchRuleCode;
            SCBP.tripDetail_carUseLimitCounts = formatNull(numberVehiclesUsed, 'unlimited');
            selectUseCarRuleId = matchRuleId;
            if (matchRuleName != '') {
                changeProperty('yccj', 'value', matchRuleName);
            }
            var setRuleSelectArg = {
                showIndex: matchRuleIndex,
                eleName: 'car_apply_cs_select_div'
            };
            lua_page.set_item_selected(setRuleSelectArg);
            invoke_trancode_donot_checkRepeat('jjbx_service', 'car_service', {
                TranCode: 'queryCarUseInstitution',
                useCarRuleId: ruleId
            }, set_business_apply_by_rule, {}, all_callback, { CloseLoading: 'false' });
        } else {
            close_loading();
        }
    } else {
        lua_car.render_addr_default_page();
        alert('制度信息异常');
    }
};
lua_car.select_use_car_time = function () {
    lua_system.select_interval_date({
        startDate: defaultDateStart,
        endDate: defaultDateEnd,
        callbackFunc: 'lua_car.set_use_car_time',
        title: '请选择用车日期'
    });
};
lua_car.set_use_car_time = function (startTime, endTime) {
    var startTime = formatNull(startTime);
    var endTime = formatNull(endTime);
    var startDate = ryt.getSubstringValue(startTime, 0, 4) + ('-' + (ryt.getSubstringValue(startTime, 5, 7) + ('-' + ryt.getSubstringValue(startTime, 8, 10))));
    var endDate = ryt.getSubstringValue(endTime, 0, 4) + ('-' + (ryt.getSubstringValue(endTime, 5, 7) + ('-' + ryt.getSubstringValue(endTime, 8, 10))));
    changeProperty('use_car_start_time_label', 'value', startDate);
    changeProperty('use_car_end_time_label', 'value', endDate);
};
lua_car.show_ywcj_select_page = function () {
    var useCarYWCJData = formatNull(companyTable['useCarYWCJData']);
    if (useCarYWCJData === '') {
        alert(C_NoneUseCarYWCJTip);
    } else {
        lua_page.div_page_ctrl('ywcj_page_div', 'false', 'false');
    }
};
lua_car.show_yccj_select_page = function () {
    var useCarYCCJData = formatNull(companyTable['useCarYCCJData']);
    if (useCarYCCJData === '') {
        alert(C_NoneUseCarRuleTip);
    } else {
        lua_page.div_page_ctrl('yccj_page_div', 'false', 'false');
    }
};
lua_car.render_business_car_rule_by_cache = function (type) {
    var business_use_car_rule = formatNull(companyTable['useCarYCCJData']);
    if (business_use_car_rule != '') {
        var divBorder = '0';
        var yccj_list_div_item_html = '';
        var business_rule_len = business_use_car_rule.length;
        for (let i = 1; business_rule_len; i++) {
            var BusinessUseCarRule = formatNull(business_use_car_rule[i]);
            var ruleIndex = tostring(i);
            var businessScenariosName = vt('businessScenariosName', BusinessUseCarRule);
            var institutionName = vt('institutionName', BusinessUseCarRule);
            var institutionCode = vt('institutionCode', BusinessUseCarRule);
            var idusecarInstitution = vt('idusecarInstitution', BusinessUseCarRule);
            var numberVehiclesUsedControl = vt('numberVehiclesUsedControl', BusinessUseCarRule);
            var numberVehiclesUsed = vt('numberVehiclesUsed', BusinessUseCarRule);
            var showUseCounts = lua_car.remainTimesMsg(numberVehiclesUsed);
            var vehicleDateControl = vt('vehicleDateControl', BusinessUseCarRule);
            var vehicleDateBegin = vt('vehicleDateBegin', BusinessUseCarRule);
            var vehicleDateEnd = vt('vehicleDateEnd', BusinessUseCarRule);
            var showUseDateInterval = '';
            if (vehicleDateControl === '00') {
                showUseDateInterval = lua_car.useDateIntervalMsg(vehicleDateBegin, vehicleDateEnd, 'timestamp');
            } else {
                showUseDateInterval = lua_car.useDateIntervalMsg();
            }
            var limitPerOrderControl = vt('limitPerOrderControl', BusinessUseCarRule);
            var limitPerOrderMoney = vt('limitPerOrderMoney', BusinessUseCarRule);
            var showLimitPerOrderMoney = '';
            if (limitPerOrderControl === '00') {
                showLimitPerOrderMoney = lua_car.perLimitMsg(limitPerOrderMoney);
            } else {
                showLimitPerOrderMoney = lua_car.perLimitMsg('');
            }
            var timeInfo = vt('timeInfo', BusinessUseCarRule);
            var timeInfoCounts = timeInfo.length;
            var alertShowUseInfo = '';
            if (timeInfoCounts > 0) {
                for (let i = 1; timeInfoCounts; i++) {
                    var timeInfoValue = formatNull(timeInfo[i]);
                    if (timeInfoCounts === 1) {
                        alertShowUseInfo = timeInfoValue;
                    } else {
                        alertShowUseInfo = timeInfoValue + ('\\n' + alertShowUseInfo);
                    }
                }
            } else {
                alertShowUseInfo = showDefaultUseExplain;
            }
            globalTable['alertShowBusinessUseInfo'][i] = alertShowUseInfo;
            var taxiAgentControlMsg = lua_car.taxiAgentControlMsg(vt('taxiAgentControl', BusinessUseCarRule));
            var taxi_agent_ctrl_html = '';
            if (taxiAgentControlMsg != '') {
                taxi_agent_ctrl_html = '[[\n                    <input type="button" name="taxi_agent_btn_]]' + (ruleIndex + ('[[" class="car_apply_cs_b_taxiagent_btn" border="1" value="]]' + (taxiAgentControlMsg + '[[" />\n                ]]')));
            }
            var show_use_explain_div_html = '';
            var alertShowUseInfoLen = ryt.getLengthByStr(alertShowUseInfo);
            var show_use_explain_onClick = '';
            if (alertShowUseInfo === showDefaultUseExplain) {
            } else {
                if (timeInfoCounts === 1 && alertShowUseInfoLen <= showUseExplainLength) {
                    if (string.find(alertShowUseInfo, defaultUseExplainPC)) {
                        alertShowUseInfo = defaultUseExplainAPP;
                    }
                } else {
                    show_use_explain_onClick = 'show_use_explain(\'business\',\'' + (ruleIndex + '\')');
                }
            }
            if (show_use_explain_onClick === '') {
                show_use_explain_div_html = '[[\n                    <div class="car_apply_cs_b_useex_div" border="]]' + (divBorder + ('[[">\n                        ]]' + (taxi_agent_ctrl_html + ('[[\n                        <label class="car_apply_cs_b_useex_full_label" name="car_apply_cs_b_useex_label_]]' + (ruleIndex + ('[[">]]' + (alertShowUseInfo + '[[</label>\n                    </div>\n                ]]')))))));
            } else {
                show_use_explain_div_html = '[[\n                    <div class="car_apply_cs_b_useex_div" border="]]' + (divBorder + ('[[" onclick="]]' + (show_use_explain_onClick + ('[[">\n                        ]]' + (taxi_agent_ctrl_html + ('[[\n                        <label class="car_apply_cs_b_useex_label" name="car_apply_cs_b_useex_label_]]' + (ruleIndex + ('[[">]]' + (defaultUseExplainTip + ('[[</label>\n                        <img src="local:arrow_mine.png" class="car_apply_cs_b_useexarw_icon" name="car_apply_cs_b_useexarw_icon_]]' + (ruleIndex + ('[[" onclick="]]' + (show_use_explain_onClick + '[[\')"/>\n                    </div>\n                ]]')))))))))))));
            }
            var onclick_html = 'onclick=\\"lua_car.choose_business_car_rule(\'' + (idusecarInstitution + '\')\\"');
            var remarks = vt('remarks', BusinessUseCarRule);
            var remark_html = '';
            if (remarks != '') {
                remark_html = '[[\n                    <div class="space_02_div" border="]]' + (divBorder + ('[[" />\n                    <div class="car_apply_cs_b_sy_div" border="]]' + (divBorder + ('[[" ]]' + (onclick_html + ('[[>>\n                        <label class="car_apply_cs_b_sy_label">]]' + (remarks + ('[[</label>\n                    </div>\n                    <div class="space_08_div" border="]]' + (divBorder + '[[" />\n                ]]')))))))));
            } else {
                remark_html = '[[<div class="space_10_div" border="]]' + (divBorder + '[[" />]]');
            }
            yccj_list_div_item_html = yccj_list_div_item_html + ('[[\n                <div class="car_apply_cs_business_div" border="1" ]]' + (onclick_html + ('[[>\n                    <div class="car_apply_cs_select_div" name="car_apply_cs_select_div" border="]]' + (divBorder + ('[[">\n                        <img src="local:selected_round.png" class="car_apply_cs_select_icon" />\n                    </div>\n\n                    <div class="car_apply_cs_business_content_div" border="]]' + (divBorder + ('[[" ]]' + (onclick_html + ('[[>\n                        <div class="car_apply_cs_b_title_div" border="]]' + (divBorder + ('[[" ]]' + (onclick_html + ('[[>\n                            <label class="car_apply_cs_b_title_label">]]' + (institutionName + ('[[</label>\n                        </div>\n                        ]]' + (remark_html + ('[[\n                        <div class="car_apply_cs_b_ruleinfo_div" border="]]' + (divBorder + ('[[" ]]' + (onclick_html + ('[[>\n                            <input type="button" class="car_apply_cs_b_counts_label" border="1" name="b_counts_label_]]' + (ruleIndex + ('[[" value="]]' + (showUseCounts + ('[[" />\n                            <input type="button" class="car_apply_cs_b_limit_label"  border="1" name="b_limit_label_]]' + (ruleIndex + ('[["  value="]]' + (showLimitPerOrderMoney + ('[[" />\n                            <input type="button" class="car_apply_cs_b_time_label"   border="1" name="b_time_label_]]' + (ruleIndex + ('[["   value="]]' + (showUseDateInterval + ('[[" />\n                        </div>\n                        <div class="space_10_div" border="]]' + (divBorder + ('[[" />\n                        ]]' + (show_use_explain_div_html + ('[[\n                    </div>\n                </div>\n                <div class="space_10_div" border="]]' + (divBorder + '[[" />\n            ]]'))))))))))))))))))))))))))))))))))))));
        }
        var yccj_list_div_html = '[[\n            <div class="car_apply_cs_yccj_list_div" border="]]' + (divBorder + ('[[" name="yccj_list_div">\n                <div class="car_apply_cs_yccj_list_item_div" border="]]' + (divBorder + ('[[" name="yccj_list_item_div">\n                    <div class="space_10_div" border="]]' + (divBorder + ('[[" />\n                    ]]' + (yccj_list_div_item_html + '[[\n                </div>\n            </div>\n        ]]')))))));
        document.getElementsByName('yccj_list_div')[1].setInnerHTML(yccj_list_div_html);
        var Line1AdapterArg = {
            initLeft: '10',
            counts: business_rule_len,
            label1Content: 'b_counts_label',
            label1FontSize: '10',
            label2Content: 'b_limit_label',
            label2FontSize: '10',
            label3Content: 'b_time_label',
            label3FontSize: '10'
        };
        lua_car.rule_msg_width_adapter(Line1AdapterArg);
        var Line2AdapterArg = {
            initLeft: '10',
            counts: business_rule_len,
            label1Content: 'taxi_agent_btn',
            label1FontSize: '10',
            label2Content: 'car_apply_cs_b_useex_label',
            label2FontSize: '12',
            label3Content: 'car_apply_cs_b_useexarw_icon',
            label3FontSize: '10',
            label3AutoHide: 'false'
        };
        lua_car.rule_msg_width_adapter(Line2AdapterArg);
        if (type === 'apply') {
            if (business_rule_len === 1 || selectFirstOption === 'true') {
                var idusecarInstitutionFirst = formatNull(business_use_car_rule[1]['idusecarInstitution']);
                lua_car.choose_business_car_rule(idusecarInstitutionFirst);
            } else {
                lua_car.render_addr_default_page();
                close_loading();
            }
        }
    }
};
lua_car.render_addr_default_page = function () {
    var select_addr_default_div_html = '[[\n        <div class="choose_location_div" name="choose_location_div" border="1">\n            <div class="choose_location_item_div" name="choose_cfdd_div" onclick="lua_car.choose_cfdd_addr()">\n                <label class="ifRequired_css" name="cfdd_required">*</label>\n                <label class="cfdd_choose_label" value="]]' + (C_CFSelectUseCarAddrTip + ('[[" name="choose_cfdd_addr_label" onclick="lua_car.choose_cfdd_addr()" />\n                <img src="local:arrow_common.png" class=\'arrow_icon\'/>\n            </div>\n            <line class="line_css" />\n\n            <div class="choose_location_item_div" name="choose_dddd_div" onclick="lua_car.choose_dddd_addr()">\n                <label class="ifRequired_css" name="dddd_required">*</label>\n                <label class="dddd_choose_label" value="]]' + (C_DDSelectUseCarAddrTip + '[[" name="choose_dddd_addr_label" onclick="lua_car.choose_dddd_addr()" />\n                <img src="local:arrow_common.png" class=\'arrow_icon\'/>\n            </div>\n        </div>\n    ]]')));
    changeStyle('addr_select_div1', 'display', 'none');
    changeStyle('addr_select_div2', 'display', 'block');
};
lua_car.car_bill_check = function (submitFlag, type) {
    if (type === 'apply') {
        SCBP.didibillno = vt('applicationNo', addUseCarBillRes);
        SCBP.createuser = vt('createUser', addUseCarBillRes);
        SCBP.createdate = vt('createDate', addUseCarBillRes);
        SCBP.pkcorp = vt('pkcorp', addUseCarBillRes);
        SCBP.pkdept = vt('deptcode', addUseCarBillRes);
        SCBP.dept = vt('pkdept', addUseCarBillRes);
        SCBP.deptname = vt('deptName', addUseCarBillRes);
        SCBP.corpname = vt('corpName', addUseCarBillRes);
        SCBP.pkuser = vt('pkuser', addUseCarBillRes);
        SCBP.corpcode = vt('corpcode', addUseCarBillRes);
        SCBP.createusercode = vt('usercode', addUseCarBillRes);
        SCBP.pkpsndoc = vt('pkpsndoc', addUseCarBillRes);
    }
    SCBP.tripDetail_lngFrom = useCarLocationParams.cf_addr_longitude;
    SCBP.tripDetail_latFrom = useCarLocationParams.cf_addr_latitude;
    SCBP.tripDetail_companyNameFrom = useCarLocationParams.cf_company_name;
    SCBP.tripDetail_companyCodeFrom = useCarLocationParams.cf_company_code;
    SCBP.tripDetail_cityId = useCarLocationParams.cf_addr_cityCode;
    SCBP.locationstart = useCarLocationParams.cf_addr_address;
    SCBP.tripDetail_lngTo = useCarLocationParams.dd_addr_longitude;
    SCBP.tripDetail_latTo = useCarLocationParams.dd_addr_latitude;
    SCBP.tripDetail_companyNameTo = useCarLocationParams.dd_company_name;
    SCBP.tripDetail_companyCodeTo = useCarLocationParams.dd_company_code;
    SCBP.tripDetail_toCityId = useCarLocationParams.dd_addr_cityCode;
    SCBP.locationend = useCarLocationParams.dd_addr_address;
    SCBP.reason = getValue('use_car_reason');
    SCBP.tripDetail_yccs = getValue('yccs_text');
    var useCarStartDate = getValue('use_car_start_time_label');
    SCBP.dateStart = useCarStartDate;
    var useCarEndDate = getValue('use_car_end_time_label');
    SCBP.dateEnd = useCarEndDate;
    SCBP.billType = billTypeList_utils.ycsq;
    SCBP.submitFlag = submitFlag;
    lua_car.do_submit_car_bill();
};
lua_car.render_business_car_scene = function () {
    var useCarYWCJData = formatNull(companyTable['useCarYWCJData']);
    var useCarYWCJDataCounts = useCarYWCJData.length;
    if (useCarYWCJDataCounts > 0) {
        var selectEleArg = {};
        for (var [key, value] in pairs(useCarYWCJData)) {
            var ywcjContentcode = formatNull(value['businessCode']);
            var ywcjContentname = formatNull(value['businessName']);
            var ywcjInfo = ywcjContentcode + ('_' + ywcjContentname);
            var onclickFun = 'lua_car.select_business_scene(\'' + (ywcjInfo + '\')');
            var selectEleArgItem = {
                labelName: ywcjContentname,
                clickFunc: 'lua_car.select_business_scene',
                clickFuncArg: ywcjInfo
            };
            table.insert(selectEleArg, selectEleArgItem);
        }
        var renderSelectArg = {
            bgName: 'ywcj_page_div',
            topEleName: 'top_ywcj_div',
            topTitleName: '选择业务场景',
            selectEleName: 'ywcj_list_div',
            selectEleArg: selectEleArg,
            renderCallBackFun: 'render_select_ywcj_page_call'
        };
        lua_page.render_select_page(renderSelectArg);
    }
    close_loading();
};
lua_car.init_use_explain_cache = function () {
    globalTable['alertShowPersonalUseInfo'] = null;
    globalTable['alertShowPersonalUseInfo'] = {};
    globalTable['alertShowBusinessUseInfo'] = null;
    globalTable['alertShowBusinessUseInfo'] = {};
};
lua_car.clear_use_addr_info = function (addrType, clearType) {
    var addrType = formatNull(addrType);
    var clearType = formatNull(clearType, 'all');
    var addrLabelName = '';
    var addrLabelDefaultValue = '';
    var addrArgKeyWords = '';
    var companyLabelName = '';
    var companyLabelDefaultValue = '';
    var companyListName = '';
    var companyArgKeyWords = '';
    var addressCtrlFlag = formatNull(globalTable['addressCtrlFlag']);
    if (addrType === 'cfdd') {
        addrLabelName = 'choose_cfdd_addr_label';
        addrLabelDefaultValue = C_CFSelectUseCarAddrTip;
        addrArgKeyWords = 'cf_addr_';
        companyLabelName = 'choose_cfdd_company_label';
        companyLabelDefaultValue = C_CFSelectUseCarCompanyTip;
        companyListName = 'cfdd_company_list';
        companyArgKeyWords = 'cf_company_';
    } else if (addrType === 'dddd') {
        addrLabelName = 'choose_dddd_addr_label';
        addrLabelDefaultValue = C_DDSelectUseCarAddrTip;
        addrArgKeyWords = 'dd_addr_';
        companyLabelName = 'choose_dddd_company_label';
        companyLabelDefaultValue = C_DDSelectUseCarCompanyTip;
        companyListName = 'dddd_company_list';
        companyArgKeyWords = 'dd_company_';
    } else {
        debug_alert('清理类型未定义');
        return;
    }
    var useClear = '';
    if (clearType === 'all') {
        useClear = 'company,addr';
    } else if (clearType === 'company') {
        useClear = 'company';
    } else if (clearType === 'addr') {
        useClear = 'addr';
    }
    if (string.find(useClear, 'company')) {
        if (addressCtrlFlag === '01' || addressCtrlFlag === '02') {
            for (var [key, value] in pairs(useCarLocationParams)) {
                if (string.find(key, companyArgKeyWords)) {
                    useCarLocationParams[key] = '';
                }
            }
            document.getElementsByName(companyListName)[1].setCustomPropertyByName('defaultChecked', '');
            changeProperty(companyLabelName, 'value', companyLabelDefaultValue);
        }
    }
    if (string.find(useClear, 'addr')) {
        for (var [key, value] in pairs(useCarLocationParams)) {
            if (string.find(key, addrArgKeyWords)) {
                useCarLocationParams[key] = '';
            }
        }
        changeProperty(addrLabelName, 'value', addrLabelDefaultValue);
    }
};
lua_car.select_ycfs = function (selectkey) {
    var selectkey = formatNull(selectkey, '1');
    var divElements = document.getElementsByName('ycfs_div');
    var labelElements = document.getElementsByName('ycfs_label');
    for (let i = 1; divElements.length; i++) {
        if (i === parseFloat(selectkey)) {
            divElements[i].setStyleByName('background-image', 'car_checked.png');
            labelElements[i].setStyleByName('color', '#FF4F00');
        } else {
            divElements[i].setStyleByName('background-image', 'car_checkBg.png');
            labelElements[i].setStyleByName('color', '#323233');
        }
    }
    if (selectkey === '1') {
        SCBP.tripDetail_ycfs = '0';
        hide_ele('yccs_div');
    } else if (selectkey === '2') {
        SCBP.tripDetail_ycfs = '1';
        hide_ele('yccs_div');
    } else if (selectkey === '3') {
        SCBP.tripDetail_ycfs = '2';
        show_ele('yccs_div');
    }
    page_reload();
};
lua_car.load_apply_page_element = function (pageConfig) {
    for (let i = 1; pageConfig.length; i++) {
        var Item = formatNull(pageConfig[i]);
        var fieldAppName = vt('fieldName', Item);
        var modelType = vt('modelType', Item);
        if (modelType === '1' && fieldAppName === 'ycsy') {
            var fieldAppDIV = fieldAppName + '_div';
            var fieldAppSpaceDIV = fieldAppName + '_space_div';
            var fieldDispName = Item['fieldDispName'];
            var labelEleName = fieldAppName + '_title';
            var requiredLabelName = fieldAppName + '_required';
            var displayFlag = vt('fieldVisible', Item, '1');
            var requiredStatus = vt('fieldRequired', Item, '1');
            if (displayFlag === '1') {
                changeStyle(fieldAppDIV, 'display', 'block');
                changeStyle(fieldAppSpaceDIV, 'display', 'block');
                changeProperty(labelEleName, 'value', fieldDispName);
                if (requiredStatus === '1') {
                    changeProperty(requiredLabelName, 'value', '*');
                } else {
                    changeProperty(requiredLabelName, 'value', '');
                }
            } else {
                changeStyle(fieldAppDIV, 'display', 'none');
                changeStyle(fieldAppSpaceDIV, 'display', 'none');
            }
        }
    }
    page_reload();
};
lua_car.taxiAgentControlMsg = function (taxiAgentControlFlag) {
    var taxiAgentMsg = '';
    if (taxiAgentControlFlag === '00') {
        taxiAgentMsg = '可代叫';
    }
    if (useCarCardMsgDebug === 'true') {
        taxiAgentMsg = '可代叫';
    }
    return taxiAgentMsg;
};
lua_car.remainTimesMsg = function (Times) {
    var Times = formatNull(Times);
    var showRemainTimes = '不限次';
    if (Times != '') {
        showRemainTimes = '余' + (Times + '次');
    }
    if (useCarCardMsgDebug === 'true') {
        showRemainTimes = '余9999次';
    }
    return showRemainTimes;
};
lua_car.perLimitMsg = function (Limit) {
    var Limit = formatNull(Limit);
    var showPerLimit = '不限额';
    if (Limit != '') {
        showPerLimit = '单笔限额' + (math.ceil(Limit) + '元');
    }
    if (useCarCardMsgDebug === 'true') {
        showPerLimit = '单笔限额123456元';
    }
    return showPerLimit;
};
lua_car.useDateIntervalMsg = function (Start, End, DateType) {
    var Start = formatNull(Start);
    var End = formatNull(End);
    var DateType = formatNull(DateType);
    var showUseDateInterval = '不限期';
    if (Start != '' && End != '') {
        if (DateType === 'timestamp') {
            showUseDateInterval = os.date('%m/%d', Start / 1000) + ('-' + os.date('%m/%d', End / 1000));
        } else if (DateType === 'YYYY-MM-DD') {
            Start = ryt.getSubstringValue(Start, 5, 10);
            Start = string.gsub(Start, '-', '/');
            End = ryt.getSubstringValue(End, 5, 10);
            End = string.gsub(End, '-', '/');
            showUseDateInterval = Start + ('-' + End);
        }
    }
    if (useCarCardMsgDebug === 'true') {
        showUseDateInterval = '09/09-10/10';
    }
    return showUseDateInterval;
};
module.exports = { lua_car: lua_car };