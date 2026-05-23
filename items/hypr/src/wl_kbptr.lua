local wl_kbptr_cmd = "pgrep -x wl-kbptr >/dev/null && pkill -x wl-kbptr || timeout -k 1s 15s wl-kbptr"

hl.bind("SUPER + F", hl.dsp.exec_cmd(wl_kbptr_cmd))
