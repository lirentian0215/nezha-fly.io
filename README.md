# nezha-fly
来自 [lyj0309/nezha-fly](https://github.com/lyj0309/nezha-fly)

删除commit是因为之前不小心将secrets直接上传了
## 部署哪吒面板到fly.io

## 原理
通过基于原哪吒面板的docker镜像，在此基础上自动添加config文件，其中config文件在github secrets中

两个secrets 

`CONFIG`: 哪吒面板配置文件

`FLY_API_TOKEN`: fly的api token
