Pod::Spec.new do |s|

s.platform = :ios
s.ios.deployment_target = '8.0'
s.name = "Table2Grid"
s.summary = "Table2Grid is a framwork made for creating browser. You have 2 mode of view table and grid."
s.requires_arc = true

s.version = "0.1.0"

s.license = { :type => "APACHE2", :file => "LICENSE" }

s.author = { "Leo Marcotte" => "leo@pydio.com" }

s.homepage = "https://github.com/pydio/t2g"

s.source = { :git => "https://github.com/pydio/t2g.git", :tag => "#{s.version}"}

s.framework = "UIKit"
s.dependency 'Material', '~> 1.0'

s.source_files = "Table2Grid/**/*.{swift}"

#s.resources = "Table2Grid/**/*.{png,jpeg,jpg,storyboard,xib}"
s.ios.resource_bundle = { 'Images' => 'Table2Grid/Images.xcassets' }
end