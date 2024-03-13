const lua_jjbx = require('./jjbx');
const lua_format = require('./format');
const lua_ask = require('./ask');
const lua_page = require('./page');
lua_message = {};
lua_message.qry_mess_info_ByPk = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        ReqParams['ReqAddr'] = 'pubMessageService/qryMessInfoByPk';
        ReqParams['ReqUrlExplain'] = '查询消息详情';
        ReqParams['BusinessCall'] = lua_message.qry_mess_info_ByPk;
        var qryMessInfoByPk_params = { pkNotimsg: ReqParams['pkNotimsg'] };
        ReqParams['BusinessParams'] = table2json(qryMessInfoByPk_params);
        lua_jjbx.common_req(ReqParams);
    } else {
        close_loading();
        var responseBody = json2table(vt('responseBody', ResParams));
        if (responseBody['errorNo'] === '000000') {
            var pkNotimsg = responseBody['pkNotimsg'];
            var msgConten = formatSpecialChar(responseBody['content']);
            var messageSubclassEn = formatSpecialChar(responseBody['messageSubclassEn']);
            if (messageSubclassEn === 'billEvaluationInfo') {
                msgConten = formatNull(responseBody['headline']);
            }
            var businessModule = formatNull(responseBody['businessModule']);
            var msgDate = formatNull(responseBody['ts']);
            var pkMsgPublishList = formatNull(responseBody['pkMsgPublishList']);
            var replyState = formatNull(responseBody['replyState']);
            var base64Msgid = lua_format.base64_encode(pkMsgPublishList);
            var popupFlag = formatNull(responseBody['popupFlag']);
            var readFlag = 'false';
            var res3 = formatNull(responseBody['res3']);
            var billNo = formatNull(responseBody['billNo']);
            var billType = '';
            if (billNo != '') {
                billType = bill_no2type(billNo);
            }
            var detailContents = 'pkNotimsg=' + (pkNotimsg + ('&base64Msgid=' + (base64Msgid + ('&messageSubclassEn=' + (messageSubclassEn + ('&msgDate=' + (msgDate + ('&pkMsgPublishList=' + (pkMsgPublishList + ('&popupFlag=' + (popupFlag + ('&businessModule=' + (businessModule + ('&content=' + (msgConten + ('&billNo=' + (billNo + ('&res3=' + (res3 + ('&billType=' + (billType + ('&replyState=' + (replyState + '&readFlag=false')))))))))))))))))))))));
            lua_message.qryMsgDetail(detailContents, '1');
        } else {
            alert(responseBody['errorMsg']);
        }
    }
};
lua_message.qryMsgDetail = function (detailContents, index) {
    var detailContents = formatNull(detailContents);
    if (detailContents != '') {
        var detail = string_to_table(detailContents);
        var billNo = vt('billNo', detail);
        var billType = vt('billType', detail);
        var base64Msgid = vt('base64Msgid', detail);
        var messageSubclassEn = vt('messageSubclassEn', detail);
        var content = vt('content', detail);
        var msgDate = vt('msgDate', detail);
        var pkNotimsg = vt('pkNotimsg', detail);
        var pkMsgPublishList = vt('pkMsgPublishList', detail);
        var businessModule = vt('businessModule', detail);
        var popupFlag = vt('popupFlag', detail);
        var res3 = vt('res3', detail);
        var replyState = vt('replyState', detail);
        globalTable['DelpkNotimsg'] = pkNotimsg;
        globalTable['DelpkMsgPublishList'] = pkMsgPublishList;
        globalTable['popupFlag'] = popupFlag;
        globalTable['msgCenterIndex'] = index;
        globalTable['msgType'] = msgType;
        var readFlag = vt('readFlag', detail);
        var DefaultAlertArg = {
            content: content,
            readFlag: readFlag
        };
        if (globalTable['msgType'] === '1') {
            globalTable['webview_page_title'] = '消息中心';
        } else if (globalTable['msgType'] === '2') {
            globalTable['webview_page_title'] = '企业公告';
        } else if (globalTable['msgType'] === '3') {
            globalTable['webview_page_title'] = '产品消息';
        } else {
            globalTable['webview_page_title'] = '消息详情';
        }
        globalTable['msgCenterTypeIndex'] = conditionIndex;
        if (messageSubclassEn === 'businesspublish' || messageSubclassEn === 'internalpublish') {
            var qryArg = {
                PkMsgPublishList: base64Msgid,
                MsgType: msgType,
                PopupFlag: popupFlag
            };
            lua_jjbx.qry_msg_h5_link(qryArg);
        } else if (messageSubclassEn === 'salarypublish') {
            if (readFlag != 'true') {
                lua_jjbx.updMarkunreadFlag();
            }
            globalTable['salaryMonth'] = string.sub(msgDate, 1, 7);
            invoke_page('jjbx_salary_service/xhtml/monthSalary.xhtml', page_callback, null);
        } else if (messageSubclassEn === 'billEvaluationInfo') {
            var qryArg = {
                PkMsgPublishList: base64Msgid,
                MsgType: msgType,
                PopupFlag: popupFlag
            };
            lua_jjbx.qry_msg_h5_link(qryArg);
        } else if (messageSubclassEn === 'salaryrelease') {
            if (readFlag != 'true') {
                lua_jjbx.updMarkunreadFlag();
            }
            alert_confirm('薪酬管理', content, '返回', '查看', 'alert_confirm_call', 'CallFun=lua_menu.to_other_salary_info_page');
        } else if (messageSubclassEn === 'socialsecurityradixpublish') {
            if (readFlag != 'true') {
                lua_jjbx.updMarkunreadFlag();
            }
            alert_confirm('社保管理', content, '返回', '查看', 'alert_confirm_call', 'CallFun=lua_menu.to_social_detail_page');
        } else if (messageSubclassEn === 'budgetTaskAdjust' || messageSubclassEn === 'budgetTaskPublish') {
            if (string.find(res3, ',1')) {
                if (readFlag != 'true') {
                    lua_jjbx.updMarkunreadFlag();
                }
                alert_confirm('预算管理', content, '返回', '查看', 'alert_confirm_call', 'CallFun=lua_menu.to_budget_info_page');
            } else {
                lua_jjbx.msg_default_alert(DefaultAlertArg);
            }
        } else if (messageSubclassEn === 'ImproveAssertCardInformation' || messageSubclassEn === 'CgPaymentAlertBusi' || messageSubclassEn === 'CgPaymentAlertWelfare') {
            if (readFlag != 'true') {
                lua_jjbx.updMarkunreadFlag();
            }
            var CallArg = {
                orderId: res3,
                messageSubclassEn: messageSubclassEn
            };
            var CallArgStr = lua_format.base64_encode(table2json(CallArg));
            var TipHeadMsg = '查看订单';
            if (messageSubclassEn === 'CgPaymentAlertBusi') {
                TipHeadMsg = '查看单据';
            }
            alert_confirm('消息内容', content, '返回', TipHeadMsg, 'alert_confirm_call', 'CallFun=lua_purchase.purchase_msg_call&CallArg=' + CallArgStr);
        } else if (messageSubclassEn === 'questionFeedbackNotification' || messageSubclassEn === 'questionReplyNotification') {
            if (readFlag != 'true') {
                lua_jjbx.updMarkunreadFlag();
            }
            var pkQuestion = '';
            if (res3 != '') {
                pkQuestion = res3;
            } else {
                pkQuestion = pkMsgPublishList;
            }
            lua_ask.to_user_ask_page('feedback_reply', {
                pkQuestion: pkQuestion,
                questionType: messageSubclassEn
            });
        } else if (messageSubclassEn === 'functionGuide' || messageSubclassEn === 'frequentQuestion') {
            if (readFlag != 'true') {
                lua_jjbx.updMarkunreadFlag();
            }
            lua_ask.ask_msg_jump({ messageSubclassEn: messageSubclassEn });
        } else if (messageSubclassEn === 'pushInventoryTransferMsg') {
            if (readFlag != 'true') {
                lua_jjbx.updMarkunreadFlag();
            }
            billArchive_receiveInventoryTransfer_CallArg = {
                transferInfoSource: splitUtils(res3, ',')[1],
                pkNotimsg: pkNotimsg
            };
            if (splitUtils(res3, ',')[2] === '0') {
                alert_confirm('消息内容', content, '拒绝', '确认', 'lua_message.pushInventoryTransferMsg_callback');
            } else if (splitUtils(res3, ',')[2] === '1') {
                alert('该消息已确认');
            } else if (splitUtils(res3, ',')[2] === '2') {
                alert('该移交申请已作废\uFF0C无需再处理');
            } else {
                alert_confirm('消息内容', content, '', '返回', '', '');
            }
        } else if (messageSubclassEn === 'bankTransactionAuthorization') {
            if (readFlag != 'true') {
                lua_jjbx.updMarkunreadFlag();
            }
            globalTable['ifAlertHint'] = 'true';
            invoke_page('jjbx_msg_center/xhtml/msg_account_checking.xhtml', page_callback, {
                CloseLoading: 'false',
                ClickArg: ClickArg
            });
        } else if (messageSubclassEn === 'gydkpays' || messageSubclassEn === 'salaryPensionInfo') {
            if (readFlag != 'true') {
                lua_jjbx.updMarkunreadFlag();
            }
            if (res3 === '0') {
                lua_message.query_pension_info('', {});
            } else if (res3 === '1') {
                var nowTime = os.time();
                var nowDate = os.date('%Y-%m-%d', nowTime);
                globalTable['qryPayYear'] = splitUtils(nowDate, '-')[1];
                globalTable['selfInfoSure'] = 'false';
                invoke_page('jjbx_salary_service/xhtml/ylj_qysb_001.xhtml', page_callback, null);
            }
        } else if (messageSubclassEn === 'SendExchangeConfirmation' || messageSubclassEn === 'SendTYKKExchangeConfirmation') {
            if (readFlag != 'true') {
                lua_jjbx.updMarkunreadFlag();
            }
            lua_message.turn_to_verify('', { djh: res3 });
        } else if (messageSubclassEn === 'exp' && string.sub(res3, 0, 3) === 'SSL') {
            if (readFlag != 'true') {
                lua_jjbx.updMarkunreadFlag();
            }
            lua_message.checkBillUser('', {
                djh: res3,
                content: content
            });
        } else if (messageSubclassEn === 'tripReminder') {
            if (readFlag != 'true') {
                lua_jjbx.updMarkunreadFlag();
            }
            alert_confirm('消息内容', content, '返回', '商旅首页', 'lua_message.to_travel_index', '');
        } else if (messageSubclassEn === 'registrationMessage') {
            if (readFlag != 'true') {
                lua_jjbx.updMarkunreadFlag();
            }
            invoke_page('jjbx_process_bill/xhtml/process_bill_jjdj_detail.xhtml', page_callback, { msgID: res3 });
        } else {
            if (replyState === '0' || replyState === '1' || replyState === '2') {
                invoke_page('jjbx_msg_center/xhtml/msg_reply.xhtml', page_callback, null);
            } else if (businessModule === '120203') {
                invoke_trancode_noloading('jjbx_index', 'query_msg', {
                    TranCode: 'CheckJdMessage',
                    msgId: pkNotimsg
                }, lua_message.checkJdMessageCallBack, {});
            } else if (billNo != '' && billType != '' && res3 != null) {
                if (readFlag != 'true') {
                    lua_jjbx.updMarkunreadFlag();
                }
                globalTable['billCode'] = billNo;
                globalTable['billTypeCode'] = billType;
                globalTable['res3'] = res3;
                alert_confirm('消息内容', content, '返回', '查看单据', 'lua_message.msg_to_billDetail', '');
            } else if (res3 != '' && messageSubclassEn === 'deductionpulish') {
                globalTable['res3'] = res3;
                alert_confirm('消息内容', content, '返回', '去缴款', 'lua_message.msg_to_billDetail', '');
            } else {
                lua_jjbx.msg_default_alert(DefaultAlertArg);
            }
        }
    } else {
        alert('暂无详情');
    }
};
lua_message.turn_to_verify = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams, {});
        ReqParams['ReqAddr'] = 'billNcVerification/turnToVerify';
        ReqParams['ReqUrlExplain'] = '查看往来确认消息';
        ReqParams['BusinessCall'] = lua_message.turn_to_verify;
        var BusinessParams = { djh: ReqParams['djh'] };
        ReqParams['BusinessParams'] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    } else {
        close_loading();
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            var listData = vt('list', res);
            if (listData.length > 0) {
                var CallBackData = { ItemData: lua_format.table_arg_pack(listData[1]) };
                var status = formatNull(listData[1]['editStatus'], '0');
                invoke_page('jjbx_index/xhtml/jjbx_wlqr_detail.xhtml', page_callback, {
                    CallBackData: CallBackData,
                    status: status
                });
            } else {
                alert('未获取到往来确认详情');
            }
        } else {
            alert(res['errorMsg']);
        }
    }
};
lua_message.query_pension_info = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams, {});
        ReqParams['ReqAddr'] = 'sspSalaryPensionController/queryPensionInfo';
        ReqParams['ReqUrlExplain'] = '查看工资缴纳方案信息';
        ReqParams['BusinessCall'] = lua_message.query_pension_info;
        var nowTime = os.time();
        var nowDate = os.date('%Y-%m-%d', nowTime);
        var nowYear = splitUtils(nowDate, '-')[1];
        var BusinessParams = { qryYear: nowYear };
        ReqParams['BusinessParams'] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    } else {
        close_loading();
        var res = json2table(ResParams['responseBody']);
        if (res['errorNo'] === '000000') {
            var salaryPensionItem = vt('salaryPensionItem', res);
            if (vt('id', salaryPensionItem) != '') {
                invoke_page('jjbx_salary_service/xhtml/ylj_jcfa_004.xhtml', page_callback, { queryPensionInfo: res });
            } else {
                alert('未获取到缴存方案');
            }
        } else {
            alert(res['errorMsg']);
        }
    }
};
lua_message.billArchive_receiveInventoryTransfer_callback = function (params) {
    close_loading();
    refreshMsg();
    var responseBody = json2table(params['responseBody']);
    if (responseBody['errorNo'] === '000000') {
        alert('操作成功');
    } else {
        alert(responseBody['errorMsg']);
    }
};
lua_message.billArchive_receiveInventoryTransfer = function (operationType) {
    var ReqParams = {};
    var BusinessParams = {
        transferInfoSource: vt('transferInfoSource', billArchive_receiveInventoryTransfer_CallArg),
        pkNotimsg: vt('pkNotimsg', billArchive_receiveInventoryTransfer_CallArg),
        operationType: operationType
    };
    ReqParams['ReqAddr'] = 'billArchive/receiveInventoryTransfer';
    ReqParams['ReqUrlExplain'] = '清册消息确认';
    ReqParams['BusinessParams'] = table2json(BusinessParams);
    ReqParams['BusinessCall'] = lua_message.billArchive_receiveInventoryTransfer_callback;
    lua_jjbx.common_req(ReqParams);
};
lua_message.pushInventoryTransferMsg_callback = function (index) {
    if (index === 1) {
        lua_message.billArchive_receiveInventoryTransfer('1');
    } else {
        lua_message.billArchive_receiveInventoryTransfer('0');
    }
};
lua_message.checkJdMessageCallBack = function (params) {
    var jsonData = params['responseBody'];
    var data = json2table(jsonData);
    if (data['errorNo'] === '000000') {
        lua_jjbx.updMarkunreadFlag();
        if (parseFloat(data['page']) === 0) {
            globalTable['jdOrderId'] = formatNull(data['porderId']);
            invoke_trancode('jjbx_service', 'online_shopping', {
                TranCode: 'getOrderInfoByOrderId',
                jdOrderId: globalTable['jdOrderId']
            }, lua_message.getOrderInfoByOrderIdCallBack, {}, all_callback, { CloseLoading: 'false' });
        } else if (parseFloat(data['page']) === 1) {
            globalTable['queryAllOrder_params'] = {
                TranCode: 'getJdOrderFlow',
                pageNum: '1',
                pageSize: '10',
                listIndex: '1',
                screenType: 'welfare',
                welfareIndex: '1',
                statusIndex: '1',
                descIndex: '1',
                orderType: '',
                orderStatus: '0',
                sord: '',
                jdOrderId: data['porderId']
            };
            invoke_page('jjbx_online_shopping/xhtml/onlineShopping_allOrder.xhtml', page_callback, { CloseLoading: 'false' });
        }
    } else {
        alert(data['errorMsg']);
    }
};
lua_message.getOrderInfoByOrderIdCallBack = function (params) {
    var responseBody = json2table(params['responseBody']);
    if (responseBody['errorNo'] === '000000') {
        var orderDetail = responseBody['orderList'][1];
        globalTable['orderDetail'] = orderDetail;
        for (let i = 1; globalTable['orderDetail']['subOrders'].length; i++) {
            globalTable['orderDetail']['subOrders'][i]['name'] = string.gsub(globalTable['orderDetail']['subOrders'][i]['name'], '{', '%{');
            globalTable['orderDetail']['subOrders'][i]['name'] = string.gsub(globalTable['orderDetail']['subOrders'][i]['name'], '}', '%}');
            globalTable['orderDetail']['subOrders'][i]['name'] = string.gsub(globalTable['orderDetail']['subOrders'][i]['name'], '<', '\u300A');
            globalTable['orderDetail']['subOrders'][i]['name'] = string.gsub(globalTable['orderDetail']['subOrders'][i]['name'], '>', '\u300B');
        }
        if (orderDetail['uniqueNo'] === '') {
            invoke_page('jjbx_online_shopping/xhtml/onlineShopping_orderDetail_welfare.xhtml', page_callback, null);
        } else {
            invoke_page('jjbx_online_shopping/xhtml/onlineShopping_orderDetail_official.xhtml', page_callback, null);
        }
    } else {
        alert(responseBody['errorMsg']);
    }
};
lua_message.msg_to_billDetail = function (index) {
    if (index === 1) {
        if (globalTable['res3'] != '') {
            go_to_jkd('', globalTable['res3']);
        } else {
            invoke_trancode_donot_checkRepeat('jjbx_index', 'my_request', {
                TranCode: 'BillHaveProcessInfo',
                billNo: globalTable['billCode'],
                billType: globalTable['billTypeCode']
            }, bill_page_router, {}, all_callback, { CloseLoading: 'false' });
        }
    }
};
lua_message.to_travel_index = function (index) {
    if (index === 1) {
        invoke_page('jjbx_travel_service/xhtml/travel_service_index.xhtml', page_callback, {});
    }
};
qryMsgMarkUnReadCount = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        invoke_trancode_noloading('jjbx_index', 'query_msg', { TranCode: 'qryMsgMarkUnReadCount' }, qryMsgMarkUnReadCount, {}, all_callback, { CloseLoading: 'false' });
    } else {
        var responseBody = json2table(ResParams['responseBody']);
        if (responseBody['errorNo'] === '000000') {
            var unReadCount = parseFloat(responseBody['unReadCount']);
            if (unReadCount > 0) {
                if (unReadCount < 100) {
                    changeProperty('JJBX_titleName', 'value', '消息中心(' + (unReadCount + ')'));
                } else {
                    changeProperty('JJBX_titleName', 'value', '消息中心(99+)');
                }
                page_reload();
                show_ele('head_title_icon_div');
                lua_page.update_top({ updateTarget: 'title_icon' });
            } else {
                changeProperty('JJBX_titleName', 'value', '消息中心');
                hide_ele('head_title_icon_div');
            }
            close_loading();
        } else {
            alert(responseBody['errorMsg']);
        }
    }
};
lua_message.checkBillUser = function (ResParams, ReqParams) {
    if (formatNull(ResParams) === '') {
        var ReqParams = formatNull(ReqParams, {});
        ReqParams['ReqAddr'] = '/bill/common/checkBillUser';
        ReqParams['ReqUrlExplain'] = '查看往来确认消息';
        ReqParams['BusinessCall'] = lua_message.checkBillUser;
        var BusinessParams = { billNo: ReqParams['djh'] };
        globalTable['content'] = ReqParams['content'];
        ReqParams['BusinessParams'] = table2json(BusinessParams);
        lua_jjbx.common_req(ReqParams);
    } else {
        close_loading();
        var res = json2table(ResParams['responseBody']);
        var content = vt('content', globalTable);
        globalTable['content'] = null;
        if (res['errorNo'] === '000000') {
            var bill = vt('bill', res);
            var zdrgh = vt('zdrgh', bill);
            if (vt('workid', globalTable) === zdrgh) {
                var orderID = ryt.getSubstringValue(content, 4, 23);
                invoke_page('jjbx_travel_service/xhtml/travel_service_my_orders.xhtml', page_callback, { orderID: orderID });
            } else {
                alert_confirm('消息内容', content, '', '确认', '', '');
            }
        } else {
            alert(res['errorMsg']);
        }
    }
};
module.exports = { lua_message: lua_message };