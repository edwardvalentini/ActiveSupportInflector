Pod::Spec.new do |s|
  s.name         = "ActiveSupportInflector"
  s.version      = "0.1.2"
  s.summary      = "Active Support Inflector"
  s.homepage     = "https://github.com/edwardvalentini/ActiveSupportInflector"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Tom Ward" => "tom@popdog.net" }
  s.source       = { :git => "https://github.com/edwardvalentini/ActiveSupportInflector.git", :tag => s.version.to_s }
  s.source_files = 'ActiveSupportInflector/*.{h,m}'
  s.requires_arc = true
end
