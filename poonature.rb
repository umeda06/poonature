require 'pi_piper'
require 'json'
require 'rest-client'

threshold = 12

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

  while(value < threshold) do
    sleep(1)
    PiPiper::Spi.begin do |spi|
      raw = spi.write [0b01101000,0]
      value = ((raw[0]<<8) + raw[1]) & 0x03FF
    end
    puts value
  end

  # 電気ON
  RestClient.proxy = proxy_uri
  request_content['content'] = {'contentType' => 1, 'toType' => 1, 'text' => "うんち開始"}
  RestClient.post(endpoint_uri, request_content.to_json, request_header)

  while(value >= threshold) do
    sleep(1)
    PiPiper::Spi.begin do |spi|
      raw = spi.write [0b01101000,0]
      value = ((raw[0]<<8) + raw[1]) & 0x03FF
    end
    puts value
  end

  # 電気OFF
  RestClient.proxy = proxy_uri
  request_content['content'] = {'contentType' => 1, 'toType' => 1, 'text' => "うんち終了"}
  RestClient.post(endpoint_uri, request_content.to_json, request_header)

  # においセンサー

  RestClient.proxy = proxy_uri
  request_content['content'] = {'contentType' => 1, 'toType' => 1, 'text' => "今日のうん性 512 (0-1023) ヘクサ"}
  RestClient.post(endpoint_uri, request_content.to_json, request_header)

end
