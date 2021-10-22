# RCRTC 介绍


## 基础架构

融云场景Demo的主要代码模块有以下几类。

* 常规业务： `RxSwift + ReactorKit` 来实现 `MVVM` 的基本逻辑，例如 `UI <---> Data` 双向绑定等。
* 静态资源：使用 `R.swift` 来管理静态资源。
* 网络请求： 基于 `RxMoya` 的网络请求
* 列表数据源：使用 `RxDataSources` 绑定 UITableView 和 UICollectionView 的数据源。
* 核心业务开发： 以防部分开发对响应式编程和MVVM结构不熟悉。我们在重要的演示模块，例如语聊房核心代码，依旧使用了常规的MVC开发。
* 视图导航： 基于 Swift Enum 的 `AppNavigation`，用户也可基于 `runtime` 去动态生成视图来做视图间的解耦。



## 目录结构

主体目录结构如下:

<img src="https://tva1.sinaimg.cn/large/008i3skNly1gvnve1v53dj60u00ykmzp02.jpg" width = "70%" align=center />



### 语聊房核心模块结构(VoiceRoomModule)

* 创建语聊房：`CreateVoiceRoom`实现语聊房创建
* 语聊房：`VoiceRoom`实现语聊房信息展示和控制中心
* 语聊房在线用户：`VoiceRoomUserList`实现当前在线观众列表和管理
* 语聊房密码：`VoiceRoomPassword`实现密码验证和设置
* 语聊房背景：`VoiceRoomBackgroundSetting`实现语聊房背景更换
* 上麦邀请：`VoiceRoomInvite`实现邀请用户上麦和处理上麦请求
* 语聊房设置：`VoiceRoomSetting`实现语聊房设置：上锁和解锁、全麦管理等
* 音乐：`Music`实现音乐添加、下载、播放等
* 麦位管理：`ManageSeat`座位上锁或禁麦，上麦邀请，抱下麦等
* 公屏消息：`Message`实现公屏消息展示：进入、系统、聊天、管理设置、麦位数等


### 电台房核心模块结构(RadioRoomModule)

电台房间的创建、在线用户、音乐、公屏消息、设置等功能，延用语聊房 UI。

* 电台房间：`RadioRoom`实现电台房间信息展示和控制中心

### 视频直播核心模块结构(LiveVideoModule)

* 视频直播：`LiveRoom`实现视频直播房间的创建、美颜、信息展示和控制中心
* 连麦管理：`LiveRoomMicrophone`实现邀请用户上麦和处理上麦请求
* 房间设置：`LiveRoomSetting`实现语聊房设置：上锁和解锁、美颜等



## 核心业务类优化

语音聊天、电台聊天、视频直播等房间核心类业务繁多，导致单文件代码量过大，导致后续维护困难。
根据不同业务模块进行拆分，并达到以下目标：

* 实现业务需求
* 模块结构清晰，简单易懂，易于维护
* 模块相互独立，无直接依赖，可直接删减某模块不影响其他模块

### 拆分实现方法：`extension` 加 `@_dynamicReplacement`

在 Swift 中 extension 可以为 class、struct、enum、protocol等添加新特性，类似 OC 的 category。
`_dynamicReplacement` 是 Swift 5 新增的方法或属性替换的关键字，需要与 `dynamic` 配合使用。
`_dynamicReplacement` 使用方式：
* 设置动态属性： 格式为 `dynamic var instance: Type`
* 设置动态方法：格式为 `dynamic func foo() {}`
* 设置链式响应：在 `Buid Settings` 中的 `Other swift flags` 配置中，添加 `-Xfrontend -enable-dynamic-replacement-chaining`

结合 `extension` 和 `_dynamicReplacement`，将房间类拆分，以语聊房为例，拆分后类名结构图如下：
<div align=center>
<img src="https://tva1.sinaimg.cn/large/008i3skNly1grt8zygt19j30u013kn3o.jpg" width="400px" height="auto" />
</div>


### 示例代码

不同模块通过替换属性和方法，捕获事件触发时机，处理各自事务：
```
///kv信息
dynamic var kvRoomInfo: RCVoiceRoomInfo?
///设置模块，在viewDidLoad中调用
dynamic func setupModules() {}

@_dynamicReplacement(for: setupModules)
private func setupRoomInfoModule() {
	setupModules()
	roomInfoView.delegate = self
}
    
@_dynamicReplacement(for: kvRoomInfo)
private var roomInfo_kvRoomInfo: RCVoiceRoomInfo? {
	get { kvRoomInfo }
	set {
		kvRoomInfo = newValue
		if let info = newValue {
			updateRoomInfo(info: info)
		}
	}
}
```



## 快速对照Demo浏览代码结构的建议

为了方便用户对照Demo的运行阅读代码逻辑。项目内置了[UIViewController-Swizzled](https://github.com/RuiAAPeres/UIViewController-Swizzled)

会很方便的在 `console `中打印出ViewController的层级关系。

随着点击不同的ViewController，`console` 中会打印出`ViewController`的层级关系。

下列代码展示了不同页面的层级关系。

可以看到页面的展示顺序是从 `HomeViewController` --> `VoiceRoomListViewController` --> `VoiceRoomViewController`

```
2021-06-24 13:46:59.554026+0800 RCE[658:239776] ---> RCE.HomeViewController
2021-06-24 13:47:02.907656+0800 RCE[658:239776] -----> RCE.VoiceRoomListViewController
2021-06-24 13:47:07.387716+0800 RCE[658:239776] -------> RCE.VoiceRoomViewController
```

如果想关闭这个功能。只需要在AppDelegate中删除

`UIViewController.swizzIt()` 


## 如何运行？

1. 部署我们的开源服务器。开源地址： https://github.com/rongcloud/rongcloud-scene-server-demo
2. 部署成功后，在项目文件中搜索`Environment` 文件。
3. 替换文件中的`url` 为自己服务器地址。
4. 替换`rcKey`为您自己的融云appkey
