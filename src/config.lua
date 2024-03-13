--[[
    项目配置参数
    ·声明的系统配置变量以"C_"开头
    ·声明的业务配置变量以"JJBX_"开头
]]

--系统缓存，生命周期为应用启动到应用关闭
if appTable == nil then
    appTable = {};
end;
--配置缓存，生命周期为应用当次连接服务器到断开连接或重连（用于存储服务端配置信息）
configTable = {};
--系统缓存，生命周期为应用当次连接服务器到断开连接或重连（用于存储存储当前客户端安装生命周期内不会变更的信息）
systemTable = {};
--公司缓存，生命周期为用户当次登录且未切换机构（用于存储一些和登录机构相关联的信息，避免重复查询），退出登录或切换机构后清空
companyTable = {};
--全局缓存，生命周期为用户当次登录（用于存储当前用户业务缓存信息），退出登录后清空
globalTable = {};
--页面缓存，生命周期为应用当次连接服务器到断开连接或重连（用于存储当前页面携带的参数，可以自定义传参）
pageinfoTable = {};

--免密登录
C_NoPwdLogin = "true";

--屏幕基准宽高
C_screenBaseWidth=375;
C_screenBaseHeight=667;

--[[
    noraregular控件：
    ·2个以下（包含2个）字符时，宽度使用长宽度
    ·2个以上字符时，宽度使用短宽度
]]
C_noraregular_ShortWidth = 12;
C_noraregular_LongWidth = 11;

--[[
    高度适配
]]
--页面头部基准高度
C_TopHeight = 45;
--iPhone头部比基准高度差值
C_iPhone_TopHeightDiff = 20;
--Android头部比基准高度差值
C_Android_TopHeightDiff = 0;

--iPhoneX比其他iPhone头部和底部多一部分，这部分是在客户端里固定配置的，此处需要同步配置
--头部固定高度
C_iPX_SpecialtopHeight = 16;
--底部固定高度
C_iPX_SpecialbottomHeight = 23;

--iPhone大屏设备类型
C_iPhonePlusDevices = "iPhone6 Plus,iPhone6s Plus,iPhone7 Plus,iPhone8 Plus";

--定时器延时的累加时间，通过定时器实现延时操作时，需要自行实现初始化累加操作
C_TimerInitDalayedSec = 0;

--[[配置公司的业务启用权限和报错信息，首页使用到]]
--首页采购权限提示
onlineShoppingCheckMsg = "您暂无在线采购功能，请联系管理员";

--用车服务
carServiceFlag = "disenable";
--首页提示
carServiceCheckMsg = "您暂未被分配用车出行功能，请联系管理员。";

--用餐服务
eatServiceFlag = "disenable";
--首页提示
eatServiceCheckMsg = "您暂无用餐服务功能，请联系管理员";
--用餐首页，公务用餐提示
OBeatServiceFlag = "disenable";
OBeatServiceCheckMsg = "您暂无公务用餐权限，请联系管理员";
--用餐首页，自由用餐提示
OtherEatServiceFlag = "disenable";
OtherEatServiceCheckMsg = "您暂无自由用餐权限，请联系管理员";
--用餐首页，自由用餐2提示
OtherEat2ServiceFlag = "disenable";
OtherEat2ServiceCheckMsg = "您暂无自由用餐2权限，请联系管理员";
--用餐首页，自由用餐3提示
OtherEat3ServiceFlag = "disenable";
OtherEat3ServiceCheckMsg = "您暂无自由用餐3权限，请联系管理员";

--报销申请
processBillFlag = "disenable";
--首页提示
processBillCheckMsg = "您暂无报销申请功能，请联系管理员";

--消息中心权限
MsgCenterFlag = "disenable";

--杭口医院权限
HKHospitalFlag = "disenable";
HKHospitalCheckMsg = "您暂无杭口医院服务功能，请联系管理员";

--租房服务权限
RenatalHourseFlag = "disenable";
RenatalHourseCheckMsg = "您暂无租房服务功能，请联系管理员";

--商旅
travelServiceFlag = "disenable";
--首页提示
travelServiceCheckMsg = "您暂无商旅服务功能，请联系管理员";
--商旅预订无渠道提示
ApplyTravelChannelCheckMsg = "公司未启用商旅预订功能";
--商旅首页，携程提示
ApplyTravelChannelXieChengCheckMsg = "公司未启用携程预订";
--商旅首页，同程提示
ApplyTravelChannelTongchengCheckMsg = "公司未启用同程预订";
--商旅首页，阿里提示
ApplyTravelChannelALiCheckMsg = "公司未启用阿里预订"

--定义搜索内容前的文字
C_SearchContextBegin = "请输入";
--定义搜索内容前的默认文字
C_SearchKeyWords = "关键字";
--定义搜索内容后的文字
C_SearchContextEnd = "搜索";

--短信验证码发送间隔
C_SMS_Interval = 90;

--设备绑定上限个数
C_Bind_Device_Max_Counts = 5;

--审批流显示条目数，大于该条目时进行折叠，给空默认不折叠
C_Operate_Show_Counts = 3;

--弹窗缺省信息配置
C_Default_Title_Msg = "温馨提示";
C_Default_Alert_Msg = "无信息";

--Toast消息内容
C_Toast_DefaultMsg   = "无信息";
C_Toast_SuccessedMsg = "操作成功";
C_Toast_FailedMsg    = "操作失败";
C_Ocr_FailedMsg      = "未识别";
C_RevoketMsg         = "已撤回";
C_RejectMsg          = "已驳回";
C_ApprovalMsg        = "已批准";
C_SavedMsg           = "已保存";
C_AddMsg             = "已添加";
C_DeleteMsg          = "已删除";
C_CommitMsg          = "已提交";
C_CancelMsg          = "已取消";
C_EditMsg            = "已编辑";
C_CopyMsg            = "已复制";
C_SetMsg             = "已设置";
C_ModifyMsg          = "已修改";
C_RelatedMsg         = "已关联";
C_InputtedMsg        = "已录入";
C_UploadedMsg        = "已上传";
C_CoveredMsg         = "已覆盖";
C_OpenedMsg          = "已开启";
C_ClosedMsg          = "已关闭";
C_PaidMsg            = "已支付";
C_NoneMsg            = "无记录";

--单据页面金额不为空时配置的显示文字
C_ShowAmountMsg = "请查看";

--[[
    客户端上传文件单个请求分包尺寸
    Android单线程，iOS多线程，参数实测如下
    切割尺寸为 40kb
      ·Android 1M流完整上传动作时间为10秒
      ·iPhone  1M流完整上传动作时间为 2秒
]]
C_ClientUploadSplitSize_Android = "40";
C_ClientUploadSplitSize_iPhone = "40";

--上传文件的尺寸限制kb（iPhone和Android折算基准不一致）
C_UploadMaxKbSize_Android = "10240";
C_UploadMaxKbSize_iPhone = "10000";
C_UploadMaxTipMsg = "单个文件不能大于10M";

--弹窗控件容器复选框默认状态，0不勾选，1勾选
C_CheckBoxMsgDefaultStatus = "0";
--弹窗控件弹出标识
msg_popup_status = "close";

--菜单弹出标识
menu_alert_status = "close";

--发票类型数据
C_invoiceTypeList = {
    {dataCode="0110", dataName="电票"},
    {dataCode="011001", dataName="电票（客运服务）"},
    {dataCode="0114", dataName="电票（征税通行费）"},
    {dataCode="0120", dataName="其他电票"},
    {dataCode="0121", dataName="其他电票（客运服务）"}
};

--app可以通过webview控件预览的文件类型
C_AppH5ViewFileTypeList = "pdf,xls,xlsx,doc,docx,ppt,pptx";

--配置的上传默认提示
C_UploadDefaultCountsTip = "已上传0个";

--机器人审核标志
RobotCheckFlag = "1";

--单据申请承担人参数列表
JJBX_BillApplyCdrParams = {
    --姓名
    feeTakerName = "",
    --工号
    feeTakerCode = "",
    --主键
    feeTakerPk = "",
    --部门
    feeTakerDeptName = "",
    --部门编码
    feeTakerDeptCode = "",
    --部门主键
    feeTakerDeptPk = ""
};

--共享人场景编码
JJBX_SharePeopleSecneCode = {
    --京东采购
    zxcg = "BUY",
    --京东个人采购1
    jd_grcg1 = "BUY01",
    jd_grcg2 = "BUY02",

    --E家银采购
    ejyshop = "EJYSHOPPING",

    --用餐服务（饿了么，美团）
    ycfw = "ELM,MT",
    --饿了么自由用餐
    ele_zyyc1 = "ELM01",
    ele_zyyc2 = "ELM02",
    ele_zyyc3 = "ELM03",

    --用车出行
    yccx = "YC",

    --口腔医院
    hkHospital = "HK",
    --口腔医院场景1
    hkRule1 = "HK01"
};

--支付宝登录重复授权 PC:以PC返回数据为依据; 不配置，每次都会调取授权；
JJBX_AliPayLoginRepeatAuth = "";

--系统lua配置
C_SYSTEM_LUA_INFO = {
    --客户端方法

    --支付宝授权
    ryt_relate_auth_manager = {
        FuncName = "ryt:relate_auth_manager"
    },
    --神策登录
    picker_sensorsAnalyticsLogin = {
        FuncName = "picker:sensorsAnalyticsLogin"
    },
    --神策数据埋点
    picker_sensorsAnalyticsPointTrack = {
        FuncName = "picker:sensorsAnalyticsPointTrack"
    },
    --打开相机拍摄视频
    picker_open_camera_shoot = {
        FuncName = "picker:open_camera_shoot"
    },
    --打开相册选择视频
    picker_open_album_video = {
        FuncName = "picker:open_album_video"
    },
    --模板管理
    BillModuleManagement = {
        FuncName = "BillModuleManagement"
    },
    --读取剪贴板内容
    RYTL_readPasteTargetStr = {
        FuncName = "RYTL:readPasteTargetStr"
    },
    --获取推送注册token
    RYTL_get_push_token = {
        FuncName = "RYTL:get_push_token"
    },
    --打开系统设置界面
    RYTL_open_system_settings = {
        FuncName = "RYTL:openSystemSettings"
    },
    --安卓检测相机权限
    RYTL_checkCamera = {
        FuncName = "RYTL:checkCamera"
    },
    --启动手机银行
    RYTL_open_bank_to_annuity = {
        FuncName = "RYTL:openBankToAnnuity"
    },
    --打开摄像头扫码
    picker_open_scan_by_camera = {
        FuncName = "picker:open_scan_by_camera"
    },

    --客户端列表

    --反馈列表
    feedback_list = {
        FuncName = "feedback_list"
    },
    --用餐申请单列表
    EatServiceBusinessApplyList = {
        FuncName = "EatServiceBusinessApplyList"
    },
    --用餐申请单可用列表
    EatServiceBusinessUseList = {
        FuncName = "EatServiceBusinessUseList"
    },
    --用餐订单列表
    EatServiceOrderList = {
        FuncName = "EatServiceOrderList"
    },
    --发票列表
    InvoiceList = {
        FuncName = "InvoiceList"
    },
    --单据通用列表(关联核销，关联在建工程)
    ProcessBillInfoList = {
        FuncName = "ProcessBillInfoList"
    },
    --安卓指纹功能
    ESand_checkStatusFinger = {
        FuncName = "eSand:checkStatusFinger"
    }
};

--公司信息
JJBX_COMPANY_INFO = {
    service_number="0571-87659199",
    service_mail="jjbxfw@czbank.com"
}; 

--帮助功能配置
JJBX_ASK_PERMISSION_INFO = {
    {
        FuncAbb="xxzx",
        FuncName="消息中心",
        FuncCode="ba02"
    },
    {
        FuncAbb="wdrw",
        FuncName="我的任务",
        FuncCode="ba03"
    },
    {
        FuncAbb="wdsq",
        FuncName="我的申请",
        FuncCode="ba04"
    },
    {
        FuncAbb="yhkgl",
        FuncName="银行卡管理",
        FuncCode="ba05"
    },
    {
        FuncAbb="grxx",
        FuncName="个人信息",
        FuncCode="ba06"
    },
    {
        FuncAbb="xyz",
        FuncName="信用值",
        FuncCode="ba07"
    },
    {
        FuncAbb="yszc",
        FuncName="隐私政策",
        FuncCode="ba08"
    },
    {
        FuncAbb="xjcx",
        FuncName="薪金查询",
        FuncCode="bb02"
    },
    {
        FuncAbb="grys",
        FuncName="个人预算",
        FuncCode="bb03"
    },
    {
        FuncAbb="fpc",
        FuncName="发票池",
        FuncCode="bb04"
    },
    {
        FuncAbb="skd",
        FuncName="收款单",
        FuncCode="bb05"
    },
    {
        FuncAbb="xfls",
        FuncName="消费流水",
        FuncCode="bb06"
    },
    {
        FuncAbb="jkqr",
        FuncName="缴款确认",
        FuncCode="bb07"
    },
    {
        FuncAbb="kpxx",
        FuncName="开票信息",
        FuncCode="bb08"
    },
    {
        FuncAbb="bxsq",
        FuncName="报销申请",
        FuncCode="bb01",
        QryFlag="2"
    },
    {
        FuncAbb="slfw",
        FuncName="商旅服务",
        FuncCode="bc01",
        QryFlag="3"
    },
    {
        FuncAbb="zxcg",
        FuncName="在线采购",
        FuncCode="bc02",
        QryFlag="4"
    },
    {
        FuncAbb="yccx",
        FuncName="用车出行",
        FuncCode="bc04",
        QryFlag="5"
    },
    {
        FuncAbb="ycfw",
        FuncName="用餐服务",
        FuncCode="bc03",
        QryFlag="6"
    }
};

--页面信息配置（部分页面没有标题，或者标题信息不能明显区分页面，这里作补全配置）
JJBX_PAGE_INFO = {
    {
        Name="应用首页",
        Path="jjbx_index/xhtml/jjbx_index.xhtml",
    },
    {
        Name="我的页面",
        Path="jjbx_myInfo/xhtml/myInfo.xhtml",
    },
    {
        Name="密码登录",
        Path="jjbx_login/xhtml/jjbx_login.xhtml",
    },
    {
        Name="手机号登录",
        Path="jjbx_login/xhtml/jjbx_mobileLogin.xhtml",
    },
    {
        Name="TouchID登录",
        Path="jjbx_login/xhtml/jjbx_touchIDLogin.xhtml",
    },
    {
        Name="FaceID登录",
        Path="jjbx_login/xhtml/jjbx_faceIDLogin.xhtml",
    },
    {
        Name="手势密码登录",
        Path="jjbx_login/xhtml/jjbx_gestureLogin.xhtml",
    },
    {
        Name="我的申请",
        Path="jjbx_index/xhtml/jjbx_myAsk.xhtml",
    },
    {
        Name="用餐申请已失效列表",
        Path="jjbx_eat_service/apply_invalid_record_list.xhtml",
    },
    {
        Name="发票池待报销列表",
        Path="jjbx_fpc/xhtml/jjbx_invoiceList_dbx.xhtml",
    },
    {
        Name="发票池已报销列表",
        Path="jjbx_fpc/xhtml/jjbx_invoiceList_ybx.xhtml",
    },
    {
        Name="我的任务",
        Path="jjbx_index/xhtml/jjbx_approvedItems.xhtml",
    },
    {
        Name="关联资产信息",
        Path="jjbx_proccess_reimbursement_bill/xhtml/reimbursement_bill_asset_list.xhtml",
    },
    {
        Name="关联发票",
        Path="jjbx_proccess_reimbursement_bill/xhtml/reimbursement_bill_invoice_list.xhtml",
    },
    {
        Name="关联事项申请单",
        Path="jjbx_proccess_reimbursement_bill/xhtml/reimbursement_bill_items_apply.xhtml",
    },
    {
        Name="关联流水",
        Path="jjbx_proccess_reimbursement_bill/xhtml/reimbursement_bill_serial_list.xhtml",
    },
    {
        Name="还款单关联借垫款单",
        Path="jjbx_proccess_repayment_bill/xhtml/repayment_bill_relatedJKD.xhtml",
    },
    {
        Name="关联核销单",
        Path="jjbx_process_bill/xhtml/process_bill_glhx.xhtml",
    },
    {
        Name="已关联核销单列表",
        Path="jjbx_process_bill/xhtml/process_bill_glhx_list.xhtml",
    },
    {
        Name="已关联核销单列表查看",
        Path="jjbx_process_bill/xhtml/process_bill_glhx_list_look.xhtml",
    },
    {
        Name="关联在建工程",
        Path="jjbx_process_bill/xhtml/process_bill_glzjgc.xhtml",
    },
    {
        Name="已关联在建工程列表",
        Path="jjbx_process_bill/xhtml/process_bill_glzjgc_list.xhtml",
    },
    {
        Name="已关联在建工程列表查看",
        Path="jjbx_process_bill/xhtml/process_bill_glzjgc_list_look.xhtml",
    },
    {
        Name="选择转办对象",
        Path="jjbx_process_bill/xhtml/process_bill_transfer_zbr.xhtml",
    },
    {
        Name="借款单关联事项申请单列表",
        Path="jjbx_process_borrow_bill/xhtml/borrow_bill_glsxlist.xhtml",
    },
    {
        Name="商旅酒店列表",
        Path="jjbx_travel_hotel/xhtml/travel_service_hotel_index.xhtml",
    },
    {
        Name="商旅发起报销",
        Path="jjbx_travel_reimbursement/xhtml/travel_service_reimbursement_myOrder.xhtml",
    },
    {
        Name="商旅选择出行人",
        Path="jjbx_travel_service/xhtml/travel_service_cxr.xhtml",
    },
    {
        Name="商旅我的报销列表",
        Path="jjbx_travel_service/xhtml/travel_service_my_process.xhtml",
    },
    {
        Name="商旅我的申请列表",
        Path="jjbx_travel_service/xhtml/travel_service_my_travel.xhtml",
    }
};
