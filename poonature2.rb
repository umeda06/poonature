require 'wiringpi'
#require 'pi_piper'
#require 'json'
#require 'rest-client'

humansensor_in_pin = 0
humansensor_in = WiringPi::GPIO.new
humansensor_in.mode(humansensor_in_pin, INPUT)

endpoint_uri = 'https://trialbot-api.line.me/v1/events'
proxy_uri = 'http://fixie:txWOOjRVVdvzE5O@velodrome.usefixie.com:80'
request_header = {
  'Content-Type' => 'application/json; charset=UTF-8',
  'X-Line-ChannelID' => '1472270926',
  'X-Line-ChannelSecret' => '134d53f572c4c509be1066e020baf96e',
  'X-Line-Trusted-User-With-ACL' => 'u109f2d033f3e461a765c51f7b63be452',
}
request_content = {
  'to' => ['uc44791bb49f8e18b9e54e351af192a4b'],
  'toChannel' => 1383378250,
  'eventType' => '138311608800106203',
}

loop do

  value = 0
  while value == 0 do
    10.times do
      sleep(1)
      value += humansensor_in.read(humansensor_in_pin)
      puts value
    end
  end

  # 人がいる
  #RestClient.proxy = proxy_uri
  #request_content['content'] = {'contentType' => 1, 'toType' => 1, 'text' => "うんち開始"}
  #RestClient.post(endpoint_uri, request_content.to_json, request_header)
  puts "うんち開始"

  while value > 0 do
    value = 0
    10.times do
      sleep(1)
      value += humansensor_in.read(humansensor_in_pin)
      puts value
    end
  end

  # 人がいない
  #RestClient.proxy = proxy_uri
  #request_content['content'] = {'contentType' => 1, 'toType' => 1, 'text' => "うんち終了"}
  #RestClient.post(endpoint_uri, request_content.to_json, request_header)
  puts "うんち終了"

  # においセンサー

  #RestClient.proxy = proxy_uri
  #request_content['content'] = {'contentType' => 1, 'toType' => 1, 'text' => "今日のうん性 512 (0-1023) ヘクサ"}
  #RestClient.post(endpoint_uri, request_content.to_json, request_header)
  puts "今日のうん性 512 (0-1023) ヘクサ"

end
