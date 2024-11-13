#!/usr/bin/env python
# -*- coding: utf-8 -*-
#Powered by Jason
import subprocess
import json

def checkSite(domain, compare, verbose):
	answer = subprocess.check_output(["./compare_webs.sh","-d", "www.google.es", "-c", "true", "-v", "false"])
	print "JSON: ", answer
	s = json.loads(answer)

	status = s.get('status', None)
	msg = s.get('msg', None)
	mfile = s.get('file', None)

	print "status: ", status
	print "MSG:    ", msg
	print "File:   ", mfile

	if status == 0: #  all OK
		pass
	elif status == 1: # differences found send compared file
		print "sending email with attachment..." 
	elif status == 2: #  other error
		pass


arr = ["www.google.es", "www.apple.com"]

for s in arr:
	checkSite(s, True, False)
