#! /bin/bash


cpu_led_on=71
gpu_led_on=$cpu_led_on

cpu_led_blink=74
gpu_led_blink=$cpu_led_blink


measure_every=10 # every 10 seconds

while [ true ]; do

	cpu1=$(</sys/class/thermal/thermal_zone0/temp)
	cpu_int=$((cpu1/1000))

	gpu1=$(/opt/vc/bin/vcgencmd measure_temp)
	gpu=$(echo "$gpu1"|sed -e 's#^.*=##'|sed -e 's#.C.*$##')
	gpu_int=$(echo "$gpu1"|sed -e 's#^.*=##'|sed -e 's#\..*$##')

	led=0 # 0->off, 1->on, 2->blink

	if [ $gpu_int -ge $gpu_led_on ]; then
		led=1
	else
		if [ $cpu_int -ge $cpu_led_on ]; then
			led=1
		fi
	fi

	if [ "$led""x" == "1x" ]; then
		if [ $gpu_int -ge $gpu_led_blink ]; then
			led=2
		else
			if [ $cpu_int -ge $cpu_led_blink ]; then
				led=2
			fi
		fi
	fi



	if [ "$led""x" == "1x" ]; then
		# turn led on
		sudo bash -c  'echo default-on > /sys/class/leds/led0/trigger'
	elif [ "$led""x" == "2x" ]; then
		# make led blink
		sudo bash -c  'echo heartbeat > /sys/class/leds/led0/trigger'
	else
		# turn led off
		sudo bash -c  'echo none > /sys/class/leds/led0/trigger'
	fi

	sleep $measure_every

done
