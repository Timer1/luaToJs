'use strict'
const utils = require('./utils');

// BinaryExpression：表示二元表达式，如加法、减法等。
// UnaryExpression：表示一元表达式，如取反、取负等。
// IndexExpression：表示表索引表达式。
// CallExpression
// TableConstructorExpression：表示表构造器，用于创建Lua中的表。
// MemberExpression
// LogicalExpression


function binaryExpression(luaAst,convertLuaToJs){
    return {
        type: 'BinaryExpression',
        operator: utils.operatorMaps.has(luaAst.operator)? utils.operatorMaps.get(luaAst.operator): luaAst.operator,
        left: convertLuaToJs(luaAst.left),
        right: convertLuaToJs(luaAst.right),
    };
}

function unaryExpression(luaAst,convertLuaToJs){
    if (luaAst.operator === '#'){
        return{
            type: 'MemberExpression',
            object: convertLuaToJs(luaAst.argument),
            property: {
                type: 'Identifier',
                name: 'length',
            },
            computed: false,    
        };
    }else{
        return {
            type: 'UnaryExpression',
            operator: utils.operatorMaps.has(luaAst.operator)? utils.operatorMaps.get(luaAst.operator): luaAst.operator,
            argument: convertLuaToJs(luaAst.argument),
        };
    }
}

function indexExpression(luaAst,convertLuaToJs){
    return {
        type:'MemberExpression',
        object:convertLuaToJs(luaAst.base),
        property:convertLuaToJs(luaAst.index),
        computed:true,
    };
}

function callExpression(luaAst,convertLuaToJs){
    return{
        type: 'CallExpression',
        callee:convertLuaToJs(luaAst.base),
        arguments:luaAst.arguments.map(arg => convertLuaToJs(arg)),
    };
}

function tableConstructorExpression(luaAst,convertLuaToJs){
    if(luaAst.fields[0] != null && luaAst.fields[0].type === 'TableValue'){
        return{
            type: 'ArrayExpression',
            elements: luaAst.fields.map(arg => convertLuaToJs(arg.value,convertLuaToJs)),
        };
    }else{
        return objectExpression(luaAst,convertLuaToJs);
    }
    // properties: luaAst.fields.map(field => {
    //     if(field.type === 'TableKeyString'){
    //         return{
    //             type: 'Property',
    //             key: convertLuaToJs(field.key),
    //             value: convertLuaToJs(field.value),
    //             kind: 'init',
    //         };
    //     }
    //     return convertLuaToJs(field);
    // }).filter(Boolean),
}

function memberExpression(luaAst,convertLuaToJs){
    return{
        type:'MemberExpression',
        object: convertLuaToJs(luaAst.base),
        property: convertLuaToJs(luaAst.identifier),
        computed:false,
    };
}

function logicalExpression(luaAst,convertLuaToJs){
    return{
        type: 'LogicalExpression',
        operator: utils.operatorMaps.has(luaAst.operator)? utils.operatorMaps.get(luaAst.operator): luaAst.operator,
        left: convertLuaToJs(luaAst.left),
        right: convertLuaToJs(luaAst.right),
    };
}

function arrayExpression(luaAst,convertLuaToJs){
    return{
        type: 'ArrayExpression',
        elements: luaAst.fields.map(arg => objectExpression(arg.value,convertLuaToJs)),
    }
}

function objectExpression(luaAst,convertLuaToJs){
    return{
        type: 'ObjectExpression',
        properties: luaAst.fields.map(arg =>{
            return{
                type: 'Property',
                key: convertLuaToJs(arg.key),
                value: convertLuaToJs(arg.value),
                kind: 'init',
            };
        }).filter(Boolean),
    };
}

module.exports = {
    binaryExpression,
    unaryExpression,
    tableConstructorExpression,
    indexExpression,
    callExpression,
    memberExpression,
    logicalExpression,
    arrayExpression,
    objectExpression,
}