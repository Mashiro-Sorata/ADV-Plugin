<div align="center"><h1>ADV-Plugin</h1></div>
<div align="center"><a href="https://nvg.dev/Mashiro_Sorata/ADV-Plugin">简体中文</a> | English</div>
<div align="center"><img src="https://s3.bmp.ovh/imgs/2022/05/25/890c76939e00f9ab.png"></div>
<div align="center">Powered By <a href="http://mashiros.top">Mashiro_Sorata</a></div>

---

# Introduction

`ADV-Plugin` is a third-party plug-in for [SAO Utils 2](http://sao.gpbeta.com/) that provides visualization of system audio data.With the extension written in Qml language, the second generation ADV-Plugin can integrate the client and server functions in the first generation, and it is also easier to set custom styles.

## Style Settings

When the plugin is installed and enabled, the first preset style is loaded by default. Right-click on the widget to open the menu, and click on "Style Settings..." option to open the style settings window. The style options can switch between different styles, and if the style offers configurable options, a configuration item will appear below the style options.

<div align="center"><img src="https://s3.bmp.ovh/imgs/2022/05/27/d1f9370c7a04d88b.png" style="zoom:80%;" /></div>

## Server Settings

Right-click on the widget and select "Server Settings..." in the menu item. You can set up and debug the server. Generally, you can use the default settings, but you can also further customize the parameters of the server to adjust the animation effect of all the audio visualization widgets. In addition, for all users whose audio visualization widgets are not displayed properly, debugging options are provided to better help locate errors.

<div align="center"><img src="https://s3.bmp.ovh/imgs/2022/05/27/1516e8a3a63d658f.png" style="zoom:80%;" /></div>

The options are specified below.

* `Debug Mode`: Because the plug-in has an error recovery function, each self-start will overwrite the log file. Therefore, you need to turn on debug mode to turn off the error self-start function, after which you can locate the specific error through the log file.

* `General`
  * `Port`: The port of the Websocket server.
  * `Max Number of Clients`: Maximum number of connections to the Websocket server, audio visualization widgets all share data from the same connection.
  * `Enable Logging`: When enabled, the log file `ADV_Log.log` will be output in the plugin server directory to locate errors. Logging must be enabled when entering `debug mode`.
* `Data`
  * `Increase Factor`: affects the speed when the spectrum data increases, the higher the value, the slower the speed when the data increases.
  * `Reduction Factor`: affects the speed when the spectrum data decreases, the higher the value, the slower the speed when the data decreases.
  * `Peak Extra Increment`: Additional increment of the data normalization peak, which regulates the dynamic range of the spectrum.
  * `Dynamic Normalization Factor`: The convergence speed of the normalized peak data. The larger the value, the faster the convergence speed of the normalized peak data.
  * `Transmission Rate`: The number of times the data is sent per second, which can be interpreted as the widget refresh rate.
  * `Change Speed`: Adjusts the rate of spectrum data change in proportion to the `Change Speed/Transmission Rate`, which is generally less than the `Transmission Rate`.

# Style Development

If you want to develop a new spectrum style, you can refer to the [ADV-Plugin Wiki](https://github.com/Mashiro-Sorata/ADV-Plugin/wiki) for instructions and development tutorials.

Welcome to develop more interesting and fun spectrum styles and share them with everyone~

