import socket
import struct
import RPi.GPIO as GPIO
import can
import time
import os
import queue
from threading import Thread

led = 22

#RPM and SPEED CAN PID of RX-8 Instrument cluster
RPM_PID		=  0x201 

#Engine temperature CAN PID of RX-8 Instrument cluster
TEMP_PID = 0x420
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(led,GPIO.OUT)
GPIO.output(led,True)


count = 0

print('\n\rCAN Rx test')
print('Bring up CAN0....')

# Bring up can0 interface at 500kbps
#the parameter restart-ms is because sometimes the buffer of the can interface becomes full, and the program crashes
os.system("sudo /sbin/ip link set can0 up type can bitrate 500000 restart-ms 200")
time.sleep(0.1)	
print('Press CTL-C to exit')

try:
	bus = can.interface.Bus(channel='can0', bustype='socketcan_native')
except OSError:
	print('Cannot find PiCAN board.')
	GPIO.output(led,False)
	exit()




# Create UDP Server socket.
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# Bind to LFS.
sock.bind(('192.168.1.112', 30000))

try:
    while True:
        # Receive data.
        data = sock.recv(256)

        if not data:
            break # Lost connection
    
        # Unpack the data.
        #struct.unpack('>f', data[16:19])    
        outgauge_pack = struct.unpack('I3sxH2B7f2I3f15sx15sx', data)
        datetime = outgauge_pack[0]
        car = outgauge_pack[1]
        flags = outgauge_pack[2]
        gear = outgauge_pack[3]
        speed = outgauge_pack[5]
        rpm = outgauge_pack[6] #4 bytes
        turbo = outgauge_pack[7]
        engtemp = outgauge_pack[8]
        fuel = outgauge_pack[9]
        oilpressure = outgauge_pack[10]
        oiltemp = outgauge_pack[11]
        dashlights = outgauge_pack[12]
        showlights = outgauge_pack[13]
        throttle = outgauge_pack[14]
        brake = outgauge_pack[15]
        clutch = outgauge_pack[16]
        display1 = outgauge_pack[17]
        display2 = outgauge_pack[18]

        speed = speed * 3600 / 1000 #em KM/s

  

        

        rpm = int(rpm)
        speed = int(speed)

        print("Speed_KMH: "+str(speed))
        print("RPM: "+str(rpm))
      
        #this the formula to calculate the value of the speed necessary to create a byte array
        speed = int(speed*100 +10000)

        velocidade_bytes = speed.to_bytes(2,'big')

        revs = int(136 * rpm / 9000)
        GPIO.output(led,True)
        

        #byte 0 = rpms
        #bytes 4 and 5 = speed
        msg = can.Message(arbitration_id=RPM_PID,data=[revs,0,0,0,velocidade_bytes[0],velocidade_bytes[1],0,0],extended_id=False)
        bus.send(msg)
        
        GPIO.output(led,False)
        

except KeyboardInterrupt:
	#Catch keyboard interrupt
	GPIO.output(led,False)
	os.system("sudo /sbin/ip link set can0 down")
	print('\n\rKeyboard interrtupt')
sock.close()
    # Release the socket.
    

