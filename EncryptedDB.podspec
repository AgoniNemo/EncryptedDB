
Pod::Spec.new do |s|
  s.name             = 'EncryptedDB'
  s.version          = '0.2.0'
  s.summary          = 'EncryptedDB.'

  s.description      = '加密数据库EncryptedDB，静态库'

  s.homepage         = 'https://github.com/AgoniNemo/EncryptedDB'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'AgoniNemo' => 'XZC168520@163.com' }
  s.source           = { :git => 'https://github.com/AgoniNemo/EncryptedDB.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.source_files = 'EncryptedDB/Classes/*.h'

if ENV['sys']
    s.subspec 'Database' do |d|
      d.dependency 'FMDB/SQLCipher', '~> 2.7.5'
      d.source_files = 'EncryptedDB/Classes/Database/*.{h,m}'
    end
else
    s.vendored_frameworks = 'EncryptedDB/Products/*.{framework}'
end
  #s.subspec 'Database' do |d|
      # d.dependency 'EncryptedDB/FileManager'
      #d.dependency 'FMDB/SQLCipher', '~> 2.7.5'
      #d.source_files = 'EncryptedDB/Classes/Database/*.{h,m}'
  #end
  
  # s.subspec 'FileManager' do |f|
      #f.source_files = 'EncryptedDB/Classes/FileManager/*.{h,m}'
  # end
  
  # s.resource_bundles = {
  #   'EncryptedDB' => ['EncryptedDB/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'FMDB/SQLCipher', '~> 2.7.5'
end
