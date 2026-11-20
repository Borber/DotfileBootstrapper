hl.bind("SUPER + F", hl.dsp.exec_cmd("/usr/bin/binger"))
hl.layer_rule({ match = { namespace = "binger" }, no_anim = true })
