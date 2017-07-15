#! /bin/sh
while true; do
	sleep 15;
	BLDC_Test_Bench -M 1 >/dev/null 2>&1
done
