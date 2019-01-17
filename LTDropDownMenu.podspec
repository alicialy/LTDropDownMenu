
Pod::Spec.new do |s|

  s.name         = "LTDropDownMenu"
  s.version      = "0.0.1"
  s.summary      = "DropDown Menu in TableHeader"
  s.homepage     = "https://github.com/alicialy/LTDropDownMenu"
  s.license      = "MIT"
  s.author	     = { "alicialy" => "alicialy@qq.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/alicialy/LTDropDownMenu.git", :tag => "#{s.version}" }
  s.source_files  = "LTDropDownMenu/*.{h,m}"
  s.resources	= "LTDropDownMenu/Resource/Image.xcassets"
  s.requires_arc = true

end
