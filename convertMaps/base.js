'use strict'
const utils = require('./utils');

// Chunk：表示整个Lua程序。
// Block：表示一个代码块，通常由多个语句组成。
// FunctionCall：表示函数调用。
// Identifier：表示标识符。



function chunk(luaAst,convertLuaToJs){
    return{
        type: 'Program',
        body: luaAst.body.map(convertLuaToJs),
    };
}


function identifier(luaAst,convertLuaToJs){
    return{
        type: 'Identifier',
        name: utils.funcMaps.has(luaAst.name)? utils.funcMaps.get(luaAst.name): luaAst.name,
    };
}

function tableValue(luaAst,convertLuaToJs){
    return {
        type: 'ObjectExpression',
        properties: convertLuaToJs(luaAst.value),
    };
}

function moduleExportHandler(luaAst){
    // console.log(luaAst.body[0]);
    var exportModule = {
        type: 'ExpressionStatement',
        expression: {
            type: 'AssignmentExpression',
            operator: '=',
            left: {
                type: 'MemberExpression',
                object: {
                    type: 'Identifier',
                    name: 'module',
                },
                property: {
                    type: 'Identifier',
                    name: 'exports',
                },
                computed: false,
            },
            right: {
                type: 'ObjectExpression',
                properties: [{
                    type: 'Property',
                    key: luaAst.body[0].expression.left,
                    value: luaAst.body[0].expression.left,
                    kind: 'init',
                    computed: false,
                    method: false,
                    shorthand: false,
                }]
            }
        }
    }
    luaAst.body.push(exportModule);
    return luaAst;
}

function moduleImportHandler(luaAst,f){
    // console.log(f);
    var requireList = [];
    traverse(luaAst,requireList,f);
    // console.log(requireList);

    var requireNodes = [];

    requireList.forEach(arg => requireNodes.push(
        {
            type: 'VariableDeclaration',
            declarations: [{
                type: 'VariableDeclarator',
                id: {
                    type: 'Identifier',
                    name: 'lua_'+arg,
                },
                init: {
                    type: 'CallExpression',
                    callee: {
                        type: 'Identifier',
                        name: 'require',
                    },
                    arguments: [{
                        type: 'Literal',
                        value: './'+arg,
                    }],
                },
            }],
            kind: 'const',
        }
    ));

    console.log(requireList);
    luaAst.body.unshift(...requireNodes);
    return luaAst;
}

function traverse(node,requireList,f){
    if (node && typeof node === 'object') {
        // console.log(`Visiting node type: ${node.type}`);
        if (node.type === 'Identifier' && node.name.includes('lua_') && !node.name.includes(f)){
            if(!requireList.includes(node.name.replace('lua_',''))){
                requireList.push(node.name.replace('lua_',''));
            }
        }
        // 遍历节点的属性
        for (const key in node) {
          if (node.hasOwnProperty(key)) {
            const childNode = node[key];
            // 递归遍历子节点
            if (Array.isArray(childNode)) {
              childNode.forEach(child => traverse(child,requireList,f));
            } else {
              traverse(childNode,requireList,f);
            }
          }
        }
    }
}

module.exports = {
    chunk,
    identifier,
    tableValue,
    moduleExportHandler,
    moduleImportHandler,
};


