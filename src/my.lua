--[[我的业务相lua]]
lua_my = {};

--[[渲染共享人使用场景]]
function lua_my.render_share_people_use_scene()
    --业务场景数据
    local SharePeopleUseSceneData = vt("SharePeopleUseSceneData",companyTable);
    --业务场景条目数
    local SharePeopleUseSceneDataCounts = #SharePeopleUseSceneData;
    --debug_alert(SharePeopleUseSceneDataCounts);

    --业务场景存在时创建
    if SharePeopleUseSceneDataCounts > 0 then
        local selectEleArg = {};
        for key,value in pairs(SharePeopleUseSceneData) do
            local sycjContentcode = formatNull(value["sceneCode"]);
            local sycjContentname = formatNull(value["label"]);
            local sycjInfo = sycjContentcode.."_"..sycjContentname;

            local selectEleArgItem = {
                --显示文字
                labelName=sycjContentname,
                --点击函数
                clickFunc="lua_my.select_share_people_scene",
                --点击函数入参
                clickFuncArg=sycjInfo
            };
            table.insert(selectEleArg,selectEleArgItem);
        end;

        --渲染select页面
        local renderSelectArg = {
            bgName="sp_sycj_page_div",
            topEleName="top_sycj_div",
            topTitleName="使用场景",
            selectEleName="sycj_list_div",
            selectEleArg=selectEleArg,
            renderCallBackFun="render_select_sycj_page_call",
            selectType="multiple",
            finishBtnStyle="BottomFullBtn",
            finishCall="select_sycj_finish_call()",
            backCall="none"
        };
        lua_page.render_select_page(renderSelectArg);                    
    end;
    close_loading();
end;

--[[选择使用场景]]
function lua_my.select_share_people_scene(sycjInfo)
    --debug_alert(sycjInfo);
    --点击的使用场景编码
    local sycjbm = "";
    --点击的使用场景名称
    local sycjname = "";
    --使用场景
    local SharePeopleUseSceneData = vt("SharePeopleUseSceneData",companyTable);
    local SharePeopleUseSceneDataLen = #SharePeopleUseSceneData;

    if formatNull(sycjInfo)=="" or SharePeopleUseSceneData=="" then
        alert("无可用使用场景");
    else
        sycjbm = splitUtils(sycjInfo,"_")[1];
        sycjname = splitUtils(sycjInfo,"_")[2];

        --[[debug_alert(
            "选择使用场景\n"..
            "名称 : "..sycjname.."\n"..
            "编码 : "..sycjbm.."\n"..
            ""
        );]]

        --通过使用场景编码去匹配下标
        local matchsycjIndex = "";
        for i=1,SharePeopleUseSceneDataLen do
            local SharePeopleUseSceneData = formatNull(SharePeopleUseSceneData[i]);
            --debug_alert(foreach_arg2print(SharePeopleUseSceneData));
            --使用场景编码
            local sycjContentcode = vt("value",SharePeopleUseSceneData);
            if sycjContentcode == sycjbm then
                matchsycjIndex = tostring(i);
                break
            end;
        end;

        if matchsycjIndex ~= "" then
            --更新使用场景选中效果
            local setsycjSelectArg = {
                showIndex=matchsycjIndex,
                selectTyle="multiple"
            };
            local selected = lua_page.set_item_selected(setsycjSelectArg);
            --设置信息
            local saveIndex = tostring(matchsycjIndex);
            local saveInfo = "";
            if selected == "true" then
                saveInfo = sycjInfo;
            end;

            --存储参数
            globalTable["SelectSharePeopleSceneData"][saveIndex] = saveInfo;

            --标记选择过场景
            globalTable["SceneSelectFlag"] = "1";

            --[[debug_alert(
                "匹配信息\n"..
                "saveIndex : "..saveIndex.."\n"..
                "saveInfo : "..saveInfo.."\n"..
                ""
            );]]

            --更新选择的使用场景
            lua_my.update_selected_sycj();
        end;
    end;
end;

--[[更新选择的使用场景]]
function lua_my.update_selected_sycj()
    local sycj_selected_item_html = "";
    for key,value in pairs(globalTable["SelectSharePeopleSceneData"]) do
        --debug_alert(key.." "..value);
        if value ~= "" then
            local info = splitUtils(value,"_");
            local sceneCode = formatNull(info[1]);
            local sceneName = formatNull(info[2]);
            sycj_selected_item_html = sycj_selected_item_html..[[
                <div class="sycj_item_div" name="sycj_item_div" border="0">
                    <label class="sycj_name_label" value="]]..sceneName..[["></label>
                </div>
            ]];
        end;
    end;

    local sycj_selected_div_html = [[
        <div class="sycj_selected_div" name="sycj_selected_div" border="0" onclick="show_select_sharePeopleUseScene_page()">
            ]]..sycj_selected_item_html..[[
        </div>
    ]];
    document:getElementsByName("sycj_selected_div")[1]:setInnerHTML(sycj_selected_div_html);
    
    if sycj_selected_item_html ~= "" then
        show_ele("sycj_selected_div");
        changeProperty("sycj","value","");
    else
        hide_ele("sycj_selected_div");
        changeProperty("sycj","value","请选择");
    end;
    page_reload();
end;

--[[转换共享人使用场景]]
function lua_my.format_send_share_people_scene()
    local SelectSharePeopleSceneData = vt("SelectSharePeopleSceneData",globalTable);

    local sceneValue = "";
    if SelectSharePeopleSceneData ~= "" then
        for key,value in pairs(SelectSharePeopleSceneData) do
            --debug_alert(key.." / "..value);
            if value ~= "" then
                local info = splitUtils(value,"_");
                local sceneCode = formatNull(info[1]);
                if sceneCode ~= "" then
                    if sceneValue == "" then
                        sceneValue = sceneCode;
                    else
                        sceneValue = sceneValue..","..sceneCode;
                    end;
                end;
            end;
        end;
    end;

    --[[debug_alert(
        "转换共享人使用场景\n"..
        "选择的共享人数据"..foreach_arg2print(SelectSharePeopleSceneData).."\n"..
        "sceneValue : "..sceneValue.."\n"..
        ""
    );]]

    return sceneValue;
end;

--[[删除共享人确认]]
function lua_my.confirm_del_share_people(ArgJson)
    local Arg = json2table(lua_format.base64_decode(ArgJson));
    local ConfirmFlag = vt("ConfirmFlag",Arg);
    local UserPk = vt("UserPk",Arg);
    local DelCall = vt("DelCall",Arg);

    if ConfirmFlag == "1" then
        lua_my.del_share_people("",{pkShareUser=UserPk,DelCall=DelCall});
    else
        Arg["ConfirmFlag"] = "1";
        local CallArgJson = lua_format.base64_encode(table2json(Arg));
        --debug_alert(CallArgJson);
        alert_confirm(
            "",
            "是否确认删除共享人，删除后将不可使用原账号密码登录极简报销",
            "取消",
            "确定",
            "alert_confirm_call",
            "CallFun=lua_my.confirm_del_share_people&CallArg="..CallArgJson
        );
    end;
end;

--[[删除共享人]]
function lua_my.del_share_people(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams);
        ReqParams["TranCode"] = "delShareUser";
        invoke_trancode(
            "jjbx_myInfo",
            "share_people_manage",
            ReqParams,
            lua_my.del_share_people,
            {
                DelCall=vt("DelCall",ReqParams)
            },
            all_callback,
            {CloseLoading="false"}
        );
    else
        local res = json2table(ResParams["responseBody"]);
        --debug_alert("删除共享人-响应\n"..foreach_arg2print(ResParams));
        local DelCall = vt("DelCall",ResParams,"back_fun");

        local errorNo = vt("errorNo",res);
        local errorMsg = vt("errorMsg",res);
        if errorNo == "000000" then
            alertToast("0",C_DeleteMsg,"",DelCall,"");
        else
            alert(errorMsg);
        end;
    end;
end;

--[[查询用户是否授权]]
function lua_my.queryUserAuthInfo(ResParams,ReqParams)
    local MatchRes = lua_system.check_app_func("ryt_relate_auth_manager");
    if MatchRes == "true" then
        if JJBX_AliPayLoginRepeatAuth == "PC" then
            if formatNull(ResParams) == "" then
                local ReqParams = formatNull(ReqParams,{});
                ReqParams["TranCode"] = "CommonInterfaceReq";
                ReqParams["ReqAddr"] = "alipay/queryUserAuthInfo";
                ReqParams["ReqUrlExplain"] = "查询用户是否授权支付宝";
                invoke_trancode_donot_checkRepeat(
                    "jjbx_service",
                    "app_service",
                    ReqParams,
                    lua_my.queryUserAuthInfo,
                    {},
                    all_callback,
                    {CloseLoading="false"}
                );
            else
                local res = json2table(ResParams["responseBody"]);
                if res["errorNo"] == "000000" then
                    -- 0未授权 1已授权
                    local userAuth = vt("userAuth",res);
                    if userAuth == "0" then
                        --获取授权信息
                        lua_my.generateAuthInfo();
                    else
                        alertToast0("已授权");
                    end;
                else
                    alert(res["errorMsg"]);
                end;
            end;
        else
            --获取授权信息
            lua_my.generateAuthInfo();
        end;
    else
        --更新提示
        local upverArg = {
            updateType="OPTION",
            updateMsg="授权服务已经升级，请更新后使用。"
        };
        lua_ota.show_upvsr_view(upverArg);
    end;
end;

--[[获取授权信息]]
function lua_my.generateAuthInfo(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams,{});
        ReqParams["TranCode"] = "CommonInterfaceReq";
        ReqParams["ReqAddr"] = "alipay/generateAuthInfo";
        ReqParams["ReqUrlExplain"] = "生成支付宝授权authInfo";
        invoke_trancode_donot_checkRepeat(
            "jjbx_service",
            "app_service",
            ReqParams,
            lua_my.generateAuthInfo,
            {},
            all_callback,
            {CloseLoading="false"}
        );
    else
        local res = json2table(ResParams["responseBody"]);
        if res["errorNo"] == "000000" then
            close_loading();
            --授权信息
            local authInfo = vt("authInfo",res);
            --调用关联授权
            local AuthArg = {
                --操作类型
                CtrlType="AlipayLoginAuth",
                --认证信息
                AuthInfo=authInfo,
                --回调方法
                CtrlCall="alipay_login_auth_call",
                --回调参数
                CtrlCallArg=""
            };
            ryt:relate_auth_manager(table2json(AuthArg));
        else
            alert(res["errorMsg"]);
        end;
    end;
end;
