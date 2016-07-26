#
# Be sure to run `pod lib lint Table2Grid.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'Table2Grid'
s.version          = '0.1.0'
s.summary          = 'Implementation of table view that is switchable to collection view.'
s.description      = <<-DESC
Implementation of table view that is switchable to collection view along with all the goodies known in both - be it obvious things such as standard protocol for populating the view or not so obvious, but still nice thing - dynamic loading and smooth transition animations.
DESC

s.homepage         = 'https://github.com/pydio/t2g'
# s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
s.license          = { :type => 'APACHE2', :file => 'LICENSE' }
s.author           = { 'Leo Marcotte' => 'leo@pydio.com' }
s.source           = { :git => 'https://github.com/pydio/t2g.git', :tag => s.version.to_s }
s.social_media_url = 'https://twitter.com/pydio'

s.ios.deployment_target = '8.0'

s.source_files = 'Table2Grid/Classes/**/*'
s.resources = 'Table2Grid/Assets/*.xcassets'

#s.resource_bundles = {
#'Table2Grid' => ['Table2Grid/Assets/*.xcassets']
#}

# s.public_header_files = 'Pod/Classes/**/*.h'
# s.frameworks = 'UIKit', 'MapKit'
s.dependency 'Material', '~> 1.0'
end