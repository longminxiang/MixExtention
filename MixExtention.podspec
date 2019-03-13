Pod::Spec.new do |s|
    s.name = 'MixExtention'
    s.version = '1.0.7'
    s.summary = 'Mix Extention'
    s.authors = { 'Eric Long' => 'longminxiang@163.com' }
    s.license = 'MIT'
    s.homepage = "https://github.com/longminxiang/MixExtention"
    s.source  = { :git => "https://github.com/longminxiang/MixExtention.git", :tag => "v" + s.version.to_s }
    s.requires_arc = true
    s.ios.deployment_target = '8.0'

    s.source_files = 'Classes/**/*.{h,m}'
end
