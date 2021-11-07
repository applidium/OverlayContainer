#
# Be sure to run `pod lib lint OverlayContainer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OverlayContainer'
  s.version          = '3.5.2'
  s.summary          = 'OverlayContainer is a UI library which makes it easier to develop overlay based interfaces.'

  s.swift_versions   = ["4.2", "5.0"]

  s.description      = <<-DESC
  OverlayContainer is a UI library written in Swift. It makes it easier to develop overlay based interfaces, such as the one presented in the Apple Maps, Stocks or Shortcuts apps.
  The main component of the library is the `OverlayContainerViewController`. It defines an area where a view controller can be dragged up and down, hidding or revealing the content underneath it. 
                       DESC


  s.homepage         = 'https://github.com/applidium/ADOverlayContainer'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'gaetanzanella' => 'gaetan.zanella@fabernovel.com' }
  s.source           = { :git => 'https://github.com/applidium/ADOverlayContainer.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.source_files = 'Source/Classes/**/*'
end
