const lua_system = require('./system');
const lua_jjbx = require('./jjbx');
const lua_format = require('./format');
const lua_form = require('./form');
const lua_mission = require('./mission');
lua_upload = {};
lua_upload.upload_bank_card_to_scan = function (type) {
    var type = formatNull(type);
    var pic_cut_tableArg = {
        heightScale: '0.75',
        widthScale: '0.75',
        needBoard: 'true',
        cutPic: 'true',
        showTitle: '请将卡片置于裁剪区域内',
        edgeColor: '#F96A0E'
    };
    var call_upload_widget_tableArg = {
        doFlag: 'Upload',
        uploadFlag: 'upCardPic',
        compressStyle: 'No',
        maxCounts: '1',
        maxCountsTip: '选择图片不能大于1张',
        callback: 'upload_bankCardPic_callback',
        cutArg: pic_cut_tableArg
    };
    if (type === 'camera') {
        lua_system.open_camera(call_upload_widget_tableArg);
    } else if (type === 'album') {
        lua_system.open_album(call_upload_widget_tableArg);
    } else {
        alert('不支持的上传方式');
    }
};
upload_bankCardPic_callback = function (totalcounts, successcounts, resmsg, resinfoJson) {
    if (parseFloat(totalcounts) === parseFloat(successcounts)) {
        var resinfoTable = json2table(resinfoJson);
        var res = vt('res', resinfoTable);
        res = formatNull(res[1]);
        var ocr_card_no = vt('ocr_card_no', res);
        var error_no = vt('error_no', res);
        var error_msg = vt('error_nerror_msg', res);
        if (error_no === '000000') {
            var updateWidgetName = vt('CardNoWidgetName', globalTable);
            globalTable['CardNoWidgetName'] = '';
            if (updateWidgetName != '' && string.len(ocr_card_no) >= 10) {
                changeProperty('account_no', 'value', ocr_card_no);
            } else {
                alertToast1(C_Ocr_FailedMsg);
            }
        } else {
            if (error_msg === '') {
                alertToast1(C_Ocr_FailedMsg);
            } else {
                alert(error_msg);
            }
        }
    } else {
        alert('卡片上传失败');
    }
};
lua_upload.upload_headPic = function (type) {
    var type = formatNull(type);
    var call_upload_widget_tableArg = {
        doFlag: 'Upload',
        uploadFlag: 'upHeadProtrait',
        compressStyle: 'Min',
        maxCounts: '1',
        maxCountsTip: '选择图片不能大于1张',
        callback: 'upload_headPic_callback'
    };
    if (type === 'camera') {
        lua_system.open_camera(call_upload_widget_tableArg);
    } else if (type === 'album') {
        lua_system.open_album(call_upload_widget_tableArg);
    } else {
        alert('不支持的上传方式');
    }
};
get_related_inv_img = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var FileAbsPath = vt('filePath', ReqParams);
        if (FileAbsPath != '') {
            invoke_trancode_noloading('jjbx_process_query', 'jjbx_fpc', {
                TranCode: 'GetRelatedInvImg',
                FileAbsPath: vt('filePath', ReqParams),
                OFD2PDF: 'false',
                netFlag: '1'
            }, get_related_inv_img, {});
        } else {
        }
    } else {
        var res = json2table(vt('responseBody', ResParams));
        var isInvoiceFile = vt('isInvoiceFile', res);
        var PCInvoiceFileType = vt('FileType', res);
        var PCInvoiceFileDlUrl = vt('PCInvoiceFileDlUrl', res);
        var FileOriginalType = vt('FileOriginalType', res);
        var doReplace = vt('DoReplace', res);
        if (PCInvoiceFileDlUrl != '') {
            if (isInvoiceFile === 'true') {
                alert_confirm('温馨提示', '请选择打开方式', '取消', '预览附件', 'do_download_ofd_enclosure', '');
            } else {
                alert_confirm('温馨提示', '暂不支持该类型文件预览', '取消', '下载附件', 'do_download_enclosure', globalTable['OfdFileDlUrl']);
            }
        }
    }
};
view_pdf_CallBack = function (res) {
    close_loading();
    var res = json2table(res['responseBody']);
    var tableArg = json2table(res['Arg']);
    var FileName = res['FileName'];
    var PCInvoiceFileDlUrl = res['PCInvoiceFileDlUrl'];
    var openPdfArg = {
        pdfLinkUrl: PCInvoiceFileDlUrl,
        pdfFileType: file_type,
        pdfPageTitle: '查看附件',
        pdfOpenStyle: 'ClientWidget'
    };
    lua_system.view_file_by_webview(openPdfArg);
};
view_pdf = function (Arg) {
    var arg = json2table(Arg);
    var viewPdf_params = {
        billNo: arg['EnclosureBillNo'],
        fileName: arg['PCFileName'],
        fileKey: arg['fileKey'],
        TranCode: 'viewPdf',
        billType: arg['billType']
    };
    invoke_trancode_donot_checkRepeat('jjbx_process_query', 'jjbx_fpc', viewPdf_params, view_pdf_CallBack, {}, all_callback, {
        CloseLoading: 'false',
        Arg: Arg
    });
};
download_enclosure = function (Arg) {
    var tableArg = json2table(Arg);
    var file_type = vt('FileType', tableArg);
    var file_dlurl = vt('FileDlUrl', tableArg);
    var PCConfigListsTable = vt('PCConfigListsTable', globalTable);
    var IMG0015 = vt('IMG0015', PCConfigListsTable);
    var IMG0016 = vt('IMG0016', PCConfigListsTable);
    if (string.find('pdf', file_type)) {
        var openPdfArg = {
            pdfLinkUrl: file_dlurl,
            pdfFileType: file_type,
            pdfPageTitle: '查看附件',
            pdfOpenStyle: 'ClientWidget'
        };
        lua_system.view_file_by_webview(openPdfArg);
    } else if (string.find(C_AppH5ViewFileTypeList, file_type)) {
        var openPdfArg = {
            pdfLinkUrl: file_dlurl,
            pdfFileType: file_type,
            pdfPageTitle: '查看附件',
            pdfOpenStyle: 'ClientWidget'
        };
        lua_system.view_file_by_webview(openPdfArg);
    } else if (file_type === 'zip' || file_type === 'rar' || file_type === 'eml') {
        if (vt('downloadFlag', globalTable) === 'true') {
            alert_confirm('温馨提示', '不支持预览' + (file_type + '格式的文件'), '取消', '下载附件', 'do_download_enclosure', file_dlurl);
        } else {
            alert_confirm('温馨提示', '不支持预览' + (file_type + '格式的文件'), '', '确定');
        }
    } else if (file_type === 'ofd') {
        var ofd_file_view_url = vt('previewPath', tableArg);
        if (ofd_file_view_url != '') {
            lua_system.alert_webview({
                title: '文件预览',
                visit_url: ofd_file_view_url,
                close_call_func: '',
                back_type: 'BACK',
                listen_url: 'http://app_h5_callback_url',
                listen_call: 'lua_system.webview_h5_callback'
            });
        } else {
            lua_upload.get_related_inv_img(vt('fileKey', tableArg), vt('PCFilePath', tableArg));
        }
    } else {
        alert('不支持预览' + (file_type + '格式的文件'));
    }
};
lua_upload.getRelatedInvImgCallBack = function (res) {
    var responseBody = json2table(vt('responseBody', res));
    if (responseBody['errorNo'] === '000000') {
        close_loading();
        var imgList = vt('imgList', responseBody);
        if (imgList.length > 0) {
            lua_system.alert_webview({
                title: '文件预览',
                visit_url: imgList[1],
                close_call_func: '',
                back_type: 'BACK',
                listen_url: 'http://app_h5_callback_url',
                listen_call: 'lua_system.webview_h5_callback'
            });
        } else {
            alert('无法获取文件预览链接');
        }
    } else {
        alert(responseBody['errorMsg']);
    }
};
lua_upload.get_related_inv_img = function (fileKey, filePath) {
    var ReqParams = {};
    ReqParams['ReqAddr'] = 'invoice/getRelatedInvImg';
    ReqParams['ReqUrlExplain'] = '查询附件预览链接';
    ReqParams['BusinessCall'] = lua_upload.getRelatedInvImgCallBack;
    var getRelatedInvImg_params = {
        channel: '1',
        ofdFileKey: fileKey,
        path: filePath,
        netFlag: '1'
    };
    ReqParams['BusinessParams'] = table2json(getRelatedInvImg_params);
    lua_jjbx.common_req(ReqParams);
};
do_download_enclosure = function (TouchIndex, CallArg) {
    if (tostring(TouchIndex) === '1') {
        lua_system.download_file(CallArg);
    }
};
do_download_ofd_enclosure = function (TouchIndex, CallArg) {
    var viewUrl = globalTable['OfdFileViewUrl'];
    var dlUrl = globalTable['OfdFileDlUrl'];
    globalTable['OfdFileViewUrl'] = '';
    globalTable['OfdFileDlUrl'] = '';
    if (tostring(TouchIndex) === '1') {
        lua_system.file_preview(viewUrl, 'pdf');
    }
};
lua_upload.query_enclosure_pic = function (QryEnclosureArg) {
    var billNo = vt('billNo', QryEnclosureArg);
    var billType = vt('billType', QryEnclosureArg);
    var callback = vt('callback', QryEnclosureArg, 'lua_upload.init_upload_enclosure_widget');
    var loading = vt('loading', QryEnclosureArg, 'true');
    var UpdateViewLocation = vt('UpdateViewLocation', QryEnclosureArg, 'true');
    var doQueryCallBack = lua_format.str2fun(callback);
    var ReloadFlag = vt('ReloadFlag', QryEnclosureArg);
    var specialExplain = vt('specialExplain', QryEnclosureArg);
    var RuleID = vt('ruleID', QryEnclosureArg);
    var eatServerSupplement = vt('eatServerSupplement', QryEnclosureArg);
    var netfunction = '';
    var LoadingClose = '';
    if (loading === 'true') {
        netfunction = 'invoke_trancode_donot_checkRepeat';
        LoadingClose = 'false';
    } else {
        netfunction = 'invoke_trancode_noloading';
        LoadingClose = 'true';
    }
    var doNetfunction = lua_format.str2fun(netfunction);
    var QryType = '';
    var UploadEnclosurePicEditFlag = formatNull(globalTable['UploadEnclosurePicEditFlag'], 'YES');
    if (UploadEnclosurePicEditFlag === 'NO') {
        QryType = 'Look';
    }
    doNetfunction('jjbx_service', 'app_service', {
        TranCode: 'EnclosureService',
        EnclosureServiceCode: 'QryPCEnclosure',
        EnclosureNo: billNo,
        billType: billType,
        QryType: QryType,
        UpdateViewLocation: UpdateViewLocation,
        ReloadFlag: ReloadFlag,
        SpecialExplain: specialExplain,
        RuleID: RuleID,
        eatServerSupplement: eatServerSupplement
    }, doQueryCallBack, {}, all_callback, { CloseLoading: LoadingClose });
};
query_upload_enclosure_counts = function (billNo, ReqParams) {
    var billNo = formatNull(billNo);
    var ReqParams = formatNull(ReqParams, {});
    ReqParams['billNo'] = billNo;
    lua_upload.update_counts_cache('', ReqParams);
};
lua_upload.update_counts_cache = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        var ResCallFunc = vt('ResCallFunc', ReqParams);
        ReqParams['TranCode'] = 'EnclosureService';
        ReqParams['EnclosureServiceCode'] = 'QryPCEnclosure';
        ReqParams['EnclosureNo'] = vt('billNo', ReqParams);
        ReqParams['QryType'] = 'Look';
        invoke_trancode_noloading('jjbx_service', 'app_service', ReqParams, lua_upload.update_counts_cache, { ResCallFunc: ResCallFunc }, all_callback, { CloseLoading: 'false' });
    } else {
        var res = json2table(ResParams['responseBody']);
        var PcEnclosureTotalCounts = vt('PcEnclosureTotalCounts', res, '0');
        globalTable['PcEnclosureTotalCounts'] = PcEnclosureTotalCounts;
        if (parseFloat(PcEnclosureTotalCounts) > 0) {
            var e = document.getElementsByName('seeAnnex');
            if (e.length > 0) {
                changeStyle('seeAnnex', 'display', 'block');
                page_reload();
            }
        }
        var ResCallFunc = vt('ResCallFunc', ResParams);
        lua_system.do_function(ResCallFunc, res);
    }
};
lua_upload.init_upload_enclosure_widget = function (params) {
    var responseBody = json2table(params['responseBody']);
    var errorNo = vt('BillFileQryErrorNo', responseBody);
    var errorMsg = vt('BillFileQryErrorMsg', responseBody);
    if (errorNo === '000000') {
        var PcEnclosureTotalCounts = vt('PcEnclosureTotalCounts', responseBody, '0');
        var UpdateViewLocation = vt('UpdateViewLocation', responseBody);
        var ReloadFlag = vt('ReloadFlag', responseBody);
        if (ReloadFlag === '1') {
            lua_jjbx.update_answer_transfer_enclosure_call(params);
        } else {
            enclosurepic_uploaded_call(responseBody);
        }
        var WidgetData = '';
        if (parseFloat(PcEnclosureTotalCounts) > 0) {
            WidgetData = params['responseBody'];
        }
        changeProperty('uploadEnclosure', 'value', WidgetData);
        close_loading();
    } else {
        changeProperty('uploadEnclosure', 'value', '');
        alert(errorMsg);
    }
};
lua_upload.upload_enclosure = function (type) {
    var type = formatNull(type);
    var billNo = vt('UploadEnclosurePicBillNo', globalTable);
    var billType = vt('UploadEnclosurePicBillType', globalTable);
    var ReloadFlag = vt('UploadEnclosurePicReloadFlag', globalTable);
    var specialExplain = vt('specialExplain', globalTable);
    var eatServerSupplement = vt('eatServerSupplement', globalTable);
    var ruleID = vt('UploadEnclosurePicRuleID', globalTable);
    var params3 = {
        ReloadFlag: ReloadFlag,
        specialExplain: specialExplain,
        eatServerSupplement: eatServerSupplement,
        ruleID: ruleID
    };
    params3 = lua_format.base64_encode(table2json(params3));
    var argListTable = [
        billType,
        billNo
    ];
    var checkArgRes = lua_form.arglist_check_empty(argListTable);
    if (checkArgRes === 'true') {
        if (type === 'camera') {
            var call_upload_widget_tableArg = {
                doFlag: 'Upload',
                uploadFlag: 'upEnclosurePic',
                compressStyle: 'No',
                maxCounts: '1',
                maxCountsTip: '拍照图片不能大于1张',
                callback: 'lua_upload.upload_enclosure_callback',
                cutArg: {
                    heightScale: '0.75',
                    widthScale: '0.75',
                    needBoard: 'true',
                    cutPic: 'true',
                    showTitle: '请将附件置于取景框内',
                    edgeColor: '#F96A0E'
                },
                params1: billType,
                params2: billNo,
                params3: params3
            };
            lua_system.open_camera(call_upload_widget_tableArg);
        } else if (type === 'album') {
            var call_upload_widget_tableArg = {
                doFlag: 'Upload',
                uploadFlag: 'upEnclosurePic',
                compressStyle: 'Normal',
                maxCounts: '5',
                maxCountsTip: '选择图片不能大于5张',
                callback: 'lua_upload.upload_enclosure_callback',
                params1: billType,
                params2: billNo,
                params3: params3
            };
            lua_system.open_album(call_upload_widget_tableArg);
        } else if (type === 'filesystem') {
            var pagetitle = C_SearchContextBegin + ('文件名' + C_SearchContextEnd);
            var filetype = 'pdf,ofd,doc,docx,eml,PDF,OFD,DOC,DOCX,EML,png,jpg,jpeg,PNG,JPG,JPEG';
            var tableArg = {
                pagetitle: pagetitle,
                uploadtype: 'multiple',
                counts: '5',
                countsmsg: '选择文件不能大于5个',
                filetype: filetype,
                loadFileType: 'PDF,OFD,其他',
                defaultType: 'PDF',
                filetypemsg: '目前不支持上传该格式的文件',
                callfun: 'lua_upload.upload_enclosure_callback',
                uploadflag: 'upEnclosureFile',
                params1: billType,
                params2: billNo,
                params3: params3
            };
            lua_system.client_file_upload(tableArg);
        } else {
            alert('不支持的上传方式');
        }
    } else {
        alert('单据信息不完整\uFF0C无法上传');
    }
};
lua_upload.upload_enclosure_callback = function (totalcounts, successcounts, resmsg, resinfoJson) {
    var totalcounts = formatNull(totalcounts);
    var successcounts = formatNull(successcounts);
    var resmsg = formatNull(resmsg);
    var resinfoJson = formatNull(resinfoJson);
    if (parseFloat(successcounts) > 0) {
        var resinfoTable = json2table(resinfoJson);
        var res = vt('res', resinfoTable);
        var EnclosureType = vt('EnclosureType', res[1]);
        var EnclosureNo = vt('EnclosureNo', res[1]);
        var ReloadFlag = vt('ReloadFlag', res[1]);
        var pushArg = {
            billTye: EnclosureType,
            billNo: EnclosureNo,
            uploadInfo: resinfoJson,
            ReloadFlag: ReloadFlag
        };
        lua_upload.push_file_to_pc_receiver(pushArg);
    } else {
        alertToast1(C_Toast_FailedMsg);
    }
};
lua_upload.push_file_to_pc_receiver = function (pushArg) {
    var billNo = vt('billNo', pushArg);
    var billTye = vt('billTye', pushArg);
    var uploadInfo = vt('uploadInfo', pushArg);
    var ReloadFlag = vt('ReloadFlag', pushArg);
    var pushReqArg = {
        TranCode: 'EnclosureService',
        EnclosureServiceCode: 'PushEnclosureToPC',
        EnclosureNo: billNo,
        EnclosureType: billTye,
        EnclosureInfo: uploadInfo,
        ReloadFlag: ReloadFlag
    };
    invoke_trancode_donot_checkRepeat('jjbx_service', 'app_service', pushReqArg, file_receive_call, {}, all_callback, { CloseLoading: 'false' });
};
file_receive_call = function (params) {
    var responseBody = json2table(params['responseBody']);
    enclosurepic_uploaded_call(responseBody);
    if (responseBody['errorNo'] === '000000') {
        lua_upload.init_upload_enclosure_widget(params);
        alertToast0(C_UploadedMsg);
    } else {
        alert(responseBody['errorMsg']);
    }
};
enclosurepic_uploaded_call = function (responseBody) {
};
update_enclosurepic_page_tip = function (msg) {
};
lua_upload.del_pic_enclosure = function (delarg) {
    var delarg = json2table(delarg);
    var ReqParams = {
        EnclosureNo: vt('EnclosureBillNo', delarg),
        DelFileNames: vt('PCFileName', delarg),
        ReloadFlag: vt('UploadEnclosurePicReloadFlag', globalTable),
        eatServerSupplement: vt('eatServerSupplement', globalTable)
    };
    lua_upload.do_del_pic_enclosure('', ReqParams);
};
lua_upload.do_del_pic_enclosure = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['TranCode'] = 'EnclosureService';
        ReqParams['EnclosureServiceCode'] = 'DelPCEnclosure';
        invoke_trancode_noloading_checkRepeat('jjbx_service', 'app_service', ReqParams, lua_upload.do_del_pic_enclosure, {}, all_callback, { CloseLoading: 'true' });
    } else {
        var res = json2table(ResParams['responseBody']);
        var errorNo = vt('errorNo', res);
        var errorMsg = vt('errorMsg', res);
        var EnclosureBillNo = vt('EnclosureBillNo', res);
        var ReloadFlag = vt('ReloadFlag', res);
        if (errorNo === '000000') {
            alertToast0(C_DeleteMsg);
            var QueryEnclosureArg = {};
            if (vt('specialExplain', globalTable) === 'true') {
                QueryEnclosureArg = {
                    billNo: vt('UploadEnclosurePicBillNo', globalTable),
                    billType: vt('UploadEnclosurePicBillType', globalTable),
                    ruleID: vt('UploadEnclosurePicRuleID', globalTable),
                    callback: 'special_explain_enclosure',
                    UpdateViewLocation: 'false',
                    specialExplain: 'true'
                };
            } else if (vt('eatServerSupplement', globalTable) === 'true') {
                QueryEnclosureArg = {
                    billNo: vt('UploadEnclosurePicBillNo', globalTable),
                    billType: billTypeList_utils.eatServer,
                    UpdateViewLocation: 'false',
                    eatServerSupplement: 'true'
                };
            } else {
                QueryEnclosureArg = {
                    billNo: EnclosureBillNo,
                    loading: 'false',
                    UpdateViewLocation: 'false',
                    ReloadFlag: ReloadFlag
                };
            }
            lua_upload.query_enclosure_pic(QueryEnclosureArg);
        } else {
            alert(errorMsg);
        }
    }
};
lua_upload.pic_rotate = function (rotateArg) {
    var rotateArg = json2table(rotateArg);
    var FileStyle = vt('FileStyle', rotateArg);
    if (FileStyle === 'image') {
        var ReqParams = {
            EnclosureNo: vt('EnclosureBillNo', rotateArg),
            RotateFileName: vt('PCFileName', rotateArg),
            RotateAngel: vt('RotateAngel', rotateArg, '90')
        };
        lua_upload.do_pic_rotate('', ReqParams);
    } else {
        alert('暂不支持旋转操作');
    }
};
lua_upload.do_pic_rotate = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['TranCode'] = 'EnclosureService';
        ReqParams['EnclosureServiceCode'] = 'RotateEnclosureImage';
        invoke_trancode_donot_checkRepeat('jjbx_service', 'app_service', ReqParams, lua_upload.do_pic_rotate, {}, all_callback, { CloseLoading: 'false' });
    } else {
        var res = json2table(ResParams['responseBody']);
        var errorNo = vt('errorNo', res);
        var errorMsg = vt('errorMsg', res);
        var EnclosureBillNo = vt('EnclosureBillNo', res);
        var RotateFileName = vt('RotateFileName', res);
        if (errorNo === '000000') {
            var QueryEnclosureArg = {
                billNo: EnclosureBillNo,
                loading: 'false',
                UpdateViewLocation: 'false',
                ReloadFlag: vt('temp_reloadFlag', globalTable)
            };
            lua_upload.query_enclosure_pic(QueryEnclosureArg);
        } else {
            alert(errorMsg);
        }
    }
};
lua_upload.sort_enclosure = function (sortJsonArg) {
    var sortTableArg = json2table(sortJsonArg);
    var EnclosureBillNo = vt('EnclosureBillNo', sortTableArg[1]);
    var SortEnclosureFileNames = '';
    for (let i = 1; sortTableArg.length; i++) {
        if (SortEnclosureFileNames === '') {
            SortEnclosureFileNames = vt('PCFileName', sortTableArg[i]);
        } else {
            SortEnclosureFileNames = SortEnclosureFileNames + (',' + vt('PCFileName', sortTableArg[i]));
        }
    }
    var ReqParams = {
        EnclosureBillNo: EnclosureBillNo,
        SortEnclosureFileNames: SortEnclosureFileNames
    };
    lua_upload.do_sort_enclosure('', ReqParams);
};
lua_upload.do_sort_enclosure = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['TranCode'] = 'EnclosureService';
        ReqParams['EnclosureServiceCode'] = 'SortEnclosure';
        invoke_trancode_noloading_checkRepeat('jjbx_service', 'app_service', ReqParams, lua_upload.do_sort_enclosure, {}, all_callback, { CloseLoading: 'true' });
    } else {
        var res = json2table(ResParams['responseBody']);
        var errorNo = vt('errorNo', res);
        var errorMsg = vt('errorMsg', res);
        var EnclosureBillNo = vt('EnclosureBillNo', res);
        if (errorNo === '000000') {
            var QueryEnclosureArg = {
                billNo: EnclosureBillNo,
                loading: 'false',
                UpdateViewLocation: 'false'
            };
            lua_upload.query_enclosure_pic(QueryEnclosureArg);
            close_loading();
        } else {
            alert(errorMsg);
        }
    }
};
lua_upload.upload_file_by_app = function (filename, filepath) {
    var loginPkUser = formatNull(globalTable['PkUser']);
    if (loginPkUser != '') {
        lua_mission.clear_app_register_mission({ ClearMsg: '执行上传' });
        var filename = formatNull(filename);
        var filepath = formatNull(filepath);
        if (filename != '' && filepath != '') {
            if (string.find(filename, '.pdf') || string.find(filename, '.ofd')) {
                jjbx_utils_hideContent('true', 'false');
                var uploadTableArg = {
                    pagetitle: '上传文件',
                    uploadtype: 'singleauto',
                    counts: '1',
                    countsmsg: '选择文件不能大于1个',
                    filetype: 'pdf,ofd',
                    loadFileType: 'PDF,OFD',
                    defaultType: 'PDF',
                    filetypemsg: '目前只支持上传pdf,ofd格式的文件',
                    callfun: 'lua_jjbx.upload_invoice_to_add_call',
                    uploadflag: 'upInvoiceFile'
                };
                uploadTableArg['sa-filename'] = filename;
                uploadTableArg['sa-filepath'] = filepath;
                var checkFileSupport = 'false';
                lua_system.client_file_upload(uploadTableArg, '', checkFileSupport);
            } else {
                alert('目前只支持pdf\uFF0Cofd格式文件上传');
            }
        } else {
            alert('上传文件异常\uFF0C找不到文件');
        }
    } else {
    }
};
lua_upload.upload_app_cache_enclosure = function (type) {
    var type = formatNull(type);
    var UploadAppCacheEnclosurePicMaxCounts = vt('UploadAppCacheEnclosurePicMaxCounts', globalTable, '5');
    var UploadAppCacheEnclosureParams1 = lua_format.base64_encode(vt('UploadAppCacheEnclosureParams1', globalTable));
    var UploadAppCacheEnclosureParams2 = vt('UploadAppCacheEnclosureParams2', globalTable);
    var UploadAppCacheEnclosureParams3 = vt('UploadAppCacheEnclosureParams3', globalTable);
    if (type === 'camera' || type === 'album') {
        var call_upload_widget_tableArg = {
            doFlag: 'Upload',
            uploadFlag: 'upAppCacheEnclosure',
            compressStyle: 'Normal',
            maxCounts: UploadAppCacheEnclosurePicMaxCounts,
            maxCountsTip: '选择图片不能大于5张',
            callback: 'lua_upload.upload_app_cache_enclosure_callback',
            params1: UploadAppCacheEnclosureParams1,
            params2: UploadAppCacheEnclosureParams2,
            params3: UploadAppCacheEnclosureParams3
        };
        if (type === 'camera') {
            lua_system.open_camera(call_upload_widget_tableArg);
        } else {
            lua_system.open_album(call_upload_widget_tableArg);
        }
    } else if (type === 'shoot_video' || type === 'album_video') {
        var call_upload_widget_tableArg = {
            doFlag: 'Upload',
            uploadFlag: 'upAppCacheEnclosure',
            compressStyle: 'Normal',
            timeSeconds: '15',
            maxCounts: '1',
            maxCountsTip: '单次只能上传1个视频文件',
            maxSize: '10',
            maxSizeTip: '视频尺寸大于10M\uFF0C不能上传',
            callback: 'lua_upload.upload_app_cache_enclosure_callback',
            params1: UploadAppCacheEnclosureParams1,
            params2: UploadAppCacheEnclosureParams2,
            params3: UploadAppCacheEnclosureParams3
        };
        if (type === 'shoot_video') {
            lua_system.open_camera_shoot(call_upload_widget_tableArg);
        } else {
            lua_system.open_album_video(call_upload_widget_tableArg);
        }
    } else {
        alert('不支持的上传方式');
    }
};
lua_upload.upload_app_cache_enclosure_callback = function (totalcounts, successcounts, resmsg, resinfoJson) {
    var totalcounts = formatNull(totalcounts);
    var successcounts = formatNull(successcounts);
    var resmsg = formatNull(resmsg);
    var resinfoJson = formatNull(resinfoJson);
    if (parseFloat(totalcounts) === parseFloat(successcounts)) {
        var resinfoTable = json2table(resinfoJson);
        var res = vt('res', resinfoTable);
        var AppCacheEnclosureUploadedCallBack = vt('AppCacheEnclosureUploadedCallBack', res[1]);
        if (AppCacheEnclosureUploadedCallBack != '') {
            lua_system.do_function(AppCacheEnclosureUploadedCallBack, res);
        } else {
            alertToast0(C_UploadedMsg);
        }
    } else {
        alertToast1(C_Toast_FailedMsg);
    }
};
lua_upload.gen_app_enclosure_dllink = function (Arg) {
    var DlFilePath = vt('DlFilePath', Arg);
    var DlFileName = vt('DlFileName', Arg);
    var SysDlAddr = vt('SysDlAddr', systemTable);
    var res = '';
    if (SysDlAddr != '' && DlFilePath != '' && DlFileName != '') {
        res = SysDlAddr + ('dlType=enclosure' + ('&dlFileName=' + (lua_format.url_encode(DlFileName) + ('&dlPath=' + (lua_format.base64_encode(DlFilePath) + '')))));
    }
    return res;
};
lua_upload.gen_pc_sr_viewlink = function (Arg) {
    var DlFilePath = vt('DlFilePath', Arg);
    var DlFileName = vt('DlFileName', Arg);
    var StaticResourceAddr = vt('JJBX_Nginx_HOST', systemTable);
    var res = '';
    if (StaticResourceAddr != '' && DlFilePath != '') {
        res = StaticResourceAddr + ('/webapp/staticResource' + (lua_format.url_encode(DlFilePath) + ''));
    }
    return res;
};
lua_upload.clear_upload_cache_arg = function () {
    globalTable['UploadAppCacheEnclosurePicMaxCounts'] = '';
    globalTable['UploadAppCacheEnclosureParams1'] = '';
    globalTable['UploadAppCacheEnclosureParams2'] = '';
    globalTable['UploadAppCacheEnclosureParams3'] = '';
};
get_uploading_file = function (fileList) {
    var FileList = json2table(fileList);
    var uploadingFile = vt('uploadingFile', globalTable, {});
    if (FileList.length > 0) {
        for (var [key, value] in pairs(FileList)) {
            var t = {
                fileName: value['fileName'],
                fileID: value['fileHash'],
                uploadState: '正在上传'
            };
            table.insert(uploadingFile, t);
        }
        changeStyle('drag_ctrl_ele2', 'display', 'block');
    }
    globalTable['uploadingFile'] = uploadingFile;
    alert('已添加至任务列表\uFF0C您可点击任务图标查看\uFF0C上传成功后将保存入池\u3002');
    init_uploading_file_info();
    if (vt('uploadInvoiceBack', globalTable) === 'true') {
        globalTable['uploadInvoiceBack'] = 'false';
        var billMenu_historyLength = vt('billMenu_historyLength', globalTable);
        back_fun(parseFloat(billMenu_historyLength));
    }
};
init_uploading_file_info = function () {
    var uploadingFile = vt('uploadingFile', globalTable);
    var fileTypeIcon = '';
    var htmlContent = '';
    for (var [key, value] in pairs(uploadingFile)) {
        if (value['uploadState'] != '已保存' && value['uploadState'] != '取消保存') {
            var fileName = value['fileName'];
            var splitFileName = splitUtils(fileName, '%.');
            var splitFileNameLen = splitFileName.length;
            var fileType = splitFileName[splitFileNameLen];
            var fileTypeStr = 'pdf,PDF,eml,EML,excel,EXCEL,ofd,OFD,ppt,PPT,rar,RAR,txt,TXT,word,WORD,xml,XML,zip,ZIP';
            var fileTypeIcon = '';
            if (string.find(fileTypeStr, fileType)) {
                fileTypeIcon = 'file_' + (string.lower(fileType) + '_icon.png');
            } else {
                fileTypeIcon = 'file_other_icon.png';
            }
            var uploadState = value['uploadState'];
            var displayFlag = 'displayNone';
            if (uploadState === '保存失败') {
                displayFlag = 'displayBlock';
            }
            htmlContent = htmlContent + ('[[\n                <horiTableViewControl class=\'main_module_div\' width=\'355\' divwidth=\'355\' divheight=\'100\' divwidth2=\'45\' value=\'0\' >\n                    <div class="uploadingFile_div" border="0" onclick="reSave_invoice(\']]' + (fileName + ('[[\',\']]' + (uploadState + ('[[\')">\n                        <img src="local:]]' + (fileTypeIcon + ('[[" class="fileTypeIcon_css" />\n                        <label class="fileName_css" value="]]' + (fileName + ('[[" />\n                        <label class="fileState_css" value="]]' + (uploadState + ('[[" />\n                        <img src="edit_icon.png" class="edit_icon_css,]]' + (displayFlag + ('[[" />\n                        <line class="line_css" style="bottom: 0px;" />\n                    </div>\n                    <div class="delete_div" border="1" onclick="cancelUpload(]]' + (key + '[[)">\n                        <label class="delete_value" value="删除" />\n                    </div>\n                </horiTableViewControl>\n            ]]'))))))))))))));
        }
    }
    htmlContent = '[[<div class="option_div,left-10" border="1" name="uploadingFileList">]]' + (htmlContent + '[[</div>]]');
    var element = document.getElementsByName('uploadingFileList');
    if (element.length > 0) {
        element[1].setInnerHTML(htmlContent);
        page_reload();
    }
};
var invoiceSaveFlag = '1';
lua_upload.saveCheckSuccessInvoice = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        if (invoiceSaveFlag === '1') {
            invoiceSaveFlag = '0';
            var ReqParams = formatNull(ReqParams, {});
            ReqParams['ReqAddr'] = 'invoice/addInvoiceIntoPersonalInvPoool';
            ReqParams['ReqUrlExplain'] = 'APP上传的发票关联至发票池';
            var ScrollData = vt('UploadInvoiceToAddRes', globalTable);
            var ItemData = formatNull(ScrollData[1]);
            var fileID = vt('fileID', ItemData);
            var uploadingFile = vt('uploadingFile', globalTable);
            var saveFlag = 'true';
            for (var [key, value] in pairs(uploadingFile)) {
                if (parseFloat(fileID) === parseFloat(value['fileID'])) {
                    if (value['uploadState'] === '取消保存') {
                        saveFlag = 'false';
                    }
                }
            }
            if (saveFlag === 'true') {
                var InvoiceData = vt('obj', ItemData);
                var BusinessParams = {
                    pkCorp: globalTable['selectOrgList'][1]['pkCorp'],
                    corpName: globalTable['selectOrgList'][1]['unitname'],
                    pkUser: vt('PkUser', globalTable),
                    psnName: vt('userName', globalTable),
                    invoiceType: vt('invoiceTypeName', InvoiceData),
                    invoiceTypeCode: vt('invoiceType', InvoiceData),
                    invoiceContentCode: vt('invoiceContentCode', InvoiceData),
                    invoiceCode: vt('invoiceCode', InvoiceData),
                    invoiceNo: vt('invoiceNumber', InvoiceData),
                    totalPrice: vt('taxAndPriceLow', InvoiceData),
                    taxAmount: vt('totalTax', InvoiceData, '0'),
                    invoiceDate: vt('makeTime', InvoiceData),
                    annulName: vt('salerName', InvoiceData),
                    checkCode: vt('checkCode', InvoiceData),
                    taxPayerId: vt('buyerTaxRegisNum', InvoiceData),
                    acquiringName: vt('buyerName', InvoiceData),
                    filePath: vt('fileName', ItemData)
                };
                ReqParams['BusinessParams'] = table2json(BusinessParams);
                ReqParams['ReqFuncName'] = 'invoke_trancode_noloading';
                ReqParams['BusinessCall'] = lua_upload.saveCheckSuccessInvoice;
                lua_jjbx.common_req(ReqParams);
            } else {
                table.remove(globalTable['UploadInvoiceToAddRes'], 1);
                var ScrollData = vt('UploadInvoiceToAddRes', globalTable);
                if (ScrollData.length > 0) {
                    lua_upload.saveCheckSuccessInvoice('', {});
                }
            }
        }
    } else {
        invoiceSaveFlag = '1';
        var res = json2table(ResParams['responseBody']);
        var UploadInvoiceToAddRes = vt('UploadInvoiceToAddRes', globalTable);
        var fileID = vt('fileID', UploadInvoiceToAddRes[1]);
        var uploadingFile = vt('uploadingFile', globalTable, {});
        for (var [key, value] in pairs(uploadingFile)) {
            if (parseFloat(fileID) === parseFloat(value['fileID'])) {
                if (res['errorNo'] === '000000') {
                    uploadingFile[key]['uploadState'] = '已保存';
                } else {
                    uploadingFile[key]['uploadState'] = '保存失败';
                }
            }
        }
        var e = document.getElementsByName('uploadingFileList');
        if (e.length > 0) {
            init_uploading_file_info();
        }
        e = document.getElementsByName('list_widget');
        if (e.length > 0) {
        }
        if (res['errorNo'] === '000000') {
            if (vt('saveInvoiceSuccessList', globalTable) === '') {
                globalTable['saveInvoiceSuccessList'] = {};
            }
            table.insert(globalTable['saveInvoiceSuccessList'], UploadInvoiceToAddRes[1]);
        } else {
            if (vt('saveInvoiceFailedList', globalTable) === '') {
                globalTable['saveInvoiceFailedList'] = {};
            }
            UploadInvoiceToAddRes[1]['saveErrorNo'] = res['errorNo'];
            UploadInvoiceToAddRes[1]['saveErrorMsg'] = res['errorMsg'];
            table.insert(globalTable['saveInvoiceFailedList'], UploadInvoiceToAddRes[1]);
        }
        table.remove(globalTable['UploadInvoiceToAddRes'], 1);
        var ScrollData = vt('UploadInvoiceToAddRes', globalTable);
        if (ScrollData.length > 0) {
            lua_upload.saveCheckSuccessInvoice('', {});
        }
    }
};
module.exports = { lua_upload: lua_upload };