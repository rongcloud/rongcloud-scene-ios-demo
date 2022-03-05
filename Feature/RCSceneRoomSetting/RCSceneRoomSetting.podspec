#
# Be sure to run `pod lib lint RCSceneRoomSetting.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RCSceneRoomSetting'
  s.version          = '0.0.1'
  s.summary          = 'Scene Room Setting.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
RCRTC project scene room settings.
                       DESC

  s.homepage         = 'https://github.com/shaoshuai/RCSceneRoomSetting'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'shaoshuai' => 'shaoshuai@rongcloud.cn' }
  s.source           = { :git => 'https://github.com/shaoshuai/RCSceneRoomSetting.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.requires_arc = true
  s.static_framework = true
  s.swift_version = '5.0'
  
  s.ios.deployment_target = '11.0'
  
  s.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'VALID_ARCHS' => 'arm64 x86_64',
  }

  s.source_files = 'RCSceneRoomSetting/Classes/**/*'
  
   s.resource_bundles = {
     'Images' => ['RCSceneRoomSetting/Assets/Assets.xcassets'],
     'Colors' => ['RCSceneRoomSetting/Assets/Colors.xcassets']
   }

  s.public_header_files = 'Pod/Classes/Header/RCSceneRoomSettingKit.h'
  
  s.dependency 'SnapKit'
  s.dependency 'Reusable'
  
end
