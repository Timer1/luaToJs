'use strict'

// IfClause
// ElseIfClause
// ElseClause


function elseIfClause(luaAst,convertLuaToJs){
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

function elseClause(luaAst,convertLuaToJs){
    return {
        type: 'BlockStatement',
        body: luaAst.clauses[0].body.map(arg => convertLuaToJs(arg)),
    };
    
}


module.exports = {
    elseIfClause,
    elseClause,
}