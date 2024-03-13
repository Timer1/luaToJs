--[[用车相关lua]]
lua_car = {};

--选择出发地提示
C_CFSelectUseCarCompanyTip = "请选择出发公司";
C_CFSelectUseCarAddrTip    = "请选择出发地点";
--选择到达地提示
C_DDSelectUseCarCompanyTip = "请选择到达公司";
C_DDSelectUseCarAddrTip    = "请选择到达地点";
--选择场景提示
C_SelectUseCarRuleTip      = "请选择用车场景";
C_NoneUseCarRuleTip        = "无可用的用车场景";
C_NoneUseCarYWCJTip        = "无可用的业务场景";
C_QryAddrByCompanyTip      = "当前公司暂未维护地址";
--用车使用说明缺省显示
showDefaultUseExplain = "无使用说明";
--首页文字配置
businessUseCarTitle="公务用车";
businessUseCarTip="";
personalUseCarTitle="自由出行";
personalUseCarTip="";
--默认使用说明
defaultUseExplainTip="使用说明";
--PC和APP的缺省使用说明配置，当PC返回的使用说明中含有配置信息时，替换成APP的默认说明配置
defaultUseExplainPC="不限";
defaultUseExplainAPP="使用时段不限制";
defaultUseExplainAPP_geRen="仅限支付宝个人支付";

--用车首页边框调试
useCarDebugBorder="0";
--用车卡片信息调试
useCarCardMsgDebug="false";
--用车时间默认开始时间
defaultDateStart = os.date("%Y-%m-%d",os.time());
--用车时间默认结束时间
defaultDateEnd = os.date("%Y-%m-%d",os.time()+(24*60*60));
--查验制度时间（公务用车）
businessCheckRuleTimeFlag = "false";
--查验制度时间（自由出行）
personalCheckRuleTimeFlag = "false";
--用车H5页面展示方式 alert/page
useCarH5PageInitStyle = "alert";
--地址选择H5页面展示方式 alert/page
useCarSelectAddrH5PageInitStyle = "alert";
--页面初始化时，是否默认设置出发城市
useCarInitCfAddr = "true";
--新建用车申请单的响应包
addUseCarBillRes = "";
--配置新建页面是否默认选中第一个业务场景和用车场景 true默认选中，false只有一个时选中第一个（新建逻辑）
selectFirstOption = "false";
--当前选择的用车制度编号
selectUseCarRuleId = "";
--选择的公司
chooseCompanyPkCorp = "";
--限制出发地或目的地为办公地 1为出发地 2为到达地
useCarAddrFlag = "";
--用车申请单用车明细（编辑逻辑）
applicationYc = "";
--用车申请单用车明细初始化标记，只初始化一次（编辑逻辑）
applicationYcInitFlag = "";
--用车使用说明显示长度限制
showUseExplainLength = 20;
--公务用车缓存数据包
applyListCacheData = {};
--用车首页公务、个人卡片滚动缓存
useCarIndexCardCache = {
    --公务用车滚动卡片下标
    BusinessCardIndex="",
    --公务用车滚动卡片制度ID
    BusinessCardRuleId="",
    --个人用车滚动卡片下标
    PersonalCardIndex="",
    --个人用车滚动卡片制度ID
    PersonalCardRuleId=""
};
--跳转H5的经纬度参数，出发cf_开头，到达dd_开头
useCarLocationParams = {
    --出发地点信息
    --经度
    cf_addr_longitude = "",
    --纬度
    cf_addr_latitude = "",
    --地址
    cf_addr_address = "",
    --城市名称
    cf_addr_cityName = "",
    --城市编码
    cf_addr_cityCode = "",
    --公司名称
    cf_company_name = "",
    --公司主键
    cf_company_code = "",
    --根据公司主键查询到的地点列表
    cf_company_addrlist = "",

    --到达地点信息，以dd_开头命名
    --经度
    dd_addr_longitude = "",
    --纬度
    dd_addr_latitude = "",
    --地址
    dd_addr_address = "",
    --城市名称
    dd_addr_cityName = "",
    --城市编码
    dd_addr_cityCode = "",
    --公司名称
    dd_company_name = "",
    --公司主键
    dd_company_code = "",
    --根据公司主键查询到的地点列表
    dd_company_addrlist = ""
};
--保存申请参数列表/submitCarApplyBillParams
SCBP = {
    --app处理交易码
    TranCode = "submitCarApplyBill",
    --app处理提交类型
    submitFlag = "",
    --单据类型
    billType = "",
    --用车申请单号
    didibillno = "",
    --制单人姓名
    createuser = "",
    --制单日期
    createdate = "",
    --机构主键
    pkcorp = "",
    --部门编码
    pkdept = "",
    --部门主键
    dept = "",
    --部门名称
    deptname = "",
    --机构名称
    corpname = "",
    --单据状态码，默认0
    billstatusNo = "0",
    --制单人用户主键
    pkuser = "",
    --用车申请出发地点
    locationstart = "",
    --用车申请到达地点
    locationend = "",
    --机构编码
    corpcode = "",
    --制单人员工编码
    createusercode = "",
    --制单人员工主键
    pkpsndoc = "",
    --用车出行日期开始 yyyy-MM-dd
    dateStart = defaultDateStart,
    --用车事由
    reason = "",
    --用车出行日期结束 yyyy-MM-dd
    dateEnd = defaultDateEnd,
    --用车明细（制度id）
    tripDetail_ruleId = "",
    --用车明细（制度名称）
    tripDetail_carScene = "",
    --用车明细（制度编码）
    tripDetail_carSceneCode = "",
    --用车明细（业务场景名称）
    tripDetail_businessScene = "",
    --用车明细（业务场景编码）
    tripDetail_businessSceneCode = "",
    --用车明细（出发地公司名称）
    tripDetail_companyNameFrom = "",
    --用车明细（出发地公司主键）
    tripDetail_companyCodeFrom = "",
    --用车明细（出发地点经度）
    tripDetail_lngFrom = "",
    --用车明细（出发地点纬度）
    tripDetail_latFrom = "",
    --用车明细（出发城市编码）
    tripDetail_cityId = "",
    --用车明细（到达地公司名称）
    tripDetail_companyNameTo = "",
    --用车明细（到达地公司主键）
    tripDetail_companyCodeTo = "",
    --用车明细（目的地点经度）
    tripDetail_lngTo = "",
    --用车明细（目的地点纬度）
    tripDetail_latTo = "",
    --用车明细（目的城市编码）
    tripDetail_toCityId = "",
    --用车明细（用车方式）
    tripDetail_ycfs = "0",
    --用车明细（用户输入用车次数）
    tripDetail_yccs = "",
    --用车明细（制度限制用车次数）
    tripDetail_carUseLimitCounts = ""
};

--[[用车参数初始化]]
function lua_car.arg_init_qry(ResParams,ReqParams)
    --系统参数查询
    if formatNull(ResParams) == "" then
        --业务场景
        local useCarYWCJData = vt("useCarYWCJData",companyTable);
        --用车场景
        local useCarYCCJData = vt("useCarYCCJData",companyTable);
        --公司控件数据
        local CompanyListWidgetData = vt("CompanyListWidgetData",companyTable);
        --用车渠道配置
        local UseCarEnableChannels = vt("UseCarEnableChannels",companyTable);

        --为空时查询
        local argListTable = {
            useCarYWCJData,
            useCarYCCJData,
            CompanyListWidgetData,
            UseCarEnableChannels
        };
        local checkArgRes = lua_form.arglist_check_empty(argListTable);
        --debug_alert(checkArgRes);

        local ReqParams = formatNull(ReqParams);
        local InitCallFun = vt("InitCallFun",ReqParams);
        if checkArgRes == "true" then
            --debug_alert("用车参数已初始化");

            lua_system.do_function(InitCallFun,"");
        else
            --debug_alert("用车参数初始化-请求");

            ReqParams["TranCode"] = "ArgInitQry";
            invoke_trancode_donot_checkRepeat(
                "jjbx_service",
                "car_service",
                ReqParams,
                lua_car.arg_init_qry,
                {},
                all_callback,
                {CloseLoading="false"}
            );
        end;
    else
        --debug_alert("用车参数初始化-响应");

        --记录初始化标志
        companyTable["CarServiceArgInitStatus"] = "true";

        --用车首页公务、个人卡片滚动缓存初始化
        lua_format.reset_table(useCarIndexCardCache);

        local res = json2table(ResParams["responseBody"]);
        --debug_alert("用车参数初始化-响应\n"..foreach_arg2print(res));

        --存储用车业务场景列表
        if res["YwcjDataErrorNo"] == "000000" then
            local useCarYWCJData = vt("YwcjData",res);
            --debug_alert("业务场景列表\n"..foreach_arg2print(useCarYWCJData));
            
            if useCarYWCJData == "" then
                --alert("没有查询到业务场景信息");
            else
                --业务场景数据存缓存
                companyTable["useCarYWCJData"] = useCarYWCJData;
            end;
        else
            --alert(res["YwcjDataErrorMsg"]);
        end;

        --存储用车场景列表
        if res["YccjDataErrorNo"] == "000000" then
            local useCarYCCJData = vt("YccjData",res);
            --debug_alert("用车场景列表\n"..foreach_arg2print(useCarYCCJData));
            
            if useCarYCCJData == "" then
                --alert("没有查询到用车场景信息");
            else
                --用车场景数据存缓存
                companyTable["useCarYCCJData"] = useCarYCCJData;
            end;
        else
            --alert(res["YccjDataErrorMsg"]);
        end;

        --存储公司列表
        if res["CompanyDataErrorNo"] == "000000" then
            local CompanyData = vt("CompanyData",res);
            --debug_alert("公司数据\n"..CompanyData);
            if CompanyData == "" then
                --alert("没有查询到公司信息");
            else
                --控件数据存缓存
                companyTable["CompanyListWidgetData"] = CompanyData;
            end;
        else
            --alert(res["CompanyDataErrorMsg"]);
        end;

        --存储用车地图H5地址
        --实际地址
        local UseCarSelectMapUrl = vt("UseCarSelectMapUrl",res);
        --demo地址
        local UseCarSelectMapDemoUrl = vt("UseCarSelectMapDemoUrl",res);
        if systemTable["AppEnvironment"] ~= "pro" and systemTable["PublicNetHost"]=="false" then
            --debug_alert("非生产环境且访问为内网时候，使用demo地址");
            UseCarSelectMapUrl = UseCarSelectMapDemoUrl;
        end;
        --地址存缓存
        globalTable["UseCarSelectMapUrl"] = UseCarSelectMapUrl;
        --debug_alert("地图地址 : "..globalTable["UseCarSelectMapUrl"]);

        --设置用车的渠道
        lua_car.set_channel(res);

        --参数初始化完成回调
        local InitCallFun = vt("InitCallFun",res);
        lua_system.do_function(InitCallFun,"");
    end;
end;

--[[设置用车的渠道]]
function lua_car.set_channel(Arg)
    local Arg = formatNull(Arg);

    --滴滴是否启用
    local DiDiEnable = "false";
    --曹操是否启用
    local CaoCaoEnable = "false";
    --设置的渠道 00-曹操出行 01-滴滴出行 02-滴滴出行，曹操出行 03-都未启用
    local SetUseCarEnableChannels = "03";

    --用车渠道配置(权限高) 0-不开启 1-滴滴出行 2-曹操出行 1,2/2,1-滴滴+曹操
    local carService = formatNull(companyTable["thirdPartyServiceStatus"]["carService"]);
    --用车渠道配置(权限低) 00-曹操出行 01-滴滴出行 02-滴滴出行，曹操出行 03-都未启用
    local UseCarEnableChannels = vt("UseCarEnableChannels",Arg,"03");
    
    if configTable["ThirdServiceConfigSwitch"] == "false" then
        --配置关闭的时候，设置所有渠道可用
        SetUseCarEnableChannels = "02";
    else
        if string.find(carService,"1") then
            if string.find(UseCarEnableChannels,"01") or string.find(UseCarEnableChannels,"02") then
                DiDiEnable = "true";
            end;
        end;

        if string.find(carService,"2") then
            if string.find(UseCarEnableChannels,"00") or string.find(UseCarEnableChannels,"02") then
                CaoCaoEnable = "true";
            end;
        end;

        if DiDiEnable=="true" and CaoCaoEnable=="true" then
            --均开启
            SetUseCarEnableChannels = "02";
        elseif DiDiEnable=="true" and CaoCaoEnable=="false" then
            --仅滴滴
            SetUseCarEnableChannels = "01";
        elseif DiDiEnable=="false" and CaoCaoEnable=="true" then
            --仅曹操
            SetUseCarEnableChannels = "00";
        end;
    end;

    --[[debug_alert(
        "APP用车渠道设置\n\n"..
        "内管配置 :\n"..carService.."(0禁用 1滴滴 2曹操)\n"..
        "机构配置 :\n"..UseCarEnableChannels.."(00曹操 01滴滴 02滴滴曹操 03禁用)\n\n"..
        "实际设置 :\n"..SetUseCarEnableChannels.."(00曹操 01滴滴 02滴滴曹操 03禁用)\n\n"..
        "启用情况 :\n"..
        "滴滴 : "..DiDiEnable.."\n"..
        "曹操 : "..CaoCaoEnable.."\n"..
        ""
    );]]

    --设置用车渠道
    companyTable["UseCarEnableChannels"] = SetUseCarEnableChannels;
end;

--[[将查询出来的公务用车申请单数据存入公务用车缓存数据包]]
function lua_car.insert_apply_list_cache_data(key,value)
    if formatNull(key) ~= "" then
        local addItem = {
            key=key,
            value=value
        };
        table.insert(applyListCacheData,addItem);
    end;
end;

--[[清理公务用车缓存数据包]]
function lua_car.reset_apply_list_cache_data()
    applyListCacheData = {};
end;

--[[根据单据号查找对应的公务用车申请单信息]]
function lua_car.find_apply_data(billNo)
    local res = "";
    if formatNull(billNo) ~= "" then
        for key,value in pairs(applyListCacheData) do
            local dataKey = vt("key",value);
            if billNo == dataKey then
                local dataValue = vt("value",value);
                res = dataValue;
            end;
        end;
    end;
    return res;
end;

--[[根据用车场景地址管控规则渲染地址选择界面]]
function lua_car.render_select_addr_div()
    --地址管控类型
    local addressCtrlFlag = vt("addressCtrlFlag",globalTable);
    local select_addr_div_html = "";

    if addressCtrlFlag == "01" or addressCtrlFlag == "02" then
        local start_location_type_switch_div_html = "";
        local end_location_type_switch_div_html = "";

        if addressCtrlFlag == "01" then
            --debug_alert("01限制出发地或目的地为办公地，添加切换层");

            start_location_type_switch_div_html = [[
                <div class="choose_location_item_div" name="cfdd_div">
                    <label class="ifRequired_css" name="cfdd_required">*</label>
                    <label class="cfdd_title_label" name="cfdd_title" value="出发地点"></label>
                    <div class="choose_location_type_div" border="0">
                        <input type="button" class="choose_location_company_btn" value="公司" name="ycdd_type_btn" onclick="lua_car.location_type_switch(1)"/>
                        <input type="button" class="choose_location_customer_btn" value="自定义" name="ycdd_type_btn" onclick="lua_car.location_type_switch(2)"/>
                    </div>
                </div>
            ]];

            end_location_type_switch_div_html = [[
                <div class="choose_location_item_div" name="dddd_div">
                    <label class="ifRequired_css" name="dddd_required">*</label>
                    <label class="dddd_title_label" name="dddd_title" value="到达地点"></label>
                    <div class="choose_location_type_div" border="0">
                        <input type="button" class="choose_location_company_btn" value="公司" name="ycdd_type_btn" onclick="lua_car.location_type_switch(3)"/>
                        <input type="button" class="choose_location_customer_btn" value="自定义" name="ycdd_type_btn" onclick="lua_car.location_type_switch(4)"/>
                    </div>
                </div>
            ]];
        else
            --debug_alert("02限制出发地和目的地均为办公地");
        end;

        select_addr_div_html = start_location_type_switch_div_html..[[
            <div class="choose_location_item_div" name="choose_cfdd_company_div" onclick="lua_car.choose_cfdd_company()">
                <label class="ifRequired_css" name="company_required">*</label>
                <label class="cfdd_choose_label" value="]]..C_CFSelectUseCarCompanyTip..[[" name="choose_cfdd_company_label" onclick="lua_car.choose_cfdd_company()" />
                <img src="local:arrow_common.png" class='arrow_icon'/>
            </div>
            <div class="choose_location_item_div" name="choose_cfdd_div" onclick="lua_car.choose_cfdd_addr()">
                <label class="ifRequired_css" name="cfdd_required">*</label>
                <label class="cfdd_choose_label" value="]]..C_CFSelectUseCarAddrTip..[[" name="choose_cfdd_addr_label" onclick="lua_car.choose_cfdd_addr()" />
                <img src="local:arrow_common.png" class='arrow_icon'/>
            </div>
            <line class="line_css" />

            ]]..end_location_type_switch_div_html..[[
            <div class="choose_location_item_div" name="choose_dddd_company_div" onclick="lua_car.choose_dddd_company()">
                <label class="ifRequired_css" name="company_required">*</label>
                <label class="cfdd_choose_label" value="]]..C_DDSelectUseCarCompanyTip..[[" name="choose_dddd_company_label" onclick="lua_car.choose_dddd_company()" />
                <img src="local:arrow_common.png" class='arrow_icon'/>
            </div>
            <div class="choose_location_item_div" name="choose_dddd_div" onclick="lua_car.choose_dddd_addr()">
                <label class="ifRequired_css" name="dddd_required">*</label>
                <label class="dddd_choose_label" value="]]..C_DDSelectUseCarAddrTip..[[" name="choose_dddd_addr_label" onclick="lua_car.choose_dddd_addr()" />
                <img src="local:arrow_common.png" class='arrow_icon'/>
            </div>
        ]];
    else
        --debug_alert("其他为不管控（默认显示出发地和到达地选择），不另做处理");
        select_addr_div_html = [[
            <div class="choose_location_item_div" name="choose_cfdd_div" onclick="lua_car.choose_cfdd_addr()">
                <label class="ifRequired_css" name="cfdd_required">*</label>
                <label class="cfdd_choose_label" value="]]..C_CFSelectUseCarAddrTip..[[" name="choose_cfdd_addr_label" onclick="lua_car.choose_cfdd_addr()" />
                <img src="local:arrow_common.png" class='arrow_icon'/>
            </div>
            <line class="line_css" />

            <div class="choose_location_item_div" name="choose_dddd_div" onclick="lua_car.choose_dddd_addr()">
                <label class="ifRequired_css" name="dddd_required">*</label>
                <label class="dddd_choose_label" value="]]..C_DDSelectUseCarAddrTip..[[" name="choose_dddd_addr_label" onclick="lua_car.choose_dddd_addr()" />
                <img src="local:arrow_common.png" class='arrow_icon'/>
            </div>
        ]];
    end;

    select_addr_div_html = [[
        <div class="choose_location_div" name="choose_location_div" border="1">
            ]]..select_addr_div_html..[[
        </div>
    ]];

    --[[debug_alert(
        "根据用车场景地址管控规则渲染地址选择界面\n"..
        "addressCtrlFlag : "..addressCtrlFlag.."\n"..
        "select_addr_div_html : "..select_addr_div_html.."\n"..
        ""
    );]]

    document:getElementsByName("choose_location_div")[1]:setInnerHTML(select_addr_div_html);
    page_reload();

    --清空记录选中状态
    globalTable["useCarLocationTypeSwitchIndex"] = "";

    if addressCtrlFlag == "01" then
        --单向管控时，默认选择第一个
        lua_car.location_type_switch(1);
    elseif addressCtrlFlag == "02" then
        --管控均为公司

        --出发公司和到达公司默认选择当前人员所在公司
        lua_car.select_current_company("all");
    else
        --不管控的情况
    end;
end;

--[[初始化出发地点地址信息]]
function lua_car.init_cfdd_addr(params)
    if useCarInitCfAddr == "true" then
        if formatNull(params)=="" and systemTable["location_cityCode"]=="" then
            local cityName = vt("location_cityName",systemTable);
            --debug_alert("使用客户端定位的城市名称向后台获取匹配的城市编码\n城市名称 : "..cityName);

            if cityName ~= "" then
                --debug_alert("初始化出发地点地址信息-请求");

                invoke_trancode_donot_checkRepeat(
                    "jjbx_service",
                    "app_service",
                    {TranCode="QryCityInfoByCityName",cityName=cityName},
                    lua_car.init_cfdd_addr,
                    {},
                    all_callback,
                    {CloseLoading="false"}
                );
            else
                close_loading();
                --debug_alert("定位失败");
            end;
        else
            --城市名称
            local cityName = "";
            --城市编码
            local cityCode = "";

            if formatNull(params)=="" and systemTable["location_cityCode"]~="" then
                --debug_alert("定位里有城市编码，不另外发请求获取");
                cityName = vt("location_cityName",systemTable);
                cityCode = vt("location_cityCode",systemTable);
            else
                --debug_alert("定位里没有城市编码，发请求获取");
                local res = json2table(params["responseBody"]);
                --debug_alert("初始化出发地点地址信息-响应\n"..foreach_arg2print(res));
                local cityInfo = vt("cityInfo",res);
                --后台返回的城市名称和编码（高德坐标系）
                cityName = vt("cityName",cityInfo);
                cityCode = vt("cityCode",cityInfo);

                --获取到的城市编码存到系统变量中
                systemTable["location_cityCode"] = cityCode;
            end;

            local longitude = vt("location_longitude",systemTable);
            local latitude = vt("location_latitude",systemTable);
            local addr = vt("location_addr",systemTable);

            --管控的出发地点集合
            local cfddCtrlCityCodes = formatNull(globalTable["cfddCtrlCityCodes"]);

            --城市编码只能为数字
            local cityCodeCheckRes = formatNull(tonumber(cityCode));

            --[[debug_alert(
                "城市名称 : "..cityName.."\n"..
                "城市编码 : "..cityCode.."\n"..
                "编码检查 : "..cityCodeCheckRes.."\n"..
                "管控集合 : "..cfddCtrlCityCodes.."\n"..
                ""
            );]]

            --设置页面初始显示
            changeProperty("choose_cfdd_addr_label","value",C_CFSelectUseCarAddrTip);
            --清空用车地理位置参数包
            lua_format.reset_table(useCarLocationParams);

            --当前定位城市编码不为空
            if cityCodeCheckRes ~= "" then
                --没有管控 或 有管控且出发地点在管控集合内则设置出发地点
                if cfddCtrlCityCodes=="" or (cfddCtrlCityCodes~="" and string.find(cfddCtrlCityCodes,cityCode)) then
                    --debug_alert("管控城市为空或当前定位在管控城市集合内，校验空参");

                    --空参校验
                    local argListTable = {
                        longitude,
                        latitude,
                        addr,
                        cityName,
                        cityCode
                    };
                    --debug_alert("匹配到城市编码时初始化出发城市参数列表\n"..foreach_arg2print(argListTable));

                    --匹配到城市编码时初始化出发城市参数列表
                    if lua_form.arglist_check_empty(argListTable) == "true" then
                        useCarLocationParams.cf_addr_longitude=longitude;
                        useCarLocationParams.cf_addr_latitude=latitude;
                        useCarLocationParams.cf_addr_address=addr;
                        useCarLocationParams.cf_addr_cityName=cityName;
                        useCarLocationParams.cf_addr_cityCode=cityCode;

                        --设置页面显示地址
                        changeProperty("choose_cfdd_addr_label","value",addr);
                    end;
                else
                   --debug_alert("当前定位不在管控城市，请重新选择");
                end;
            else
                --debug_alert("城市编码为空或不为数字");
            end;
            close_loading();
        end;
    else
        --debug_alert("不初始化出发地点地址信息");
        close_loading();
    end;
end;

--[[地点类型切换]]
function lua_car.location_type_switch(index)
    --当前下标
    local useCarLocationTypeSwitchIndex = vt("useCarLocationTypeSwitchIndex",globalTable);
    --目标下标
    local index = formatNull(index);

    --[[debug_alert(
        "地点类型切换\n"..
        "当前下标 : "..useCarLocationTypeSwitchIndex.."\n"..
        "目标下标 : "..tostring(index).."\n"..
        ""
    );]]

    --判断是否选择过下标，且下标是否被更换
    if useCarLocationTypeSwitchIndex~="" and string.find(useCarLocationTypeSwitchIndex,tostring(index)) then
        --debug_alert("未切换");
    else
        --按钮对象
        local locationTypeEles = document:getElementsByName("ycdd_type_btn");

        --地址管控类型
        local addressCtrlFlag = vt("addressCtrlFlag",globalTable);
        if addressCtrlFlag == "01" then
            --[[debug_alert(
                "01限制出发地或目的地为办公地\n"..
                "code : "..addressCtrlFlag.."\n"..
                "index : "..index.."\n"..
                ""
            );]]

            --更新提示文字信息和选中状态，对角切换
            if index==1 or index==4 then
                --debug_alert("记录选中状态（出发地为公司）");

                globalTable["useCarLocationTypeSwitchIndex"] = "14";
                useCarAddrFlag=1;

                show_ele("choose_cfdd_company_div");
                changeProperty("choose_cfdd_company_label","value",C_CFSelectUseCarCompanyTip);
                changeProperty("choose_cfdd_addr_label","value",C_CFSelectUseCarAddrTip);

                hide_ele("choose_dddd_company_div");
                changeProperty("choose_dddd_addr_label","value",C_DDSelectUseCarAddrTip);

                locationTypeEles[1]:setStyleByName("background-image","car_checked.png");
                locationTypeEles[1]:setStyleByName("color","#FE6F14");
                locationTypeEles[4]:setStyleByName("background-image","car_checked.png");
                locationTypeEles[4]:setStyleByName("color","#FE6F14");

                locationTypeEles[2]:setStyleByName("background-image","car_checkBg.png");
                locationTypeEles[2]:setStyleByName("color","#999999");
                locationTypeEles[3]:setStyleByName("background-image","car_checkBg.png");
                locationTypeEles[3]:setStyleByName("color","#999999");
            elseif index==2 or index==3 then
                --debug_alert("记录选中状态（到达地为公司）");

                globalTable["useCarLocationTypeSwitchIndex"] = "23";
                useCarAddrFlag=2;

                show_ele("choose_dddd_company_div");
                changeProperty("choose_dddd_company_label","value",C_DDSelectUseCarCompanyTip);
                changeProperty("choose_dddd_addr_label","value",C_DDSelectUseCarAddrTip);

                hide_ele("choose_cfdd_company_div");
                changeProperty("choose_cfdd_addr_label","value",C_CFSelectUseCarAddrTip);

                locationTypeEles[2]:setStyleByName("background-image","car_checked.png");
                locationTypeEles[2]:setStyleByName("color","#FE6F14");
                locationTypeEles[3]:setStyleByName("background-image","car_checked.png");
                locationTypeEles[3]:setStyleByName("color","#FE6F14");

                locationTypeEles[1]:setStyleByName("background-image","car_checkBg.png");
                locationTypeEles[1]:setStyleByName("color","#999999");
                locationTypeEles[4]:setStyleByName("background-image","car_checkBg.png");
                locationTypeEles[4]:setStyleByName("color","#999999");
            else

            end;
        else
            --不存在该场景
        end;

        --还原选择显示
        changeProperty("choose_cfdd_company_label","value",C_CFSelectUseCarCompanyTip);
        changeProperty("choose_cfdd_addr_label","value",C_CFSelectUseCarAddrTip);
        changeProperty("choose_dddd_company_label","value",C_DDSelectUseCarCompanyTip);
        changeProperty("choose_dddd_addr_label","value",C_DDSelectUseCarAddrTip);

        --还原选择参数（出发地点经纬度）
        lua_format.reset_table(useCarLocationParams);

        --还原申请单参数（出发地点经纬度）
        if formatNull(SCBP) ~= "" then
            SCBP.tripDetail_lngFrom="";
            SCBP.tripDetail_latFrom="";
            SCBP.locationstart="";
            SCBP.tripDetail_lngTo="";
            SCBP.tripDetail_latTo="";
            SCBP.locationend="";
        end;

        if index==1 or index==4 then
            --出发公司触发一次选择动作，默认选择当前人员所在公司
            lua_car.select_current_company("cfdd");
        end;

        page_reload();
    end;
end;

--[[选择出发地点公司]]
function lua_car.choose_cfdd_company()
    --首页跳转的自由出行不校验用车场景
    if globalTable["setCityCtrlType"] ~= "index" then
        --校验用车场景是否选择
        if SCBP.tripDetail_ruleId == "" then
            alert(C_SelectUseCarRuleTip)
            return;
        end;
    end;
    --debug_alert("出发地点-选择公司");
    lua_page.div_page_ctrl("cfdd_company_page_bg_div", "true", "true");
end;

--[[选择到达地点公司]]
function lua_car.choose_dddd_company()
    --首页跳转的自由出行不校验用车场景
    if globalTable["setCityCtrlType"] ~= "index" then
        --校验用车场景是否选择
        if SCBP.tripDetail_ruleId == "" then
            alert(C_SelectUseCarRuleTip)
            return;
        end;
    end;
    --校验出发地点是否选择
    local checkCfddArgTable = {
        useCarLocationParams.cf_addr_longitude,
        useCarLocationParams.cf_addr_latitude,
        useCarLocationParams.cf_addr_address,
        useCarLocationParams.cf_addr_cityCode
    };
    if lua_form.arglist_check_empty(checkCfddArgTable) ~= "true" then
        alert("请先选择出发地点");
        return;
    end;
    
    --debug_alert("到达地点-选择公司");
    lua_page.div_page_ctrl("dddd_company_page_bg_div", "true", "true");
end;

--[[选择出发地点]]
function lua_car.choose_cfdd_addr()
    --首页跳转的自由出行不校验用车场景
    if globalTable["setCityCtrlType"] ~= "index" then
        --校验用车场景是否选择
        if SCBP.tripDetail_ruleId == "" then
            alert(C_SelectUseCarRuleTip)
            return;
        end;
    end;
    --地址管控类型
    local addressCtrlFlag = formatNull(globalTable["addressCtrlFlag"]);
    local useCarAddrFlagNow = formatNull(useCarAddrFlag);
    local useCfddAddrList = formatNull(useCarLocationParams.cf_company_addrlist);

    --[[debug_alert(
        "选择出发地点\n"..
        "地址管控规则 : "..addressCtrlFlag.."\n"..
        "公司/自定义切换下标 : "..useCarAddrFlagNow.."\n"..
        "使用公司列表 : "..foreach_arg2print(useCfddAddrList).."\n"..
        ""
    );]]

    local chooseCfddAddrTip = "无可选出发地点，请重新选择公司";
    if addressCtrlFlag == "01" then
        --限制出发地或目的地为办公地
        if useCarAddrFlagNow == 1 then
            --当前出发地为办公地
            if #useCfddAddrList > 0 then
                lua_page.div_page_ctrl("cfdd_addr_list_page_div", "true", "true");
            else
                alert(chooseCfddAddrTip);
            end;
        else
            lua_car.select_use_car_city_by_h5("cfdd");
        end;
    elseif addressCtrlFlag == "02" then
        --均限制为办公地址
        if #useCfddAddrList > 0 then
            lua_page.div_page_ctrl("cfdd_addr_list_page_div", "true", "true");
        else
            alert(chooseCfddAddrTip);
        end;
    else
        --00或其他均不限制
        lua_car.select_use_car_city_by_h5("cfdd");
    end;
end;

--[[选择到达地点]]
function lua_car.choose_dddd_addr()
    --首页跳转的自由出行不校验用车场景
    if globalTable["setCityCtrlType"] ~= "index" then
        --校验用车场景是否选择
        if SCBP.tripDetail_ruleId == "" then
            alert(C_SelectUseCarRuleTip)
            return;
        end;
    end;
    --校验出发地点是否选择
    local checkCfddArgTable = {
        useCarLocationParams.cf_addr_longitude,
        useCarLocationParams.cf_addr_latitude,
        useCarLocationParams.cf_addr_address,
        useCarLocationParams.cf_addr_cityCode
    };
    if lua_form.arglist_check_empty(checkCfddArgTable) ~= "true" then
        alert("请先选择出发地点");
        return;
    end;

    --切换公司地点
    local useCarAddrFlagNow = formatNull(useCarAddrFlag);
    --公司查询地址
    local useDdddAddrList = formatNull(useCarLocationParams.dd_company_addrlist);
    --地址管控类型
    local addressCtrlFlag = formatNull(globalTable["addressCtrlFlag"]);
    --APP应用跨城管控
    local crossCityCtrlFlag = formatNull(globalTable["crossCityCtrlFlag"],"01");

    --不允许跨城时，将到达地址的管控信息设置为已经选择的出发地信息
    if crossCityCtrlFlag == "00" then
        --APP应用到达管控
        globalTable["ddddCtrlCityCodes"] = formatNull(useCarLocationParams.cf_addr_cityCode);
        globalTable["ddddCtrlCityNames"] = formatNull(useCarLocationParams.cf_addr_cityName);
    else
        --允许跨城不更新参数
    end;

    --[[debug_alert(
        "选择到达地点\n"..
        "应用跨城管控 : "..crossCityCtrlFlag.."\n"..
        "地址管控类型 : "..addressCtrlFlag.."\n"..
        "切换公司地点 : "..useCarAddrFlagNow.."\n"..
        "公司查询地址 : "..foreach_arg2print(useDdddAddrList).."\n"..
        "\n"..
        "APP应用到达管控编码 : "..formatNull(globalTable["ddddCtrlCityCodes"]).."\n"..
        "APP应用到达管控名称 : "..formatNull(globalTable["ddddCtrlCityNames"]).."\n"..
        ""
    );]]

    local chooseDdddAddrTip = "无可选到达地点，请重新选择公司";
    if addressCtrlFlag == "01" then
        --限制出发地或目的地为办公地
        if useCarAddrFlagNow == 2 then
            --当前到达地为办公地
            if #useDdddAddrList > 0 then
                lua_page.div_page_ctrl("dddd_addr_list_page_div", "true", "true");
            else
                alert(chooseDdddAddrTip);
            end;
        else
            lua_car.select_use_car_city_by_h5("dddd");
        end;
    elseif addressCtrlFlag == "02" then
        --均限制为办公地址
        if #useDdddAddrList > 0 then
            lua_page.div_page_ctrl("dddd_addr_list_page_div", "true", "true");
        else
            alert(chooseDdddAddrTip);
        end;
    else
        --00或其他均不限制
        lua_car.select_use_car_city_by_h5("dddd");
    end;
end;

--[[选择用车地址]]
function lua_car.select_use_car_addr(companyType,index)
    --关闭选择界面
    lua_page.div_page_ctrl();

    --公司类型
    local companyType = formatNull(companyType);

    local addrInfo = "";
    if companyType == "cfdd" then
        addrInfo = formatNull(useCarLocationParams.cf_company_addrlist[tonumber(index)]);
    elseif companyType == "dddd" then
        addrInfo = formatNull(useCarLocationParams.dd_company_addrlist[tonumber(index)]);
    else

    end;

    --debug_alert("选择用车地址"..foreach_arg2print(addrInfo));

    --经纬度
    local addrLongitude = vt("lng",addrInfo);
    local addrLatitude = vt("lat",addrInfo);
    --地址
    local address = vt("address",addrInfo);
    --建筑
    local building = vt("building",addrInfo);
    --城市编码
    local cityCode = vt("city",addrInfo);
    --城市名称（后台暂不支持）
    local cityName = "";

    --地址管控类型
    local addressCtrlFlag = formatNull(globalTable["addressCtrlFlag"]);
    --管控是否跨城
    local crossCityCtrlFlag = formatNull(globalTable["crossCityCtrlFlag"]);
    --出发地点管控城市编码
    local cfddCtrlCityCodes = formatNull(globalTable["cfddCtrlCityCodes"]);
    --出发地点管控城市名称
    local cfddCtrlCityNames = formatNull(globalTable["cfddCtrlCityNames"]);
    --到达地点管控城市编码
    local ddddCtrlCityCodes = formatNull(globalTable["ddddCtrlCityCodes"]);
    --到达地点管控城市名称
    local ddddCtrlCityNames = formatNull(globalTable["ddddCtrlCityNames"]);

    --选择后实际查询使用的公司主键
    local useChooseCompanyPkCorp = formatNull(chooseCompanyPkCorp);

    if crossCityCtrlFlag=="00" and companyType=="cfdd" then
        --不允许跨城时，选择出发地点，需要将选择的城市名称和城市编码覆盖至管控参数供后续使用
        globalTable["cfddCtrlCityCodes"] = cityCode;
        globalTable["cfddCtrlCityNames"] = cityName;
    end;

    if companyType == "cfdd" then
        useCarLocationParams.cf_addr_longitude = addrLongitude;
        useCarLocationParams.cf_addr_latitude = addrLatitude;
        useCarLocationParams.cf_addr_address = address;
        useCarLocationParams.cf_addr_cityCode = cityCode;

        if address ~= "" then
            changeProperty("choose_cfdd_addr_label","value",address);
        end;

        if globalTable["crossCityCtrlFlag"] == "00" then
            --debug_alert("不允许跨城时，选择出发地点后，清理到达地点信息");
            lua_car.clear_use_addr_info("dddd","all");
        end;
    elseif companyType == "dddd" then
        useCarLocationParams.dd_addr_longitude = addrLongitude;
        useCarLocationParams.dd_addr_latitude = addrLatitude;
        useCarLocationParams.dd_addr_address = address;
        useCarLocationParams.dd_addr_cityCode = cityCode;

        if address ~= "" then
            changeProperty("choose_dddd_addr_label","value",address);
        end;
    end;

    --[[debug_alert(
        "选择用车地址\n"..
        "公司地址类型 : "..companyType.."\n"..
        "经纬度 : "..addrLongitude.."/"..addrLatitude.."\n"..
        "地址 : "..address.."\n"..
        "建筑 : "..building.."\n"..
        "编码 : "..cityCode.."\n"..
        "\n"..
        "APP应用出发管控编码 : "..globalTable["cfddCtrlCityCodes"].."\n"..
        "APP应用出发管控名称 : "..globalTable["cfddCtrlCityNames"].."\n"..
        ""
    );]]
end;

--[[通过公司查询可选地址]]
function lua_car.qry_addr_by_company(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        --debug_alert("通过公司查询可选地址-请求");
        --区分出发公司和到达公司
        local companyType = vt("companyType",ReqParams);
        --公司名称
        local companyName = vt("companyName",ReqParams);
        --公司主键
        local companyPkCorp = vt("companyPkCorp",ReqParams);
        --清理标记，选择后的清理逻辑是否执行，初始化设置参数时传false
        local clearFlag = vt("clearFlag",ReqParams,"true");

        --地址管控类型
        local addressCtrlFlag = formatNull(globalTable["addressCtrlFlag"]);
        --管控是否跨城
        local crossCityCtrlFlag = formatNull(globalTable["crossCityCtrlFlag"]);
        --出发地点管控城市编码
        local cfddCtrlCityCodes = formatNull(globalTable["cfddCtrlCityCodes"]);
        --出发地点管控城市名称
        local cfddCtrlCityNames = formatNull(globalTable["cfddCtrlCityNames"]);
        --到达地点管控城市编码
        local ddddCtrlCityCodes = formatNull(globalTable["ddddCtrlCityCodes"]);
        --到达地点管控城市名称
        local ddddCtrlCityNames = formatNull(globalTable["ddddCtrlCityNames"]);

        --优先获取选择的公司主键
        local useChooseCompanyPkCorp = formatNull(chooseCompanyPkCorp,companyPkCorp);

        --管控出发地或目的地时，需要上送管控的城市编码去后台获取地址
        local useQryCityCodes = "";
        local useQryCityNames = "";

        --不允许跨城
        if crossCityCtrlFlag == "00" then
            if companyType == "dddd" then
                --选择到达地点时候使用出发地点实际选择的城市名称和城市编码（因为是优先选择出发地点，所以这个时候的缓存已经被重新设置）
                useQryCityCodes = cfddCtrlCityCodes;
                useQryCityNames = cfddCtrlCityNames;
            elseif companyType == "cfdd" then
                --选择出发地点
                if addressCtrlFlag=="01" or addressCtrlFlag=="02" then
                    --出发地和到达地有管控公司地址时，不取后台的编码控制，使用空参数
                else
                    --出发地和到达地均不管控公司地址时，使用后台设置的管控城市（不允许跨城的时候以出发地控制为准）
                    useQryCityCodes = cfddCtrlCityCodes;
                    useQryCityNames = cfddCtrlCityNames;
                end;
            else

            end;
        else
            --允许跨城，取设置的出发地和到达地编码控制，各自应用至出发地和到达地
            if companyType == "cfdd" then
                --设置出发地点管控
                useQryCityCodes = cfddCtrlCityCodes;
                useQryCityNames = cfddCtrlCityNames;
            elseif companyType == "dddd" then
                --设置到达地点管控
                useQryCityCodes = ddddCtrlCityCodes;
                useQryCityNames = ddddCtrlCityNames;
            else

            end;
        end;

        --[[debug_alert(
            "通过公司查询可选地址-请求\n"..
            "公司出发到达 : "..companyType.."\n"..
            "地址管控类型 : "..addressCtrlFlag.."\n"..
            "公司查询地址 : "..addressCtrlFlag.."\n"..
            "管控是否跨城 : "..crossCityCtrlFlag.."\n"..
            "出发管控城市 : "..cfddCtrlCityCodes.."\n"..
            "到达管控城市 : "..ddddCtrlCityCodes.."\n"..
            "查询公司主键 : "..useChooseCompanyPkCorp.."\n"..
            "公司名称 : "..companyName.."\n"..
            "公司主键 : "..companyPkCorp.."\n"..
            "\n"..
            "APP应用城市编码 : "..useQryCityCodes.."\n"..
            "APP应用城市名称 : "..useQryCityNames.."\n"..
            ""
        );]]

        if useChooseCompanyPkCorp ~= "" then
            invoke_trancode_donot_checkRepeat(
                "jjbx_service",
                "app_service",
                {
                    TranCode="qryAddress",
                    pkCorp=useChooseCompanyPkCorp,
                    cityCodes=useQryCityCodes,
                    cityNames=useQryCityNames,
                    companyType=companyType,
                    companyName=companyName,
                    companyPkCorp=companyPkCorp,
                    clearFlag=clearFlag
                },
                lua_car.qry_addr_by_company,
                {},
                all_callback,
                {CloseLoading="false"}
            );
        else
            alert("请先选择公司");
        end;
    else
        local res = json2table(ResParams["responseBody"]);
        --debug_alert("通过公司查询可选地址-响应\n"..foreach_arg2print(res));
        if res["errorNo"] == "000000" then
            close_loading();

            local crossCityCtrlFlag = formatNull(globalTable["crossCityCtrlFlag"]);
            local addressList = vt("addressList",res);
            local cityCodes = vt("cityCodes",res);
            local cityNames = vt("cityNames",res);
            local companyType = vt("companyType",res);
            local companyName = vt("companyName",res);
            local companyPkCorp = vt("companyPkCorp",res);
            local clearFlag = vt("clearFlag",res);

            --[[debug_alert(
                "通过公司查询可选地址-响应\n"..
                "公司类型 : "..companyType.."\n"..
                "公司名称 : "..companyName.."\n"..
                "公司主键 : "..companyPkCorp.."\n"..
                "城市编码 : "..cityCodes.."\n"..
                "允许跨城 : "..crossCityCtrlFlag.."\n"..
                "城市名称 : "..cityNames.."\n"..
                "清理标识 : "..clearFlag.."\n"..
                "地址列表 : "..foreach_arg2print(addressList).."\n"..
                ""
            );]]

            if #addressList > 0 then
                --查询到地址列表

                --关闭选择界面
                lua_page.div_page_ctrl();

                if companyType == "cfdd" then
                    --存储出发公司名称和主键
                    useCarLocationParams.cf_company_name = companyName;
                    useCarLocationParams.cf_company_code = companyPkCorp;
                    --将地址信息存为出发地点列表
                    useCarLocationParams.cf_company_addrlist = addressList;

                    --选择出发公司后，清理已经选择的出发地点信息
                    if clearFlag == "true" then
                        lua_car.clear_use_addr_info("cfdd","addr");

                        if crossCityCtrlFlag == "00" then
                            --debug_alert("不允许跨城时，选择出发地点后，清理到达地点信息");
                            lua_car.clear_use_addr_info("dddd","all");
                        end;
                    end;
                elseif companyType == "dddd" then
                    --存储到达公司名称和主键
                    useCarLocationParams.dd_company_name = companyName;
                    useCarLocationParams.dd_company_code = companyPkCorp;

                    --将地址信息存为到达地点列表
                    useCarLocationParams.dd_company_addrlist = addressList;

                    --选择到达公司后，清理已经选择的到达地点信息
                    if clearFlag == "true" then
                        lua_car.clear_use_addr_info("dddd","addr");
                    end;
                end;

                --debug_alert("选择出发公司后的地点信息\n"..foreach_arg2print(useCarLocationParams));

                --渲染选择用车地址页面
                lua_car.render_select_addr_page(companyType,addressList);
            else
                --没有查询到地址列表

                if companyType == "cfdd" then
                    --清理出发地信息和到达地信息
                    lua_car.clear_use_addr_info("cfdd","all");
                    lua_car.clear_use_addr_info("dddd","all");
                elseif companyType == "dddd" then
                    --清理到达地信息
                    lua_car.clear_use_addr_info("dddd","all");
                end;

                if companyType == "cfdd" then
                    alert(C_QryAddrByCompanyTip);
                elseif companyType == "dddd" then
                    if crossCityCtrlFlag == "00" then
                        --选择到达地点时，如果制度不允许跨城，提示信息修改
                        if cityCodes=="" or cityNames=="" then
                            alert("不允许跨城用车，出发地点为"..useCarLocationParams.cf_addr_address.."，请选择与出发地相同城市的公司");
                        else
                            --debug_alert("管控城市编码 : "..cityCodes);
                            alert("不允许跨城用车，出发地点为"..useCarLocationParams.cf_addr_address.."，管控城市为"..cityNames.."，请选择与出发地相同城市的公司");
                        end;
                    else
                        alert(C_QryAddrByCompanyTip);
                    end;
                end;
            end;
        else
            alert(res["errorMsg"]);
        end;
    end;
end;

--[[渲染选择用车地址页面]]
function lua_car.render_select_addr_page(companyType,addressList)
    --获取查询地址的公司类型
    local companyType = formatNull(companyType);

    --[[debug_alert(
        "获取查询地址的公司类型"..companyType.."\n"..
        "渲染选择"..companyType.."用车地址页面，地址共"..tostring(#addressList).."个"..
        ""
    );]]

    local htmlOption = "";
    if #addressList > 0 then
        for key,value in pairs(addressList) do
            local addrIndex = tostring(key);
            local building = vt("building",value);
            local address = vt("address",value);
            --[[debug_alert(
                "addrIndex : "..addrIndex.."\n"..
                "building : "..building.."\n"..
                "address : "..address.."\n"..
                ""
            );]]

            htmlOption = htmlOption..[[
                <div class="addr_list_option_div" border="0" onclick="lua_car.select_use_car_addr(']]..companyType..[[',']]..addrIndex..[[')">
                    <label class="addr_title_label" value="]]..building..[[" />
                    <label class="addr_detail_label" value="]]..address..[[" />
                    <line class="addr_line_css" />
                </div>
            ]];
        end;

        local addrListDivName = "";
        if companyType == "cfdd" then
            addrListDivName = "cfdd_addr_list_div";
        elseif companyType == "dddd" then
            addrListDivName = "dddd_addr_list_div";
        end;

        local htmlContent = [[
            <div class="content_div" border="0" name="]]..addrListDivName..[[">
            ]]..htmlOption..[[
            </div>
        ]];
        document:getElementsByName(addrListDivName)[1]:setInnerHTML(htmlContent);
        page_reload();
    else
        alert("当前公司暂未维护地址，请联系管理员或切换公司再试");
    end;
end;

--[[选中当前人员所在公司]]
function lua_car.select_current_company(selectType)
    --获取当前的机构信息
    local selectOrgInfo = formatNull(globalTable["selectOrgList"][1]);
    local DefalutOrgFlag = vt("unitcode",selectOrgInfo);
    local DefaultCorp = vt("pkCorp",selectOrgInfo);
    local DefaultCorpName = vt("unitname",selectOrgInfo);

    local DefaultArgListTable = {
        DefalutOrgFlag,
        DefaultCorp,
        DefaultCorpName
    };

    --[[debug_alert(
        "选中当前人员所在公司\n"..
        "selectType : "..selectType.."\n"..
        foreach_arg2print(DefaultArgListTable).."\n"..
        ""
    );]]

    local argCheckRes = lua_form.arglist_check_empty(DefaultArgListTable);
    --debug_alert(argCheckRes);
    if argCheckRes == "true" then
        local defaultSelectCompanyArg = DefalutOrgFlag..","..DefaultCorp..","..DefaultCorpName;

        local doSelectCfdd = "";
        local doSelectDddd = "";

        if selectType == "cfdd" then
            doSelectCfdd = "true";
        elseif selectType == "dddd" then
            doSelectDddd = "true";
        elseif selectType == "all" then
            doSelectCfdd = "true";
            doSelectDddd = "true";
        else

        end;

        --[[debug_alert(
            "执行选中\n"..
            "doSelectCfdd : "..doSelectCfdd.."\n"..
            "doSelectDddd : "..doSelectDddd.."\n"..
            "defaultSelectCompanyArg : "..defaultSelectCompanyArg.."\n"..
            ""
        );]]

        --选择默认公司（到达地点）
        if doSelectCfdd == "true" then
            document:getElementsByName("cfdd_company_list")[1]:setCustomPropertyByName("defaultChecked",DefaultCorp);
            lua_car.select_cfdd_company(defaultSelectCompanyArg);
        end;

        --选择默认公司（出发地点）
        if doSelectDddd == "true" then
            document:getElementsByName("dddd_company_list")[1]:setCustomPropertyByName("defaultChecked",DefaultCorp);
            lua_car.select_dddd_company(defaultSelectCompanyArg);
        end;
    end;
end;

--[[选择出发地点的公司]]
function lua_car.select_cfdd_company(params)
    lua_car.select_company(params,"cfdd");
end;

--[[选择到达地点的公司]]
function lua_car.select_dddd_company(params)
    lua_car.select_company(params,"dddd");
end;

--[[获取选中的公司信息]]
function lua_car.select_company(params,companyType)
    --地址管控规则
    local addressCtrlFlag = formatNull(globalTable["addressCtrlFlag"]);
    --公司类型
    local companyType = formatNull(companyType);

    if formatNull(params) ~= "" then
        local codeAndName = splitUtils(params,",");
        local companyInfo = "";
        local companyName = "";
        local listLen = #codeAndName;
        for i=1,listLen do
            if i ~= listLen then
                if companyInfo == "" then
                    companyInfo = codeAndName[i];
                else
                    companyInfo = companyInfo..","..codeAndName[i];
                end;
                if i == listLen - 1 then
                    chooseCompanyPkCorp = codeAndName[i];
                end;
            else
                companyName = codeAndName[i];
            end;
        end;

        --[[debug_alert(
            "获取选中的公司信息\n"..
            "params : "..params.."\n"..
            "companyType : "..companyType.."\n"..
            "companyName : "..companyName.."\n"..
            "chooseCompanyPkCorp : "..chooseCompanyPkCorp.."\n"..
            "useCarAddrFlag : "..tostring(useCarAddrFlag).."\n"..
            "useCarAddrFlag : "..addressCtrlFlag.."\n"..
            ""
        );]]

        if addressCtrlFlag == "01" then
            --限制出发地或目的地为办公地
            if useCarAddrFlag == 1 then
                changeProperty("choose_cfdd_company_label","value",companyName);
                changeProperty("choose_cfdd_addr_label","value",C_CFSelectUseCarAddrTip);
            elseif useCarAddrFlag == 2 then
                changeProperty("choose_dddd_company_label","value",companyName);
                changeProperty("choose_dddd_addr_label","value",C_DDSelectUseCarAddrTip);
            else

            end;
        elseif addressCtrlFlag == "02" then
            --均限制为办公，默认均不限制
            if companyType == "cfdd" then
                changeProperty("choose_cfdd_company_label","value",companyName);
            elseif companyType == "dddd" then
                changeProperty("choose_dddd_company_label","value",companyName);
            end;
        else
            --均不限制
            
        end;

        --通过公司查询可选地址
        local qryAddrReqParams = {
            companyType=companyType,
            companyName=companyName,
            companyPkCorp=chooseCompanyPkCorp
        };
        lua_car.qry_addr_by_company("",qryAddrReqParams);
    else
        if useCarAddrFlag == 1 then
            changeProperty("choose_cfdd_company_label","value",C_CFSelectUseCarCompanyTip);
            changeProperty("choose_cfdd_addr_label","value",C_CFSelectUseCarAddrTip);
        elseif useCarAddrFlag == 2 then
            changeProperty("choose_dddd_company_label","value",C_DDSelectUseCarCompanyTip);
            changeProperty("choose_dddd_addr_label","value",C_DDSelectUseCarAddrTip);
        else
            
        end;
    end;
end;

--[[查询公司数据并渲染公司选择界面]]
function lua_car.render_company_page()
    local CompanyListWidgetData = vt("CompanyListWidgetData",companyTable);
    if CompanyListWidgetData=="" then
        alert("查询公司失败");
    else
        title_head("选择出发地点","lua_page.div_page_ctrl()","top_cfdd_addr_div");
        title_head("选择到达地点","lua_page.div_page_ctrl()","top_dddd_addr_div");

        changeProperty("cfdd_company_list","value",CompanyListWidgetData.."&");
        changeProperty("dddd_company_list","value",CompanyListWidgetData.."&");

        page_reload();
    end;
end;

--[[通过后台h5页面选择地址]]
function lua_car.select_use_car_city_by_h5(addrType)
    --地址类型
    local addrType = formatNull(addrType);
    --回调参数
    local callBackArg = formatNull(addrType);
    --页面标题
    local pageTitle = "选择地址";
    --管控城市编码
    local ctrlCityCodes = "";
    --管控城市名称
    local ctrlCityNames = "";

    if addrType == "cfdd" then
        pageTitle = "出发地点";
        ctrlCityCodes = vt("cfddCtrlCityCodes",globalTable);
        ctrlCityNames = vt("cfddCtrlCityNames",globalTable);
    elseif addrType == "dddd" then
        pageTitle = "到达地点";
        ctrlCityCodes = vt("ddddCtrlCityCodes",globalTable);
        ctrlCityNames = vt("ddddCtrlCityNames",globalTable);
    else

    end;
    
    --初始地址
    local UseCarSelectMapUrl = vt("UseCarSelectMapUrl",globalTable);

    if UseCarSelectMapUrl ~= "" then
        --经纬度
        local longitude = vt("location_longitude",systemTable);
        local latitude = vt("location_latitude",systemTable);

        --坐标系判断
        local mapType = "";
        if platform == "iPhone OS" then
            --iPhone使用gps坐标系
            --mapType = "gps";
        elseif platform == "Android" then
            --Android使用百度坐标系
            --mapType = "baidu";
        end;

        --访问地址
        local visit_url =
            UseCarSelectMapUrl..
            "longitude="..longitude..
            "&latitude="..latitude..
            "&mapType="..mapType..
            "&ctrlCityCodes="..ctrlCityCodes..
            "&CallBackArg="..callBackArg..
            "";

        --展示用车城市选择界面
        local ReqParams = {
            H5InitStyle=useCarSelectAddrH5PageInitStyle,
            PageTitle=pageTitle,
            VisitUrl=visit_url
        };
        lua_car.show_use_car_city_by_h5("",ReqParams);
    else
        alert("获取地图异常");
    end;
end;

--[[展示用车城市选择界面]]
function lua_car.show_use_car_city_by_h5(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        --debug_alert("展示用车城市选择界面-请求"..foreach_arg2print(ReqParams));

        local ReqParams = formatNull(ReqParams);
        ReqParams["TranCode"] = "CarServiceLogRegister";
        invoke_trancode(
            "jjbx_service",
            "car_service",
            ReqParams,
            lua_car.show_use_car_city_by_h5,
            {},
            all_callback,
            {CloseLoading="false"}
        );
    else
        --debug_alert("展示用车城市选择界面-响应"..foreach_arg2print(ResParams));

        close_loading();

        local res = json2table(ResParams["responseBody"]);
        local H5InitStyle = vt("H5InitStyle",res);
        local PageTitle = vt("PageTitle",res);
        local VisitUrl = vt("VisitUrl",res);

        if H5InitStyle == "alert" then
            --debug_alert("弹出地址选择界面");

            local AlertWebviewArg = {
                title = PageTitle,
                visit_url = VisitUrl,
                listen_url = "http://app_h5_callback_url",
                listen_call = "lua_system.webview_h5_callback",
                location = "true"
            };
            lua_system.alert_webview(AlertWebviewArg);
        else
            --debug_alert("加载地址选择页面");

            globalTable["webview_url"] = VisitUrl;
            globalTable["webview_page_title"] = PageTitle;
            invoke_page("jjbx_page/xhtml/webview_page.xhtml",page_callback,{CloseLoading="false"});
        end;
    end;
end;

--[[用车-通过H5选择城市回调]]
function lua_car.use_car_selectCity(argTable)
    --经度
    local longitude = vt("longitude",argTable);
    --纬度
    local latitude = vt("latitude",argTable);
    --城市名称
    local cityName = vt("cityName",argTable);
    --城市编码（高德）
    local cityCode = vt("cityCode",argTable);
    --地址名称
    local addr = vt("addr",argTable);
    --回调参数
    local callbackArg = vt("CallBackArg",argTable);
    --地址管控规则
    local addressCtrlFlag = vt("addressCtrlFlag",globalTable);

    --空参校验
    local argListTable = {
        longitude,
        latitude,
        addr,
        cityCode
    };
    local argCheckRes = lua_form.arglist_check_empty(argListTable);

    --[[debug_alert(
        "用车-通过H5选择城市回调\n"..
        "经度 : "..longitude.."\n"..
        "纬度 : "..latitude.."\n"..
        "城市 : "..cityName.."\n"..
        "编码 : "..cityCode.."\n"..
        "地址 : "..addr.."\n"..
        "回调 : "..callbackArg.."\n"..
        "规则 : "..addressCtrlFlag.."\n"..
        ""
    );]]

    if callbackArg == "cfdd" then
        --debug_alert("更新出发地点信息");

        if argCheckRes == "true" then
            useCarLocationParams.cf_addr_longitude = longitude;
            useCarLocationParams.cf_addr_latitude = latitude;
            useCarLocationParams.cf_addr_address = addr;
            useCarLocationParams.cf_addr_cityName = cityName;
            useCarLocationParams.cf_addr_cityCode = cityCode;

            --更新出发地点文字
            if addr ~= "" then
                local e = document:getElementsByName("choose_cfdd_addr_label");
                for i=1,#e do
                    e[i]:setPropertyByName("value",addr);
                    --changeProperty("choose_cfdd_addr_label","value",addr);
                end;
            end;

            if globalTable["crossCityCtrlFlag"] == "00" then
                --debug_alert("不允许跨城时，选择出发地点后，清理到达地点信息");
                lua_car.clear_use_addr_info("dddd","all");
            end;

            --01限制出发地或目的地为办公地
            if addressCtrlFlag == "01" then
                --出发地点选择后，触发一次选择到达公司默认选择动作
                lua_car.select_current_company("dddd");
            end;
        else
            alert("出发地点信息不完整，请重新选择");
        end;
    elseif callbackArg == "dddd" then
        --debug_alert("更新到达地点信息");

        if argCheckRes == "true" then
            useCarLocationParams.dd_addr_longitude = longitude;
            useCarLocationParams.dd_addr_latitude = latitude;
            useCarLocationParams.dd_addr_address = addr;
            useCarLocationParams.dd_addr_cityName = cityName;
            useCarLocationParams.dd_addr_cityCode = cityCode;
            --更新到达地点文字
            if addr ~= "" then
                local e = document:getElementsByName("choose_dddd_addr_label");
                for i=1,#e do
                    e[i]:setPropertyByName("value",addr);
                end;
                --changeProperty("choose_dddd_addr_label","value",addr);
            end;
        else
            alert("到达地点信息不完整，请重新选择");
        end;
    else
        alert("获取地点信息异常");
    end;
end;

--[[前往用车服务h5页面]]
function lua_car.to_use_car_h5_page(useCarPageArg)
    local useCarPageArg = formatNull(useCarPageArg);

    --用车渠道 dd/cc
    local useCarChannel = vt("useCarChannel",useCarPageArg);
    --用车类型 business/personal
    local useCarType = vt("useCarType",useCarPageArg);
    --用车订单号，非详情页面传空
    local UseCarOrderId = "";
    --用车制度id
    local useCarRuleId = vt("useCarRuleId",useCarPageArg);
    --用车单据号
    local useCarBillNo = vt("useCarBillNo",useCarPageArg);
    --行程类型（公务用车） 去程0 返程1
    local useCarTripStyle = vt("useCarTripStyle",useCarPageArg);
    --乘车人手机号
    local useCarPassengerPhone = vt("useCarPassengerPhone",useCarPageArg);

    --出发地点经纬度、地点、城市编码（高德）
    local longitudeStart = vt("longitudeStart",useCarPageArg);
    local latitudeStart = vt("latitudeStart",useCarPageArg);
    local addrStart = vt("addrStart",useCarPageArg);
    local cityCodeStart = vt("cityCodeStart",useCarPageArg);
    local cityNameStart = vt("cityNameStart",useCarPageArg);
    --到达地点经纬度、地点、城市编码（高德）
    local longitudeEnd = vt("longitudeEnd",useCarPageArg);
    local latitudeEnd = vt("latitudeEnd",useCarPageArg);
    local addrEnd = vt("addrEnd",useCarPageArg);
    local cityCodeEnd = vt("cityCodeEnd",useCarPageArg);
    local cityNameEnd = vt("cityNameEnd",useCarPageArg);

    --[[debug_alert(
        "前往用车服务h5页面\n"..
        "用车渠道 : "..useCarChannel.."\n"..
        "用车类型 : "..useCarType.."\n"..
        "用车订单 : "..UseCarOrderId.."\n"..
        "申请单号 : "..useCarBillNo.."\n"..
        "用车制度 : "..useCarRuleId.."\n"..
        "行程类型 : "..useCarTripStyle.."\n"..
        "用车手机 : "..useCarPassengerPhone.."\n"..
        "\n"..
        "出发经度 : "..longitudeStart.."\n"..
        "出发纬度 : "..latitudeStart.."\n"..
        "出发地点 : "..addrStart.."\n"..
        "出发编码 : "..cityCodeStart.."\n"..
        "出发城市 : "..cityNameStart.."\n"..
        "\n"..
        "到达经度 : "..longitudeEnd.."\n"..
        "到达纬度 : "..latitudeEnd.."\n"..
        "到达地点 : "..addrEnd.."\n"..
        "到达编码 : "..cityCodeEnd.."\n"..
        "到达城市 : "..cityNameEnd.."\n"..
        ""
    );]]

    if useCarType=="" or useCarChannel=="" then
        alert("未知用车渠道");
    else
        local useCarH5Arg = {
            useCarType=useCarType,
            useCarRuleId=useCarRuleId,
            useCarBillNo=useCarBillNo,
            useCarTripStyle=useCarTripStyle,
            useCarPassengerPhone=useCarPassengerPhone,
            longitudeStart=longitudeStart,
            latitudeStart=latitudeStart,
            addrStart=addrStart,
            cityCodeStart=cityCodeStart,
            longitudeEnd=longitudeEnd,
            latitudeEnd=latitudeEnd,
            addrEnd=addrEnd,
            cityCodeEnd=cityCodeEnd
        };
        lua_car.qry_use_car_h5_link(useCarChannel,UseCarOrderId,useCarH5Arg);
    end;
end;

--[[
    查询用车h5链接
    orderChannel : 用车渠道 dd/cc
    orderId      : 用车订单号，查看订单详情时传递
    useCarH5Arg  : 用车参数包
]]
function lua_car.qry_use_car_h5_link(orderChannel,orderId,useCarH5Arg)
    local orderChannel = formatNull(orderChannel);
    local orderId = formatNull(orderId);
    --链接标识
    local linkTag = "";
    if orderId ~= "" then
        --有订单号认为是前往订单详情，并清空其他参数
        linkTag = "OrderDetail";
        useCarH5Arg = "";
    else
        linkTag = "ApplyOrder";
    end;

    local useCarType = vt("useCarType",useCarH5Arg);
    --申请单号
    local useCarBillNo = vt("useCarBillNo",useCarH5Arg);
    --制度id
    local useCarRuleId = vt("useCarRuleId",useCarH5Arg);
    --申请单信息
    local ApplyInfo = lua_car.find_apply_data(useCarBillNo);
    --行程类型，默认去程0
    local useCarTripStyle = vt("useCarTripStyle",useCarH5Arg,"0");
    --乘车人手机号
    local useCarPassengerPhone = vt("useCarPassengerPhone",useCarH5Arg);

    --出发地点经纬度、地址、城市、城市编码
    local longitudeStart = "";
    local latitudeStart = "";
    local addrStart = "";
    local cityCodeStart = "";
    local cityNameStart = "";
    --到达地点经纬度、地址、城市、城市编码
    local longitudeEnd = "";
    local latitudeEnd = "";
    local addrEnd = "";
    local cityCodeEnd = "";
    local cityNameEnd = "";

    if useCarType == "personal" then
        --debug_alert("自由用车获取用户选择的地点信息\nuseCarH5Arg\n"..foreach_arg2print(useCarH5Arg));

        longitudeStart = vt("longitudeStart",useCarH5Arg);
        latitudeStart = vt("latitudeStart",useCarH5Arg);
        addrStart = vt("addrStart",useCarH5Arg);
        cityCodeStart = vt("cityCodeStart",useCarH5Arg);
        cityNameStart = "";

        longitudeEnd = vt("longitudeEnd",useCarH5Arg);
        latitudeEnd = vt("latitudeEnd",useCarH5Arg);
        addrEnd = vt("addrEnd",useCarH5Arg);
        cityCodeEnd = vt("cityCodeEnd",useCarH5Arg);
        cityNameEnd = "";
    elseif useCarType == "business" then
        --debug_alert("公务用车从申请单信息里获取用户选择的地点信息\nApplyInfo\n"..foreach_arg2print(ApplyInfo));
        useCarTripStyle = useCarTripStyle;

        longitudeStart = vt("lngFrom",ApplyInfo);
        latitudeStart = vt("latFrom",ApplyInfo);
        addrStart = vt("addrS",ApplyInfo);
        cityCodeStart = vt("cityId",ApplyInfo);
        cityNameStart = "";

        longitudeEnd = vt("lngTo",ApplyInfo);
        latitudeEnd = vt("latTo",ApplyInfo);
        addrEnd = vt("addrE",ApplyInfo);
        cityCodeEnd = vt("toCityId",ApplyInfo);
        cityNameEnd = "";
    end;

    local reqParams = {
        useCarChannel=orderChannel,
        useCarLinkTag=linkTag,
        useCarOrderId=orderId,
        useCarBillNo=useCarBillNo,
        useCarRuleId=useCarRuleId,
        useCarTripStyle=useCarTripStyle,
        useCarPassengerPhone=useCarPassengerPhone,
        --出发地点经纬度、地址、城市编码
        longitudeStart=longitudeStart,
        latitudeStart=latitudeStart,
        addrStart=addrStart,
        cityCodeStart=cityCodeStart,
        cityNameStart=cityNameStart,
        --到达地点经纬度、地址、城市编码
        longitudeEnd=longitudeEnd,
        latitudeEnd=latitudeEnd,
        addrEnd=addrEnd,
        cityCodeEnd=cityCodeEnd,
        cityNameEnd=cityNameEnd
    };

    --[[debug_alert(
        "查询用车h5链接\n"..
        "用车渠道 : "..orderChannel.."\n"..
        "用车订单 : "..orderId.."\n"..
        "链接标识 : "..linkTag.."\n"..
        "\n"..
        "用车类型 : "..useCarType.."\n"..
        "申请单号 : "..useCarBillNo.."\n"..
        "用车制度 : "..useCarRuleId.."\n"..
        "\n"..
        "出发经度 : "..longitudeStart.."\n"..
        "出发纬度 : "..latitudeStart.."\n"..
        "出发地点 : "..addrStart.."\n"..
        "出发编码 : "..cityCodeStart.."\n"..
        "出发城市 : "..cityNameStart.."\n"..
        "\n"..
        "到达经度 : "..longitudeEnd.."\n"..
        "到达纬度 : "..latitudeEnd.."\n"..
        "到达地点 : "..addrEnd.."\n"..
        "到达编码 : "..cityCodeEnd.."\n"..
        "到达城市 : "..cityNameEnd.."\n"..
        "\n"..
        "申请信息 : \n"..foreach_arg2print(ApplyInfo).."\n"..
        "\n"..
        "请求参数 : \n"..foreach_arg2print(reqParams).."\n"..
        ""
    );]]

    --确认查验制度
    local CheckRuleTimeFlag = "";
    if linkTag=="OrderDetail" then
        --访问订单详情不查验制度
        CheckRuleTimeFlag = "false";
    else
        if useCarType=="personal" and personalCheckRuleTimeFlag=="false" then
            --自由出行配置了不查验
            CheckRuleTimeFlag = "false";
        elseif useCarType=="business" and businessCheckRuleTimeFlag=="false" then
            --公务用车配置了不查验
            CheckRuleTimeFlag = "false";
        else
            --其他情况均查验
            CheckRuleTimeFlag = "true";
        end;
    end;

    if CheckRuleTimeFlag == "true" then
        --查验用车制度时间
        globalTable["openUseCarH5LinkArg"] = reqParams;
        lua_car.check_rule_time("",useCarRuleId);
    else
        --直接访问用车链接
        lua_car.open_use_car_h5_link("",reqParams);
    end;
end;

--[[查验用车制度时间]]
function lua_car.check_rule_time(resParams,useCarRuleId)
    if formatNull(resParams) == "" then
        --debug_alert("查验用车制度时间-请求");
        invoke_trancode_donot_checkRepeat(
            "jjbx_service",
            "car_service",
            {
                TranCode="checkInstitutionTime",
                useCarRuleId=useCarRuleId
            },
            lua_car.check_rule_time,
            {},
            all_callback,
            {CloseLoading="false"}
        );
    else
        local res = json2table(resParams["responseBody"]);
        --debug_alert("查验用车制度时间-响应");

        if res["errorNo"] == "000000" then
            local sign = vt("sign",res);
            if sign == "true" then
                close_loading();

                local openUseCarH5LinkArg = formatNull(globalTable["openUseCarH5LinkArg"]);
                globalTable["openUseCarH5LinkArg"] = "";

                --制度时间查验成功，获取h5链接
                lua_car.open_use_car_h5_link("",openUseCarH5LinkArg);
            else
                alert("未到用车时间，无法用车");
            end;
        else
            local errorMsg = vt("errorMsg",res);
            alert(errorMsg);
        end;
    end;
end;

--[[查询并打开用车h5链接]]
function lua_car.open_use_car_h5_link(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        --debug_alert("查询并打开用车h5链接-请求\n"..foreach_arg2print(ReqParams));

        local ReqParams = formatNull(ReqParams);
        ReqParams["TranCode"] = "getUseCarH5Link";
        invoke_trancode_donot_checkRepeat(
            "jjbx_service",
            "car_service",
            ReqParams,
            lua_car.open_use_car_h5_link,
            {},
            all_callback,
            {CloseLoading="false"}
        );
    else
        local res = json2table(ResParams["responseBody"]);
        --debug_alert("打开用车h5链接-响应\n"..foreach_arg2print(res));

        if res["errorNo"] == "000000" then
            local useCarOrderId = vt("useCarOrderId",res);
            local useCarChannel = vt("useCarChannel",res);
            local useCarLinkTag = vt("useCarLinkTag",res);
            local useCarH5LinkUrl = vt("useCarH5LinkUrl",res);

            local useCarH5PageTitle = "打开页面";
            if useCarLinkTag == "OrderDetail" then
                useCarH5PageTitle = "订单详情";
            elseif useCarLinkTag == "ApplyOrder" then
                if useCarChannel == "dd" then
                    useCarH5PageTitle = "滴滴打车";
                elseif useCarChannel == "cc" then
                    useCarH5PageTitle = "曹操专车";
                else

                end;
            else

            end;

            --[[debug_alert(
                "打开用车h5链接\n"..
                "用车订单 : "..useCarOrderId.."\n"..
                "用车渠道 : "..useCarChannel.."\n"..
                "链接标识 : "..useCarLinkTag.."\n"..
                "页面标题 : "..useCarH5PageTitle.."\n"..
                "链接地址 : "..useCarH5LinkUrl.."\n"..
                ""
            );]]

            if useCarH5LinkUrl ~= "" then
                --涉嫌电信诈骗提示
                local UserRiskCheckMsg = vt("UserRiskCheckMsg",globalTable);
                if UserRiskCheckMsg ~= "" then
                    alert(UserRiskCheckMsg);
                else
                    if useCarH5PageInitStyle == "alert" then
                        if useCarChannel == "dd" then
                            --弹出打开h5界面
                            lua_system.alert_webview(
                                {
                                    title = useCarH5PageTitle,
                                    visit_url = useCarH5LinkUrl,
                                    listen_url = "http://app_h5_callback_url",
                                    listen_call = "lua_system.webview_h5_callback",
                                    AddUserAgent = "/CZBANK/JJBXAPP"
                                }
                            );
                        else
                            --弹出打开h5界面
                            lua_system.alert_webview(
                                {
                                    title = useCarH5PageTitle,
                                    visit_url = useCarH5LinkUrl,
                                    listen_url = "http://app_h5_callback_url",
                                    listen_call = "lua_system.webview_h5_callback",
                                    back_type = "BACK"
                                }
                            );
                        end;
                    else
                        --加载用车h5界面
                        globalTable["webview_url"] = useCarH5LinkUrl;
                        globalTable["webview_page_title"] = useCarH5PageTitle;
                        globalTable["webview_close_fun"] = "back_fun()";
                        globalTable["url_encode"] = "false";
                        invoke_page("jjbx_page/xhtml/webview_page.xhtml",page_callback,{CloseLoading="false"});
                    end;
                end;
            else
                alert("获取用车地址为空");
            end;
            close_loading();
        else
            alert(res["errorMsg"]);
        end;
    end;
end;

--[[用车宽度动态计算]]
function lua_car.rule_msg_width_adapter(Arg)
    --初始的左侧宽度
    local initLeft = vt("initLeft",Arg);
    --元素个数
    local counts = vt("counts",Arg);

    --文本1内容
    local label1Content = vt("label1Content",Arg);
    --文本1字体大小
    local label1FontSize = vt("label1FontSize",Arg,"10");
    --文本1为空是否自动隐藏
    local label1AutoHide = vt("label1AutoHide",Arg,"true");

    --文本2内容
    local label2Content = vt("label2Content",Arg);
    --文本2字体大小
    local label2FontSize = vt("label2FontSize",Arg,"10");
    --文本2为空是否自动隐藏
    local label2AutoHide = vt("label2AutoHide",Arg,"true");

    --文本3内容
    local label3Content = vt("label3Content",Arg);
    --文本3字体大小
    local label3FontSize = vt("label3FontSize",Arg,"10");
    --文本3为空是否自动隐藏
    local label3AutoHide = vt("label3AutoHide",Arg,"true");

    for i=1,counts do
        --初始left
        local initLeft = tonumber(formatNull(initLeft,"15"));
        --填充宽度
        local paddingWidth = 6;
        --间隔宽度
        local spaceWidth = 4;
        --下标
        local index = tostring(i);

        local label1Name = label1Content.."_"..index;
        local label2Name = label2Content.."_"..index;
        local label3Name = label3Content.."_"..index;

        local label1Value = getValue(label1Name,"0");
        local label1Width = formatNull(calculate_text_width(label1Value,label1FontSize),"0");
        local label1SetWidth = "";
        if label1Width ~= "0" then
            label1SetWidth = tonumber(label1Width)+paddingWidth;
        else
            if label1AutoHide == "true" then
                hide_ele(label1Name);
            end;
            label1SetWidth = 0;
        end;
        local label1Left = initLeft;

        local label2Value = getValue(label2Name,"0");
        local label2Width = formatNull(calculate_text_width(label2Value,label2FontSize),"0");
        local label2SetWidth = "";
        if label2Width ~= "0" then
            label2SetWidth = tonumber(label2Width)+paddingWidth;
        else
            if label2AutoHide == "true" then
                hide_ele(label2Name);
            end;
            label2SetWidth = 0;
        end;
        local label2Left = "";
        if label1SetWidth ~= 0 then
            label2Left = label1Left+spaceWidth+label1SetWidth;
        else
            label2Left = label1Left;
        end;

        local label3Value = getValue(label3Name,"0");
        local label3Width = formatNull(calculate_text_width(label3Value,label3FontSize),"0");
        local label3SetWidth = "";
        if label3Width ~= "0" then
            label3SetWidth = tonumber(label3Width)+paddingWidth;
        else
            if label3AutoHide == "true" then
                hide_ele(label3Name);
            end;
            label3SetWidth = 0;
        end;
        local label3Left = ""
        if label2SetWidth ~= 0 then
            label3Left = label2Left+spaceWidth+label2SetWidth;
        else
            label2Left = label2Left;
        end;

        --[[debug_alert(
            "计算宽度\n"..
            "名 : "..label1Name.."\n"..
            "值 : "..label1Value.."\n"..
            "宽 : "..label1Width.."\n"..
            "设 : "..label1SetWidth.."\n"..
            "左 : "..label1Left.."\n"..
            "\n"..
            "名 : "..label2Name.."\n"..
            "值 : "..label2Value.."\n"..
            "宽 : "..label2Width.."\n"..
            "设 : "..label2SetWidth.."\n"..
            "左 : "..label2Left.."\n"..
            "\n"..
            "名 : "..label3Name.."\n"..
            "值 : "..label3Value.."\n"..
            "宽 : "..label3Width.."\n"..
            "设 : "..label3SetWidth.."\n"..
            "左 : "..label3Left.."\n"..
            ""
        );]]

        if label1SetWidth ~= 0 then
            changeStyle(label1Name,"width",tostring(label1SetWidth));
        end;
        if label2SetWidth ~= 0 then
            changeStyle(label2Name,"width",tostring(label2SetWidth));
        end;
        if label3SetWidth ~= 0 then
            changeStyle(label3Name,"width",tostring(label3SetWidth));
        end;

        changeStyle(label1Name,"left",tostring(label1Left));
        changeStyle(label2Name,"left",tostring(label2Left));
        changeStyle(label3Name,"left",tostring(label3Left));

        page_reload();
    end;
end;

--[[用车申请提交保存表单检查]]
function lua_car.bill_form_check()
    --地址管控类型
    local addressCtrlFlag = formatNull(globalTable["addressCtrlFlag"]);
    --保存提交类型
    local submitFlag = "";
    if SCBP.submitFlag == "save" then
        submitFlag = "save";
    else
        submitFlag = "submit";
    end;

    --[[debug_alert(
        "用车申请提交保存表单检查\n"..
        "addressCtrlFlag : "..addressCtrlFlag.."\n"..
        "useCarAddrFlag : "..useCarAddrFlag.."\n"..
        "submitFlag : "..submitFlag.."\n"..
        "\n"..
        "useCarLocationParams\n"..
        foreach_arg2print(useCarLocationParams).."\n"..
        "\n"..
        "SCBP\n"..
        foreach_arg2print(SCBP).."\n"..
        ""
    );]]

    --检查用车场景
    if SCBP.tripDetail_ruleId == "" then
        alert(C_SelectUseCarRuleTip);
        return "false";
    end;

    --提交时检查
    if submitFlag == "submit" then
        --检查业务场景
        if SCBP.tripDetail_businessSceneCode == "" then
            alert("请选择业务场景");
            return "false";
        end;

        --检查用车事由
        if SCBP.reason == "" then
            --debug_alert("事由是否显示 : "..getStyle("ycsy_div","display").."，是否必输 : "..getValue("ycsy_required"));
            if getStyle("ycsy_div","display")=="block" and getValue("ycsy_required")=="*" then
                alert("请填写用车事由");
                return "false";
            end;
        end;
    end;

    --[[debug_alert(
        "检查用车方式和用车次数\n"..
        "用车方式 : "..SCBP.tripDetail_ycfs.."\n"..
        "用车次数 : "..SCBP.tripDetail_yccs.."\n"..
        "制度次数 : "..SCBP.tripDetail_carUseLimitCounts.."\n"..
        ""
    );]]

    --检查用车方式和用车次数
    if SCBP.tripDetail_ycfs == "2" then
        --用车方式为其他的时候需要校验用车次数
        if SCBP.tripDetail_yccs == "" then
            alert("请填写用车次数");
            return "false";
        else
            if SCBP.tripDetail_carUseLimitCounts == "" then
                alert(C_SelectUseCarRuleTip);
                return "false";
            elseif SCBP.tripDetail_carUseLimitCounts == "unlimited" then
                --不限制用车次数
            else
                if tonumber(SCBP.tripDetail_yccs) > tonumber(SCBP.tripDetail_carUseLimitCounts) then
                    alert("用车次数超过制度限制");
                    return "false";
                end;
            end;
        end;
    else
        --用车方式为单程或往返的时候不上送用车次数
        SCBP.tripDetail_yccs = "";
    end;

    if submitFlag == "submit" then
        --校验出发公司
        if (addressCtrlFlag=="01" and useCarAddrFlag==1) or addressCtrlFlag=="02" then
            --1、限制出发地或目的地为办公地，且用户选择出发地为办公地址
            --2、出发地和到达地均限制为办公地
            if SCBP.tripDetail_companyNameFrom=="" or SCBP.tripDetail_companyCodeFrom=="" then
                alert(C_CFSelectUseCarCompanyTip);
                return "false";
            end;
        end;

        --校验出发地址
        if SCBP.tripDetail_lngFrom=="" or SCBP.tripDetail_latFrom=="" or SCBP.tripDetail_cityId=="" then
            alert(C_CFSelectUseCarAddrTip);
            return "false";
        end;
    elseif submitFlag == "save" then
        --保存时，当出发经纬度和地址信息不为空的时候，需要校验出发公司是否上送
        if SCBP.tripDetail_lngFrom~="" and SCBP.tripDetail_latFrom~="" or SCBP.tripDetail_cityId~="" then
            if (addressCtrlFlag=="01" and useCarAddrFlag==1) or addressCtrlFlag=="02" then
                if SCBP.tripDetail_companyNameFrom=="" or SCBP.tripDetail_companyCodeFrom=="" then
                    alert(C_CFSelectUseCarCompanyTip);
                    return "false";
                end;
            end;
        end;
    end;

    --校验到达公司
    if submitFlag == "submit" then
        if (addressCtrlFlag=="01" and useCarAddrFlag==2) or addressCtrlFlag=="02" then
            --1、限制出发地或目的地为办公地，且用户选择到达地为办公地址
            --2、出发地和到达地均限制为办公地
            if SCBP.tripDetail_companyNameTo=="" or SCBP.tripDetail_companyCodeTo=="" then
                alert(C_DDSelectUseCarCompanyTip);
                return "false";
            end;
        end;

        --校验到达地址
        if SCBP.tripDetail_lngTo=="" or SCBP.tripDetail_latTo==""  or SCBP.tripDetail_toCityId=="" then
            alert(C_DDSelectUseCarAddrTip);
            return "false";
        end;
    elseif submitFlag == "save" then
        --保存时，当到达经纬度和地址信息不为空的时候，需要校验到达公司是否上送
        if SCBP.tripDetail_lngTo~="" and SCBP.tripDetail_latTo~="" and SCBP.tripDetail_toCityId~="" then
            if (addressCtrlFlag=="01" and useCarAddrFlag==2) or addressCtrlFlag=="02" then
                --1、限制出发地或目的地为办公地，且用户选择到达地为办公地址
                --2、出发地和到达地均限制为办公地
                if SCBP.tripDetail_companyNameTo=="" or SCBP.tripDetail_companyCodeTo=="" then
                    alert(C_DDSelectUseCarCompanyTip);
                    return "false";
                end;
            end;
        end;
    end;

    return "true";
end;

--[[提交用车申请单]]
function lua_car.do_submit_car_bill(params)
    if formatNull(params) == "" then
        local checkBillRes = lua_car.bill_form_check();
        if checkBillRes ~= "true" then
            return;
        end;

        --debug_alert("提交用车申请单-请求\n"..foreach_arg2print(SCBP));
        invoke_trancode(
            "jjbx_service",
            "car_service",
            SCBP,
            lua_car.do_submit_car_bill,
            {},
            all_callback,
            {CloseLoading="false"}
        );
    else
        --debug_alert("提交用车申请单-响应");
        local doSubmitCarBillRes = json2table(params["responseBody"]);
        local errorNo = vt("errorNo",doSubmitCarBillRes);
        local errorMsg = vt("errorMsg",doSubmitCarBillRes);
        --预算提示语
        local budgetPrompts = vt("budgetPrompts",doSubmitCarBillRes);
        local SubmitFlag = vt("SubmitFlag",doSubmitCarBillRes);

        if SubmitFlag == "save" then
            if errorNo == "000000" then
                alertToast("0",C_SavedMsg,"","","");
            else
                alert(errorMsg);
            end;
        else
            globalTable["CarServiceApplyResErrorNo"] = errorNo;
            globalTable["CarServiceApplyResErrorMsg"] = errorMsg;
            globalTable["CarServiceApplyResBudgetPrompts"] = budgetPrompts;
            invoke_page("jjbx_car_service/xhtml/car_service_ApplyRes.xhtml", page_callback, {CloseLoading="false"});
        end;
    end;
end;

--[[根据制度详情确定公务用车申请管控内容]]
function lua_car.set_city_ctrl(ruleInfo,type)
    globalTable["setCityCtrlType"] = type;
    --跨城用车：00-限制 01-不限制
    local crossCityCtrlFlag = vt("crossCity",ruleInfo);
    globalTable["crossCityCtrlFlag"] = crossCityCtrlFlag;
    --出发城市控制，00-控制 01-不控制
    local vehicleCityControlEnable = vt("vehicleCityControlEnable",ruleInfo);
    --出发管控城市编码（高德）
    local vehicleCityControlCode = vt("vehicleCityControlCode",ruleInfo);
    --出发管控城市名称（高德）
    local vehicleCityControlName = vt("vehicleCityControlName",ruleInfo);
    --到达城市控制，00-控制 01-不控制
    local destinationCityControlEnable = vt("destinationCityControlEnable",ruleInfo);
    --到达管控城市编码（高德）
    local destinationCityControlCode = vt("destinationCityControlCode",ruleInfo);
    --到达管控城市名称（高德）
    local destinationCityControlName = vt("destinationCityControlName",ruleInfo);

    --地址管控类型
    local addressCtrlFlag = formatNull(globalTable["addressCtrlFlag"]);

    --清空参数
    globalTable["cfddCtrlCityCodes"] = "";
    globalTable["cfddCtrlCityNames"] = "";
    globalTable["ddddCtrlCityCodes"] = "";
    globalTable["ddddCtrlCityNames"] = "";

    --不允许跨城
    if crossCityCtrlFlag == "00" then
        if addressCtrlFlag=="01" or addressCtrlFlag=="02" then
            --出发地和到达地有管控公司地址时，不取后台的编码控制，使用空参数
        else
            --出发地到达地均不管控公司地址时，判断是否管控出发城市编码（限制跨城用车时，后台只会返回出发地点的管控信息，需要APP自行应用至目的地点）
            if vehicleCityControlEnable == "00" then
                globalTable["cfddCtrlCityCodes"] = vehicleCityControlCode;
                globalTable["cfddCtrlCityNames"] = vehicleCityControlName;
                globalTable["ddddCtrlCityCodes"] = vehicleCityControlCode;
                globalTable["ddddCtrlCityNames"] = vehicleCityControlName;
            end;
        end;
    else
        --允许跨城，取设置的出发地和到达地编码控制，各自应用至出发地和到达地

        if vehicleCityControlEnable == "00" then
            --设置出发地点管控
            globalTable["cfddCtrlCityCodes"] = vehicleCityControlCode;
            globalTable["cfddCtrlCityNames"] = vehicleCityControlName;
        end;

        if destinationCityControlEnable == "00" then
            --设置到达地点管控
            globalTable["ddddCtrlCityCodes"] = destinationCityControlCode;
            globalTable["ddddCtrlCityNames"] = destinationCityControlName;
        end;
    end;

    --[[debug_alert(
        "根据制度详情确定用车申请管控内容\n"..
        "\n"..
        "地址管控类型: "..addressCtrlFlag.."\n"..
        "跨城用车管控: "..crossCityCtrlFlag.."\n"..
        "\n"..
        "出发管控参数: "..vehicleCityControlEnable.."\n"..
        "出发管控编码: "..vehicleCityControlCode.."\n"..
        "\n"..
        "到达管控参数: "..destinationCityControlEnable.."\n"..
        "到达管控编码: "..destinationCityControlCode.."\n"..
        "\n"..
        "APP应用跨城管控: "..globalTable["crossCityCtrlFlag"].."\n"..
        "APP应用出发管控: "..globalTable["cfddCtrlCityCodes"].."\n"..
        "APP应用到达管控: "..globalTable["ddddCtrlCityCodes"].."\n"..
        "\n"..
        "管控信息参数: "..foreach_arg2print(ruleInfo).."\n"..
        "调用页面: "..type..
        ""
    );]]

    --新建申请且出发到达不管控公司时，回填出发地点
    if type == "apply" then
        if addressCtrlFlag~="01" and addressCtrlFlag~="02" then
            lua_car.init_cfdd_addr();
        end;
    end;
end;

--[[渲染选择行程类型页面]]
function lua_car.render_choose_trip_style_page(Arg)
    --背景控件名称
    local pageBgName = vt("pageBgName",Arg);
    --出发地点地址
    local cfddAddr = vt("cfddAddr",Arg);
    --到达地点地址
    local ddddAddr = vt("ddddAddr",Arg);
    --隐藏参数
    local hiddenArg = vt("hiddenArg",Arg);
    --标题
    local title = vt("title",Arg);
    --按钮文字
    local btnContent = vt("btnContent",Arg);
    --按钮文字
    local btnClickFun = vt("btnClickFun",Arg);
    --是否显示切换按钮
    local showSwitch = vt("showSwitch",Arg);
    --背景点击方法
    local bgClickFun = vt("bgClickFun",Arg);
    --乘车人手机号表单
    local mobileInput = vt("mobileInput",Arg);

    local cfddDivClass = "";
    local ddddDivClass = "";
    local addrLabelClass = "";
    local addrLabelMaxLen = 0;
    --切换按钮
    local car_trip_switch_div = "";
    if showSwitch == "true" then
        cfddDivClass = "car_trip_cfdd_div";
        ddddDivClass = "car_trip_dddd_div";
        addrLabelClass = "trip_style_vlabel";
        addrLabelMaxLen = 15;
        car_trip_switch_div = [[
            <div class="car_trip_switch_div" name="car_trip_switch_div" border="]]..useCarDebugBorder..[[" onclick="lua_car.choose_trip_style('switch')">
                <img src="local:car_trip_switch.png" class="car_trip_switch_icon" onclick="lua_car.choose_trip_style('switch')"/>
            </div>
        ]];
    else
        cfddDivClass = "car_trip_cfdd_full_div";
        ddddDivClass = "car_trip_dddd_full_div";
        addrLabelClass = "trip_style_full_vlabel";
        addrLabelMaxLen = 20;
        car_trip_switch_div = "";
    end;

    local mobileInputHtml = "";
    if mobileInput == "true" then
        mobileInputHtml = [[
            <div class="car_trip_mobile_div" border="]]..useCarDebugBorder..[[">
                <label class="car_trip_mobile_lable" name="car_trip_mobile_lable">乘车人手机号</label>
                <input type="text" class="car_trip_mobile_text" value="" name="car_trip_mobile_text" style="-wap-input-format: 'N';" border="0" hold="请输入" maxleng="11" DivInputAccessoryView="YES"/>
            </div>
            <div class="space_10_div" border="0"/>
        ]];
    end;

    local page_html = [[
        <div class="full_screen_widget_bg_div" name="]]..pageBgName..[[" border="0" onclick="]]..bgClickFun..[[">
            <div class="trip_style_switch_div" name="trip_style_switch_div" border="1" onclick="">
                <label class="trip_style_hidden_label" name="useCarPageArg_hidden_label" value="" />

                <!-- 标题 -->
                <div class="trip_style_title_div" border="]]..useCarDebugBorder..[[">
                    <label class="trip_style_title_label" name="trip_style_title_label">]]..title..[[</label>
                </div>

                <!-- 切换层 -->
                <div class="car_trip_info_div" border="]]..useCarDebugBorder..[[">
                    <!-- 出发地点 -->
                    <div class="]]..cfddDivClass..[[" border="]]..useCarDebugBorder..[[">
                        <img src="local:car_cfdd_point.png" class="car_addr_point_icon"/>
                        <label class="trip_style_klabel">出发</label>
                        <label class="]]..addrLabelClass..[[" name="car_trip_cfdd_addr_label">请确认出发地点</label>
                    </div>

                    <!-- 到达地点 -->
                    <div class="]]..ddddDivClass..[[" border="]]..useCarDebugBorder..[[">
                        <img src="local:car_dddd_point.png" class="car_addr_point_icon"/>
                        <label class="trip_style_klabel">到达</label>
                        <label class="]]..addrLabelClass..[[" name="car_trip_dddd_addr_label">请确认到达地点</label>
                    </div>

                    <!-- 切换按钮 -->
                    ]]..car_trip_switch_div..[[
                </div>
                <div class="space_10_div" border="0"/>

                <!-- 乘车人手机号 -->
                ]]..mobileInputHtml..[[

                <!-- 按钮 -->
                <div class="car_trip_btn_div" border="]]..useCarDebugBorder..[[">
                    <img src="local:car_trip_btn.png" class="car_trip_btn_icon" onclick="]]..btnClickFun..[["/>
                    <label class="car_trip_btn_label" name="car_trip_btn_label" onclick="]]..btnClickFun..[[">]]..btnContent..[[</label>
                </div>

                <div class="space_10_div" border="0"/>
            </div>
        </div>
    ]];
    document:getElementsByName(pageBgName)[1]:setInnerHTML(page_html);

    --控件居中适配
    lua_page.widget_center_adapt("trip_style_switch_div","x/y");
    --公务用车往返选择
    lua_page.div_page_ctrl(pageBgName,"false","false");

    --更新隐藏域参数
    changeProperty("useCarPageArg_hidden_label","value",hiddenArg);
    --更新出发地点
    changeProperty("car_trip_cfdd_addr_label","value",cutStr(cfddAddr,addrLabelMaxLen));
    --更新到达地点
    changeProperty("car_trip_dddd_addr_label","value",cutStr(ddddAddr,addrLabelMaxLen));
end;

--[[选择行程类型]]
function lua_car.choose_trip_style(type)
    local type = formatNull(type);
    --debug_alert("选择行程类型 : "..type);

    if type == "switch" then
        --切换

        --当前的出发地点
        local cfddNowValue = getValue("car_trip_cfdd_addr_label");
        --当前的到达地点
        local ddddNowValue = getValue("car_trip_dddd_addr_label");
        --切换
        changeProperty("car_trip_cfdd_addr_label","value",cutStr(ddddNowValue,15));
        changeProperty("car_trip_dddd_addr_label","value",cutStr(cfddNowValue,15));

        if globalTable["useCarTripStyle"] == "0" then
            globalTable["useCarTripStyle"] = "1";
        else
            globalTable["useCarTripStyle"] = "0";
        end;
    elseif type == "submit" then
        --提交

        local useCarPageJsonArg = getValue("useCarPageArg_hidden_label");
        local useCarPageTableArg = json2table(useCarPageJsonArg);
        --取值并初始化参数
        local useCarTripStyle = globalTable["useCarTripStyle"];
        globalTable["useCarTripStyle"] = "0";

        --[[debug_alert(
            "行程类型 : "..globalTable["useCarTripStyle"].."\n"..
            "useCarPageJsonArg : "..useCarPageJsonArg.."\n"..
            foreach_arg2print(useCarPageTableArg).."\n"..
            ""
        );]]

        --用车渠道
        local useCarChannel = vt("useCarChannel",useCarPageTableArg);
        --是否允许代叫车
        local taxiAgentControl = vt("taxiAgentControl",useCarPageTableArg);

        --允许代叫车，且渠道为滴滴时，添加乘车人手机号上送
        if taxiAgentControl=="00" and useCarChannel=="dd" then
            local useCarPassengerPhone = getValue("car_trip_mobile_text");
            --乘车人手机号
            if useCarPassengerPhone == "" then
                alert("请输入乘车人手机号");
                return;
            else
                useCarPageTableArg["useCarPassengerPhone"] = useCarPassengerPhone;
            end;
        end;

        --更新行程类型参数
        useCarPageTableArg["useCarTripStyle"] = useCarTripStyle;

        --界面关闭
        lua_page.div_page_ctrl();

        --前往用车服务h5页面
        lua_car.to_use_car_h5_page(useCarPageTableArg);
    else
        --默认关闭并初始化参数
        globalTable["useCarTripStyle"] = "0";
        lua_page.div_page_ctrl();
    end;
end;

--[[选择业务场景]]
function lua_car.select_business_scene(ywcjInfo)
    --关闭业务场景选择
    lua_page.div_page_ctrl();

    --debug_alert(ywcjInfo);
    --业务场景编码
    local ywcjbm = "";
    --业务场景名称
    local ywcjname = "";
    if formatNull(ywcjInfo) ~= "" then
        ywcjbm = splitUtils(ywcjInfo,"_")[1];
        ywcjname = splitUtils(ywcjInfo,"_")[2];

        --[[debug_alert(
            "选择业务场景\n"..
            "名称 : "..ywcjname.."\n"..
            "编码 : "..ywcjbm.."\n"..
            ""
        );]]

        --通过业务场景编码去匹配下标
        local matchYWCJIndex = "";
        local useCarYWCJData = formatNull(companyTable["useCarYWCJData"]);
        if useCarYWCJData ~= "" then
            local useCarYWCJDataLen = #useCarYWCJData;
            for i=1,useCarYWCJDataLen do
                local useCarYWCJData = formatNull(useCarYWCJData[i]);
                --debug_alert(foreach_arg2print(useCarYWCJData));
                --业务场景编码
                local ywcjContentcode = vt("businessCode",useCarYWCJData);
                if ywcjContentcode == ywcjbm then
                    matchYWCJIndex = tostring(i);
                    break
                end;
            end;

            if matchYWCJIndex ~= "" then
                --存参（业务场景名称）
                SCBP.tripDetail_businessScene = ywcjname;
                --存参（业务场景编码）
                SCBP.tripDetail_businessSceneCode = ywcjbm;

                --回显业务场景名称
                changeProperty("ywcj","value",ywcjname);

                --更新业务场景选中效果
                local setYWCJSelectArg = {
                    showIndex=matchYWCJIndex
                };
                lua_page.set_item_selected(setYWCJSelectArg);
            else
                alert(C_NoneUseCarYWCJTip);
            end;
        else
            alert(C_NoneUseCarYWCJTip);
        end;
    else
        alert(C_NoneUseCarYWCJTip);
    end;
end;

--[[选择用车场景]]
function lua_car.choose_business_car_rule(ruleId)
    local ruleId = formatNull(ruleId);

    --关闭用车场景选择界面
    lua_page.div_page_ctrl();

    --[[debug_alert(
        "选择用车场景\n"..
        "制度ID\n"..
        "前次 : "..selectUseCarRuleId.."\n"..
        "本次 : "..ruleId.."\n"..
        ""
    );]]

    --制度id不为空且进行过切换
    if ruleId ~= "" then
        if ruleId ~= selectUseCarRuleId then
            --存在切换的情况下，通过制度id去匹配下标

            --匹配到的制度下标
            local matchRuleIndex = "";
            --匹配到的制度ID
            local matchRuleId = "";
            --匹配到的制度名称
            local matchRuleName = "";
            --匹配到的制度编码
            local matchRuleCode = "";
            --匹配到的制度使用次数
            local numberVehiclesUsed = "";

            local business_use_car_rule = formatNull(companyTable["useCarYCCJData"]);
            if business_use_car_rule ~= "" then
                local business_rule_len = #business_use_car_rule;
                for i=1,business_rule_len do
                    local BusinessUseCarRule = formatNull(business_use_car_rule[i]);
                    --debug_alert("匹配到的制度信息"..foreach_arg2print(BusinessUseCarRule));

                    --制度主键
                    local idusecarInstitution = vt("idusecarInstitution",BusinessUseCarRule);
                    if idusecarInstitution == ruleId then
                        --制度下标
                        matchRuleIndex = tostring(i);
                        --制度ID
                        matchRuleId = idusecarInstitution;
                        --制度名称
                        matchRuleName = vt("institutionName",BusinessUseCarRule);
                        --制度编码
                        matchRuleCode = vt("institutionCode",BusinessUseCarRule);
                        --使用次数
                        numberVehiclesUsed = vt("numberVehiclesUsed",BusinessUseCarRule);

                        break
                    end;
                end;
            end;

            --[[debug_alert(
                "通过选择的制度ID在可选制度中匹配的信息\n"..
                "制度下标 : "..matchRuleIndex.."\n"..
                "制度ID : "..matchRuleId.."\n"..
                "制度名称 : "..matchRuleName.."\n"..
                "制度编码 : "..matchRuleCode.."\n"..
                "使用次数 : "..numberVehiclesUsed.."\n"..
                ""
            );]]

            --存参（制度id）
            SCBP.tripDetail_ruleId = matchRuleId;
            --存参（制度名称）
            SCBP.tripDetail_carScene = matchRuleName;
            --存参（制度编码）
            SCBP.tripDetail_carSceneCode = matchRuleCode;
            --存参（制度用车次数，不限制给0）
            SCBP.tripDetail_carUseLimitCounts = formatNull(numberVehiclesUsed,"unlimited");

            --保存最新选择的制度ID
            selectUseCarRuleId = matchRuleId;

            --回显制度名称
            if matchRuleName ~= "" then
                changeProperty("yccj","value",matchRuleName);
            end;

            --更新制度选中效果
            local setRuleSelectArg = {
                showIndex=matchRuleIndex,
                eleName="car_apply_cs_select_div"
            };
            lua_page.set_item_selected(setRuleSelectArg);

            --根据制度id查询制度详情并设置申请单
            invoke_trancode_donot_checkRepeat(
                "jjbx_service",
                "car_service",
                {
                    TranCode="queryCarUseInstitution",
                    useCarRuleId=ruleId
                },
                set_business_apply_by_rule,
                {},
                all_callback,
                {CloseLoading="false"}
            );
        else
            --debug_alert("没有切换用车场景");
            close_loading();
        end;
    else
        --制度信息不完整时，加载默认地址
        lua_car.render_addr_default_page();
        alert("制度信息异常");
    end;
end;

--[[调用客户端控件选择日期]]
function lua_car.select_use_car_time()
    --[[debug_alert(
        "调用客户端控件选择日期\n"..
        "默认开始 : "..defaultDateStart.."\n"..
        "默认结束 : "..defaultDateEnd.."\n"..
        ""
    );]]

    --调用客户端控件选择日期区间
    lua_system.select_interval_date(
        {
            startDate=defaultDateStart,
            endDate=defaultDateEnd,
            callbackFunc="lua_car.set_use_car_time",
            title="请选择用车日期"
        }
    );
end;

--[[客户端控件返回选择的日期]]
function lua_car.set_use_car_time(startTime,endTime)
    local startTime = formatNull(startTime);
    local endTime = formatNull(endTime);
    local startDate = ryt:getSubstringValue(startTime,0,4).."-"..ryt:getSubstringValue(startTime,5,7).."-"..ryt:getSubstringValue(startTime,8,10);
    local endDate = ryt:getSubstringValue(endTime,0,4).."-"..ryt:getSubstringValue(endTime,5,7).."-"..ryt:getSubstringValue(endTime,8,10);

    --[[debug_alert(
        "客户端控件返回选择的日期\n"..
        "原值\n"..
        "startTime : "..startTime.."\n"..
        "endTime : "..endTime.."\n"..
        "处理过的值\n"..
        "startDate : "..startDate.."\n"..
        "endDate : "..endDate.."\n"..
        ""
    );]]

    changeProperty("use_car_start_time_label","value",startDate);
    changeProperty("use_car_end_time_label","value",endDate);
end;

--[[显示业务场景选择界面]]
function lua_car.show_ywcj_select_page()
    local useCarYWCJData = formatNull(companyTable["useCarYWCJData"]);
    if useCarYWCJData == "" then
        alert(C_NoneUseCarYWCJTip);
    else
        lua_page.div_page_ctrl('ywcj_page_div','false','false');
    end;
end;

--[[显示用车场景选择界面]]
function lua_car.show_yccj_select_page()
    local useCarYCCJData = formatNull(companyTable["useCarYCCJData"]);
    if useCarYCCJData == "" then
        alert(C_NoneUseCarRuleTip);
    else
        lua_page.div_page_ctrl('yccj_page_div','false','false');
    end;
end;

--[[根据首页查询的缓存渲染用车场景（制度）]]
function lua_car.render_business_car_rule_by_cache(type)
    local business_use_car_rule = formatNull(companyTable["useCarYCCJData"]);
    if business_use_car_rule ~= "" then
        --debug_alert("查询用车场景（制度）\n"..foreach_arg2print(business_use_car_rule));

        --div边框调试
        local divBorder = "0";

        local yccj_list_div_item_html = "";
        local business_rule_len = #business_use_car_rule;
        for i=1,business_rule_len do
            local BusinessUseCarRule = formatNull(business_use_car_rule[i]);
            --debug_alert(foreach_arg2print(BusinessUseCarRule));
            --制度下标
            local ruleIndex = tostring(i);
            --业务场景名称
            local businessScenariosName = vt("businessScenariosName",BusinessUseCarRule);
            --制度名称
            local institutionName = vt("institutionName",BusinessUseCarRule);
            --制度编码
            local institutionCode = vt("institutionCode",BusinessUseCarRule);
            --制度主键
            local idusecarInstitution = vt("idusecarInstitution",BusinessUseCarRule);
            --用车次数限制状态 00限制 01不限制
            local numberVehiclesUsedControl = vt("numberVehiclesUsedControl",BusinessUseCarRule);
            --用车次数
            local numberVehiclesUsed = vt("numberVehiclesUsed",BusinessUseCarRule);
            --显示剩余用车次数
            local showUseCounts = lua_car.remainTimesMsg(numberVehiclesUsed);
            --用车日期限制状态 00限制 01不限制
            local vehicleDateControl = vt("vehicleDateControl",BusinessUseCarRule);
            --用车日期起始时间
            local vehicleDateBegin = vt("vehicleDateBegin",BusinessUseCarRule);
            --用车日期终止时间
            local vehicleDateEnd = vt("vehicleDateEnd",BusinessUseCarRule);
            --显示用车日期区间
            local showUseDateInterval = "";
            if vehicleDateControl == "00" then
                --获取区间限制信息
                showUseDateInterval = lua_car.useDateIntervalMsg(vehicleDateBegin,vehicleDateEnd,"timestamp");
            else
                --获取缺省区间限制信息
                showUseDateInterval = lua_car.useDateIntervalMsg();
            end;

            --每单限额限制状态 00限制 01不限制
            local limitPerOrderControl = vt("limitPerOrderControl",BusinessUseCarRule);
            --每单限额
            local limitPerOrderMoney = vt("limitPerOrderMoney",BusinessUseCarRule);
            --显示单笔限额信息
            local showLimitPerOrderMoney = "";
            if limitPerOrderControl == "00" then
                --获取实际限额显示信息
                showLimitPerOrderMoney = lua_car.perLimitMsg(limitPerOrderMoney);
            else
                --获取缺省限额显示信息
                showLimitPerOrderMoney = lua_car.perLimitMsg("");
            end;

            --时间信息
            local timeInfo = vt("timeInfo",BusinessUseCarRule);
            local timeInfoCounts = #timeInfo;
            --debug_alert(foreach_arg2print(timeInfo));
            --弹出显示的使用信息
            local alertShowUseInfo = "";
            if timeInfoCounts > 0 then
                for i=1,timeInfoCounts do
                    local timeInfoValue = formatNull(timeInfo[i]);
                    if timeInfoCounts == 1 then
                        alertShowUseInfo = timeInfoValue;
                    else
                        alertShowUseInfo = timeInfoValue.."\n"..alertShowUseInfo;
                    end;
                end;
            else
                alertShowUseInfo = showDefaultUseExplain;
            end;
            globalTable["alertShowBusinessUseInfo"][i] = alertShowUseInfo;

            --是否允许代叫车
            local taxiAgentControlMsg = lua_car.taxiAgentControlMsg(vt("taxiAgentControl",BusinessUseCarRule));

            --允许代叫车div
            local taxi_agent_ctrl_html = "";
            if taxiAgentControlMsg ~= "" then
                taxi_agent_ctrl_html = [[
                    <input type="button" name="taxi_agent_btn_]]..ruleIndex..[[" class="car_apply_cs_b_taxiagent_btn" border="1" value="]]..taxiAgentControlMsg..[[" />
                ]];
            end;

            --使用说明div
            local show_use_explain_div_html = "";

            --使用说明长度
            local alertShowUseInfoLen = ryt:getLengthByStr(alertShowUseInfo);
            --[[debug_alert(
                "说明字数 : "..alertShowUseInfoLen.."\n"..
                "说明行数 : "..tostring(timeInfoCounts).."\n"..
                "\n"..
                "使用说明 : "..alertShowUseInfo.."\n"..
                ""
            );]]

            local show_use_explain_onClick = "";
            if alertShowUseInfo == showDefaultUseExplain then
                --说明为空（缺省信息）
            else
                if timeInfoCounts==1 and alertShowUseInfoLen<=showUseExplainLength then
                    --只有一条时间规则，且长度在限制区间内
                    if string.find(alertShowUseInfo,defaultUseExplainPC) then
                        alertShowUseInfo = defaultUseExplainAPP;
                    end;
                else
                    show_use_explain_onClick = "show_use_explain('business','"..ruleIndex.."')";
                end;
            end;

            if show_use_explain_onClick == "" then
                show_use_explain_div_html = [[
                    <div class="car_apply_cs_b_useex_div" border="]]..divBorder..[[">
                        ]]..taxi_agent_ctrl_html..[[
                        <label class="car_apply_cs_b_useex_full_label" name="car_apply_cs_b_useex_label_]]..ruleIndex..[[">]]..alertShowUseInfo..[[</label>
                    </div>
                ]];
            else
                show_use_explain_div_html = [[
                    <div class="car_apply_cs_b_useex_div" border="]]..divBorder..[[" onclick="]]..show_use_explain_onClick..[[">
                        ]]..taxi_agent_ctrl_html..[[
                        <label class="car_apply_cs_b_useex_label" name="car_apply_cs_b_useex_label_]]..ruleIndex..[[">]]..defaultUseExplainTip..[[</label>
                        <img src="local:arrow_mine.png" class="car_apply_cs_b_useexarw_icon" name="car_apply_cs_b_useexarw_icon_]]..ruleIndex..[[" onclick="]]..show_use_explain_onClick..[[')"/>
                    </div>
                ]];
            end;

            --选择用车制度
            local onclick_html = "onclick=\"lua_car.choose_business_car_rule('"..idusecarInstitution.."')\"";

            --备注信息
            local remarks = vt("remarks",BusinessUseCarRule);
            --备注信息
            local remark_html = "";
            if remarks ~= "" then
                remark_html = [[
                    <div class="space_02_div" border="]]..divBorder..[[" />
                    <div class="car_apply_cs_b_sy_div" border="]]..divBorder..[[" ]]..onclick_html..[[>>
                        <label class="car_apply_cs_b_sy_label">]]..remarks..[[</label>
                    </div>
                    <div class="space_08_div" border="]]..divBorder..[[" />
                ]];
            else
                remark_html = [[<div class="space_10_div" border="]]..divBorder..[[" />]];
            end;

            yccj_list_div_item_html = yccj_list_div_item_html..[[
                <div class="car_apply_cs_business_div" border="1" ]]..onclick_html..[[>
                    <div class="car_apply_cs_select_div" name="car_apply_cs_select_div" border="]]..divBorder..[[">
                        <img src="local:selected_round.png" class="car_apply_cs_select_icon" />
                    </div>

                    <div class="car_apply_cs_business_content_div" border="]]..divBorder..[[" ]]..onclick_html..[[>
                        <div class="car_apply_cs_b_title_div" border="]]..divBorder..[[" ]]..onclick_html..[[>
                            <label class="car_apply_cs_b_title_label">]]..institutionName..[[</label>
                        </div>
                        ]]..remark_html..[[
                        <div class="car_apply_cs_b_ruleinfo_div" border="]]..divBorder..[[" ]]..onclick_html..[[>
                            <input type="button" class="car_apply_cs_b_counts_label" border="1" name="b_counts_label_]]..ruleIndex..[[" value="]]..showUseCounts..[[" />
                            <input type="button" class="car_apply_cs_b_limit_label"  border="1" name="b_limit_label_]]..ruleIndex..[["  value="]]..showLimitPerOrderMoney..[[" />
                            <input type="button" class="car_apply_cs_b_time_label"   border="1" name="b_time_label_]]..ruleIndex..[["   value="]]..showUseDateInterval..[[" />
                        </div>
                        <div class="space_10_div" border="]]..divBorder..[[" />
                        ]]..show_use_explain_div_html..[[
                    </div>
                </div>
                <div class="space_10_div" border="]]..divBorder..[[" />
            ]];
        end;

        local yccj_list_div_html = [[
            <div class="car_apply_cs_yccj_list_div" border="]]..divBorder..[[" name="yccj_list_div">
                <div class="car_apply_cs_yccj_list_item_div" border="]]..divBorder..[[" name="yccj_list_item_div">
                    <div class="space_10_div" border="]]..divBorder..[[" />
                    ]]..yccj_list_div_item_html..[[
                </div>
            </div>
        ]];
        document:getElementsByName("yccj_list_div")[1]:setInnerHTML(yccj_list_div_html);

        --用车宽度动态计算
        local Line1AdapterArg = {
            initLeft="10",
            counts=business_rule_len,
            label1Content="b_counts_label",
            label1FontSize="10",
            label2Content="b_limit_label",
            label2FontSize="10",
            label3Content="b_time_label",
            label3FontSize="10"
        };
        lua_car.rule_msg_width_adapter(Line1AdapterArg);
        local Line2AdapterArg = {
            initLeft="10",
            counts=business_rule_len,
            label1Content="taxi_agent_btn",
            label1FontSize="10",
            label2Content="car_apply_cs_b_useex_label",
            label2FontSize="12",
            label3Content="car_apply_cs_b_useexarw_icon",
            label3FontSize="10",
            label3AutoHide="false"
        };
        lua_car.rule_msg_width_adapter(Line2AdapterArg);

        --debug_alert("公务用车制度数 : "..tostring(business_rule_len));

        if type == "apply" then
            --只有一个制度时默认选中（新建逻辑）
            if business_rule_len==1 or selectFirstOption=="true" then
                --制度主键
                local idusecarInstitutionFirst = formatNull(business_use_car_rule[1]["idusecarInstitution"]);
                --[[debug_alert(
                    "只有一个制度时默认选中\n"..
                    "制度主键 : "..idusecarInstitutionFirst.."\n"..
                    ""
                );]]
                lua_car.choose_business_car_rule(idusecarInstitutionFirst);
            else
                --不默认选中制度时，加载默认地址
                lua_car.render_addr_default_page()
                close_loading();
            end;
        end;
    end;
end;

--[[加载默认地址界面]]
function lua_car.render_addr_default_page()
    local select_addr_default_div_html = [[
        <div class="choose_location_div" name="choose_location_div" border="1">
            <div class="choose_location_item_div" name="choose_cfdd_div" onclick="lua_car.choose_cfdd_addr()">
                <label class="ifRequired_css" name="cfdd_required">*</label>
                <label class="cfdd_choose_label" value="]]..C_CFSelectUseCarAddrTip..[[" name="choose_cfdd_addr_label" onclick="lua_car.choose_cfdd_addr()" />
                <img src="local:arrow_common.png" class='arrow_icon'/>
            </div>
            <line class="line_css" />

            <div class="choose_location_item_div" name="choose_dddd_div" onclick="lua_car.choose_dddd_addr()">
                <label class="ifRequired_css" name="dddd_required">*</label>
                <label class="dddd_choose_label" value="]]..C_DDSelectUseCarAddrTip..[[" name="choose_dddd_addr_label" onclick="lua_car.choose_dddd_addr()" />
                <img src="local:arrow_common.png" class='arrow_icon'/>
            </div>
        </div>
    ]];
    changeStyle("addr_select_div1","display","none");
    changeStyle("addr_select_div2","display","block");
    --document:getElementsByName("choose_location_div")[1]:setInnerHTML(select_addr_default_div_html);
    --page_reload();
end;

--[[用车申请单据检查提交]]
function lua_car.car_bill_check(submitFlag,type)
    --debug_alert("用车申请单据表单检查 submitFlag : "..submitFlag.." type : "..type);
    if type == "apply" then
        --存参（新建逻辑）
        SCBP.didibillno=vt("applicationNo",addUseCarBillRes);
        SCBP.createuser=vt("createUser",addUseCarBillRes);
        SCBP.createdate=vt("createDate",addUseCarBillRes);
        SCBP.pkcorp=vt("pkcorp",addUseCarBillRes);
        SCBP.pkdept=vt("deptcode",addUseCarBillRes);
        SCBP.dept=vt("pkdept",addUseCarBillRes);
        SCBP.deptname=vt("deptName",addUseCarBillRes);
        SCBP.corpname=vt("corpName",addUseCarBillRes);
        SCBP.pkuser=vt("pkuser",addUseCarBillRes);
        SCBP.corpcode=vt("corpcode",addUseCarBillRes);
        SCBP.createusercode=vt("usercode",addUseCarBillRes);
        SCBP.pkpsndoc=vt("pkpsndoc",addUseCarBillRes);
    end;

    --定位信息存储（出发信息）
    SCBP.tripDetail_lngFrom=useCarLocationParams.cf_addr_longitude;
    SCBP.tripDetail_latFrom=useCarLocationParams.cf_addr_latitude;
    SCBP.tripDetail_companyNameFrom=useCarLocationParams.cf_company_name;
    SCBP.tripDetail_companyCodeFrom=useCarLocationParams.cf_company_code;
    SCBP.tripDetail_cityId=useCarLocationParams.cf_addr_cityCode;
    SCBP.locationstart=useCarLocationParams.cf_addr_address;

    --定位信息存储（到达信息）
    SCBP.tripDetail_lngTo=useCarLocationParams.dd_addr_longitude;
    SCBP.tripDetail_latTo=useCarLocationParams.dd_addr_latitude;
    SCBP.tripDetail_companyNameTo=useCarLocationParams.dd_company_name;
    SCBP.tripDetail_companyCodeTo=useCarLocationParams.dd_company_code;
    SCBP.tripDetail_toCityId=useCarLocationParams.dd_addr_cityCode;
    SCBP.locationend=useCarLocationParams.dd_addr_address;

    --用车事由
    SCBP.reason = getValue("use_car_reason");

    --用车次数
    SCBP.tripDetail_yccs = getValue("yccs_text");

    --用车开始时间
    local useCarStartDate = getValue("use_car_start_time_label");
    SCBP.dateStart = useCarStartDate;
    --用车结束时间
    local useCarEndDate = getValue("use_car_end_time_label");
    SCBP.dateEnd = useCarEndDate;

    --打印请求参数
    --debug_alert("用车申请单据检查提交，表单内容"..foreach_arg2print(SCBP));

    --提交用车申请单
    SCBP.billType = billTypeList_utils.ycsq;
    SCBP.submitFlag = submitFlag;
    lua_car.do_submit_car_bill();
end;

--[[渲染用车业务场景]]
function lua_car.render_business_car_scene()
    --业务场景数据
    local useCarYWCJData = formatNull(companyTable["useCarYWCJData"]);
    --业务场景条目数
    local useCarYWCJDataCounts = #useCarYWCJData;
    --debug_alert(useCarYWCJDataCounts);

    --业务场景存在时创建
    if useCarYWCJDataCounts > 0 then
        local selectEleArg = {};
        for key,value in pairs(useCarYWCJData) do
            local ywcjContentcode = formatNull(value["businessCode"]);
            local ywcjContentname = formatNull(value["businessName"]);
            local ywcjInfo = ywcjContentcode.."_"..ywcjContentname;
            local onclickFun = "lua_car.select_business_scene('"..ywcjInfo.."')";

            local selectEleArgItem = {
                --显示文字
                labelName=ywcjContentname,
                --点击函数
                clickFunc="lua_car.select_business_scene",
                --点击函数入参
                clickFuncArg=ywcjInfo
            };
            table.insert(selectEleArg,selectEleArgItem);
        end;

        --渲染select页面
        local renderSelectArg = {
            bgName="ywcj_page_div",
            topEleName="top_ywcj_div",
            topTitleName="选择业务场景",
            selectEleName="ywcj_list_div",
            selectEleArg=selectEleArg,
            renderCallBackFun="render_select_ywcj_page_call"
        };
        lua_page.render_select_page(renderSelectArg);
    end;
    close_loading();
end;

--[[初始化用车使用说明缓存]]
function lua_car.init_use_explain_cache()
    --自由用车使用说明
    globalTable["alertShowPersonalUseInfo"] = nil;
    globalTable["alertShowPersonalUseInfo"] = {};
    --公务用车使用说明
    globalTable["alertShowBusinessUseInfo"] = nil;
    globalTable["alertShowBusinessUseInfo"] = {};
end;

--[[
    清理用车地点信息
    addrType  : 地址类型 cfdd出发地点 dddd到达地点
    clearType : 清理类型 all全部 公司company 地点addr
]]
function lua_car.clear_use_addr_info(addrType,clearType)
    local addrType = formatNull(addrType);
    local clearType = formatNull(clearType,"all");

    --地点文字控件名
    local addrLabelName = "";
    --地点文字控件值
    local addrLabelDefaultValue = "";
    --地点参数关键字
    local addrArgKeyWords = "";
    --公司文字控件名
    local companyLabelName = "";
    --公司文字控件值
    local companyLabelDefaultValue = "";
    --公司列表控件
    local companyListName = "";
    --公司参数关键字
    local companyArgKeyWords = "";

    --地址管控类型
    local addressCtrlFlag = formatNull(globalTable["addressCtrlFlag"]);

    if addrType == "cfdd" then
        addrLabelName = "choose_cfdd_addr_label";
        addrLabelDefaultValue = C_CFSelectUseCarAddrTip;
        addrArgKeyWords = "cf_addr_";

        companyLabelName = "choose_cfdd_company_label";
        companyLabelDefaultValue = C_CFSelectUseCarCompanyTip;
        companyListName = "cfdd_company_list";
        companyArgKeyWords = "cf_company_";
    elseif addrType == "dddd" then
        addrLabelName = "choose_dddd_addr_label";
        addrLabelDefaultValue = C_DDSelectUseCarAddrTip;
        addrArgKeyWords = "dd_addr_";

        companyLabelName = "choose_dddd_company_label";
        companyLabelDefaultValue = C_DDSelectUseCarCompanyTip;
        companyListName = "dddd_company_list";
        companyArgKeyWords = "dd_company_";
    else
        debug_alert("清理类型未定义");
        return;
    end;

    local useClear = "";
    if clearType == "all" then
        --清理全部（已选择的公司、已选择的地点、已经查询到的地址列表）
        useClear = "company,addr";
    elseif clearType == "company" then
        --清理公司
        useClear = "company";
    elseif clearType == "addr" then
        --清理地点
        useClear = "addr";
    end;

    if string.find(useClear,"company") then
        --管控为公司的情况下才清理公司相关信息
        if addressCtrlFlag=="01" or addressCtrlFlag=="02" then
            --清理公司相关信息
            for key,value in pairs(useCarLocationParams) do
                if string.find(key,companyArgKeyWords) then
                    useCarLocationParams[key] = "";
                end;
            end;

            --还原公司显示文字和默认选择
            document:getElementsByName(companyListName)[1]:setCustomPropertyByName("defaultChecked","");
            changeProperty(companyLabelName,"value",companyLabelDefaultValue);
        end;
    end;

    if string.find(useClear,"addr") then
        --清理地点相关信息
        for key,value in pairs(useCarLocationParams) do
            if string.find(key,addrArgKeyWords) then
                useCarLocationParams[key] = "";
            end;
        end;

        --还原地点显示文字
        changeProperty(addrLabelName,"value",addrLabelDefaultValue);
    end;
end;

--[[选择用车方式]]
function lua_car.select_ycfs(selectkey)
    local selectkey = formatNull(selectkey,"1");
    local divElements = document:getElementsByName("ycfs_div");
    local labelElements = document:getElementsByName("ycfs_label");

    for i=1,#divElements do
        if i == tonumber(selectkey) then
            divElements[i]:setStyleByName("background-image","car_checked.png");
            labelElements[i]:setStyleByName("color","#FF4F00");
        else
            divElements[i]:setStyleByName("background-image","car_checkBg.png");
            labelElements[i]:setStyleByName("color","#323233");
        end;
    end;

    if selectkey == "1" then
        --单程
        SCBP.tripDetail_ycfs = "0";
        hide_ele("yccs_div");
    elseif selectkey == "2" then
        --往返
        SCBP.tripDetail_ycfs = "1";
        hide_ele("yccs_div");
    elseif selectkey == "3" then
        --其他
        SCBP.tripDetail_ycfs = "2";
        show_ele("yccs_div");
    end;

    page_reload();
end;

--[[加载用车申请单页面元素]]
function lua_car.load_apply_page_element(pageConfig)
    for i=1,#pageConfig do
        local Item = formatNull(pageConfig[i]);
        local fieldAppName = vt("fieldName",Item);
        local modelType = vt("modelType",Item);

        if modelType=="1" and fieldAppName=="ycsy" then
            local fieldAppDIV = fieldAppName.."_div";
            local fieldAppSpaceDIV = fieldAppName.."_space_div";
            local fieldDispName = Item["fieldDispName"];
            local labelEleName = fieldAppName.."_title";
            local requiredLabelName = fieldAppName.."_required";

            --是否显示
            local displayFlag = vt("fieldVisible",Item,"1");
            --是否必输
            local requiredStatus = vt("fieldRequired",Item,"1");

            if displayFlag == "1" then
                changeStyle(fieldAppDIV,"display","block");
                changeStyle(fieldAppSpaceDIV,"display","block");
                changeProperty(labelEleName,"value",fieldDispName);
                if requiredStatus == "1" then
                    changeProperty(requiredLabelName,"value","*");
                else
                    changeProperty(requiredLabelName,"value","");
                end;
            else
                changeStyle(fieldAppDIV,"display","none");
                changeStyle(fieldAppSpaceDIV,"display","none");
            end;
        end;
    end;

    page_reload();
end;

--[[代叫车展示信息]]
function lua_car.taxiAgentControlMsg(taxiAgentControlFlag)
    local taxiAgentMsg = "";

    if taxiAgentControlFlag == "00" then
        taxiAgentMsg = "可代叫";
    end;

    --调试代叫车信息显示
    if useCarCardMsgDebug == "true" then
        taxiAgentMsg = "可代叫";
    end;

    --[[debug_alert(
        "代叫车展示信息\n"..
        "taxiAgentControlFlag : "..taxiAgentControlFlag.."\n"..
        "taxiAgentMsg : "..taxiAgentMsg.."\n"..
        ""
    );]]

    return taxiAgentMsg;
end;

--[[次数限制展示信息]]
function lua_car.remainTimesMsg(Times)
    local Times = formatNull(Times);

    local showRemainTimes = "不限次";
    if Times ~= "" then
        showRemainTimes = "余"..Times.."次";
    end;

    --调试次数显示
    if useCarCardMsgDebug == "true" then
        showRemainTimes = "余9999次";
    end;

    --[[debug_alert(
        "次数限制展示信息\n"..
        "Times : "..Times.."\n"..
        "showRemainTimes : "..showRemainTimes.."\n"..
        ""
    );]]

    return showRemainTimes;
end;

--[[额度限制展示信息]]
function lua_car.perLimitMsg(Limit)
    local Limit = formatNull(Limit);

    local showPerLimit = "不限额";
    if Limit ~= "" then
        showPerLimit = "单笔限额"..math.ceil(Limit).."元";
    end;

    --调试限额显示
    if useCarCardMsgDebug == "true" then
        showPerLimit = "单笔限额123456元";
    end;

    --[[debug_alert(
        "额度限制展示信息\n"..
        "Limit : "..Limit.."\n"..
        "showPerLimit : "..showPerLimit.."\n"..
        ""
    );]]

    return showPerLimit;
end;

--[[时间限制展示信息]]
function lua_car.useDateIntervalMsg(Start,End,DateType)
    local Start = formatNull(Start);
    local End = formatNull(End);
    local DateType = formatNull(DateType);

    local showUseDateInterval = "不限期";
    if Start~="" and End~="" then
        if DateType == "timestamp" then
            showUseDateInterval = os.date("%m/%d",Start/1000).."-"..os.date("%m/%d",End/1000);
        elseif DateType == "YYYY-MM-DD" then
            Start = ryt:getSubstringValue(Start,5,10);
            Start = string.gsub(Start,"-","/");
            End = ryt:getSubstringValue(End,5,10);
            End = string.gsub(End,"-","/");
            showUseDateInterval = Start.."-"..End;
        end;
    end;
    
    --调试时间限制显示
    if useCarCardMsgDebug == "true" then
        showUseDateInterval = "09/09-10/10";
    end;

    --[[debug_alert(
        "时间限制展示信息\n"..
        "Start : "..Start.."\n"..
        "End : "..End.."\n"..
        "DateType : "..DateType.."\n"..
        "showUseDateInterval : "..showUseDateInterval.."\n"..
        ""
    );]]

    return showUseDateInterval;
end;
