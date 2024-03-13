--[[版本控制]]

lua_ota = {};

--[[执行版本更新]]
function do_up_vsr(params)
    --打开下载更新地址
    local update_download_url = formatNull(systemTable["UpdateDownloadUrl"]);
    --[[debug_alert(
        "执行版本更新\n"..
        "下载地址 : "..update_download_url.."\n"..
        ""
    );]]
    if update_download_url == "" then
        alert("下载失败，找不到更新文件。");
    else
        if platform == "iPhone OS" then
            system:openURL(update_download_url);
        else
            update:openDownLoad(update_download_url);
        end;
    end;
end;

--[[忽略本次更新]]
function do_skip_up_vsr()
    --debug_alert("do_skip_up_vsr");
    --记录跳过更新状态，本次登录有效
    globalTable["skip_up_vsr"] = "true";

    --有回调指定时调用回调
    local SkipVersionUpdateCallFuc = vt("SkipVersionUpdateCallFuc",globalTable);
    local SkipVersionUpdateCallArg = vt("SkipVersionUpdateCallArg",globalTable);
    globalTable["SkipVersionUpdateCallFuc"] = "";
    globalTable["SkipVersionUpdateCallArg"] = "";
    lua_system.do_function(SkipVersionUpdateCallFuc,SkipVersionUpdateCallArg);
end;

--[[显示版本更新界面]]
function lua_ota.show_upvsr_view(Arg)
    local updateType = vt("updateType",Arg);
    local updateMsg = vt("updateMsg",Arg,"已经发布新版本，请及时更新！");
    local updateBtnText = vt("updateBtnText",Arg,"立即升级");
    local cancelBtnText = vt("cancelBtnText",Arg,"稍后提醒");
    --跳过按钮回调方法和参数
    local SkipVersionUpdateCallFuc = vt("SkipVersionUpdateCallFuc",Arg);
    local SkipVersionUpdateCallArg = vt("SkipVersionUpdateCallArg",Arg);
    globalTable["SkipVersionUpdateCallFuc"] = SkipVersionUpdateCallFuc;
    globalTable["SkipVersionUpdateCallArg"] = SkipVersionUpdateCallArg;

    --版本是否可以跳过
    local vsrCanSkip = "";
    if updateType == "MUST" then
        vsrCanSkip = "1";
    else
        --默认可以跳过
        vsrCanSkip = "0";
    end;

    --[[debug_alert(
        "show_upvsr_view\n"..
        "updateType:"..updateType.."\n"..
        "updateMsg:"..updateMsg.."\n"..
        "vsrCanSkip:"..vsrCanSkip.."\n"..
        "updateBtnText:"..updateBtnText.."\n"..
        "cancelBtnText:"..cancelBtnText.."\n"..
        ""
    );]]

    --[[
        版本更弹框控件
        * @param 1 更新内容
        * @param 2 更新按钮文字
        * @param 3 跳过按钮文字
        * @param 4 是否显示跳过按钮 0:显示,1:不显示
        * @param 5 更新方法
        * @param 6 跳过方法
    ]]
    picker:updateAPPDialog(updateMsg,updateBtnText,cancelBtnText,vsrCanSkip,"do_up_vsr","do_skip_up_vsr");
end;

--[[客户端检查更新]]
function check_app_update()
    local need_update = "";
    --判断当次登录是否不再提醒
    if globalTable["skip_up_vsr"] ~= "true" then
        --debug_alert(systemTable["updateStatus"]);
        if systemTable["updateStatus"] == "MUST" then
            --强制更新
            need_update = "MUST";

            --更新提示
            local upverArg = {
                updateType="MUST"
            };
            lua_ota.show_upvsr_view(upverArg);
        elseif systemTable["updateStatus"] == "OPTION" then
            --建议更新
            need_update = "OPTION";
            
            --更新提示
            local upverArg = {
                updateType="OPTION"
            };
            lua_ota.show_upvsr_view(upverArg);
        else
            --无需更新 "NOTUPDATE"
            need_update = "";
        end;
    end;

    return need_update;
end;

--[[版本判断]]
function lua_ota.version_ctrl(nowVersion, supportVersion)
    local nowVersion = formatNull(nowVersion);
    local supportVersion = formatNull(supportVersion);
    local nowVersionPointLen = find_str_counts(nowVersion,"%.");
    local supportVersionPointLen = find_str_counts(supportVersion,"%.");

    local result = "true";
    --版本号正确才进行控制分析，默认不分析
    if nowVersionPointLen == 2 and supportVersionPointLen == 2 then
        local nowVersionList = splitUtils(nowVersion,"%.");
        local supportVersionList = splitUtils(supportVersion,"%.");

        nowX = tonumber(nowVersionList[1]);
        nowY = tonumber(nowVersionList[2]);
        nowZ = tonumber(nowVersionList[3]);
        supportX = tonumber(supportVersionList[1]);
        supportY = tonumber(supportVersionList[2]);
        supportZ = tonumber(supportVersionList[3]);

        --各个位数上的比较结果
        local XRes = "";
        local YRes = "";
        local ZRes = "";

        if nowX > supportX then
            XRes = "false";
            result = "true";
        elseif supportX == nowX and nowY > supportY then
            YRes = "false";
            result = "true";
        elseif supportX == nowX and supportY == nowY and nowZ >= supportZ then
            ZRes = "false";
            result = "true";
        else
            result = "false";
        end;

        --[[debug_alert(
            "lua_ota.version_ctrl\n"..
            "nowVersion:"..nowVersion.."\n"..
            "nowVersionPointLen:"..nowVersionPointLen.."\n"..
            "nowX:"..nowX.."\n"..
            "nowY:"..nowY.."\n"..
            "nowZ:"..nowZ.."\n"..
            "\n"..
            "supportVersion:"..supportVersion.."\n"..
            "supportVersionPointLen:"..supportVersionPointLen.."\n"..
            "supportX:"..supportX.."\n"..
            "supportY:"..supportY.."\n"..
            "supportZ:"..supportZ.."\n"..
            "\n"..
            "Compare Res X:"..XRes.."\n"..
            "Compare Res Y:"..YRes.."\n"..
            "Compare Res Z:"..ZRes.."\n"..
            "\n"..
            "result :"..result.."\n"..
            ""
        );]]
    end;

    return result;
end;

--[[app功能最低版本支持检测]]
function lua_ota.version_support(AppFunId)
    local AppFunId = formatNull(AppFunId);
    --是否支持
    local appSupport = "true";
    --提示信息
    local appSupportTipMsg = "";
    --当前版本
    local nowVersion = systemTable["nowVersion"];
    --支持版本
    local supportVersion = "";
    local VersionSupportConfig = vt("version_support_obj",globalTable);

    --[[local debug_alert_msg = "";
    debug_alert_msg =
        debug_alert_msg..
        "app功能最低版本支持检测\n"..
        "功能简称 : "..AppFunId.."\n"..
        "当前版本 : "..nowVersion.."\n"..
        "参数配置 : "..foreach_arg2print(VersionSupportConfig).."\n"..
        "";]]

    if VersionSupportConfig ~= "" then
        local appSupportConf = vt(AppFunId,VersionSupportConfig);
        if appSupportConf ~= "" then
            --配置的参数名
            local appSupportConfVerName = "";
            local appSupportConfMsgName = "";
            if platform =="iPhone OS" then
                appSupportConfVerName = "iPhone_ver";
                appSupportConfMsgName = "iPhone_msg";
            else
                appSupportConfVerName = "Android_ver";
                appSupportConfMsgName = "Android_msg";
            end;

            --最低版本号
            local appSupportConfVerValue = formatNull(appSupportConf[1][appSupportConfVerName]);
            supportVersion = appSupportConfVerValue;
            --提示信息
            local appSupportConfMsgValue = formatNull(appSupportConf[1][appSupportConfMsgName]);

            --版本支持判断
            appSupport = lua_ota.version_ctrl(nowVersion,appSupportConfVerValue);
            --提示信息
            appSupportTipMsg = appSupportConfMsgValue;

            --调试信息
            --[[debug_alert_msg =
                debug_alert_msg..
                "最低版本号 : "..appSupportConfVerValue.."\n"..
                "提示信息 : "..appSupportConfMsgValue.."\n"..
                "";]]
        end;
    end;

    --debug_alert(debug_alert_msg);

    --返回结果
    return {
        appSupport = appSupport,
        appSupportTipMsg = appSupportTipMsg,
        nowVersion = nowVersion,
        supportVersion = supportVersion
    };
end;
