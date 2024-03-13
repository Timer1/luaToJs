'use strict'
const base = require("./base");
const declaration = require("./declaration");
const expression = require("./expression");
const literal = require("./literal");
const statement = require("./statement");
const clause = require("./clause");

function convertLuaToJs(luaAst) {
    switch(luaAst.type){
        // Base类
        case 'Chunk':
            return base.chunk(luaAst,convertLuaToJs);
        case 'Identifier':
            return base.identifier(luaAst,convertLuaToJs);
        case 'TableValue':
            return base.tableValue(luaAst,convertLuaToJs);

        // Declararion类
        case 'FunctionDeclaration':
            return declaration.functionDeclaration(luaAst,convertLuaToJs);

        // Literal类
        case 'StringLiteral':
            return literal.stringLiteral(luaAst,convertLuaToJs);
        case 'NumericLiteral':
            return literal.numbericLiteral(luaAst,convertLuaToJs);
        case 'NilLiteral':
            return literal.nilLiteral(luaAst,convertLuaToJs);
        case 'BooleanLiteral':
            return literal.booleanLiteral(luaAst,convertLuaToJs);
        
        // Statement类
        case 'LocalStatement':
            return statement.localStatement(luaAst,convertLuaToJs);
        case 'CallStatement':
            return statement.callStatement(luaAst,convertLuaToJs);
        case 'AssignmentStatement':
            return statement.assignmentStatement(luaAst,convertLuaToJs);
        case 'IfStatement':
            return statement.ifStatement(luaAst,convertLuaToJs);
        case 'ReturnStatement':
            return statement.returnStatement(luaAst,convertLuaToJs);
        case 'ForNumericStatement':
            return statement.forNumbericStatement(luaAst,convertLuaToJs);
        case 'BreakStatement':
            return statement.breakStatement(luaAst,convertLuaToJs);
        case 'ForGenericStatement':
            return statement.forGenericStatement(luaAst,convertLuaToJs);
        case 'WhileStatement':
            return statement.whileStatement(luaAst,convertLuaToJs);
        case 'DoStatement':
            return statement.doStatement(luaAst,convertLuaToJs);

        // Expression类
        case 'CallExpression':
            return expression.callExpression(luaAst,convertLuaToJs);
        case 'TableConstructorExpression':
            return expression.tableConstructorExpression(luaAst,convertLuaToJs);
        case 'MemberExpression':
            return expression.memberExpression(luaAst,convertLuaToJs);
        case 'IndexExpression':
            return expression.indexExpression(luaAst,convertLuaToJs);
        case 'BinaryExpression':
            return expression.binaryExpression(luaAst,convertLuaToJs);
        case 'LogicalExpression':
            return expression.logicalExpression(luaAst,convertLuaToJs);
        case 'UnaryExpression':
            return expression.unaryExpression(luaAst,convertLuaToJs);

        // Clause类
        case 'IfClause':
            return clause.ifClause(luaAst,convertLuaToJs);
        case 'ElseifClause':
            return clause.elseIfClause(luaAst,convertLuaToJs);
        case 'ElseClause':
            return clause.elseClause(luaAst,convertLuaToJs);

        // 未处理
        default :
            console.log(luaAst.type)
            return null;
    }    
}

function moduleHandler(luaAst,f){
    var estree = convertLuaToJs(luaAst);
    estree = base.moduleExportHandler(estree);
    estree = base.moduleImportHandler(estree,f.slice(0,f.indexOf('.')));
    return estree;
}

module.exports = {
    moduleHandler,
}