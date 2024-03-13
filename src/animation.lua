--[[动画库]]

lua_animation = {};
--当前动画执行的方向(默认从右往左)
AnimationFlg = "left";

--[[--------------------API依赖Begin--------------------]]

--[[动画注册]]
function lua_animation.register(arg)
    --动画运行时间
    local RunTime = tonumber(formatNull(arg["RunTime"],"0.3"));
    --动画重复次数
    local RepeatCounts = tonumber(formatNull(arg["RepeatCounts"],"1"));
    --动画类型
    local AnimationStyle = formatNull(arg["AnimationStyle"]);
    --X轴移动距离
    local MoveDistanceX = tonumber(formatNull(arg["MoveDistanceX"],"0"));
    --Y轴移动距离
    local MoveDistanceY = tonumber(formatNull(arg["MoveDistanceY"],"0"));

    --动画标记
    local AnimationTag = formatNull(arg["AnimationTag"]);
    --动画对象名
    local AnimationElementName = formatNull(arg["AnimationElementName"]);
    --容器对象名
    local AnimationElementPackName = formatNull(arg["AnimationElementPackName"]);
    --动画结束后操作对象的位置是否更新
    local AnimationLocationUpdate = formatNull(arg["AnimationLocationUpdate"],"false");
    --动画开始是否使用loading框
    local AnimationStartLoading = formatNull(arg["AnimationStartLoading"],"false");
    --动画结束是否使用loading框
    local AnimationStopLoading = formatNull(arg["AnimationStopLoading"],"false");

    --客户端动画开始时的系统回调方法
    local AnimationStartCallFuncName = formatNull(arg["AnimationStartCallFuncName"],"lua_animation.default_start_call");
    --客户端动画结束时的系统回调方法
    local AnimationStopCallFuncName = formatNull(arg["AnimationStopCallFuncName"],"lua_animation.default_stop_call");

    if AnimationElementName ~= "" then
        --动画对象
        local AnimationElementObj = document:getElementsByName(AnimationElementName)[1];

        local register_debug_msg = 
            "动画注册\n"..
            "运行时间 : "..RunTime.."\n"..
            "运行次数 : "..RepeatCounts.."\n"..
            "动画类型 : "..AnimationStyle.."\n"..
            "横轴移动 : "..MoveDistanceX.."\n"..
            "纵轴移动 : "..MoveDistanceY.."\n"..
            "动画标记 : "..AnimationTag.."\n"..
            "开始回调 : "..AnimationStartCallFuncName.."\n"..
            "结束回调 : "..AnimationStopCallFuncName.."\n"..
            "开始加载 : "..AnimationStartLoading.."\n"..
            "结束加载 : "..AnimationStopLoading.."\n"..
            "容器控件 : "..AnimationElementPackName.."\n"..
            "动画控件 : "..AnimationElementName.."\n"..
            "位置更新 : "..AnimationLocationUpdate.."\n"..
            "";
        --debug_alert(register_debug_msg);

        --注册动画启动监听
        transition:setStartListener(AnimationElementObj,lua_format.str2fun(AnimationStartCallFuncName));
        --注册动画结束监听
        transition:setStopListener(AnimationElementObj,lua_format.str2fun(AnimationStopCallFuncName));

        --设置动画重复次数
        transition:setRepeatCount(AnimationElementObj,RepeatCounts);

        --动画参数存缓存
        globalTable["AnimationArg"] = arg;

        --执行动画
        if AnimationStyle == "X" then
            --X轴平移
            transition:translateX(AnimationElementObj,MoveDistanceX,RunTime);
        elseif AnimationStyle == "Y" then
            --Y轴平移
            transition:translateY(AnimationElementObj,MoveDistanceY,RunTime);
        elseif AnimationStyle == "XY" then
            --X轴Y轴同时平移（未调试）
            --transition:translateY(AnimationElementObj,MoveDistanceX,MoveDistanceY,RunTime);
        elseif AnimationStyle == "Alpha" then
            --更改控件透明度（未调试）
            --transition:alpha(AnimationElementObj,0.5,RunTime);
        else
            debug_alert("不支持的动画类型");
        end;

        return "true";
    else
        debug_alert("动画注册失败");
        return "error";
    end;
end;

--[[动画启动监听回调]]
function lua_animation.default_start_call()
    --debug_alert("动画启动监听回调");
    lua_animation.do_call("start");
end;

--[[动画结束监听回调]]
function lua_animation.default_stop_call()
    --debug_alert("动画结束监听回调");
    lua_animation.do_call("stop");
end;

--[[动画loading处理]]
function lua_animation.loading(ActFlag,StartLoading,StopLoading)
    --是否使用loading框
    local UseLoading = "false";

    if ActFlag == "start" then
        --单次动画开始start
        UseLoading = StartLoading;
    else
        --单次动画结束stop
        UseLoading = StopLoading;
    end;

    local loading_debug_msg =
        "动画loading处理\n"..
        "参数-动画类型 : "..ActFlag.."\n"..
        "参数-开始loading : "..StartLoading.."\n"..
        "参数-结束loading : "..StopLoading.."\n"..
        "\n"..
        "执行loading : "..UseLoading.."\n"..
        "";
    --debug_alert(loading_debug_msg);

    --loading执行
    if UseLoading == "true" then
        show_loading();
    else
        close_loading();
    end;
end;

--[[执行动画回调]]
function lua_animation.do_call(actflag)
    --记录动画当前状态（开始：start，结束：stop）
    globalTable["AnimationActFlag"] = actflag;
    --debug_alert("lua_animation.do_call actflag : "..actflag);

    --动画参数
    local AnimationArg = formatNull(globalTable["AnimationArg"]);
    --[[debug_alert(
        "lua_animation.do_call actflag : "..actflag.."\n"..
        "animation Arg : "..foreach_arg2print(AnimationArg).."\n"..
        ""
    );]]

    if AnimationArg ~= "" then
        --动画执行标记，标记单次动画调用的开始和结束
        local AnimationActFlag = actflag;
        --动画标记，标记是整个动画逻辑的开始和结束
        local AnimationTag = formatNull(AnimationArg["AnimationTag"]);
        --动画开始是否使用loading框
        local AnimationStartLoading = formatNull(AnimationArg["AnimationStartLoading"],"false");
        --动画结束是否使用loading框
        local AnimationStopLoading = formatNull(AnimationArg["AnimationStopLoading"],"false");
        --动画结束后操作对象的位置是否更新
        local AnimationLocationUpdate = formatNull(AnimationArg["AnimationLocationUpdate"],"false");
        --动画类型
        local AnimationStyle = formatNull(AnimationArg["AnimationStyle"],"false");
        --X轴移动距离
        local MoveDistanceX = tonumber(formatNull(AnimationArg["MoveDistanceX"],"0"));
        --Y轴移动距离
        local MoveDistanceY = tonumber(formatNull(AnimationArg["MoveDistanceY"],"0"));
        --动画对象名
        local AnimationElementName = formatNull(AnimationArg["AnimationElementName"]);
        --动画控件容器名
        local AnimationElementPackName = formatNull(AnimationArg["AnimationElementPackName"]);

        --动画loading处理
        lua_animation.loading(AnimationActFlag,AnimationStartLoading,AnimationStopLoading);

        --整个动画逻开始
        if AnimationTag == "BEGIN" then
        --整个动画逻结束
        elseif AnimationTag == "END" then
            --隐藏动画容器
            if AnimationActFlag == "stop" and AnimationElementPackName ~= "" then
                --debug_alert("动画结束隐藏容器 : "..AnimationElementPackName);
                hide_ele(AnimationElementPackName);
            end;
        else
            debug_alert("动画开始结束标记不正确");
            return;
        end;

        --动画开始的处理
        if AnimationActFlag == "start" then
            --动画开始时的回调
            lua_system.do_function(AnimationArg["AnimationStartFuncName"],AnimationArg["AnimationStartFuncArg"]);
        --动画结束的处理
        elseif AnimationActFlag == "stop" then
            --更新动画控件位置
            if AnimationLocationUpdate == "true" then
                --动画对象宽度
                local AnimationElementeleWidth = getEleLocation(AnimationElementName,"width");
                --动画对象高度
                local AnimationElementeleHeight = getEleLocation(AnimationElementName,"height");
                --动画对象左距
                local AnimationElementeleLeft = getEleLocation(AnimationElementName,"left");
                --动画对象右距
                local AnimationElementeleRight = getEleLocation(AnimationElementName,"right");
                --动画对象顶部距离
                local AnimationElementeleTop = getEleLocation(AnimationElementName,"top");
                --动画对象底部距离
                local AnimationElementeleBottom = getEleLocation(AnimationElementName,"bottom");

                --横轴更新距离
                local UpdateDistanceX = AnimationElementeleLeft+MoveDistanceX;
                local UpdateDistanceY = AnimationElementeleTop+MoveDistanceY;

                local move_debug_msg =
                    "动画结束的回调处理\n\n"..
                    "原位置 : \n"..
                    "宽/高 : "..AnimationElementeleWidth.."/"..AnimationElementeleHeight.."\n"..
                    "左/右 : "..AnimationElementeleLeft.."/"..AnimationElementeleRight.."\n"..
                    "上/下 : "..AnimationElementeleTop.."/"..AnimationElementeleBottom.."\n"..
                    "\n"..
                    "移动距离 : \n"..
                    "横轴 : "..MoveDistanceX.."\n"..
                    "纵轴 : "..MoveDistanceY.."\n"..
                    "\n"..
                    "更新位置\n"..
                    "横轴 : "..UpdateDistanceX.."\n"..
                    "纵轴 : "..UpdateDistanceY.."\n"..
                    "";
                --debug_alert(move_debug_msg);

                if AnimationStyle == "X" then
                    --横轴移动
                    setEleLocation(AnimationElementName,"left",UpdateDistanceX);
                elseif AnimationStyle == "Y" then
                    --纵轴移动
                    setEleLocation(AnimationElementName,"top",UpdateDistanceY);
                else

                end;

                --刷新页面
                --location:reload();
                --page_reload();
            end;

            --动画结束时的回调
            lua_system.do_function(AnimationArg["AnimationStopFuncName"],AnimationArg["AnimationStopFuncArg"]);
        else

        end;
    else
        debug_alert("动画参数为空");
    end;
end;

--[[--------------------API依赖End--------------------]]

--[[--------------------侧屏动画Begin--------------------]]

--[[动画显示侧屏]]
function lua_animation.show_screen_page(containerName, widgetName, direction, businessCallFun, businessCallArg)
    lua_animation.screen_page_ctrl(containerName, widgetName, direction, businessCallFun, businessCallArg, "BEGIN");
end;

--[[动画关闭侧屏]]
function lua_animation.hide_screen_page(containerName, widgetName, direction, businessCallFun, businessCallArg)
    lua_animation.screen_page_ctrl(containerName, widgetName, direction, businessCallFun, businessCallArg, "END");
end;

--[[
    侧屏动画控制，支持从上、下、左、右四个方向通过动画移动的方式显示和隐藏控件
    containerName   : 侧屏容器
    widgetName      : 侧屏控件
    direction       : 侧屏的初始方位 left/right/up/down
    businessCallFun : 动画结束后的业务回调方法
    businessCallArg : 动画结束后的业务回调参数
    animationTag    : 动画标记，开始BEGIN/结束END
]]
function lua_animation.screen_page_ctrl(containerName, widgetName, direction, businessCallFun, businessCallArg, animationTag)
    --容器名名称
    local containerName = formatNull(containerName);
    --容器宽度
    local containerWidth = getEleLocation(containerName,"width");
    --容器高度
    local containerHeight = getEleLocation(containerName,"height");

    --控件名称
    local widgetName = formatNull(widgetName);
    --控件宽度
    local widgetWidth = getEleLocation(widgetName,"width");
    --控件高度
    local widgetHeight = getEleLocation(widgetName,"height");

    --默认控件在屏幕右侧
    local direction = formatNull(direction,"right");
    --动画结束调用业务回调方法
    local businessCallFun = formatNull(businessCallFun);
    --动画结束调用业务回调参数
    local businessCallArg = formatNull(businessCallArg);
    --默认动画逻辑标记为"开始"
    local animationTag = formatNull(animationTag,"BEGIN");

    --动画结束后的系统回调
    local animationStopFuncName = "lua_animation.screen_page_ctrl_sys_call";

    --移动方向
    local animationStyle = "";
    if direction=="right" or direction=="left" then
        --当控件初始位于左右方位时认为是X轴移动
        animationStyle = "X";
    elseif direction=="up" or direction=="down" then
        --当控件初始位于上下方位时认为是X轴移动
        animationStyle = "Y";
    end;

    --X轴移动距离
    local moveDistanceX = 0;
    --Y轴移动距离
    local moveDistanceY = 0;

    --动画距离计算
    if animationTag=="BEGIN" and direction=="right" then
        --控件初始在右侧，开始往左侧平移
        moveDistanceX = 0-widgetWidth;
    elseif animationTag=="BEGIN" and direction=="left" then
        --控件初始在左侧，开始往右侧平移
        moveDistanceX = widgetWidth;
    elseif animationTag=="END" and direction=="right" then
        --控件初始在右侧，往左侧平移结束后往右侧还原
        moveDistanceX = widgetWidth;
    elseif animationTag=="END" and direction=="left" then
        --控件初始在左侧，往右侧平移后结束后往左侧还原
        moveDistanceX = 0-widgetWidth;
    elseif animationTag=="BEGIN" and direction=="up" then
        --控件初始在上方，开始往下方平移
        moveDistanceY = widgetHeight;
    elseif animationTag=="BEGIN" and direction=="down" then
        --控件初始在下方，开始往上方平移
        moveDistanceY = 0-widgetHeight;
    elseif animationTag=="END" and direction=="up" then
        --控件初始在上方，往下方平移后结束后往上方还原
        moveDistanceY = 0-widgetHeight;
    elseif animationTag=="END" and direction=="down" then
        --控件初始在下方，往上方平移后结束后往下方还原
        moveDistanceY = widgetHeight;
    else
        debug_alert(
            "不支持的移动方位\n"..
            "animationTag : "..animationTag.."\n"..
            "direction : "..direction.."\n"..
            ""
        );
        return;
    end;

    --注册动画
    local registerArg = {
        AnimationElementName=widgetName,
        AnimationElementPackName=containerName,
        AnimationStyle=animationStyle,
        MoveDistanceX=moveDistanceX,
        MoveDistanceY=moveDistanceY,
        AnimationTag=animationTag,
        AnimationStartLoading="true",
        AnimationStopLoading="false",
        AnimationLocationUpdate="true",
        AnimationStopFuncName=animationStopFuncName,
        AnimationStopFuncArg={
            containerName=containerName,
            containerWidth=containerWidth,
            containerHeight=containerHeight,
            widgetName=widgetName,
            widgetWidth=widgetWidth,
            widgetHeight=widgetHeight,
            direction=direction,
            finishCallFun=businessCallFun,
            finishCallArg=businessCallArg,
            animationTag=animationTag,
            moveDistanceX=moveDistanceX,
            moveDistanceY=moveDistanceY
        }
    };
    local registerRes = lua_animation.register(registerArg);

    --调试信息
    local ctrl_debug_msg =
        "lua_animation.screen_page_ctrl\n"..
        "\n"..
        "input Arg\n"..
        "containerName : "..containerName.."\n"..
        "widgetName : "..widgetName.."\n"..
        "direction : "..direction.."\n"..
        "businessCallFun : "..businessCallFun.."\n"..
        "businessCallArg : "..businessCallArg.."\n"..
        "animationTag : "..animationTag.."\n"..
        "\n"..
        "register Arg"..foreach_arg2print(registerArg)..
        "";
    --debug_alert(ctrl_debug_msg);

    --动画注册成功
    if registerRes ~= "error" then
        --有容器的情况下，在动画启动前显示容器
        if containerName~="" and animationTag=="BEGIN" then
            show_ele(containerName);
        end;
    end;

    return registerRes;
end;

--[[动画结束后的系统回调]]
function lua_animation.screen_page_ctrl_sys_call(Arg)
    local call_debug_msg = "";

    --控件背景容器
    local containerName = formatNull(Arg["containerName"]);
    local containerWidth = formatNull(Arg["containerWidth"]);
    local containerHeight = formatNull(Arg["containerHeight"]);
    --动画控件
    local widgetName = formatNull(Arg["widgetName"]);
    local widgetWidth = formatNull(Arg["widgetWidth"]);
    local widgetHeight = formatNull(Arg["widgetHeight"]);
    --动画控件的父控件
    local parentWidget = getParentWidget(widgetName);
    local parentWidgetName = parentWidget:getPropertyByName("name");
    local parentWidgetWidth = getEleLocation(parentWidgetName,"width");
    local parentWidgetHeight = getEleLocation(parentWidgetName,"height");

    --控件初始方位
    local direction = formatNull(Arg["direction"]);
    --动画类型标记
    local animationTag = formatNull(Arg["animationTag"]);
    --X轴移动距离
    local moveDistanceX = formatNull(Arg["moveDistanceX"]);
    --Y轴移动距离
    local moveDistanceY = formatNull(Arg["moveDistanceY"]);

    if animationTag == "END" then
        --动画结束后，初始化控件位置
        if containerName~="" and widgetName~="" then
            if direction == "right" then
                local setRightPx = parentWidgetWidth;
                setEleLocation(widgetName,"left",setRightPx);
                call_debug_msg = call_debug_msg.."控件初始在右侧，隐藏时将控件还原至屏幕右侧，设置left值为父控件宽度"..setRightPx.."\n";
            elseif direction == "left" then
                local setLeftPx = 0-widgetWidth;
                setEleLocation(widgetName,"left",setLeftPx);
                call_debug_msg = call_debug_msg.."控件初始在左侧，隐藏时将控件还原至屏幕左侧，设置left值为-控件宽度"..setLeftPx.."\n";
            elseif direction == "up" then
                local setTopPx = 0-widgetHeight;
                setEleLocation(widgetName,"top",setTopPx);
                call_debug_msg = call_debug_msg.."控件初始在上方，隐藏时将控件还原至上方，设置top值为-控件高度:"..setTopPx.."\n";
            elseif direction == "down" then
                --设置top值为父控件的高度
                local setTopPx = parentWidgetHeight;
                setEleLocation(widgetName,"top",setTopPx);
                call_debug_msg = call_debug_msg.."控件初始在下方，隐藏时将控件还原至下方，设置top值为父控件高度:"..setTopPx.."\n";
            end;

            if containerName ~= "" then
                --有容器的情况下，在动画结束后隐藏容器
                hide_ele(containerName);
            end;
        end;
    end;

    --debug_alert("动画结束回调参数\n"..foreach_arg2print(Arg).."\n\n执行操作 :\n"..call_debug_msg);

    --业务回调
    if finishCallFun~= "" then
        lua_system.do_function(Arg["finishCallFun"],Arg["finishCallArg"])
    end;
end;

--[[--------------------侧屏动画End--------------------]]

--[[--------------------单向移动动画Begin--------------------]]

--[[
    单向移动
    widgetName      : 控件名
    moveDirection   : 移动方向 X/Y
    moveDistance    : 移动距离
    businessCallFun : 动画完成后的业务回调方法
    businessCallArg : 动画完成后的业务回调参数
]]
function lua_animation.one_way_action(widgetName, moveDirection, moveDistance, businessCallFun, businessCallArg)
    local widgetName = formatNull(widgetName);
    local moveDirection = formatNull(moveDirection);
    local moveDistance = formatNull(moveDistance);
    local businessCallFun = formatNull(businessCallFun);
    local businessCallArg = formatNull(businessCallArg);

    local registerArg = {
        AnimationElementName=widgetName,
        AnimationStyle=moveDirection,
        MoveDistanceX=moveDistance,
        AnimationTag="BEGIN",
        AnimationStartLoading="true",
        AnimationStopLoading="false",
        AnimationLocationUpdate="true",
        AnimationStopFuncName="lua_animation.one_way_sys_call",
        AnimationStopFuncArg={
            finishCallFun=businessCallFun,
            finishCallArg=businessCallArg
        }
    };
    local registerRes = lua_animation.register(registerArg);
    --动画注册成功
    if registerRes ~= "error" then
        --debug_alert("单向移动动画注册成功");
    end;
end;

--[[单向移动动画结束后的系统回调]]
function lua_animation.one_way_sys_call(arg)
    --执行业务回调
    lua_system.do_function(arg["finishCallFun"],arg["finishCallArg"]);
end;

--[[--------------------单向移动动画End--------------------]]

--[[--------------------拖拽动画Begin--------------------]]

--拖动动画参数列表，预置5个拖动操作对象
AniDragArgList = {
    drag_ctrl_ele1 = {},
    drag_ctrl_ele2 = {},
    drag_ctrl_ele3 = {},
    drag_ctrl_ele4 = {},
    drag_ctrl_ele5 = {}
};

--拖动动画参数列表，预置5个拖动设置参数
AniSetDragArg1 = {
    DragEleNames="drag_ctrl_ele1",
    DragCtrlName="drag_ctrl_ele1",
    DragCallFun="drag_ctrl_ele1_call",
    DragXStyleCtrl="",
    DragYStyleCtrl=""
};
AniSetDragArg2 = {
    DragEleNames="drag_ctrl_ele2",
    DragCtrlName="drag_ctrl_ele2",
    DragCallFun="drag_ctrl_ele2_call",
    DragXStyleCtrl="",
    DragYStyleCtrl=""
};
AniSetDragArg3 = {
    DragEleNames="drag_ctrl_ele3",
    DragCtrlName="drag_ctrl_ele3",
    DragCallFun="drag_ctrl_ele3_call",
    DragXStyleCtrl="",
    DragYStyleCtrl=""
};
AniSetDragArg4 = {
    DragEleNames="drag_ctrl_ele4",
    DragCtrlName="drag_ctrl_ele4",
    DragCallFun="drag_ctrl_ele4_call",
    DragXStyleCtrl="",
    DragYStyleCtrl=""
};
AniSetDragArg5 = {
    DragEleNames="drag_ctrl_ele5",
    DragCtrlName="drag_ctrl_ele5",
    DragCallFun="drag_ctrl_ele5_call",
    DragXStyleCtrl="",
    DragYStyleCtrl=""
};

--[[设置控件拖拽动画]]
function lua_animation.set_drag_listener(Arg)
    --debug_alert("设置控件拖拽动画"..foreach_arg2print(Arg));
    --拖拽对象名称集合(,分隔)
    local DragEleNames = vt("DragEleNames",Arg);
    local DragEleList = splitUtils(DragEleNames,",");
    local DragEleCounts = #DragEleList;
    if DragEleCounts <= 0 then
        debug_alert("未设置拖拽监听对象");
        return;
    end;
    --拖拽回调操作对象名称，默认为拖拽对象
    local DragCtrlName = vt("DragCtrlName",Arg);
    if DragCtrlName == "" then
        debug_alert("未设置监听操作对象");
        return;
    end;
    --X轴拖拽方式控制
    local DragXStyleCtrl = vt("DragXStyleCtrl",Arg);
    --Y轴拖拽方式控制
    local DragYStyleCtrl = vt("DragYStyleCtrl",Arg);
    --拖拽回调
    local DragCallFun = vt("DragCallFun",Arg);
    if DragCallFun == "" then
        debug_alert("拖拽回调方法未指定");
        return;
    end;

    if DragCtrlName ~= "" then
        --参数初始化
        AniDragArgList[DragCtrlName] = {
            --拖拽对象名称集合(,分隔)
            DragEleNames = DragEleNames,
            --操作对象名称
            DragCtrlName = DragCtrlName,

            --X轴拖拽方式控制
            DragXStyleCtrl = DragXStyleCtrl,
            --Y轴拖拽方式控制
            DragYStyleCtrl = DragYStyleCtrl,

            --累计在X轴上运动的像素距离
            TotalMoveX = 0,
            --累计在Y轴上运动的像素距离
            TotalMoveY = 0,

            --移动目标的初始位置
            EleStartTop = getEleLocation(DragCtrlName,"top"),
            EleStartLeft = getEleLocation(DragCtrlName,"left"),
            EleHeight = getEleLocation(DragCtrlName,"height"),
            Elewidth = getEleLocation(DragCtrlName,"width"),

            --共计移动次数
            MoveCounts = 0,

            --屏幕高度（按照屏宽比例计算）
            ScreenHeight = systemTable["phoneInfo"].screenUseHeight,
            --屏幕宽度
            ScreenWidth = 375
        };

        for i=1,DragEleCounts do
            --Android针对父控件设置监听，不会映射到子控件，此处批量设置监听，针对多个控件的拖拽动作，操作同一个对象
            gesture:setDragListener(document:getElementsByName(DragEleList[i])[1], lua_format.str2fun(DragCallFun));
        end;
    else
        debug_alert("监听对象未指定");
    end;
end;

--[[预置拖动对象1的拖动回调]]
function drag_ctrl_ele1_call(MoveArg)
    drag_ctrl_ele_call("drag_ctrl_ele1",MoveArg);
end;

--[[预置拖动对象2的拖动回调]]
function drag_ctrl_ele2_call(MoveArg)
    drag_ctrl_ele_call("drag_ctrl_ele2",MoveArg);
end;

--[[预置拖动对象3的拖动回调]]
function drag_ctrl_ele3_call(MoveArg)
    drag_ctrl_ele_call("drag_ctrl_ele3",MoveArg);
end;

--[[预置拖动对象4的拖动回调]]
function drag_ctrl_ele4_call(MoveArg)
    drag_ctrl_ele_call("drag_ctrl_ele4",MoveArg);
end;

--[[预置拖动对象5的拖动回调]]
function drag_ctrl_ele5_call(MoveArg)
    drag_ctrl_ele_call("drag_ctrl_ele5",MoveArg);
end;

--[[预置拖动对象统一回调]]
function drag_ctrl_ele_call(CtrlEleName,MoveArg)
    --获取配置控件的移动参数（由于Android不支持在回调里指定控件名，此处需要根据回调方法来做区分）
    local DragCtrlArg = vt(CtrlEleName,AniDragArgList);
    if DragCtrlArg ~= "" then
        --控件拖拽后的回调
        local EleArg = {
            CtrlEleName = CtrlEleName
        };
        lua_animation.ele_drag_call(MoveArg,EleArg);
    else
        debug_alert("未配置参数");
    end;
end;

--[[控件拖拽后的回调]]
function lua_animation.ele_drag_call(MoveArg,EleArg)
    --当次移动参数
    local MoveArg = formatNull(MoveArg);
    --控件参数
    local EleArg = formatNull(EleArg);
    --控制的控件名
    local CtrlEleName = vt("CtrlEleName",EleArg);

    --获取配置的控件参数
    local AniDragArg = AniDragArgList[CtrlEleName];

    --获取客户端回调时传递的移动坐标（四舍五入）
    local NowMoveX = math.floor(tonumber(vt("x",MoveArg)+0.5));
    local NowMoveY = math.floor(tonumber(vt("y",MoveArg)+0.5));

    --[[debug_alert(
        "控件拖拽后的回调\n"..
        "坐标 : ".."x-"..tostring(NowMoveX).." / ".."y-"..tostring(NowMoveY).."\n"..
        "控件名 : "..CtrlEleName.."\n"..        
        "控件 : "..foreach_arg2print(EleArg).."\n"..
        "参数 : "..foreach_arg2print(AniDragArgList[CtrlEleName]).."\n"..
        ""
    );]]

    --X移动坐标处理，屏幕内自由活动
    if AniDragArg.EleStartLeft+AniDragArg.TotalMoveX+NowMoveX+AniDragArg.Elewidth > AniDragArg.ScreenWidth then
        --alert("超出屏幕右边距");
        --return;
    elseif AniDragArg.EleStartLeft+AniDragArg.TotalMoveX+NowMoveX < 0 then
        --alert("超出屏幕左边距");
        --return;
    else
        AniDragArg.TotalMoveX = NowMoveX+AniDragArg.TotalMoveX;
    end;

    --Y移动坐标处理，屏幕内自由活动
    if AniDragArg.EleStartTop+AniDragArg.TotalMoveY+NowMoveY+AniDragArg.EleHeight > AniDragArg.ScreenHeight-tonumber(get_bottom_diff()) then
        --alert("超出屏幕下边距");
        --return;
    elseif AniDragArg.EleStartTop+AniDragArg.TotalMoveY+NowMoveY < 0+tonumber(get_top_diff()) then
        --alert("超出屏幕上边距");
        --return;
    else
        AniDragArg.TotalMoveY = NowMoveY+AniDragArg.TotalMoveY;
    end;

    --debug_alertToast(tostring(AniDragArg.TotalMoveX).."/"..tostring(AniDragArg.TotalMoveY));

    --X轴移动
    local newLeft = AniDragArg.EleStartLeft+AniDragArg.TotalMoveX;
    if AniDragArg.DragYStyleCtrl == "CloseToLeft" then
        --靠近左侧
        changeStyle(AniDragArg.DragCtrlName,"left","0");
    elseif AniDragArg.DragYStyleCtrl == "CloseToRight" then
        --靠近右侧
        changeStyle(AniDragArg.DragCtrlName,"right","0");
    elseif AniDragArg.DragYStyleCtrl == "CloseToLeftOrRight" then
        --靠近两侧悬停
        changeStyle(AniDragArg.DragCtrlName,"left",newLeft);
        if newLeft < (AniDragArg.ScreenWidth/2) then
            changeStyle(AniDragArg.DragCtrlName,"left","0");
        else
            changeStyle(AniDragArg.DragCtrlName,"right","0");
        end;
    else
        --正常设置
        changeStyle(AniDragArg.DragCtrlName,"left",newLeft);
    end;

    --Y轴移动
    local newTop = AniDragArg.EleStartTop+AniDragArg.TotalMoveY;
    if AniDragArg.DragXStyleCtrl == "CloseToTop" then
        --靠近顶部
        changeStyle(AniDragArg.DragCtrlName,"top",tostring(get_top_diff()));
    elseif AniDragArg.DragXStyleCtrl == "CloseToBottom" then
        --靠近底部
        changeStyle(AniDragArg.DragCtrlName,"bottom","0");
    elseif AniDragArg.DragXStyleCtrl == "CloseToTopOrBottom" then
        --靠近两侧悬停
        changeStyle(AniDragArg.DragCtrlName,"top",newTop);
        if newTop < (AniDragArg.ScreenHeight-get_top_diff())/2 then
            changeStyle(AniDragArg.DragCtrlName,"top",tostring(get_top_diff()));
        else
            changeStyle(AniDragArg.DragCtrlName,"bottom","0");
        end;
    else
        --正常设置
        changeStyle(AniDragArg.DragCtrlName,"top",newTop);
    end;

    --存储移动后的位置
    AniDragArg["EleEndTop"] = newTop;
    AniDragArg["EleEndLeft"] = newLeft;

    AniDragArgList[CtrlEleName] = AniDragArg;
end;

--[[启动纵向循环动画]]
function lua_animation.start_X_loop_animation(Arg)
    --动画对象
    local AnimationElementName = vt("AnimationElementName",Arg);
    --移动距离（像素点）
    local AnimationPX = vt("AnimationPX",Arg,0);
    --动画执行过程中，不重新注册动画
    if vt("AnimationActFlag",globalTable) ~= "start" then
        local MoveDistanceX = 0;
        if AnimationFlg == "left" then
            MoveDistanceX = -AnimationPX;
            AnimationFlg = "right";
        else
            MoveDistanceX = AnimationPX;
            AnimationFlg = "left";
        end;

        --[[debug_alert(
            "启动横向循环动画\n"..
            "y轴移动距离 : "..MoveDistanceX.."\n"..
            ""
        );]]
        local showarg = {
            AnimationElementName=AnimationElementName,
            RunTime="0.3",
            RepeatCounts="1",
            AnimationStyle="X",
            MoveDistanceX=MoveDistanceX,
            AnimationTag="BEGIN",
            AnimationStartLoading="false",
            AnimationStopLoading="false",
            AnimationLocationUpdate="true"
        };
        local registerRes = lua_animation.register(showarg);
        if registerRes ~= "error" then
            --启动动画成功
        end;
    end;
end;

--[[--------------------拖拽动画End--------------------]]