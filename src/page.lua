--[[页面处理]]

lua_page = {};

--[[
    通过setInnerHTML实现创建页面顶部Bar，页面需要预置如下头部栏
    <div class="top_div_#{=systemTable['SysLayoutStyle']}#" border="0" name="top_all_div" />

    bar_back_fun:
        返回按钮的事件，可以指定，默认为back_fun();

    bar_center_type:头部中间类型 默认为标题栏
        标题栏 : title_bar
        搜索栏 : search_bar（不控制输入）
                 search_bar-N（只能输入整数）
                 search_bar-n（只能输入整数和.）
    bar_center_text:
        显示在bar中间的文字信息，标题栏和搜索栏上限均为10个字
        标题栏默认为“标题”，搜索栏默认为“请输入关键字进行搜索”
    bar_center_fun:
        搜索栏时，onchange调用，标题栏时，onclick调用，默认为空

    bar_right_type:默认为空
        文字 : label_bar
        筛选 : filt_bar
        搜索 : search_bar
        菜单 : menu_bar
    bar_right_text:
        显示在bar右侧的文字信息
        ·文字label_bar文字上限4个
        ·筛选filt_bar文字上限2个
        ·搜索search_bar不可放文字
    bar_right_fun:
        均为onclick调用，默认为空
    bar_top_name:
        头控件容器的name值，创建多个头时可以在外层指定
    bar_close_fun:
        头部添加一个关闭按钮，指定关闭按钮的点击事件，特定的webview使用（用车）
]]

--[[旧方法]]
function create_page_title(bar_back_fun, bar_center_type_arg, bar_center_text, bar_center_fun, bar_right_type, bar_right_text, bar_right_fun, bar_top_name, bar_close_fun)
    local createArg = {
        bar_back_fun=bar_back_fun,
        bar_center_type_arg=bar_center_type_arg,
        bar_center_text=bar_center_text,
        bar_center_fun=bar_center_fun,
        bar_right_type=bar_right_type,
        bar_right_text=bar_right_text,
        bar_right_fun=bar_right_fun,
        bar_top_name=bar_top_name,
        bar_close_fun=bar_close_fun
    };
    lua_page.do_create_top(createArg);
end;

--[[封装新方法]]
function lua_page.create_top(createArg)
    lua_page.do_create_top(createArg);
end;

--[[创建页面头]]
function lua_page.do_create_top(createArg)
    --默认值处理
    local bar_back_fun = vt("bar_back_fun", createArg, "back_fun()");
    local bar_close_fun = vt("bar_close_fun", createArg);
    --获取title类型参数
    local bar_center_type_arg = vt("bar_center_type_arg", createArg, "title_bar");
    --获取title类型参数
    local bar_center_type_arg_split = splitUtils(bar_center_type_arg,"-");
    --title类型
    local bar_center_type = bar_center_type_arg_split[1];
    --title输入样式
    local bar_center_input_style = bar_center_type_arg_split[2];
    --title标签名
    local bar_center_name = vt("bar_center_name", createArg, "JJBX_titleName");
    --title文字
    local bar_center_text = vt("bar_center_text", createArg);
    --title方法
    local bar_center_fun = vt("bar_center_fun", createArg);
    if bar_center_type == "search_bar" then
        --设置默认文字
        bar_center_text = formatNull(bar_center_text,C_SearchKeyWords);
    else
        bar_center_text = formatNull(bar_center_text);
        bar_center_fun = "";
        --debug关闭的情况下，文字标题栏不添加响应事件
        if configTable["lua_debug"] == "true" then
            bar_center_fun = "lua_debug.reload_page()";
        end;
    end;

    --title右侧类型
    local bar_right_type = vt("bar_right_type", createArg);
    --title右侧文字
    local bar_right_text = vt("bar_right_text", createArg);
    if bar_right_type == "label_bar" then
        bar_right_text = bar_right_text;
    elseif bar_right_type == "filt_bar" then
        bar_right_text = formatNull(bar_right_text,"筛选");
    elseif bar_right_type == "search_bar" then
        bar_right_text = "";
    elseif bar_right_type == "icon_bar" then
        --显示图标
    else
        bar_right_text = "";
    end;
    local bar_right_fun = vt("bar_right_fun", createArg);
    local bar_top_name = vt("bar_top_name", createArg, "top_all_div");

    --debug_alert("create page title arg\n"..foreach_arg2print(createArg));

    --边框设置
    local border = "0";
    --开始标签
    local htmlBegin = [[
        <div class="top_div_]]..systemTable['SysLayoutStyle']..[[" border="]]..border..[[" name="]]..bar_top_name..[[">
            <div class="top_div" border="]]..border..[[">
    ]];
    --结束标签
    local htmlEnd = [[
            </div>
        </div>
    ]];
    --标题内容
    local htmlContent = "";

    --左侧内容
    local titleHtmlLeft = "";
    --中间内容
    local titleHtmlCenter = "";
    --右侧内容
    local titleHtmlRight = "";

    --关闭按钮
    local titleCloseHtml = "";
    if bar_close_fun ~= "" then
        titleCloseHtml = [[
            <div class="closebtn_click_div" name="closebtn_click_div" border="]]..border..[[" onclick="]]..bar_close_fun..[[">
                <img class="closebtn_click_img" name="closebtn_click_img" src="local:close_topBar.png" onclick="]]..bar_close_fun..[[" />
            </div>
        ]];
    end;

    --设置左侧内容（返回按钮、webview关闭按钮、返回按钮文字）
    if bar_back_fun ~= "none" then
        titleHtmlLeft = [[
            <div class="backbtn_div" name="common_titile_backbtn_div" border="]]..border..[[" onclick="]]..bar_back_fun..[[">
                <div class="backbtn_click_div" name="backbtn_click_div" border="]]..border..[[" onclick="]]..bar_back_fun..[[">
                    <img class="backbtn_click_img" name="backbtn_click_img" src="local:arrow_topBar.png" onclick="]]..bar_back_fun..[[" />
                </div>
                ]]..titleCloseHtml..[[
                <label class="backbtn_click_label" name="backbtn_click_label" value="" onclick="]]..bar_back_fun..[[" />
            </div>
        ]];
    end;

    --判断右侧是否有内容，根据内容长短定义右侧层的样式
    local TopSearchTextDivStyle = "top_search_text_div";
    local TopSearchTextStyle = "top_search_text";
    local TopSearchDivStyle = "top_search_div";
    local TopSearchRightLabelDivStyle = "head_right_label4_div";

    --设置中间内容
    if bar_center_type == "search_bar" then
        --初始化搜索栏的输入类型
        local InputStyle = "";
        if bar_center_input_style == "N" then
            InputStyle = "style=\"-wap-input-format:'N'\"";
        elseif bar_center_input_style == "n" then
            InputStyle = "style=\"-wap-input-format:'n'\"";
        end;
        --debug_alert(InputStyle);

        if bar_right_type == "" then
            --没有内容搜索控件给为全屏长度
            TopSearchTextDivStyle = "top_search_full_text_div";
            TopSearchTextStyle = "top_search_full_text";
            TopSearchDivStyle = "top_search_full_div";
            TopSearchRightLabelDivStyle = "head_right_label4_div";
        elseif bar_right_type == "label_bar" then
            --当为labelbar的时候，要判断字符长度
            local labelLength = ryt:getLengthByStr(bar_right_text);
            --debug_alert("labelLength:"..labelLength);
            if labelLength == 2 then
                TopSearchTextDivStyle = "top_search_label2_text_div";
                TopSearchTextStyle = "top_search_label2_text";
                TopSearchDivStyle = "top_search_label2_div";
                TopSearchRightLabelDivStyle = "head_right_label2_div";
            elseif labelLength == 3 then
                TopSearchTextDivStyle = "top_search_label3_text_div";
                TopSearchTextStyle = "top_search_label3_text";
                TopSearchDivStyle = "top_search_label3_div";
                TopSearchRightLabelDivStyle = "head_right_label3_div";
            else
                --使用默认样式
            end;
        elseif bar_right_type == "menu_bar" then
            TopSearchTextDivStyle = "top_search_label2_text_div";
            TopSearchTextStyle = "top_search_label2_text";
            TopSearchDivStyle = "top_search_label2_div";
            TopSearchRightLabelDivStyle = "head_right_label2_div";
        else
            --使用默认样式
        end;

        titleHtmlCenter = [[
            <div class="]]..TopSearchDivStyle..[[" name="top_search_div" border="1" cornerRadius="16">
                <img src="local:search_icon.png" class="top_search_icon" name="top_search_icon" />
                <div class="]]..TopSearchTextDivStyle..[[" border="]]..border..[[">
                    <input type="text" class="]]..TopSearchTextStyle..[[" name="top_search_text" ]]..InputStyle..[[ holdColor="#9B9B9B" hold="]]..C_SearchContextBegin..bar_center_text..C_SearchContextEnd..[[" border="]]..border..[[" value="" onchange="]]..bar_center_fun..[[" />
                </div>
            </div>
        ]];
    else
        local bar_center_icon_fun = vt("bar_center_icon_fun", createArg);
        local bar_center_icon = vt("bar_center_icon", createArg);

        local bar_center_icon_html = "";
        if bar_center_icon ~= "" then
            bar_center_icon_html = [[
                <div class="head_title_icon_div" name="head_title_icon_div" border="]]..border..[[" onclick="]]..bar_center_icon_fun..[[">
                    <img class="head_title_icon_]]..systemTable['SysLayoutStyle']..[[" name="head_title_icon" src="local:]]..bar_center_icon..[[" onclick="]]..bar_center_icon_fun..[[" />
                </div>
            ]];
        end;

        --其他均为标题栏
        titleHtmlCenter = [[
            <div class="head_title_div" name="head_title_div" border="]]..border..[[" onclick="]]..bar_center_fun..[[">
                <label class="head_title_label" value="]]..bar_center_text..[[" name="]]..bar_center_name..[["/>
                ]]..bar_center_icon_html..[[
            </div>
        ]];
    end;

    --设置右侧内容
    if bar_right_type == "label_bar" then
        titleHtmlRight = [[
            <div class="]]..TopSearchRightLabelDivStyle..[[" name="head_right_label_div" border="]]..border..[[" onclick="]]..bar_right_fun..[[">
                <label class="head_right_label" name="head_right_label" value="]]..bar_right_text..[[" onclick="]]..bar_right_fun..[[" />
            </div>
        ]];
    elseif bar_right_type == "filt_bar" then
        titleHtmlRight = [[
            <div class="head_filt_div" name="head_filt_div" onclick="]]..bar_right_fun..[[" border="]]..border..[[">
                <img class="head_filt_img" name="head_filt_img" src="local:filter.png" onclick="]]..bar_right_fun..[[" />
                <label class="head_filt_label" name="head_filt_label" onclick="]]..bar_right_fun..[[" value="]]..bar_right_text..[["/>
            </div>
        ]];
    elseif bar_right_type == "search_bar" then
        titleHtmlRight = [[
            <div class="head_search_div" name="head_search_div" onclick="]]..bar_right_fun..[[" border="]]..border..[[">
                <img class="head_search_img" name="head_search_img" src="local:search.png" onclick="]]..bar_right_fun..[[" />
            </div>
        ]];
    elseif bar_right_type == "menu_bar" then
        if formatNull(globalTable["rightMenuFlag"],"true") == "true" then
            titleHtmlRight = [[
                <div class="head_menu_div" name="head_menu_div" onclick="]]..bar_right_fun..[[" border="]]..border..[[">
                    <img class="head_menu_img" name="head_menu_img" src="local:menu_bar_white.png" onclick="]]..bar_right_fun..[[" />
                </div>
            ]];
        else
            titleHtmlRight = "";
        end;
        globalTable["rightMenuFlag"] = "true";
    elseif bar_right_type == "icon_bar" then
        local bar_right_icon = vt("bar_right_icon",createArg);
        titleHtmlRight = [[
            <div class="head_rt_icon_div" name="head_rt_icon_div" onclick="]]..bar_right_fun..[[" border="]]..border..[[">
                <img class="head_rt_icon_img_]]..systemTable['SysLayoutStyle']..[[" name="head_rt_icon_img" src="local:]]..bar_right_icon..[[" onclick="]]..bar_right_fun..[[" />
                <label class="head_rt_icon_label" name="head_rt_icon_label" onclick="]]..bar_right_fun..[[" value="]]..bar_right_text..[["/>
            </div>
        ]];
    elseif bar_right_type == "image_bar" then
        local bar_right_image = vt("bar_right_image",createArg);
        titleHtmlRight = [[
            <div class="head_rt_icon_div" name="head_rt_image_div" onclick="]]..bar_right_fun..[[" border="]]..border..[[">
                <img class="head_rt_image_]]..systemTable['SysLayoutStyle']..[[" name="head_rt_image" src="local:]]..bar_right_image..[[" onclick="]]..bar_right_fun..[[" />
            </div>
        ]];
    else
        titleHtmlRight = "";
    end;
    --title内容
    htmlContent = titleHtmlLeft..titleHtmlCenter..titleHtmlRight;

    local top_div_elements = document:getElementsByName(bar_top_name);
    if #top_div_elements < 1 then
        debug_alert("标题未定义 : "..bar_top_name);
        return;
    else
        --开始创建头，部分页面复用两个头，可以创建多个
        for i=1,#top_div_elements do
            --debug_alert(i);
            top_div_elements[i]:setInnerHTML(htmlBegin..htmlContent..htmlEnd);
        end;
        --页面刷新
        page_reload();

        --页面说明
        local page_explain = vt("page_explain", createArg);
        --页面统一埋点信息
        local ReportPageName = "";
        if page_explain ~= "" then
            --优先取页面说明字段
            if page_explain == "None" then
                --不登记页面
            else
                ReportPageName = page_explain;
            end;
        else
            --默认埋点只针对标题栏进行处理
            if bar_center_type == "title_bar" then
                --过滤掉空字符串
                local prepare_center_text = string.gsub(bar_center_text," ","");
                if prepare_center_text ~= "" then
                    ReportPageName = prepare_center_text;
                end;
            end;
        end;

        --页面信息不为空时埋点
        if ReportPageName ~= "" then
            --获取当前页面地址
            local CurrentPageInfo = lua_page.current_page_info();
            local PageFilePath = vt("page_file_path",CurrentPageInfo);
            --页面数据上报
            local reportArg = {
                Event="JJBXAppOpenAppPage",
                PageUrl=PageFilePath,
                PageName=ReportPageName
            };
            lua_system.sensors_report(reportArg);
        end;

        --lua调试
        if configTable["lua_debug"] == "true" then
            if history:length() > 2 then
                --debug_alert("调试模式，缓存页面数较多时，设置长按监听，返回首页");
                set_longtap_listener("common_titile_backbtn_div","lua_debug.alert_menu","");
            end;
        end;
    end;
end;

--[[更新头部标题图标位置]]
function lua_page.update_top(updateArg)
    local updateTarget = vt("updateTarget",updateArg);
    if updateTarget == "title_icon" then
        --文字内容
        local headTitleLabelContent = formatNull(getValue("JJBX_titleName","0"),"消息中心");
        --文字宽度
        local headTitleLabelWidth = tonumber(calculate_text_width(headTitleLabelContent,"17"));
        --文字容器宽度
        local headTitleDivWidth = 235;
        --图标容器宽度
        local headTitleIconDivWidth = 40;
        --图标容器调整距离（右侧）
        local headTitleIconRightTrim = 5;
        --图标容器实际距离（右侧）
        local headTitleIconRight = tostring((headTitleDivWidth-headTitleLabelWidth)/2-headTitleIconDivWidth+headTitleIconRightTrim);

        --[[debug_alert(
            "标题动态调整\n"..
            "文字内容 : "..headTitleLabelContent.."\n"..
            "文字宽度 : "..headTitleLabelWidth.."\n"..
            "文字容器宽度 : "..headTitleDivWidth.."\n"..
            "图标容器宽度 : "..headTitleIconDivWidth.."\n"..
            "图标容器调整距离（右侧） : "..headTitleIconRightTrim.."\n"..
            "图标容器实际距离（右侧） : "..headTitleIconRight.."\n"..
            ""
        );]]

        --设置图标容器实际距离（右侧）
        changeStyle("head_title_icon_div","right",headTitleIconRight);
        page_reload();
    end;
end;

--[[定义一些常用的title]]

--[[
    创建通用标题栏，包含标题和返回键
    传标题文字 返回方法
    返回方法默认back_fun 不需要重写的情况下不需要传
    头部名称默认top_all_div 不需要指定的情况下不需要传
]]
function title_head(titletext, backfun, topname)
    create_page_title(backfun, "title_bar", titletext, "", "", "", "", topname);
end;

--[[
    创建搜索栏，包含搜索和返回键，onchange事件调用
    传搜索框文字 onchange事件
    返回方法默认back_fun 不需要重写的情况下不需要传
    头部名称默认top_all_div 不需要指定的情况下不需要传
]]
function search_head(titletext, serachfun, topname)
    create_page_title("", "search_bar", titletext, serachfun, "", "", "", topname);
end;

--[[
    创建通用标题栏，包含标题和返回键，右侧有文字按钮
    传标题文字 右侧按钮文字 右侧按钮事件
]]
function right_label_head(titletext, righttext, rightfun, topname)
    create_page_title("", "title_bar", titletext, "", "label_bar", righttext, rightfun, topname);
end;

--[[
    创建通用标题栏，包含标题和返回键，右侧有搜索按钮
    传标题文字 右侧搜索按钮事件
]]
function right_search_head(titletext, rightfun, topname)
    create_page_title("", "title_bar", titletext, "", "search_bar", "", rightfun, topname);
end;

--[[
    创建通用标题栏，包含标题和返回键，右侧有筛选按钮
    传标题文字 右侧筛选按钮事件
]]
function right_filt_head(titletext, righttext, rightfun, topname)
    create_page_title("", "title_bar", titletext, "", "filt_bar", righttext, rightfun, topname);
end;

--[[标识div是否已经弹出,true:弹出状态，false:未弹出状态]]
isShowContent = false;
--[[弹出层的下]]
showContentIndex = 1;

--[[
    弹出指定的DIV
    index       : 下标
    elementName : 控件名
    refreshpage : 是否需要刷新页面
]]
function jjbx_utils_showContent(index,elementName,refreshpage)
    local refreshpage = formatNull(refreshpage, "true");
    showContentIndex = tonumber(index);

    if isShowContent then
        isShowContent = false;
        window:hide(showContentIndex);
        if refreshpage == "true" then
            --关闭后需要对body进行重新适配
            height_adapt("body",0,0);
        end;
    else
        isShowContent = true;
        local showDiv = document:getElementsByName(elementName);
        if refreshpage == "true" then
            height_adapt(elementName,0,0);
        end;
        --弹出div，这里Android客户端不需要适配到顶部，从状态栏往下开始适配即可
        window:showControl(showDiv[1],showContentIndex);
    end;
end;

--[[
    隐藏指定的DIV
    refreshpage : 关闭后是否刷新页面
    doback      : 没有弹出层的时候，是否调用返回
]]
function jjbx_utils_hideContent(refreshpage, doback)
    local refreshpage = formatNull(refreshpage, "true");
    local doback = formatNull(doback, "true");
    if isShowContent then
        window:hide(showContentIndex);
        isShowContent = false;
        if refreshpage == "true" then
            height_adapt("body",0,0);
            page_reload();
        end;
    else
        if doback == "true" then
            back_fun();
        end;
    end;
    
    --回收键盘
    lua_system.hide_keyboard();
end;

--[[
    高度适配，状态栏高度给定
    name      : 控件名
    fixheight : 已知的控件高度
    topheight : 头部的高度差，不指定取默认
    doflag    : 操作类型 calculate(仅计算) adapt(计算并且适配)

    调用示例:
      区分状态栏:
        默认状态栏高度20:height_adapt("list", 50)
        指定状态栏高度30:height_adapt("list", 50, 30)
        指定状态栏高度0:height_adapt("list", 50, 0)
]]
function height_adapt(name, fixheight, topheight, doflag)
    --如果外层没有指定上方容器的高度值，设置默认适配头高度
    local fixheight = formatNull(fixheight,C_TopHeight);
    --设置状态栏高度差
    local topheight = formatNull(topheight,get_top_diff());
    --操作类型
    local doflag = formatNull(doflag,"adapt");
    --操作类型为calculate时，需要将结果返回
    local res = prepare2do_height(name, fixheight, topheight, doflag);
    res = formatNull(res);

    --调试信息
    --[[if globalTable["ShowAdaptMsg"] == "true" then
        debug_alert(
            "高度适配-头部、底部计算\n"..
            "name:"..name.."\n"..
            "fixheight:"..fixheight.."\n"..
            "topheight:"..topheight.."\n"..
            "doflag:"..doflag.."\n"..
            "res:"..res.."\n"..
            ""
        );
    end;]]

    return res;
end;

--[[根据机型计算头部高度并调用高度适配]]
function prepare2do_height(name, fixheight, topheight, doflag)
    --适配高度为去掉头部和底部的高度
    local adapt_height = fixheight + topheight;
    --通过屏幕比例计算后转换回的高度
    local real_adapt_height = calculate_height_by_screen_ratio(adapt_height,name);

    --调试信息
    --[[if globalTable["ShowAdaptMsg"] == "true" then
        debug_alert(
            "高度适配-通过比例转换计算结果\n"..
            "fixheight:"..fixheight.."\n"..
            "topheight:"..topheight.."\n"..
            "doflag:"..doflag.."\n"..
            "\n"..
            "name:"..name.."\n"..
            "adapt_height:"..adapt_height.."\n"..
            "real_adapt_height:"..real_adapt_height.."\n"..
            ""
        );
    end;]]

    if doflag == "calculate" then
        --只计算的情况下直接返回适配计算结果
        return real_adapt_height;
    else
        --执行适配
        do_height_adapt(name, real_adapt_height);
    end;
end;

--[[
    根据屏幕比例计算实际适配高度
    fix_height : 页面已知的高度信息，基于375*667的比例
]]
function calculate_height_by_screen_ratio(fix_height,widget_name)
    local fix_height = tonumber(formatNull(fix_height,"0"));

    --根据底部状态获取底部高度差
    local bottomheight = tonumber(get_bottom_diff());
    --固定高度需要加上底部高度
    local use_fix_height = fix_height+bottomheight;

    --执行修改高度
    local do_adapt_height = 0;

    local widget_name = formatNull(widget_name);
    local screen_width = systemTable["phoneInfo"].screenWidth;
    local width_ratio = systemTable["phoneInfo"].widthRatio;
    local screen_height = systemTable["phoneInfo"].screenHeight;
    local height_ratio = systemTable["phoneInfo"].heightRatio;
    local screen_configured = systemTable["phoneInfo"].screenConfigured;

    local base_msg =
        "高度适配-通过比例转换计算过程\n"..
        "适配控件:"..widget_name.."\n"..
        "\n"..
        "基本信息\n"..
        "－－－－－－－－－－\n"..
        "已知高度:"..use_fix_height.."px\n"..
        "底部高度:"..bottomheight.."px\n"..
        "屏宽:"..screen_width.." ".."屏高:"..screen_height.."\n"..
        "屏宽比:"..width_ratio.." ".."屏高比:"..height_ratio.."\n"..
        "是否已知:"..screen_configured.."\n"..
        "\n";
    local cal_adapt_msg = "";

    --固定高度为0时为全屏计算，无需计算，直接按照比例折算即可
    if tonumber(fix_height)==0 then
        local adapt_screen_height = float((screen_height-bottomheight)/width_ratio,4);
        cal_adapt_msg =
            "全屏适配不计算\n"..
            "屏幕高度:"..screen_height.."\n"..
            "底部高度:"..bottomheight.."\n"..
            "适配高度/屏宽比:"..adapt_screen_height.."\n"..
            "\n";
        do_adapt_height = adapt_screen_height;
    else
        local real_height = float(screen_height/width_ratio,4);
        local adapt_height = float(real_height-use_fix_height,4);

        cal_adapt_msg =
            "计算信息\n"..
            "－－－－－－－－－－\n"..
            "全屏高度(屏高*屏宽比):"..real_height.."\n"..
            "剩余屏高:"..adapt_height.."\n"..
            "\n";
        do_adapt_height = adapt_height;
    end;

    local do_adapt_msg =
        "执行适配\n"..
        "－－－－－－－－－－\n";

    if do_adapt_height <= 0 then
        do_adapt_height = 1;
        do_adapt_msg = do_adapt_msg.."高度为0，适配为1个像素";
    else
        --分辨率支持的设备向上取整，其他设备向下取整
        if screen_configured == "true" then
            do_adapt_height = math.ceil(do_adapt_height);
        else
            do_adapt_height = math.floor(do_adapt_height);
        end;

        do_adapt_msg = do_adapt_msg.."执行修改高度:"..do_adapt_height;
    end;

    --调试信息
    if globalTable["ShowAdaptMsg"] == "true" then
        debug_alert(base_msg..cal_adapt_msg..do_adapt_msg);
    end;

    --返回实际适配高度
    return do_adapt_height;
end;

--[[列表页面的高度适配]]
function do_height_adapt(widget_name, real_adapt_height)
    --控件名
    local widget_name = formatNull(widget_name);
    --页面已知的高度信息
    local real_adapt_height = formatNull(real_adapt_height);

    --[[debug_alert(
        "控件名称 : "..widget_name.."\n"..
        "适配高度 : "..real_adapt_height.."\n"..
        ""
    );]]

    changeStyle(widget_name,"height",real_adapt_height);
    location:reload();
end;

--[[获取控件位置信息，同名控件只获取第一个]]
function getEleLocation(element, locTag)
    local element = formatNull(element)
    local locTag = formatNull(locTag);
    local res = "";

    if element~="" and locTag~="" then
        local element = formatNull(document:getElementsByName(element)[1]);
        if element ~= "" then
            local location = element:getStyleByName(locTag);
            res = px2num(location);
        end;
    end;

    --[[debug_alert(
        "getEleLocation\n"..
        "element : "..element.."\n"..
        "locTag : "..locTag.."\n"..
        "res : "..res.."\n"..
        ""
    );]]

    return res;
end;

--[[设置控件位置信息，同名控件只设置第一个]]
function setEleLocation(element, locTag, locValue)
    local element = formatNull(element)
    local locTag = formatNull(locTag);
    local locValue = formatNull(locValue);

    --[[debug_alert(
        "setEleLocation\n"..
        "element : "..element.."\n"..
        "locTag : "..locTag.."\n"..
        "locValue : "..locValue.."\n"..
        ""
    );]]

    if element~="" and locTag~="" and locValue~="" then
        local element = document:getElementsByName(element)[1];
        element:setStyleByName(locTag,tostring(locValue).."px");
    end;
end;

--[[
    获取当前控件的父控件对象,通过对象方法从结果里拿取需要的数据
    例如 : parentWidget:getPropertyByName("name"));
]]
function getParentWidget(childrenWidgetName)
    local childrenWidgetName = formatNull(childrenWidgetName);
    local parentWidget = "";

    if childrenWidgetName ~= "" then
        childrenEle = document:getElementsByName(childrenWidgetName)[1];
        parentWidget = childrenEle:getParent();
    end;

    return parentWidget;
end;

--[[
    获取当前控件的所有子节点控件对象集合，结果可以通过循环拿取需要的数据
    例如 : childrenWidgetList[1]:getPropertyByName("name"); 可以获取第一个子控件的控件名
]]
function getChildrenWidgetList(parentWidgetName)
    local parentWidgetName = formatNull(parentWidgetName);
    local childrenWidgetList = "";
    if parentWidgetName ~= "" then
        parentEle = document:getElementsByName(parentWidgetName)[1];
        childrenWidgetList = parentEle:getChildren();
    end;
    return childrenWidgetList;
end;

--[[获取控件的value值]]
function getValue(name,debugFlag)
    local element = document:getElementsByName(name)[1];
    if element == "" or element == nil then
        local debugFlag = formatNull(debugFlag,"1");
        if debugFlag ~= "0" then
            debug_alert("name="..name.."的控件不存在!");
        end;
        return "";
    else
        local res = element:getPropertyByName("value");
        return formatNull(res);
    end;
end;

--[[changeProperty后刷新]]
function changePropertyReload(name,property,newValue,index)
    changeProperty(name,property,newValue,index)
    page_reload();
end;
--[[封装setPropertyByName方法]]
function changeProperty(name,property,newValue,index)
    --[[debug_alert(
        "changeProperty\n"..
        "name : "..formatNull(name).."\n"..
        "property : "..formatNull(property).."\n"..
        "newValue : "..formatNull(newValue).."\n"..
        ""
    );]]

    local ctrl = document:getElementsByName(name);
    if ctrl and #ctrl > 0 then
        local index = formatNull(index,"1");
        ctrl[tonumber(index)]:setPropertyByName(property,newValue);
    end;
end;
function changeAllProperty(name,property,newValue)
    local ctrl = document:getElementsByName(name);
    if ctrl and #ctrl > 0 then
        for i=1,#ctrl do
            ctrl[i]:setPropertyByName(property,newValue);
        end;
    end;
end;

--[[
    封装setStyleByName:getStyleByName方法，获取第一个对象的样式
    widgetName : 控件名
    styleName  : 样式名
]]
function getStyle(widgetName,styleName)
    local res = "";

    local widgetName = formatNull(widgetName);
    local styleName = formatNull(styleName);

    if widgetName~="" and styleName~="" then
        local StyleValue = document:getElementsByName(widgetName)[1]:getStyleByName(styleName);
        res = formatNull(StyleValue);
    end;

    return res;
end;

--[[changeStyle后刷新]]
function changeStyleReload(name,style,value)
    changeStyle(name,style,value);
    page_reload();
end;
--[[封装setStyleByName方法]]
function changeStyle(name,style,value)
    local ctrl = document:getElementsByName(name);
    if ctrl and #ctrl > 0 then
        ctrl[1]:setStyleByName(style,value);
    end;
end;
--[[更新全部样式]]
function changeAllStyle(name,style,value)
    local ctrl = document:getElementsByName(name);
    if ctrl and #ctrl > 0 then
        for i=1,#ctrl do
            ctrl[i]:setStyleByName(style,value);
        end;
    end;
end;
--[[更新指定下标的样式]]
function changeStyleByIndex(name,Index,style,value)
    local ctrl = document:getElementsByName(name);
    if ctrl and #ctrl >= tonumber(Index) then
        ctrl[tonumber(Index)]:setStyleByName(style,value);
    end;
end;

--[[显示控件]]
function show_ele(name)
    changeStyle(name,"display","block");
end;

--[[批量显示控件]]
function batch_show_ele(namelist)
    local namelist = formatNull(namelist);

    if namelist == "" then
        debug_alert("参数为空");
    else
        --通过,将控件名转换为数组
        local array = splitUtils(namelist,",");
        if #array < 1 then
            debug_alert("控件集合为空");
        else
            for i=1,#array do
                local name = formatNull(array[i]);
                show_ele(name);
            end;
        end;
    end;
end;

--[[批量显示控件]]
function show_eles(name)
    changeAllStyle(name,"display","block");
end;

--[[隐藏控件]]
function hide_ele(name)
    changeStyle(name,"display","none");
end;

--[[批量隐藏控件]]
function batch_hide_ele(namelist)
    local namelist = formatNull(namelist);

    if namelist == "" then
        debug_alert("参数为空");
    else
        --通过,将控件名转换为数组
        local array = splitUtils(namelist,",");
        if #array < 1 then
            debug_alert("控件集合为空");
        else
            for i=1,#array do
                local name = formatNull(array[i]);
                hide_ele(name);
            end;
        end;
    end;
end;

--[[批量隐藏控件]]
function hide_eles(name)
    changeAllStyle(name,"display","none");
end;

--[[获取单选按钮已选择的按钮下标，返回下标，类型为string]] 
function jjbx_utils_getRadioButtonState(elementName,imageName)
    local elements = document:getElementsByName(elementName);
    local imageName = formatNull(imageName,"btn_apply.png");
    local bacImage = "";
    local tempIndex = "";
    for i=1,#elements do
        bacImage = elements[i]:getStyleByName("background-image");
        if bacImage == imageName then
            tempIndex = tostring(i);
        end;
    end;
    return tempIndex;
end;

--[[
    index: 需要返回页面的指定栈值，可不传
    index不为空时，跳转至指定栈值的页面
    index为空时，返回到上一个页面
    LoadingFlag:控制加载狂
        ·"1": 默认效果，点击返回后打开，页面替换完成后关闭
        ·"2"：点击返回后打开，页面替换完成后不主动关闭，需要在页面自行实现loading关闭
        ·"3"：全程无loading效果
        ·open：返回到上一页后，是否关闭loading
    CloseLoading参考使用场景：
        1、返回上一页，页面初始化请求没有加loading的。
        2、上一个页面请求过程中，页面不允许点击的。
]]
function back_fun(index, LoadingFlag, JumpStyle)
    local index = formatNull(index);
    local LoadingFlag = formatNull(LoadingFlag,"2");
    --页面跳转类型，默认为右侧切入
    local JumpStyle = formatNull(JumpStyle,"left");
    --栈值
    local HistoryLength = tonumber(history:length());

    --[[debug_alert(
        "back_fun\n"..
        "index:"..index.."\n"..
        "LoadingFlag:"..LoadingFlag.."\n"..
        "JumpStyle:"..JumpStyle.."\n"..
        ""
    );]]

    --页面有弹出层时（调用了jjbx_utils_showContent方法）执行隐藏弹出层操作，不做直接返回
    if isShowContent then
        --debug_alert("页面有弹出层时（调用了jjbx_utils_showContent方法）执行隐藏弹出层操作，不做直接返回");
        jjbx_utils_hideContent();
    else
        --页面属性初始化
        page_sys_init();

        if HistoryLength == 1 then
            --返回时候，如果当前页面为底栈，这时重新请求首页
            lua_menu.to_index_page("back");
        else
            --打开loading
            if LoadingFlag == "1" or LoadingFlag == "2" then
                show_loading();
            else
                close_loading();
            end;

            local page = "";
            if index ~= "" then
                page = history:get(tonumber(index));
            else
                page = history:get(-1);
            end;
            local afterpage = slt2.render(slt2.loadstring(page),nil);

            local CloseLoading = "false";
            if LoadingFlag == "1" or LoadingFlag == "3" then
                --回调里关闭loading
                CloseLoading = "true";
            end;

            --通过跳转样式指定页面切换方式的参数
            local UseJumpStyle = page_jump_style(JumpStyle);
            location:replace(afterpage, UseJumpStyle, replace_callback, {CloseLoading=CloseLoading});
        end;
    end;
end;

--[[通过跳转样式指定页面切换方式的参数]]
function page_jump_style(JumpStyle)
    local UseJumpStyle = {};
    if JumpStyle == "left" then
        UseJumpStyle = transitionType.slideFromLeft;
    elseif JumpStyle == "right" then
        UseJumpStyle = transitionType.slideFromRight;
    elseif JumpStyle == "up" then
        UseJumpStyle = transitionType.curlUp;
    elseif JumpStyle == "down" then
        UseJumpStyle = transitionType.curlDown;
    elseif JumpStyle == "none" then
        UseJumpStyle = {}
    end;

    return UseJumpStyle;
end;

--[[不展示loading的返回]]
function back_fun_noloading(index)
    back_fun(index,"3");
end;

--[[不关闭loading的返回]]
function back_fun_loading(index)
    back_fun(index,"2");
end;

--[[返回指定栈值页面]]
function back_fun_getHistory(historyIndex)
    --debug_alert("back_fun_getHistory");
    local historyIndex = formatNull(historyIndex);
    if historyIndex == "" then
        --默认返回上一个页面
        historyIndex = history:length()-1;
    end;

    --页面有弹出层时（调用了jjbx_utils_showContent方法）执行隐藏弹出层操作，不做直接返回
    if isShowContent then
        jjbx_utils_hideContent();
    else
        --页面属性初始化
        page_sys_init();

        show_loading();
        local page = history:get(historyIndex);
        local afterpage = slt2.render(slt2.loadstring(page),nil);
        location:replace(afterpage, transitionType.slideFromLeft, replace_callback,{CloseLoading="true"});
    end;
end;

--[[
    计算控件集合的总高度，用于适配页面
    containerlists : 控件名，用,号分隔
    toppx          : 顶部已知高度，如果不指定，取默认高度差
]]
function count_containers_height(containerlists, toppx)
    local heightall = 0;
    local debug_alert_msg = "";
    local containerlists = formatNull(containerlists);
    if containerlists == "" then
        debug_alert("参数为空");
    else
        --通过,将控件名转换为数组
        local array = splitUtils(containerlists,",");
        if #array < 1 then
            debug_alert("控件集合为空");
        else
            for i=1,#array do
                --获取高度
                local heightstr = formatNull(getEleLocation(array[i],"height"),"0");
                debug_alert_msg = debug_alert_msg..array[i]..":"..heightstr.."\n";
                --高度删除px
                local height = px2num(heightstr);
                --转成number后相加
                heightall = heightall+height;
            end;
        end;
    end;

    --当结果不为0时
    if heightall ~= 0 then
        --如果在外层没有指定头部高度差，这里需要设置默认高度差
        local toppx = formatNull(toppx, get_top_diff());
        --底部高度改为系统计算，height_adapt会根据底部打开关闭状态自动适应该高度，此处不用给定
        local bottompx = 0;
        heightall = heightall - toppx - bottompx;

        --[[debug_alert(
            "高度计算".."\n"..
            "toppx:"..toppx.."\n"..
            "\n"..
            debug_alert_msg..
            "heightall:"..heightall.."\n"..
            ""
        );]]
    end;

    return heightall;
end;

--[[获取客户端文字控件的宽度]]
function get_noraRegularWidth(elementName,elementValue)
    --debug_alert("get_noraRegularWidth elementName:"..elementName);
    local noraregular = document:getElementsByName(elementName)[1];
    --取值
    local noraregularValue = formatNull(elementValue);
    if noraregularValue == "" then
        noraregularValue = noraregular:getPropertyByName("value");
    end;
    --debug_alert("get_noraRegularWidth noraregularValue:"..noraregularValue);
    --获取文本长度
    local noraregularValueLen = "";
    noraregularValueLen = ryt:getLengthByStr(noraregularValue);
    --根据值的长度计算出控件需占用的宽度
    local elementWidth = "";
    --单个字符的宽度值
    local lenpx = "";
    if noraregularValueLen <3 then
        lenpx = C_noraregular_ShortWidth;
    else
        lenpx = C_noraregular_LongWidth;
    end;

    --计算宽度
    elementWidth = tonumber(noraregularValueLen) * lenpx;
    --debug_alert(elementWidth);

    --宽度设置
    noraregular:setStyleByName("width",tostring(elementWidth).."px");
    return tostring(elementWidth);
end;

--[[根据右侧目标(数字)，动态调整目标距离右侧的大小，referenceFont右侧目标字体大小，interval间隔,oldInterval目标距离右侧大小]]
function adapt_right_locateion(reference, referenceFont, interval, oldInterval)
    local labelLen = ryt:getLengthByStr(reference);
    local imgRight = 0;
    imgRight = oldInterval + interval + labelLen*referenceFont/2;
    return imgRight;
end;

--[[默认头部高度基准为45px，根据客户端类型获取和基准相差的高度，进行后续的页面适配]]
function get_top_diff(height)
    local height = formatNull(height, 0);
    if height == 0 then
        local topDiffValue = 0;
        if platform == "iPhone OS" then
            if systemTable["is_iPhoneX"] == "true" then
                --iPhoneX需要加上顶部固定的高度
                topDiffValue = C_iPhone_TopHeightDiff + C_iPX_SpecialtopHeight;
            else
                --iPhone
                local PhoneType = ryt:getIPhoneType();
                local LowerPhoneTypeStr = string.lower(PhoneType);
                local LoweriPhonePlusDevices = string.lower(C_iPhonePlusDevices);
                --转小写后查找
                if string.find(LoweriPhonePlusDevices,LowerPhoneTypeStr) then
                    --debug_alert("678Plus设备头部偏移1个像素，避免滑动");
                    topDiffValue = C_iPhone_TopHeightDiff + 1;
                else
                    topDiffValue = C_iPhone_TopHeightDiff;
                end;
            end;
        else
            --Android
            topDiffValue = C_Android_TopHeightDiff;
        end;

        --[[debug_alert(
            "get_top_diff\n"..
            "input height:"..height.."\n"..
            "topDiffValue:"..topDiffValue.."\n"..
            ""
        );]]

        topDiffValue = topDiffValue;
        return topDiffValue;
    else
        return height;
    end;
end;

--[[默认iPhoneX底部高度基准为23px，根据客户端类型获取和基准相差的高度，进行后续的页面适配]]
function get_bottom_diff(height)
    --debug_alert("get_bottom_diff");
    local height = formatNull(height, 0);
    if height == 0 then
        local bottomDiffValue = 0;
        local iPhoneXBottomStyle = formatNull(globalTable["iPhoneXBottomStyle"]);
        local iSiPhoneX = formatNull(systemTable["is_iPhoneX"]);

        --iPhoneX且底部是打开的状态
        if iSiPhoneX == "true" then
            if iPhoneXBottomStyle == "show" then
                --iPhoneX底部固定的高度
                bottomDiffValue = C_iPX_SpecialbottomHeight;
            else
                bottomDiffValue = 0;
            end;
        else
            bottomDiffValue = 0;
        end;

        --[[debug_alert(
            "get_bottom_diff\n"..
            "iSiPhoneX:"..iSiPhoneX.."\n"..
            "iPhoneXBottomStyle:"..iPhoneXBottomStyle.."\n"..
            "input height:"..height.."\n"..
            "bottomDiffValue:"..bottomDiffValue.."\n"..
            ""
        );]]

        return bottomDiffValue;
    else
        return height;
    end;
end;

--[[针对特殊字体，根据右侧目标(数字)，动态调整目标距离右侧的大小，referenceFont右侧目标字体大小，interval间隔,oldInterval目标距离右侧大小]]
function adapt_right_locateion(reference, referenceFont, interval, oldInterval)
    local labelLen = ryt:getLengthByStr(reference);
    local imgRight = 0;
    imgRight = oldInterval + interval + labelLen*referenceFont/2;
    return imgRight;
end;

--[[自适应文字大小，当文字过长时改小字体]]
function jjbx_utils_adaptFontSize(elementName)
    if ryt:getLengthByStr(getValue(elementName)) > 34 then
        changeStyle(elementName,"font-size","10px");
    end;
end;

--[[根据宽度设置两个控件的左右间距]]
function jjbx_setStyleLeftOrRight(targetpostion,targetElemetName,selfpostion,selfElmentName,leftOrRight)
    --默认左布局
    local leftOrRight = formatNull(leftOrRight,"left");
    local targetElemet = document:getElementsByName(targetElemetName);
    local selfElment = document:getElementsByName(selfElmentName);
    local targetElemetWidht = "";
    for i=1,#targetElemet do
        targetElemetWidht = targetElemet[i]:getStyleByName("width");
        targetElemetWidht = ryt:getSubstringValue(targetElemetWidht,0,ryt:getLengthByStr(targetElemetWidht)-2);
        selfElment[i]:setStyleByName(leftOrRight,tostring(targetpostion+targetElemetWidht+selfpostion).."px");
    end;
    page_reload();
end;

--[[左布局]]
function jjbx_setStyleToLeft(targetLeft,targetElemetName,selfLeft,selfElmentName)
    jjbx_setStyleLeftOrRight(targetLeft,targetElemetName,selfLeft,selfElmentName,"left");
end;

--[[右布局]]
function jjbx_setStyleToRight(targetRight,targetElemetName,selfLeft,selfElmentName)
    jjbx_setStyleLeftOrRight(targetRight,targetElemetName,selfLeft,selfElmentName,"right");
end;

--[[
    渲染弹窗，样式参见公共样式
    参数：标题、文字输入提示、输入上限、按钮文字、按钮事件
    需要在页面中定义弹出来的背景层div
    <div class="do_operate_bg_div" name="do_operate_bg_div" border="0" onclick="">        
    </div>
]]
function render_input_alert_window(title,inputhold,inputmax,btntext,btnfun)
    local RenderArg = {
        title=title,
        inputhold=inputhold,
        inputmax=inputmax,
        btntext=btntext,
        btnfun=btnfun
    };
    do_render_input_alert_window(RenderArg);
end;

function do_render_input_alert_window(RenderArg)
    local operateTitle = vt("title",RenderArg);
    local textareaHoldContent = vt("inputhold",RenderArg,"请输入");
    local inputMaxLength = vt("inputmax",RenderArg,"100");
    local btnText = vt("btntext",RenderArg,"确定");
    local btnFun = vt("btnfun",RenderArg);
    local SysLayoutStyle = vt("SysLayoutStyle",systemTable);
    local showUploadButton = vt("showUploadButton", RenderArg);
    local uploadBtnFun = vt("uploadBtnFun",RenderArg);

    --渲染标题、关闭按钮、分割线、意见输入框、提交
    local doOperateHtml = [[
        <div class="do_operate_bg_div" name="do_operate_bg_div" border="0" onclick="">
            <div class="do_operate_div_]]..SysLayoutStyle..[[" border="1">
                <div class="do_operate_title_label_div" border="0">
                    <label class="do_operate_title_label" value="]]..operateTitle..[["/>
                </div>
                <div class="do_operate_close_div" border="0" onclick="close_do_operate_window('do_operate_bg_div')" >
                    <img class="do_operate_close_icon" src="local:sl_ico_close.png" onclick="close_do_operate_window('do_operate_bg_div')" />
                </div>
                <div class="do_operate_headline_div" border="0"/>
                <div class="space_10_div" border="0"/>
    ]];
    if operateTitle == "转办回复" then
        doOperateHtml = doOperateHtml..[[
            <div class="transferMsg_div" border="0">
                <label class="transferMsg_title" value="转办内容"></label>
                <label class="transferMsg_label" value="]]..globalTable["transferMsg"]..[["></label>
                <div class="space_10_div" border="0"/>
                <label class="transferMsg_title2" value="回复内容"></label>
            </div>  
            <div class="space_10_div" border="0"/>
        ]];
    end;
    doOperateHtml = doOperateHtml..[[
        <div class="do_operate_input_div" border="1">
            <textarea class="do_operate_input_textarea" inputKeyboardDisapper="YES" inputScrollFitPage="inputScrollFitPage" disableEmoji="false" selection="3" inputTransparents="yes" name="do_operate_input_textarea" border="0" hold="]]..textareaHoldContent..[[" holdColor="#D9D9D9" maxleng="]]..inputMaxLength..[[" />
        </div>
    ]];

    if btnText == "批准" and globalTable["spjdFlag"] == "1" then        
        doOperateHtml = doOperateHtml..[[
            <div class="space_10_div" border="0"/>
            <div class="do_operate_title_label_div2" border="0">
                <label class="do_operate_title_label2" value="请选择下个审批流程"/>
            </div>
            <div class="do_operate_spjd_div" border="0" name="spjdList">
        ]];
        for i=1,#globalTable["selectNodelist"] do
            doOperateHtml = doOperateHtml ..[[
                <div class="do_operate_spjd_name_div" border="0" onclick="chooseOneJd(]]..i..[[)">
                    <img src="local:select.png" class="do_operate_spjd_check" name="check_img" onclick="chooseOneJd(]]..i..[[)"/>
                    <label class="do_operate_spjd_name" value="]]..globalTable["selectNodelist"][i]["descDirection"]..[[" onclick="chooseOneJd(]]..i..[[)"/>
                </div>
            ]];
        end;
        doOperateHtml = doOperateHtml..[[
            </div>
        ]];
    end;

    if showUploadButton == "1" then
        doOperateHtml = doOperateHtml..[[
            <div class="space_10_div" border="0"/>
            <div class="transferMsg_upload_div" border="1" name="fj_div">
                <label class="transferMsg_upload_label_title" value="]]..C_UploadDefaultCountsTip..[[" name="fj_title"></label>
                <label class="transferMsg_upload_label_value" value="上传附件" name="fj" onclick="]]..uploadBtnFun..[["></label>
                <img src="local:arrow_common.png" name="fj_img" class="transferMsg_upload_arrow" />
            </div>
        ]];
    end;

    doOperateHtml = doOperateHtml..[[
                <div class="space_20_div" border="0"/>
                <div class="do_operate_btn_div" border="0" onclick="]]..btnFun..[[">
                    <div class="do_operate_btn_label_div" border="0" onclick="]]..btnFun..[[">
                        <label class="do_operate_btn_label" name="do_operate_btn_label" border="2" onclick="]]..btnFun..[[" value="]]..btnText..[[" />
                    </div>
                </div>
                <div class="space_30_div" border="0"/>
            </div>
        </div>
    ]];
    document:getElementsByName("do_operate_bg_div")[1]:setInnerHTML(doOperateHtml);
    --height_adapt("spjdList",565);
    page_reload();
end;

--[[渲染审批节点窗口]]
function render_selectNode_window(btnText,btnFun)
    local SysLayoutStyle = systemTable['SysLayoutStyle'];
    local doOperateHtml = [[
        <div class="do_operate_bg_div" name="do_operate_bg_div" border="0" onclick="">
            <div class="do_operate_div_]]..SysLayoutStyle..[[" border="1">
                <div class="do_operate_title_label_div" border="0">
                    <label class="do_operate_title_label" value=""/>
                </div>
                <div class="do_operate_close_div" border="0">
                    <img class="do_operate_close_icon" src="local:sl_ico_close.png" onclick="close_do_operate_window('do_operate_bg_div')" />
                </div>
                <div class="space_10_div" border="0"/>
                <div class="do_operate_title_label_div2" border="0">
                    <label class="do_operate_title_label2" value="请选择流程"/>
                </div>
                <div class="do_operate_spjd_div" border="0" name="spjdList">
    ]];
    for i=1,#globalTable["selectNodelist"] do
        doOperateHtml = doOperateHtml ..[[
            <div class="do_operate_spjd_name_div" border="0" onclick="chooseOneJd(]]..i..[[)">
                <img src="local:select.png" class="do_operate_spjd_check" name="check_img" onclick="chooseOneJd(]]..i..[[)"/>
                <label class="do_operate_spjd_name" value="]]..globalTable["selectNodelist"][i]["descDirection"]..[[" onclick="chooseOneJd(]]..i..[[)"/>
            </div>
        ]];
    end;
    doOperateHtml = doOperateHtml .. [[
            </div>
                <div class="space_20_div" border="0"/>
                <div class="do_operate_btn_div" border="0" onclick="]]..btnFun..[[">
                    <div class="do_operate_btn_label_div" border="0" onclick="]]..btnFun..[[">
                        <label class="do_operate_btn_label" name="do_operate_btn_label" border="2" onclick="]]..btnFun..[[" value="]]..btnText..[[" />
                    </div>
                </div>
                <div class="space_30_div" border="0"/>
            </div>
        </div>
    ]];
    document:getElementsByName("do_operate_bg_div")[1]:setInnerHTML(doOperateHtml);
    if #globalTable["selectNodelist"] > 7 then
        height_adapt("spjdList",450);
    end;
    page_reload();
end;

--[[弹出审批弹窗]]
function show_do_operate_window(windowname)
    local windowname = formatNull(windowname,"do_operate_bg_div");
    changeStyle(windowname,"display","block");
end;

--[[关闭审批弹窗]]
function close_do_operate_window(windowname)
    --关闭弹窗时，清空标志为转办回复的缓存变量
    globalTable["temp_reloadFlag"] = "";
    local windowname = formatNull(windowname,"do_operate_bg_div");
    changeStyle(windowname,"display","none");
end;

--[[显示全部审批流转]]
function lua_page.open_operate_fold()
    --debug_alert("显示全部审批流转");

    show_eles("operate_info_fold_div");
    hide_ele("operate_fold_ctrl_div");
    page_reload();
end;

--[[
    审批进度渲染
    用于单据详情页面的审批流转展示
    需要在页面中定义待渲染的审批流程信息div
    <div class="operate_msglist_div" border="0" name="operate_msglist_div">
        
    </div>
    需要传递后台返回的审批信息集和div名称
]]
function render_operate_info(operateInfoList, elementName)
    --边框调试
    local border = "0";

    --审批流数据
    local operateInfoList = formatNull(operateInfoList);
    --审批流数据条目数
    local operateInfoListCounts = #operateInfoList;
    --页面实例的容器名称
    local elementName = formatNull(elementName);

    --[[debug_alert(
        "审批进度渲染\n"..
        "总条目数 : "..tostring(operateInfoListCounts).."\n"..
        "容器名称 : "..tostring(elementName).."\n"..
        "显示条目 : "..tostring(showCounts).."\n"..
        ""
    );]]

    --当配置了显示条目数且条目总数大于显示条目限制时，展示折叠界面
    local OperateFoldCtrlHtml = "";
    if C_Operate_Show_Counts~="" and operateInfoListCounts>C_Operate_Show_Counts then
        OperateFoldCtrlHtml = [[
            <div class="operate_fold_ctrl_div" name="operate_fold_ctrl_div" border="]]..border..[[" onclick="lua_page.open_operate_fold()">
                <label class="operate_fold_ctrl_label" name="operate_fold_ctrl_label" value="展开全部审批历史" onclick="lua_page.open_operate_fold()" />
                <img class="operate_fold_ctrl_icon" name="operate_fold_ctrl_icon" src="local:arrow_down_blue.png" onclick="lua_page.open_operate_fold()" />
            </div>
        ]];
    end;

    local OperateHtmlsContent = "";
    local operate_node_stopTime_style = "";

    for i=1,operateInfoListCounts do
        local operateItem = formatNull(operateInfoList[i]);
        --debug_alert("审批信息"..foreach_arg2print(operateItem));

        local classValue = "";
        local status = vt("status",operateItem);
        --节点状态
        if status == "point" then
            classValue = "operate_status_doing_label";
        else
            classValue = "operate_status_done_label";
        end;
        --显示的节点操作人姓名
        local operater_name = vt("name",operateItem);
        operater_name = string.gsub(operater_name,"<","");
        operater_name = string.gsub(operater_name,">","");

        local show_operater_name = cutStr(operater_name,6);
        --显示的节点操作备注
        local operate_node_opinion = vt("opinion",operateItem);
        --显示的节点名称
        local operate_induty_name = vt("nodeName",operateItem);

        --审批意见长度换算为行数
        local opinionlinecounts = 0;
        local opinionlength = ryt:getLengthByStr(operate_node_opinion);
        if opinionlength < 20 then
            opinionlinecounts = 1;
        elseif opinionlength < 40 then
            opinionlinecounts = 2;
        elseif opinionlength < 60 then
            opinionlinecounts = 3;
        elseif opinionlength < 80 then
            opinionlinecounts = 4;
        else
            opinionlinecounts = 5;
        end;

        local opinion_classValue = "operate_opinion_div";
        if opinionlinecounts > 4 then
            opinion_classValue = "operate_opinion_div_more";
        end;

        --根据文字长度选择对应样式
        local operate_info_div_class = "operate_info_div_"..tonumber(opinionlinecounts);
        --显示的节点操作状态
        local show_operate_node_status = jjbx_formatSPLC(status,operate_node_opinion);
        --节点停留时间
        local operate_node_stopTime = vt("stopTime",operateItem);
        --节点停留天数
        local operate_node_stopDays = vt("stopDays",operateItem);

        --[[debug_alert(
            "节点操作人姓名 : "..operater_name.."\n"..
            "节点名称 : "..operate_induty_name.."\n"..
            "显示的节点操作备注 : "..operate_node_opinion.."\n"..
            "节点停留时间 : "..operate_node_stopTime.."\n"..
            "节点停留天数 : "..operate_node_stopDays.."\n"..
            "显示的节点操作状态 : "..show_operate_node_status.."\n"..
            "根据文字长度选择的样式 : "..operate_info_div_class.."\n"..
            ""
        );]]

        local isRobotFlag = vt("isRobot",operateItem,"0");

        --节点停留时间显示格式化
        local operate_node_stopTime_show = "";
        if operate_node_stopTime=="" and operate_node_stopDays=="" then
            operate_node_stopTime_show = "";
        else
            if tonumber(operate_node_stopDays) < 1 then
                --停留小于1天

                --operate_node_stopTime_show = millisecondTotime(operate_node_stopTime);
                --operate_node_stopTime_style = "stopTime";

                operate_node_stopTime_show = "已停留0个工作日";
                operate_node_stopTime_style = "stopDays";
            else
                operate_node_stopTime_show = "已停留"..operate_node_stopDays.."个工作日";
                operate_node_stopTime_style = "stopDays";
            end;
        end;

        --节点操作时间
        local operate_node_dealTime = formatNull(operateItem["dealTime"]);

        --节点点击事件
        local operate_onclick_fun = "alert_operater_name('"..operater_name.."','"..show_operate_node_status.."')";

        --处理审批意见为待审批、审批中的情况
        if operate_node_opinion == "待审批" or operate_node_opinion == "审批中" then
            operate_node_opinion = "";
        end;

        --节点名称页面内容
        local induty_name_html = "";
        if operate_induty_name ~= "" then
            induty_name_html = [[
                <div class="induty_name_div" border="]]..border..[[">
                    <label class="induty_name_label">]]..operate_induty_name..[[</label>
                </div>
            ]];
        end;

        --div item名字
        local operate_info_div_name = "";
        --配置了可显示条目数且当前条目大于可显示条目时，放到折叠层，其他的放到正常显示层
        if C_Operate_Show_Counts~="" and i>C_Operate_Show_Counts then
            operate_info_div_name = "operate_info_fold_div";
        else
            operate_info_div_name = "operate_info_base_div";
        end;
        --debug_alert(tostring(i).." "..operate_info_div_name);

        --空白串
        local concatSpace = " ";

        --是否基建审批
        local isSkip = vt("isSkip",operateItem);
        if isSkip == "1" then
            isSkip = "（基建）";
        else
            isSkip = "";
        end;

        --设置审批人、状态、审批信息页面内容
        OperateHtmlsContent =
            OperateHtmlsContent..[[
                <div name="]]..operate_info_div_name..[[" class="operate_info_content_div" border="]]..border..[[">
                    ]]..induty_name_html..[[
                    <div class="]]..operate_info_div_class..[[" border="]]..border..[[" onclick="]]..operate_onclick_fun..[[">
                        <div class="operate_info_div" border="]]..border..[[" onclick="]]..operate_onclick_fun..[[">
            ]];
        if isRobotFlag == "1" then
            OperateHtmlsContent =
            OperateHtmlsContent..[[
                            <img src="local:robot.png" class="robot_img"/>
                            ]];
        else
            OperateHtmlsContent =
            OperateHtmlsContent..[[
                            <label class="operate_name_label" onclick="]]..operate_onclick_fun..[[">]]..show_operater_name..[[</label>
                            ]];
        end;
        OperateHtmlsContent =
            OperateHtmlsContent..[[
                            <label class="]]..classValue..[[" value="]]..concatSpace..show_operate_node_status.."   "..[[" onclick="]]..operate_onclick_fun..[["></label>
                            <label class="operate_isSkip_label" value="]]..isSkip.."   "..[[" onclick="]]..operate_onclick_fun..[["></label>
                            <div class="]]..opinion_classValue..[[" border="]]..border..[[" onclick="]]..operate_onclick_fun..[[">
                                <label class="operate_opinion_label" onclick="]]..operate_onclick_fun..[[">]]..operate_node_opinion..[[</label>
                            </div>
        ]];

        --设置审批时间页面内容
        if operate_node_dealTime ~= "" then
            OperateHtmlsContent = OperateHtmlsContent..[[
                <label class="operate_done_time_label">]]..operate_node_dealTime..[[</label>
            ]];
        else
            if operate_node_stopTime ~= "" then
                --debug_alert(operate_node_stopTime);
                --定义全局变量，用于更新审批时间
                OperateNodeStopTimes = tonumber(operate_node_stopTime);
                if operate_node_stopTime_style == "stopTime" then
                    OperateHtmlsContent = OperateHtmlsContent..[[
                        <label class="operate_text_label" name="operate_text_label">已停留</label>
                        <label class="operate_stop_time_label" name="operate_stop_time_label">]]..operate_node_stopTime_show..[[</label>
                    ]];
                else
                    OperateHtmlsContent = OperateHtmlsContent..[[
                        <label class="operate_stop_days_label" name="operate_stop_days_label">]]..operate_node_stopTime_show..[[</label>
                    ]];
                end;
            end;
        end;

        --html子容器结束
        OperateHtmlsContent = OperateHtmlsContent..[[
                    </div>
                </div>
            </div>
        ]];
    end;

    --更新html
    OperateHtmls = [[
        <div class="]]..elementName..[[" border="]]..border..[[" name="]]..elementName..[[">
            <div class="operate_msginfo_div" border="]]..border..[[" name="operate_msginfo_div">
                <div class="space_10_div" border="]]..border..[[" />
                ]]..OperateHtmlsContent..[[
                <div class="space_10_div" border="]]..border..[[" />
            </div>
            ]]..OperateFoldCtrlHtml..[[
        </div>
    ]];
    --debug_alert(OperateHtmls);
    document:getElementsByName(elementName)[1]:setInnerHTML(OperateHtmls);
    --隐藏折叠层
    hide_eles("operate_info_fold_div");
    page_reload();

    for k=1,operateInfoListCounts do
        if operateInfoList[k]["status"] == "point" then
            --debug_alert("已停留样式 : "..operate_node_stopTime_style);
            if operate_node_stopTime_style == "stopTime" then
                --设置审批节点的时间位置
                setoperate_text_labelTimeRight();

                local CurrentPageInfo = lua_page.current_page_info();
                local PageFilePath = vt("page_file_path",CurrentPageInfo);
                --注册定时任务
                local MissionRegisterArg = {
                    ID = "ApplyDetailStopTimer",
                    Name = "单据详情页面，已停留审批时间倒计时",
                    PageUrl = PageFilePath,
                    CallFunc = "update_operate_stopTime_label",
                    CallArg = ""
                };
                lua_system.timer_register(MissionRegisterArg);
            end;
        end;
    end;
end;

--[[弹窗显示完整审批人信息]]
function alert_operater_name(name,status)
    --debug_alert("alert_operater_name "..name);

    local name = formatNull(name);
    if name ~= "" then
        if string.find(name,"审批") then
            --debug_alert("名称包含审批字样，不弹出");
        else
            if ryt:getLengthByStr(name) > 6 then
                if status == "待回复" or status == "已回复" then
                    alert_confirm("转办对象",name,"","确定","");
                else
                    alert_confirm("审批人",name,"","确定","");
                end;
            else
                --debug_alert("名称未截取，不弹出");
            end;
        end;
    end;
end;

--[[
    定时器响应处理页面文字更新
    更新审批时间戳信息
]]
function update_operate_stopTime_label()
    OperateNodeStopTimes = OperateNodeStopTimes + 1000;
    local codeTimerelement = "operate_stop_time_label";
    --[[debug_alert(
        "jjbx_utils_timer_uplabel\n"..
        "OperateNodeStopTimes :"..OperateNodeStopTimes.."\n"..
        "codeTimerelement :"..codeTimerelement.."\n"..
        ""
    );]]
    changeProperty(codeTimerelement,"value",millisecondTotime(OperateNodeStopTimes));
end;

--[[
    审批按钮渲染
    用于单据详情页面的审批按钮展示
    需要在页面中定义审批按钮div
    <div class="operate_btn_div" border="0" name="operate_btn_div">
    </div>
    operate_style:定义3个、2个、1个按钮
    operate_arg:定义按钮文字和事件的json
]]
function load_operate_button(operate_style, operate_arg)
    --[[debug_alert(
        "load_operate_button\n"..
        "operate_style:"..operate_style.."\n"..
        "operate_arg:"..operate_arg.."\n"..
        ""
    );]]
    --解析按钮json参数
    local operate_arg = json2table(operate_arg);

    local optionDiv = "";
    if operate_style == "four_btn" then
        --四个按钮
        optionDiv = [[
            <div class="operate_btn_div" border="0" name="operate_btn_div">
                <div class="four_btn_div" border="0">
                    <div class="four_btn1_div" border="0" onclick="]]..operate_arg['btn1_onclick']..[[">
                        <label class="four_btn1_label">]]..operate_arg['btn1_text']..[[</label>
                    </div>
                    <div class="four_btn2_div" border="0" onclick="]]..operate_arg['btn2_onclick']..[[">
                        <label class="four_btn2_label">]]..operate_arg['btn2_text']..[[</label>
                    </div>
                    <div class="four_btn3_div" border="0" onclick="]]..operate_arg['btn3_onclick']..[[">
                        <label class="four_btn3_label">]]..operate_arg['btn3_text']..[[</label>
                    </div>
                    <div class="four_btn4_div" border="0" onclick="]]..operate_arg['btn4_onclick']..[[">
                        <label class="four_btn4_label">]]..operate_arg['btn4_text']..[[</label>
                    </div>
                </div>
            </div>
        ]];
    elseif operate_style == "three_btn" then
        --三个按钮
        optionDiv = [[
            <div class="operate_btn_div" border="0" name="operate_btn_div">
                <div class="three_btn_div" border="0">
                    <div class="three_btn1_div" border="0" onclick="]]..operate_arg['btn1_onclick']..[[">
                        <label class="three_btn1_label">]]..operate_arg['btn1_text']..[[</label>
                    </div>
                    <div class="three_btn2_div" border="0" onclick="]]..operate_arg['btn2_onclick']..[[">
                        <label class="three_btn2_label">]]..operate_arg['btn2_text']..[[</label>
                    </div>
                    <div class="three_btn3_div" border="0" onclick="]]..operate_arg['btn3_onclick']..[[">
                        <label class="three_btn3_label">]]..operate_arg['btn3_text']..[[</label>
                    </div>
                </div>
            </div>
        ]];
    elseif operate_style == "two_btn" then
        --两个按钮
        optionDiv = [[
            <div class="operate_btn_div" border="0" name="operate_btn_div">
                <div class="two_btn_div" name="two_btn_div" border="0">
                    <div class="two_btn1_div" border="0" onclick="]]..operate_arg['btn1_onclick']..[[">
                        <label class="two_btn1_label">]]..operate_arg['btn1_text']..[[</label>
                    </div>
                    <div class="two_btn2_div" border="0" onclick="]]..operate_arg['btn2_onclick']..[[">
                        <label class="two_btn2_label">]]..operate_arg['btn2_text']..[[</label>
                    </div>
                </div>
            </div>
        ]];
    elseif operate_style == "one_btn" then
        --一个按钮
        optionDiv = [[
            <div class="operate_btn_div" border="0" name="operate_btn_div">
                <div class="btn_single_full_screen_div" border="0" onclick="]]..operate_arg['btn1_onclick']..[[">
                    <label class="btn_single_full_screen_label" border="0" value="]]..operate_arg['btn1_text']..[[" />
                </div>
            </div>
        ]];
    elseif operate_style == "one_btn2" then
        --行程共享一个按钮
        optionDiv = [[
            <div class="operate_btn_div" border="0" name="operate_btn_div">
                <div class="btn_single_full_screen_div" border="0" onclick="]]..operate_arg['btn1_onclick']..[[">
                    <img src="local:share.png" class="btn_single_img_gx" />
                    <label class="btn_single_text_gx" border="0" value="]]..operate_arg['btn1_text']..[[" />
                </div>
            </div>
        ]];
    elseif operate_style == "one_btn3" then
        --行程共享已共享时一个按钮
        optionDiv = [[
            <div class="operate_btn_div" border="0" name="operate_btn_div">
                <div class="btn_single_full_screen_div" border="0">
                    <label class="btn_single_full_screen_label2" border="0" value="]]..operate_arg['btn1_text']..[[" />
                </div>
            </div>
        ]];
    elseif operate_style == "three_btn2" then
        --行程共享三个按钮
        optionDiv = [[
            <div class="operate_btn_div" border="0" name="operate_btn_div">
                <div class="three_btn_div" border="0">
                    <div class="three_btn1_div" border="0" onclick="]]..operate_arg['btn1_onclick']..[[">
                        <img src="local:share.png" class="three_btn1_label_img" />
                        <label class="three_btn1_label_text">]]..operate_arg['btn1_text']..[[</label>
                    </div>
                    <div class="three_btn2_div" border="0" onclick="]]..operate_arg['btn2_onclick']..[[">
                        <label class="three_btn2_label">]]..operate_arg['btn2_text']..[[</label>
                    </div>
                    <div class="three_btn3_div" border="0" onclick="]]..operate_arg['btn3_onclick']..[[">
                        <label class="three_btn3_label">]]..operate_arg['btn3_text']..[[</label>
                    </div>
                </div>
            </div>
        ]];
    elseif operate_style == "two_btn2" then
        --行程共享两个按钮
        optionDiv = [[
            <div class="operate_btn_div" border="0" name="operate_btn_div">
                <div class="two_btn_div" name="two_btn_div" border="0">
                    <div class="two_btn1_div" border="0" onclick="]]..operate_arg['btn1_onclick']..[[">
                        <img src="local:share.png" class="two_btn1_label_img" />
                        <label class="two_btn1_label_text">]]..operate_arg['btn1_text']..[[</label>
                    </div>
                    <div class="two_btn2_div" border="0" onclick="]]..operate_arg['btn2_onclick']..[[">
                        <label class="two_btn2_label">]]..operate_arg['btn2_text']..[[</label>
                    </div>
                </div>
            </div>
        ]];
    elseif operate_style == "three_btn3" then
        --行程共享已共享时三个按钮
        optionDiv = [[
            <div class="operate_btn_div" border="0" name="operate_btn_div">
                <div class="three_btn_div" border="0">
                    <div class="three_btn1_div" border="0">
                        <label class="three_btn1_label2">]]..operate_arg['btn1_text']..[[</label>
                    </div>
                    <div class="three_btn2_div" border="0" onclick="]]..operate_arg['btn2_onclick']..[[">
                        <label class="three_btn2_label">]]..operate_arg['btn2_text']..[[</label>
                    </div>
                    <div class="three_btn3_div" border="0" onclick="]]..operate_arg['btn3_onclick']..[[">
                        <label class="three_btn3_label">]]..operate_arg['btn3_text']..[[</label>
                    </div>
                </div>
            </div>
        ]];
    elseif operate_style == "two_btn3" then
        --行程共享已共享时两个按钮
        optionDiv = [[
            <div class="operate_btn_div" border="0" name="operate_btn_div">
                <div class="two_btn_div" name="two_btn_div" border="0">
                    <div class="two_btn1_div" border="0">
                        <label class="two_btn1_label2">]]..operate_arg['btn1_text']..[[</label>
                    </div>
                    <div class="two_btn2_div" border="0" onclick="]]..operate_arg['btn2_onclick']..[[">
                        <label class="two_btn2_label">]]..operate_arg['btn2_text']..[[</label>
                    </div>
                </div>
            </div>
        ]];
    else
        changeStyle("operate_btn_div","display","none");
    end;

    if optionDiv ~= "" then
        document:getElementsByName("operate_btn_div")[1]:setInnerHTML(optionDiv);
    end;
end;

--[[创建详情页面表头]]
function create_bill_detal_baseinfo(detailItem, baseinfodivname)
    --debug_alert(detailItem);
    local detailItem = formatNull(detailItem);
    local baseinfodivname = formatNull(baseinfodivname);

    local itemhtmls = "";
    local debug_alert_msg = "";

    for i=1,#detailItem do
        --下方label类型，目前支持默认和金额，金额为橘色
        local style = formatNull(detailItem[i]["style"]);
        local value_label_style = "";
        if style == "orange" then
            value_label_style = "bill_basedetail_value_orange_label";
        elseif style == "blue" then
            value_label_style = "bill_basedetail_value_blue_label";
        else
            value_label_style = "bill_basedetail_value_label";
        end;

        --上方label控件名
        local topname = formatNull(detailItem[i]["topname"]);
        --上方label控件值
        local topvalue = formatNull(detailItem[i]["topvalue"]);
        --下方label控件名
        local downname = formatNull(detailItem[i]["downname"]);
        --下方label控件值
        local downvalue = formatNull(detailItem[i]["downvalue"]);
        --点击事件，带参数需要转义 fun="test()" fun="test(\"a\")" 
        local func = formatNull(detailItem[i]["func"]);

        debug_alert_msg = debug_alert_msg..
            "topname:"..topname.."\n"..
            "topvalue:"..topvalue.."\n"..
            "downname:"..downname.."\n"..
            "downvalue:"..downvalue.."\n"..
            "func:"..func.."\n"..
            "\n";

        local setcontent = [[
            <div class='bill_basedetail_item_div' border='0' onclick=']]..func..[['>
                <label class='bill_basedetail_key_label' value=']]..topvalue..[['></label>
                <label class=']]..value_label_style..[[' name=']]..downname..[[' value=']]..downvalue..[[' onclick=']]..func..[['></label>
            </div>
        ]];

        if downname == "xcsq_shared" and globalTable["createUserCode"] == globalTable["workid_xcsq"] then
            setcontent = [[
                <div class='bill_basedetail_item_div' border='0' onclick=']]..func..[['>
                    <label class='bill_basedetail_key_label' value=']]..topvalue..[['></label>
                    <label class=']]..value_label_style..[[' name=']]..downname..[[' value=']]..downvalue..[[' onclick=']]..func..[['></label>
                    <label class='bill_basedetail_value_label2' border='0' onclick='cancelShared()' name='cancel'>取消</label>
                </div>
            ]];
        elseif downname == "xcsq_shared" and globalTable["createUserCode"] ~= globalTable["workid_xcsq"] then
            setcontent = [[
                <div class='bill_basedetail_item_div' border='0' onclick=']]..func..[['>
                    <label class='bill_basedetail_key_label' value=']]..topvalue..[['></label>
                    <label class=']]..value_label_style..[[' name=']]..downname..[[' value=']]..downvalue..[[' onclick=']]..func..[['></label>
                </div>
            ]];
        end;

        --2个换行
        local rem = i%2;
        local mod = i/2;

        if rem == 1 then
            itemhtmls = itemhtmls..[[
                <div class="bill_basedetail_div" border="0">
                    <div class="bill_basedetail_left_div" border="0">
                        ]]..setcontent..[[
                    </div>
            ]];
            if i == #detailItem then
                --debug_alert("单数结尾");
                itemhtmls = itemhtmls..[[
                    </div>
                ]];
            end;
        elseif rem == 0 then
            itemhtmls = itemhtmls..[[
                    <img src="local:line_v.png" class="line_v_icon"/>
                    <div class="bill_basedetail_right_div" border="0">
                        ]]..setcontent..[[
                    </div>
                </div>
                <div class="space_05_div" border="0"/>
            ]];
        end;

        --[[debug_alert(
            "i:"..i.."\n"..
            "rem:"..rem.."\n"..
            "mod:"..mod.."\n"..
            "itemhtmls:"..itemhtmls.."\n"..
            ""
        );]]
    end;

    --[[debug_alert(
        "baseinfodivname:"..baseinfodivname.."\n"..
        --debug_alert_msg..
        itemhtmls
    );]]

    local htmls = [[
        <div class="bill_baseinfo_div" border="0" name="]]..baseinfodivname..[[">
            <div class="bill_baseline_div" border="0"/>
            ]]..itemhtmls;

    --是否加载查看附件浮层
    local PcEnclosureTotalCounts = tonumber(globalTable["PcEnclosureTotalCounts"]);
    --debug_alert("查看附件总张数 : "..PcEnclosureTotalCounts);
    globalTable["PcEnclosureTotalCounts"] = "";
    --附件张数大于0时，创建查看附件按钮且显示
    if tonumber(formatNull(PcEnclosureTotalCounts,"0")) > 0 then
        htmls = htmls .. [[
            <img src="local:seeAnnex.png" class="fujian_button" name="seeAnnex" onclick="seeAnnex()" />
        ]];
    else
    --附件张数获取不到时，创建隐藏的对象，因为查询附件跟创建对象是异步操作，防止出现创建对象时附件还没有返回查询结果而导致的实际有附件而不显示按钮
        htmls = htmls .. [[
            <img src="local:seeAnnex.png" class="fujian_button,displayNone" name="seeAnnex" onclick="seeAnnex()" />
        ]];
    end;

    htmls = htmls .. [[
            <div class="space_30_div" border="0"/>
        </div>
    ]];
    --debug_alert(htmls);
    document:getElementsByName(baseinfodivname)[1]:setInnerHTML(htmls);
end;

--[[
    根据单据配置，动态生成详情页面头
    itemContentEleName: 页面容器div的名称
    billConfigData: billConfig/queryConfigApp的http返回
    billTypeCode: 单据类型
    billInfoData: common/queryByBillNo的http返回
]]
function credit_bill_base_info_by_config(itemContentEleName, billConfigData, billTypeCode, billInfoData)
    local itemContentEleName = formatNull(itemContentEleName);
    local billConfigData = formatNull(billConfigData);
    local billTypeCode = formatNull(billTypeCode);
    local billInfoData = formatNull(billInfoData);
    --debug_alert("credit_bill_base_info_by_config billInfoData Len:"..#billInfoData);
    --debug_alert(billInfoData);

    if itemContentEleName ~= "" and billConfigData ~= "" then
        --声明容器
        local detailItem = {};

        --配置的字段
        local fieldAppId = "";
        --APP使用的值
        local billInfoDataValue = "";
        --是否显示 1 为显示
        local fieldVisible = "";
        --显示文字
        local fieldDispName = "";
        --信息归类 1为基本信息
        local modelType = "";
        local debug_alert_msg = "详情页面配置:\n";
        --是否插入信息
        local insertBillInfo = "false";

        for i=1,#billConfigData do
            --默认为空
            fieldAppId = formatNull(billConfigData[i]["fieldAppId"]);
            --默认为不显示
            fieldVisible = formatNull(billConfigData[i]["fieldVisible"], "0");
            --默认为空
            fieldDispName = formatNull(billConfigData[i]["fieldDispName"]);
            --默认为不显示
            modelType = formatNull(billConfigData[i]["modelType"]);
            --判断是否需要插入单据信息
            insertBillInfo = insert_bill_info(fieldAppId,fieldVisible,modelType,billTypeCode);

            --[[debug_alert(
                "fieldAppId:"..fieldAppId.."\n"..
                "fieldVisible:"..fieldVisible.."\n"..
                "fieldDispName:"..fieldDispName.."\n"..
                "modelType:"..modelType.."\n"..
                "insertBillInfo:"..insertBillInfo.."\n"..
                "\n"
            );]]

            --添加显示字段
            if insertBillInfo == "true" then
                --默认参数初始化
                local billInfoDataType = "";
                local billInfoDataKey = "";
                local itemStyle = "";
                local useFunc = "";
                if billTypeCode ~= "" then
                    AppConfigIdInfo = formatNull(bill_config["level1"][billTypeCode][fieldAppId]);
                    --有值的情况下做切分
                    AppConfigIdInfoSplitResult = splitUtils(AppConfigIdInfo,",");

                    --数值类型
                    billInfoDataType = formatNull(AppConfigIdInfoSplitResult[1]);
                    --数值参数名
                    billInfoDataKey = formatNull(AppConfigIdInfoSplitResult[2]);
                    --显示样式
                    itemStyle = formatNull(AppConfigIdInfoSplitResult[3]);
                    --点击事件
                    useFunc = formatNull(AppConfigIdInfoSplitResult[4]);

                    --根据key取info数据里的值
                    if #billInfoData < 1 then
                        billInfoDataValue = formatNull(billInfoData[billInfoDataKey]);
                    else
                        for i=1,#billInfoData do
                            --debug_alert("billInfoData index"..tostring(i));
                            --debug_alert(billInfoData);
                            billInfoDataValue = formatNull(billInfoData[i][billInfoDataKey]);
                            if billInfoDataValue ~= "" then
                                --debug_alert("index"..tostring(i)..":"..billInfoDataValue);
                                break
                            end;
                        end;
                    end;

                    if billInfoDataType == "date" then
                        --日期类型数据做转换
                        billInfoDataValue = timestamp_to_date(billInfoDataValue,"date");
                    elseif billInfoDataType == "bool" then
                        --布尔类型转换
                        if tonumber(billInfoDataValue) == 1 then
                            billInfoDataValue = "是";
                        else
                            billInfoDataValue = "否";
                        end;
                    elseif billInfoDataType == "cartype" then
                        --用车类型
                        billInfoDataValue = jjbx_yccx(billInfoDataValue);
                    elseif billInfoDataType == "yclx" then
                        --用餐类型
                        if tonumber(billInfoDataValue) == 0 then
                            billInfoDataValue = "外卖";
                        elseif tonumber(billInfoDataValue) == 1 then
                            billInfoDataValue = "到店";
                        else
                            billInfoDataValue = "外卖、到店";
                        end;
                    elseif billInfoDataType == "rjcb" then
                        --人均餐标
                        if tonumber(formatNull(billInfoDataValue,"0")) > 0 then
                            billInfoDataValue = billInfoDataValue.."/人";
                        else
                            billInfoDataValue = "*/人";
                        end;
                    elseif billInfoDataType == "djzt" then
                        --单据状态
                        billInfoDataValue = bill_statecode2text(billInfoDataValue);
                    elseif billInfoDataType == "ycsj" then
                        --用车时间
                        if formatNull(billInfoData["diditripdate"]) ~= "" and formatNull(billInfoData["usecartime"]) ~= "" then
                            billInfoDataValue=billInfoData["diditripdate"]..' 至 '..billInfoData["usecartime"];
                        else
                            billInfoDataValue=billInfoData["diditripdate"];
                        end;
                    elseif billInfoDataType == "eatServiceTime" then
                        --用餐时间
                        if formatNull(billInfoData[2]["xcrqst"]) ~= "" and formatNull(billInfoData[2]["xcrqed"]) ~= "" then
                            billInfoDataValue= timestamp_to_date(billInfoData[2]["xcrqst"],"date")..' 至 '..timestamp_to_date(billInfoData[2]["xcrqed"],"date");
                        else
                            billInfoDataValue= timestamp_to_date(billInfoData[2]["xcrqed"],"date")
                        end;
                    elseif billInfoDataType == "fjzsFlag" then
                        --纸质附件
                        if billInfoDataValue and tonumber(billInfoDataValue) == 1 then
                            billInfoDataValue = "有";
                        elseif billInfoDataValue and tonumber(billInfoDataValue) == 0 then
                            billInfoDataValue = "无";
                        else 
                            billInfoDataValue = "";
                        end;
                    else
                        --默认为text不处理
                    end;

                    --流水金额为0，不加事件，不为0显示配置的链接名称
                    if billInfoDataKey == "lsje" then
                        if tonumber(billInfoDataValue) == 0 then
                            useFunc = "";
                        else
                            billInfoDataValue = C_ShowAmountMsg;
                        end;
                    end;
                end;

                table.insert(detailItem,{style=itemStyle, topname="", topvalue=fieldDispName, downname=fieldAppId, downvalue=billInfoDataValue, func=useFunc});

                debug_alert_msg = debug_alert_msg..
                    "配置接口返回ID:"..fieldAppId.."\n"..
                    "取值Key:"..billInfoDataKey.."\n"..
                    "取值Value:"..billInfoDataValue.."\n"..
                    "值类型:"..billInfoDataType.."\n"..
                    "显示名称:"..fieldDispName.."\n"..
                    "显示样式:"..itemStyle.."\n"..
                    "事件函数:"..useFunc.."\n"..
                    "\n";
            end;
        end;

        --debug_alert(debug_alert_msg);
        --debug_alert(detailItem);

        create_bill_detal_baseinfo(detailItem, itemContentEleName);
    else
        alert("单据基本信息查询失败")
    end;
end;

--[[判断是否需要插入单据信息]]
function insert_bill_info(fieldAppId,fieldVisible,modelType,billTypeCode)
    --[[debug_alert(
        "insert_bill_info\n"..
        "fieldAppId : "..fieldAppId.."\n"..
        "fieldVisible : "..fieldVisible.."\n"..
        "modelType : "..modelType.."\n"..
        "billTypeCode : "..billTypeCode.."\n"..
        ""
    );]]

    local insert = "false";
    --用餐申请单只显示123类型
    if billTypeCode == "eatServer" then
        if modelType == "1" or modelType == "2" or modelType == "3" then
            --用餐申请单的剩余可用次数、剩余可用金额页面里补齐，这里不进行记录插入
            if fieldAppId == "sykycs_div" or fieldAppId == "sykyje_div" then
                insert = "false";
            else
                if fieldVisible == "1" then
                    insert = "true";
                else
                    insert = "false";
                end;
            end;
        else
            insert = "false";
        end;
    elseif billTypeCode == "cgsq_new" then
        if fieldAppId == "zdy" or fieldAppId == "xmda" then
            insert = "false";
        else
            if modelType == "1" and  fieldVisible == "1" then
                insert = "true";
            else
                insert = "false";
            end;
        end;
    else
        if modelType == "1" and  fieldVisible == "1" then
            insert = "true";
        else
            insert = "false";
        end;
    end;

    return insert;
end;

--[[
    计算文字宽度
    textStr      : 字符串
    textFontSize : 字体大小
]]
function calculate_text_width(textStr,textFontSize)
    local textStr = formatNull(textStr);
    local textFontSize = formatNull(textFontSize);
    if textStr~="" and textFontSize~="" then
        local text_width = RYTL:getWidthByStr(textStr,textFontSize);
        text_width = formatNull(text_width);
        return tostring(text_width);
    else
        return "0";
    end;
end;

--[[页面属性初始化]]
function page_sys_init()
    --计时器注销
    lua_system.timer_unregister();

    --还原iPhoneX底部适配，默认为显示底部
    globalTable["iPhoneXBottomStyle"] = "show";
end;

--[[页面头部切换点击]]
function click_head_option(optionIndex, optionEleName, callFunName, callFunArg)
    --点击的下标
    local optionIndex = formatNull(optionIndex);
    --点击的控件名称（同名）
    local optionEleName = formatNull(optionEleName);
    --切换回调方法
    local callFunName = formatNull(callFunName);
    --切换回调方法入参
    local callFunArg = formatNull(callFunArg);

    local optionElements = document:getElementsByName(optionEleName);
    local optionElementsCounts = #optionElements;

    --[[debug_alert(
        "页面头部切换点击\n"..
        "点击的下标 : "..optionIndex.."\n"..
        "点击的控件名称 : "..optionEleName.."\n"..
        "点击的控件个数 : "..tostring(optionElementsCounts).."\n"..
        "切换回调方法 : "..callFunName.."\n"..
        "切换回调方法入参 : "..callFunArg.."\n"..
        ""
    );]]

    for i=1,optionElementsCounts do
        if i == tonumber(optionIndex) then
            --debug_alert("显示"..tostring(i));
            optionElements[i]:setStyleByName("display","block");
        else
            --debug_alert("隐藏"..tostring(i));
            optionElements[i]:setStyleByName("display","none");
        end;
    end;

    lua_system.do_function(callFunName,callFunArg);
end;

--[[
    控件批量做通用高度适配
    containerlists : 控件名，用,号分隔
    adaptSetUp     : 适配指定
        ·common : 适配头部
        ·screen : 适配全屏
        ·指定像素值，只能为Num
]]
function batch_height_adapt(containerlists, adaptSetUp)
    local containerlists = formatNull(containerlists);
    local adaptSetUp = formatNull(adaptSetUp,"common");
    --[[debug_alert(
        "batch_height_adapt\n"..
        "containerlists:"..containerlists.."\n"..
        "adaptSetUp:"..adaptSetUp.."\n"..
        ""
    );]]

    if containerlists == "" then
        debug_alert("参数为空");
    else
        --通过,将控件名转换为数组
        local array = splitUtils(containerlists,",");
        if #array < 1 then
            debug_alert("控件集合为空");
        else
            for i=1,#array do
                --进行通用适配
                local containername = formatNull(array[i]);
                --debug_alert(containername);
                if containername ~= "" then
                    if adaptSetUp == "screen" then
                        --全屏批量适配
                        height_adapt(containername,0,0);
                    elseif adaptSetUp == "common" then
                        --通用批量适配
                        height_adapt(containername);
                    else
                        --指定像素批量适配
                        if type(adaptSetUp) == "number" then
                            height_adapt(containername,adaptSetUp);
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

--[[创建银行网点选择控件]]
function lua_page.create_network_widget(elename)
    --定义银行和网点全局变量
    globalTable["bank_code"] = "";
    globalTable["bank_name"] = "";
    globalTable["network_code"] = "";
    globalTable["network_name"] = "";

    local elename = formatNull(elename,"bank_network_widget_div");

    --创建银行控件、网点搜索控件、网点选择/搜索控件，网点控件iOS不支持单独设置圆角，所以在底部给了一个白色的直角层，完成上圆角下直角的显示效果
    local html = [[
        <div name="]]..elename..[[" class="bank_network_widget_div" border="0">
            <div class="bank_bg_div" border="0" name="bank_bg_div">
                <bankSelectBasicInfoManage name="bank_widget" class="bank_widget" function="select_bank" hidefun="hide_banknetwork_widget" value="" />
            </div>

            <div class="network_bg_div" border="0" name="network_bg_div" onclick="">
                <div class="top_div_]]..systemTable['SysLayoutStyle']..[[" border="0" name="top_search_network_and_check_div" />

                <div name="radius_bg_div" class="radius_bg_div" border="0" />

                <div name="network_widget_div" class="network_widget_div" border="1">
                    <bankBranch name="network_widget" class="network_widget" width="375" height="321" function="select_network" hidefun="hide_banknetwork_widget" value="" />
                </div>
            </div>

            <div class="search_network_bg_div" border="0" name="search_network_bg_div" onclick="">
                <div class="top_div_]]..systemTable['SysLayoutStyle']..[[" border="0" name="top_search_network_div" />
            </div>
        </div>
    ]];

    document:getElementsByName(elename)[1]:setInnerHTML(html);
    --批量将下列控件高度适配为全屏
    batch_height_adapt("containerlists,bank_network_widget_div,bank_bg_div,bank_widget,network_bg_div,search_network_bg_div,network_widget", "screen");

    --创建搜索头
    create_page_title("hide_banknetwork_widget()", "search_bar", "网点名称精确", "search_network_onChange(1)", "label_bar", "确定", "search_network(1)", "top_search_network_and_check_div");
    create_page_title("hide_banknetwork_widget()", "search_bar", "网点名称精确", "search_network_onChange(2)", "label_bar", "确定", "search_network(2)", "top_search_network_div");

    page_reload();
end;

--[[渲染单据右侧头部菜单]]
function lua_page.render_bill_top_right_menu(add_menu_list)
    --debug_alert("lua_page.render_bill_top_right_menu");

    --新增菜单
    local add_menu_list = formatNull(add_menu_list,{});

    --菜单集合
    local menu_list = {};

    --单据打印菜单
    local bill_print_menu = {
        menu_name="单据下载",
        menu_click="lua_page.top_right_menu_router('get_bill_cover_pdf')",
        menu_icon="menu_bar_pdf.png"
    };

    if lua_form.nil_table(add_menu_list) == "false" then
        --debug_alert("有追加菜单");
        for i,add_menu in pairs(add_menu_list) do
            table.insert(menu_list,add_menu);
        end;
    else
        --debug_alert("无追加菜单");
    end;

    --最后位置追加打印菜单
    local PCConfigListsTable = vt("PCConfigListsTable",globalTable);
    local djzt = globalTable["djzt_download"];
    if vt("BILL0019",PCConfigListsTable)~="" and vt("BILL0019",PCConfigListsTable)=="审批结束" then
        if djzt == "3" or djzt == "4" or djzt == "5" or djzt == "6" or djzt == "7" or djzt == "98" then
            table.insert(menu_list, bill_print_menu);
        end;
    else
        table.insert(menu_list, bill_print_menu);
    end;
    -- 是否创建右侧菜单
    if #menu_list > 0 then
        globalTable["rightMenuFlag"] = "true";
    else
        globalTable["rightMenuFlag"] = "false";
    end;
    --创建右侧菜单
    local renderArg = {menu_list=menu_list};

    lua_page.render_top_right_menu(renderArg);
end;

--[[渲染右侧头部菜单页面]]
function lua_page.render_top_right_menu(arg)
    --debug_alert("lua_page.render_top_right_menu");
    local arg = formatNull(arg);

    --操作页背景容器
    local menu_bg_name = formatNull(arg["menu_bg_name"],"top_menu_bg_div");
    --操作页父控件
    local menu_parent_name = formatNull(arg["menu_parent_name"],"top_menu_page_content_div");
    --操作页子控件
    local menu_child_name = formatNull(arg["menu_child_name"],"top_menu_content_div");
    --菜单显示隐藏方法
    local menu_child_fun = formatNull(arg["menu_child_fun"],"lua_page.top_right_menu_ctrl()");
    --菜单标题
    local menu_title = formatNull(arg["menu_title"],"选择操作");
    --菜单右侧样式
    local menu_right_style = formatNull(arg["menu_right_style"],"default");
    --菜单信息
    local menu_list = formatNull(arg["menu_list"]);
    --菜单返回方法
    local menu_back_fun = formatNull(arg["menu_back_fun"],"lua_page.top_right_menu_ctrl()");
    --菜单个数
    local menu_counts = #menu_list;

    --[[debug_alert(
        "渲染右侧头部菜单页面\n"..
        "菜单个数 : "..menu_counts.."\n"..
        foreach_arg2print(menu_list)..
        ""
    );]]

    --拼接菜单项
    local menu_item_html = "";
    if #menu_list > 0 then
        for key,value in pairs(menu_list) do
            --菜单文字
            local menu_name = formatNull(menu_list[key]["menu_name"]);
            --菜单点击事件
            local menu_click = formatNull(menu_list[key]["menu_click"]);
            --菜单图标
            local menu_icon = formatNull(menu_list[key]["menu_icon"]);
            --菜单图标控件名
            local menu_icon_name = formatNull(menu_list[key]["menu_icon_name"]);
            --菜单图标类型 sign带标记的菜单
            local menu_icon_style = formatNull(menu_list[key]["menu_icon_style"]);
            --菜单层对象名
            local menu_div_name = formatNull(menu_list[key]["menu_div_name"]);
            --菜单文字对象名
            local menu_label_name = formatNull(menu_list[key]["menu_label_name"]);

            local menu_icon_html = "";
            local menu_label_class = "";

            --没有图标，文字铺满
            if menu_icon ~= "" then
                menu_icon_html = [[<img src="local:]]..menu_icon..[[" class="top_menu_icon" name="]]..menu_icon_name..[[" />]];
                menu_label_class = "top_menu_icon_label";
            else
                if menu_icon_style == "sign" then
                    menu_icon_html = [[<img src="local:right_menu_untouch.png" class="top_menu_status_icon" name="]]..menu_icon_name..[[" />]];
                    menu_label_class = "top_menu_label";
                else
                    menu_icon_html = "";
                    menu_label_class = "top_menu_label";
                end;
            end;

            menu_item_html = menu_item_html..[[
                <div class="top_menu_item_div" border="1" name="]]..menu_div_name..[[" onclick="]]..menu_click..[[">
                    ]]..menu_icon_html..[[
                    <label class="]]..menu_label_class..[[" name="]]..menu_label_name..[[">]]..menu_name..[[</label>
                </div>
            ]];

            if key ~= menu_counts then
                --加个线条
                menu_item_html = menu_item_html..[[<line class="line_css" />]];
            end;
        end;

        menu_item_html = [[
            <div class="top_menu_item_list_div" border="1">]]..
                menu_item_html..[[
            </div>
        ]];

        --获取背景容器对象
        local top_menu_bg_div = document:getElementsByName(menu_bg_name)[1];

        local html = [[
            <div class="top_menu_bg_div" name="]]..menu_bg_name..[[" border="0" onclick="]]..menu_child_fun..[[">
                <div class="top_div_]]..systemTable['SysLayoutStyle']..[[" border="0" name="menu_top_div" />

                <div class="top_menu_page_content_div" name="]]..menu_parent_name..[[" border="0" onclick="]]..menu_child_fun..[[">
                    <div class="top_menu_content_div" name="]]..menu_child_name..[[" border="0" onclick="]]..menu_child_fun..[[">
                        <div class="top_menu_div" name="top_menu_div" border="0" onclick="">
                            <div class="top_menu_padding_top_div" border="0">
                                <img src="local:menu_bg_bubble.png" class="top_menu_bubble_icon" />
                            </div>]]..
                            menu_item_html..[[
                        </div>
                    </div>
                </div>
            </div>
        ]];
        --debug_alert(html);

        top_menu_bg_div:setInnerHTML(html);

        --创建头
        if menu_right_style == "default" then
            create_page_title(menu_back_fun, "title_bar", menu_title, "", "menu_bar", "", menu_back_fun, "menu_top_div");
        elseif menu_right_style == "none" then
            create_page_title(menu_back_fun, "title_bar", menu_title, "", "", "", "", "menu_top_div");
        end;

        --控件适配头部
        height_adapt(menu_parent_name);
        --背景适配全屏
        height_adapt(menu_bg_name,0,0);
    end;
    page_reload();
end;

--[[右侧头部菜单显示隐藏控制]]
function lua_page.top_right_menu_ctrl(arg)
    local arg = formatNull(arg);

    --操作页背景容器
    local menu_bg_name = formatNull(arg["menu_bg_name"],"top_menu_bg_div");
    --操作页子控件
    local menu_child_name = formatNull(arg["menu_child_name"],"top_menu_content_div");

    --控件动画结束后的回调方法
    local menu_ctrl_call = formatNull(arg["menu_ctrl_call"]);
    --控件动画结束后的回调参数
    local menu_ctrl_call_arg = formatNull(arg["menu_ctrl_call_arg"]);

    --[[debug_alert(
        "lua_page.top_right_menu_ctrl\n"..
        "menu_bg_name : "..menu_bg_name.."\n"..
        "menu_child_name : "..menu_child_name.."\n"..
        "menu_ctrl_call : "..menu_ctrl_call.."\n"..
        "menu_ctrl_call_arg : "..menu_ctrl_call_arg.."\n"..
        ""
    );]]

    local DisplayFlag = getStyle(menu_bg_name,"display");
    --debug_alert("lua_page.top_right_menu_ctrl display : "..DisplayFlag);

    local animation_fun = "";
    if DisplayFlag == "block" then
        set_android_Physical_back();
        animation_fun = "lua_animation.hide_screen_page";
        changeAllProperty("head_menu_img","src","local:menu_bar_white.png");
    else
        set_android_Physical_back("lua_page.top_right_menu_ctrl()");
        animation_fun = "lua_animation.show_screen_page";
        changeAllProperty("head_menu_img","src","local:menu_bar_black.png");
    end;

    --执行动画
    lua_format.str2fun(animation_fun)(menu_bg_name,menu_child_name,"right",menu_ctrl_call,menu_ctrl_call_arg);
end;

--[[头部右侧展开菜单路由]]
function lua_page.top_right_menu_router(ctrl,type)
    --操作码
    local ctrl = formatNull(ctrl);
    --菜单类型，调试功能入参为debug
    local type = formatNull(type,"release");

    local menu_ctrl_call = "";
    local menu_ctrl_call_arg = "";
    if ctrl ~= "" then        
        if type == "release" then
            menu_ctrl_call = "lua_menu.top_right_menu_action";
        else
            --环境允许调试的情况下开启
            if systemTable["EnvAllowDebug"] == "true" then
                --调试功能写在调试页面里
                menu_ctrl_call = "top_right_menu_debug_action";
            end;
        end;
        menu_ctrl_call_arg = ctrl;
    end;

    --动画结束后执行回调
    local menu_ctrl_arg = {
        menu_ctrl_call = menu_ctrl_call,
        menu_ctrl_call_arg = menu_ctrl_call_arg
    };
    lua_page.top_right_menu_ctrl(menu_ctrl_arg);
end;

--[[渲染弹出菜单]]
function lua_page.render_alert_menu(arg)
    --菜单信息
    local menu_info = formatNull(arg["menu_list"]);

    --拼接菜单项
    local menu_item_html = "";
    for key,value in pairs(menu_info) do
        local menu_name = menu_info[key]["menu_name"];
        local menu_click = menu_info[key]["menu_click"];

        menu_item_html = menu_item_html..[[
            <div class="alert_menu_item_div" border="1" onclick="]]..menu_click..[[">
                <label class="alert_menu_label">]]..menu_name..[[</label>
            </div>
        ]];
        if key ~= #menu_info then
            --加个线条
            menu_item_html = menu_item_html..[[<line class="line_css" />]];
        end;
    end;

    local html = [[
        <div class="alert_menu_bg_div" name="alert_menu_bg_div" border="0" onclick="lua_page.alert_menu_bg_ctrl('alert_menu_bg_div')">
            <div class="alert_menu_div" name="alert_menu_div" border="1" onclick="">
                <div class="alert_menu_item_list_div" name="alert_menu_item_list_div" border="1">]]..
                    menu_item_html..[[
                </div>
            </div>
        </div>
    ]];
    --debug_alert(html);

    --获取背景容器对象
    local alert_menu_bg_div = document:getElementsByName("alert_menu_bg_div")[1];
    alert_menu_bg_div:setInnerHTML(html);

    --控件全屏适配
    height_adapt("alert_menu_bg_div",0,0);
    --控件居中适配
    lua_page.widget_center_adapt("alert_menu_div","x/y");
end;

--[[灰色遮罩背景控制]]
function lua_page.alert_menu_bg_ctrl(bgwidgetName)
    local bgwidgetName = formatNull(bgwidgetName);
    if bgwidgetName ~= "" then
        local DisplayFlag = getStyle(bgwidgetName,"display");

        if DisplayFlag == "block" then
            --隐藏
            set_android_top_bar_image("topBar_Bg.png");
            hide_ele(bgwidgetName);
        else
            --显示
            set_android_top_bar_color("#4C4B59");
            show_ele(bgwidgetName);
        end;
    else
        debug_alert("未找到遮罩背景");
    end;
end;

--[[控件全屏居中适配]]
function lua_page.widget_center_adapt(widgetName,direction,parentWidgetName)
    --目标控件名
    local widgetName = formatNull(widgetName);
    --目标控件高度
    local widgetHeight = tonumber(getEleLocation(widgetName,"height"));
    --目标控件宽度
    local widgetWidth = tonumber(getEleLocation(widgetName,"width"));

    --居中方向x,y,x/y
    local direction = formatNull(direction);

    --父控件名
    local parentWidgetName = formatNull(parentWidgetName);
    --目标控件高度
    local parentWidgetHeight = tonumber(formatNull(getEleLocation(parentWidgetName,"height"),0));
    --目标控件宽度
    local parentWidgetWidth = tonumber(formatNull(getEleLocation(parentWidgetName,"width"),0));

    --剩余高度
    local screenSurHeight = "";
    --剩余宽度
    local screenSurWidth = "";

    --适配类型
    local centerAdaptStyle = "";

    if parentWidgetName ~= "" then
        centerAdaptStyle = "基于父控件";

        --取父控件宽高减去目标控件宽高
        screenSurHeight = tonumber(parentWidgetHeight - widgetHeight);
        screenSurWidth = tonumber(parentWidgetWidth - widgetWidth);
    else
        centerAdaptStyle = "基于屏幕";

        --未指定父控件默认全屏适配，取屏幕剩余宽高
        screenSurHeight = height_adapt(widgetName,0,0,"calculate")-widgetHeight;
        screenSurWidth = C_screenBaseWidth - widgetWidth;
    end;

    --设置高度
    local top = float((screenSurHeight/2),0);
    --设置左边距
    local left = float((screenSurWidth/2),0);

    --[[debug_alert(
        "控件"..direction.."居中适配\n"..
        "适配类型 : "..centerAdaptStyle.."\n"..
        "\n"..
        "目标控件 : "..widgetName.."\n"..
        "控件高度 : "..widgetHeight.."\n"..
        "控件宽度 : "..widgetWidth.."\n"..
        "\n"..
        "父控件名 : "..parentWidgetName.."\n"..
        "控件高度 : "..parentWidgetHeight.."\n"..
        "控件宽度 : "..parentWidgetWidth.."\n"..
        "\n"..
        "剩余高度 : "..screenSurHeight.."\n"..
        "剩余宽度 : "..screenSurWidth.."\n"..
        "设置top : "..top.."\n"..
        "设置left : "..left.."\n"..
        ""
    );]]

    if direction=="y" and top~="" then
        --设置y居中
        setEleLocation(widgetName,"top",top);
    elseif direction=="x" and left~="" then
        --设置x居中
        setEleLocation(widgetName,"left",left);
    elseif direction=="x/y" and top~="" and left~="" then
        --设置x/y居中
        setEleLocation(widgetName,"top",top);
        setEleLocation(widgetName,"left",left);
    else
        debug_alert("不支持的方向");
        return;
    end;
end;

--[[
    页面级别的div控制，主要用于客户端全屏控件显示隐藏
    pageDivEleName   : 显示page级div的控件名
    pageDivNeedAdapt : 控件是否需要重新适配高度，默认需要
    bodyNeedAdapt    : 控件关闭时body是否需要重新适配高度，默认不需要

]]
function lua_page.div_page_ctrl(pageDivEleName, pageDivNeedAdapt, bodyNeedAdapt)
    --当前是否有page级div显示
    local pageDivEleName = formatNull(pageDivEleName);
    local ShowPageDivEleName = formatNull(globalTable["ShowPageDivEleName"]);
    local pageDivNeedAdapt = formatNull(pageDivNeedAdapt, "false");
    local bodyNeedAdapt = formatNull(bodyNeedAdapt, "false");

    --[[debug_alert(
        "lua_page.div_page_ctrl\n"..
        "pageDivEleName : "..pageDivEleName.."\n"..
        "ShowPageDivEleName : "..ShowPageDivEleName.."\n"..
        "pageDivNeedAdapt : "..pageDivNeedAdapt.."\n"..
        "bodyNeedAdapt : "..bodyNeedAdapt.."\n"..
        ""
    );]]
    
    if ShowPageDivEleName ~= "" then
        --debug_alert("有page级div显示");
        lua_system.hide_keyboard();
        --隐藏该div
        hide_ele(ShowPageDivEleName);
        --清理缓存记录
        globalTable["ShowPageDivEleName"] = "";
        --物理键还原
        local ADPhysicalBackFunBeforeDivPageShow = formatNull(globalTable["ADPhysicalBackFunBeforeDivPageShow"]);
        local ADPhysicalBackArgBeforeDivPageShow = formatNull(globalTable["ADPhysicalBackArgBeforeDivPageShow"]);
        --[[debug_alert(
            "还原后的物理键\n"..
            "方法 : "..ADPhysicalBackFunBeforeDivPageShow.."\n"..
            "参数 : "..ADPhysicalBackArgBeforeDivPageShow.."\n"..
            ""
        );]]
        set_android_Physical_back(ADPhysicalBackFunBeforeDivPageShow,ADPhysicalBackArgBeforeDivPageShow);
        --关闭后需要对body进行重新适配
        if bodyNeedAdapt == "true" then
            height_adapt("body",0,0);
        end;
    else
        --debug_alert("没有page级div显示");

        if pageDivEleName ~= "" then
            --对div进行适配
            if pageDivNeedAdapt == "true" then
                height_adapt(pageDivEleName,0,0);
            end;
            --显示该div
            show_ele(pageDivEleName);
            --存储显示page级div控件名到缓存
            globalTable["ShowPageDivEleName"] = pageDivEleName;
            --存储当前物理键信息
            local ADPhysicalBackFunBeforeDivPageShow = formatNull(globalTable["ADPhysicalBackFun"]);
            local ADPhysicalBackArgBeforeDivPageShow = formatNull(globalTable["ADPhysicalBackArg"]);
            --[[debug_alert(
                "显示前的物理键\n"..
                "方法 : "..ADPhysicalBackFunBeforeDivPageShow.."\n"..
                "参数 : "..ADPhysicalBackArgBeforeDivPageShow.."\n"..
                ""
            );]]
            globalTable["ADPhysicalBackFunBeforeDivPageShow"] = ADPhysicalBackFunBeforeDivPageShow;
            globalTable["ADPhysicalBackArgBeforeDivPageShow"] = ADPhysicalBackArgBeforeDivPageShow;
            --将Android物理返回键设置为关闭page级div
            set_android_Physical_back("lua_page.div_page_ctrl");
        else
            --物理键还原
            local ADPhysicalBackFunBeforeDivPageShow = formatNull(globalTable["ADPhysicalBackFunBeforeDivPageShow"]);
            local ADPhysicalBackArgBeforeDivPageShow = formatNull(globalTable["ADPhysicalBackArgBeforeDivPageShow"]);
            set_android_Physical_back(ADPhysicalBackFunBeforeDivPageShow,ADPhysicalBackArgBeforeDivPageShow);
        end;
    end;
end;

--[[根据路径渲染发票图片]]
function lua_page.render_invoice_img_by_path(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        --debug_alert("getInvImgDlLinkByPath req");
        --缓存的发票信息
        local UploadInvoiceInfo = vt("UploadInvoiceInfo",globalTable);
        --绝对路径，识别火车票为absolutePath，其他票据为path
        local path = vt("path",UploadInvoiceInfo);
        local absolutePath = vt("absolutePath",UploadInvoiceInfo);
        local FileAbsPath = "";
        if absolutePath ~= "" then
            FileAbsPath = absolutePath;
        else
            FileAbsPath = path;
        end;
        --[[debug_alert(
            "path : "..path.."\n"..
            "absolutePath : "..absolutePath.."\n"..
            "FileAbsPath : "..FileAbsPath.."\n"..
            ""
        );]]
        if FileAbsPath ~= "" then
            invoke_trancode_noloading(
                "jjbx_process_query",
                "jjbx_fpc",
                {
                    TranCode="GetRelatedInvImg",
                    FileAbsPath=FileAbsPath,
                    ofdFileKey = vt("fileKey",UploadInvoiceInfo),
                    OFD2PDF="false",
                    netFlag = "1"
                },
                lua_page.render_invoice_img_by_path,
                {}
            );
        else
            --alert("无文件路劲");
            batch_hide_ele("invoice_preview_space_div,invoice_preview_div");
        end;
    else
        local res = json2table(vt("responseBody",ResParams));

        --debug_alert("getInvImgDlLinkByPath res :\n"..foreach_arg2print(res));
        local isInvoiceFile = vt("isInvoiceFile",res);
        local PCInvoiceFileType = vt("FileOriginalType",res);
        local PCInvoiceFileDlUrl = vt("PCInvoiceFileDlUrl",res);
        local FileOriginalType = vt("FileOriginalType",res);
        local doReplace = vt("DoReplace",res);

        --[[debug_alert(
            "文件是否存在 : "..isInvoiceFile.."\n"..
            "发票下载链接 : "..PCInvoiceFileDlUrl.."\n"..
            "预览文件类型 : "..PCInvoiceFileType.."\n"..
            "文件原始类型 : "..FileOriginalType.."\n"..
            "是否转换文件 : "..doReplace.."\n"..
            ""
        );]]

        if PCInvoiceFileDlUrl ~= "" then
            --文件存在且下载链接不为空则加载视图
            local preview_div_html = "";
            local onclick_html = "";

            --获取到原文件时，打开预览文件
            if isInvoiceFile == "true" then
                onclick_html = "onclick=\"lua_system.file_preview('"..PCInvoiceFileDlUrl.."','"..PCInvoiceFileType.."')\"";
            else
                --获取不到原文件时，跳转页面展示发票信息
                local UploadInvoiceInfo = vt("UploadInvoiceInfo",globalTable);
                --发票类型编码
                local InvoiceType = vt("fplxbm",UploadInvoiceInfo);
                --文件原路径
                local FileOriginalPath = vt("filePath",UploadInvoiceInfo);
                --附件编码
                local fileKey = vt("fileKey",UploadInvoiceInfo);
                --发票ID
                local invoiceId = vt("invoiceId",UploadInvoiceInfo);
                onclick_html = "onclick=\"lua_upload.get_related_inv_img('"..fileKey.."','"..FileOriginalPath.."')\"";
            end;

            if string.lower(FileOriginalType)=="png" or string.lower(FileOriginalType)=="jpg" or string.lower(FileOriginalType)=="jpeg" then
                --debug_alert("源文件为png格式调用客户端图片预览");
                preview_div_html = [[<imageView width="80" height="80" class="invoice_image" name="invoice_image" radius="6" ]]..onclick_html.. [[ value="]]..PCInvoiceFileDlUrl..[[" />]];
            else
                --上传文件原名称
                local AppUploadOriginalFileName = formatNull(globalTable["UploadInvoiceInfo"]["AppUploadOriginalFileName"]);
                --debug_alert("上传文件原名称 : "..AppUploadOriginalFileName);
                local PCInvoiceFileName = formatNull(jjbx_utils_setStringLength(AppUploadOriginalFileName,12));

                local fileIconName = "";
                local fileTip = PCInvoiceFileName;

                if FileOriginalType == "ofd" then
                    --debug_alert("源文件为ofd格式展示ofd图标");
                    fileIconName = "file_ofd_icon.png";
                elseif FileOriginalType == "pdf" then
                    --debug_alert("源文件为pdf格式分析是否为ofd转换的");
                    if doReplace == "true" then
                        --展示ofd图标
                        fileIconName = "file_ofd_icon.png";
                    else
                        --展示pdf图标
                        fileIconName = "file_pdf_icon.png";
                    end;
                    --debug_alert("源文件为pdf格式展示pdf图标");
                    fileIconName = "file_pdf_icon.png";
                else
                    --debug_alert("源文件为其他格式展示other file图标");
                    fileIconName = "file_other_icon.png";
                end;

                preview_div_html = [[
                    <div class="file_icon_div" border="0" ]]..onclick_html..[[>
                        <img src="local:]]..fileIconName..[[" class="file_icon" ]]..onclick_html..[[/>
                    </div>
                    <div class="file_tip_div" border="0" ]]..onclick_html..[[>
                        <label class="file_tip_label" value="]]..fileTip..[[" ]]..onclick_html..[[ />
                    </div>
                ]];
            end;

            preview_div_html = [[
                <div class="invoice_preview_div" border="1" name="invoice_preview_div" ]]..onclick_html..[[>
                    ]]..preview_div_html..[[
                </div>
            ]];
            --debug_alert(preview_div_html);
            document:getElementsByName("invoice_preview_div")[1]:setInnerHTML(preview_div_html);
            batch_show_ele("invoice_preview_space_div,invoice_preview_div");
        else
            batch_hide_ele("invoice_preview_space_div,invoice_preview_div");
        end;
        page_reload();
    end;
end;

--手势密码控件缩略图参数
SetGestureDisplayWidgetArg = {
    --客户端比对值，会显示在缩略图
    setKey="",
    outCycleNormal="#CCCCCC",
    holloColor="#979797",
    solidColor="#979797",
    display="true",
    innerCycleTouched="#979797",
    width="29",
    height="29"
};

--手势密码控件，显示提示文字的参数
SetGestureTipWidgetArg = {
    --字体颜色
    textColor="",
    --字体大小
    textSize="15",
    --提示内容
    textContent="",
    --提示是否抖动
    isShake="",
    --高度
    height="21",
    --高度
    width="375"
};

--手势密码控件参数
SetGestureWidgetArg = {
    setKey="",
    func="gesture_set_widget_call",
    outCycleNormal="",
    outCycleOntouch="",
    innerCycleTouched="",
    innerCycleNoTouch="",
    lineColor="",
    errorlineColor="",
    innerCycleErrorColor="",
    innerCycleOnTouchBgColor=""
};

--[[初始化手势密码设置控件]]
function lua_page.init_gesture_set_widgets()
    height_adapt("gesture_set_body_div");

    --手势密码缩略图参数
    SetGestureDisplayWidgetArg.setKey="";
    SetGestureDisplayWidgetArg.holloColor="#979797";
    SetGestureDisplayWidgetArg.solidColor="#979797";
    local lockDisplayJson = table2json(SetGestureDisplayWidgetArg);

    --提示文字参数
    SetGestureTipWidgetArg.textColor="#A5A5A5";
    SetGestureTipWidgetArg.isShake="false";
    local tipContentJson = table2json(SetGestureTipWidgetArg);

    --绘制控件参数
    SetGestureWidgetArg.outCycleNormal="#FE6F14";
    SetGestureWidgetArg.outCycleOntouch="#FE6F14";
    SetGestureWidgetArg.innerCycleTouched="#FE6F14";
    SetGestureWidgetArg.innerCycleNoTouch="#FFFFFF";
    SetGestureWidgetArg.lineColor="#FE6F14";
    SetGestureWidgetArg.errorlineColor="#E70012";
    SetGestureWidgetArg.innerCycleErrorColor="#E70012";
    SetGestureWidgetArg.innerCycleOnTouchBgColor="#FFFFFFF";
    local gestureLockJson = table2json(SetGestureWidgetArg);

    --初始化手势密码控件
    local gesture_set_body_div_html = [[
        <div class="gesture_set_body_div" name="gesture_set_body_div" border="0">
            <div class="space_80_div" border="0" />

            <!-- 手势密码缩略图 -->
            <div class="gesture_set_display_div" name="gesture_set_display_div" border="0">
                <gestureLockDisplay border="0" name="gestureLockDisplay_widget" class="gesture_set_display_widget_]]..systemTable['SysLayoutStyle']..[[" width="39" value=']]..lockDisplayJson..[['/>
            </div>

            <!-- 手势密码提示文字 -->
            <div class="gesture_set_text_shake_div" name="gesture_set_text_shake_div" border="0">
                <textShake border="0" name="gesture_set_text_shake_widget" class="gesture_set_text_shake_widget" value=']]..tipContentJson..[['/>
            </div>

            <div class="space_40_div" border="0" />

            <!-- 手势密码操作区域 -->
            <div class="gesture_set_div" name="gesture_set_div" border="0">
                <gestureLock border="0" name="gesture_set_widget" class="gesture_set_widget" width="271" value=']]..gestureLockJson..[['/>
            </div>
        </div>
    ]];
    document:getElementsByName("gesture_set_body_div")[1]:setInnerHTML(gesture_set_body_div_html);

    page_reload();
end;

--[[渲染select页面]]
function lua_page.render_select_page(renderSelectArg)
    --debug_alert("渲染select页面\n"..foreach_arg2print(renderSelectArg));

    --容器名称
    local bgName = vt("bgName",renderSelectArg);
    --头部控件名称
    local topEleName = vt("topEleName",renderSelectArg);
    --头部标题名称
    local topTitleName = vt("topTitleName",renderSelectArg);
    --select控件名称
    local selectEleName = vt("selectEleName",renderSelectArg);
    --select控件参数
    local selectEleArg = vt("selectEleArg",renderSelectArg);
    --select控件个数
    local selectEleCounts = #selectEleArg;
    --渲染完回调方法
    local renderCallBackFun = vt("renderCallBackFun",renderSelectArg);
    --渲染完回调方法参数
    local renderCallBackFunArg = {
        selectItemCounts=selectEleCounts
    };
    --选择类型 多选multiple 单选single
    local selectType = vt("selectType",renderSelectArg);
    local finishCall = vt("finishCall",renderSelectArg,"lua_page.div_page_ctrl()");
    local finishBtnStyle = vt("finishBtnStyle",renderSelectArg,"TopRightBtn");

    --创建页面头参数
    local CreateTopArg = {
        bar_center_text=topTitleName,
        bar_top_name=topEleName
    };

    --返回按钮事件
    local backCall = vt("backCall",renderSelectArg,"lua_page.div_page_ctrl()");

    --选择图标
    local selectedIcon = "";
    --选择层样式
    local selectDivClass = "";

    if selectType == "multiple" then
        --多选未选中图标
        selectedIcon = "sl_ico_checkBox.png";
        --多选的层默认显示
        selectDivClass = "common_select_item_select_icon_sdiv";
        --多选不显示返回按钮，提供完成按钮
        CreateTopArg["bar_back_fun"] = backCall;
        if finishBtnStyle == "TopRightBtn" then
            CreateTopArg["bar_right_type"] = "label_bar";
            CreateTopArg["bar_right_text"] = "完成";
            CreateTopArg["bar_right_fun"] = finishCall;
        end;
    else
        selectedIcon = "start_pCircle_icon.png";
        --单选的层默认隐藏
        selectDivClass = "common_select_item_select_icon_hdiv";
        CreateTopArg["bar_back_fun"] = backCall;
    end;

    --创建页面头
    lua_page.create_top(CreateTopArg);
    --容器适配全屏
    height_adapt(bgName,0,0);
    --控件适配
    if selectType=="multiple" and finishBtnStyle=="BottomFullBtn" then
        --debug_alert("多选且完成按钮样式为全屏按钮时，适配去掉底部按钮");
        height_adapt(selectEleName,45+50);
    else
        height_adapt(selectEleName);
    end;

    --div边框调试
    local divBorder = "0";
    local selectItemHtml = "";

    for i=1,selectEleCounts do
        local selectEleArgItem = selectEleArg[i];
        --显示文字
        local labelName = vt("labelName",selectEleArgItem);
        --提示文字
        local tipName = vt("tipName",selectEleArgItem);
        --点击函数
        local clickFunc = vt("clickFunc",selectEleArgItem);
        --点击函数入参
        local clickFuncArg = vt("clickFuncArg",selectEleArgItem);
        --点击方法
        local onclickFun = clickFunc.."('"..clickFuncArg.."')";
        if i == 1 then
            --默认选中的方法名
            renderCallBackFunArg["selectFirstFuncName"] = clickFunc;
            --默认选中的方法参数
            renderCallBackFunArg["selectFirstFuncArg"] = clickFuncArg;
        end;

        --选项文字样式
        local labelNameClass = "";
        --提示文字样式
        local tipNameClass = "";        
        if tipName ~= "" then
            labelNameClass = "common_select_item_name_label";
            tipNameClass = "common_select_item_tip_label";
        else
            labelNameClass = "common_select_item_label";
        end;

        --暴露渲染方法，支持自定义布局
        local renderItemFunc = vt("renderItemFunc",selectEleArgItem);
        --选项DIV
        local selectItemIconDiv = vt("selectItemIconDiv",renderSelectArg,"common_select_item_select_icon_div");
        --显示勾选DIV
        local selectItemIcon = vt("selectItemIcon",renderSelectArg,"common_select_item_select_icon");
        local renderItemHtml = "";
        if renderItemFunc == "" then
            renderItemHtml = [[
                <div class="common_select_item_div" border="]]..divBorder..[[" onclick="]]..onclickFun..[[">
                    <div class="common_select_item_label_div" border="]]..divBorder..[[" onclick="]]..onclickFun..[[">
                        <label class="]]..labelNameClass..[[" onclick="]]..onclickFun..[[">]]..labelName..[[</label>
                        <label class="]]..tipNameClass..[[" onclick="]]..onclickFun..[[">]]..tipName..[[</label>
                    </div>
                    <div class="]]..selectDivClass..[[" name="]]..selectItemIconDiv..[[" border="]]..divBorder..[[" onclick="]]..onclickFun..[[">
                        <img src="local:]]..selectedIcon..[[" class="common_select_item_select_icon" name="]]..selectItemIcon..[[" onclick="]]..onclickFun..[["/>
                    </div>
                </div>
                <line class="line_css" />
            ]];
        else
            renderItemHtml = lua_system.do_function(renderItemFunc,selectEleArgItem);
        end;
        selectItemHtml = selectItemHtml..renderItemHtml;
    end;
    --debug_alert("selectEleArg\n"..foreach_arg2print(selectEleArg));
    local selectListHtml = [[
        <div class="common_select_list_div" border="]]..divBorder..[[" name="]]..selectEleName..[[">
            ]]..selectItemHtml..[[
        </div>
    ]];
    document:getElementsByName(selectEleName)[1]:setInnerHTML(selectListHtml);
    page_reload();

    --渲染完回调
    lua_system.do_function(renderCallBackFun,renderCallBackFunArg);
end;

--[[通过显示隐藏设置选中效果]]
function lua_page.set_item_selected(setArg)
    local selected = "false";

    --显示的下标
    local showIndex = vt("showIndex",setArg);

    --操作的层控件名
    local selectDivEleName = vt("eleName",setArg,"common_select_item_select_icon_div");
    --操作的图标控件名
    local selectIconEleName = vt("iconEleName",setArg,"common_select_item_select_icon");
    --选择类型 multiple single
    local selectTyle = vt("selectTyle",setArg,"single");

    --操作对象集合
    local divCtrlEles = document:getElementsByName(selectDivEleName);
    local iconCtrlEles = document:getElementsByName(selectIconEleName);

    if selectTyle == "single" then
        --单选时，选择区域统一初始化为隐藏，通过显示隐藏来表明状态
        --循环初始化
        for i=1,#divCtrlEles do
            divCtrlEles[i]:setStyleByName("display","none");
        end;
    end;

    --[[debug_alert(
        "通过显示隐藏设置选中效果\n"..
        "下标 : "..tostring(showIndex).."\n"..
        "层名称 : "..selectDivEleName.."\n"..
        "图标名 : "..selectIconEleName.."\n"..
        "类型 : "..selectTyle.."\n"..
        ""
    );]]

    --匹配下标
    for i=1,#divCtrlEles do
        --当选中的列表下标等于显示的元素下标时，显示勾选/取消勾选
        if i == tonumber(showIndex) then
            if selectTyle == "single" then
                selected = "true";
                divCtrlEles[i]:setStyleByName("display","block");
            else
                local nowIcon = iconCtrlEles[i]:getPropertyByName("src");
                if nowIcon == "sl_ico_checkBoxOrange.png" then
                    --前次状态：选中
                    selected = "false";
                    iconCtrlEles[i]:setPropertyByName("src","sl_ico_checkBox.png");
                else
                    --前次状态：未选中
                    selected = "true";
                    iconCtrlEles[i]:setPropertyByName("src","sl_ico_checkBoxOrange.png");
                end;
            end;
        end;
    end;

    return selected;
end;

--[[创建人员搜索界面]]
function lua_page.create_search_people_page(Arg)
    --是否显示人员
    local ShowUser = vt("ShowUser",Arg,"false");
    --显示人员标题
    local UserNameKey = vt("UserNameKey",Arg,"申请人");
    local UserNameValue = vt("UserNameValue",Arg,"*** ***");
    --默认显示的工号
    local DefaultShowCdrWrokId = vt("DefaultShowCdrWrokId",Arg);
    --默认显示的人员信息
    local DefaultShowCdrInfo = vt("DefaultShowCdrInfo",Arg);

    --[[debug_alert(
        "创建人员搜索界面"..foreach_arg2print(Arg).."\n"..
        ""
    );]]

    local Border = "0";
    local ShowUserHtml = "";
    if ShowUser == "true" then
        ShowUserHtml = [[
            <div class="space_05_div" border="]]..Border..[["/>
            <div class="search_people_content_div" border="]]..Border..[[">
                <label class="search_people_klabel" name="search_people_klabel" value="]]..UserNameKey..[[" />
                <label class="search_people_vlabel" name="search_people_vlabel" value="]]..UserNameValue..[[" />
            </div>
            <div class="space_05_div" border="]]..Border..[[" />

            <div class="search_people_content_space_div" border="]]..Border..[[" />
        ]];
    end;

    local DefaultShowCdrHtml = "";
    if DefaultShowCdrWrokId~="" and DefaultShowCdrInfo~="" then
        DefaultShowCdrHtml = [[
            <div class="search_people_option_div" border="]]..Border..[[" onclick="lua_jjbx.select_cdr('cdr_by_self')">
                <label class="search_people_res_info1_label" name="workID">]]..DefaultShowCdrWrokId..[[</label>
                <label class="search_people_res_info2_label" name="nameAndDept">]]..DefaultShowCdrInfo..[[</label>
                <div class="space_05_div" border="]]..Border..[[" />
                <line class="search_people_line" />
            </div>
        ]];
    end;

    local SearchPeoplePageHtml = [[
        <div class="search_people_page_div" border="]]..Border..[[" name="search_people_page_div" onclick="lua_page.div_page_ctrl()">
            <div class="top_div_]]..systemTable['SysLayoutStyle']..[[" border="]]..Border..[[" name="top_search_people_page_div" />

            <div class="search_people_body_div" border="]]..Border..[[" onclick="">
                ]]..ShowUserHtml..[[
                <div class="space_05_div" border="]]..Border..[[" />
                <div class="search_people_content_div" border="]]..Border..[[" >
                    <label class="search_people_klabel">承担人</label>
                    <input type="text" class="search_people_vtext" name="search_cdr_text" value="" hold="请搜索" holdColor="#9B9B9B" onchange="lua_jjbx.search_cdr('search_cdr_text')" border="]]..Border..[[" />
                    <img src="local:arrow_common.png" class="search_people_arrow_icon" />
                </div>
                <line class="search_people_line" />
            </div>

            <!-- 显示可选承担人 -->
            <div class="search_people_list_div" border="]]..Border..[[" name="search_people_list_div" onclick="">
                ]]..DefaultShowCdrHtml..[[
            </div>
        </div>
    ]];

    document:getElementsByName("search_people_page_div")[1]:setInnerHTML(SearchPeoplePageHtml);
    page_reload();

    --创建头
    title_head(Arg["TitleName"],"lua_page.div_page_ctrl()","top_search_people_page_div");
end;

--[[设置筛选列表的默认选中样式]]
function lua_page.set_filt_content(tagName,index)
    local tagNameDiv = document:getElementsByName(tagName.."Div");
    local selectOrange = document:getElementsByName("select_orange_"..tagName);
    for i=1,#tagNameDiv do
        if i == tonumber(index) then
            tagNameDiv[i]:setStyleByName("background-color","#F5F5F5");
            selectOrange[i]:setStyleByName("display","block");
        else
            tagNameDiv[i]:setStyleByName("background-color","#FFFFFF");
            selectOrange[i]:setStyleByName("display","none");
        end;
    end;
end;

--[[获取当前页面缓存信息]]
function lua_page.current_page_info(Arg)
    --[[debug_alert(
        "lua_page.current_page_info\n"..
        "history:length = "..tostring(history:length()).."\n"..
        "pageinfoTable Arg\n"..foreach_arg2print(pageinfoTable).."\n"..
        ""
    );]]
    return formatNull(pageinfoTable[tonumber(history:length())]);
end;

--[[当前页面缓存信息追加]]
function lua_page.set_current_page_arg(key,value)
    local key = formatNull(key);
    local value = formatNull(value);
    if key ~= "" then
        --栈值
        local HistoryLength = tonumber(history:length());
        --追加缓存信息
        pageinfoTable[HistoryLength][key] = value;
    end;
end;

--[[页面刷新]]
function lua_page.reload_page()
    --[[debug_alert(
        "lua_page.reload_page\n"..
        "history:length = "..tostring(history:length()).."\n"..
        "pageinfoTable Arg\n"..foreach_arg2print(pageinfoTable).."\n"..
        ""
    );]]

    local CurrentPageInfo = lua_page.current_page_info();
    CurrentPageInfo = formatNull(CurrentPageInfo,{});

    local PageFilePath = vt("page_file_path",CurrentPageInfo);
    CurrentPageInfo["CloseLoading"] = "false";
    CurrentPageInfo["JumpStyle"] = "none";
    CurrentPageInfo["AddPage"] = "true";
    if PageFilePath ~= "" then
        invoke_page_donot_checkRepeat(PageFilePath,page_callback,CurrentPageInfo);
    else
        debug_alert("请求页面为空");
    end;
end;

--[[页面信息]]
function lua_page.info(QryPath)
    local QryPath = formatNull(QryPath);
    local PageName = "";
    if QryPath ~= "" then
        for i=1,#JJBX_PAGE_INFO do
            local PageInfo = formatNull(JJBX_PAGE_INFO[i]);
            local Name = vt("Name",PageInfo);
            local Path = vt("Path",PageInfo);
            if Path == QryPath then
                PageName = Name;
                break
            end;
        end;
    end;

    return {
        PageFilePath=QryPath,
        PageName=PageName
    };
end;

--[[获取元素是否为显示]]
function lua_page.check_display(elementName)
    local elementName = formatNull(elementName);
    local displayFlag = "";
    local ele = document:getElementsByName(elementName);
    local eleCounts = #ele;
    if eleCounts > 0 then
        --获取显示状态
        displayFlag = ele[1]:getStyleByName("display");
    else
        displayFlag = "";
    end;
    return displayFlag;
end;

--[[显示控件的文本]]
function lua_page.show_ele_text(elementName)
    local elementName = formatNull(elementName);
    if elementName ~= "" then
        alert(getValue(elementName))
    end;
end;

--[[计算控件高度]]
function lua_page.calculate_widget_height(Arg)
    local widgetNames = vt("widgetNames",Arg);
    local checkDisplay = vt("checkDisplay",Arg);
    local widgetNameList = splitUtils(widgetNames,",");
    local SumPx = 0;
    for i=1, #widgetNameList do
        local widgetName = widgetNameList[i];
        if widgetName ~= "" then
            local widgetHeight = tonumber(getEleLocation(widgetName,"height"));
            local displayFlag = lua_page.check_display(widgetName);
            --[[debug_alert(
                "widgetName : "..widgetName.."\n"..
                "widgetHeight : "..tostring(widgetHeight).."\n"..
                "displayFlag : "..displayFlag.."\n"..
                ""
            );]]
            if checkDisplay == "true" then
                if displayFlag == "block" then
                    --控件显示
                else
                    --检查不显示
                    widgetHeight = 0;
                end;
            else
                --不检查
            end;
            SumPx = SumPx+widgetHeight;
        end;
    end;
    return SumPx;
end;

-- 格式化文本显示样式
function lua_page.formatText_to_R_B(divName,str,styleCss)
    local styleCss = formatNull(styleCss);
    --格式化文本显示样式,加粗、标红
    --local str = "这段文字标R{红},这段文字B{加粗},这段文字RB{标红加粗},R{这段文字标红},B{这段文字加粗},BR{这段文字加粗标红}";
    str = string.gsub(str,"RB{","' /><label class='label_red_bold_css' "..styleCss.." value='");
    str = string.gsub(str,"BR{","' /><label class='label_red_bold_css' "..styleCss.." value='");
    str = string.gsub(str,"R{","' /><label class='label_red_css' "..styleCss.." value='");
    str = string.gsub(str,"B{","' /><label class='label_bold_css' "..styleCss.." value='");
    str = string.gsub(str,"}","' /><label class='label_css' "..styleCss.." value='");
    str = "<div class='contentDiv_css' border='0' name='"..divName.."'><label class='label_css' "..styleCss.." value='"..str.."' /></div>";
    document:getElementsByName(divName)[1]:setInnerHTML(str);
    page_reload();
end;