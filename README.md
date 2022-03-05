# 融云 RTC

## 简介
本仓库是融云 RTC 项目开源代码，为开发者提供接入场景化 SDK 代码示例。

## 基础架构

融云 RTC 开发语言以 Swfit 为主，

* 常规业务：根据业务简易程度，实现 `MVC` 和 `MVVM` 的基本逻辑。
* 静态资源：使用 `R.swift` 来管理静态资源。
* 网络请求：基于 `Moya` 封装网络请求没，每个业务接口以 Enum 的方式实现 Moya.TargetType 协议。
* 视图导航：基于 Swift 中 Enum 的 `AppNavigation`，用户也可基于 `runtime` 去动态生成视图来做视图间的解耦。
* 环境变量：除了默认的 `Debug` 和 `Release`，额外增加海外 `Overseas` 和打包 `Production` 两个环境。


## 模块结构

融云 RTC 的主要模块：

![](https://tva1.sinaimg.cn/large/008i3skNly1grt4fatbqwj31130u0q8n.jpg)

### 语聊房核心模块结构(VoiceRoomModule)

* 语聊房列表：`VoiceRoomList`实现语聊房列表展示
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

### 语聊房`VoiceRoom`业务逻辑代码拆分


语聊房核心类VoiceRoomViewController业务繁多，导致单文件代码量过大，导致后续维护困难。
根据不同业务模块进行拆分，并达到以下目标：

* 实现业务需求
* 模块结构清晰，简单易懂，易于维护
* 模块相互独立，无直接依赖，可直接删减某模块不影响其他模块

#### 拆分实现方法：extension&@_dynamicReplacement

extension可以为class、struct、enum、protocol等添加新特性，类似OC的category。
_dynamicReplacement是swift 5新增的方法或属性替换的关键字，需要与dynamic配合使用。
_dynamicReplacement使用方式：
* dynamic var instance: Type，动态属性，支持属性替换
* dynamic func foo() {}，动态方法，支持方法替换
* Other swift flags添加-Xfrontend -enable-dynamic-replacement-chaining，支持链表式响应

结合extension和_dynamicReplacement，将VoiceRoomViewController拆分，拆分后类名结构图如下：
<div align=center>
<img src="https://tva1.sinaimg.cn/large/008i3skNly1grt8zygt19j30u013kn3o.jpg" width="400px" height="auto" />
</div>

不同模块通过替换属性和方法，捕获事件触发时机，处理各自事务。示例代码：
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
