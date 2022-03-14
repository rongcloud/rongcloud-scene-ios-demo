# 融云 RTC

## 简介
本仓库是融云 RTC 项目开源代码，为开发者提供接入场景化 SDK 代码示例。

## 基础架构

融云 RTC 开发语言以 Swfit 为主，

* 常规业务：根据业务简易程度，实现 `MVC` 和 `MVVM` 的基本逻辑
* 视图导航：基于 `XCoordinator` 实现路由，部分模块使用 `AppNavigation`
* 网络请求：基于 `Moya` 封装网络请求，每个模块有对应的 `Service` 处理网络请求
* 环境变量：支持 `Debug`、`Release`、`Overseas` 和 `Production` 四个编译环境
* 静态资源：使用 `R.swift` 来管理静态资源


## 模块结构

融云 RTC 的模块结构：

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h09hsslebwj213k0u0ad1.jpg)
<div align=center>
<img src="https://tva1.sinaimg.cn/large/e6c9d24ely1h09hsslebwj213k0u0ad1.jpg" width="800px" height="auto" />
</div>

### 基础功能模块

- 登录(Feature/Login)：App 首次启动、登出、注销、踢下线等都会触发登录
- 首页(Feature/Home)：实现核心功能模块展示和入口
- 发现(Feature/Discover)：实现最新活动 Web 页面展示
- 我的(Feature/Mine)：实现用户信息展示、活动入口和客服支持
- 设置(Feature/Setting)：实现退出登录、注销、修改信息、隐私和协议


### 房间通用模块

- 房间列表(Feature/RoomList)：更具不同房间类型 roomType 获取房间列表
- 好友列表(Feature/FriendList)：实现关注和粉丝列表信息展示
- 创建房间(Feature/CreateVoiceRoom)：更具不同房间类型 roomType 创建不同房间
- 用户列表(Modular/SceneRoomUser)：实现房间内用户信息展示
- 用户管理(Modular/SceneRoomUser)：实现房间内用户关注、送礼、私聊、邀上麦、抱下麦、踢出等
- 房间点赞(Modular/Like)：实现房间内双击点赞功能
- 房间设置(RCSceneSetting)：实现修改房间密码、背景、名称、屏蔽词、公告等
- 房间音乐(RCMusicControlKit)：实现房间内音乐播放
- 赠送礼物(RCSceneGift)：实现房间内多用户赠送礼物、礼物数量展示和全服礼物消息
- 公屏消息(RCChatroomSceneKit)：实现房间聊天室消息发送和展示

### 语聊房模块(RCSceneVoiceRoom)

- 房间管理：`VoiceRoom` 实现加入房间、离开房间、全麦管理、PK等
- 观众连麦：`VoiceRoomInvite` 实现邀请用户上麦和处理上麦请求
- 麦位管理：`ManageSeat` 实现麦位控制：锁麦、禁麦、闭麦、跳麦等

### 语音电台模块(RCSceneRadioRoom)

语音电台观众订阅 CDN 流，功能直接使用 IMLib 和 RTCLib 实现。

### 视频直播模块(RCSceneVideoRoom)

- 房主房间：`LiveRoomHost` 实现创建者全功能入口：加入房间、离开房间、全麦管理、房间信息设置等
- 观众房间：`LiveRoomAudience` 实现用户全功能入口：加入房间、离开房间、上下麦等
- 观众连麦：`LiveRoomMicrophone` 实现邀请用户上麦、处理上麦请求和连麦布局切换
- 房间 PK：`LiveRoomPK` 实现跨房间 PK：邀请、响应、结束、恢复、静音等
- 视频美颜：`LiveRoomBeauty` 实现视频美颜功能

### 音视频通话模块(RCSceneCall)

- 输入号码：`Dial` 实现手机号码输入
- 拨号记录：`Persistent` 实现已播号码历史列表

## 模块路由

低版本里通过 `Enum` 罗列各个业务模块页面，通过 `Switch` 返回对应 ViewController。随着业务功能不断增加，路由类 `AppNavigation` 枚举类型不断增多，路由维护愈发困难。在模块拆分初期，引入了 `XCoordinator` 三方路由库，逐步替换当前的 `AppNavigation`，目前，项目中两者同时存在，后续会不断替代完善。

项目内置了 `UIViewController-Swizzled`，随着不同的页面展示，控制台会打印出 `UIViewController` 的层级关系，方便开发者快速对照 Demo 运行中控制器的层级结构。示例如下：

```
2021-06-24 13:46:59.554026+0800 RCE[658:239776] ---> RCE.HomeViewController
2021-06-24 13:47:02.907656+0800 RCE[658:239776] -----> RCE.VoiceRoomListViewController
2021-06-24 13:47:07.387716+0800 RCE[658:239776] -------> RCE.VoiceRoomViewController
```

可以直观的看到页面的展示顺序是：

 `HomeViewController` --> `VoiceRoomListViewController` --> `VoiceRoomViewController`

在 `AppDelegate` 中可以关闭该功能：

`UIViewController.swizzIt()` 

## 业务功能类

在房间核心类中，业务逻辑繁多，导致单文件代码量过大，严重影响开发效率和后续维护。因此，需要根据不同业务模块进行拆分，并达到以下目的：

- 每个模块实现单独业务功能
- 每个模块结构清晰，简单易懂，易于维护
- 每个模块相互独立，无直接依赖，删减某模块不影响运行

### 拆分实现方法：`extension` & `@_dynamicReplacement`

`extension` 可以为 class、struct、enum、protocol 等添加新特性，类似 OC 的 category。
`@_dynamicReplacement` 是 swift 5 新增的方法或属性替换的关键字，需要与 dynamic 配合使用。
`@_dynamicReplacement` 使用方式：
- dynamic var instance: Type，动态属性，支持属性替换
- dynamic func foo() {}，动态方法，支持方法替换
- Other swift flags 添加 -Xfrontend -enable-dynamic-replacement-chaining，支持链表式响应

结合 `extension` 和 `@_dynamicReplacement`，以语聊房为例，将 `VoiceRoomViewController` 拆分，拆分后类名结构图如下：
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

## 如何运行？

1. 申请 BusinessToken：https://rcrtc-api.rongcloud.net/code
2. 搜索 `Environment` 文件，替换 BusinessToken
3. 替换 `bundleId` 和开发者证书，每个 target 都需要替换
4. 在项目根目录执行 `pod install`
5. 打开 `RCE.xcworkspace`
6. 连手机运行（demo 目前不支持模拟器）
