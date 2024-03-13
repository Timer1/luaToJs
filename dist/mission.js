const lua_system = require('./system');
const lua_jjbx = require('./jjbx');
lua_mission = {};
var mission_init_status = 'ready';
index_mission_list = [
    {
        missionName: '处理客户端登记的任务',
        missionFun: 'lua_index_mission.deal_client_register_mission',
        missionStatus: mission_init_status,
        missionNeedLogin: 'false',
        missionFinish: 'AC'
    },
    {
        missionName: '引导页展示分析',
        missionFun: 'lua_index_mission.analysis_show_lead',
        missionStatus: mission_init_status,
        missionNeedLogin: 'true',
        missionFinish: 'AC'
    },
    {
        missionName: '信用权益说明展示分析',
        missionFun: 'lua_index_mission.analysis_show_credit_explain',
        missionStatus: mission_init_status,
        missionNeedLogin: 'true',
        missionFinish: 'AC'
    },
    {
        missionName: '参与单据评价分析',
        missionFun: 'lua_index_mission.analysis_show_bill_evaluation',
        missionStatus: mission_init_status,
        missionNeedLogin: 'true',
        missionFinish: 'AC'
    },
    {
        missionName: '发布收款业务确认消息',
        missionFun: 'lua_index_mission.analysis_show_confirm_collection',
        missionStatus: mission_init_status,
        missionNeedLogin: 'true',
        missionFinish: 'AC'
    },
    {
        missionName: '发布消息提示分析',
        missionFun: 'lua_index_mission.analysis_show_msg',
        missionStatus: mission_init_status,
        missionNeedLogin: 'true',
        missionFinish: 'MC'
    }
];
lua_mission.index_debug = function () {
    var res = '';
    var IndexMissionConfigDebugFlag = 'false';
    var IndexMissionUserSetDebugFlag = formatNull(globalTable['IndexMissionUserSetDebugFlag']);
    if (formatNull(IndexMissionUserSetDebugFlag, IndexMissionConfigDebugFlag) === 'true') {
        res = 'true';
    } else {
        res = 'false';
    }
    return res;
};
lua_mission.index_handle = function () {
    var debug_alert_msg = '';
    if (lua_mission.index_debug() === 'true') {
        var FinishIndex = formatNull(globalTable['IndexPageMissionIndex']);
        if (FinishIndex != '') {
            debug_alert_msg = '关闭\\n' + ('\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\\n' + ('任务编号 : ' + (FinishIndex + ('\\n' + ''))));
        }
    }
    if (globalTable['IndexPageMissionIndex'] != null) {
        lua_mission.index_finish(globalTable['IndexPageMissionIndex'], 'AC');
        globalTable['IndexPageMissionIndex'] = null;
    }
    var missionAlertMsg = '';
    for (var [missionIndex, mission] in pairs(index_mission_list)) {
        var mission = formatNull(mission);
        if (mission === '') {
            debug_alert('读取任务配置错误');
        } else {
            var missionName = vt('missionName', mission);
            var missionStatus = vt('missionStatus', mission);
            var missionFun = vt('missionFun', mission);
            var missionFinish = vt('missionFinish', mission);
            var missionNeedLogin = vt('missionNeedLogin', mission);
            if (missionStatus === 'ready') {
                if (lua_mission.index_debug() === 'true') {
                    debug_alert_msg = debug_alert_msg + ('\\n' + ('调用\\n' + ('\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\uFF0D\\n' + ('调用时间 : ' + (os.time() + ('\\n' + ('调用编号 : ' + (missionIndex + ('\\n' + ('任务名称 : ' + (missionName + ('\\n' + ('任务状态 : ' + (missionStatus + ('\\n' + ('任务函数 : ' + (missionFun + ('\\n' + ('完成方式 : ' + (missionFinish + ('\\n' + '')))))))))))))))))))));
                    if (globalTable['IndexMissionShowDebugMsg'] === 'true') {
                        debug_alert(debug_alert_msg);
                    }
                }
                var PkUserNow = vt('PkUser', globalTable);
                var DoMission = 'true';
                if (missionNeedLogin === 'true') {
                    if (PkUserNow != '') {
                        DoMission = 'true';
                    } else {
                        DoMission = 'false';
                    }
                } else {
                    DoMission = 'true';
                }
                if (DoMission === 'true') {
                    globalTable['IndexPageMissionIndex'] = missionIndex;
                    lua_system.do_function(missionFun, mission);
                    break;
                } else {
                }
            } else {
            }
        }
    }
    if (companyTable['ArgInitAfterLoginFlag'] != 'true' && PkUserNow != '') {
        lua_jjbx.arg_init_after_login();
    } else {
        close_loading();
    }
};
lua_mission.index_finish = function (missionIndex, finishStyle) {
    var finishStyle = formatNull(finishStyle, 'AC');
    var missionIndex = parseFloat(formatNull(missionIndex, '-1'));
    if (missionIndex < 0) {
    } else {
        var missionObj = formatNull(index_mission_list[missionIndex]);
        if (missionObj != '') {
            var missionFinish = formatNull(missionObj['missionFinish']);
            if (missionFinish === 'AC') {
                lua_mission.index_set('finish', missionIndex);
            } else if (missionFinish === 'MC') {
                if (finishStyle === 'MC') {
                    lua_mission.index_set('finish', missionIndex);
                } else {
                }
            } else {
            }
        } else {
            debug_alert('读取任务配置错误');
        }
    }
};
lua_mission.index_set = function (status, index) {
    var status = formatNull(status);
    var index = formatNull(index);
    var missionStatus = '';
    if (status === 'ready') {
        missionStatus = 'ready';
    } else if (status === 'finish') {
        missionStatus = 'finish';
    }
    if (missionStatus != '') {
        if (index === '') {
            for (var [missionIndex, mission] in pairs(index_mission_list)) {
                var mission = formatNull(mission);
                if (mission === '') {
                    debug_alert('读取任务配置错误');
                } else {
                    index_mission_list[missionIndex] = {
                        missionFun: vt('missionFun', mission),
                        missionName: vt('missionName', mission),
                        missionNeedLogin: vt('missionNeedLogin', mission),
                        missionFinish: vt('missionFinish', mission),
                        missionStatus: missionStatus
                    };
                }
            }
        } else {
            var setMission = formatNull(index_mission_list[index]);
            if (setMission === '') {
                debug_alert('读取任务配置错误');
            } else {
                index_mission_list[index] = {
                    missionFun: formatNull(index_mission_list[index]['missionFun']),
                    missionName: formatNull(index_mission_list[index]['missionName']),
                    missionNeedLogin: formatNull(index_mission_list[index]['missionNeedLogin']),
                    missionFinish: formatNull(index_mission_list[index]['missionFinish']),
                    missionStatus: missionStatus
                };
            }
        }
    }
};
lua_mission.clear_app_register_mission = function (Arg) {
    var ClearMsg = vt('ClearMsg', Arg);
    set_db_value('ClientRegisterMissionArg', '');
};
module.exports = { lua_mission: lua_mission };