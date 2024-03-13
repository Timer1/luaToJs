--[[创建附件上传控件，初始化成功和更新控件时会调用enclosurepic_uploaded_call函数，在具体业务调用处实现该方法，完成业务数据更新，比如已上传附件数目更新等操作。]]
function uploadEnclosure(Arg)
    --附件是否可编辑，默认为可编辑
    local editFlag = vt("editFlag",Arg,"YES");
    --判断审批人是否可编辑附件
    if vt("ifApprover",Arg,"false") == "true" then
        --审批人状态，如有编辑附件权限，则可修改附件
        if vt("approverEditFlag",Arg,"false") == "true" then
            editFlag = "YES";
        else
            editFlag = "NO";
        end;
    end;

    --附件图片旋转方法
    local picrotatefunction = "lua_upload.pic_rotate";
    --租房服务不支持附件旋转
    if vt("billType",Arg) == "zffw" then
        picrotatefunction = "";
    end;
    --点击上传的方法（用于展开菜单）
    local upfunction = "";
    --附件排序方法
    local sortfunction = "";
    --点击删除的方法，客户端会把初始化的json item string作为入参传递
    local delfunction = "";

    if editFlag == "YES" then
        upfunction = "lua_menu.alert_upload_enclosure_menu";
        sortfunction = "lua_upload.sort_enclosure";
        delfunction = "lua_upload.del_pic_enclosure";
    elseif editFlag == "NO" then
        --非编辑状态不允许上传、删除、排序
        upfunction = "";
        sortfunction = "";
        delfunction = "";
    end;

    --控件最大显示高度，需要初始化后进行适配更新
    local height = vt("height",Arg,"300");
    --单行显示个数
    local rowCount = vt("rowCount",Arg,"3");
    --最大文件个数
    local maxCount = vt("maxCount",Arg,"50");
    --单次上传最大个数
    local uploadCount = vt("uploadCount",Arg,"5");

    --是否启动水印
    local PCConfigListsTable = vt("PCConfigListsTable",globalTable);
    local IMG0015 = vt("IMG0015",PCConfigListsTable);
    --水印样式
    local waterMarkValue = "";
    if IMG0015 == "是" then
        --获取当前日期
        local nowTime = os.time();
        local nowDate = os.date("%Y-%m-%d",nowTime);
        --获取工号
        local workID = globalTable["workid"];
        --获取所属公司名称
        local unitname = globalTable["selectOrgList"][1]["unitname"];
        waterMarkValue = unitname.." "..nowDate.." "..workID;
    end;

    local html = [[
        <!-- 附件上传控件 -->
        <div class="uploadEnclosure_div" name="uploadEnclosure_div" border="0">
            <uploadEnclosure name="uploadEnclosure" delfunction="]]..delfunction..[[" picrotatefunction="]]..picrotatefunction..[[" sortfunction="]]..sortfunction..[[" upfunction="]]..upfunction..[[" height="]]..height..[[" rowCount="]]..rowCount..[[" maxCount="]]..maxCount..[[" uploadCount="]]..uploadCount..[[" class="uploadEnclosure_widget" border="0" value="" waterMarkValue="]]..waterMarkValue..[[" waterMarkColor="#8B8B8B"></uploadEnclosure>
        </div>
    ]];

    return html;
end;
