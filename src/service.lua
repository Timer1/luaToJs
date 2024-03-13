--[[服务相关lua]]
lua_service = {};

--[[杭口医院预算查询]]
function lua_service.qry_hk_budget(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        --debug_alert("杭口医院预算查询");
        local ResCallBackFunc = vt("ResCallBackFunc",ReqParams);
        invoke_trancode_donot_checkRepeat(
            "jjbx_service",
            "local_service",
            {
                ServiceName="hkHospital",
                TranCode="getBudget"
            },
            lua_service.qry_hk_budget,
            {
                ResCallBackFunc=ResCallBackFunc
            },
            all_callback,
            {CloseLoading="false"}
        );
    else
        local res = json2table(ResParams["responseBody"]);
        --debug_alert("杭口医院预算查询响应"..foreach_arg2print(res));
        local errorNo = vt("errorNo",res);
        local errorMsg = vt("errorMsg",res);

        --自定义回调
        local ResCallBackFunc = vt("ResCallBackFunc",ResParams);
        --剩余预算金额
        local remainValue = vt("remainValue",res);
        
        --[[debug_alert(
            "剩余预算金额 : "..remainValue.."\n"..
            "自定义回调方法名 : "..ResCallBackFunc.."\n"..
            ""
        );]]

        if ResCallBackFunc ~= "" then
            --自定义回调
            lua_system.do_function(ResCallBackFunc,{remainValue=remainValue});
        else
            --默认回调
            if errorNo == "000000" then
                if remainValue == "" then
                    alert("未获取到预算，无法公司账号支付，请联系系统管理员");
                else
                    if tonumber(remainValue) > 0 then
                        --debug_alert("前往金额输入页面");
                        invoke_page("jjbx_local_service/hkHospital/amount_input.xhtml",page_callback,{CloseLoading="false"});
                    else
                        alert("您的公司账户余额为0，暂不可使用");
                    end;
                end;
            else
                alert(errorMsg);
            end;
        end;
    end;
end;

--[[杭口医院付款信息查询]]
function lua_service.qry_hk_pay_info(ResParams,ReqParams)
    if formatNull(ResParams) == "" then
        local InputAmount = formatNull(getValue("input_amount"),"0");
        invoke_trancode(
            "jjbx_service",
            "local_service",
            {
                ServiceName="hkHospital",
                TranCode="executeBudgetAndGetInfo",
                amount=InputAmount
            },
            lua_service.qry_hk_pay_info,
            {},
            all_callback,
            {CloseLoading="false"}
        );
    else
        local res = json2table(ResParams["responseBody"]);
        --debug_alert(foreach_arg2print(res));

        local errorNo = vt("errorNo",res);
        local errorMsg = vt("errorMsg",res);

        if errorNo == "000000" then
            local QrCodeInfoRes = vt("qrCode",res);
            if QrCodeInfoRes == "" then
                alert("付款码获取失败");
            else
                --存储付款码信息
                globalTable["hkHospitalPayQrCodeInfo"] = QrCodeInfoRes;
                --存储消费金额
                globalTable["hkHospitalPayAmount"] = vt("InputAmount",res);
                --前往付款码页面
                invoke_page("jjbx_local_service/hkHospital/pay_qrcode.xhtml",page_callback,{CloseLoading="false"});
            end;
        else
            --更新预算
            update_budget(res);
            --错误信息
            alert(errorMsg);
        end;
    end;
end;
