#
# Be sure to run `pod lib lint QuickList.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'QuickList'
  s.version          = '1.0.2'
  s.summary          = 'A short description of QuickList.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/gzhongcheng/QuickList'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'gzc' => 'gzhongcheng@qq.com' }
  s.source           = { :git => 'https://github.com/gzhongcheng/QuickList.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'
  s.swift_version = "5.5"
  
  s.default_subspec = "Base"

  s.subspec "Base" do |ss|
    ss.source_files = 'QuickList/Classes/Base/**/*.{h,m,mm,swift}'
    
    ss.dependency 'SnapKit'
  end
  
  s.subspec "Items" do |ss|
    ss.source_files = 'QuickList/Classes/Items/**/*.{h,m,mm,swift}'

    ss.dependency 'QuickList/Base'
  end
  
  s.subspec "WebImage" do |ss|
    ss.source_files = 'QuickList/Classes/WebImage/**/*.{h,m,mm,swift}'
    
    ss.dependency 'QuickList/Base'
    ss.dependency 'QuickList/Items'
    ss.dependency 'Kingfisher'
    ss.dependency 'KingfisherWebP'
  end
  
  # s.subspec "SegmentPage" do |ss|
  #   ss.source_files = 'QuickList/Classes/SegmentPage/**/*.{h,m,mm,swift}'

  #   ss.dependency 'QuickList/Base'
  # end
end
