--[[单据配置字典]]

lua_bill_dict = {};

--[[单据类型列表]]
billTypeList_utils = {
    --行程报销单
    xcbx      = "FIN-006-001",
    --报账单
    bzd       = "FIN-006-002",
    --事项申请单
    sxsq      = "FIN-006-003",
    --借垫款单
    jk        = "FIN-006-004",
    --还款单
    hk        = "FIN-006-005",
    --应付款申请单
    yfksq     = "FIN-006-006",
    --应付款支付单
    yfkzf     = "FIN-006-007",
    --系统内支付单
    xtnzf     = "FIN-006-008",
    --成本分摊单
    cbft      = "FIN-006-009",
    --备用金申请单
    byjsq     = "FIN-006-010",
    --凭证单据
    pzdj      = "FIN-006-011",
    --行程申请单
    xcsq      = "FIN-006-012",
    --用车申请单
    ycsq      = "FIN-006-013",
    --采购申请单
    cgsq      = "FIN-006-014",
    --统一结算单
    tyjs      = "FIN-006-015",
    --差旅报销单
    clbx      = "FIN-006-016",
    --福利采购单
    flcg      = "FIN-006-017",
    --用餐申请单
    eatServer = "FIN-006-019",
    --扣款单
    kkd = "FIN-006-021",
    --新采购申请
    cgsq_new = "FIN-006-022",
    --薪酬审批单
    xcsp = "FIN-006-023",
    --事项调整单
    sxjs = "FIN-006-025",
    --专业报账单
    zybzd = "FIN-006-026"
};

--[[单据名称列表]]
billNameList_utils = {
    jk = "借垫款单"
};

--[[通过单据号获取单据类型]]
function bill_no2type(billNo)
    local billNo = formatNull(billNo);
    if billNo ~= "" then
        billNo = string.sub(billNo,1,3);
        --行程报销单
        if billNo == "BSL" then return billTypeList_utils.xcbx;
        --报账单
        elseif billNo == "BFY" then return billTypeList_utils.bzd;
        --事项申请单
        elseif billNo == "SSX" then return billTypeList_utils.sxsq;
        --借垫款单
        elseif billNo == "BJK" then return billTypeList_utils.jk;
        --还款单
        elseif billNo == "BHK" then return billTypeList_utils.hk;
        --应付款申请单
        elseif billNo == "ZYF" then return billTypeList_utils.yfksq;
        --应付款支付单
        elseif billNo == "BYF" then return billTypeList_utils.yfkzf;
        --系统内支付单
        elseif billNo == "ZXT" then return billTypeList_utils.xtnzf;
        --成本分摊单
        elseif billNo == "ZCB" then return billTypeList_utils.cbft;
        --备用金申请单
        elseif billNo == "ZBY" then return billTypeList_utils.byjsq;
        --凭证单据
        elseif billNo == "ZPZ" then return billTypeList_utils.pzdj;
        --行程申请单
        elseif billNo == "SSL" then return billTypeList_utils.xcsq;
        --用车申请单
        elseif billNo == "CAR" then return billTypeList_utils.ycsq;
        --采购申请单
        elseif billNo == "SCG" then return billTypeList_utils.cgsq;
        --统一结算单
        elseif billNo == "TAC" then return billTypeList_utils.tyjs;
        --差旅报销单
        elseif billNo == "BCL" then return billTypeList_utils.clbx;
        --用餐申请单
        elseif billNo == "SYC" then return billTypeList_utils.eatServer;
        --扣款单
        elseif billNo == "ZSK" then return billTypeList_utils.kkd;
        --新采购申请单
        elseif billNo == "CGD" then return billTypeList_utils.cgsq_new;
        --薪酬审批单
        elseif billNo == "ZXC" then return billTypeList_utils.xcsp;
        --事项调整单
        elseif billNo == "SJS" then return billTypeList_utils.sxjs;
        else
            --alert("不支持该单据");
            return "";
        end;
    else
        alert("单据号为空");
        return "";
    end;
end;

--[[档案类型编码]]
fileCodeList_utils = {
    --业务类型
    ywlx   = "FIN-001",
    --收支项目
    szxm   = "FIN-002",
    --项目档案
    xmda   = "FIN-003",
    --发票类型
    fplx   = "FIN-004",
    --转出类型
    zclx   = "FIN-005",
    --单据类型
    djlx   = "FIN-006",
    --科目
    km     = "FIN-007",
    --进项税科目
    jxskm  = "FIN-008",
    --流水备注档案
    lsbzda = "FIN-009",
    --报销场景
    bxcj   = "FIN-010",
    --结算方式类型
    jsfslx = "FIN-011",
    --期薪类型
    qxlx   = "FIN-012",
    --申请类型
    sqlx   = "FIN-013",
    --借垫款方式
    jkfs   = "FIN-014",
    --还款方式
    hkfs   = "FIN-015",
    --在建工程科目
    zjgckm = "FIN-016",
    --折旧方法
    zjff   = "FIN-017",
    --企业收款账户
    qyskzh = "FIN-018",
    --分摊类型
    ftlx   = "FIN-019",
    --应付款类型
    yfklx  = "FIN-020"
};

--[[单据类型]]
function lua_bill_dict.billCode_to_billName(billCode)
    if billCode == billTypeList_utils.xcbx then
        return "行程报销单";
    elseif billCode == billTypeList_utils.bzd then
        return "报账单";
    elseif billCode == billTypeList_utils.sxsq then
        return "事项申请单";
    elseif billCode == billTypeList_utils.jk then
        return "借垫款单";
    elseif billCode == billTypeList_utils.hk then
        return "还款单";
    elseif billCode == billTypeList_utils.yfksq then
        return "应付款申请单";
    elseif billCode == billTypeList_utils.yfkzf then
        return "应付款支付单";
    elseif billCode == billTypeList_utils.xtnzf then
        return "系统内支付单";
    elseif billCode == billTypeList_utils.cbft then
        return "成本分摊单";
    elseif billCode == billTypeList_utils.byjsq then
        return "备用金申请单";
    elseif billCode == billTypeList_utils.pzdj then
        return "凭证单据";
    elseif billCode == billTypeList_utils.xcsq then
        return "行程申请单";
    elseif billCode == billTypeList_utils.ycsq then
        return "用车申请单";
    elseif billCode == billTypeList_utils.cgsq then
        return "采购申请单";
    elseif billCode == billTypeList_utils.tyjs then
        return "统一结算单";
    elseif billCode == billTypeList_utils.clbx then
        return "差旅报销单";
    elseif billCode == billTypeList_utils.flcg then
        return "福利采购单";
    elseif billCode == billTypeList_utils.eatServer then
        return "用餐申请单";
    elseif billCode == billTypeList_utils.kkd then
        return "统一收款单";
    elseif billCode == billTypeList_utils.cgsq_new then
        return "新采购申请单"
    elseif billCode == billTypeList_utils.xcsp then
        return "薪酬审批单"
    elseif billCode == billTypeList_utils.sxjs then
        return "事项调整单"
    elseif billCode == billTypeList_utils.zybzd then
        return "专业报账单"
    else
        return "";
    end;
end;

--[[
    根据后台的单据配置在app建立的关联关系
    level1 : 单据基本信息，对应后台的billConfig/queryConfigApp接口的modelType=1
    level1.key   : app转义的单据类型
    level1.value : billConfig/queryConfigApp modelType为1的字段名
    level1.value[1] : 字段定义的显示内容类型
    level1.value[2] : common/queryByBillNo 对应取值的字段名
    level1.value[3] : 显示样式类型定义
    level1.value[4] : 点击事件
]]
bill_config = {
    level1 = {
        --行程报销 FIN-006-001
        xcbx = {
            --单据号
            djh="text,djh",
            --申请日期
            zdrq="date,zdrq",
            --申请人
            zdr="text,zdr",
            --申请公司
            zdrgs="text,ssjg",
            --申请部门
            zdrbm="text,ssbm",
            --单据金额
            djje="text,hjje,orange",
            --结算方式
            jsfs="text,zffs",
            --应收发票金额
            ysfphjj="text,ysfphj,orange",
            --事由
            sy="text,bxsm",
            --附件张数
            fjzs="text,fjzs",
            --流水金额
            lsje="text,lsje,orange,jjbx_relevance_serial()",
            --纸质附件
            fjzsFlag="fjzsFlag,fjzsFlag",
            --扫描顺序号
            scanSequenceNo="text,scanSequenceNo",
            --数据来源
            billSource = "text,billSource"
        },
        --报账单 FIN-006-002
        bzd = {
            --单据号
            djh="text,djh",
            --申请公司
            zdrgs="text,ssjg",
            --申请人
            zdr="text,zdr",
            --申请日期
            zdrq="date,zdrq",
            --申请部门
            zdrbm="text,ssbm",
            --附件张数
            fjzs="text,fjzs",
            --单据金额
            djje="text,hjje,orange",
            --流水金额
            lsje="text,lsje,orange,jjbx_relevance_serial()",
            --备用字段
            byzd="text,byzd",
            --纸质附件
            fjzsFlag="fjzsFlag,fjzsFlag",
            --自定义字段
            zdy="text,zdy",
            --扫描顺序号
            scanSequenceNo="text,scanSequenceNo",
            --数据来源
            billSource = "text,billSource"
        },
        --报账单 FIN-006-026
        zybzd = {
            --单据号
            djh="text,djh",
            --申请公司
            zdrgs="text,ssjg",
            --申请人
            zdr="text,zdr",
            --申请日期
            zdrq="date,zdrq",
            --申请部门
            zdrbm="text,ssbm",
            --附件张数
            fjzs="text,fjzs",
            --单据金额
            djje="text,hjje,orange",
            --流水金额
            lsje="text,lsje,orange,jjbx_relevance_serial()",
            --备用字段
            byzd="text,byzd",
            --纸质附件
            fjzsFlag="fjzsFlag,fjzsFlag",
            --自定义字段
            zdy="text,zdy",
            --扫描顺序号
            scanSequenceNo="text,scanSequenceNo",
            --数据来源
            billSource = "text,billSource"
        },
        --事项申请单 FIN-006-003
        sxsq = {
            --单据号  
            djh="text,djh",
            --申请公司
            zdrgs="text,ssjg",
            --申请人  
            zdr="text,zdr",
            --申请日期
            zdrq="date,zdrq",
            --申请部门
            zdrbm="text,ssbm",
            --单据金额
            djje="text,hjje,orange",
            --申请类型
            sqlx="text,sqlx",
            --事由    
            sy="text,bxsm",
            --是否紧急
            sfjj="bool,sfjj",
            --上传附件
            fjzs="text,fjzs",
            --纸质附件
            fjzsFlag="fjzsFlag,fjzsFlag",
            --扫描顺序号
            scanSequenceNo="text,scanSequenceNo",
            --数据来源
            billSource = "text,billSource",
            --是否经财审会审批
            sfsp_div = "text,sfsp",
            --数据来源
            billSource = "text,billSource"
        },
        --借垫款单 FIN-006-004
        jk = {
            --单据号 
            djh="text,djh",
            --申请人  
            zdr="text,zdr",
            --申请公司
            zdrgs="text,ssjg",
            --申请部门
            zdrbm="text,ssbm",
            --申请日期
            zdrq="date,zdrq",
            --单据金额
            djje="text,hjje,orange",
            --是否紧急
            sfjj="bool,sfjj",
            --附件张数
            fjzs="text,fjzs",
            --纸质附件
            fjzsFlag="fjzsFlag,fjzsFlag",
            --自定义字段
            zdy="text,zdy",
            --扫描顺序号
            scanSequenceNo="text,scanSequenceNo",
            --数据来源
            billSource = "text,billSource",
            --数据来源
            billSource = "text,billSource"
        },
        --还款单 FIN-006-005
        hk = {
            --单据号  
            djh="text,djh",
            --申请人  
            zdr="text,zdr",
            --申请公司
            zdrgs="text,ssjg",
            --申请部门
            zdrbm="text,ssbm",
            --申请日期
            zdrq="date,zdrq",
            --单据金额
            djje="text,hjje,orange",
            --附件张数
            fjzs="text,fjzs",
            --纸质附件
            fjzsFlag="fjzsFlag,fjzsFlag",
            --自定义字段
            zdy="text,zdy",
            --扫描顺序号
            scanSequenceNo="text,scanSequenceNo",
            --数据来源
            billSource = "text,billSource",
            --数据来源
            billSource = "text,billSource"
        },
        --应付款申请单 FIN-006-006
        yfksq = {
            --单据号  
            djh="text,djh",
            --申请日期
            zdrq="date,zdrq",
            --申请人  
            zdr="text,zdr",
            --申请公司
            zdrgs="text,ssjg",
            --申请部门
            zdrbm="text,ssbm",
            --单据金额
            djje="text,hjje,orange",
            --附件张数
            fjzs="text,fjzs",
            --纸质附件
            fjzsFlag="fjzsFlag,fjzsFlag",
            --自定义字段
            zdy="text,zdy",
            --扫描顺序号
            scanSequenceNo="text,scanSequenceNo",
            --数据来源
            billSource = "text,billSource"
        },
        --应付款支付单 FIN-006-007
        yfkzf = {
            --单据号  
            bxdh="text,djh",
            --申请日期
            zdrq="date,zdrq",
            --申请人  
            zdr="text,zdr",
            --申请公司
            ssjg="text,ssjg",
            --申请部门
            ssbm="text,ssbm",
            --单据金额
            hjje="text,hjje,orange",
            --附件张数
            fjzs="text,fjzs",
            --纸质附件
            fjzsFlag="fjzsFlag,fjzsFlag",
            --是否紧急
            sfjj="bool,sfjj",
            --事由
            bxsm="text,bxsm",
            --扫描顺序号
            scanSequenceNo="text,scanSequenceNo",
            --数据来源
            billSource = "text,billSource"
        },
        --系统内支付单 FIN-006-008
        xtnzf = {
            --单据号  
            djh="text,djh",
            --申请人  
            zdr="text,zdr",
            --申请公司
            zdrgs="text,ssjg",
            --申请部门
            zdrbm="text,ssbm",
            --申请日期
            zdrq="date,zdrq",
            --单据金额
            djje="text,hjje,orange",
            --附件张数
            fjzs="text,fjzs",
            --纸质附件
            fjzsFlag="fjzsFlag,fjzsFlag",
            --自定义字段
            zdy="text,zdy",
            --扫描顺序号
            scanSequenceNo="text,scanSequenceNo",
            --数据来源
            billSource = "text,billSource"
        },
        --成本分摊单 FIN-006-009
        cbft = {
            --单据号  
            djh="text,djh",
            --申请人  
            zdr="text,zdr",
            --申请公司
            zdrgs="text,ssjg",
            --申请部门
            zdrbm="text,ssbm",
            --申请日期
            zdrq="date,zdrq",
            --单据金额
            djje="text,hjje,orange",
            --事由    
            sy="text,bxsm",
            --附件张数
            fjzs="text,fjzs",
            --流水金额
            lsje="text,lsje,orange,jjbx_relevance_serial()",
            --发票金额
            fpje="text,fphj,orange",
            --纸质附件
            fjzsFlag="fjzsFlag,fjzsFlag",
            --扫描顺序号
            scanSequenceNo="text,scanSequenceNo",
            --数据来源
            billSource = "text,billSource"
        },
        --备用金申请单 FIN-006-010
        byjsq = {
            --事由    
            sy="text,bxsm",
            --单据号  
            djh="text,djh",
            --申请人  
            zdr="text,zdr",
            --申请公司
            zdrgs="text,ssjg",
            --申请部门
            zdrbm="text,ssbm",
            --申请日期
            zdrq="date,zdrq",
            --附件张数
            fjzs="text,fjzs",
            --单据金额
            djje="text,hjje,orange",
            --纸质附件
            fjzsFlag="fjzsFlag,fjzsFlag",
            --扫描顺序号
            scanSequenceNo="text,scanSequenceNo",
            --数据来源
            billSource = "text,billSource"
        },
        --凭证单据 FIN-006-011
        pzdj = {
            --单据号  
            djh="text,djh",
            --申请人  
            zdr="text,zdr",
            --申请公司
            zdrgs="text,ssjg",
            --申请部门
            zdrbm="text,ssbm",
            --申请日期
            zdrq="date,zdrq",
            --单据金额
            djje="text,hjje,orange",
            --附件张数
            fjzs="text,fjzs",
            --凭证类别
            pzlx="text,sqlx",
            --冲销单据号
            gldjh="text,gldjh",
            --流水金额
            lsje="text,lsje,orange,jjbx_relevance_serial()",
            --备用金申请金额
            byjhjje="text,byjhj,orange",
            --发票金额
            fphjje="text,fphj,orange",
            --纸质附件
            fjzsFlag="fjzsFlag,fjzsFlag",
            --自定义字段
            zdy="text,zdy",
            --扫描顺序号
            scanSequenceNo="text,scanSequenceNo",
            --数据来源
            billSource = "text,billSource",
            --数据来源
            billSource = "text,billSource"
        },
        --行程申请 FIN-006-012
        xcsq = {
            --单据号  
            djh="text,tripappno",
            --申请人  
            zdr="text,createuser",
            --申请公司
            zdrgs="text,corpName",
            --申请部门
            zdrbm="text,deptName",
            --申请日期
            zdrq="date,createdate",
            --事由    
            sy="text,abs",
            --行程类型
            xclx="text,triptypeName",
            --项目档案
            xmda="text,item",
            --报销单号
            bxdh="text,travelReimbursementNo",
            --预估金额
            ygje="text,costestimate,orange",
            --业务类型
            ywlx="text,serviceType",
            --自定义字段
            zdy="text,zdy",
            --数据来源
            billSource = "text,billSource"
        },
        --用车申请单 FIN-006-013
        ycsq = {
            djzt="text,billstatus",
            --是否往返
            ycsfwf="bool,ifwf",
            --申请单号
            djh="text,tripappno",
            --用车时间
            ycycsj="ycsj,usecartime",
            --申请人  
            zdr="text,createUser",
            --申请公司
            zdrgs="text,corpname",
            --申请日期
            zdrq="text,createDate",
            --申请部门
            zdrbm="text,deptname",
            --事由    
            sy="text,reason",
            --项目档案
            xmda="text,item",
            --车型    
            yccx="cartype,cartype",
            --用车城市
            yccs="text,didicity",
            --是否代叫车
            ycsfdjc="bool,callcarflag",
            --出发地点    
            yccfdd="text,locationstart",
            --到达地点
            ycmddd="text,locationend",
            --有效期至
            yxqend="text,diditripdate",
            --数据来源
            billSource = "text,billSource"
        },
        --采购申请单 FIN-006-014
        cgsq = {
            --单据状态
            djzt="text",
            --单据号
            djh="text,purchaseNo",
            --申请人  
            zdr="text,createuser",
            --申请公司
            zdrgs="text,corpname",
            --事由
            sy="text,purchasereason",
            --项目档案
            xmda="text,item",
            --承担人
            cdr="text,chengdanren",
            --承担部门
            cdrbm="text,chengdanbumen",
            --申请部门
            zdrbm="text,deptname",
            --申请日期
            zdrq="text,createdate",
            --有效期至
            yxqend="text,expDate",
            --采购总额
            cghjje="text",
            --自定义字段
            zdy="text,zdy",
            --数据来源
            billSource = "text,billSource"
        },
        --统一结算单 FIN-006-015
        tyjs = {
            --单据号  
            djh="text,djh",
            --申请人  
            zdr="text,zdr",
            --申请公司
            zdrgs="text,ssjg",
            --申请日期
            zdrq="date,zdrq",
            --单据金额
            djje="text,hjje,orange",
            --发票总额
            fphjje="text,fphj,orange",
            --事由    
            sy="text,bxsm",
            --附件张数
            fjzs="text,fjzs",
            --纸质附件
            fjzsFlag="fjzsFlag,fjzsFlag",
            --结算周期
            jszq="text,cfcs",
            --数据来源
            sjly="text,mdcs",
            --扫描顺序号
            scanSequenceNo="text,scanSequenceNo",
            --数据来源
            billSource = "text,billSource"
        },
        --差旅报销 FIN-006-016
        clbx = {
            --单据号  
            djh="text,djh",
            --申请人  
            zdr="text,zdr",
            --申请公司
            zdrgs="text,ssjg",
            --申请部门
            zdrbm="text,ssbm",
            --申请日期
            zdrq="date,zdrq",
            --单据金额
            djje="text,hjje,orange",
            --事由    
            sy="text,bxsm",
            --上传附件
            fjzs="text,fjzs",
            --出发日期
            cfrq="date,cfrq",
            --返程日期
            fcrq="date,fcrq",
            --出发城市    
            cfcs="text,cfcs",
            --目的城市
            mdcs="text,mdcs",
            --流水金额
            lsje="text,lsje,orange,jjbx_relevance_serial()",
            --纸质附件
            fjzsFlag="fjzsFlag,fjzsFlag",
            --扫描顺序号
            scanSequenceNo="text,scanSequenceNo",
            --数据来源
            billSource = "text,billSource"
        },
        --福利采购 FIN-006-017
        flcg = {
            --单据号  
            djh="text,djh",
            --申请人  
            zdr="text,zdr",
            --申请公司
            zdrgs="text,zdrgs",
            --事由    
            sy="text,sy",
            --项目档案
            xmda="text,xmda",
            --承担人  
            cdr="text,cdr",
            --承担部门
            cdrbm="text,cdrbm",
            --数据来源
            billSource = "text,billSource"
        },
        --用餐申请单 FIN-006-019    
        eatServer = {
            --单据状态
            djzt="djzt,djzt",
            --单据号  
            djh="text,djh",
            --申请日期
            zdrq="date,createTime",
            --申请人  
            zdr="text,zdr",
            --申请公司
            zdrgs="text,ssjg",
            --申请部门
            zdrbm="text,ssbm",
            --单据金额
            djje="text,hjje,orange",
            --附件张数
            fjzs="text,fjzs",
            --企业收款账户
            qyskzh="text,qyskzh",
            --扣款事由
            sy="text,bz",
            --承担人
            cdr="text,cdr",
            --承担人部门
            cdrbm="text,cdbm",
            --用餐事由
            ycsy_div="text,bxsm",
            --用餐日期
            ycrq_div="eatServiceTime,xcrqed",
            --申请金额
            sqje_div="text,hjje,orange",
            --业务场景
            ywcj_div="text,bxcj",
            --用餐类型
            yclx_div="yclx,sfzc",
            --可用次数
            kycs_div="text,zdrt",
            --收支项目
            szxm_div="text,szxm",
            --项目档案
            xmda_div="text,xmda",
            --业务类型
            ywlx_div="text,ywlx",
            --剩余可用次数
            sykycs_div="text,sjcxts",
            --剩余可用金额
            sykyje_div="text,btje2",
            --人均餐标
            rjcb_div="rjcb,btje3",
            --用餐人数
            ycrs_div="text,zcsl",
            -- 用餐制度
            yczd_div="text,sqlx",
            --数据来源
            billSource = "text,billSource"
        },
        --统一收款单 FIN-006-021
        kkd = {
            --单据号  
            djh="text,djh",
            --申请人  
            zdr="text,zdr",
            --申请公司
            zdrgs="text,ssjg",
            --申请部门
            zdrbm="text,ssbm",
            --申请日期
            zdrq="date,zdrq",
            --单据金额
            djje="text,hjje,orange",
            --附件张数
            fjzs="text,fjzs",
            --事由    
            bxsm="text,bxsm",
            --收款户名    
            sqlxbm="text,sqlxbm",
            --收款账户    
            sqlx="text,sqlx",
            --纸质附件
            fjzsFlag="fjzsFlag,fjzsFlag",
            --扫描顺序号
            scanSequenceNo="text,scanSequenceNo",
            --数据来源
            billSource = "text,billSource"
        },
        --新采购申请单 FIN-006-022
        cgsq_new = {
            --单据状态
            djzt="text",
            --单据号
            djh="text,djh",
            --申请人  
            zdr="text,zdr",
            --申请公司
            ssjg="text,ssjg",
            --事由
            cgsy="text,bxsm",
            --承担人
            cdr="text",
            --承担部门
            cdbm="text",
            --申请部门
            ssbm="text,ssbm",
            --申请日期
            zdrq="date,zdrq",
            --采购总额
            cghjje="text,hjje,orange",
            --采购制度
            cgzd="text,sqlx",
            --数据来源
            billSource = "text,billSource"
        },
        --薪酬审批单 FIN-006-023
        xcsp = {
            --单据号  
            djh="text,djh",
            --申请人  
            zdr="text,zdr",
            --申请公司
            zdrgs="text,ssjg",
            --申请部门
            zdrbm="text,ssbm",
            --申请日期
            zdrq="date,zdrq",
            --单据金额
            djje="text,hjje,orange",
            --附件张数
            fjzs="text,fjzs",
            --凭证类别
            pzlx="text,sqlx",
            --冲销单据号
            gldjh="text,gldjh",
            --流水金额
            lsje="text,lsje,orange,jjbx_relevance_serial()",
            --备用金申请金额
            byjhjje="text,byjhj,orange",
            --发票金额
            fphjje="text,fphj,orange",
            --纸质附件
            fjzsFlag="fjzsFlag,fjzsFlag",
            --自定义字段
            zdy="text,zdy",
            --扫描顺序号
            scanSequenceNo="text,scanSequenceNo",
            --数据来源
            billSource = "text,billSource"
        },
        --事项调整单 FIN-006-025
        sxjs = {
            --单据号  
            djh="text,djh",
            --申请公司
            zdrgs="text,ssjg",
            --申请人  
            zdr="text,zdr",
            --申请日期
            zdrq="date,zdrq",
            --申请部门
            zdrbm="text,ssbm",
            --单据金额
            djje="text,hjje,orange",
            --申请类型
            sqlx="text,sqlx",
            --事由    
            sy="text,bxsm",
            --是否紧急
            sfjj="bool,sfjj",
            --上传附件
            fjzs="text,fjzs",
            --纸质附件
            fjzsFlag="fjzsFlag,fjzsFlag",
            --关联单据号
            gldjh = "text,gldjh,blue,jjbx_to_sxsqDetail()",
            --数据来源
            billSource = "text,billSource",
            --扫描顺序号
            scanSequenceNo="text,scanSequenceNo"
        }
    }
};

--[[转换单据状态：编码转文字]]
function bill_statecode2text(stateCode)
    --[[0待提交;1已提交;2审批中;3审批通过;98已作废]]
    if stateCode == "0" then
        return "待提交";
    elseif stateCode == "1" then
        return "已提交";
    elseif stateCode == "2" then
        return "审批中";
    elseif stateCode == "3" then
        return "审批通过";
    elseif stateCode == "4" then
        return "审批失败";
    elseif stateCode == "98" then
        return "已作废";
    else
        return "其他";
    end;
end;

--[[转换单据状态：文字转编码]]
function bill_statetext2code(stateText)
    if stateText == "审批通过" or stateText == "审批完成" then
        return "3";
    elseif stateText == "审批失败" then
        return "4";
    elseif stateText == "审批中" then
        return "2";
    elseif stateText == "已提交" then
        return "1";
    elseif stateText == "待提交" then
        return "0";
    elseif stateText == "已作废" then
        return "98";
    else
        return "";
    end;
end;

--福利明细报销类型配置(预算载体)
JJBX_BudgetProcessType = {
    {name="全部",value="ALL"},
    {name="行程报销单",value=billTypeList_utils.xcbx},
    {name="行程申请单",value=billTypeList_utils.xcsq},
    {name="报账单",value=billTypeList_utils.bzd},
    {name="事项申请单",value=billTypeList_utils.sxsq},
    {name="系统内支付单",value=billTypeList_utils.xtnzf},
    {name="成本分摊单据",value=billTypeList_utils.cbft},
    {name="凭证单据",value=billTypeList_utils.pzdj},
    {name="差旅报销单",value=billTypeList_utils.clbx},
    {name="滴滴",value="DDLS"},
    {name="曹操",value="CCLS"},
    {name="携程",value="XCLS"},
    {name="同程",value="TCLS"},
    {name="阿里",value="ALI"},
    {name="京东-福利",value="JDLS"},
    {name="京东-对公",value="JDLSDG"},
    {name="E家银商城",value="STORE"},
    {name="E家银商城(非统一结算)",value="STOREC"},
    {name="饿了么-公务用餐",value="ELMBUS"},
    {name="饿了么-自由用餐",value="ELMOTHER"},
    {name="饿了么-生活补贴",value="ELMOTHERC"},
    {name="美团",value="MT"},
    {name="美团用餐申请单",value=billTypeList_utils.eatServer},
    {name="杭州口腔医院",value="ORAL"}
};

--发票字段列表
JJBX_InvoiceContentList = {
    {code="01",name="发票内容",tipMsg="请输入发票内容",tagName="fpnr"},
    {code="02",name="发票号码",tipMsg="请输入发票号码",tagName="fphm"},
    {code="03",name="发票代码",tipMsg="请输入发票代码",tagName="fpdm"},
    {code="04",name="发票净价",tipMsg="请输入发票净价",tagName="fpjj"},
    {code="05",name="发票税额",tipMsg="请输入发票税额",tagName="fpse"},
    {code="06",name="开票日期",tipMsg="请选择开票日期",tagName="kprq"},
    {code="07",name="抵扣类型",tipMsg="请选择抵扣类型",tagName="dklx"},
    {code="08",name="转出类型",tipMsg="请选择转出类型",tagName="zclx"},
    {code="09",name="转出税额",tipMsg="请输入转出税额",tagName="zcse"},
    {code="10",name="校验码",  tipMsg="请输入校验码",  tagName="jym"},
    {code="11",name="乘客姓名",tipMsg="请输入乘客姓名",tagName="ckxm"},
    {code="12",name="出发城市",tipMsg="请选择出发城市",tagName="cfcs"},
    {code="13",name="目的城市",tipMsg="请选择目的城市",tagName="mdcs"},
    {code="14",name="车次",    tipMsg="请输入车次",    tagName="cc"},
    {code="15",name="乘车日期",tipMsg="请输入乘车日期",tagName="ccrq"}
};

--招待事由
JJBX_SERVER_TYPE = {
    {code="ZDSY001",name="考察调研"},
    {code="ZDSY002",name="执行任务"},
    {code="ZDSY003",name="学习交流"},
    {code="ZDSY004",name="检查指导"},
    {code="ZDSY005",name="请示汇报"},
    {code="ZDSY006",name="商业谈判"},
    {code="ZDSY007",name="商业合作"}
};

--招待对象
JJBX_SERVER_OBJECT_TYPE = {
    {key="JDDX001",value="客户"},
    {key="JDDX002",value="同业"},
    {key="JDDX003",value="行内"},
    {key="JDDX004",value="党政军"},
    {key="JDDX005",value="其他"}
}