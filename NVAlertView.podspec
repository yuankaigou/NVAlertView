Pod::Spec.new do |spec|
  spec.name         = "NVAlertView"
  spec.version      = "0.0.2"
  spec.summary      = "基于SCLAlertView的提示框"
  spec.homepage     = "https://github.com/yuankaigou/NVAlertView"
  
  spec.license            = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "yuankaigou" => "602122923@qq.com" }
  spec.platform           = :ios
  spec.frameworks         = "UIKit", "AudioToolbox", "Accelerate", "CoreGraphics"
  spec.ios.deployment_target = '6.0'
  spec.source             = { :git => "https://github.com/yuankaigou/NVAlertView.git", :tag => spec.version.to_s }
  spec.source_files       = "NVAlertView/*"
  spec.requires_arc       = true
end
