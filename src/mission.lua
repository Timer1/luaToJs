--[[极简报销任务序列处理]]

lua_mission = {};

--[[####################首页任务Begin####################]]

--[[
    首页加载完后的任务配置，按配置的先后顺序调用
      ·missionName      : 任务名称
      ·missionFun       : 调用函数，具体函数实现的所有出口均需要回调任务处理函数lua_mission.index_handle
      ·missionStatus    : 任务状态 ready/finish
      .missionNeedLogin : 任务是否需要登录
      ·missionFinish    : 完成方式 AC（系统可以自行关闭）/MC（必须手动关闭任务）
]]
local mission_init_status = "ready";
index_mission_list = {
    {
        missionName="处理客户端登记的任务",
        missionFun="lua_index_mission.deal_client_register_mission",
        missionStatus=mission_init_status,
        missionNeedLogin="false",
        missionFinish="AC"
    },
    {
        missionName="引导页展示分析",
        missionFun="lua_index_mission.analysis_show_lead",
        missionStatus=mission_init_status,
        missionNeedLogin="true",
        missionFinish="AC"
    },
    {
        missionName="信用权益说明展示分析",
        missionFun="lua_index_mission.analysis_show_credit_explain",
        missionStatus=mission_init_status,
        missionNeedLogin="true",
        missionFinish="AC"
    },
    {
        missionName="参与单据评价分析",
        missionFun="lua_index_mission.analysis_show_bill_evaluation",
        missionStatus=mission_init_status,
        missionNeedLogin="true",
        missionFinish="AC"
    },
    {
        missionName="发布收款业务确认消息",
        missionFun="lua_index_mission.analysis_show_confirm_collection",
        missionStatus=mission_init_status,
        missionNeedLogin="true",
        missionFinish="AC"
    },
    {
        missionName="发布消息提示分析",
        missionFun="lua_index_mission.analysis_show_msg",
        missionStatus=mission_init_status,
        missionNeedLogin="true",
        missionFinish="MC"
    }
};

--[[获取调试状态]]
function lua_mission.index_debug()
    local res = "";
    --配置的调试开关
    local IndexMissionConfigDebugFlag = "false";
    --用户设置的调试开关
    local IndexMissionUserSetDebugFlag = formatNull(globalTable["IndexMissionUserSetDebugFlag"]);

    --优先取用户设置的调试开关
    if formatNull(IndexMissionUserSetDebugFlag, IndexMissionConfigDebugFlag) == "true" then
        res = "true";
    else
        res = "false";
    end;

    --[[debug_alert(
        "获取调试状态\n"..
        "配置状态 : "..IndexMissionConfigDebugFlag.."\n"..
        "设置状态 : "..IndexMissionUserSetDebugFlag.."\n"..
        "返回结果 : "..res.."\n"..
        ""
    );]]

    return res;

    --强制开启调试
    --globalTable["IndexMissionShowDebugMsg"] = "true";
    --return "true";
end

--[[首页任务处理]]
function lua_mission.index_handle()
    --debug_alert("lua_mission.index_handle");

    --调试
    local debug_alert_msg = "";
    if lua_mission.index_debug() == "true" then
        local FinishIndex = formatNull(globalTable["IndexPageMissionIndex"]);
        if FinishIndex ~= "" then
            debug_alert_msg =
                "关闭\n"..
                "－－－－－－－－－－－－－－－\n"..
                "任务编号 : "..FinishIndex.."\n"..
                "";
        end;
    end;

    --由于当前任务配置均只调用一次，为了避免死循环，这里强制对上一个任务进行完成操作
    if globalTable["IndexPageMissionIndex"] ~= nil then
        lua_mission.index_finish(globalTable["IndexPageMissionIndex"],"AC");
        globalTable["IndexPageMissionIndex"] = nil;
    end;

    local missionAlertMsg = "";
    for missionIndex,mission in pairs(index_mission_list) do
        local mission = formatNull(mission);
        if mission == "" then
            debug_alert("读取任务配置错误");
        else
            local missionName = vt("missionName",mission);
            local missionStatus = vt("missionStatus",mission);
            local missionFun = vt("missionFun",mission);
            local missionFinish = vt("missionFinish",mission);
            local missionNeedLogin = vt("missionNeedLogin",mission);

            if missionStatus == "ready" then
                --debug_alert("未执行待办 :\n"..missionName);

                --debug演示
                if lua_mission.index_debug() == "true" then
                    debug_alert_msg =
                        debug_alert_msg..
                        "\n"..
                        "调用\n"..
                        "－－－－－－－－－－－－－－－\n"..
                        "调用时间 : "..os.time().."\n"..
                        "调用编号 : "..missionIndex.."\n"..
                        "任务名称 : "..missionName.."\n"..
                        "任务状态 : "..missionStatus.."\n"..
                        "任务函数 : "..missionFun.."\n"..
                        "完成方式 : "..missionFinish.."\n"..
                        "";
                    if globalTable["IndexMissionShowDebugMsg"] == "true" then
                        debug_alert(debug_alert_msg);
                    end;
                end;

                --当前用户登录的主键
                local PkUserNow = vt("PkUser",globalTable);

                --判断是否执行任务
                local DoMission = "true";
                if missionNeedLogin == "true" then
                    if PkUserNow ~= "" then
                        --任务需要登录，用户已经登录
                        DoMission = "true";
                    else
                        --任务需要登录，用户未登录
                        DoMission = "false";
                    end;
                else
                    --任务无需登录，或任务实现处进行处理
                    DoMission = "true";
                end;

                if DoMission == "true" then
                    --存储任务编号
                    globalTable["IndexPageMissionIndex"] = missionIndex;

                    --debug_alert("执行任务"..missionName);
                    lua_system.do_function(missionFun, mission);
                    break
                else
                    --debug_alert("跳过任务"..missionName);
                end;
            else
                --debug_alert("已执行待办 :\n"..missionName);
            end;
        end;
    end;

    --debug_alert("ArgInitAfterLoginFlag : "..vt("ArgInitAfterLoginFlag",companyTable));

    if companyTable["ArgInitAfterLoginFlag"]~="true" and PkUserNow~="" then
        --debug_alert("用户已经登录且参数未初始化的情况下，进行参数初始化");
        lua_jjbx.arg_init_after_login();
    else
        close_loading();
    end;
end;

--[[首页任务状态标记为完成]]
function lua_mission.index_finish(missionIndex,finishStyle)
    --关闭方式
    local finishStyle = formatNull(finishStyle,"AC");
    --任务编号
    local missionIndex = tonumber(formatNull(missionIndex,"-1"));

    --[[debug_alert(
        "lua_mission.index_finish\n"..
        "missionIndex : "..missionIndex.."\n"..
        "finishStyle : "..finishStyle.."\n"..
        ""
    );]]

    if missionIndex < 0 then
        --debug_alert("无待关闭任务");
    else
        --任务对象
        local missionObj = formatNull(index_mission_list[missionIndex]);
        --修改任务状态
        if missionObj ~= "" then
            local missionFinish = formatNull(missionObj["missionFinish"]);

            if missionFinish == "AC" then
                --自动关闭
                lua_mission.index_set("finish",missionIndex);
            elseif missionFinish == "MC" then
                --任务指定为手动关闭时才能关闭
                if finishStyle=="MC" then
                    lua_mission.index_set("finish",missionIndex);
                else
                    --debug_alert("任务必须手动完成");
                end;
            else

            end;
        else
            debug_alert("读取任务配置错误");
        end;
    end;
end;

--[[首页任务设置]]
function lua_mission.index_set(status,index)
    local status = formatNull(status);
    local index = formatNull(index);
    local missionStatus = "";
    if status == "ready" then
        missionStatus = "ready";
    elseif status == "finish" then
        missionStatus = "finish";
    end;

    if missionStatus ~= "" then
        if index == "" then
            --没有给定任务，默认为全部设置
            for missionIndex,mission in pairs(index_mission_list) do
                local mission = formatNull(mission);
                if mission == "" then
                    debug_alert("读取任务配置错误");
                else
                    index_mission_list[missionIndex]={
                        missionFun=vt("missionFun",mission),
                        missionName=vt("missionName",mission),
                        missionNeedLogin=vt("missionNeedLogin",mission),
                        missionFinish=vt("missionFinish",mission),
                        missionStatus=missionStatus
                    };
                end;
            end;
        else
            --给定任务编号设置对应任务
            local setMission = formatNull(index_mission_list[index]);
            if setMission == "" then
                debug_alert("读取任务配置错误");
            else
                index_mission_list[index]={
                    missionFun=formatNull(index_mission_list[index]["missionFun"]),
                    missionName=formatNull(index_mission_list[index]["missionName"]),
                    missionNeedLogin=formatNull(index_mission_list[index]["missionNeedLogin"]),
                    missionFinish=formatNull(index_mission_list[index]["missionFinish"]),
                    missionStatus=missionStatus
                };
            end;
        end;
    end;
end;

--[[####################首页任务End####################]]

--[[清理客户端登记任务]]
function lua_mission.clear_app_register_mission(Arg)
    local ClearMsg = vt("ClearMsg",Arg);
    --debug_alert(ClearMsg.."，操作完成后，清理客户端登记任务");
    set_db_value("ClientRegisterMissionArg","");
end;
