#!/usr/bin/env python

import serial  
import sys
import time
import urllib
import webbrowser

#DEFAULTS
sleep = 1
device = "/dev/tty.usbmodemfd131" 

#CONNECT TO SERIAL
try:  
	print "Connecting: ",device
	arduino = serial.Serial(device, 57600) 
except:  
	print "Failed: ",device
	sys.exit(0)
print "Connected: ",device

#READ & WEB v1.0
while True:
	try:
   		rfid = arduino.readline().rstrip('\n')
   		if len(rfid) > 4:
   			url = "http://www.betadeli.com/fu?rfid=" + rfid
	   		print "HTTP GET --->",url
	   		f = urllib.urlopen(url)
	   		s = f.read()
	   		f.close()
	   		print "HTTP GET <--- ",s
	   		if s.find("error") > 0 and s.find("registered") > 0:
				webbrowser.open_new("http://www.betadeli.com/_/wk/checkins/in.html?rfid=" + rfid)
				arduino.write('0') #error
			elif s.find("error") > 0:
				print "error"
				arduino.write('2') #error
			else:
				print "success"
				arduino.write('1') #success
		else:
			print "error"
			arduino.write('0') #error
	except KeyboardInterrupt:
		print "Exiting..."
		sys.exit(1);
	except ValueError:
		pass
	except:
		print "Failed to read serial!"
	time.sleep(sleep)

