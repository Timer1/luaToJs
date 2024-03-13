'use strict'

// 函数映射表
let funcMaps = new Map([
    ['print','console.log'],
    ['tonumber','parseFloat'],
])

// 操作符映射表
let operatorMaps = new Map([
    ['~=','!='],
    ['==','==='],
    ['..','+'],
    ['and','&&'],
    ['or','||'],
    ['not','!'],
])

// let requireList = new Array
module.exports = {
    funcMaps,
    operatorMaps,
}

