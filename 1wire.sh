# !/bin/sh
# /etc/init.d/1wire.sh

### BEGIN INIT INFO
# Provides:          1wire.sh
# Required-Start:    $remote_fs $syslog $all
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Simple script to start a program at boot
# Description:       A simple script that will start/stop 1wire measurements at boot/shutdown.
### END INIT INFO

# If you want a command to always run, put it here

# Carry out specific functions when asked to by the system
case "$1" in
  start)
    echo "Starting 1wire"
    # run application you want to start
	cd /home/pi/bin/
	/home/pi/bin/1wire/1wire.pl
    ;;
  stop)
    echo "Stopping 1wire"
    # kill application you want to stop
    killall 1wire.pl
    ;;
  *)
    echo "Usage: /etc/init.d/1wire.sh {start|stop}"
    exit 1
    ;;
esac

exit 0
