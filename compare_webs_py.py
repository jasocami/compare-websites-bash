#!/usr/bin/env python
# Powered by Jason
import argparse
import sys
import subprocess
import json

def checkSite(domain: str, compare: bool, verbose: bool) -> None:
	"""
	Example:
	- domain: www.google.com
	- compare: true/false
	- verbose: true/false
	"""
	answer = subprocess.check_output(["./compare_webs.sh","-d", domain, "-c", compare, "-v", verbose])
	if verbose: 
		print(f"JSON: {answer}")
	s = json.loads(answer)

	status = s.get('status', None)
	msg = s.get('msg', None)
	mfile = s.get('file', None)

	if verbose: 
		print(f"status: {status}")
		print(f"MSG: {msg}")
		print(f"File: {mfile}")

		if status == 0: #  all OK
			print('All ok')
		elif status == 1: # differences found send compared file
			print("sending email with attachment...")
		elif status == 2: #  other error
			print('Error')


class MyParser(argparse.ArgumentParser):
    def error(self, message):
        sys.stderr.write('error: %s\n' % message)
        self.print_help()
        sys.exit(2)


if __name__ == "__main__":
	parser = MyParser()
	parser.add_argument('arr', nargs='+', help="List of websites to check. Ex: foo bar boo")
	
	if len(sys.argv) == 1:
		parser.print_help(sys.stderr)
		sys.exit(1)
	
	args = parser.parse_args()
	
	for ws in args.arr:
		checkSite(ws, True, False)
