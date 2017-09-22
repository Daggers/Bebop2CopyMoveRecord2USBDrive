#! /bin/sh
# This script is for copy media files from internal memory to USB OTG Drive

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
				BLDC_Test_Bench -G 1 0 1  >/dev/null 2>&1
                usleep 500000
                BLDC_Test_Bench -G 0 0 0  >/dev/null 2>&1
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
                BLDC_Test_Bench -G 1 0 0 /dev/null 2>&1
				BLDC_Test_Bench -G 1 0 1 /dev/null 2>&1
                usleep 500000
                BLDC_Test_Bench -G 0 0 0 /dev/null 2>&1
                usleep 500000
        done

        # put back to green. we make the assumption the previous state was
        # green, because we have no way to query it
        sleep 2
        BLDC_Test_Bench -G 0 1 0 >/dev/null 2>&1
fi
}

USBSRC=$(mount | grep sda1 | awk '{ print $1 }')
USBDST=$(mount | grep sda1 | awk '{ print $3 }')
INTMEM=/data/ftp/internal_000

if grep -q Milos /proc/cpuinfo; then
	BBDIR=/Bebop_2
	# Script starts - 4 rotor sounds
	BLDC_Test_Bench -M 1 >/dev/null 2>&1
	sleep 2
else
	BBDIR=/Bebop_Drone
	# Script starts - Red LED
	BLDC_Test_Bench -G 1 0 0 >/dev/null 2>&1
fi
sleep 1

if [ $USBDST = "$INTMEM$BBDIR/media" ]; then
	echo "USBDrive mounted to /data/ftp/internal_000/..."
	Fail
else
	# check if we have USB OTG drive mounted
	if [ -d $USBDST ]; then
		mount -o remount,rw $USBDST
		if [ "$(ls -A $INTMEM$BBDIR/media/)" ]; then
			echo "Copying media to USB OTG drive"
			# Feedback during copying
			if [ $BBDIR == "/Bebop_2" ]; then
				exec /bin/onoffbutton/feedback.sh &
			else
				(BLDC_Test_Bench -G 1 1 0 >/dev/null 2>&1) &
			fi
			# copying media files
			cp -f $INTMEM$BBDIR/media/* $USBDST
			if [ $? -ne 0 ]; then
				kill -9 ` ps | grep feedback.sh | grep -v grep | awk '{print $1}' `
				Fail
			else
				#creates copy_ok file when the copy process is finished
				touch $INTMEM$BBDIR/copy_ok
				# DONE
				if [ $BBDIR == "/Bebop_2" ]; then
					kill -9 ` ps | grep feedback.sh | grep -v grep | awk '{print $1}' `
					sleep 1
					Success
				else
					(BLDC_Test_Bench -G 0 1 0 >/dev/null 2>&1) &
				fi
			fi
		else
			# NOTHING TO COPY. DONE 
			echo "No files to copy! $INTMEM$BBDIR/media/ is empty"
			if [ $BBDIR == "/Bebop_2" ]; then
				f=/sys/devices/platform/leds_pwm/leds/milos:super_led/brightness
				brightness=150
				old_brightness=$(cat $f)
				echo 0 > $f
				usleep 500000
				echo ${brightness} > $f
				BLDC_Test_Bench -M 2 >/dev/null 2>&1
                usleep 500000
                echo 0 > $f
				usleep 500000
				echo ${old_brightness} > $f
			else
				(BLDC_Test_Bench -G 0 1 0 >/dev/null 2>&1; usleep 250000; BLDC_Test_Bench -G 1 1 0 >/dev/null 2>&1; usleep 250000; BLDC_Test_Bench -G 0 1 0 >/dev/null 2>&1; usleep 250000; BLDC_Test_Bench -G 1 1 0 >/dev/null 2>&1; usleep 250000; BLDC_Test_Bench -G 0 1 0 >/dev/null 2>&1; usleep 250000; BLDC_Test_Bench -G 1 1 0 >/dev/null 2>&1; usleep 250000; BLDC_Test_Bench -G 0 1 0 >/dev/null;) &
			fi
		fi
	else
		echo "USB OTG drive not mounted!"
		# ERROR
		Fail
	fi
fi
