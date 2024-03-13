const lua_code = require('./code');
slt2 = {};
include_fold = function (template, start_tag, end_tag, fold_func, init_func) {
    var result = init_func();
    start_tag = start_tag || '#{';
    end_tag = end_tag || '}#';
    var start_tag_inc = start_tag + 'include:';
    var start1 = string.find(template, start_tag_inc, 1, true), end1 = string.find(template, start_tag_inc, 1, true);
    var start2 = null;
    var end2 = 0;
    while (start1 != null) {
        if (start1 > end2 + 1) {
            result = fold_func(result, string.sub(template, end2 + 1, start1 - 1));
        }
        start2 = string.find(template, end_tag, end1 + 1, true);
        assert(start2, 'end tag "' + (end_tag + '" missing'));
        {
            var filename = assert(loadstring('return ' + string.sub(template, end1 + 1, start2 - 1)))();
            assert(filename);
            var fin = assert(io.open(filename));
            result = fold_func(result, include_fold(fin.read('*a'), start_tag, end_tag, fold_func, init_func), filename);
            fin.close();
        }
        start1 = string.find(template, start_tag_inc, end2 + 1, true);
    }
    result = fold_func(result, string.sub(template, end2 + 1));
    return result;
};
slt2.precompile = function (template, start_tag, end_tag) {
    return table.concat(include_fold(template, start_tag, end_tag, function (acc, v) {
        if (type(v) === 'string') {
            table.insert(acc, v);
        } else if (type(v) === 'table') {
            table.insert(acc, table.concat(v));
        } else {
            error('Unknown type: ' + type(v));
        }
        return acc;
    }, function () {
        return {};
    }));
};
stable_uniq = function (t) {
    var existed = {};
    var res = {};
    for (var [_, v] in ipairs(t)) {
        if (!existed[v]) {
            table.insert(res, v);
            existed[v] = true;
        }
    }
    return res;
};
slt2.get_dependency = function (template, start_tag, end_tag) {
    return stable_uniq(include_fold(template, start_tag, end_tag, function (acc, v, name) {
        if (type(v) === 'string') {
        } else if (type(v) === 'table') {
            if (name != null) {
                table.insert(acc, name);
            }
            for (var [_, subname] in ipairs(v)) {
                table.insert(acc, subname);
            }
        } else {
            error('Unknown type: ' + type(v));
        }
        return acc;
    }, function () {
        return {};
    }));
};
slt2.loadstring = function (template, start_tag, end_tag, tmpl_name) {
    var lua_code = {};
    start_tag = start_tag || '#{';
    end_tag = end_tag || '}#';
    var output_func = 'coroutine.yield';
    template = slt2.precompile(template, start_tag, end_tag);
    var start1 = string.find(template, start_tag, 1, true), end1 = string.find(template, start_tag, 1, true);
    var start2 = null;
    var end2 = 0;
    var cEqual = string.byte('=', 1);
    while (start1 != null) {
        if (start1 > end2 + 1) {
            table.insert(lua_code, output_func + ('(' + (string.format('%q', string.sub(template, end2 + 1, start1 - 1)) + ')')));
        }
        start2 = string.find(template, end_tag, end1 + 1, true);
        assert(start2, 'end_tag "' + (end_tag + '" missing'));
        if (string.byte(template, end1 + 1) === cEqual) {
            table.insert(lua_code, output_func + ('(' + (string.sub(template, end1 + 2, start2 - 1) + ')')));
        } else {
            table.insert(lua_code, string.sub(template, end1 + 1, start2 - 1));
        }
        start1 = string.find(template, start_tag, end2 + 1, true);
    }
    table.insert(lua_code, output_func + ('(' + (string.format('%q', string.sub(template, end2 + 1)) + ')')));
    var ret = { name: tmpl_name || '=(slt2.loadstring)' };
    if (setfenv === null) {
        ret.code = table.concat(lua_code, '\\n');
    } else {
        ret.code = assert(loadstring(table.concat(lua_code, '\\n'), ret.name));
    }
    return ret;
};
getfile = function (filename) {
    var path = 'name=' + utility.escapeURI('channels/' + filename);
    var page = ryt.post(null, 'page_s/get_page', path, null, null, true);
    return page;
};
slt2.loadfile = function (filename, start_tag, end_tag) {
    var t;
    if (file.isExist(filename) != true) {
        t = getfile(filename);
    } else {
        t = file.read(filename, 'text');
    }
    return slt2.loadstring(t);
};
var mt52 = { __index: _ENV };
var mt51 = { __index: _G };
slt2.render_co = function (t, env) {
    var f;
    if (setfenv === null) {
        if (env != null) {
            setmetatable(env, mt52);
        }
        f = assert(load(t.code, t.name, 't', env || _ENV));
    } else {
        if (env != null) {
            setmetatable(env, mt51);
        }
        f = setfenv(t.code, env || _G);
    }
    return f;
};
slt2.render = function (t, env) {
    var result = {};
    var co = coroutine.create(slt2.render_co(t, env));
    while (coroutine.status(co) != 'dead') {
        var ok = coroutine.resume(co), chunk = coroutine.resume(co);
        if (!ok) {
            close_loading();
            error(chunk);
        }
        table.insert(result, chunk);
    }
    return table.concat(result);
};
escapeHTML = function (str) {
    var tt = {
        '<': '&lt;',
        '>': '&gt;'
    };
    str = string.gsub(str, '&', '&amp;');
    str = string.gsub(str, '[<>]', tt);
    return str;
};
slt2.renderfile = function (filename, paramsTable) {
    var file = slt2.loadfile(filename);
    var render_file = slt2.render(file, paramsTable);
    return render_file;
};
module.exports = { slt2: slt2 };