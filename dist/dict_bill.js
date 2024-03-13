const lua_bill_dict = require('./bill_dict');
lua_bill_dict = {};
billTypeList_utils = {
    xcbx: 'FIN-006-001',
    bzd: 'FIN-006-002',
    sxsq: 'FIN-006-003',
    jk: 'FIN-006-004',
    hk: 'FIN-006-005',
    yfksq: 'FIN-006-006',
    yfkzf: 'FIN-006-007',
    xtnzf: 'FIN-006-008',
    cbft: 'FIN-006-009',
    byjsq: 'FIN-006-010',
    pzdj: 'FIN-006-011',
    xcsq: 'FIN-006-012',
    ycsq: 'FIN-006-013',
    cgsq: 'FIN-006-014',
    tyjs: 'FIN-006-015',
    clbx: 'FIN-006-016',
    flcg: 'FIN-006-017',
    eatServer: 'FIN-006-019',
    kkd: 'FIN-006-021',
    cgsq_new: 'FIN-006-022',
    xcsp: 'FIN-006-023',
    sxjs: 'FIN-006-025',
    zybzd: 'FIN-006-026'
};
billNameList_utils = { jk: '借垫款单' };
bill_no2type = function (billNo) {
    var billNo = formatNull(billNo);
    if (billNo != '') {
        billNo = string.sub(billNo, 1, 3);
        if (billNo === 'BSL') {
            return billTypeList_utils.xcbx;
        } else if (billNo === 'BFY') {
            return billTypeList_utils.bzd;
        } else if (billNo === 'SSX') {
            return billTypeList_utils.sxsq;
        } else if (billNo === 'BJK') {
            return billTypeList_utils.jk;
        } else if (billNo === 'BHK') {
            return billTypeList_utils.hk;
        } else if (billNo === 'ZYF') {
            return billTypeList_utils.yfksq;
        } else if (billNo === 'BYF') {
            return billTypeList_utils.yfkzf;
        } else if (billNo === 'ZXT') {
            return billTypeList_utils.xtnzf;
        } else if (billNo === 'ZCB') {
            return billTypeList_utils.cbft;
        } else if (billNo === 'ZBY') {
            return billTypeList_utils.byjsq;
        } else if (billNo === 'ZPZ') {
            return billTypeList_utils.pzdj;
        } else if (billNo === 'SSL') {
            return billTypeList_utils.xcsq;
        } else if (billNo === 'CAR') {
            return billTypeList_utils.ycsq;
        } else if (billNo === 'SCG') {
            return billTypeList_utils.cgsq;
        } else if (billNo === 'TAC') {
            return billTypeList_utils.tyjs;
        } else if (billNo === 'BCL') {
            return billTypeList_utils.clbx;
        } else if (billNo === 'SYC') {
            return billTypeList_utils.eatServer;
        } else if (billNo === 'ZSK') {
            return billTypeList_utils.kkd;
        } else if (billNo === 'CGD') {
            return billTypeList_utils.cgsq_new;
        } else if (billNo === 'ZXC') {
            return billTypeList_utils.xcsp;
        } else if (billNo === 'SJS') {
            return billTypeList_utils.sxjs;
        } else {
            return '';
        }
    } else {
        alert('单据号为空');
        return '';
    }
};
fileCodeList_utils = {
    ywlx: 'FIN-001',
    szxm: 'FIN-002',
    xmda: 'FIN-003',
    fplx: 'FIN-004',
    zclx: 'FIN-005',
    djlx: 'FIN-006',
    km: 'FIN-007',
    jxskm: 'FIN-008',
    lsbzda: 'FIN-009',
    bxcj: 'FIN-010',
    jsfslx: 'FIN-011',
    qxlx: 'FIN-012',
    sqlx: 'FIN-013',
    jkfs: 'FIN-014',
    hkfs: 'FIN-015',
    zjgckm: 'FIN-016',
    zjff: 'FIN-017',
    qyskzh: 'FIN-018',
    ftlx: 'FIN-019',
    yfklx: 'FIN-020'
};
lua_bill_dict.billCode_to_billName = function (billCode) {
    if (billCode === billTypeList_utils.xcbx) {
        return '行程报销单';
    } else if (billCode === billTypeList_utils.bzd) {
        return '报账单';
    } else if (billCode === billTypeList_utils.sxsq) {
        return '事项申请单';
    } else if (billCode === billTypeList_utils.jk) {
        return '借垫款单';
    } else if (billCode === billTypeList_utils.hk) {
        return '还款单';
    } else if (billCode === billTypeList_utils.yfksq) {
        return '应付款申请单';
    } else if (billCode === billTypeList_utils.yfkzf) {
        return '应付款支付单';
    } else if (billCode === billTypeList_utils.xtnzf) {
        return '系统内支付单';
    } else if (billCode === billTypeList_utils.cbft) {
        return '成本分摊单';
    } else if (billCode === billTypeList_utils.byjsq) {
        return '备用金申请单';
    } else if (billCode === billTypeList_utils.pzdj) {
        return '凭证单据';
    } else if (billCode === billTypeList_utils.xcsq) {
        return '行程申请单';
    } else if (billCode === billTypeList_utils.ycsq) {
        return '用车申请单';
    } else if (billCode === billTypeList_utils.cgsq) {
        return '采购申请单';
    } else if (billCode === billTypeList_utils.tyjs) {
        return '统一结算单';
    } else if (billCode === billTypeList_utils.clbx) {
        return '差旅报销单';
    } else if (billCode === billTypeList_utils.flcg) {
        return '福利采购单';
    } else if (billCode === billTypeList_utils.eatServer) {
        return '用餐申请单';
    } else if (billCode === billTypeList_utils.kkd) {
        return '统一收款单';
    } else if (billCode === billTypeList_utils.cgsq_new) {
        return '新采购申请单';
    } else if (billCode === billTypeList_utils.xcsp) {
        return '薪酬审批单';
    } else if (billCode === billTypeList_utils.sxjs) {
        return '事项调整单';
    } else if (billCode === billTypeList_utils.zybzd) {
        return '专业报账单';
    } else {
        return '';
    }
};
bill_config = {
    level1: {
        xcbx: {
            djh: 'text,djh',
            zdrq: 'date,zdrq',
            zdr: 'text,zdr',
            zdrgs: 'text,ssjg',
            zdrbm: 'text,ssbm',
            djje: 'text,hjje,orange',
            jsfs: 'text,zffs',
            ysfphjj: 'text,ysfphj,orange',
            sy: 'text,bxsm',
            fjzs: 'text,fjzs',
            lsje: 'text,lsje,orange,jjbx_relevance_serial()',
            fjzsFlag: 'fjzsFlag,fjzsFlag',
            scanSequenceNo: 'text,scanSequenceNo',
            billSource: 'text,billSource'
        },
        bzd: {
            djh: 'text,djh',
            zdrgs: 'text,ssjg',
            zdr: 'text,zdr',
            zdrq: 'date,zdrq',
            zdrbm: 'text,ssbm',
            fjzs: 'text,fjzs',
            djje: 'text,hjje,orange',
            lsje: 'text,lsje,orange,jjbx_relevance_serial()',
            byzd: 'text,byzd',
            fjzsFlag: 'fjzsFlag,fjzsFlag',
            zdy: 'text,zdy',
            scanSequenceNo: 'text,scanSequenceNo',
            billSource: 'text,billSource'
        },
        zybzd: {
            djh: 'text,djh',
            zdrgs: 'text,ssjg',
            zdr: 'text,zdr',
            zdrq: 'date,zdrq',
            zdrbm: 'text,ssbm',
            fjzs: 'text,fjzs',
            djje: 'text,hjje,orange',
            lsje: 'text,lsje,orange,jjbx_relevance_serial()',
            byzd: 'text,byzd',
            fjzsFlag: 'fjzsFlag,fjzsFlag',
            zdy: 'text,zdy',
            scanSequenceNo: 'text,scanSequenceNo',
            billSource: 'text,billSource'
        },
        sxsq: {
            djh: 'text,djh',
            zdrgs: 'text,ssjg',
            zdr: 'text,zdr',
            zdrq: 'date,zdrq',
            zdrbm: 'text,ssbm',
            djje: 'text,hjje,orange',
            sqlx: 'text,sqlx',
            sy: 'text,bxsm',
            sfjj: 'bool,sfjj',
            fjzs: 'text,fjzs',
            fjzsFlag: 'fjzsFlag,fjzsFlag',
            scanSequenceNo: 'text,scanSequenceNo',
            billSource: 'text,billSource',
            sfsp_div: 'text,sfsp',
            billSource: 'text,billSource'
        },
        jk: {
            djh: 'text,djh',
            zdr: 'text,zdr',
            zdrgs: 'text,ssjg',
            zdrbm: 'text,ssbm',
            zdrq: 'date,zdrq',
            djje: 'text,hjje,orange',
            sfjj: 'bool,sfjj',
            fjzs: 'text,fjzs',
            fjzsFlag: 'fjzsFlag,fjzsFlag',
            zdy: 'text,zdy',
            scanSequenceNo: 'text,scanSequenceNo',
            billSource: 'text,billSource',
            billSource: 'text,billSource'
        },
        hk: {
            djh: 'text,djh',
            zdr: 'text,zdr',
            zdrgs: 'text,ssjg',
            zdrbm: 'text,ssbm',
            zdrq: 'date,zdrq',
            djje: 'text,hjje,orange',
            fjzs: 'text,fjzs',
            fjzsFlag: 'fjzsFlag,fjzsFlag',
            zdy: 'text,zdy',
            scanSequenceNo: 'text,scanSequenceNo',
            billSource: 'text,billSource',
            billSource: 'text,billSource'
        },
        yfksq: {
            djh: 'text,djh',
            zdrq: 'date,zdrq',
            zdr: 'text,zdr',
            zdrgs: 'text,ssjg',
            zdrbm: 'text,ssbm',
            djje: 'text,hjje,orange',
            fjzs: 'text,fjzs',
            fjzsFlag: 'fjzsFlag,fjzsFlag',
            zdy: 'text,zdy',
            scanSequenceNo: 'text,scanSequenceNo',
            billSource: 'text,billSource'
        },
        yfkzf: {
            bxdh: 'text,djh',
            zdrq: 'date,zdrq',
            zdr: 'text,zdr',
            ssjg: 'text,ssjg',
            ssbm: 'text,ssbm',
            hjje: 'text,hjje,orange',
            fjzs: 'text,fjzs',
            fjzsFlag: 'fjzsFlag,fjzsFlag',
            sfjj: 'bool,sfjj',
            bxsm: 'text,bxsm',
            scanSequenceNo: 'text,scanSequenceNo',
            billSource: 'text,billSource'
        },
        xtnzf: {
            djh: 'text,djh',
            zdr: 'text,zdr',
            zdrgs: 'text,ssjg',
            zdrbm: 'text,ssbm',
            zdrq: 'date,zdrq',
            djje: 'text,hjje,orange',
            fjzs: 'text,fjzs',
            fjzsFlag: 'fjzsFlag,fjzsFlag',
            zdy: 'text,zdy',
            scanSequenceNo: 'text,scanSequenceNo',
            billSource: 'text,billSource'
        },
        cbft: {
            djh: 'text,djh',
            zdr: 'text,zdr',
            zdrgs: 'text,ssjg',
            zdrbm: 'text,ssbm',
            zdrq: 'date,zdrq',
            djje: 'text,hjje,orange',
            sy: 'text,bxsm',
            fjzs: 'text,fjzs',
            lsje: 'text,lsje,orange,jjbx_relevance_serial()',
            fpje: 'text,fphj,orange',
            fjzsFlag: 'fjzsFlag,fjzsFlag',
            scanSequenceNo: 'text,scanSequenceNo',
            billSource: 'text,billSource'
        },
        byjsq: {
            sy: 'text,bxsm',
            djh: 'text,djh',
            zdr: 'text,zdr',
            zdrgs: 'text,ssjg',
            zdrbm: 'text,ssbm',
            zdrq: 'date,zdrq',
            fjzs: 'text,fjzs',
            djje: 'text,hjje,orange',
            fjzsFlag: 'fjzsFlag,fjzsFlag',
            scanSequenceNo: 'text,scanSequenceNo',
            billSource: 'text,billSource'
        },
        pzdj: {
            djh: 'text,djh',
            zdr: 'text,zdr',
            zdrgs: 'text,ssjg',
            zdrbm: 'text,ssbm',
            zdrq: 'date,zdrq',
            djje: 'text,hjje,orange',
            fjzs: 'text,fjzs',
            pzlx: 'text,sqlx',
            gldjh: 'text,gldjh',
            lsje: 'text,lsje,orange,jjbx_relevance_serial()',
            byjhjje: 'text,byjhj,orange',
            fphjje: 'text,fphj,orange',
            fjzsFlag: 'fjzsFlag,fjzsFlag',
            zdy: 'text,zdy',
            scanSequenceNo: 'text,scanSequenceNo',
            billSource: 'text,billSource',
            billSource: 'text,billSource'
        },
        xcsq: {
            djh: 'text,tripappno',
            zdr: 'text,createuser',
            zdrgs: 'text,corpName',
            zdrbm: 'text,deptName',
            zdrq: 'date,createdate',
            sy: 'text,abs',
            xclx: 'text,triptypeName',
            xmda: 'text,item',
            bxdh: 'text,travelReimbursementNo',
            ygje: 'text,costestimate,orange',
            ywlx: 'text,serviceType',
            zdy: 'text,zdy',
            billSource: 'text,billSource'
        },
        ycsq: {
            djzt: 'text,billstatus',
            ycsfwf: 'bool,ifwf',
            djh: 'text,tripappno',
            ycycsj: 'ycsj,usecartime',
            zdr: 'text,createUser',
            zdrgs: 'text,corpname',
            zdrq: 'text,createDate',
            zdrbm: 'text,deptname',
            sy: 'text,reason',
            xmda: 'text,item',
            yccx: 'cartype,cartype',
            yccs: 'text,didicity',
            ycsfdjc: 'bool,callcarflag',
            yccfdd: 'text,locationstart',
            ycmddd: 'text,locationend',
            yxqend: 'text,diditripdate',
            billSource: 'text,billSource'
        },
        cgsq: {
            djzt: 'text',
            djh: 'text,purchaseNo',
            zdr: 'text,createuser',
            zdrgs: 'text,corpname',
            sy: 'text,purchasereason',
            xmda: 'text,item',
            cdr: 'text,chengdanren',
            cdrbm: 'text,chengdanbumen',
            zdrbm: 'text,deptname',
            zdrq: 'text,createdate',
            yxqend: 'text,expDate',
            cghjje: 'text',
            zdy: 'text,zdy',
            billSource: 'text,billSource'
        },
        tyjs: {
            djh: 'text,djh',
            zdr: 'text,zdr',
            zdrgs: 'text,ssjg',
            zdrq: 'date,zdrq',
            djje: 'text,hjje,orange',
            fphjje: 'text,fphj,orange',
            sy: 'text,bxsm',
            fjzs: 'text,fjzs',
            fjzsFlag: 'fjzsFlag,fjzsFlag',
            jszq: 'text,cfcs',
            sjly: 'text,mdcs',
            scanSequenceNo: 'text,scanSequenceNo',
            billSource: 'text,billSource'
        },
        clbx: {
            djh: 'text,djh',
            zdr: 'text,zdr',
            zdrgs: 'text,ssjg',
            zdrbm: 'text,ssbm',
            zdrq: 'date,zdrq',
            djje: 'text,hjje,orange',
            sy: 'text,bxsm',
            fjzs: 'text,fjzs',
            cfrq: 'date,cfrq',
            fcrq: 'date,fcrq',
            cfcs: 'text,cfcs',
            mdcs: 'text,mdcs',
            lsje: 'text,lsje,orange,jjbx_relevance_serial()',
            fjzsFlag: 'fjzsFlag,fjzsFlag',
            scanSequenceNo: 'text,scanSequenceNo',
            billSource: 'text,billSource'
        },
        flcg: {
            djh: 'text,djh',
            zdr: 'text,zdr',
            zdrgs: 'text,zdrgs',
            sy: 'text,sy',
            xmda: 'text,xmda',
            cdr: 'text,cdr',
            cdrbm: 'text,cdrbm',
            billSource: 'text,billSource'
        },
        eatServer: {
            djzt: 'djzt,djzt',
            djh: 'text,djh',
            zdrq: 'date,createTime',
            zdr: 'text,zdr',
            zdrgs: 'text,ssjg',
            zdrbm: 'text,ssbm',
            djje: 'text,hjje,orange',
            fjzs: 'text,fjzs',
            qyskzh: 'text,qyskzh',
            sy: 'text,bz',
            cdr: 'text,cdr',
            cdrbm: 'text,cdbm',
            ycsy_div: 'text,bxsm',
            ycrq_div: 'eatServiceTime,xcrqed',
            sqje_div: 'text,hjje,orange',
            ywcj_div: 'text,bxcj',
            yclx_div: 'yclx,sfzc',
            kycs_div: 'text,zdrt',
            szxm_div: 'text,szxm',
            xmda_div: 'text,xmda',
            ywlx_div: 'text,ywlx',
            sykycs_div: 'text,sjcxts',
            sykyje_div: 'text,btje2',
            rjcb_div: 'rjcb,btje3',
            ycrs_div: 'text,zcsl',
            yczd_div: 'text,sqlx',
            billSource: 'text,billSource'
        },
        kkd: {
            djh: 'text,djh',
            zdr: 'text,zdr',
            zdrgs: 'text,ssjg',
            zdrbm: 'text,ssbm',
            zdrq: 'date,zdrq',
            djje: 'text,hjje,orange',
            fjzs: 'text,fjzs',
            bxsm: 'text,bxsm',
            sqlxbm: 'text,sqlxbm',
            sqlx: 'text,sqlx',
            fjzsFlag: 'fjzsFlag,fjzsFlag',
            scanSequenceNo: 'text,scanSequenceNo',
            billSource: 'text,billSource'
        },
        cgsq_new: {
            djzt: 'text',
            djh: 'text,djh',
            zdr: 'text,zdr',
            ssjg: 'text,ssjg',
            cgsy: 'text,bxsm',
            cdr: 'text',
            cdbm: 'text',
            ssbm: 'text,ssbm',
            zdrq: 'date,zdrq',
            cghjje: 'text,hjje,orange',
            cgzd: 'text,sqlx',
            billSource: 'text,billSource'
        },
        xcsp: {
            djh: 'text,djh',
            zdr: 'text,zdr',
            zdrgs: 'text,ssjg',
            zdrbm: 'text,ssbm',
            zdrq: 'date,zdrq',
            djje: 'text,hjje,orange',
            fjzs: 'text,fjzs',
            pzlx: 'text,sqlx',
            gldjh: 'text,gldjh',
            lsje: 'text,lsje,orange,jjbx_relevance_serial()',
            byjhjje: 'text,byjhj,orange',
            fphjje: 'text,fphj,orange',
            fjzsFlag: 'fjzsFlag,fjzsFlag',
            zdy: 'text,zdy',
            scanSequenceNo: 'text,scanSequenceNo',
            billSource: 'text,billSource'
        },
        sxjs: {
            djh: 'text,djh',
            zdrgs: 'text,ssjg',
            zdr: 'text,zdr',
            zdrq: 'date,zdrq',
            zdrbm: 'text,ssbm',
            djje: 'text,hjje,orange',
            sqlx: 'text,sqlx',
            sy: 'text,bxsm',
            sfjj: 'bool,sfjj',
            fjzs: 'text,fjzs',
            fjzsFlag: 'fjzsFlag,fjzsFlag',
            gldjh: 'text,gldjh,blue,jjbx_to_sxsqDetail()',
            billSource: 'text,billSource',
            scanSequenceNo: 'text,scanSequenceNo'
        }
    }
};
bill_statecode2text = function (stateCode) {
    if (stateCode === '0') {
        return '待提交';
    } else if (stateCode === '1') {
        return '已提交';
    } else if (stateCode === '2') {
        return '审批中';
    } else if (stateCode === '3') {
        return '审批通过';
    } else if (stateCode === '4') {
        return '审批失败';
    } else if (stateCode === '98') {
        return '已作废';
    } else {
        return '其他';
    }
};
bill_statetext2code = function (stateText) {
    if (stateText === '审批通过' || stateText === '审批完成') {
        return '3';
    } else if (stateText === '审批失败') {
        return '4';
    } else if (stateText === '审批中') {
        return '2';
    } else if (stateText === '已提交') {
        return '1';
    } else if (stateText === '待提交') {
        return '0';
    } else if (stateText === '已作废') {
        return '98';
    } else {
        return '';
    }
};
JJBX_BudgetProcessType = [
    {
        name: '全部',
        value: 'ALL'
    },
    {
        name: '行程报销单',
        value: billTypeList_utils.xcbx
    },
    {
        name: '行程申请单',
        value: billTypeList_utils.xcsq
    },
    {
        name: '报账单',
        value: billTypeList_utils.bzd
    },
    {
        name: '事项申请单',
        value: billTypeList_utils.sxsq
    },
    {
        name: '系统内支付单',
        value: billTypeList_utils.xtnzf
    },
    {
        name: '成本分摊单据',
        value: billTypeList_utils.cbft
    },
    {
        name: '凭证单据',
        value: billTypeList_utils.pzdj
    },
    {
        name: '差旅报销单',
        value: billTypeList_utils.clbx
    },
    {
        name: '滴滴',
        value: 'DDLS'
    },
    {
        name: '曹操',
        value: 'CCLS'
    },
    {
        name: '携程',
        value: 'XCLS'
    },
    {
        name: '同程',
        value: 'TCLS'
    },
    {
        name: '阿里',
        value: 'ALI'
    },
    {
        name: '京东-福利',
        value: 'JDLS'
    },
    {
        name: '京东-对公',
        value: 'JDLSDG'
    },
    {
        name: 'E家银商城',
        value: 'STORE'
    },
    {
        name: 'E家银商城(非统一结算)',
        value: 'STOREC'
    },
    {
        name: '饿了么-公务用餐',
        value: 'ELMBUS'
    },
    {
        name: '饿了么-自由用餐',
        value: 'ELMOTHER'
    },
    {
        name: '饿了么-生活补贴',
        value: 'ELMOTHERC'
    },
    {
        name: '美团',
        value: 'MT'
    },
    {
        name: '美团用餐申请单',
        value: billTypeList_utils.eatServer
    },
    {
        name: '杭州口腔医院',
        value: 'ORAL'
    }
];
JJBX_InvoiceContentList = [
    {
        code: '01',
        name: '发票内容',
        tipMsg: '请输入发票内容',
        tagName: 'fpnr'
    },
    {
        code: '02',
        name: '发票号码',
        tipMsg: '请输入发票号码',
        tagName: 'fphm'
    },
    {
        code: '03',
        name: '发票代码',
        tipMsg: '请输入发票代码',
        tagName: 'fpdm'
    },
    {
        code: '04',
        name: '发票净价',
        tipMsg: '请输入发票净价',
        tagName: 'fpjj'
    },
    {
        code: '05',
        name: '发票税额',
        tipMsg: '请输入发票税额',
        tagName: 'fpse'
    },
    {
        code: '06',
        name: '开票日期',
        tipMsg: '请选择开票日期',
        tagName: 'kprq'
    },
    {
        code: '07',
        name: '抵扣类型',
        tipMsg: '请选择抵扣类型',
        tagName: 'dklx'
    },
    {
        code: '08',
        name: '转出类型',
        tipMsg: '请选择转出类型',
        tagName: 'zclx'
    },
    {
        code: '09',
        name: '转出税额',
        tipMsg: '请输入转出税额',
        tagName: 'zcse'
    },
    {
        code: '10',
        name: '校验码',
        tipMsg: '请输入校验码',
        tagName: 'jym'
    },
    {
        code: '11',
        name: '乘客姓名',
        tipMsg: '请输入乘客姓名',
        tagName: 'ckxm'
    },
    {
        code: '12',
        name: '出发城市',
        tipMsg: '请选择出发城市',
        tagName: 'cfcs'
    },
    {
        code: '13',
        name: '目的城市',
        tipMsg: '请选择目的城市',
        tagName: 'mdcs'
    },
    {
        code: '14',
        name: '车次',
        tipMsg: '请输入车次',
        tagName: 'cc'
    },
    {
        code: '15',
        name: '乘车日期',
        tipMsg: '请输入乘车日期',
        tagName: 'ccrq'
    }
];
JJBX_SERVER_TYPE = [
    {
        code: 'ZDSY001',
        name: '考察调研'
    },
    {
        code: 'ZDSY002',
        name: '执行任务'
    },
    {
        code: 'ZDSY003',
        name: '学习交流'
    },
    {
        code: 'ZDSY004',
        name: '检查指导'
    },
    {
        code: 'ZDSY005',
        name: '请示汇报'
    },
    {
        code: 'ZDSY006',
        name: '商业谈判'
    },
    {
        code: 'ZDSY007',
        name: '商业合作'
    }
];
JJBX_SERVER_OBJECT_TYPE = [
    {
        key: 'JDDX001',
        value: '客户'
    },
    {
        key: 'JDDX002',
        value: '同业'
    },
    {
        key: 'JDDX003',
        value: '行内'
    },
    {
        key: 'JDDX004',
        value: '党政军'
    },
    {
        key: 'JDDX005',
        value: '其他'
    }
];
module.exports = { lua_bill_dict: lua_bill_dict };