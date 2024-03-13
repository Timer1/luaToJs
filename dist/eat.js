const lua_system = require('./system');
const lua_page_list = require('./page_list');
const lua_format = require('./format');
const lua_ota = require('./ota');
const lua_jjbx = require('./jjbx');
lua_eat = {};
EatArgSet = { PRuleScrollIndex: '' };
EARLQArg = {
    qryFlag: '',
    billNo: '',
    aplStatus: '',
    aplStatusName: '',
    aplReviewStatusOptionIndex: '',
    aplStatusOptionIndex: '',
    aplDateStart: '',
    aplDateEnd: '',
    aplDateName: '',
    aplDateOptionIndex: '',
    minAplMoney: '',
    maxAplMoney: '',
    AplMoneyName: '',
    AplMoneyOptionIndex: ''
};
EOLQArg = {
    orderType: '',
    orderTypeName: '',
    orderTypeOptionIndex: '',
    startTime: '',
    endTime: '',
    TimeSectionName: '',
    TimeSectionOptionIndex: '',
    dinnerType: '',
    dinnerTypeName: '',
    dinnerTypeOptionIndex: '',
    timeOrder: '',
    timeOrderName: '',
    timeOrderOptionIndex: ''
};
lua_eat.page_router = function (PageName, RouterArg) {
    var PageUrl = '';
    if (PageName === 'index') {
        PageUrl = 'jjbx_eat_service/index.xhtml';
        EatArgSet.PRuleScrollIndex = '';
    } else if (PageName === 'apply') {
        globalTable['pageType'] = 'newBill';
        PageUrl = 'jjbx_eat_service/apply.xhtml';
    } else if (PageName === 'apply_edit') {
        PageUrl = 'jjbx_eat_service/apply_edit.xhtml';
    } else if (PageName === 'apply_detail') {
        PageUrl = 'jjbx_eat_service/apply_detail.xhtml';
    } else if (PageName === 'apply_result') {
        PageUrl = 'jjbx_eat_service/apply_result.xhtml';
    } else if (PageName === 'apply_record_list') {
        var EatServiceBusinessApplyListInstall = lua_system.check_app_func('EatServiceBusinessApplyList');
        if (EatServiceBusinessApplyListInstall === 'true') {
            PageUrl = 'jjbx_eat_service/apply_record_list.xhtml';
            lua_page_list.init_qry_arg('eat_apply_record_list');
            lua_format.reset_table(EARLQArg);
        } else {
            close_loading();
            var upverArg = {
                updateType: 'OPTION',
                updateMsg: '申请单服务已经升级\uFF0C请更新后使用\u3002'
            };
            lua_ota.show_upvsr_view(upverArg);
            return;
        }
    } else if (PageName === 'apply_invalid_record_list') {
        var EatServiceBusinessApplyListInstall = lua_system.check_app_func('EatServiceBusinessApplyList');
        if (EatServiceBusinessApplyListInstall === 'true') {
            PageUrl = 'jjbx_eat_service/apply_invalid_record_list.xhtml';
            lua_page_list.init_qry_arg('eat_apply_invalid_record_list');
            lua_format.reset_table(EARLQArg);
        } else {
            close_loading();
            var upverArg = {
                updateType: 'OPTION',
                updateMsg: '申请单服务已经升级\uFF0C请更新后使用\u3002'
            };
            lua_ota.show_upvsr_view(upverArg);
            return;
        }
    } else if (PageName === 'apply_record_use_list') {
        var EatServiceBusinessUseListInstall = lua_system.check_app_func('EatServiceBusinessUseList');
        if (EatServiceBusinessUseListInstall === 'true') {
            PageUrl = 'jjbx_eat_service/apply_record_use_list.xhtml';
            lua_page_list.init_qry_arg('eat_apply_record_use_list');
            lua_format.reset_table(EARLQArg);
        } else {
            close_loading();
            var upverArg = {
                updateType: 'OPTION',
                updateMsg: '申请单服务已经升级\uFF0C请更新后使用\u3002'
            };
            lua_ota.show_upvsr_view(upverArg);
            return;
        }
    } else if (PageName === 'order_list' || PageName === 'budget_order_list') {
        var EatServiceOrderListInstall = lua_system.check_app_func('EatServiceOrderList');
        if (EatServiceOrderListInstall === 'true') {
            if (PageName === 'order_list') {
                PageUrl = 'jjbx_eat_service/order_list.xhtml';
                lua_page_list.init_qry_arg('eat_order_list');
                lua_format.reset_table(EOLQArg);
            } else if (PageName === 'budget_order_list') {
                PageUrl = 'jjbx_eat_service/budget_order_list.xhtml';
                lua_page_list.init_qry_arg('budget_eat_order_list');
                lua_format.reset_table(EOLQArg);
            }
        } else {
            close_loading();
            var upverArg = {
                updateType: 'OPTION',
                updateMsg: '订单服务已经升级\uFF0C请更新后使用\u3002'
            };
            lua_ota.show_upvsr_view(upverArg);
            return;
        }
    } else if (PageName === 'elm_order_list') {
        globalTable['getElmOrderList'] = {
            TranCode: '',
            orderType: '0',
            timeOrder: '2',
            timeOrderbm: '1',
            startTime: '',
            startTimebm: '1',
            endTime: nowDate,
            dinnerType: '0',
            dinnerTypebm: '1',
            pagenum: '1',
            pagesize: '10',
            isClear: 'true',
            isLastPage: 'false'
        };
        globalTable['pageIndex'] = '1';
        PageUrl = 'jjbx_eat_service/xhtml/eatServer_myOrder.xhtml';
    } else if (PageName === 'choose_receiver_addr') {
        PageUrl = 'jjbx_eat_service/choose_receiver_addr.xhtml';
    } else if (PageName === 'receiver_addr') {
        PageUrl = 'jjbx_eat_service/receiver_addr.xhtml';
    } else if (PageName === 'complaint_shop') {
        PageUrl = 'jjbx_eat_service/complaint_shop.xhtml';
    } else {
        alertToast1('页面异常');
    }
    if (PageUrl != '') {
        var RouterArg = formatNull(RouterArg, {});
        RouterArg['CloseLoading'] = vt('CloseLoading', RouterArg, 'false');
        invoke_page(PageUrl, page_callback, RouterArg);
    }
};
lua_eat.qry_apply_list = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['ReqAddr'] = 'mtController/queryMtMealBillList';
        ReqParams.BusinessCall = lua_eat.qry_apply_list;
        var ResCallFunc = vt('ResCallFunc', ReqParams);
        if (ResCallFunc === '') {
            debug_alert('查询用餐申请列表回调未指定');
        } else {
            lua_jjbx.common_req(ReqParams);
        }
    } else {
        var res = json2table(ResParams['responseBody']);
        var ListData = vt('billList', res);
        var ListDataCounts = ListData.length;
        var UpdateArg = {
            UpdateArgName: 'LoadedCounts',
            UpdateArgValue: ListDataCounts
        };
        lua_page_list.update_qry_arg(UpdateArg);
        var ResCallFunc = vt('ResCallFunc', ResParams);
        lua_system.do_function(ResCallFunc, res);
    }
};
lua_eat.gen_apply_list_item = function (ItemData) {
    var ItemData = formatNull(ItemData);
    var CardItemType = vt('CardItemType', ItemData, 'Apply');
    var layOutArg = {
        CardStyle: '',
        CardTitleText: '单据号: ' + vt('billNo', ItemData),
        CardUseText1: '',
        CardUseText1Class: '',
        CardUseText2: '',
        CardUseText2Class: '',
        AmountText: vt('aplMoney', ItemData),
        AmountTipText: '申请金额(元)',
        CardTipText1: '',
        CardTipText2: '有效期至' + vt('availEndDate', ItemData),
        CardTipText3: vt('cause', ItemData),
        CardTipText4: '',
        CardTipText4ClickArg: 'show_use_msg',
        CardTipText4ArrowIcon: '',
        CardTipText5: '',
        CardTipText5ClickArg: '',
        CardTipText5Color: '',
        CardStatusIcon: ''
    };
    var availFlag = vt('availFlag', ItemData);
    if (availFlag === '0') {
        layOutArg['CardUseText1'] = '可使用';
        layOutArg['CardUseText1Class'] = 'Orange';
    }
    var billStatus = vt('billStatus', ItemData);
    var billStatusIconKey = '';
    if (CardItemType === 'Apply') {
        layOutArg['CardStyle'] = '1';
        if (billStatus === '0') {
            billStatusIconKey = 'dtj';
        } else if (billStatus === '1') {
            billStatusIconKey = 'ytj';
        } else if (billStatus === '2') {
            billStatusIconKey = 'spz';
        } else if (billStatus === '3') {
            billStatusIconKey = 'sptg';
        }
    } else if (CardItemType === 'InvalidApply') {
        layOutArg['CardStyle'] = '2';
        layOutArg['CardUseText1'] = '';
        layOutArg['CardUseText2'] = '';
        var reviewStatus = vt('reviewStatus', ItemData);
        if (reviewStatus != '') {
            if (reviewStatus === '0') {
                billStatusIconKey = 'dbl';
            } else if (reviewStatus === '1') {
                billStatusIconKey = 'bltj';
            } else if (reviewStatus === '2') {
                billStatusIconKey = 'fhtg';
            } else if (reviewStatus === '3') {
                billStatusIconKey = 'fhbh';
            }
        } else {
            if (billStatus === '0') {
                billStatusIconKey = 'ywj';
            } else if (billStatus === '1') {
                billStatusIconKey = 'ygq';
            } else if (billStatus === '2') {
                billStatusIconKey = 'spsb';
            } else if (billStatus === '3') {
                billStatusIconKey = 'ych';
            }
        }
    }
    layOutArg['CardStatusIcon'] = status_icon(billStatusIconKey);
    if (CardItemType === 'Apply') {
        var timeInfoList = vt('timeInfoList', ItemData);
        var timeInfoCounts = timeInfoList.length;
        if (timeInfoCounts === 0) {
            layOutArg['CardTipText4'] = '使用时间不限制';
        } else if (timeInfoCounts === 1) {
            layOutArg['CardTipText4'] = vt('timeString', timeInfoList[1]);
        } else {
            layOutArg['CardTipText4'] = '使用说明';
            layOutArg['CardTipText4ArrowIcon'] = 'arrow_mine.png';
        }
    }
    var mealType = vt('mealType', ItemData);
    if (mealType === '0') {
        mealType = '外卖';
    } else if (mealType === '1') {
        mealType = '到店';
    } else if (mealType === '2') {
        mealType = '到店\u3001外卖通用';
    } else {
        mealType = '-';
    }
    layOutArg['CardTipText1'] = mealType;
    if (CardItemType === 'Apply') {
        var sharePkUser = vt('sharePkUser', ItemData);
        var shareName = vt('shareName', ItemData);
        var shareFlag = vt('shareFlag', ItemData);
        if (shareFlag === '0' && availFlag === '0') {
            if (shareName != '' && sharePkUser != '') {
                layOutArg['CardTipText5'] = '已共享给\uFF1A' + (cutStr(shareName, 4) + '\u3000取消共享');
                layOutArg['CardTipText5Color'] = '#427EE4';
            } else {
                layOutArg['CardTipText5'] = '共享';
            }
            layOutArg['CardTipText5ClickArg'] = 'share_ctrl';
            layOutArg['CardTipText5Color'] = '#427EE4';
        }
    }
    return layOutArg;
};
lua_eat.qry_order_list = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        var ReqAddr = vt('ReqAddr', ReqParams, 'mtController/queryMtOrderList');
        ReqParams['ReqAddr'] = ReqAddr;
        ReqParams.BusinessCall = lua_eat.qry_order_list;
        var ResCallFunc = vt('ResCallFunc', ReqParams);
        if (ResCallFunc === '') {
            debug_alert('查询用餐订单列表回调未指定');
        } else {
            lua_jjbx.common_req(ReqParams);
        }
    } else {
        var res = json2table(ResParams['responseBody']);
        var ListData = vt('mtOrderList', res);
        var ListDataCounts = ListData.length;
        var UpdateArg = {
            UpdateArgName: 'LoadedCounts',
            UpdateArgValue: ListDataCounts
        };
        lua_page_list.update_qry_arg(UpdateArg);
        var ResCallFunc = vt('ResCallFunc', ResParams);
        lua_system.do_function(ResCallFunc, res);
    }
};
lua_eat.mt_h5_login = function (Arg) {
    var MTH5LoginBusinessParams = vt('MTH5LoginBusinessParams', Arg);
    var ReqParams = {
        ReqUrlExplain: '获取用餐登陆H5地址\uFF08美团\uFF09',
        BusinessParams: table2json(MTH5LoginBusinessParams)
    };
    lua_eat.h5_open_ctrl('', ReqParams);
};
lua_eat.h5_open_ctrl = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['ReqAddr'] = 'mtController/fetchMtLoginUrl';
        ReqParams.BusinessCall = lua_eat.h5_open_ctrl;
        ReqParams.ArgStr = ReqParams.BusinessParams;
        lua_jjbx.common_req(ReqParams);
    } else {
        var res = json2table(ResParams['responseBody']);
        var ResCallFunc = vt('ResCallFunc', ResParams);
        if (ResCallFunc != '') {
            lua_system.do_function(ResCallFunc, res);
        } else {
            var errorNo = vt('errorNo', res);
            var errorMsg = vt('errorMsg', res);
            if (errorNo != '000000') {
                if (errorMsg === '') {
                    alert('获取用餐页面失败');
                } else {
                    alert(errorMsg);
                }
            } else {
                var ReqArg = json2table(vt('ArgStr', ResParams));
                var tipMsg = vt('tipMsg', res);
                var AlertWebviewArg = {
                    title: '美团',
                    visit_url: vt('url', res),
                    back_type: 'BACK',
                    close_call_func: 'eat_h5_close_call',
                    listen_url: 'http://app_h5_callback_url',
                    listen_call: 'lua_system.webview_h5_callback',
                    AddUserAgent: '/CZBANK/JJBXAPP'
                };
                var EncodeTable = {
                    AlertWebviewArg: AlertWebviewArg,
                    BusinessCtrlArg: {
                        entrance: vt('entrance', ReqArg),
                        promptFlag: vt('promptFlag', res),
                        promptInf: vt('promptInf', res)
                    }
                };
                var EncodeArg = lua_format.table_arg_pack(EncodeTable);
                if (tipMsg != '') {
                    alert_confirm('', tipMsg, '', '确定', 'alert_confirm_call', 'CallFun=lua_eat.open_mt_page&CallArg=' + EncodeArg);
                } else {
                    lua_eat.open_mt_page(EncodeArg);
                }
            }
        }
    }
};
lua_eat.open_mt_page = function (EncodeArg) {
    var DecodeArg = lua_format.table_arg_unpack(EncodeArg);
    var AlertWebviewArg = vt('AlertWebviewArg', DecodeArg);
    var BusinessCtrlArg = vt('BusinessCtrlArg', DecodeArg);
    var promptFlag = vt('promptFlag', BusinessCtrlArg);
    var promptInf = vt('promptInf', BusinessCtrlArg, '未获取到提示信息');
    if (promptFlag === '0') {
        alertTip('', promptInf, '不再提示', '', '知道了', 'lua_eat.open_mt_page_tip_call', EncodeArg);
    } else {
        close_loading();
        lua_system.alert_webview(AlertWebviewArg);
    }
};
lua_eat.open_mt_page_tip_call = function (sureFlag, checkFlag, EncodeArg) {
    var DecodeArg = lua_format.table_arg_unpack(EncodeArg);
    var AlertWebviewArg = vt('AlertWebviewArg', DecodeArg);
    var BusinessCtrlArg = vt('BusinessCtrlArg', DecodeArg);
    var entrance = vt('entrance', BusinessCtrlArg);
    var upFlag = '';
    if (entrance === 'A' || entrance === 'B') {
        upFlag = '5';
    } else {
        upFlag = '6';
    }
    if (upFlag != '' && parseFloat(checkFlag) === 1) {
        var BusinessParams = {
            flag: upFlag,
            value: vt('promptInf', BusinessCtrlArg)
        };
        var ReqParams = {
            ReqUrlExplain: '更新用餐不再提示状态',
            BusinessParams: table2json(BusinessParams)
        };
        lua_eat.update_tip_status('', ReqParams);
    }
    close_loading();
    lua_system.alert_webview(AlertWebviewArg);
};
lua_eat.order_status_info = function (OrderData) {
    var payStatus = vt('payStatus', OrderData);
    var logisticsStatus = vt('logisticsStatus', OrderData);
    var orderStatus = vt('orderStatus', OrderData);
    var orderType = vt('orderType', OrderData);
    var OrderStatusName = '订单状态未知';
    if (orderType === '4') {
        if (orderStatus === '1') {
            if (payStatus === '10') {
                OrderStatusName = '未支付';
            }
        } else if (orderStatus === '2') {
            OrderStatusName = '等待商家接单';
        } else if (orderStatus === '4') {
            if (logisticsStatus === '20') {
                OrderStatusName = '已取餐';
            } else if (logisticsStatus === '40') {
                OrderStatusName = '已送达';
            } else {
                OrderStatusName = '已接单';
            }
        } else if (orderStatus === '8') {
            OrderStatusName = '已完成';
        } else if (orderStatus === '9') {
            OrderStatusName = '已取消';
        }
    } else {
        if (payStatus === '10') {
            OrderStatusName = '未支付';
        } else if (payStatus === '20') {
            OrderStatusName = '已支付';
        } else if (payStatus === '31') {
            OrderStatusName = '部分退款';
        } else if (payStatus === '32') {
            OrderStatusName = '全额退款';
        }
    }
    return OrderStatusName;
};
lua_eat.order_detail = function (OrderData) {
    var djType = vt('djType', OrderData);
    var orderNo = vt('orderNo', OrderData);
    var phone = vt('phone', OrderData);
    var budgetKey = vt('budgetkey', OrderData);
    if (orderNo === '' || phone === '') {
        alert('订单信息不完整');
    } else {
        var BusinessParams = {
            loginFlag: '1',
            sqtOrderId: orderNo,
            staffNo: phone,
            budgetKey: budgetKey
        };
        var ReqParams = {
            ReqUrlExplain: '获取用餐订单详情H5地址\uFF08美团\uFF09',
            BusinessParams: table2json(BusinessParams)
        };
        lua_eat.h5_open_ctrl('', ReqParams);
    }
};
lua_eat.update_tip_status = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['ReqAddr'] = 'mtController/saveMtPromptInfo';
        ReqParams.BusinessCall = lua_eat.update_tip_status;
        lua_jjbx.common_req(ReqParams);
    } else {
        close_loading();
        var res = json2table(ResParams['responseBody']);
        var errorNo = vt('errorNo', res);
        var errorMsg = vt('errorMsg', res);
        if (errorNo != '000000') {
            alert(errorMsg);
        }
    }
};
lua_eat.show_use_msg = function (ItemEncodeData) {
    var ItemDecodeData = lua_format.table_arg_unpack(ItemEncodeData);
    var ShowUseMsg = '';
    var timeInfoList = vt('UseTimeInfo', ItemDecodeData);
    var timeInfoCounts = timeInfoList.length;
    if (timeInfoCounts > 1) {
        for (let i = 1; timeInfoCounts; i++) {
            ShowUseMsg = ShowUseMsg + ('\\n' + vt('timeString', timeInfoList[i]));
        }
    } else {
        ShowUseMsg = '';
    }
    if (ShowUseMsg != '') {
        var AlertArg = {
            titleMsg: '使用说明',
            alertMsg: lua_format.url_encode(ShowUseMsg),
            msgEncodeType: 'url_encode'
        };
        lua_system.app_alert(AlertArg);
    } else {
        if (timeInfoCounts > 1) {
            alert('没有使用说明信息');
        } else {
            debug_alert('没有使用说明信息');
        }
    }
};
lua_eat.qry_ctrl_addr = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams);
        ReqParams['ReqAddr'] = 'mtController/qryMtAdress';
        ReqParams.BusinessCall = lua_eat.qry_ctrl_addr;
        var ResCallFunc = vt('ResCallFunc', ReqParams);
        if (ResCallFunc === '') {
            debug_alert('查询管控地址回调未指定');
        } else {
            lua_jjbx.common_req(ReqParams);
        }
    } else {
        var res = json2table(ResParams['responseBody']);
        var ResCallFunc = vt('ResCallFunc', ResParams);
        var ArgStr = vt('ArgStr', ResParams);
        var errorNo = vt('errorNo', res);
        var errorMsg = vt('errorMsg', res);
        if (errorNo != '000000') {
            alert(errorMsg);
        } else {
            res['ResCallArgStr'] = ArgStr;
            lua_system.do_function(ResCallFunc, res);
        }
    }
};
lua_eat.order_fee_text_deal = function (OrderData) {
    var OrderData = formatNull(OrderData);
    var AmountText = '';
    var AmountTipText = '';
    if (OrderData != '') {
        var wmTotal = parseFloat(vt('wmTotal', OrderData, '0'));
        var ddTotal = parseFloat(vt('ddTotal', OrderData, '0'));
        var serviceFeeByPay = parseFloat(vt('serviceFeeByPay', OrderData, '0'));
        var serviceRefundFee = parseFloat(vt('serviceFee', OrderData, '0'));
        var entPayFee = parseFloat(vt('entPayFee', OrderData, '0'));
        var empPayFee = parseFloat(vt('empPayFee', OrderData, '0'));
        var entRefundFee = parseFloat(vt('entRefundFee', OrderData, '0'));
        var empRefundFee = parseFloat(vt('empRefundFee', OrderData, '0'));
        var withorderfeeFlag = vt('withorderfeeFlag', OrderData, '0');
        var orderType = vt('orderType', OrderData);
        if (orderType === '4') {
            AmountText = wmTotal;
        } else {
            AmountText = ddTotal;
        }
        var payStatus = vt('payStatus', OrderData);
        if (withorderfeeFlag === '0') {
            AmountText = formatMoney(AmountText);
            if (payStatus === '31' || payStatus === '32') {
                if (formatMoney(empRefundFee) === '0.00') {
                    AmountTipText = '含企业退款:' + (formatMoney(entRefundFee) + '元');
                } else {
                    AmountTipText = '含企业退款:' + (formatMoney(entRefundFee) + ('元 个人退款:' + (formatMoney(empRefundFee) + '元')));
                }
            } else if (payStatus === '10') {
                AmountTipText = '';
            } else {
                if (formatMoney(empPayFee) === '0.00') {
                    AmountTipText = '含企业支付' + (formatMoney(entPayFee) + '元');
                } else {
                    AmountTipText = '含企业支付:' + (formatMoney(entPayFee) + ('元 个人支付:' + (formatMoney(empPayFee) + '元')));
                }
            }
        } else {
            AmountText = formatMoney(AmountText + serviceFeeByPay);
            if (payStatus === '31' || payStatus === '32') {
                if (formatMoney(empRefundFee) === '0.00') {
                    AmountTipText = '含服务费退款:' + (formatMoney(serviceRefundFee) + ('元 企业退款:' + (formatMoney(entRefundFee) + '元')));
                } else {
                    AmountTipText = '含服务费退款:' + (formatMoney(serviceRefundFee) + ('元 企业退款:' + (formatMoney(entRefundFee) + ('元 个人退款:' + (formatMoney(empRefundFee) + '元')))));
                }
            } else if (payStatus === '10') {
                AmountTipText = '';
            } else {
                AmountTipText = '含服务费' + (formatMoney(serviceFeeByPay) + ('元 企业支付' + (formatMoney(entPayFee) + ('元 个人支付' + (formatMoney(empPayFee) + '元')))));
            }
        }
    }
    var Res = {
        AmountText: AmountText,
        AmountTipText: AmountTipText
    };
    return Res;
};
lua_eat.scan_to_pay = function (Arg) {
    var Arg = formatNull(Arg);
    var OpenArg = {
        ScanCallFunc: 'lua_eat.scan_call',
        ScanCallFuncSetArg: 'eat to pay'
    };
    lua_system.open_scan_by_camera(OpenArg);
};
lua_eat.scan_call = function (ScanArg, CallArg) {
    var ScanArg = formatNull(ScanArg);
    var CallArg = formatNull(CallArg);
    var ScanRes = lua_format.base64_decode(ScanArg);
    if (ScanRes != '') {
        if (string.find(ScanRes, 'http://') === 1 || string.find(ScanRes, 'https://') === 1) {
            var EncodeTable = {
                AlertWebviewArg: {
                    title: '用餐服务',
                    visit_url: ScanRes,
                    back_type: 'BACK',
                    close_call_func: 'eat_h5_close_call'
                }
            };
            var EncodeArg = lua_format.table_arg_pack(EncodeTable);
            lua_eat.open_mt_page(EncodeArg);
        } else {
            alert('非美团二维码');
        }
    } else {
        alert('未获取到扫描结果');
    }
};
module.exports = { lua_eat: lua_eat };