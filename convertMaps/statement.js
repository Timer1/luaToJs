'use strict'

// AssignmentStatement：表示变量赋值语句。
// IfStatement：表示条件语句，包括if、elseif和else。
// WhileStatement：表示while循环语句。
// RepeatStatement：表示repeat-until循环语句。
// ForNumbericStatement：表示for循环语句。
// CallStatement
// LocalStatement
// BreakStatement

function assignmentStatement(luaAst,convertLuaToJs){
    return {
        type: 'ExpressionStatement',
        expression: {
            type: 'AssignmentExpression',
            operator: '=',
            left: convertLuaToJs(luaAst.variables[0]),
            right: convertLuaToJs(luaAst.init[0]),
        }
    }
}


function ifStatement(luaAst,convertLuaToJs){
    var localClauses = luaAst.clauses.slice(1);
    return {
        type: 'IfStatement',
        // if条件
        test: convertLuaToJs(luaAst.clauses[0].condition),
        // 符合if条件时执行的语句
        consequent: {
            type: 'BlockStatement',
            body: luaAst.clauses[0].body.map(arg => convertLuaToJs(arg)),
        },
        // 不符合if条件时执行的语句
        alternate: 
            localClauses.length === 0? 
            null: convertLuaToJs({
                type: localClauses[0].type,
                clauses: localClauses,
            }),
    };
}

function whileStatement(luaAst,convertLuaToJs){
    return {
        type: 'WhileStatement',
        test: convertLuaToJs(luaAst.condition),
        body: {
            type: 'BlockStatement',
            body: luaAst.body.map(arg => convertLuaToJs(arg)),
        }
    };
}

function forNumbericStatement(luaAst,convertLuaToJs){
    return {
        type: 'ForStatement',
        init: {
            type: 'VariableDeclaration',
            declarations: [{
                type: 'VariableDeclarator',
                id: convertLuaToJs(luaAst.variable),
                init: convertLuaToJs(luaAst.start),
            }],
            kind: 'let',
        },
        test: convertLuaToJs(luaAst.end),
        update: {
            type: 'UpdateExpression',
            operator: luaAst.step === null? '++':'+='+luaAst.step.raw,
            argument: convertLuaToJs(luaAst.variable),
        },
        body:{
            type: 'BlockStatement',
            body: luaAst.body.map(arg => convertLuaToJs(arg)),
        },
    };
}


function callStatement(luaAst,convertLuaToJs){
    return{
        type: 'ExpressionStatement',
        expression:{
            type:'CallExpression',
            callee:convertLuaToJs(luaAst.expression.base),
            arguments:luaAst.expression.arguments.map(arg => convertLuaToJs(arg)),
        }
    };
}

function localStatement(luaAst,convertLuaToJs){
    return{
        type: 'VariableDeclaration',
        kind: 'var',
        declarations: luaAst.variables.map(arg => ({
            type: 'VariableDeclarator',
            id: convertLuaToJs(arg),
            init: luaAst.init.length === 0?
            null : convertLuaToJs(luaAst.init[0]),
        })),
    };
}

function returnStatement(luaAst,convertLuaToJs){
    return{
        type: 'ReturnStatement',
        argument: luaAst.arguments.length === 0? 
        null : convertLuaToJs(luaAst.arguments[0]),
    };
}

function breakStatement(luaAst,convertLuaToJs){
    return{
        type: 'BreakStatement',
        lable: null,
    };
}

function forGenericStatement(luaAst,convertLuaToJs){
    return{
        type: 'ForInStatement',
        left: {
            type: 'VariableDeclaration',
            declarations: [{
                    type: 'VariableDeclarator',
                    id: {
                        type: 'ArrayPattern',
                        elements: luaAst.variables.map(arg => convertLuaToJs(arg)),
                    },
                    init: null,
                }],
            kind: 'var',
        },
        right: convertLuaToJs(luaAst.iterators[0]),
        body: {
            type: 'BlockStatement',
            body: luaAst.body.map(arg => convertLuaToJs(arg)), 
        }
    };
}

function doStatement(luaAst,convertLuaToJs){
    return{
        type: 'BlockStatement',
        body: luaAst.body.map(arg => convertLuaToJs(arg)),
    }
}

module.exports = {
    assignmentStatement,
    ifStatement,
    whileStatement,
    forNumbericStatement,
    callStatement,
    localStatement,
    returnStatement,
    breakStatement,
    forGenericStatement,
    doStatement,
};