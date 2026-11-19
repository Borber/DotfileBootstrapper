local binger_cmd = "pgrep -x binger >/dev/null && pkill -x binger || binger"

hl.bind("SUPER + F", hl.dsp.exec_cmd(binger_cmd))
