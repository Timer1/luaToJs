'use strict'

// FunctionDeclaration：表示函数的声明。
// LocalDeclaration：表示局部变量的声明。
// VariableDeclaration

function functionDeclaration(luaAst,convertLuaToJs){
    if (luaAst.identifier === null){
        return {
            type: 'FunctionExpression',
            id: null,
            params: luaAst.parameters.map(arg => convertLuaToJs(arg)),
            body:{
                type: 'BlockStatement',
                body: luaAst.body.map(arg => convertLuaToJs(arg)),
            },
            generator: false,
            expression: false,
            async: false,
        };
    }else{
        return {
            type: 'ExpressionStatement',
            expression: {
                type: 'AssignmentExpression',
                operator: '=',
                left: convertLuaToJs(luaAst.identifier),
                right: {
                    type: 'FunctionExpression',
                    id: null,
                    params: luaAst.parameters.map(arg => convertLuaToJs(arg)),
                    body: {
                        type: 'BlockStatement',
                        body: luaAst.body.map(arg => convertLuaToJs(arg)),
                    },
                    generator: false,
                    expression: false,
                    async: false
                },
            },
        };
    }
}


function variableDeclaration(){

}


module.exports = {
    functionDeclaration,
    variableDeclaration,
};