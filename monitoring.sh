#!/bin/bash

while true; do 
	date >> /tmp/result.txt
	ps -afx >> /tmp/result.txt
	ss -putan >> /tmp/result.txt
done
