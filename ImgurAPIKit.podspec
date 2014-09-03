#
# Be sure to run `pod spec lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about the attributes see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "ImgurAPIKit"
  s.version          = "0.1.0"
  s.summary          = "An API kit that allows you to easily interact with Imgur"
  s.description      = "Drop in, register for your API keys, and get to work!"
  s.homepage         = "https://github.com/pyro2927/ImgurAPIKit"
  s.license          = 'MIT'
  s.author           = { "pyro2927" => "joseph@pintozzi.com" }
  s.source           = { :git => "https://github.com/pyro2927/ImgurAPIKit.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/pyro2927'

  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
  s.requires_arc = true

  s.source_files = 'Classes'
  s.public_header_files = 'Classes/**/*.h'
  # s.frameworks = 'SomeFramework', 'AnotherFramework'
  s.dependency 'AFNetworking', '~> 2.2.0'
end
