#
# Be sure to run `pod lib lint ChatRoomScene.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ChatRoomScene'
  s.version          = '0.0.1'
  s.summary          = 'ChatRoomScene for messages.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  ChatRoomScene for messages. 0.0.1
                       DESC

  s.homepage         = 'https://github.com/a1252425/ChatRoomScene'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'a1252425' => 'shaoshuai@rongcloud.cn' }
  s.source           = { :git => 'https://github.com/a1252425/ChatRoomScene.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  
  s.xcconfig = {
      'VALID_ARCHS' =>  'arm64 x86_64 armv7',
  }
  
  s.pod_target_xcconfig = {
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  s.user_target_xcconfig = {
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  
  s.source_files = 'ChatRoomScene/Classes/**/*'
  
  s.dependency 'RongCloudIM/IMLib'
  
end
