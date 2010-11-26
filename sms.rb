require 'rubygems'
require 'json'
require 'net/http'
require 'soap/wsdlDriver'
require 'active_record'

class SmsDB < ActiveRecord::Base
  self.abstract_class = true
  establish_connection(
   :adapter  => "mysql",
   :database => "coolpur_sms",
   :encoding => "utf8",
   :username => "root",
   :password => 'liangyihua',
   :host     => 'localhost'
  )
end
class Msg < SmsDB
  def to_s
    "#{self.id}) #{self.address} #{self.sendee} : #{self.created_at.strftime("%Y-%m-%d %H:%M")}"
  end
end

class Sms
  def initialize
    @sms_cfg = {
      :wsdl => 'http://211.157.113.148:8060/webservice.asmx?WSDL',
      :sn => 'SDK-SKY-010-00281',
      :psw => '092395'
    }

    @service = SOAP::WSDLDriverFactory.new(@sms_cfg[:wsdl]).create_rpc_driver
    # @service.wiredump_file_base = "soap-log.txt"
  end

  def balance
    begin
      @service.GetBalance(:sn => @sms_cfg[:sn], :pwd => @sms_cfg[:psw]).getBalanceResult.to_i
    #rescue
    #  -1
    end
  end

  def send(mobile, content)
    begin
      @service.SendSMS(:sn => @sms_cfg[:sn], :pwd => @sms_cfg[:psw], :mobile => mobile, :content => content).sendSMSResult.to_i
    rescue
      -1
    end
  end
end



def get_new_messages
  begin
   resp = Net::HTTP.get_response(URI.parse(@@base_url + 'get_new_messages'))
   JSON.parse(resp.body)
  rescue
    []
  end
end

def retrieve_data
    msgs = get_new_messages
    msgs.each do |msg|
      op = '[NEW] '
      m = Msg.new
      msg["msg"].to_a.each {|k,v| m[k] = v}
      if Msg.find_by_id(m.id)
        op = '[skip] '
      else
        m.save
      end
      puts op + m.to_s
    end
    msgs.count
end

def send_sms
  print "1-HaoYiTong, 2-CaiMeng"
  r = gets.chomp.upcase[0]
  Msg.all(:conditions => 'status=0 and msg_type="SMS"').each do |msg|
    @@sms.send(msg.address, msg.msg_body) if r == ?1
    send_by_cm(msg.address, msg.msg_body) if r == ?2

    msg.status = 1
    msg.save!
    puts msg.address + ": " + msg.msg_body
    puts msg.to_s
    puts '----------'
  end
end
def send_by_cm(mobile, content)
  @@srv_cm ||= SOAP::WSDLDriverFactory.new("http://61.144.195.169/cminterface/gsmmodem/sendsms.asmx?WSDL").create_rpc_driver
  @@srv_cm.SendSMS(:sender => "KUGOU", :mobile => mobile, :msg	=> content, :needreport => '0', :ischinese => '1')
end
def send_sms_by_hyt
  Msg.all(:conditions => 'status=0 and msg_type="SMS"').each do |msg|
    @@sms ||= Sms.new
    @@sms.send(msg.address, msg.msg_body)

    msg.status = 1
    msg.save!
    puts msg.address + ": " + msg.msg_body
    puts msg.to_s
    puts '----------'
  end
end
def send_sms_by_cm
  Msg.all(:conditions => 'status=0 and msg_type="SMS"').each do |msg|
    send_by_cm(msg.address, msg.msg_body)

    msg.status = 1
    msg.save!
    puts msg.address + ": " + msg.msg_body
    puts msg.to_s
    puts '----------'
  end
end

def update_status
  ids1 = []
  Msg.all(:conditions => 'status=0').each {|msg| ids1 <<  msg.id}

  ids2 = []
  Msg.all(:conditions => 'status=1').each {|msg| ids2 <<  msg.id}

  res = Net::HTTP.post_form(URI.parse(@@base_url + 'update_messages_status'), {'s1' => ids1.join(','), 's2' => ids2.join(',')})
  puts res.body
end

def get_balance
  puts 'Balace: ' + @@sms.balance.to_s
end



def quit?
  begin
    # See if a 'Q' has been typed yet
    while c = STDIN.read_nonblock(1)
      return true if c == 'Q' or c == 'q'
    end
    # No 'Q' found
    false
  rescue Errno::EINTR
    puts "Well, your device seems a little slow..."
    false
  rescue Errno::EAGAIN
    # nothing was ready to be read
    false
  rescue EOFError
    # quit on the end of the input stream
    # (user hit CTRL-D)
    puts "Who hit CTRL-D, really?"
    true
  end
end

def auto_run
  i = 0
  puts "\nPress Q<enter> to Quit."
  loop do
    i = i + 1
    print i.to_s + ', '
    STDOUT.flush
    break if quit?

    if retrieve_data > 0
      update_status
      send_sms_by_hyt
      update_status
      get_balance
    end
    sleep 15
  end
end
def auto_run_cm
  i = 0
  puts "\nPress Q<enter> to Quit."
  loop do
    i = i + 1
    print i.to_s + ', '
    STDOUT.flush
    break if quit?

    if retrieve_data > 0
      update_status
      send_sms_by_cm
      update_status
    end
    sleep 15
  end
end



@@base_url = 'http://www.coolpur.com/etl/'
#@@sms = Sms.new
while 1 do
  system('clear')
  print 'R:read messages, S:send, U:update status, B:balance, A:auto, C:auto(CM), Q:quit'
  cmd = gets.chomp.upcase[0]

  exit if cmd == ?Q

  retrieve_data if cmd == ?R
  send_sms if cmd == ?S
  update_status if cmd == ?U
  get_balance if cmd == ?B
  auto_run if cmd == ?A
  auto_run_cm if cmd == ?C

  puts "\n-----------------\nPress ENTER to continue."
  gets
end