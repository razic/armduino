# require libraries
%w[ rubygems osc-ruby serialport ].each { |lib| require lib }

# connect to arduino
@arduino = SerialPort.new "/dev/tty.usbserial-A800etAZ", 115200, 8, 1, SerialPort::NONE

# initial arm position
@shoulder, @forearm, @elbow, @claw = 180, 50, 60, 35

# setup osc server so we can listen for messages from the multi-touch on my iphone
osc_server = OSC::Server.new "razic.local", 4000

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
  string = ""
  string << "<s#{@shoulder.to_i}>" if @shoulder.to_i != @last_shoulder
  string << "<f#{@forearm.to_i}>" if @forearm.to_i != @last_forearm
  string << "<e#{@elbow.to_i}>" if @elbow.to_i != @last_elbow
  string << "<c#{@claw.to_i}>" if @claw.to_i != @last_claw
  
  # log to stdout
  p string unless string.emtpy?
  
  # talk to arduino
  @arduino.write string unless string.empty?
  
  @last_shoulder = @shoulder.to_i
  @last_forearm = @forearm.to_i
  @last_elbow = @elbow.to_i
  @last_claw = @claw.to_i
  
  sleep 0.002
  # this sleeps for half a second (which is way too long)
  # sleep 0.0000002
end