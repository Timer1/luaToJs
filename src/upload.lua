--[[上传业务使用到的lua]]

lua_upload = {};

--[[********************银行卡上传调用OCR识别Begin********************]]

--[[上传银行卡进行扫描]]
function lua_upload.upload_bank_card_to_scan(type)
    local type = formatNull(type);
    
    local pic_cut_tableArg = {
        --裁剪高度比例
        heightScale="0.75",
        --裁剪宽度比例
        widthScale="0.75",
        --true有边框且裁剪，false无边框不裁剪
        needBoard="true",
        --true裁剪且支持缩放以及手势，false不处理，和needBoard组合使用
        cutPic="true",
        --屏幕显示文字
        showTitle="请将卡片置于裁剪区域内",
        --边框四个角颜色
        edgeColor="#F96A0E"
    };

    local call_upload_widget_tableArg = {
        --操作标志 Upload上传，目前只用到上传
        doFlag="Upload",
        --doFlag为上传时，需要定义上传类型
        uploadFlag="upCardPic",
        --压缩类型，默认Min [No不压缩，Min最小压缩（头像），Normal正常压缩（发票）]
        compressStyle="No",
        --最大文件数
        maxCounts="1",
        --超过最大文件数提示
        maxCountsTip="选择图片不能大于1张",
        --回调方法
        callback="upload_bankCardPic_callback",
        --图片截取参数
        cutArg=pic_cut_tableArg
    };

    if type == "camera" then
        lua_system.open_camera(call_upload_widget_tableArg);
    elseif type == "album" then
        lua_system.open_album(call_upload_widget_tableArg);
    else
        alert("不支持的上传方式");
    end;
end;

--[[银行卡上传识别回调]]
function upload_bankCardPic_callback(totalcounts, successcounts, resmsg, resinfoJson)
    --[[debug_alert(
        "ocr识别结果分析\n"..
        "总张数:"..totalcounts.."\n"..
        "成功张数:"..successcounts.."\n"..
        "返回结果:"..resmsg.."\n"..
        "返回信息:"..resinfoJson.."\n"..
        ""
    );]]

    --上传成功张数和总张数一致认为上传成功
    if tonumber(totalcounts) == tonumber(successcounts) then
        local resinfoTable = json2table(resinfoJson);
        local res = vt("res",resinfoTable);
        res = formatNull(res[1]);

        --更新ocr识别的卡号
        local ocr_card_no = vt("ocr_card_no",res);
        local error_no = vt("error_no",res);
        local error_msg = vt("error_nerror_msg",res);

        --[[debug_alert(
            "OCR识别结果:\n"..
            "识别卡号:"..ocr_card_no.."\n"..
            "返回编码:"..error_no.."\n"..
            "返回信息:"..error_msg.."\n"..
            ""
        );]]

        if error_no == "000000" then
            --待更新控件
            local updateWidgetName = vt("CardNoWidgetName",globalTable);
            globalTable["CardNoWidgetName"] = "";

            --识别卡号不足十位，不回显卡号
            if updateWidgetName ~= "" and string.len(ocr_card_no) >= 10 then
                changeProperty("account_no", "value", ocr_card_no);
            else
                alertToast1(C_Ocr_FailedMsg);
            end;
        else
            --调用OCR识别接口报错
            if error_msg == "" then
                alertToast1(C_Ocr_FailedMsg);
            else
                alert(error_msg);
            end;
        end;
    else
        --客户端向EWP上传图片报错
        alert("卡片上传失败");
    end;
end;

--[[********************银行卡上传调用OCR识别End********************]]

--[[********************头像上传Begin********************]]

--[[上传头像]]
function lua_upload.upload_headPic(type)
    local type = formatNull(type);
    --debug_alert("上传头像 type: "..type);

    local call_upload_widget_tableArg = {
        --操作标志 Upload上传，目前只用到上传
        doFlag="Upload",
        --doFlag为上传时，需要定义上传类型
        uploadFlag="upHeadProtrait",
        --压缩类型，默认Min [No不压缩，Min最小压缩（头像），Normal正常压缩（发票）]
        compressStyle="Min",
        --最大文件数
        maxCounts="1",
        --超过最大文件数提示
        maxCountsTip="选择图片不能大于1张",
        --回调方法
        callback="upload_headPic_callback"
    };
    if type == "camera" then
        lua_system.open_camera(call_upload_widget_tableArg);
    elseif type == "album" then
        lua_system.open_album(call_upload_widget_tableArg);
    else
        alert("不支持的上传方式");
    end;
end;

--[[********************头像上传End********************]]
--查询是否存在PDF文件
function get_related_inv_img(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        --获取文件绝对路劲
        local FileAbsPath = vt("filePath",ReqParams);
        if FileAbsPath ~= "" then
            invoke_trancode_noloading(
                "jjbx_process_query",
                "jjbx_fpc",
                {
                    TranCode="GetRelatedInvImg",
                    FileAbsPath=vt("filePath",ReqParams),
                    OFD2PDF="false",
                    netFlag = "1"
                },
                get_related_inv_img,
                {}
            );
        else
            --alert("无文件路劲");
        end;
    else
        local res = json2table(vt("responseBody",ResParams));

        --debug_alert("getInvImgDlLinkByPath res :\n"..foreach_arg2print(res));
        local isInvoiceFile = vt("isInvoiceFile",res);
        local PCInvoiceFileType = vt("FileType",res);
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
            --获取到PDF文件时，打开预览文件
            if isInvoiceFile == "true" then
                alert_confirm("温馨提示","请选择打开方式","取消","预览附件","do_download_ofd_enclosure","");
            else
                --获取不到PDF文件时，跳转页面展示发票信息
                alert_confirm("温馨提示","暂不支持该类型文件预览","取消","下载附件","do_download_enclosure",globalTable["OfdFileDlUrl"]);
            end;
        end;
    end;
end;

--[[********************附件上传Begin********************]]

--查询带水印的PDF文件
function view_pdf_CallBack(res)
    close_loading();
    local res = json2table(res["responseBody"]);
    local tableArg = json2table(res["Arg"]);
    local FileName = res["FileName"];
    local PCInvoiceFileDlUrl = res["PCInvoiceFileDlUrl"];
    --客户端控件预览PDF文件
    local openPdfArg = {
        pdfLinkUrl=PCInvoiceFileDlUrl,
        pdfFileType=file_type,
        pdfPageTitle="查看附件",
        pdfOpenStyle="ClientWidget"
    };
    lua_system.view_file_by_webview(openPdfArg);
end;

function view_pdf(Arg)
    local arg = json2table(Arg);
    local viewPdf_params = {
        billNo=arg["EnclosureBillNo"],
        fileName=arg["PCFileName"],
        fileKey=arg["fileKey"],
        TranCode="viewPdf",
        billType=arg["billType"]
    };
    invoke_trancode_donot_checkRepeat("jjbx_process_query","jjbx_fpc",viewPdf_params,view_pdf_CallBack,{},all_callback,{CloseLoading="false",Arg=Arg});
end;

--[[客户端点击附件回调方法]]
function download_enclosure(Arg)
    local tableArg = json2table(Arg);
    local file_type = vt("FileType",tableArg);
    local file_dlurl = vt("FileDlUrl",tableArg);

    --[[debug_alert(
        "点击附件\n"..
        "参数 : \n"..Arg.."\n"..
        "文件类型 : \n"..file_type.."\n"..
        "下载链接 : \n"..file_dlurl.."\n"..
        ""
    );]]

    local PCConfigListsTable = vt("PCConfigListsTable",globalTable);
    --是否启动水印
    local IMG0015 = vt("IMG0015",PCConfigListsTable);
    --是否支持附件下载
    local IMG0016 = vt("IMG0016",PCConfigListsTable);

    if string.find("pdf",file_type) then
        --if IMG0015 == "是" then
            --查询带水印的附件
            --view_pdf(Arg);
        --else
            --客户端控件预览PDF文件
            local openPdfArg = {
                pdfLinkUrl=file_dlurl,
                pdfFileType=file_type,
                pdfPageTitle="查看附件",
                pdfOpenStyle="ClientWidget"
            };
            lua_system.view_file_by_webview(openPdfArg);
        --end;
    elseif string.find(C_AppH5ViewFileTypeList,file_type) then
        --客户端控件预览文件
        local openPdfArg = {
            pdfLinkUrl=file_dlurl,
            pdfFileType=file_type,
            pdfPageTitle="查看附件",
            pdfOpenStyle="ClientWidget"
        };
        lua_system.view_file_by_webview(openPdfArg);
    elseif file_type=="zip" or file_type=="rar" or file_type=="eml" then
        --调用下载
        if vt("downloadFlag",globalTable) == "true" then
            alert_confirm("温馨提示","不支持预览"..file_type.."格式的文件","取消","下载附件","do_download_enclosure",file_dlurl);
        else
            alert_confirm("温馨提示","不支持预览"..file_type.."格式的文件","","确定");
        end;
    elseif file_type=="ofd" then
        --预览链接
        local ofd_file_view_url = vt("previewPath",tableArg);
        if ofd_file_view_url ~= "" then
            --调用下载
            --alert_confirm("温馨提示","不支持预览"..file_type.."格式的文件","取消","下载附件","do_download_enclosure",file_dlurl);
            --直接打开预览链接
            lua_system.alert_webview(
                {
                    title = "文件预览",
                    visit_url = ofd_file_view_url,
                    close_call_func="",
                    back_type = "BACK",
                    listen_url = "http://app_h5_callback_url",
                    listen_call = "lua_system.webview_h5_callback"
                }
            );
        else
            --调用预览和下载
            --globalTable["OfdFileViewUrl"] = ofd_file_view_url;
            --globalTable["OfdFileDlUrl"] = file_dlurl;
            --alert_confirm("温馨提示","请选择打开方式","取消","预览附件","do_download_ofd_enclosure","");
            -- get_related_inv_img("",{filePath=vt("PCFilePath",tableArg)})
            lua_upload.get_related_inv_img(vt("fileKey",tableArg),vt("PCFilePath",tableArg));
        end;
    else
        alert("不支持预览"..file_type.."格式的文件")
    end;
end;

--查询附件key查询预览链接
function lua_upload.getRelatedInvImgCallBack(res)
    local responseBody = json2table(vt("responseBody",res));
    if responseBody["errorNo"] == "000000" then
        close_loading();
        local imgList = vt("imgList",responseBody);
        if #imgList > 0 then
            --直接打开预览链接
            lua_system.alert_webview(
                {
                    title = "文件预览",
                    visit_url = imgList[1],
                    close_call_func="",
                    back_type = "BACK",
                    listen_url = "http://app_h5_callback_url",
                    listen_call = "lua_system.webview_h5_callback"
                }
            );
        else
            alert("无法获取文件预览链接");
        end;
    else
        alert(responseBody["errorMsg"]);
    end;
end;

--针对发票OFD文件预览时调用（其他文件查看原逻辑不变）
function lua_upload.get_related_inv_img(fileKey,filePath)
    local ReqParams = {};
    ReqParams["ReqAddr"] = "invoice/getRelatedInvImg";
    ReqParams["ReqUrlExplain"] = "查询附件预览链接";
    ReqParams["BusinessCall"] = lua_upload.getRelatedInvImgCallBack;
    local getRelatedInvImg_params = {
        channel="1",
        ofdFileKey = fileKey,
        path = filePath,
        netFlag = "1"
    };
    ReqParams["BusinessParams"] = table2json(getRelatedInvImg_params);
    lua_jjbx.common_req(ReqParams);
end;

--[[客户端点击附件下载]]
function do_download_enclosure(TouchIndex, CallArg)
    --[[debug_alert(
        "客户端点击附件下载\n"..
        "TouchIndex : \n"..TouchIndex.."\n"..
        "CallArg : \n"..CallArg.."\n"..
        ""
    );]]
    if tostring(TouchIndex) == "1" then
        --执行下载
        lua_system.download_file(CallArg);
    end;
end;

--[[客户端点击OFD附件下载]]
function do_download_ofd_enclosure(TouchIndex, CallArg)
    local viewUrl = globalTable["OfdFileViewUrl"];
    local dlUrl = globalTable["OfdFileDlUrl"];

    globalTable["OfdFileViewUrl"] = "";
    globalTable["OfdFileDlUrl"] = "";

    --[[debug_alert(
        "客户端点击OFD附件下载\n"..
        "TouchIndex : \n"..TouchIndex.."\n"..
        "viewUrl : \n"..viewUrl.."\n"..
        "dlUrl : \n"..dlUrl.."\n"..
        ""
    );]]

    if tostring(TouchIndex) == "1" then
        --执行预览
        lua_system.file_preview(viewUrl,"pdf");
    end;
end;

--[[查询附件图片]]
function lua_upload.query_enclosure_pic(QryEnclosureArg)
    --debug_alert("查询附件图片"..foreach_arg2print(QryEnclosureArg));

    --单据号
    local billNo = vt("billNo",QryEnclosureArg);
    --单据类型
    local billType = vt("billType",QryEnclosureArg);
    --回调方法，默认初始化附件控件
    local callback = vt("callback",QryEnclosureArg,"lua_upload.init_upload_enclosure_widget");
    --是否有loading
    local loading = vt("loading",QryEnclosureArg,"true");
    --是否需要更新控件当前预览位置
    local UpdateViewLocation = vt("UpdateViewLocation",QryEnclosureArg,"true");

    --获取回调方法对象
    local doQueryCallBack = lua_format.str2fun(callback);

    --是否查询转办附件 1：查询
    local ReloadFlag = vt("ReloadFlag",QryEnclosureArg);
    --特殊说明上传的附件
    local specialExplain = vt("specialExplain",QryEnclosureArg);
    --特说说明ID
    local RuleID = vt("ruleID",QryEnclosureArg);
    --用餐申请补录附件
    local eatServerSupplement = vt("eatServerSupplement",QryEnclosureArg);
    local netfunction = "";
    local LoadingClose = "";
    if loading == "true" then
        netfunction = "invoke_trancode_donot_checkRepeat";
        LoadingClose = "false";
    else
        netfunction = "invoke_trancode_noloading";
        LoadingClose = "true";
    end;
    local doNetfunction = lua_format.str2fun(netfunction);

    --不可编辑状态查看需要分组
    local QryType = "";
    local UploadEnclosurePicEditFlag = formatNull(globalTable["UploadEnclosurePicEditFlag"],"YES");
    if UploadEnclosurePicEditFlag == "NO" then
        QryType = "Look";
    end;

    doNetfunction(
        "jjbx_service",
        "app_service",
        {
            TranCode="EnclosureService",
            EnclosureServiceCode="QryPCEnclosure",
            EnclosureNo=billNo,
            billType=billType,
            QryType=QryType,
            UpdateViewLocation=UpdateViewLocation,
            ReloadFlag=ReloadFlag,
            SpecialExplain=specialExplain,
            RuleID = RuleID,
            eatServerSupplement = eatServerSupplement
        },
        doQueryCallBack,
        {},
        all_callback,
        {CloseLoading=LoadingClose}
    );
end;

--[[通过单据号查询单据附件，并更新附件张数缓存]]
function query_upload_enclosure_counts(billNo,ReqParams)
    local billNo = formatNull(billNo);
    local ReqParams = formatNull(ReqParams,{});
    ReqParams["billNo"] = billNo;
    lua_upload.update_counts_cache("",ReqParams);
end;

--[[更新附件张数缓存]]
function lua_upload.update_counts_cache(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams);
        local ResCallFunc = vt("ResCallFunc",ReqParams);
        --debug_alert(ResCallFunc);
        ReqParams["TranCode"] = "EnclosureService";
        ReqParams["EnclosureServiceCode"] = "QryPCEnclosure";
        ReqParams["EnclosureNo"] = vt("billNo",ReqParams);
        ReqParams["QryType"] = "Look";
        --debug_alert("更新附件张数缓存-请求"..foreach_arg2print(ReqParams));

        --通过单据号查询
        invoke_trancode_noloading(
            "jjbx_service",
            "app_service",
            ReqParams,
            lua_upload.update_counts_cache,
            {
                ResCallFunc=ResCallFunc
            },
            all_callback,
            {CloseLoading="false"}
        );
    else
        --debug_alert("更新附件张数缓存-响应"..foreach_arg2print(ResParams));

        --用于判断是否显示查看附件浮层
        local res = json2table(ResParams["responseBody"]);
        local PcEnclosureTotalCounts = vt("PcEnclosureTotalCounts",res,"0");
        --debug_alert("lua_upload.update_counts_cache PcEnclosureTotalCounts : "..PcEnclosureTotalCounts);

        --存缓存
        globalTable["PcEnclosureTotalCounts"] = PcEnclosureTotalCounts;
        --附件张数大于0，且页面有查看附件按钮对象时，显示按钮
        if tonumber(PcEnclosureTotalCounts) > 0 then
            local e = document:getElementsByName("seeAnnex");
            if #e > 0 then
                changeStyle("seeAnnex","display","block");
                page_reload();
            end;
        end;
        --调用回调
        local ResCallFunc = vt("ResCallFunc",ResParams);
        --debug_alert(ResCallFunc);
        lua_system.do_function(ResCallFunc,res);
    end;
end;

--[[
    初始化附件控件
    图片附件控件统一使用uploadEnclosure命名
    初始化成功会调用enclosurepic_uploaded_call函数，自行实现该函数完成页面其他逻辑处理
]]
function lua_upload.init_upload_enclosure_widget(params)
    local responseBody = json2table(params["responseBody"]);
    local errorNo = vt("BillFileQryErrorNo",responseBody);
    local errorMsg = vt("BillFileQryErrorMsg",responseBody);

    if errorNo == "000000" then
        --附件总张数
        local PcEnclosureTotalCounts = vt("PcEnclosureTotalCounts",responseBody,"0");
        --是否更新位置
        local UpdateViewLocation = vt("UpdateViewLocation",responseBody);
        --是否查询转办附件
        local ReloadFlag = vt("ReloadFlag",responseBody);
        
        --调试信息
        --[[debug_alert(
            "附件总张数 : "..PcEnclosureTotalCounts.."\n"..
            "是否更新位置 : "..UpdateViewLocation.."\n"..
            "是否查询转办附件 : "..ReloadFlag.."\n"..
            --"附件控件初始化 :"..foreach_arg2print(responseBody)..
            ""
        );]]

        --更新附件页面提示信息
        --local tipmsg = "已上传"..PcEnclosureTotalCounts.."/50张，单次上传最多5张";
        --update_enclosurepic_page_tip(tipmsg);

        --回调处理
        if ReloadFlag == "1" then
            --转办附件查询回调
            lua_jjbx.update_answer_transfer_enclosure_call(params);
        else
            --其他走自定义回调（需要在页面自行实现）
            enclosurepic_uploaded_call(responseBody);
        end;

        local WidgetData = "";
        --有附件的情况下加载
        if tonumber(PcEnclosureTotalCounts) > 0 then
            --debug_alert("初始化附件控件\n"..foreach_arg2print(params["responseBody"]));
            WidgetData = params["responseBody"];
        end;

        --设置附件
        changeProperty("uploadEnclosure","value",WidgetData);
        close_loading();
    else
        changeProperty("uploadEnclosure","value","");
        alert(errorMsg);
    end;
end;

--[[附件上传路由]]
function lua_upload.upload_enclosure(type)
    local type = formatNull(type);
    local billNo = vt("UploadEnclosurePicBillNo",globalTable);
    local billType = vt("UploadEnclosurePicBillType",globalTable);
    local ReloadFlag = vt("UploadEnclosurePicReloadFlag",globalTable);
    --情况说明附件上传
    local specialExplain = vt("specialExplain",globalTable);
    --用餐申请补录附件上传
    local eatServerSupplement = vt("eatServerSupplement",globalTable);
    local ruleID = vt("UploadEnclosurePicRuleID",globalTable);
    local params3 = {
        ReloadFlag = ReloadFlag,
        specialExplain = specialExplain,
        eatServerSupplement = eatServerSupplement,
        ruleID = ruleID
    };
    params3 = lua_format.base64_encode(table2json(params3));

    --[[debug_alert(
        "附件上传路由\n"..
        "上传类型 : "..type.."\n"..
        "单据类型 : "..billType.."\n"..
        "单据编号 : "..billNo.."\n"..
        ""
    );]]

    --参数检查
    local argListTable = {
        billType,
        billNo
    };
    local checkArgRes = lua_form.arglist_check_empty(argListTable);
    --debug_alert(checkArgRes);

    if checkArgRes == "true" then
        if type == "camera" then
            local call_upload_widget_tableArg = {
                --操作标志 Upload上传，目前只用到上传
                doFlag="Upload",
                --doFlag为上传时，需要定义上传类型
                uploadFlag="upEnclosurePic",
                --压缩类型，默认Min [No不压缩，Min最小压缩（头像），Normal正常压缩（发票）]
                compressStyle="No",
                --最大文件数
                maxCounts="1",
                --超过最大文件数提示
                maxCountsTip="拍照图片不能大于1张",
                --回调方法
                callback="lua_upload.upload_enclosure_callback",
                --图片截取参数
                cutArg={
                    --裁剪高度比例
                    heightScale="0.75",
                    --裁剪宽度比例
                    widthScale="0.75",
                    --true有边框且裁剪，false无边框不裁剪
                    needBoard="true",
                    --true裁剪且支持缩放以及手势，false不处理，和needBoard组合使用
                    cutPic="true",
                    --屏幕显示文字
                    showTitle="请将附件置于取景框内",
                    --边框四个角颜色
                    edgeColor="#F96A0E"
                },
                --预留参数位1，单据类型
                params1=billType,
                --预留参数位2，单据号
                params2=billNo,
                --预留参数位3
                params3=params3
            };
            --debug_alert("上传相机拍照的图片");
            lua_system.open_camera(call_upload_widget_tableArg);
        elseif type == "album" then
            local call_upload_widget_tableArg = {
                --操作标志 Upload上传，目前只用到上传
                doFlag="Upload",
                --doFlag为上传时，需要定义上传类型
                uploadFlag="upEnclosurePic",
                --压缩类型，默认Min [No不压缩，Min最小压缩（头像），Normal正常压缩（发票）]
                compressStyle="Normal",
                --最大文件数
                maxCounts="5",
                --超过最大文件数提示
                maxCountsTip="选择图片不能大于5张",
                --回调方法
                callback="lua_upload.upload_enclosure_callback",
                --预留参数位1，单据类型
                params1=billType,
                --预留参数位2，单据号
                params2=billNo,
                --预留参数位3
                params3=params3
            };
            --debug_alert("上传相册选择的图片");
            lua_system.open_album(call_upload_widget_tableArg);
        elseif type == "filesystem" then
            local pagetitle = C_SearchContextBegin.."文件名"..C_SearchContextEnd;

            --支持的文件类型
            local filetype = "pdf,ofd,doc,docx,eml,PDF,OFD,DOC,DOCX,EML,png,jpg,jpeg,PNG,JPG,JPEG";

            local tableArg = {
                pagetitle=pagetitle,
                uploadtype="multiple",
                counts="5",
                countsmsg="选择文件不能大于5个",
                filetype=filetype,
                loadFileType="PDF,OFD,其他",
                defaultType="PDF",
                filetypemsg="目前不支持上传该格式的文件",
                callfun="lua_upload.upload_enclosure_callback",
                uploadflag="upEnclosureFile",
                params1=billType,
                params2=billNo,
                params3=params3
            };
            lua_system.client_file_upload(tableArg);
        else
            alert("不支持的上传方式");
        end;
    else
        alert("单据信息不完整，无法上传");
    end;
end;

--[[附件上传回调]]
function lua_upload.upload_enclosure_callback(totalcounts, successcounts, resmsg, resinfoJson)
    local totalcounts = formatNull(totalcounts);
    local successcounts = formatNull(successcounts);
    local resmsg = formatNull(resmsg);
    local resinfoJson = formatNull(resinfoJson);

    --[[debug_alert(
        "附件图片上传回调\n"..
        "上传总数  : "..totalcounts.."\n"..
        "成功数目  : "..successcounts.."\n"..
        "结果信息  : "..resmsg.."\n"..
        "返回信息 : "..resinfoJson.."\n"..
        ""
    );]]

    --上传成功张数大于0时，通知后台获取上传成功的附件
    if tonumber(successcounts) > 0 then
        --if tonumber(totalcounts) == tonumber(successcounts) then
            --上传成功后，通知PC端接收文件，完成文件入库
            local resinfoTable = json2table(resinfoJson);
            local res = vt("res",resinfoTable);
            local EnclosureType = vt("EnclosureType",res[1]);
            local EnclosureNo = vt("EnclosureNo",res[1]);
            local ReloadFlag = vt("ReloadFlag",res[1]);

            --[[debug_alert(
                "附件上传信息\n"..
                "resinfoTable\n"..foreach_arg2print(resinfoTable).."\n"..
                "res\n"..foreach_arg2print(res).."\n"..
                "EnclosureType  : "..EnclosureType.."\n"..
                "EnclosureNo  : "..EnclosureNo.."\n"..
                ""
            );]]

            local pushArg = {
                billTye=EnclosureType,
                billNo=EnclosureNo,
                uploadInfo=resinfoJson,
                ReloadFlag=ReloadFlag
            };
            lua_upload.push_file_to_pc_receiver(pushArg);
        --end;
    else
        --客户端上传到EWP失败
        alertToast1(C_Toast_FailedMsg);
    end;
end;

--[[通知PC端接收文件，完成文件入库动作]]
function lua_upload.push_file_to_pc_receiver(pushArg)
    --debug_alert("通知PC端接收文件，完成文件入库动作\n"..foreach_arg2print(pushArg));

    --单据号
    local billNo = vt("billNo",pushArg);
    --单据类型
    local billTye = vt("billTye",pushArg);
    --上传信息
    local uploadInfo = vt("uploadInfo",pushArg);
    --转办附件
    local ReloadFlag = vt("ReloadFlag",pushArg);

    local pushReqArg = {
        TranCode="EnclosureService",
        EnclosureServiceCode="PushEnclosureToPC",
        EnclosureNo=billNo,
        EnclosureType=billTye,
        EnclosureInfo=uploadInfo,
        ReloadFlag=ReloadFlag
    };
    invoke_trancode_donot_checkRepeat(
        "jjbx_service",
        "app_service",
        pushReqArg,
        file_receive_call,
        {},
        all_callback,
        {CloseLoading="false"}
    );
end;

--[[
    接收结果处理
    上传成功会调用enclosurepic_uploaded_call函数，自行实现该函数完成页面其他逻辑处理
]]
function file_receive_call(params)
    local responseBody = json2table(params["responseBody"]);
    --debug_alert("file_receive_call\n"..foreach_arg2print(responseBody));

    --更新附件页面提示信息
    --local PcEnclosurePicCounts = formatNull(responseBody["PcEnclosurePicCounts"],"0");
    --local tipmsg = "已上传"..PcEnclosurePicCounts.."/50张，单次上传最多5张";
    --update_enclosurepic_page_tip(tipmsg);

    --放给页面的业务回调
    enclosurepic_uploaded_call(responseBody);

    if responseBody["errorNo"] == "000000" then
        --调试信息
        --debug_alert("file_receive_call\n"..foreach_arg2print(responseBody));

        --上传成功重新初始化控件
        lua_upload.init_upload_enclosure_widget(params);
        alertToast0(C_UploadedMsg);
    else
        alert(responseBody["errorMsg"]);
    end;
end;

--[[附件更新后的默认回调]]
function enclosurepic_uploaded_call(responseBody)
    --这里不实现，如果业务需要实现相关逻辑需要自行在页面上实现
end;

--[[默认更新附件页面提示信息]]
function update_enclosurepic_page_tip(msg)
    --local msg = formatNull(msg, "已上传0/50张，单次上传最多5张");
    --debug_alert("更新附件页面提示信息:"..msg);
    --changeProperty("upload_tip_value_label","value",msg);
end;

--[[附件删除]]
function lua_upload.del_pic_enclosure(delarg)
    --删除的参数为提供给客户端的json数据
    local delarg = json2table(delarg);

    --[[debug_alert(
        "删除附件\n"..
        foreach_arg2print(delarg)..
        ""
    );]]
    --debug_alert(vt("UploadEnclosurePicReloadFlag",globalTable));

    --执行附件删除
    local ReqParams = {
        --删除的附件单据号
        EnclosureNo=vt("EnclosureBillNo",delarg),
        --删除的文件名，接口支持多个，多个用","隔开，目前单个删除
        DelFileNames=vt("PCFileName",delarg),
        ReloadFlag=vt("UploadEnclosurePicReloadFlag",globalTable),
        eatServerSupplement = vt("eatServerSupplement",globalTable)
    };
    lua_upload.do_del_pic_enclosure("",ReqParams);
end;

--[[执行附件删除，删除后会刷新控件]]
function lua_upload.do_del_pic_enclosure(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams);
        ReqParams["TranCode"] = "EnclosureService";
        ReqParams["EnclosureServiceCode"] = "DelPCEnclosure";

        invoke_trancode_noloading_checkRepeat(
            "jjbx_service",
            "app_service",
            ReqParams,
            lua_upload.do_del_pic_enclosure,
            {},
            all_callback,
            {CloseLoading="true"}
        );
    else
        local res = json2table(ResParams["responseBody"]);
        --debug_alert("删除响应"..foreach_arg2print(res));
        local errorNo = vt("errorNo",res);
        local errorMsg = vt("errorMsg",res);

        --删除的附件单据号
        local EnclosureBillNo = vt("EnclosureBillNo",res);
        --是否转办
        local ReloadFlag = vt("ReloadFlag",res);

        if errorNo == "000000" then
            alertToast0(C_DeleteMsg);
            --删除后重新查询附件，没有loading
            local QueryEnclosureArg = {};
            if vt("specialExplain",globalTable) == "true" then
                --特殊情况说明附件查询
                QueryEnclosureArg = {
                    billNo=vt("UploadEnclosurePicBillNo",globalTable),
                    billType = vt("UploadEnclosurePicBillType",globalTable),
                    ruleID = vt("UploadEnclosurePicRuleID",globalTable),
                    callback="special_explain_enclosure",
                    UpdateViewLocation="false",
                    specialExplain = "true"
                };
            elseif vt("eatServerSupplement",globalTable) == "true" then
                --用餐申请单补录附件查询
                QueryEnclosureArg = {
                    billNo=vt("UploadEnclosurePicBillNo",globalTable),
                    billType = billTypeList_utils.eatServer,
                    UpdateViewLocation="false",
                    eatServerSupplement = "true"
                };
            else
                --常规附件查询
                QueryEnclosureArg = {
                    billNo=EnclosureBillNo,
                    loading="false",
                    UpdateViewLocation="false",
                    ReloadFlag=ReloadFlag
                };
            end;
            lua_upload.query_enclosure_pic(QueryEnclosureArg);
        else
            alert(errorMsg);
        end;
    end;
end;

--[[附件图片旋转]]
function lua_upload.pic_rotate(rotateArg)
    local rotateArg = json2table(rotateArg);

    --[[debug_alert(
        "附件图片旋转\n"..
        foreach_arg2print(rotateArg)..
        ""
    );]]

    local FileStyle = vt("FileStyle",rotateArg);
    if FileStyle == "image" then
        --执行附件旋转
        local ReqParams = {
            --附件单据号
            EnclosureNo=vt("EnclosureBillNo",rotateArg),
            --文件名
            RotateFileName=vt("PCFileName",rotateArg),
            --旋转角度
            RotateAngel=vt("RotateAngel",rotateArg,"90")
        };
        lua_upload.do_pic_rotate("",ReqParams);
    else
        alert("暂不支持旋转操作");
    end;
end;

--[[执行图片旋转，旋转后会刷新控件]]
function lua_upload.do_pic_rotate(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams);
        ReqParams["TranCode"] = "EnclosureService";
        ReqParams["EnclosureServiceCode"] = "RotateEnclosureImage";

        invoke_trancode_donot_checkRepeat(
            "jjbx_service",
            "app_service",
            ReqParams,
            lua_upload.do_pic_rotate,
            {},
            all_callback,
            {CloseLoading="false"}
        );
    else
        local res = json2table(ResParams["responseBody"]);
        local errorNo = vt("errorNo",res);
        local errorMsg = vt("errorMsg",res);

        --附件单据号
        local EnclosureBillNo = vt("EnclosureBillNo",res);

        --被旋转的文件名（需要更新文件下载链接）
        local RotateFileName = vt("RotateFileName",res);

        if errorNo == "000000" then
            --重新查询附件，没有loading
            local QueryEnclosureArg = {
                billNo=EnclosureBillNo,
                loading="false",
                UpdateViewLocation="false",
                ReloadFlag=vt("temp_reloadFlag",globalTable)
            };
            lua_upload.query_enclosure_pic(QueryEnclosureArg);
        else
            alert(errorMsg);
        end;
    end;
end;

--[[附件排序]]
function lua_upload.sort_enclosure(sortJsonArg)
    local sortTableArg = json2table(sortJsonArg);

    --附件单据号
    local EnclosureBillNo = vt("EnclosureBillNo", sortTableArg[1]);
    --排序的文件名列表
    local SortEnclosureFileNames = "";

    for i=1,#sortTableArg do
        if SortEnclosureFileNames == "" then
            SortEnclosureFileNames = vt("PCFileName",sortTableArg[i]);
        else
            SortEnclosureFileNames = SortEnclosureFileNames..","..vt("PCFileName",sortTableArg[i]);
        end;
    end;

    --[[debug_alert(
        "附件排序\n"..
        --"sortArg : "..sortArg.."\n"..
        "EnclosureBillNo : "..EnclosureBillNo.."\n"..
        "SortEnclosureFileNames : "..SortEnclosureFileNames.."\n"..
        ""
    );]]

    local ReqParams = {
        EnclosureBillNo=EnclosureBillNo,
        SortEnclosureFileNames=SortEnclosureFileNames
    };
    lua_upload.do_sort_enclosure("",ReqParams);
end;

--[[执行附件排序]]
function lua_upload.do_sort_enclosure(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local ReqParams = formatNull(ReqParams);
        ReqParams["TranCode"] = "EnclosureService";
        ReqParams["EnclosureServiceCode"] = "SortEnclosure";

        invoke_trancode_noloading_checkRepeat(
            "jjbx_service",
            "app_service",
            ReqParams,
            lua_upload.do_sort_enclosure,
            {},
            all_callback,
            {CloseLoading="true"}
        );
    else
        local res = json2table(ResParams["responseBody"]);
        local errorNo = vt("errorNo",res);
        local errorMsg = vt("errorMsg",res);

        --附件单据号
        local EnclosureBillNo = vt("EnclosureBillNo",res);

        if errorNo == "000000" then
            --重新查询附件，没有loading
            local QueryEnclosureArg = {
                billNo=EnclosureBillNo,
                loading="false",
                UpdateViewLocation="false"
            };
            lua_upload.query_enclosure_pic(QueryEnclosureArg);

            close_loading();
        else
            alert(errorMsg);
        end;
    end;
end;

--[[********************附件上传End********************]]

--[[********************文件用APP打开Begin********************]]

--[[app打开上传]]
function lua_upload.upload_file_by_app(filename,filepath)
    --检查登录
    local loginPkUser = formatNull(globalTable["PkUser"]);
    --debug_alert(loginPkUser);
    if loginPkUser ~= "" then
        --清理客户端登记任务
        lua_mission.clear_app_register_mission({ClearMsg="执行上传"});

        local filename = formatNull(filename);
        local filepath = formatNull(filepath);

        --[[debug_alert(
            "文件通过app打开上传\n"..
            "文件名称 : "..filename.."\n"..
            "文件路径 : "..filepath.."\n"..
            ""
        );]]

        if filename~="" and filepath~="" then
            --检查是否为允许的文件格式
            if string.find(filename,".pdf") or string.find(filename,".ofd") then
                --调用前关闭现有弹出的页面
                jjbx_utils_hideContent("true","false");

                local uploadTableArg = {
                    pagetitle="上传文件",
                    uploadtype="singleauto",
                    counts="1",
                    countsmsg="选择文件不能大于1个",
                    filetype="pdf,ofd",
                    loadFileType="PDF,OFD",
                    defaultType="PDF",
                    filetypemsg="目前只支持上传pdf,ofd格式的文件",
                    callfun="lua_jjbx.upload_invoice_to_add_call",
                    uploadflag="upInvoiceFile"
                };
                --自动上传的相关参数
                uploadTableArg["sa-filename"]=filename;
                uploadTableArg["sa-filepath"]=filepath;

                --由于是取的文件路径，不需要调用文件系统，这里放开检查
                local checkFileSupport = "false";
                lua_system.client_file_upload(uploadTableArg,"",checkFileSupport);
            else
                alert("目前只支持pdf，ofd格式文件上传");
            end;
        else
            --这里错误做下区分，客户端报错“上传文件异常，找不到文件路径”
            alert("上传文件异常，找不到文件");
        end;
    else
        --alert("上传文件前请先登录");
    end;
end;

--[[********************文件用APP打开End********************]]

--[[上传APP缓存附件路由]]
function lua_upload.upload_app_cache_enclosure(type)
    local type = formatNull(type);
    --取缓存参数
    local UploadAppCacheEnclosurePicMaxCounts = vt("UploadAppCacheEnclosurePicMaxCounts",globalTable,"5");
    --上传系统交互参数
    local UploadAppCacheEnclosureParams1 = lua_format.base64_encode(vt("UploadAppCacheEnclosureParams1",globalTable));
    --上传业务交互参数
    local UploadAppCacheEnclosureParams2 = vt("UploadAppCacheEnclosureParams2",globalTable);
    --上传预留参数
    local UploadAppCacheEnclosureParams3 = vt("UploadAppCacheEnclosureParams3",globalTable);

    if type=="camera" or type=="album" then
        local call_upload_widget_tableArg = {
            --操作标志 Upload上传，目前只用到上传
            doFlag="Upload",
            --doFlag为上传时，需要定义上传类型
            uploadFlag="upAppCacheEnclosure",
            --压缩类型，默认Min [No不压缩，Min最小压缩（头像），Normal正常压缩（发票）]
            compressStyle="Normal",
            --最大文件数
            maxCounts=UploadAppCacheEnclosurePicMaxCounts,
            --超过最大文件数提示
            maxCountsTip="选择图片不能大于5张",
            --回调方法
            callback="lua_upload.upload_app_cache_enclosure_callback",
            --预留参数位1，上送业务唯一ID，附件存放至该ID命名的目录下
            params1=UploadAppCacheEnclosureParams1,
            --预留参数位2
            params2=UploadAppCacheEnclosureParams2,
            --预留参数位3，上送业务回调方法
            params3=UploadAppCacheEnclosureParams3
        };
        --[[debug_alert(
            "相机/相册上传\n"..
            "类型 : "..type.."\n"..
            foreach_arg2print(call_upload_widget_tableArg).."\n"..
            ""
        );]]
        if type == "camera" then
            lua_system.open_camera(call_upload_widget_tableArg);
        else
            lua_system.open_album(call_upload_widget_tableArg);
        end;
    elseif type=="shoot_video" or type=="album_video" then
        local call_upload_widget_tableArg = {
            --操作标志 Upload上传，目前只用到上传
            doFlag="Upload",
            --上传类型
            uploadFlag="upAppCacheEnclosure",
            --压缩类型，默认Min [No不压缩，Min最小压缩，Normal正常压缩]
            compressStyle="Normal",
            --时间长度
            timeSeconds="15",
            --视频文件上传个数
            maxCounts="1",
            --视频文件上传超限提示
            maxCountsTip="单次只能上传1个视频文件",
            --单个视频文件上传尺寸限制
            maxSize="10",
            --单个视频文件上传尺寸超限提示
            maxSizeTip="视频尺寸大于10M，不能上传",
            --回调方法
            callback="lua_upload.upload_app_cache_enclosure_callback",
            --预留参数位1，上送业务唯一ID，附件存放至该ID命名的目录下
            params1=UploadAppCacheEnclosureParams1,
            --预留参数位2
            params2=UploadAppCacheEnclosureParams2,
            --预留参数位3
            params3=UploadAppCacheEnclosureParams3
        };
        --[[debug_alert(
            "拍摄/视频上传\n"..
            "类型 : "..type.."\n"..
            foreach_arg2print(call_upload_widget_tableArg).."\n"..
            ""
        );]]
        if type == "shoot_video" then
            --调用相机拍摄
            lua_system.open_camera_shoot(call_upload_widget_tableArg);
        else
            --调用相册选择视频
            lua_system.open_album_video(call_upload_widget_tableArg);
        end;
    else
        alert("不支持的上传方式");
    end;
end;

--[[APP缓存附件上传回调]]
function lua_upload.upload_app_cache_enclosure_callback(totalcounts, successcounts, resmsg, resinfoJson)
    local totalcounts = formatNull(totalcounts);
    local successcounts = formatNull(successcounts);
    local resmsg = formatNull(resmsg);
    local resinfoJson = formatNull(resinfoJson);

    --[[debug_alert(
        "APP缓存附件上传回调\n"..
        "上传总数  : "..totalcounts.."\n"..
        "成功数目  : "..successcounts.."\n"..
        "结果信息  : "..resmsg.."\n"..
        "返回信息 : "..resinfoJson.."\n"..
        ""
    );]]

    --上传的总张数跟成功的总张数相等，附件上传成功
    if tonumber(totalcounts) == tonumber(successcounts) then
        --上传成功后，通知PC端接收文件，完成文件入库
        local resinfoTable = json2table(resinfoJson);
        local res = vt("res",resinfoTable);
        local AppCacheEnclosureUploadedCallBack = vt("AppCacheEnclosureUploadedCallBack",res[1]);

        --[[debug_alert(
            "APP缓存附件上传信息\n"..
            "resinfoTable\n"..foreach_arg2print(resinfoTable).."\n"..
            --"res\n"..foreach_arg2print(res).."\n"..
            "AppCacheEnclosureId  : "..AppCacheEnclosureId.."\n"..
            "AppCacheEnclosureUploadedCallBack  : "..AppCacheEnclosureUploadedCallBack.."\n"..
            ""
        );]]

        --回调
        if AppCacheEnclosureUploadedCallBack ~= "" then
            lua_system.do_function(AppCacheEnclosureUploadedCallBack,res);
        else
            alertToast0(C_UploadedMsg);
        end;
    else
        --客户端上传到EWP失败
        alertToast1(C_Toast_FailedMsg);
    end;
end;

--[[生成APP附件下载链接]]
function lua_upload.gen_app_enclosure_dllink(Arg)
    --绝对路径
    local DlFilePath = vt("DlFilePath",Arg);
    --下载名称
    local DlFileName = vt("DlFileName",Arg);
    --下载地址
    local SysDlAddr = vt("SysDlAddr",systemTable);
    --返回链接
    local res = "";
    if SysDlAddr~="" and DlFilePath~="" and DlFileName~="" then
        res =
            SysDlAddr..
            "dlType=enclosure"..
            "&dlFileName="..lua_format.url_encode(DlFileName)..
            "&dlPath="..lua_format.base64_encode(DlFilePath)..
            "";
    end;
    return res;
end;

--[[生成PC静态资源预览链接]]
function lua_upload.gen_pc_sr_viewlink(Arg)
    --相对路径
    local DlFilePath = vt("DlFilePath",Arg);
    --下载名称
    local DlFileName = vt("DlFileName",Arg);
    --资源地址
    local StaticResourceAddr = vt("JJBX_Nginx_HOST",systemTable);
    --返回链接
    local res = "";
    if StaticResourceAddr~="" and DlFilePath~="" then
        res =
            StaticResourceAddr..
            "/webapp/staticResource"..
            lua_format.url_encode(DlFilePath)..
            "";
    end;
    return res;
end;

--[[清理上传缓存参数]]
function lua_upload.clear_upload_cache_arg()
    --debug_alert("清理上传缓存参数");
    globalTable["UploadAppCacheEnclosurePicMaxCounts"] = "";
    globalTable["UploadAppCacheEnclosureParams1"] = "";
    globalTable["UploadAppCacheEnclosureParams2"] = "";
    globalTable["UploadAppCacheEnclosureParams3"] = "";
end;

--[[
    客户端回调方法，返回正在上传的文件列表
    客户端指定的返回数据格式为json[{"fileName":"abc.png"},{"fileNanme","abc.pdf"}]
]]
function get_uploading_file(fileList)
    local FileList = json2table(fileList);
    local uploadingFile = vt("uploadingFile",globalTable,{});
    if #FileList > 0 then
        for key,value in pairs(FileList) do
            local t = {
                fileName = value["fileName"],
                fileID = value["fileHash"],
                uploadState = "正在上传"
            };
            table.insert(uploadingFile,t);
        end;
        changeStyle("drag_ctrl_ele2","display","block");
    end;
    globalTable["uploadingFile"] = uploadingFile;
    --弹窗提示
    alert("已添加至任务列表，您可点击任务图标查看，上传成功后将保存入池。");

    --更新上传任务详情页面信息
    init_uploading_file_info();

    --上传纸票后返回待报销列表页
    if vt("uploadInvoiceBack",globalTable) == "true" then
        globalTable["uploadInvoiceBack"] = "false";
        local billMenu_historyLength = vt("billMenu_historyLength",globalTable);
        back_fun(tonumber(billMenu_historyLength));
    end;
end;

--更新上传任务详情页面信息
function init_uploading_file_info()
    local uploadingFile = vt("uploadingFile",globalTable);
    local fileTypeIcon = "";
    local htmlContent = "";
    for key,value in pairs(uploadingFile) do
        if value["uploadState"] ~= "已保存" and value["uploadState"] ~= "取消保存" then
            local fileName = value["fileName"];
            local splitFileName = splitUtils(fileName,"%.");
            local splitFileNameLen = #splitFileName;
            local fileType = splitFileName[splitFileNameLen];
            local fileTypeStr = "pdf,PDF,eml,EML,excel,EXCEL,ofd,OFD,ppt,PPT,rar,RAR,txt,TXT,word,WORD,xml,XML,zip,ZIP";
            local fileTypeIcon = "";
            --根据已有的ICON拼接文件类型图片
            if string.find(fileTypeStr,fileType) then
                fileTypeIcon = "file_"..string.lower(fileType).."_icon.png";
            else
                fileTypeIcon = "file_other_icon.png";
            end;
            local uploadState = value["uploadState"];
            local displayFlag = "displayNone";
            if uploadState == "保存失败" then
                displayFlag = "displayBlock";
            end;
            --待保存、上传失败、保存失败的可以删除
            htmlContent = htmlContent..[[
                <horiTableViewControl class='main_module_div' width='355' divwidth='355' divheight='100' divwidth2='45' value='0' >
                    <div class="uploadingFile_div" border="0" onclick="reSave_invoice(']]..fileName..[[',']]..uploadState..[[')">
                        <img src="local:]]..fileTypeIcon..[[" class="fileTypeIcon_css" />
                        <label class="fileName_css" value="]]..fileName..[[" />
                        <label class="fileState_css" value="]]..uploadState..[[" />
                        <img src="edit_icon.png" class="edit_icon_css,]]..displayFlag..[[" />
                        <line class="line_css" style="bottom: 0px;" />
                    </div>
                    <div class="delete_div" border="1" onclick="cancelUpload(]]..key..[[)">
                        <label class="delete_value" value="删除" />
                    </div>
                </horiTableViewControl>
            ]];
        end;
    end;
    htmlContent = [[<div class="option_div,left-10" border="1" name="uploadingFileList">]]..htmlContent..[[</div>]];
    local element = document:getElementsByName("uploadingFileList");
    if #element > 0 then
        element[1]:setInnerHTML(htmlContent);
        page_reload();
    end;
end;

--保存发票的请求状态，0：上传中、1：上传完成
local invoiceSaveFlag = "1";
--保存识别成功的发票至发票池
function lua_upload.saveCheckSuccessInvoice(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        if invoiceSaveFlag == "1" then
            invoiceSaveFlag = "0";
            local ReqParams = formatNull(ReqParams,{});
            ReqParams["ReqAddr"] = "invoice/addInvoiceIntoPersonalInvPoool";
            ReqParams["ReqUrlExplain"] = "APP上传的发票关联至发票池";
            --debug_alert("保存上传的发票-请求"..foreach_arg2print(ReqParams));
            --获取第一条识别结果
            local ScrollData = vt("UploadInvoiceToAddRes",globalTable);
            --条目信息
            local ItemData = formatNull(ScrollData[1]);
            local fileID = vt("fileID",ItemData);
            local uploadingFile = vt("uploadingFile",globalTable);
            local saveFlag = "true";
            --根据ID去获取文件保存状态，如用户取消保存，则不调用保存接口
            for key,value in pairs(uploadingFile) do
                if tonumber(fileID) == tonumber(value["fileID"]) then
                    if value["uploadState"] == "取消保存" then
                        saveFlag = "false";
                    end;
                end;
            end;

            if saveFlag == "true" then
                --发票信息
                local InvoiceData = vt("obj",ItemData);
                --debug_alert("追加发票参数"..foreach_arg2print(InvoiceData));

                --初始化单张发票的参数
                local BusinessParams = {
                    --固定送参
                    --机构号
                    pkCorp=globalTable["selectOrgList"][1]["pkCorp"],
                    --机构名称
                    corpName=globalTable["selectOrgList"][1]["unitname"],
                    --申请人PK
                    pkUser=vt("PkUser",globalTable),
                    --申请人
                    psnName=vt("userName",globalTable),

                    --发票参数
                    --发票类型名称
                    invoiceType=vt("invoiceTypeName",InvoiceData),
                    --发票类型编码
                    invoiceTypeCode=vt("invoiceType",InvoiceData),
                    --发票内容编码
                    invoiceContentCode=vt("invoiceContentCode",InvoiceData),
                    --发票代码
                    invoiceCode=vt("invoiceCode",InvoiceData),
                    --发票号码
                    invoiceNo=vt("invoiceNumber",InvoiceData),
                    --总价
                    totalPrice=vt("taxAndPriceLow",InvoiceData),
                    --税额
                    taxAmount=vt("totalTax",InvoiceData,"0"),
                    --开票日期
                    invoiceDate=vt("makeTime",InvoiceData),
                    --销方名称
                    annulName=vt("salerName",InvoiceData),
                    --校验码
                    checkCode=vt("checkCode",InvoiceData),
                    --??ID
                    taxPayerId = vt("buyerTaxRegisNum",InvoiceData),
                    --??名称
                    acquiringName = vt("buyerName",InvoiceData),
                    --发票文件路径
                    filePath=vt("fileName",ItemData),
                };
                ReqParams["BusinessParams"] = table2json(BusinessParams);
                ReqParams["ReqFuncName"] = "invoke_trancode_noloading";
                ReqParams["BusinessCall"] = lua_upload.saveCheckSuccessInvoice;
                lua_jjbx.common_req(ReqParams);
            else
                --移除第一条数据
                table.remove(globalTable["UploadInvoiceToAddRes"],1);
                --如列表还存在数据，继续执行保存
                local ScrollData = vt("UploadInvoiceToAddRes",globalTable);
                if #ScrollData > 0 then
                    lua_upload.saveCheckSuccessInvoice("",{});
                end;
            end;
        end;
    else
        invoiceSaveFlag = "1";
        local res = json2table(ResParams["responseBody"]);
        local UploadInvoiceToAddRes = vt("UploadInvoiceToAddRes",globalTable);
        local fileID = vt("fileID",UploadInvoiceToAddRes[1]);
        local uploadingFile = vt("uploadingFile",globalTable,{});
        for key,value in pairs(uploadingFile) do
            if tonumber(fileID) == tonumber(value["fileID"]) then
                if res["errorNo"] == "000000" then
                    uploadingFile[key]["uploadState"] = "已保存";
                else
                    uploadingFile[key]["uploadState"] = "保存失败";
                end;
            end;
        end;

        local e = document:getElementsByName("uploadingFileList");
        if #e > 0 then
            --更新上传任务详情页面信息
            init_uploading_file_info();
        end;

        e = document:getElementsByName("list_widget");
        if #e > 0 then
            --刷新待报销列表
            --invoice_dbx_list_downFunc();
        end;

        if res["errorNo"] == "000000" then
            --保存成功将数据添加至成功的列表中
            if vt("saveInvoiceSuccessList",globalTable) == "" then
                globalTable["saveInvoiceSuccessList"] = {};
            end;
            table.insert(globalTable["saveInvoiceSuccessList"],UploadInvoiceToAddRes[1]);
        else
            --alert(res["errorMsg"]);
            --保存失败将数据添加至失败的列表中
            if vt("saveInvoiceFailedList",globalTable) == "" then
                globalTable["saveInvoiceFailedList"] = {};
            end;
            --向对应发票中存储查验返回信息
            UploadInvoiceToAddRes[1]["saveErrorNo"] = res["errorNo"];
            UploadInvoiceToAddRes[1]["saveErrorMsg"] = res["errorMsg"];
            table.insert(globalTable["saveInvoiceFailedList"],UploadInvoiceToAddRes[1]);
        end;
        --移除第一条数据
        table.remove(globalTable["UploadInvoiceToAddRes"],1);
        --如列表还存在数据，继续执行保存
        local ScrollData = vt("UploadInvoiceToAddRes",globalTable);
        if #ScrollData > 0 then
            lua_upload.saveCheckSuccessInvoice("",{});
        end;
    end;
end;