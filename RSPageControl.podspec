Pod::Spec.new do |s|
  s.name         = "RSPageControl"
  s.version = "0.0.1"
  s.summary      = "轮播"
  s.homepage     = "https://github.com/txy1042348976/RSPageControl"
  s.license      = "MIT"
  s.author       = { "xuyangtam" => "1042348976@qq.com" }
  s.platform     = :ios, "9.0"
  s.swift_version = "4.2"
  s.source       = { :git => "https://github.com/txy1042348976/RSPageControl.git", :tag => "#{s.version}" }
  s.framework    = "UIKit"
  s.source_files  = "RSPageControl", "RSCycleScrollView/*.{swift}"
  s.requires_arc = true
end