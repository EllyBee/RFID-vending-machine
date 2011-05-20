#!/usr/bin/env python

import serial  
import sys
import time
import urllib
import re

#DEFAULTS
device = "/dev/tty.usbmodemfd131" 
sleep = 15 #n seconds delay between HTTP requests
oldCheckins = 0
newCheckins = 0

#CONNECT TO SERIAL
try:  
	print "Connecting: ",device
	arduino = serial.Serial(device, 57600) 
except:  
	print "Failed: ",device
	sys.exit(0)
print "Connected: ",device

#READ & WEB v1.0
time.sleep(1) #one second delay to allow for arduino to warm up
while True:
	try:
   		url = "http://graph.facebook.com/147617251941131/"
	   	print "HTTP GET --->",url
	   	f = urllib.urlopen(url)
	   	s = f.read()
	   	f.close()
	   	#print "HTTP GET <--- ",s
		m = re.search('(?<="checkins":)\d+', s)
		if m != None:
			newCheckins = int(m.group(0))
		print "checkins:",oldCheckins,"/",newCheckins
		if newCheckins > oldCheckins:
			oldCheckins = newCheckins
			print "writing 1 to arduino..."
			arduino.write('1') #success
	except KeyboardInterrupt:
		print "Exiting..."
		sys.exit(1)
	except ValueError:
		pass
	try:
		time.sleep(sleep)
	except KeyboardInterrupt:
		print "Exiting..."
		sys.exit(1)

