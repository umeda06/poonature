require 'wiringpi'

vc_out_pin = 3

vc = WiringPi::GPIO.new
vc.mode(vc_out_pin, OUTPUT)

Signal.trap(:INT){
  vc.write(vc_out_pin, 0)
  exit(0)
}

loop do
  vc.write(vc_out_pin, 1)
  sleep(10)
end
