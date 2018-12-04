#
# Be sure to run `pod lib lint OverlayContainer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OverlayContainer'
  s.version          = '0.0.1'
  s.summary          = 'A short description of OverlayContainer.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
OverlayContainer is a UI library written in Swift. It makes developing overlay based interfaces easier, like those presented in the Apple Maps, Stocks or Shortcuts apps.
                       DESC

  s.homepage         = 'https://github.com/gaetanzanella/OverlayContainer'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'gaetanzanella' => 'gaetan.zanella@fabernovel.com' }
  s.source           = { :git => 'https://github.com/gaetanzanella/OverlayContainer.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.source_files = 'OverlayContainer/Classes/**/*'
end
