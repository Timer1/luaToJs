lua_dict = {};
jjbx_utils_formatEatServerStatus = function (status) {
    if (status === '10') {
        return '订单已取消';
    } else if (status === '12') {
        return '退款申请成功';
    } else if (status === '15') {
        return '等待支付';
    } else if (status === '16') {
        return '订单支付失败';
    } else if (status === '18') {
        return '订单已支付';
    } else if (status === '20') {
        return '等待商家接单';
    } else if (status === '30' || status === '35' || status === '40') {
        return '商家正在备货';
    } else if (status === '50') {
        return '骑手正在店内取货';
    } else if (status === '60') {
        return '骑手正在送货';
    } else if (status === '70') {
        return '订单已送达';
    } else if (status === '80') {
        return '配送异常';
    } else if (status === '90') {
        return '订单已完成';
    } else if (status === '100') {
        return '等待商家处理退款申请';
    } else if (status === '105') {
        return '商家拒绝退款';
    } else if (status === '110') {
        return '退款申请成功';
    } else if (status === '120') {
        return '申请部分退款';
    } else if (status === '125') {
        return '部分退款失败';
    } else if (status === '130') {
        return '部分退款成功';
    } else {
        return '状态更新失败';
    }
};
checkNoteType = function (noteCode) {
    if (noteCode === '0101' || noteCode === '0102' || noteCode === '0103' || noteCode === '0114') {
        return '增值税专用发票';
    } else {
        return '增值税普通发票';
    }
};
jjbx_utils_zfzt = function (zfzt) {
    return zfzt;
};
login_type_name = function (loginType) {
    if (loginType === '0') {
        return '账号登录';
    } else if (loginType === '1') {
        return '手势登录';
    } else if (loginType === '2') {
        return '指纹登录';
    } else if (loginType === '3') {
        return '刷脸登录';
    } else {
        return '其他登录';
    }
};
dd_using_car_status_name = function (statusCode) {
    if (statusCode === '300') {
        return '待抢单';
    } else if (statusCode === '311') {
        return '已超时';
    } else if (statusCode === '400') {
        return '待接驾';
    } else if (statusCode === '410') {
        return '待接驾';
    } else if (statusCode === '500') {
        return '行程中';
    } else if (statusCode === '600') {
        return '待支付';
    } else if (statusCode === '610') {
        return '已取消';
    } else if (statusCode === '700') {
        return '已完成';
    } else {
        return '查询中';
    }
};
cc_using_car_status_name = function (statusCode) {
    if (statusCode === '1') {
        return '未派单';
    } else if (statusCode === '2') {
        return '已派单';
    } else if (statusCode === '3') {
        return '已上车';
    } else if (statusCode === '8') {
        return '已计费';
    } else if (statusCode === '5') {
        return '待支付';
    } else if (statusCode === '7') {
        return '待评价';
    } else if (statusCode === '6') {
        return '已评价';
    } else if (statusCode === '4') {
        return '已取消';
    } else if (statusCode === '9') {
        return '行程中';
    } else if (statusCode === '10') {
        return '待付款';
    } else if (statusCode === '11') {
        return '改派中';
    } else if (statusCode === '12') {
        return '待接驾';
    } else if (statusCode === '20') {
        return '已取消';
    } else if (statusCode === '21') {
        return '已取消';
    } else if (statusCode === '26') {
        return '已取消';
    } else if (statusCode === '27') {
        return '已取消';
    } else {
        return '查询中';
    }
};
status_icon = function (status) {
    var status = formatNull(status);
    if (status === 'bxz') {
        return 'status_icon_bxz.png';
    } else if (status === 'dbx') {
        return 'status_icon_dbx.png';
    } else if (status === 'dfk') {
        return 'status_icon_dfk.png';
    } else if (status === 'dzf') {
        return 'status_icon_dzf.png';
    } else if (status === 'dsh') {
        return 'status_icon_dsh.png';
    } else if (status === 'shz') {
        return 'status_icon_shz.png';
    } else if (status === 'dtj') {
        return 'status_icon_dtj.png';
    } else if (status === 'jybtg') {
        return 'status_icon_jybtg.png';
    } else if (status === 'jytg') {
        return 'status_icon_jytg.png';
    } else if (status === 'shtg') {
        return 'status_icon_shtg.png';
    } else if (status === 'spsb') {
        return 'status_icon_spsb.png';
    } else if (status === 'sptg') {
        return 'status_icon_sptg.png';
    } else if (status === 'spz') {
        return 'status_icon_spz.png';
    } else if (status === 'wbx') {
        return 'status_icon_wbx.png';
    } else if (status === 'wtj') {
        return 'status_icon_wtj.png';
    } else if (status === 'wxbx') {
        return 'status_icon_wxbx.png';
    } else if (status === 'ybx') {
        return 'status_icon_ybx.png';
    } else if (status === 'ych') {
        return 'status_icon_ych.png';
    } else if (status === 'ygq') {
        return 'status_icon_ygq.png';
    } else if (status === 'yizuofei') {
        return 'status_icon_yizuofei.png';
    } else if (status === 'yqx') {
        return 'status_icon_yqx.png';
    } else if (status === 'ysx') {
        return 'status_icon_ysx.png';
    } else if (status === 'ytj') {
        return 'status_icon_ytj.png';
    } else if (status === 'ywc') {
        return 'status_icon_ywc.png';
    } else if (status === 'ywj') {
        return 'status_icon_ywj.png';
    } else if (status === 'yzf') {
        return 'status_icon_yzf.png';
    } else if (status === 'cszf') {
        return 'status_icon_cszf.png';
    } else if (status === 'cssx') {
        return 'status_icon_cssx.png';
    } else if (status === 'dbl') {
        return 'status_icon_dbl.png';
    } else if (status === 'bltj') {
        return 'status_icon_bltj.png';
    } else if (status === 'fhtg') {
        return 'status_icon_fhtg.png';
    } else if (status === 'fhbh') {
        return 'status_icon_fhbh.png';
    } else {
        return '';
    }
};
format_certificate = function (code) {
    var certificateList = [
        {
            key: '0',
            value: '身份证'
        },
        {
            key: '1',
            value: '台胞证'
        },
        {
            key: '2',
            value: '香港身份证'
        },
        {
            key: '3',
            value: '外籍人士护照'
        },
        {
            key: 'a',
            value: '中国护照'
        },
        {
            key: 'b',
            value: '边民出入境通行证'
        },
        {
            key: 'c',
            value: '其他个人证件'
        },
        {
            key: 'd',
            value: '户口簿'
        },
        {
            key: 'e',
            value: '军人身份证件'
        },
        {
            key: 'f',
            value: '武装警察身份证件'
        },
        {
            key: 'g',
            value: '外国人永久居留证'
        }
    ];
    var certificateName = '';
    for (let i = 1; certificateList.length; i++) {
        if (code === certificateList[i]['key']) {
            certificateName = certificateList[i]['value'];
        }
    }
    return certificateName;
};
module.exports = { lua_dict: lua_dict };