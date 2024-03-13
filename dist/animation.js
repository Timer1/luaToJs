const lua_format = require('./format');
const lua_system = require('./system');
lua_animation = {};
AnimationFlg = 'left';
lua_animation.register = function (arg) {
    var RunTime = parseFloat(formatNull(arg['RunTime'], '0.3'));
    var RepeatCounts = parseFloat(formatNull(arg['RepeatCounts'], '1'));
    var AnimationStyle = formatNull(arg['AnimationStyle']);
    var MoveDistanceX = parseFloat(formatNull(arg['MoveDistanceX'], '0'));
    var MoveDistanceY = parseFloat(formatNull(arg['MoveDistanceY'], '0'));
    var AnimationTag = formatNull(arg['AnimationTag']);
    var AnimationElementName = formatNull(arg['AnimationElementName']);
    var AnimationElementPackName = formatNull(arg['AnimationElementPackName']);
    var AnimationLocationUpdate = formatNull(arg['AnimationLocationUpdate'], 'false');
    var AnimationStartLoading = formatNull(arg['AnimationStartLoading'], 'false');
    var AnimationStopLoading = formatNull(arg['AnimationStopLoading'], 'false');
    var AnimationStartCallFuncName = formatNull(arg['AnimationStartCallFuncName'], 'lua_animation.default_start_call');
    var AnimationStopCallFuncName = formatNull(arg['AnimationStopCallFuncName'], 'lua_animation.default_stop_call');
    if (AnimationElementName != '') {
        var AnimationElementObj = document.getElementsByName(AnimationElementName)[1];
        var register_debug_msg = '动画注册\\n' + ('运行时间 : ' + (RunTime + ('\\n' + ('运行次数 : ' + (RepeatCounts + ('\\n' + ('动画类型 : ' + (AnimationStyle + ('\\n' + ('横轴移动 : ' + (MoveDistanceX + ('\\n' + ('纵轴移动 : ' + (MoveDistanceY + ('\\n' + ('动画标记 : ' + (AnimationTag + ('\\n' + ('开始回调 : ' + (AnimationStartCallFuncName + ('\\n' + ('结束回调 : ' + (AnimationStopCallFuncName + ('\\n' + ('开始加载 : ' + (AnimationStartLoading + ('\\n' + ('结束加载 : ' + (AnimationStopLoading + ('\\n' + ('容器控件 : ' + (AnimationElementPackName + ('\\n' + ('动画控件 : ' + (AnimationElementName + ('\\n' + ('位置更新 : ' + (AnimationLocationUpdate + ('\\n' + '')))))))))))))))))))))))))))))))))))))));
        transition.setStartListener(AnimationElementObj, lua_format.str2fun(AnimationStartCallFuncName));
        transition.setStopListener(AnimationElementObj, lua_format.str2fun(AnimationStopCallFuncName));
        transition.setRepeatCount(AnimationElementObj, RepeatCounts);
        globalTable['AnimationArg'] = arg;
        if (AnimationStyle === 'X') {
            transition.translateX(AnimationElementObj, MoveDistanceX, RunTime);
        } else if (AnimationStyle === 'Y') {
            transition.translateY(AnimationElementObj, MoveDistanceY, RunTime);
        } else if (AnimationStyle === 'XY') {
        } else if (AnimationStyle === 'Alpha') {
        } else {
            debug_alert('不支持的动画类型');
        }
        return 'true';
    } else {
        debug_alert('动画注册失败');
        return 'error';
    }
};
lua_animation.default_start_call = function () {
    lua_animation.do_call('start');
};
lua_animation.default_stop_call = function () {
    lua_animation.do_call('stop');
};
lua_animation.loading = function (ActFlag, StartLoading, StopLoading) {
    var UseLoading = 'false';
    if (ActFlag === 'start') {
        UseLoading = StartLoading;
    } else {
        UseLoading = StopLoading;
    }
    var loading_debug_msg = '动画loading处理\\n' + ('参数-动画类型 : ' + (ActFlag + ('\\n' + ('参数-开始loading : ' + (StartLoading + ('\\n' + ('参数-结束loading : ' + (StopLoading + ('\\n' + ('\\n' + ('执行loading : ' + (UseLoading + ('\\n' + '')))))))))))));
    if (UseLoading === 'true') {
        show_loading();
    } else {
        close_loading();
    }
};
lua_animation.do_call = function (actflag) {
    globalTable['AnimationActFlag'] = actflag;
    var AnimationArg = formatNull(globalTable['AnimationArg']);
    if (AnimationArg != '') {
        var AnimationActFlag = actflag;
        var AnimationTag = formatNull(AnimationArg['AnimationTag']);
        var AnimationStartLoading = formatNull(AnimationArg['AnimationStartLoading'], 'false');
        var AnimationStopLoading = formatNull(AnimationArg['AnimationStopLoading'], 'false');
        var AnimationLocationUpdate = formatNull(AnimationArg['AnimationLocationUpdate'], 'false');
        var AnimationStyle = formatNull(AnimationArg['AnimationStyle'], 'false');
        var MoveDistanceX = parseFloat(formatNull(AnimationArg['MoveDistanceX'], '0'));
        var MoveDistanceY = parseFloat(formatNull(AnimationArg['MoveDistanceY'], '0'));
        var AnimationElementName = formatNull(AnimationArg['AnimationElementName']);
        var AnimationElementPackName = formatNull(AnimationArg['AnimationElementPackName']);
        lua_animation.loading(AnimationActFlag, AnimationStartLoading, AnimationStopLoading);
        if (AnimationTag === 'BEGIN') {
        } else if (AnimationTag === 'END') {
            if (AnimationActFlag === 'stop' && AnimationElementPackName != '') {
                hide_ele(AnimationElementPackName);
            }
        } else {
            debug_alert('动画开始结束标记不正确');
            return;
        }
        if (AnimationActFlag === 'start') {
            lua_system.do_function(AnimationArg['AnimationStartFuncName'], AnimationArg['AnimationStartFuncArg']);
        } else if (AnimationActFlag === 'stop') {
            if (AnimationLocationUpdate === 'true') {
                var AnimationElementeleWidth = getEleLocation(AnimationElementName, 'width');
                var AnimationElementeleHeight = getEleLocation(AnimationElementName, 'height');
                var AnimationElementeleLeft = getEleLocation(AnimationElementName, 'left');
                var AnimationElementeleRight = getEleLocation(AnimationElementName, 'right');
                var AnimationElementeleTop = getEleLocation(AnimationElementName, 'top');
                var AnimationElementeleBottom = getEleLocation(AnimationElementName, 'bottom');
                var UpdateDistanceX = AnimationElementeleLeft + MoveDistanceX;
                var UpdateDistanceY = AnimationElementeleTop + MoveDistanceY;
                var move_debug_msg = '动画结束的回调处理\\n\\n' + ('原位置 : \\n' + ('宽/高 : ' + (AnimationElementeleWidth + ('/' + (AnimationElementeleHeight + ('\\n' + ('左/右 : ' + (AnimationElementeleLeft + ('/' + (AnimationElementeleRight + ('\\n' + ('上/下 : ' + (AnimationElementeleTop + ('/' + (AnimationElementeleBottom + ('\\n' + ('\\n' + ('移动距离 : \\n' + ('横轴 : ' + (MoveDistanceX + ('\\n' + ('纵轴 : ' + (MoveDistanceY + ('\\n' + ('\\n' + ('更新位置\\n' + ('横轴 : ' + (UpdateDistanceX + ('\\n' + ('纵轴 : ' + (UpdateDistanceY + ('\\n' + ''))))))))))))))))))))))))))))))));
                if (AnimationStyle === 'X') {
                    setEleLocation(AnimationElementName, 'left', UpdateDistanceX);
                } else if (AnimationStyle === 'Y') {
                    setEleLocation(AnimationElementName, 'top', UpdateDistanceY);
                } else {
                }
            }
            lua_system.do_function(AnimationArg['AnimationStopFuncName'], AnimationArg['AnimationStopFuncArg']);
        } else {
        }
    } else {
        debug_alert('动画参数为空');
    }
};
lua_animation.show_screen_page = function (containerName, widgetName, direction, businessCallFun, businessCallArg) {
    lua_animation.screen_page_ctrl(containerName, widgetName, direction, businessCallFun, businessCallArg, 'BEGIN');
};
lua_animation.hide_screen_page = function (containerName, widgetName, direction, businessCallFun, businessCallArg) {
    lua_animation.screen_page_ctrl(containerName, widgetName, direction, businessCallFun, businessCallArg, 'END');
};
lua_animation.screen_page_ctrl = function (containerName, widgetName, direction, businessCallFun, businessCallArg, animationTag) {
    var containerName = formatNull(containerName);
    var containerWidth = getEleLocation(containerName, 'width');
    var containerHeight = getEleLocation(containerName, 'height');
    var widgetName = formatNull(widgetName);
    var widgetWidth = getEleLocation(widgetName, 'width');
    var widgetHeight = getEleLocation(widgetName, 'height');
    var direction = formatNull(direction, 'right');
    var businessCallFun = formatNull(businessCallFun);
    var businessCallArg = formatNull(businessCallArg);
    var animationTag = formatNull(animationTag, 'BEGIN');
    var animationStopFuncName = 'lua_animation.screen_page_ctrl_sys_call';
    var animationStyle = '';
    if (direction === 'right' || direction === 'left') {
        animationStyle = 'X';
    } else if (direction === 'up' || direction === 'down') {
        animationStyle = 'Y';
    }
    var moveDistanceX = 0;
    var moveDistanceY = 0;
    if (animationTag === 'BEGIN' && direction === 'right') {
        moveDistanceX = 0 - widgetWidth;
    } else if (animationTag === 'BEGIN' && direction === 'left') {
        moveDistanceX = widgetWidth;
    } else if (animationTag === 'END' && direction === 'right') {
        moveDistanceX = widgetWidth;
    } else if (animationTag === 'END' && direction === 'left') {
        moveDistanceX = 0 - widgetWidth;
    } else if (animationTag === 'BEGIN' && direction === 'up') {
        moveDistanceY = widgetHeight;
    } else if (animationTag === 'BEGIN' && direction === 'down') {
        moveDistanceY = 0 - widgetHeight;
    } else if (animationTag === 'END' && direction === 'up') {
        moveDistanceY = 0 - widgetHeight;
    } else if (animationTag === 'END' && direction === 'down') {
        moveDistanceY = widgetHeight;
    } else {
        debug_alert('不支持的移动方位\\n' + ('animationTag : ' + (animationTag + ('\\n' + ('direction : ' + (direction + ('\\n' + '')))))));
        return;
    }
    var registerArg = {
        AnimationElementName: widgetName,
        AnimationElementPackName: containerName,
        AnimationStyle: animationStyle,
        MoveDistanceX: moveDistanceX,
        MoveDistanceY: moveDistanceY,
        AnimationTag: animationTag,
        AnimationStartLoading: 'true',
        AnimationStopLoading: 'false',
        AnimationLocationUpdate: 'true',
        AnimationStopFuncName: animationStopFuncName,
        AnimationStopFuncArg: {
            containerName: containerName,
            containerWidth: containerWidth,
            containerHeight: containerHeight,
            widgetName: widgetName,
            widgetWidth: widgetWidth,
            widgetHeight: widgetHeight,
            direction: direction,
            finishCallFun: businessCallFun,
            finishCallArg: businessCallArg,
            animationTag: animationTag,
            moveDistanceX: moveDistanceX,
            moveDistanceY: moveDistanceY
        }
    };
    var registerRes = lua_animation.register(registerArg);
    var ctrl_debug_msg = 'lua_animation.screen_page_ctrl\\n' + ('\\n' + ('input Arg\\n' + ('containerName : ' + (containerName + ('\\n' + ('widgetName : ' + (widgetName + ('\\n' + ('direction : ' + (direction + ('\\n' + ('businessCallFun : ' + (businessCallFun + ('\\n' + ('businessCallArg : ' + (businessCallArg + ('\\n' + ('animationTag : ' + (animationTag + ('\\n' + ('\\n' + ('register Arg' + (foreach_arg2print(registerArg) + '')))))))))))))))))))))));
    if (registerRes != 'error') {
        if (containerName != '' && animationTag === 'BEGIN') {
            show_ele(containerName);
        }
    }
    return registerRes;
};
lua_animation.screen_page_ctrl_sys_call = function (Arg) {
    var call_debug_msg = '';
    var containerName = formatNull(Arg['containerName']);
    var containerWidth = formatNull(Arg['containerWidth']);
    var containerHeight = formatNull(Arg['containerHeight']);
    var widgetName = formatNull(Arg['widgetName']);
    var widgetWidth = formatNull(Arg['widgetWidth']);
    var widgetHeight = formatNull(Arg['widgetHeight']);
    var parentWidget = getParentWidget(widgetName);
    var parentWidgetName = parentWidget.getPropertyByName('name');
    var parentWidgetWidth = getEleLocation(parentWidgetName, 'width');
    var parentWidgetHeight = getEleLocation(parentWidgetName, 'height');
    var direction = formatNull(Arg['direction']);
    var animationTag = formatNull(Arg['animationTag']);
    var moveDistanceX = formatNull(Arg['moveDistanceX']);
    var moveDistanceY = formatNull(Arg['moveDistanceY']);
    if (animationTag === 'END') {
        if (containerName != '' && widgetName != '') {
            if (direction === 'right') {
                var setRightPx = parentWidgetWidth;
                setEleLocation(widgetName, 'left', setRightPx);
                call_debug_msg = call_debug_msg + ('控件初始在右侧\uFF0C隐藏时将控件还原至屏幕右侧\uFF0C设置left值为父控件宽度' + (setRightPx + '\\n'));
            } else if (direction === 'left') {
                var setLeftPx = 0 - widgetWidth;
                setEleLocation(widgetName, 'left', setLeftPx);
                call_debug_msg = call_debug_msg + ('控件初始在左侧\uFF0C隐藏时将控件还原至屏幕左侧\uFF0C设置left值为-控件宽度' + (setLeftPx + '\\n'));
            } else if (direction === 'up') {
                var setTopPx = 0 - widgetHeight;
                setEleLocation(widgetName, 'top', setTopPx);
                call_debug_msg = call_debug_msg + ('控件初始在上方\uFF0C隐藏时将控件还原至上方\uFF0C设置top值为-控件高度:' + (setTopPx + '\\n'));
            } else if (direction === 'down') {
                var setTopPx = parentWidgetHeight;
                setEleLocation(widgetName, 'top', setTopPx);
                call_debug_msg = call_debug_msg + ('控件初始在下方\uFF0C隐藏时将控件还原至下方\uFF0C设置top值为父控件高度:' + (setTopPx + '\\n'));
            }
            if (containerName != '') {
                hide_ele(containerName);
            }
        }
    }
    if (finishCallFun != '') {
        lua_system.do_function(Arg['finishCallFun'], Arg['finishCallArg']);
    }
};
lua_animation.one_way_action = function (widgetName, moveDirection, moveDistance, businessCallFun, businessCallArg) {
    var widgetName = formatNull(widgetName);
    var moveDirection = formatNull(moveDirection);
    var moveDistance = formatNull(moveDistance);
    var businessCallFun = formatNull(businessCallFun);
    var businessCallArg = formatNull(businessCallArg);
    var registerArg = {
        AnimationElementName: widgetName,
        AnimationStyle: moveDirection,
        MoveDistanceX: moveDistance,
        AnimationTag: 'BEGIN',
        AnimationStartLoading: 'true',
        AnimationStopLoading: 'false',
        AnimationLocationUpdate: 'true',
        AnimationStopFuncName: 'lua_animation.one_way_sys_call',
        AnimationStopFuncArg: {
            finishCallFun: businessCallFun,
            finishCallArg: businessCallArg
        }
    };
    var registerRes = lua_animation.register(registerArg);
    if (registerRes != 'error') {
    }
};
lua_animation.one_way_sys_call = function (arg) {
    lua_system.do_function(arg['finishCallFun'], arg['finishCallArg']);
};
AniDragArgList = {
    drag_ctrl_ele1: {},
    drag_ctrl_ele2: {},
    drag_ctrl_ele3: {},
    drag_ctrl_ele4: {},
    drag_ctrl_ele5: {}
};
AniSetDragArg1 = {
    DragEleNames: 'drag_ctrl_ele1',
    DragCtrlName: 'drag_ctrl_ele1',
    DragCallFun: 'drag_ctrl_ele1_call',
    DragXStyleCtrl: '',
    DragYStyleCtrl: ''
};
AniSetDragArg2 = {
    DragEleNames: 'drag_ctrl_ele2',
    DragCtrlName: 'drag_ctrl_ele2',
    DragCallFun: 'drag_ctrl_ele2_call',
    DragXStyleCtrl: '',
    DragYStyleCtrl: ''
};
AniSetDragArg3 = {
    DragEleNames: 'drag_ctrl_ele3',
    DragCtrlName: 'drag_ctrl_ele3',
    DragCallFun: 'drag_ctrl_ele3_call',
    DragXStyleCtrl: '',
    DragYStyleCtrl: ''
};
AniSetDragArg4 = {
    DragEleNames: 'drag_ctrl_ele4',
    DragCtrlName: 'drag_ctrl_ele4',
    DragCallFun: 'drag_ctrl_ele4_call',
    DragXStyleCtrl: '',
    DragYStyleCtrl: ''
};
AniSetDragArg5 = {
    DragEleNames: 'drag_ctrl_ele5',
    DragCtrlName: 'drag_ctrl_ele5',
    DragCallFun: 'drag_ctrl_ele5_call',
    DragXStyleCtrl: '',
    DragYStyleCtrl: ''
};
lua_animation.set_drag_listener = function (Arg) {
    var DragEleNames = vt('DragEleNames', Arg);
    var DragEleList = splitUtils(DragEleNames, ',');
    var DragEleCounts = DragEleList.length;
    if (DragEleCounts <= 0) {
        debug_alert('未设置拖拽监听对象');
        return;
    }
    var DragCtrlName = vt('DragCtrlName', Arg);
    if (DragCtrlName === '') {
        debug_alert('未设置监听操作对象');
        return;
    }
    var DragXStyleCtrl = vt('DragXStyleCtrl', Arg);
    var DragYStyleCtrl = vt('DragYStyleCtrl', Arg);
    var DragCallFun = vt('DragCallFun', Arg);
    if (DragCallFun === '') {
        debug_alert('拖拽回调方法未指定');
        return;
    }
    if (DragCtrlName != '') {
        AniDragArgList[DragCtrlName] = {
            DragEleNames: DragEleNames,
            DragCtrlName: DragCtrlName,
            DragXStyleCtrl: DragXStyleCtrl,
            DragYStyleCtrl: DragYStyleCtrl,
            TotalMoveX: 0,
            TotalMoveY: 0,
            EleStartTop: getEleLocation(DragCtrlName, 'top'),
            EleStartLeft: getEleLocation(DragCtrlName, 'left'),
            EleHeight: getEleLocation(DragCtrlName, 'height'),
            Elewidth: getEleLocation(DragCtrlName, 'width'),
            MoveCounts: 0,
            ScreenHeight: systemTable['phoneInfo'].screenUseHeight,
            ScreenWidth: 375
        };
        for (let i = 1; DragEleCounts; i++) {
            gesture.setDragListener(document.getElementsByName(DragEleList[i])[1], lua_format.str2fun(DragCallFun));
        }
    } else {
        debug_alert('监听对象未指定');
    }
};
drag_ctrl_ele1_call = function (MoveArg) {
    drag_ctrl_ele_call('drag_ctrl_ele1', MoveArg);
};
drag_ctrl_ele2_call = function (MoveArg) {
    drag_ctrl_ele_call('drag_ctrl_ele2', MoveArg);
};
drag_ctrl_ele3_call = function (MoveArg) {
    drag_ctrl_ele_call('drag_ctrl_ele3', MoveArg);
};
drag_ctrl_ele4_call = function (MoveArg) {
    drag_ctrl_ele_call('drag_ctrl_ele4', MoveArg);
};
drag_ctrl_ele5_call = function (MoveArg) {
    drag_ctrl_ele_call('drag_ctrl_ele5', MoveArg);
};
drag_ctrl_ele_call = function (CtrlEleName, MoveArg) {
    var DragCtrlArg = vt(CtrlEleName, AniDragArgList);
    if (DragCtrlArg != '') {
        var EleArg = { CtrlEleName: CtrlEleName };
        lua_animation.ele_drag_call(MoveArg, EleArg);
    } else {
        debug_alert('未配置参数');
    }
};
lua_animation.ele_drag_call = function (MoveArg, EleArg) {
    var MoveArg = formatNull(MoveArg);
    var EleArg = formatNull(EleArg);
    var CtrlEleName = vt('CtrlEleName', EleArg);
    var AniDragArg = AniDragArgList[CtrlEleName];
    var NowMoveX = math.floor(parseFloat(vt('x', MoveArg) + 0.5));
    var NowMoveY = math.floor(parseFloat(vt('y', MoveArg) + 0.5));
    if (AniDragArg.EleStartLeft + AniDragArg.TotalMoveX + NowMoveX + AniDragArg.Elewidth > AniDragArg.ScreenWidth) {
    } else if (AniDragArg.EleStartLeft + AniDragArg.TotalMoveX + NowMoveX < 0) {
    } else {
        AniDragArg.TotalMoveX = NowMoveX + AniDragArg.TotalMoveX;
    }
    if (AniDragArg.EleStartTop + AniDragArg.TotalMoveY + NowMoveY + AniDragArg.EleHeight > AniDragArg.ScreenHeight - parseFloat(get_bottom_diff())) {
    } else if (AniDragArg.EleStartTop + AniDragArg.TotalMoveY + NowMoveY < 0 + parseFloat(get_top_diff())) {
    } else {
        AniDragArg.TotalMoveY = NowMoveY + AniDragArg.TotalMoveY;
    }
    var newLeft = AniDragArg.EleStartLeft + AniDragArg.TotalMoveX;
    if (AniDragArg.DragYStyleCtrl === 'CloseToLeft') {
        changeStyle(AniDragArg.DragCtrlName, 'left', '0');
    } else if (AniDragArg.DragYStyleCtrl === 'CloseToRight') {
        changeStyle(AniDragArg.DragCtrlName, 'right', '0');
    } else if (AniDragArg.DragYStyleCtrl === 'CloseToLeftOrRight') {
        changeStyle(AniDragArg.DragCtrlName, 'left', newLeft);
        if (newLeft < AniDragArg.ScreenWidth / 2) {
            changeStyle(AniDragArg.DragCtrlName, 'left', '0');
        } else {
            changeStyle(AniDragArg.DragCtrlName, 'right', '0');
        }
    } else {
        changeStyle(AniDragArg.DragCtrlName, 'left', newLeft);
    }
    var newTop = AniDragArg.EleStartTop + AniDragArg.TotalMoveY;
    if (AniDragArg.DragXStyleCtrl === 'CloseToTop') {
        changeStyle(AniDragArg.DragCtrlName, 'top', tostring(get_top_diff()));
    } else if (AniDragArg.DragXStyleCtrl === 'CloseToBottom') {
        changeStyle(AniDragArg.DragCtrlName, 'bottom', '0');
    } else if (AniDragArg.DragXStyleCtrl === 'CloseToTopOrBottom') {
        changeStyle(AniDragArg.DragCtrlName, 'top', newTop);
        if (newTop < (AniDragArg.ScreenHeight - get_top_diff()) / 2) {
            changeStyle(AniDragArg.DragCtrlName, 'top', tostring(get_top_diff()));
        } else {
            changeStyle(AniDragArg.DragCtrlName, 'bottom', '0');
        }
    } else {
        changeStyle(AniDragArg.DragCtrlName, 'top', newTop);
    }
    AniDragArg['EleEndTop'] = newTop;
    AniDragArg['EleEndLeft'] = newLeft;
    AniDragArgList[CtrlEleName] = AniDragArg;
};
lua_animation.start_X_loop_animation = function (Arg) {
    var AnimationElementName = vt('AnimationElementName', Arg);
    var AnimationPX = vt('AnimationPX', Arg, 0);
    if (vt('AnimationActFlag', globalTable) != 'start') {
        var MoveDistanceX = 0;
        if (AnimationFlg === 'left') {
            MoveDistanceX = -AnimationPX;
            AnimationFlg = 'right';
        } else {
            MoveDistanceX = AnimationPX;
            AnimationFlg = 'left';
        }
        var showarg = {
            AnimationElementName: AnimationElementName,
            RunTime: '0.3',
            RepeatCounts: '1',
            AnimationStyle: 'X',
            MoveDistanceX: MoveDistanceX,
            AnimationTag: 'BEGIN',
            AnimationStartLoading: 'false',
            AnimationStopLoading: 'false',
            AnimationLocationUpdate: 'true'
        };
        var registerRes = lua_animation.register(showarg);
        if (registerRes != 'error') {
        }
    }
};
module.exports = { lua_animation: lua_animation };