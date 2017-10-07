#! /bin/sh
# This script is for DELETE media files from internal memory to USB OTG Drive

Success () {
if [ "$(gprop ro.hardware)" = "milosboard" ]; then
        f=/sys/devices/platform/leds_pwm/leds/milos:super_led/brightness
        brightness=150
        old_brightness=$(cat $f)
	echo 0 > $f
        usleep 500000
        for i in 0 1; do
                echo ${brightness} > $f
				i2ctool -d /dev/i2c-cypress 0x8 0x82 0x2 >/dev/null 2>&1
                usleep 500000
                echo 0 > $f
                usleep 500000
        done
	echo ${old_brightness} > $f
elif [ "$(gprop ro.hardware)" = "mykonos3board" ]; then
        # blink red
        for i in 0 1; do
                BLDC_Test_Bench -G 1 0 0 >/dev/null 2>&1
				BLDC_Test_Bench -G 1 0 1 >/dev/null 2>&1
                usleep 500000
                BLDC_Test_Bench -G 0 0 0 >/dev/null 2>&1
                usleep 500000
        done

        # put back to green. we make the assumption the previous state was
        # green, because we have no way to query it
        sleep 2
        BLDC_Test_Bench -G 0 1 0
fi
}

Fail () {
if [ "$(gprop ro.hardware)" = "milosboard" ]; then
        f=/sys/devices/platform/leds_pwm/leds/milos:super_led/brightness
        brightness=150
        old_brightness=$(cat $f)
	echo 0 > $f
        usleep 500000
        for i in 0 1 2 3 4; do
                echo ${brightness} > $f
				i2ctool -d /dev/i2c-cypress 0x8 0x82 0x2 >/dev/null 2>&1
                usleep 500000
                echo 0 > $f
                usleep 500000
        done
	echo ${old_brightness} > $f
elif [ "$(gprop ro.hardware)" = "mykonos3board" ]; then
        # blink red
        for i in 0 1 2 3 4; do
                BLDC_Test_Bench -G 1 0 0
				BLDC_Test_Bench -G 1 0 1
                usleep 500000
                BLDC_Test_Bench -G 0 0 0
                usleep 500000
        done

        # put back to green. we make the assumption the previous state was
        # green, because we have no way to query it
        sleep 2
        BLDC_Test_Bench -G 0 1 0
fi
}

INTMEM=/data/ftp/internal_000

if grep -q Milos /proc/cpuinfo; then
	BBDIR=/Bebop_2
	# Script starts - 4 rotor sounds
	i2ctool -d /dev/i2c-cypress 0x8 0x82 0x1 >/dev/null 2>&1
 	sleep 1
else
	BBDIR=/Bebop_Drone
	# Script starts - Red LED
	(BLDC_Test_Bench -G 1 0 0 >/dev/null 2>&1)
fi

if [ -e $INTMEM$BBDIR/copy_ok ]; then
	echo "Previous copy was successful"
	# delete the files
	echo "Deleting contents of media and thumbs directory"
	# Orange light for Bebop 1 only (feedback)
	if [ $BBDIR == "/Bebop_Drone" ]; then
		(BLDC_Test_Bench -G 1 1 0 >/dev/null 2>&1) &
	fi
	# delete all media files  
	rm -R $INTMEM$BBDIR/thumb/*
	# delete all thumb files 
	rm -R $INTMEM$BBDIR/media/*
	# delete file copy_ok   
	rm -f $INTMEM$BBDIR/copy_ok
	# DONE
	Success
else
	echo "Media were not previously copied! Nothing has been deleted."
	# ERROR
	Fail
fi
