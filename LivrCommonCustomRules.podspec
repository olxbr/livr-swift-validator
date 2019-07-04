Pod::Spec.new do |s|
  s.name         = "LivrCommonCustomRules"
  s.version      = "1.0.0"
  s.summary      = "Extend LIVR validator adding common custom rules"
  s.homepage     = "https://github.com/grupozap/livr-swift-validator"
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author             = { "Felipe Lefèvre Marino" => "felipemarino91@gmail.com" }

  s.source       = { :git => "https://github.com/grupozap/livr-swift-validator.git", :tag => "#{s.version}" }

  s.ios.deployment_target = '9.0'

  s.swift_version = "4.2"
  s.dependency = "Livr"
  s.source_files  = "LivrCommonCustomRules/**/*.swift"
end