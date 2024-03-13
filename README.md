命令行运行
```
    //把src目录中的lua文件转化为js文件后存放到dist目录中
    node run.js src dist
```
#
```
    run.js将lua代码转化为AST树后，调用index.js将AST树的节点转化为EsTree的节点，convertMaps目录下的其他文件均是转化不同类型节点的函数和工具，转化完成后再将EsTree转化为js代码。
```