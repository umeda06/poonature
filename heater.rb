require 'wiringpi'

vh_out_pin = 0

vh = WiringPi::GPIO.new
vh.mode(vh_out_pin, OUTPUT)

Signal.trap(:INT){
  vh.write(vh_out_pin, 0)
  exit(0)
}

loop do
  vh.write(vh_out_pin, 1)
  #sleep(0.008)
  #vh.write(vh_out_pin, 0)
  #sleep(0.242)
  sleep(10)
end
