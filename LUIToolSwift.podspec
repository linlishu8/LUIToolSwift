#
# Be sure to run `pod lib lint LUIToolSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LUIToolSwift'
  s.version          = '0.1.0'
  s.summary          = 'LUITool的Swift版'
  
  # 本地测试pod库：pod lib lint --allow-warnings --verbose --no-clean
  # 远程验证:pod spec lint --allow-warnings --verbose --no-clean
  # 推送到xxx私有源：pod repo push xxxspecs LUI.podspec --allow-warnings --verbose
  # 推到官方源：pod trunk push LUIToolSwift.podspec --allow-warnings --verbose

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  * 主题，自定义tabbar，简化tableView，collectionView，自定义alertView，actionSheetView, 可扩大点击范围的按钮，有内边距的label，聊天界面，搜索，自定义键盘，
                       DESC

  s.homepage         = 'https://github.com/Your Name/LUIToolSwift'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'linlishu8' => 'linlishu8@163.com' }
  s.source           = { :git => 'https://github.com/linlishu8/LUIToolSwift.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'LUIToolSwift/Classes/**/*'
  
  # s.resource_bundles = {
  #   'LUIToolSwift' => ['LUIToolSwift/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
