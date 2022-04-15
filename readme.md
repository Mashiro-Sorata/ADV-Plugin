<div align="center"><h1>ADV-Plugin</h1></div>
<div align="center"><img src="https://p.qlogo.cn/zc_icon/0/0afa95dfc4850ec9539eb0800b61a15016277179577515/0.png"></div>
<div align="center">Powered By <a href="http://mashiros.top">Mashiro_Sorata</a></div>

---

# 简介

`ADV-Plugin`是[SAO Utils 2](http://sao.gpbeta.com/)的第三方插件，可以提供系统音频数据的可视化服务。
得益于SAO Utils 2允许用户使用qml脚本编写扩展插件，相对于[第一代](https://github.com/Mashiro-Sorata/AudioDVServer-Plugin)的插件方案，第二代可以整合第一代中客户端与服务器端的功能，无需复杂的配置即可使用。

## 特色
* 整合客户端与服务器端的功能，使用更简单
* 预设4种频谱显示形式，其中每种都可以进一步自定义设置其样式
* 提供了Style的开发接口，供开发者添加更多的可视化样式
* 导入第三方Style类似其他插件，预计支持steam创意工坊下载
* 服务端崩溃后自启动

## 使用说明

安装并启用插件后，默认加载第一种预设Style样式。右键挂件可调出菜单，在挂件菜单的挂件名选单中点击Settings选项，呼出Style设置窗口。点击其中的Styles选项可切换不同的Style风格，若此Style提供可配置项，则在Styles选项下方会出现配置界面的入口。

<div align="center"><img src="https://s3.bmp.ovh/imgs/2022/04/15/b62270e9dd574622.png" style="zoom:80%;" /></div>

# 进阶设置

样式设置可在插件内设置，一般服务端设置采用默认设置即可，但也提供了服务端设置的接口作为高级设置。可通过更改本插件目录`bin`文件夹中的`advConfig.ini`文件来配置插件服务器与数据设置。当配置数据错误或无配置文件时使用默认值，配置值不区分大小写。其参数的具体说明如下。

- [Server]
  - `ip`：可选，默认值为`local`，指代地址127.0.0.1，可更改为`any`，指代地址0.0.0.0。只支持`any`与默认参数`local`，定义插件提供服务的地址。
  - `port`：可选，默认值为`5050`，定义插件提供服务的端口号。
  - `maxClient`：可选，默认值为`5`，定义WebSocket的最大连接数。
  - `logger`：可选，默认值为`false`。设置为`true`后可在插件所在目录下输出日志文件`ADV_Log.log`。
- [FFT]
  - `attack`：可选，默认值为25。可调节频谱数据增大时的速度，该值越大，增大速度越慢。
  - `decay`：可选，默认值为25。可调节频谱数据减小时的速度，该值越大，减小速度越慢。
  - `norspeed`：可选，默认值为1。动态归一化系数，取值范围从1~99，该值越大，归一化的峰值数据收敛速度越快。
  - `peakthr`：可选，默认值为10。归一化的峰值数据的额外增量。
  - `fps`：可选，默认值为30。每秒钟数据发送的次数，**<font color='red'>必须确保该值大于5</font>**。
  - `changeSpeed`：可选，默认值为25。按照`changeSpeed/fps`的比例调节频谱数据变化速度，**一般该值小于fps**。


`advConfig.ini` 文件示例：
```ini
[Server]
ip = local
port = 5050
maxClient = 5
logger = true

[FFT]
attack = 25
decay = 25
norspeed = 1
peakthr = 10
fps = 35
changeSpeed = 25
```

# 频谱样式开发

如果想开发新的频谱样式，可以参照[ADV-Plugin Wiki](https://nvg.dev/Mashiro_Sorata/ADV-Plugin/wiki)的说明及开发教程。

欢迎开发更多有趣好玩的频谱样式，与大家分享~

