const gen = require("escodegen");
const luaparse = require('luaparse');
const fs = require("fs");
const index = require("./convertMaps/index");

function convert(code,f){
    // 将lua代码转化成lua AST
    var AST = luaparse.parse(code);
    // lua AST转化成ESTree
    var esTree = index.moduleHandler(AST,f);
    // ESTree转化成js代码
    var jsCode = gen.generate(esTree);
    console.log(jsCode);
    
    return jsCode;
}

function convertDir(srcdir, outdir) {
    fs.readdirSync(srcdir).forEach(function(f){
        var code = fs.readFileSync(srcdir + '/' + f).toString();
        try{
            fs.writeFileSync(outdir + '/' + f.replace('.lua','.js'),convert(code,f));
        }catch(e){
            console.log(e);
        }
    })
}

convertDir(process.argv[2], process.argv[3]);