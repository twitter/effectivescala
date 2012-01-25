all: effectivescala.html

%.html: %.md
	cat $< | bash pre.sh | mmd > $@

.PHONY: all