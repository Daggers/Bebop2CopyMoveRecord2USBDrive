#! /bin/sh
while true; do
	sleep 15;
	i2ctool -d /dev/i2c-cypress 0x8 0x82 0x1 >/dev/null 2>&1
done
