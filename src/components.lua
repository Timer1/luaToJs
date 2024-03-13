lua_components = {};

-- 添加label/select控件
function lua_components.add_element(pageElement)
	local pageElement = formatNull(pageElement,{});
	-- div的name
	local tagName = vt("tagName",pageElement);
	-- 是否显示必填(true/false)
	local tagRequired = vt("tagRequired",pageElement);
	tagRequired = formatNull(tagRequired,"true")
	if tagRequired == "true" then
		tagRequired = "*";
	else
		tagRequired = "";
	end;
	-- 是否可编辑
	local enable = vt("enable",pageElement,"true");
	-- 字段标题
	local tagTitle = vt("tagTitle",pageElement);
	-- 字段值
	local tagValue = vt("tagValue",pageElement);
	-- 是否显示箭头(true/false)
	local tagArrow = vt("tagArrow",pageElement,"true");
	local labelValueCss = vt("valueClass",pageElement,"");
	if tagArrow == "true" then
		labelValueCss = formatNull(labelValueCss,"label_value_arrow");
		tagArrow = "arrow_common_css";
	else
		labelValueCss = formatNull(labelValueCss,"label_value");
		tagArrow = "arrow_common_css,displayNone";
	end;
	--默认样式补充
	local valueStyle = vt("valueStyle",pageElement,"");
	--不可编辑且没有补充样式的时候，默认显示灰色
	if enable == "false" and valueStyle == "" then
		valueStyle = "color: #cccccc;";
	end;
	-- 点击事件
	local tagOnClick = vt("tagOnClick",pageElement);
	local onClickArg = vt("onClickArg",pageElement);
	if tagOnClick ~= "" then
		onClickArg = lua_format.table_arg_pack(onClickArg);
		tagOnClick = "onclick=\""..tagOnClick.."('"..onClickArg.."')\"";
	end;
	local htmlContent = "";
	local tagType = vt("tagType",pageElement);

	--是否显示分割线
	local lineDisplay = vt("lineDisplay",pageElement,"true");
	if lineDisplay == "true" then
		lineDisplay = "displayBlock";
	else
		lineDisplay = "displayNone";
	end;
	
	--div是否显示
	local divDisplay = vt("display",pageElement,"none");
	if divDisplay == "none" then
		divDisplay = "displayNone";
	else
		divDisplay = "";
	end;
	--div补充样式
	local style = vt("style",pageElement);

	--带字段说明按钮
	local explain = vt("explain",pageElement);
    local alertExplainClick = "";
    local explainHtml = "";
    if explain ~= "" then
    	explain = lua_format.base64_encode(explain);
    	alertExplainClick = "onclick=\"alert_explain('"..explain.."')\"";
    	explainHtml = [[
			<div class="inline-block,height-50,top-0" style="width: 15px;" border="0" ]]..alertExplainClick..[[>
	            <img src="local:unknown.png" class="unknown_css" ]]..alertExplainClick..[[/>
	        </div>
    	]];
    end;

    local tagTitleLen = ryt:getLengthByStr(tagTitle);
    local tempTagTitle = "";
    if tagTitleLen > 7 then
        tempTagTitle = ryt:getSubstringValue(tagTitle,0,7);
    else
        tempTagTitle = tagTitle;
    end;
    local textWidth = calculate_text_width(tempTagTitle,"14");
    local fontSize = "";
    if platform == "iPhone OS" then
    	textWidth = textWidth + 5;
    	--IOS超过14个字无法完整显示，需修改字体大小
    	if tagTitleLen > 14 then
            fontSize = "font-size: 13px;";
    	end;
    else
    	textWidth = textWidth + 8;
    end;
    --字段标题宽度+必填标识宽度
    local divWidth = tonumber(textWidth) + 5 + 15;
    --带有字段说明时，累加字段说明按钮宽度
    if explain ~= "" then
    	divWidth = divWidth + 20;
    end;
    local tagTitleWidth = "width: "..tostring(textWidth).."px";
    local tagTitleDivWidth = "width: "..tostring(divWidth).."px";

	if tagType == "label" or tagType == "select" then 
		htmlContent = [[
	            <div class="option_div,]]..divDisplay..[[" style="]]..style..[[" border="1" name="]]..tagName..[[_div" ]]..tagOnClick..[[ enable="]]..enable..[[">
	            	<div class="inline-block,height-50,top-0" style="]]..tagTitleDivWidth..[[" border="0">
	                    <div class="inline-block,height-50,top-0" style="width: 15px;" border="0"> 
		                	<label class="ifRequired_css" name="]]..tagName..[[_required" value="]]..tagRequired..[[" />
		                </div>
		                <div class="inline-block,height-50,top-0" style="]]..tagTitleWidth..[[" border="0">
		                	<label class="label_title,left-0" style="]]..fontSize..[[" name="]]..tagName..[[_title" value="]]..tagTitle..[[" ]]..alertExplainClick..[[ />
		                </div>]]..explainHtml..[[
		            </div>
	                <label class="]]..labelValueCss..[[" style="]]..valueStyle..[["  name="]]..tagName..[[" value="]]..tagValue..[[" />
	                <img src="local:arrow_common.png" class="]]..tagArrow..[[" name="arrow_common_]]..tagName..[[" />
	            	<line class="line_css,]]..lineDisplay..[[" />
	            </div>
	        ]];
	elseif tagType == "input" then
		--输入框提示语
		local hold = formatNull(vt("hold",pageElement),"请输入");
		--提示语颜色
		local holdColor = formatNull(vt("holdColor",pageElement),"#9B9B9B");
		--输入框边框
		local inputBorder = formatNull(vt("inputBorder",pageElement),"0");
		--最大输入长度
		local maxLength = vt("maxLength",pageElement);
		if maxLength ~= "" then
			maxLength = "maxleng=\""..maxLength.."\"";
		end;
		--input样式（int：整数类型、float：浮点型、date：日期控件）
		local inputStyle = vt("inputStyle",pageElement);
		--浮点型控制小数点位数，默认控制小数点后两位
		local pointValue = vt("pointValue",pageElement,"2");
		--onChange方法
		local onChange = vt("onchange",pageElement);
		if onChange ~= "" then
			onChange = "onchange=\""..onChange.."()\"";
		end;
		--debug_alert("onChange:"..onChange);
		--onBlur方法
		local onBlur = vt("onblur",pageElement);
		if onBlur ~= "" then
			onBlur = "onblur=\""..onBlur.."()\"";
		end;
		--是否可输入emoji表情包
		local disableEmoji = vt("disableEmoji",pageElement,"false");

		if inputStyle == "int" then
			htmlContent = [[
	            <div class="option_div,]]..divDisplay..[[" style="]]..style..[[" border="1" name="]]..tagName..[[_div" ]]..tagOnClick..[[ enable="]]..enable..[[">
	                <div class="inline-block,height-50,top-0" style="]]..tagTitleDivWidth..[[" border="0">
	                    <div class="inline-block,height-50,top-0" style="width: 15px;" border="0"> 
		                	<label class="ifRequired_css" name="]]..tagName..[[_required" value="]]..tagRequired..[[" />
		                </div>
		                <div class="inline-block,height-50,top-0" style="]]..tagTitleWidth..[[" border="0">
		                	<label class="label_title,left-0" style="]]..fontSize..[[" name="]]..tagName..[[_title" value="]]..tagTitle..[[" ]]..alertExplainClick..[[ />
		                </div>]]..explainHtml..[[
		            </div>
	                <input type="text" style="-wap-input-format:'N']]..valueStyle..[[" border="]]..inputBorder..[[" pointValue="]]..pointValue..[[" hold="]]..hold..[[" holdColor="]]..holdColor..[[" class="input_text_css" name="]]..tagName..[[" value="]]..tagValue..[[" ]]..maxLength..[[ ]]..onChange..[[ ]]..onBlur..[[ disableEmoji="]]..disableEmoji..[[" />
	                <line class="line_css,]]..lineDisplay..[[" />
	            </div>
	        ]];
		elseif inputStyle == "float" then
			htmlContent = [[
	            <div class="option_div,]]..divDisplay..[[" style="]]..style..[[" border="1" name="]]..tagName..[[_div" ]]..tagOnClick..[[ enable="]]..enable..[[">
	                <div class="inline-block,height-50,top-0" style="]]..tagTitleDivWidth..[[" border="0">
	                    <div class="inline-block,height-50,top-0" style="width: 15px;" border="0"> 
		                	<label class="ifRequired_css" name="]]..tagName..[[_required" value="]]..tagRequired..[[" />
		                </div>
		                <div class="inline-block,height-50,top-0" style="]]..tagTitleWidth..[[" border="0">
		                	<label class="label_title,left-0" style="]]..fontSize..[[" name="]]..tagName..[[_title" value="]]..tagTitle..[[" ]]..alertExplainClick..[[ />
		                </div>]]..explainHtml..[[
		            </div>
	                <input type="text" style="-wap-input-format:'n']]..valueStyle..[[" border="]]..inputBorder..[[" pointValue="]]..pointValue..[[" hold="]]..hold..[[" holdColor="]]..holdColor..[[" class="input_text_css" name="]]..tagName..[[" value="]]..tagValue..[[" ]]..maxLength..[[ ]]..onChange..[[ ]]..onBlur..[[ disableEmoji="]]..disableEmoji..[[" />
	                <line class="line_css,]]..lineDisplay..[[" />
	            </div>
	        ]];
		elseif inputStyle == "date" then
			--界面显示是日期格式
			local showFormat = vt("showFormat",pageElement,"yyyy-MM-dd");
			--获取值返回的日期格式
			local valueFormat = vt("valueFormat",pageElement,"yyyy-MM-dd");
			--日期选择样式(picker='2' -> 年-月，picker='3' -> 年-月-日)
			local picker = vt("picker",pageElement,"");
			htmlContent = [[
	            <div class="option_div" style="]]..style..[[" border="1" name="]]..tagName..[[_div" ]]..tagOnClick..[[ enable="]]..enable..[[">
	                <div class="inline-block,height-50,top-0" style="]]..tagTitleDivWidth..[[" border="0">
	                    <div class="inline-block,height-50,top-0" style="width: 15px;" border="0"> 
		                	<label class="ifRequired_css" name="]]..tagName..[[_required" value="]]..tagRequired..[[" />
		                </div>
		                <div class="inline-block,height-50,top-0" style="]]..tagTitleWidth..[[" border="0">
		                	<label class="label_title,left-0" style="]]..fontSize..[[" name="]]..tagName..[[_title" value="]]..tagTitle..[[" ]]..alertExplainClick..[[ />
		                </div>]]..explainHtml..[[
		            </div>
	                <input type="text" style="-wap-input-format:'date']]..valueStyle..[[" picker="]]..picker..[[" showFormat="]]..showFormat..[[" valueFormat="]]..valueFormat..[[" border="]]..inputBorder..[[" class="input_text_css" name="]]..tagName..[[" value="]]..tagValue..[[" disableEmoji="]]..disableEmoji..[[" />
	                <line class="line_css,]]..lineDisplay..[[" />
	            </div>
	        ]];
	    elseif inputStyle == "textarea" then
	    	-- 是否显示按钮
	    	local isShowButton = vt("isShowButton",pageElement,"false");
	    	htmlContent = [[
				<div class="option_div,]]..divDisplay..[[" style="]]..style..[[" border="1" name="]]..tagName..[[_div" ]]..tagOnClick..[[ enable="]]..enable..[[">
	                <div class="inline-block,height-50,top-0" style="]]..tagTitleDivWidth..[[" border="0">
	                    <div class="inline-block,height-50,top-0" style="width: 15px;" border="0"> 
		                	<label class="ifRequired_css" name="]]..tagName..[[_required" value="]]..tagRequired..[[" />
		                </div>
		                <div class="inline-block,height-50,top-0" style="]]..tagTitleWidth..[[" border="0">
		                	<label class="label_title,left-0" style="]]..fontSize..[[" name="]]..tagName..[[_title" value="]]..tagTitle..[[" ]]..alertExplainClick..[[ />
		                </div>]]..explainHtml..[[
		            </div>
	                <textarea class="textarea_css" style="]]..valueStyle..[[" border="]]..inputBorder..[[" name="]]..tagName..[[" hold="]]..hold..[[" holdColor="]]..holdColor..[[" value="]]..tagValue..[[" disableEmoji="]]..disableEmoji..[[" isShowButton="]]..isShowButton..[[" ]]..maxLength..[[ ]]..onChange..[[ ]]..onBlur..[[ />
	                <div class="space_10_div" border="0" />
	                <line class="line_css,]]..lineDisplay..[[" />
	            </div>
	        ]];
		else
			htmlContent = [[
	            <div class="option_div,]]..divDisplay..[[" style="]]..style..[[" border="1" name="]]..tagName..[[_div" ]]..tagOnClick..[[ enable="]]..enable..[[">
	                <div class="inline-block,height-50,top-0" style="]]..tagTitleDivWidth..[[" border="0">
	                    <div class="inline-block,height-50,top-0" style="width: 15px;" border="0"> 
		                	<label class="ifRequired_css" name="]]..tagName..[[_required" value="]]..tagRequired..[[" />
		                </div>
		                <div class="inline-block,height-50,top-0" style="]]..tagTitleWidth..[[" border="0">
		                	<label class="label_title,left-0" style="]]..fontSize..[[" name="]]..tagName..[[_title" value="]]..tagTitle..[[" ]]..alertExplainClick..[[ />
		                </div>]]..explainHtml..[[
		            </div>
	                <input type="text" border="]]..inputBorder..[[" hold="]]..hold..[[" holdColor="]]..holdColor..[[" class="input_text_css" style="]]..valueStyle..[[" name="]]..tagName..[[" value="]]..tagValue..[[" ]]..maxLength..[[ ]]..onChange..[[ ]]..onBlur..[[ disableEmoji="]]..disableEmoji..[[" />
	                <line class="line_css,]]..lineDisplay..[[" />
	            </div>
	        ]];
		end;
	elseif tagType == "radio" then
		--radio左label
		local radio_left_label = vt("leftLabel",pageElement,"是");
		--radio右label
		local radio_right_label = vt("rightLabel",pageElement,"否");
		--回调方法
		local call_back_fun = vt("callBackFun",pageElement);
		htmlContent = [[
            <div class="option_div,]]..divDisplay..[[" style="]]..style..[[" border="1" name="]]..tagName..[[_div" ]]..tagOnClick..[[ enable="]]..enable..[[">
                <div class="inline-block,height-50,top-0" style="]]..tagTitleDivWidth..[[" border="0">
                    <div class="inline-block,height-50,top-0" style="width: 15px;" border="0"> 
	                	<label class="ifRequired_css" name="]]..tagName..[[_required" value="]]..tagRequired..[[" />
	                </div>
	                <div class="inline-block,height-50,top-0" style="]]..tagTitleWidth..[[" border="0">
	                	<label class="label_title,left-0" style="]]..fontSize..[[" name="]]..tagName..[[_title" value="]]..tagTitle..[[" ]]..alertExplainClick..[[ />
	                </div>]]..explainHtml..[[
	            </div>
                <div class="radio_div" border="0">
                	<div class="leftRadio_div" border="0" onclick="lua_components.set_radio_select('0',']]..tagName..[[',']]..call_back_fun..[[')">
	                	<img class="radio_img" src="local:dj_ico_radio.png" name="]]..tagName..[[_leftRadio" onclick="lua_components.set_radio_select('0',']]..tagName..[[',']]..call_back_fun..[[')" />
	                	<label class="radio_label" style="]]..valueStyle..[[" value="]]..radio_left_label..[[" onclick="lua_components.set_radio_select('0',']]..tagName..[[',']]..call_back_fun..[[')" />
	                </div>
	                <div class="rightRadio_div" border="0" onclick="lua_components.set_radio_select('1',']]..tagName..[[',']]..call_back_fun..[[')">
	                	<img class="radio_img" src="local:dj_ico_radio.png" name="]]..tagName..[[_rightRadio" onclick="lua_components.set_radio_select('1',']]..tagName..[[',']]..call_back_fun..[[')" />
	                	<label class="radio_label" style="]]..valueStyle..[[" value="]]..radio_right_label..[[" onclick="lua_components.set_radio_select('1',']]..tagName..[[',']]..call_back_fun..[[')" />
	                </div>
                </div>
                <line class="line_css,]]..lineDisplay..[[" />
            </div>
        ]];
    else
		htmlContent = [[
            <div class="option_div,]]..divDisplay..[[" style="]]..style..[[" border="1" name="]]..tagName..[[_div" ]]..tagOnClick..[[ enable="]]..enable..[[">
                <div class="inline-block,height-50,top-0" style="]]..tagTitleDivWidth..[[" border="0">
                    <div class="inline-block,height-50,top-0" style="width: 15px;" border="0"> 
	                	<label class="ifRequired_css" name="]]..tagName..[[_required" value="]]..tagRequired..[[" />
	                </div>
	                <div class="inline-block,height-50,top-0" style="]]..tagTitleWidth..[[" border="0">
	                	<label class="label_title,left-0" style="]]..fontSize..[[" name="]]..tagName..[[_title" value="]]..tagTitle..[[" ]]..alertExplainClick..[[ />
	                </div>]]..explainHtml..[[
	            </div>
                <label class="label_value_arrow" style="]]..valueStyle..[["  name="]]..tagName..[[" value="]]..tagValue..[[" />
                <img src="local:arrow_common.png" class="]]..tagArrow..[[" name="arrow_common_]]..tagName..[[" />
                <line class="line_css,]]..lineDisplay..[[" />
            </div>
        ]];
	end;
    -- 返回HTML
    return htmlContent;
end;

function lua_components.incomeexpenditureView(pageElement)
	local pageName = vt("pageName",pageElement);
	local viewName = vt("viewName",pageElement);
	local viewTitle = vt("viewTitle",pageElement);
	local viewValue = vt("viewValue",pageElement);
	local closeFun = vt("closeFun",pageElement,"lua_page.div_page_ctrl");
	local clickFun = vt("clickFun",pageElement);
	local htmlContent = [[
		<div class="lucencyBackground_css" border="0" name="]]..pageName..[[" >
		    <incomeexpenditureView class="view_css" value=']]..viewValue..[[' name="]]..viewName..[[" cancel="]]..closeFun..[[" confirm="]]..clickFun..[[" title="]]..viewTitle..[["></incomeexpenditureView>
		</div>
	]];
	return htmlContent;
end;

--获取一个空DIV，用于撑开两个元素之间的空隙
function getSpace(spaceSize)
	local size = formatNull(spaceSize,"10");
	local htmlContent = [[
		<div class="space_]]..size..[[_div" border="0" />
	]];
	return htmlContent;
end;

--单选按钮交互方法
function lua_components.set_radio_select(index,tagName,callBackFun)
	local index = formatNull(index);
	local leftRadio = document:getElementsByName(tagName.."_leftRadio");
	local rightRadio = document:getElementsByName(tagName.."_rightRadio");
	if #leftRadio == 1 and #rightRadio == 1 then
		if index == "0" then
			--左边选中
			leftRadio[1]:setPropertyByName("src","local:sl_ico_radioOrange.png");
			rightRadio[1]:setPropertyByName("src","local:sl_ico_radioGrey.png");
		elseif index == "1" then
			--右边选中
			leftRadio[1]:setPropertyByName("src","local:sl_ico_radioGrey.png");
			rightRadio[1]:setPropertyByName("src","local:sl_ico_radioOrange.png");
		else
			--传空不选
			leftRadio[1]:setPropertyByName("src","local:sl_ico_radioGrey.png");
			rightRadio[1]:setPropertyByName("src","local:sl_ico_radioGrey.png");
		end;
	elseif #leftRadio > 1 or #rightRadio > 1 then
		debug_alert("指定radio数量大于1");
	else
		debug_alert("指定radio不存在");
	end;

	if formatNull(callBackFun) ~= "" then
		--调用回调方法，返回勾选项
		lua_system.do_function(callBackFun,index);
	else
		debug_alert("未指定回调方法");
	end;
end;

--获取选择的人员信息
function jjbx_select_people(ItemData)
    lua_page.div_page_ctrl();
    local peopleInfo = lua_format.table_arg_unpack(ItemData);
    local backFunc = vt("search_people_back_fun",globalTable);
    globalTable["search_people_back_fun"] = nil;
    if backFunc ~= "" then
    	lua_system.do_function(backFunc,peopleInfo);
    else
    	alert("回调方法未定义");
    end;
end;

function alert_explain(explain)
    if explain ~= "" then
        explain = lua_format.base64_decode(explain);
        alert(explain);
    end;
end;

--[[搜索员工信息]]
function jjbx_search_for_psn_app(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams,{});
        ReqParams["ReqAddr"] = "fuzzySearchNew/forPsnApp";
        ReqParams["ReqUrlExplain"] = "搜索员工信息";
        ReqParams["BusinessCall"] = jjbx_search_for_psn_app;
        ReqParams["BusinessParams"] = table2json(ReqParams["BusinessParams"]);
        ReqParams["ReqFuncName"] = "invoke_trancode_noloading";
        lua_jjbx.common_req(ReqParams);
    else
        close_loading();
        local res = json2table(ResParams["responseBody"]);
        if res["errorNo"] == "000000" then
            local peopleList = formatNull(res["list"],{});
            local htmlHead = [[<div class="search_content_div" border="1" name="people_info_div">]];
            local htmlContent = "";
            if #peopleList > 0 then
                for key,value in pairs(peopleList) do
			        local ItemData = peopleList[key];
			        local EncodeItemData = lua_format.table_arg_pack(ItemData);
                    htmlContent = htmlContent..[[
                        <div class="search_people_option" border="1" onclick="jjbx_select_people(']]..EncodeItemData..[[')">
                            <label class="people_workId_css" value="]]..value['workid']..[[" />
                            <label class="people_nameAndDept_css" value="]]..value['name']..[[ ]]..value['deptName']..[[" />
                            <div style="height: 5px;" border="0"/>
                            <line class="line_css_search_people" />
                        </div>
                    ]];
                end;
                htmlContent = htmlHead..htmlContent..[[</div>]];
                document:getElementsByName("people_info_div")[1]:setInnerHTML(htmlContent);
            else
                htmlContent = htmlHead..[[<div class="search_people_option" border="1"><label class="label_noData" value="查无此人" /></div></div>]];
                document:getElementsByName("people_info_div")[1]:setInnerHTML(htmlContent);
            end;
            page_reload();
        else
            alert(res["errorMsg"]);
        end;
    end;
end;

--搜索前参数赋值，使用时，因不同需求所需参数不同，可根据需求在页面重写此方法
function jjbx_search_people()
	if getValue("peopleName") ~= "" then
		local ReqParams = {
			searchFlag = "corp",
			isContainsSeal = "1",
			keywords = getValue("peopleName"),
			pkCorp = ""
		};
		globalTable["search_people_back_fun"] = "select_people_back";
		jjbx_search_for_psn_app("",{BusinessParams = ReqParams});
	end;
end;

--搜索人员信息
--使用该模板时需手动创建头部
function search_people_info(Arg)
	local Arg = formatNull(Arg);
	--标题名称
	local labelTitle = vt("labelTitle",Arg,"员工姓名");
	--输入框默认值
	local inputValue = vt("inputValue",Arg);
	--搜索方法
	local searchFunc = vt("searchFunc",Arg,"jjbx_search_people()");
	local htmlContent = [[
        <div class="search_content_css" border="0">
            <div class="space_05_div" border="0" />
            <div class="search_data_css" border="0">
                <div class="option_div" border="1">
                    <div class="search_input_div" border="0">
                        <label class="ifRequired_css" name="search_required">*</label>
                        <label class="label_title" value="]]..labelTitle..[[" />
                        <input type="text" class="input_text_css" value="]]..inputValue..[[" hold="请输入" maxleng="20" border="0" name="peopleName" onchange="]]..searchFunc..[[" />
                    </div>
                </div>
                <div style="height: 1px;" border="0"></div>
                <div class="search_content_div" border="1" name="people_info_div">
                    
                </div>
            </div>
        </div>
    ]];
    return htmlContent;
end;

--弹窗显示DIV
function show_div(elementArg)
    local elementName = lua_format.table_arg_unpack(elementArg)
    lua_page.div_page_ctrl(elementName["pageName"], "false", "false");
end;

--切换单选按钮
function jjbx_change_radio(flag,elementName)
    local eName = formatNull(elementName,"radio");
    local e = document:getElementsByName(eName);
    if flag == "0" then
        e[1]:setPropertyByName("src","local:sl_ico_radioOrange.png");
        e[2]:setPropertyByName("src","local:sl_ico_radioGrey.png");
    else
        e[1]:setPropertyByName("src","local:sl_ico_radioGrey.png");
        e[2]:setPropertyByName("src","local:sl_ico_radioOrange.png");
    end;
    return flag;
end;