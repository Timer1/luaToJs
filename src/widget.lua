--[[组件相关]]

lua_widget = {};

--[[############################## 滚动指示器 Begin ##############################]]

--当前滚动的位置
C_ScrollIndexNow = 1;
--整个滚动容器个数
C_ScrollIndexMax = 0;

--[[初始化指示器监听]]
function lua_widget.init_scroll_pointer(InitArg)
    --大于1张时
    if C_ScrollIndexMax > 1 then
        local InitArg = formatNull(InitArg);
        local FixedHeight = tonumber(vt("FixedHeight",InitArg,"0"));
        --渲染指示器
        local pointerArg = {
            MaxIndex = C_ScrollIndexMax,
            NowIndex = C_ScrollIndexNow
        };
        lua_widget.render_pointer(pointerArg);

        --设置滚动监听
        local SetArg = {
            eleName="scroll_content_div",
            defaultCall="lua_widget.scroll_listener_call",
            defaultArg=""
        };
        if platform == "Android" then
            local ScrollHeight = tonumber(getEleLocation("scroll_show_content_div","height"));
            local ScreenHeight = tonumber(systemTable["phoneInfo"]["screenUseHeight"]);
            local UseHeight = FixedHeight+ScrollHeight+45;
            local SurHeight = ScreenHeight-UseHeight;

            --[[debug_alert(
                "固定高度 : "..FixedHeight.."\n"..
                "滚动高度 : "..ScrollHeight.."\n"..
                "屏幕高度 : "..ScreenHeight.."\n"..
                "实际高度 : "..UseHeight.."\n"..
                "剩余高度 : "..SurHeight.."\n"..
                ""
            );]]

            --Android X轴手势有冲突，当前页面显示不全时，不添加监听
            if SurHeight > 0 then
                --debug_alert("当前页面高度可以全部显示");
            else
                --debug_alert("当前页面高度不可以全部显示，不建立监听");
                return;
            end;
        end;
        lua_system.set_single_swipe_listener(SetArg);
    else
        --隐藏指示器
        hide_ele("scroll_index_div");
    end;
end;

--[[渲染指示器]]
function lua_widget.render_pointer(PointerArg)
    local ScrollEle = document:getElementsByName("scroll_index_div");
    if #ScrollEle >= 1 then
        local setBorder = "0";

        local MaxIndex = vt("MaxIndex",PointerArg);
        local NowIndex = vt("NowIndex",PointerArg);

        --计算宽度
        local containerWidth = tostring(MaxIndex*21+5);
        local pointerItemHtml = "";

        for i=1,MaxIndex do
            local Icon = "pointer_icon.png";
            if i == 1 then
                Icon = "pointer_light_icon.png";
            end;
            local PointerTouch = "scroll_content_fill("..i..")";
            pointerItemHtml = pointerItemHtml..[[
                <div class="scroll_pointer_icon_div" border="]]..setBorder..[[" onclick="]]..PointerTouch..[[">
                    <img src="local:]]..Icon..[[" class="scroll_pointer_icon" name="scroll_pointer_icon" onclick="]]..PointerTouch..[[" />
                </div>
            ]];
        end;
        local html = [[
            <div class="scroll_index_div" name="scroll_index_div" border="]]..setBorder..[[">
                <div class="scroll_pointer_div" style="width:]]..containerWidth..[[px;" name="scroll_pointer_div" border="]]..setBorder..[[">
                    ]]..pointerItemHtml..[[
                </div>
            </div>
        ]];
        ScrollEle[1]:setInnerHTML(html);
        --控件居中适配
        lua_page.widget_center_adapt("scroll_pointer_div","x","scroll_index_div");

        --指示器高度适配
        lua_system.do_function("scroll_height_adapt","");

        --显示指示器
        show_ele("scroll_index_div");

        page_reload();
    else
        --隐藏指示器
        hide_ele("scroll_index_div");
    end;
end;

--[[指示器滚动]]
function lua_widget.scroll_pointer(DoScrollIndex)
    C_ScrollIndexNow = DoScrollIndex;
    local pointer = document:getElementsByName("scroll_pointer_icon");
    local pointerCounts = #pointer;
    for i=1,pointerCounts do
        if i == C_ScrollIndexNow then
            pointer[i]:setPropertyByName("src","local:pointer_light_icon.png");
        else
            pointer[i]:setPropertyByName("src","local:pointer_icon.png");
        end;
    end;
    page_reload();
end;

--[[统一监听回调]]
function lua_widget.scroll_listener_call(Arg)
    if C_ScrollIndexMax > 1 then
        --debug_alert(foreach_arg2print(Arg));
        local direction = vt("direction",Arg);
        --debug_alert(C_ScrollIndexNow);
        --debug_alert(direction);

        --滚动前保存当前表单
        lua_system.do_function("save_now_form",C_ScrollIndexNow);

        if direction == "right" then
            --前一页（自行实现）
            scroll_last_page();
        elseif direction == "left" then
            --后一页（自行实现）
            scroll_next_page();
        else
            return;
        end;
        --debug_alert(C_ScrollIndexNow);
    else
        --debug_alert("单张滚动不响应");
    end;
end;

--[[############################## 滚动指示器 End ##############################]]

--[[创建状态栏组件]]
function lua_widget.create_process_bar(CreateArg)
    local BarType = vt("BarType",CreateArg);
    local CFunc = vt("ClickFunc",CreateArg);
    local CFuncArg = vt("ClickFuncArg",CreateArg);
    local SetHtml = "";
    if BarType == "ReimbursementByStep" then
        SetHtml = [[
            <div class="process_bar_div" name="process_bar_div" border="0">
                <!-- 灰色背景 -->
                <div class="process_bar_bg_div" border="0" />

                <div class="process_bar_item_div" style="width:51px; left: 8px;" border="0" onclick="]]..CFunc..[[(']]..CFuncArg..[[','001')">
                    <div class="process_bar_icon_div" name="process_bar_icon_div" style="left: 18px;" border="0" />
                    <label class="process_bar_label" name="process_bar_label" value="出行信息" />
                </div>
                <div class="process_bar_item_div" style="width:51px; left: 82px;" border="0" onclick="]]..CFunc..[[(']]..CFuncArg..[[','002')">
                    <div class="process_bar_icon_div" name="process_bar_icon_div" style="left: 18px;" border="0" />
                    <label class="process_bar_label" name="process_bar_label" style="" value="补贴信息" />
                </div>
                <div class="process_bar_item_div" style="width:89px; left: 156px;" border="0" onclick="]]..CFunc..[[(']]..CFuncArg..[[','003')">
                    <div class="process_bar_icon_div" name="process_bar_icon_div" style="left: 38px;" border="0" />
                    <label class="process_bar_label" name="process_bar_label" value="基本及结算信息" />
                </div>
                <div class="process_bar_item_div" style="width:51px; left: 259px;" border="0" onclick="]]..CFunc..[[(']]..CFuncArg..[[','004')">
                    <div class="process_bar_icon_div" name="process_bar_icon_div" style="left: 18px;" border="0" />
                    <label class="process_bar_label" name="process_bar_label" value="补充信息" />
                </div>
                <div class="process_bar_item_div" style="width:26px; right: 20px;" border="0" onclick="]]..CFunc..[[(']]..CFuncArg..[[','005')">
                    <div class="process_bar_icon_div" name="process_bar_icon_div" style="left: 6px;" border="0" />
                    <label class="process_bar_label" name="process_bar_label" value="提交" />
                </div>
            </div>
        ]];
        document:getElementsByName("process_bar_div")[1]:setInnerHTML(SetHtml);
    end;

    if SetHtml ~= "" then
        --当前在第几个标签
        local OptionIndexNow = tonumber(vt("OptionIndexNow",CreateArg,"0"));
        if OptionIndexNow > 0 then
            changeStyleByIndex("process_bar_label",OptionIndexNow,"color","#FE6F14")
        end;

        --当前已经完成的标签
        local OptionSavedIndexs = vt("OptionSavedIndexs",CreateArg);
        local array = splitUtils(OptionSavedIndexs,",");
        if #array > 0 then
            for i=1,#array do
                local setIndex = array[i];
                local setIndexMax = 0;
                if BarType == "ReimbursementByStep" then
                    setIndexMax = 5;
                end;
                if setIndex~="" and setIndex~="," and tonumber(setIndex)<=setIndexMax then
                    --debug_alert(setIndex);
                    changeStyleByIndex("process_bar_icon_div",tonumber(setIndex),"background-image","process_bar_finish_icon.png")
                end;
            end;
        end;
        page_reload();
    else
        debug_alert("状态栏未渲染");
    end;
end;
