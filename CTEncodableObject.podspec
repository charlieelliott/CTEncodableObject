#
#  Be sure to run `pod spec lint CTEncodableObject.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = 'CTEncodableObject'
  s.version      = '0.0.2'
  s.summary      = "Base class which implements NSCoding, NSCopying for encoding, debugging, and quickLook"
  s.description  = <<-DESC
                   This is basically the crux of this class. We iterate through each of our properties using the objc-runtime method class_copyPropertyList(). We then inspect the attributes of each property, ensuring they are not weak and have storage (!readonly && !weak). If the property meets this criterea, we add it to the set of properties and move on to the next one.
                   DESC
  s.homepage     = 'https://github.com/charlieelliott/CTEncodableObject'
  s.license      = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author       = { 'Charlie Elliott' => 'charlie.elliott.m@gmail.com' }
  s.source       = { :git => 'https://github.com/charlieelliott/CTEncodableObject.git', :commit => '33fe908db73ffb4264a666150cbf9268db0047bd' }
  s.source_files = '*.{h,m}'
  s.ios.deployment_target = '6.0'
  s.requires_arc = true
end
