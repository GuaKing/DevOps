#!/usr/bin/expect
set timeout 7200
set USER root
set IP [lindex $argv 0]
set PASS casa


spawn ssh $USER@$IP "reboot"
 expect {
 "(yes/no)?"
  {
    send "yes\n"
    expect "*assword:" { send "$PASS\n"}
  }
 "*assword:"
  {
    send "$PASS\n"
  }
}
expect eof

