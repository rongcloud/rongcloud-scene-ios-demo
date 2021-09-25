#
# Be sure to run `pod lib lint RCVoiceRoomCallKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RCVoiceRoomCallKit'
  s.version          = '0.0.1'
  s.summary          = 'CallKit For RCRTC'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  CallKit For RCRTC. Single Call.
                       DESC

  s.homepage         = 'https://github.com/a1252425/RCVoiceRoomCallKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'a1252425' => 'shaoshuai@rongcloud.cn' }
  s.source           = { :git => 'https://github.com/a1252425/RCVoiceRoomCallKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  
  s.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'VALID_ARCHS' => 'arm64 x86_64 armv7',
    'ENABLE_BITCODE' => 'NO'
  }

  s.source_files = 'RCVoiceRoomCallKit/Classes/**/*'
  
  s.public_header_files = 'Pod/Classes/**/RCVoiceRoomCallKit.h', 'Pod/Classes/**/RCCall.h'
  
  s.resources = 'RCVoiceRoomCallKit/Assets/Resources/*.bundle', 'RCVoiceRoomCallKit/Assets/Resources/*.lproj/*'

  s.dependency 'RongCloudIM/IMKit', '~> 5.1.3'
  s.dependency 'RongCloudRTC/RongCallLib', '~> 5.1.3'
  
end
