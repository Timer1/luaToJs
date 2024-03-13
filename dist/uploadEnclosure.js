uploadEnclosure = function (Arg) {
    var editFlag = vt('editFlag', Arg, 'YES');
    if (vt('ifApprover', Arg, 'false') === 'true') {
        if (vt('approverEditFlag', Arg, 'false') === 'true') {
            editFlag = 'YES';
        } else {
            editFlag = 'NO';
        }
    }
    var picrotatefunction = 'lua_upload.pic_rotate';
    if (vt('billType', Arg) === 'zffw') {
        picrotatefunction = '';
    }
    var upfunction = '';
    var sortfunction = '';
    var delfunction = '';
    if (editFlag === 'YES') {
        upfunction = 'lua_menu.alert_upload_enclosure_menu';
        sortfunction = 'lua_upload.sort_enclosure';
        delfunction = 'lua_upload.del_pic_enclosure';
    } else if (editFlag === 'NO') {
        upfunction = '';
        sortfunction = '';
        delfunction = '';
    }
    var height = vt('height', Arg, '300');
    var rowCount = vt('rowCount', Arg, '3');
    var maxCount = vt('maxCount', Arg, '50');
    var uploadCount = vt('uploadCount', Arg, '5');
    var PCConfigListsTable = vt('PCConfigListsTable', globalTable);
    var IMG0015 = vt('IMG0015', PCConfigListsTable);
    var waterMarkValue = '';
    if (IMG0015 === '是') {
        var nowTime = os.time();
        var nowDate = os.date('%Y-%m-%d', nowTime);
        var workID = globalTable['workid'];
        var unitname = globalTable['selectOrgList'][1]['unitname'];
        waterMarkValue = unitname + (' ' + (nowDate + (' ' + workID)));
    }
    var html = '[[\n        <!-- 附件上传控件 -->\n        <div class="uploadEnclosure_div" name="uploadEnclosure_div" border="0">\n            <uploadEnclosure name="uploadEnclosure" delfunction="]]' + (delfunction + ('[[" picrotatefunction="]]' + (picrotatefunction + ('[[" sortfunction="]]' + (sortfunction + ('[[" upfunction="]]' + (upfunction + ('[[" height="]]' + (height + ('[[" rowCount="]]' + (rowCount + ('[[" maxCount="]]' + (maxCount + ('[[" uploadCount="]]' + (uploadCount + ('[[" class="uploadEnclosure_widget" border="0" value="" waterMarkValue="]]' + (waterMarkValue + '[[" waterMarkColor="#8B8B8B"></uploadEnclosure>\n        </div>\n    ]]')))))))))))))))));
    return html;
};
module.exports = { uploadEnclosure: uploadEnclosure };