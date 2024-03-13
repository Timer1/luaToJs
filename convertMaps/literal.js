'use strict'

// StringLiteral：表示字符串字面量。
// NumericLiteral：表示数字字面量。
// VarargLiteral：表示可变参数的字面量。


function stringLiteral(luaAst,convertLuaToJs){
    return{
        type: 'Literal',
        value: luaAst.raw.replace(/^['"]|['"]$/g, ''),
    };
}

function numbericLiteral(luaAst,convertLuaToJs){
    return {
        type: 'Literal',
        value: luaAst.value,
        raw: luaAst.raw,
    };
}



function nilLiteral(luaAst,convertLuaToJs){
    return {
        type: 'Literal',
        value: null,
        raw: 'null',
    };
}

function booleanLiteral(luaAst,convertLuaToJs){
    return {
        type: 'Literal',
        value: luaAst.value,
        raw: luaAst.value.toString(),
    }
}


module.exports = {
    stringLiteral,
    numbericLiteral,
    nilLiteral,
    booleanLiteral,
};