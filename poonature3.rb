require 'wiringpi'
require 'pi_piper'
require 'json'
require 'rest-client'

vh_out_pin = 0
vc_out_pin = 3
extension = 60
threshold = 5

vh = WiringPi::GPIO.new
vc = WiringPi::GPIO.new
vh.mode(vh_out_pin, OUTPUT)
vc.mode(vc_out_pin, OUTPUT)

endpoint_uri = 'https://trialbot-api.line.me/v1/events'
request_header = {
  'Content-Type' => 'application/json; charset=UTF-8',
  'X-Line-ChannelID' => '1472270926',
  'X-Line-ChannelSecret' => '134d53f572c4c509be1066e020baf96e',
  'X-Line-Trusted-User-With-ACL' => 'u109f2d033f3e461a765c51f7b63be452',
}
request_content = {
  'to' => ['uc44791bb49f8e18b9e54e351af192a4b','ua106f450e00d59168cd9289f01017e69'],
  'toChannel' => 1383378250,
  'eventType' => '138311608800106203',
}

Signal.trap(:INT){
  vh.write(vh_out_pin, 0)
  vc.write(vc_out_pin, 0)
  exit(0)
}

odor_initvalue = 0
odor_starttime = Time.now
odor_maxvalue = 0
odor_excount = 0

loop do
  odor = 0
  brightness = 0

  3.times do
    sleep(0.242)
    vh.write(vh_out_pin, 1)
    sleep(0.008)
    vh.write(vh_out_pin, 0)
  end

  sleep(0.237)
  vc.write(vc_out_pin, 1)
  sleep(0.003)
  PiPiper::Spi.begin do |spi|
    raw = spi.write [0b01101000,0]
    odor = ((raw[0]<<8) + raw[1]) & 0x03FF
  end
  sleep(0.002)
  vc.write(vc_out_pin, 0)
  vh.write(vh_out_pin, 1)
  sleep(0.008)
  vh.write(vh_out_pin, 0)
  odor = 1023 - odor

  PiPiper::Spi.begin do |spi|
    raw = spi.write [0b01111000,0]
    brightness = ((raw[0]<<8) + raw[1]) & 0x03FF
  end

  puts Time.now.strftime("%Y/%m/%d") + "," + Time.now.strftime("%H:%M:%S") + "," + (brightness > threshold ? 1023 : 0).to_s + "," + odor.to_s
  RestClient.post('https://toilet2.herokuapp.com:443/odor', :odor => odor.to_s)

  if brightness > threshold then
    if odor_initvalue == 0 then
      odor_initvalue = odor
      odor_starttime = Time.now
      request_content['content'] = {'contentType' => 1, 'toType' => 1, 'text' => "うんち開始(" + odor_starttime.strftime("%H:%M:%S") + ")"}
      RestClient.post(endpoint_uri, request_content.to_json, request_header)
    end
    if odor > odor_maxvalue then
      odor_maxvalue = odor
    end
    odor_excount = 0

  else
    if odor_initvalue != 0 then
      if odor_excount == 0 then
        request_content['content'] = {'contentType' => 1, 'toType' => 1, 'text' => "うんち終了(" + (Time.now-odor_starttime).floor.to_s + "秒使用)"}
        RestClient.post(endpoint_uri, request_content.to_json, request_header)
      end
      if odor_excount < extension then
        if odor > odor_maxvalue then
          odor_maxvalue = odor
        end
        odor_excount = odor_excount + 1
      else
        request_content['content'] = {'contentType' => 1, 'toType' => 1, 'text' => "只今の記録" + odor_maxvalue.to_s + "ヘクサ(" + odor_initvalue.to_s + "から" + (odor_maxvalue-odor_initvalue).to_s + "増加)"}
        RestClient.post(endpoint_uri, request_content.to_json, request_header)
        odor_initvalue = 0
        odor_maxvalue = 0
      end
    end
  end
end
