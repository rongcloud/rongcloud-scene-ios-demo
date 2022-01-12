#
# Be sure to run `pod lib lint ChatRoomScene.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RCChatroomSceneKit'
  s.version          = '0.0.1'
  s.summary          = 'ChatRoomScene for messages.'

  s.description      = <<-DESC
Chatroom Scene Message Kit.
                       DESC

  s.homepage         = 'https://github.com/rongcloud'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zangqilong' => 'zangqilong1@rongcloud.cn' }
  s.source           = { :git => 'https://github.com/rongcloud/rongcloud-scene-chatroomkit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'
  
  s.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'VALID_ARCHS' => 'arm64 x86_64 armv7',
    'ENABLE_BITCODE' => 'NO'
  }

  s.source_files = 'RCChatRoomSceneKit/Classes/**/*'

  s.public_header_files = 'Pod/Classes/RCChatroomSceneKit.h'
  s.resource = 'RCChatroomSceneKit/Assets/RCChatroomSceneKit.bundle'
  
  s.dependency 'Masonry'
  s.dependency 'YYModel'
  
end
