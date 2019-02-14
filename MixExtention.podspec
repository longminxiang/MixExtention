Pod::Spec.new do |s|
    s.name = 'MixExtention'
    s.version = '1.0.0'
    s.summary = 'Mix Extention'
    s.authors = { 'Eric Long' => 'longminxiang@163.com' }
    s.license = 'MIT'
    s.homepage = "https://dev.tencent.com/u/ericlung/p/MixExtention/git"
    s.source  = { :git => "https://git.dev.tencent.com/ericlung/MixExtention.git", :tag => "v" + s.version.to_s }
    s.requires_arc = true
    s.ios.deployment_target = '8.0'

    s.source_files = 'Classes/**/*.{h,m}'
end
