--[[项目字典]]

lua_dict = {};

--[[
    将餐饮服务订单对应的状态转换成对应的值
    入参：key
    出参：value
]]
function jjbx_utils_formatEatServerStatus(status)
    if status == "10" then
        return "订单已取消";
    elseif status == "12" then
        return "退款申请成功";
    elseif status == "15" then
        return "等待支付";
    elseif status == "16" then
        return "订单支付失败";
    elseif status == "18" then
        return "订单已支付";
    elseif status == "20" then
        return "等待商家接单";
    elseif status == "30" or status == "35" or status == "40" then
        return "商家正在备货";
    elseif status == "50" then
        return "骑手正在店内取货";
    elseif status == "60" then
        return "骑手正在送货";
    elseif status == "70" then
        return "订单已送达";
    elseif status == "80" then
        return "配送异常";
    elseif status == "90" then
        return "订单已完成";
    elseif status == "100" then
        return "等待商家处理退款申请";
    elseif status == "105" then
        return "商家拒绝退款";
    elseif status == "110" then
        return "退款申请成功";
    elseif status == "120" then
        return "申请部分退款";
    elseif status == "125" then
        return "部分退款失败";
    elseif status == "130" then
        return "部分退款成功";
    else
        return "状态更新失败";
    end;
end;

--[[
    发票类型
    0101 专票
    0104 纸质普票
    0110 电子普票
]]
function checkNoteType(noteCode)
    if noteCode == "0101" or noteCode == "0102" or noteCode == "0103" or noteCode == "0114" then
        return "增值税专用发票";
    else
        return "增值税普通发票";
    end;

    --[[
        0102 货物运输业增值税专用发票;
        0103 机动车增值税专用发票;
        0114 收费公路通行费专用发票;
        0104 纸质普通发票;
        0110 电子普通发票;
    ]]
end;

--[[转换支付状态,二期修改为后台返回，不做转换]]
function jjbx_utils_zfzt(zfzt)
    return  zfzt;
end;

--[[
    登录方式文字配置
      0-密码登录 1- 手势登录  2-指纹  3-刷脸
      mobile_login为自定义配置，不是后台返回
]]
function login_type_name(loginType)
    if loginType == "0" then
        return "账号登录";
    elseif loginType == "1" then
        return "手势登录";
    elseif loginType == "2" then
        return "指纹登录";
    elseif loginType == "3" then
        return "刷脸登录";
    else
        return "其他登录";
    end;
end;

--[[滴滴用车出行订单状态]]
function dd_using_car_status_name(statusCode)
    if     statusCode == "300" then return "待抢单";
    elseif statusCode == "311" then return "已超时";
    elseif statusCode == "400" then return "待接驾";
    elseif statusCode == "410" then return "待接驾";
    elseif statusCode == "500" then return "行程中";
    elseif statusCode == "600" then return "待支付";
    elseif statusCode == "610" then return "已取消";
    elseif statusCode == "700" then return "已完成";
    else return "查询中";
    end;
end;

--[[曹操用车出行订单状态]]
function cc_using_car_status_name(statusCode)
    if     statusCode ==  "1" then return "未派单";
    elseif statusCode ==  "2" then return "已派单";
    elseif statusCode ==  "3" then return "已上车";
    elseif statusCode ==  "8" then return "已计费";
    elseif statusCode ==  "5" then return "待支付";
    elseif statusCode ==  "7" then return "待评价";
    elseif statusCode ==  "6" then return "已评价";
    elseif statusCode ==  "4" then return "已取消";
    elseif statusCode ==  "9" then return "行程中";
    elseif statusCode == "10" then return "待付款";
    elseif statusCode == "11" then return "改派中";
    elseif statusCode == "12" then return "待接驾";
    elseif statusCode == "20" then return "已取消";
    elseif statusCode == "21" then return "已取消";
    elseif statusCode == "26" then return "已取消";
    elseif statusCode == "27" then return "已取消";
    else return "查询中";
    end;
end;

--[[获取状态图标]]
function status_icon(status)
    local status = formatNull(status);
    --debug_alert("获取状态图标 status : "..status);

    --报销中
    if status == "bxz" then return "status_icon_bxz.png";
    --待报销
    elseif status == "dbx" then return "status_icon_dbx.png";
    --待付款
    elseif status == "dfk" then return "status_icon_dfk.png";
    --待支付
    elseif status == "dzf" then return "status_icon_dzf.png";
    --待收货
    elseif status == "dsh" then return "status_icon_dsh.png";
    --审核中
    elseif status == "shz" then return "status_icon_shz.png";
    --待提交
    elseif status == "dtj" then return "status_icon_dtj.png";
    --校验不通过
    elseif status == "jybtg" then return "status_icon_jybtg.png";
    --校验通过
    elseif status == "jytg" then return "status_icon_jytg.png";
    --审核通过
    elseif status == "shtg" then return "status_icon_shtg.png";
    --审批失败
    elseif status == "spsb" then return "status_icon_spsb.png";
    --审批通过
    elseif status == "sptg" then return "status_icon_sptg.png";
    --审批中
    elseif status == "spz" then return "status_icon_spz.png";
    --未报销
    elseif status == "wbx" then return "status_icon_wbx.png";
    --未提交
    elseif status == "wtj" then return "status_icon_wtj.png";
    --无需报销
    elseif status == "wxbx" then return "status_icon_wxbx.png";
    --已报销
    elseif status == "ybx" then return "status_icon_ybx.png";
    --已撤回
    elseif status == "ych" then return "status_icon_ych.png";
    --已过期
    elseif status == "ygq" then return "status_icon_ygq.png";
    --已作废
    elseif status == "yizuofei" then return "status_icon_yizuofei.png";
    --已取消
    elseif status == "yqx" then return "status_icon_yqx.png";
    --已失效
    elseif status == "ysx" then return "status_icon_ysx.png";
    --已提交
    elseif status == "ytj" then return "status_icon_ytj.png";
    --已完成
    elseif status == "ywc" then return "status_icon_ywc.png";
    --已完结
    elseif status == "ywj" then return "status_icon_ywj.png";
    --已支付
    elseif status == "yzf" then return "status_icon_yzf.png";
    --超时支付
    elseif status == "cszf" then return "status_icon_cszf.png";
    --超时失效
    elseif status == "cssx" then return "status_icon_cssx.png";
    --待补录
    elseif status == "dbl" then return "status_icon_dbl.png";
    --补录提交
    elseif status == "bltj" then return "status_icon_bltj.png";
    --复核通过
    elseif status == "fhtg" then return "status_icon_fhtg.png";
    --复核驳回
    elseif status == "fhbh" then return "status_icon_fhbh.png";
    else
        --debug_alert("未知状态");
        return "";
    end
end;

--根据证件类型编码返回证件类型名称
function format_certificate(code)
    local certificateList = {
        {key="0",value="身份证"},
        {key="1",value="台胞证"},
        {key="2",value="香港身份证"}, 
        {key="3",value="外籍人士护照"}, 
        {key="a",value="中国护照" },
        {key="b",value="边民出入境通行证"},
        {key="c",value="其他个人证件"},
        {key="d",value="户口簿"},
        {key="e",value="军人身份证件"},
        {key="f",value="武装警察身份证件"},
        {key="g",value="外国人永久居留证"}
    };

    local certificateName = "";
    for i=1,#certificateList do
        if code == certificateList[i]["key"] then
            certificateName = certificateList[i]["value"];
        end;
    end;
    return certificateName;
end;