# require libraries
%w[ rubygems osc-ruby serialport ].each { |lib| require lib }

# connect to arduino
@arduino = SerialPort.new "/dev/tty.usbserial-A800etAZ", 115200

# initial arm position
@shoulder, @forearm, @elbow, @claw = 180, 50, 60, 35

# setup osc server so we can listen for messages from the multi-touch on my iphone
osc_server = OSC::Server.new "razic.local",8001

# these are the osc patterns and their callbacks
# it's callback is triggered when a osc message matching one of our addresses is received
osc_addrs = [
  ["/1/shoulder_forearm", Proc.new { |m| @shoulder, @forearm = *m.instance_variable_get(:@args); }], 
  ["/1/elbow", Proc.new { |m| @elbow = m.instance_variable_get(:@args)[0]; }],
  ["/1/claw", Proc.new { |m| @claw = m.instance_variable_get(:@args)[0]; }]
]
osc_addrs.each { |a| osc_server.add_method a[0], &a[1] }

# run the osc server in a new thread
Thread.new { osc_server.run }

# start telling the arduino where to move the motors
loop do
  # here are our little packets
  ["<", 0, @shoulder.to_i, ">"].each { |byte| @arduino.putc byte } if @shoulder.to_i != @last_shoulder
  ["<", 1, @forearm.to_i, ">"].each { |byte| @arduino.putc byte } if @forearm.to_i != @last_forearm
  ["<", 2, @elbow.to_i, ">"].each { |byte| @arduino.putc byte } if @elbow.to_i != @last_elbow
  ["<", 3, @claw.to_i, ">"].each { |byte| @arduino.putc byte } if @claw.to_i != @last_claw
  
  @last_shoulder = @shoulder.to_i
  @last_forearm = @forearm.to_i
  @last_elbow = @elbow.to_i
  @last_claw = @claw.to_i
  
  puts ".\n"
  
  # who needs sleep?
  sleep 0.02
end