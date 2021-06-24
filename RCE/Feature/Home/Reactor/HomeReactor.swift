//
//  HomeReactor.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/19.
//

import Foundation
import ReactorKit

final class HomeReactor: Reactor {
  var initialState: State = State()
  
  enum Action {
    
  }
  
  enum Mutation {
    
  }
  
  struct State {
    var sections: [HomeSection] = [HomeSection(items: [
                                                HomeItem(name: "语聊房", englishName: "超大聊天室，支持麦位、麦序 管理，涵盖 KTV 等多种玩法", image: R.image.voice_room_background(), isEnable: true),
                                                    
                                                HomeItem(name: "视频", englishName: "低延迟、高清晰度 视频通话", image: R.image.video_live_room_background(), isEnable: false),
                                                   
                                                HomeItem(name: "语音", englishName: "拥有智能降噪的无差别 电话体验", image: R.image.voice_call_room_background(), isEnable: false)])]
  }
}
