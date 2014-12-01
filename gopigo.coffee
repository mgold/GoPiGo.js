# This is a coffeescript port of Dexter Industries' Python library for the
# GoPiGo.

# The biggest difference is that it works asynchronously, passing callbacks
# around, rather than returning codes and values.

# This is our i2c library
i2c = require('i2c')

# This is the address for the GoPiGo
address = 0x08

# DO THIS MANUALLY: `ls /devi2c*` and see what device your Pi has
bus = new i2c(address, {device: '/dev/i2c-1'});

#GoPiGo Commands
fwd_cmd				=[119]		#Move forward with PID
motor_fwd_cmd		=[105]		#Move forward without PID
bwd_cmd				=[115]		#Move back with PID
motor_bwd_cmd		=[107]		#Move back without PID
left_cmd			=[97]		#Turn Left by turning off one motor
left_rot_cmd		=[98]		#Rotate left by running both motors is opposite direction
right_cmd			=[100]		#Turn Right by turning off one motor
right_rot_cmd		=[110]		#Rotate Right by running both motors is opposite direction
stop_cmd			=[120]		#Stop the GoPiGo
ispd_cmd			=[116]		#Increase the speed by 10
dspd_cmd			=[103]		#Decrease the speed by 10
volt_cmd			=[118]		#Read the voltage of the batteries
us_cmd				=[117]		#Read the distance from the ultrasonic sensor
led_cmd				=[108]		#Turn On/Off the LED's
servo_cmd			=[101]		#Rotate the servo
enc_tgt_cmd			=[50]		#Set the encoder targeting
fw_ver_cmd			=[20]		#Read the firmware version
en_enc_cmd			=[51]		#Enable the encoders
dis_enc_cmd			=[52]		#Disable the encoders
read_enc_status_cmd	=[53]		#Read encoder status
en_servo_cmd		=[61]		#Enable the servo's	
dis_servo_cmd		=[60]		#Disable the servo's
set_left_speed_cmd	=[70]		#Set the speed of the right motor
set_right_speed_cmd	=[71]		#Set the speed of the left motor
en_com_timeout_cmd	=[80]		#Enable communication timeout
dis_com_timeout_cmd	=[81]		#Disable communication timeout
timeout_status_cmd	=[82]		#Read the timeout status

#LED setup
LED_L=1
LED_R=0

# Synchronous (blocking) sleep calls to let the I2C bus stabilize
sleep = require('sleep')
# Sleep in miliseconds
msleep = (ms) -> sleep.usleep(1000*ms)

#Write I2C block
write_i2c_block = (block) ->
    ret = 1
    bus.writeBytes 1, block, (err) -> ret = -1 if err?
    ret

#Write a byte to the GoPiGo
writeNumber = (value) ->
    ret = 1
    bus.writeByte value, (err) -> ret = -1 if err?
    ret

#Read a byte from the GoPiGo
readByte = () ->
    bus.readByte (err, res) ->
        if err then -1 else res

#Move the GoPiGo forward
fwd = () ->
    write_i2c_block(fwd_cmd.concat [0,0,0])

#Move the GoPiGo forward without PID
motor_fwd = () ->
    write_i2c_block(motor_fwd_cmd.concat [0,0,0])

#Move GoPiGo back
bwd = () ->
    write_i2c_block(bwd_cmd.concat [0,0,0])

#Move GoPiGo back without PID control
motor_bwd = () ->
    write_i2c_block(motor_bwd_cmd.concat [0,0,0])

#Turn GoPiGo Left slow (one motor off, better control)
left = () ->
    write_i2c_block(left_cmd.concat [0,0,0])

#Rotate GoPiGo left in same position (both motors moving in the opposite direction)
left_rot = () ->
    write_i2c_block(left_rot_cmd.concat [0,0,0])

#Turn GoPiGo right slow (one motor off, better control)
right = () ->
    write_i2c_block(right_cmd.concat [0,0,0])

#Rotate GoPiGo right in same position both motors moving in the opposite direction)
right_rot = () ->
    write_i2c_block(right_rot_cmd.concat [0,0,0])

#Stop the GoPiGo
stop = () ->
    write_i2c_block(stop_cmd.concat [0,0,0])

#Increase the speed
increase_speed = () ->
    write_i2c_block(ispd_cmd.concat [0,0,0])

#Decrease the speed
decrease_speed = () ->
    write_i2c_block(dspd_cmd.concat [0,0,0])

#Read voltage
#    return:    voltage in V
volt = () ->
    write_i2c_block(volt_cmd.concat [0,0,0])
    msleep(100)
    b1=readByte()
    b2=readByte()

    if b1!=-1 and b2!=-1
        v=b1*256+b2
        v=(5*v/1024)/.4
        v=v*100 # Prepare to round to two decimal places
        v=Math.round(v)
        v/100
    else
        -1

#Read ultrasonic sensor
#    arg:
#        pin ->     Pin number on which the US sensor is connected
#    return:        distance in cm
us_dist = (pin) ->
    write_i2c_block(us_cmd.concat [pin,0,0])
    msleep(80)
    b1=readByte()
    b2=readByte()
    if b1!=-1 and b2!=-1
        b1*256+b2
    else
        -1

#Set led to the power level
#    arg:
#        l_id:    1 for left LED and 0 for right LED
#        power:    pwm power for the LED's
# API DIFFERENCE: power is coerced into [0,255]
led = (l_id,power) ->
    power = Math.min(255, Math.max(0, power))
    if l_id==LED_L or l_id==LED_R
        write_i2c_block(led_cmd.concat [l_id,power,0])

#Turn led on
#    arg:
#        l_id: 1 for left LED and 0 for right LED
led_on = (l_id) ->
    if l_id==LED_L or l_id==LED_R
        write_i2c_block(led_cmd.concat [l_id,255,0])

#Turn led off
#    arg:
#        l_id: 1 for left LED and 0 for right LED
led_off = (l_id) ->
    if l_id==LED_L or l_id==LED_R
        write_i2c_block(led_cmd.concat [l_id,0,0])

#Set servo position
#    arg:
#        position: angle in degrees to set the servo at
servo = (position) ->
    write_i2c_block(servo_cmd.concat [position,0,0])

#Set encoder targeting on
#arg:
#    m1: 0 to disable targeting for m1, 1 to enable it
#    m2:    1 to disable targeting for m2, 1 to enable it
#    target: number of encoder pulses to target (18 per revolution)
enc_tgt = (m1,m2,target) ->
    if m1>1 or m1<0 or m2>1 or m2<0
        ;
    else
        m_sel=m1*2+m2
        write_i2c_block(enc_tgt_cmd.concat [m_sel,target/256,target%256])

#Returns the firmware version
fw_ver = () ->
    write_i2c_block(fw_ver_cmd.concat [0,0,0])
    msleep(100)
    ver=readByte
    readByte(address)        #Empty the buffer
    if ver!=-1
        ver/10
    else
        -1

#Enable the encoders (enabled by default)
enable_encoders = () ->
    write_i2c_block(en_enc_cmd.concat [0,0,0])

#Disable the encoders (use this if you don't want to use the encoders)
disable_encoders = () ->
    write_i2c_block(dis_enc_cmd.concat [0,0,0])

#Enables the servo
enable_servo = () ->
    write_i2c_block(en_servo_cmd.concat [0,0,0])

#Disable the servo
disable_servo = () ->
    write_i2c_block(dis_servo_cmd.concat [0,0,0])

#Set speed of the left motor
#    arg:
#        speed-> 0-255
set_left_speed = (speed) ->
    if speed >255
        speed =255
    else if speed <0
        speed =0
    write_i2c_block(set_left_speed_cmd.concat [speed,0,0])

#Set speed of the right motor
#    arg:
#        speed-> 0-255
set_right_speed = (speed) ->
    if speed >255
        speed =255
    else if speed <0
        speed =0
    write_i2c_block(set_right_speed_cmd.concat [speed,0,0])

#Set speed of the both motors
#    arg:
#        speed-> 0-255
# Dexter Industries's API returns the result of setting the right motor and
# ignores the result of setting the left. We imitate this behavior.
set_speed = (speed) ->
    if speed >255
        speed =255
    else if speed <0
        speed =0
    setTimeout(set_left_speed,0,speed)
    set_right_speed(speed)

#Enable communication time-out(stop the motors if no command received in the specified time-out)
#    arg:
#        timeout-> 0-65535 (timeout in ms)
enable_com_timeout = (timeout) ->
    write_i2c_block(en_com_timeout_cmd.concat [timeout/256,timeout%256,0])

#Disable communication time-out
disable_com_timeout = () ->
    write_i2c_block(dis_com_timeout_cmd.concat [0,0,0])

#Read the status register on the GoPiGo
#    Gets a byte,     b0-enc_status
#                    b1-timeout_status
#    Return:    list with     l[0]-enc_status
#                        l[1]-timeout_status
read_status = () ->
    st=readByte
    st_reg=[st & (1 <<0),(st & (1 <<1))/2]
    st_reg

#Read encoder status
#    return:    0 if encoder target is reached
read_enc_status = () ->
    st=read_status()
    st[0]

#Read timeout status
#    return:    0 if timeout is reached
read_timeout_status = () ->
    st=read_status()
    st[1]

module.exports = {
    LED_L: 1,
    LED_R: 0,

    fwd: fwd,
    motor_fwd: motor_fwd,
    bwd: bwd,
    motor_bwd: motor_bwd,
    left: left,
    left_rot: left_rot,
    right: right,
    right_rot: right_rot,
    stop: stop,
    increase_speed: increase_speed,
    decrease_speed: decrease_speed,
    volt: volt,
    us_dist: us_dist,
    led: led,
    led_on: led_on,
    led_off: led_off,
    servo: servo,
    enc_tgt: enc_tgt,
    fw_ver: fw_ver,
    enable_encoders: enable_encoders,
    disable_encoders: disable_encoders,
    enable_servo: enable_servo,
    disable_servo: disable_servo,
    set_left_speed: set_left_speed,
    set_right_speed: set_right_speed,
    set_speed: set_speed,
    enable_com_timeout: enable_com_timeout,
    disable_com_timeout: disable_com_timeout,
    read_status: read_status,
    read_enc_status: read_enc_status,
    read_timeout_status: read_timeout_status
}
