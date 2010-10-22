require 'rubygems'
require 'soap/wsdlDriver'


def send_by_cm(mobile, content)
  @@srv_cm ||= SOAP::WSDLDriverFactory.new("http://61.144.195.169/cminterface/gsmmodem/sendsms.asmx?WSDL").create_rpc_driver
  @@srv_cm.SendSMS(:sender => "KUGOU", :mobile => mobile, :msg	=> content, :needreport => '0', :ischinese => '1')
end

msg = '欢迎您注册成为会员！您的登录密码为:017218。酷购将通过与手机厂商及国包商的合作关系，以及专业渠道管理，为您提供低价直供服务。详情请登录coolpur.com查询。'
puts msg[0,70]
puts '---'
puts msg[71,200]
#r = send_by_cm('13728770073', msg)
#puts r