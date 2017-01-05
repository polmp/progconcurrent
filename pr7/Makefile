CC=avr-gcc
CPPFLAGS=-DF_CPU=16000000UL
CFLAGS=-Wall -std=c99 -Os -mmcu=atmega328p -fshort-enums -Ilibpbn
LDFLAGS=-mmcu=atmega328p
DEVICE=/dev/tty.usbmodem1411
SECONDDEVICE=/dev/tty.usbmodem1421

vpath lib% libpbn 

main: main.o -lpbn

.PHONY: clean veryclean
clean:
	rm -f *~ *.o *.s *.hex

.PHONY: asc
asc:
	avr-objcopy -Oihex main main.hex
	sudo avrdude -c arduino -p atmega328p -P $(DEVICE) -U main.hex
	sudo picocom $(DEVICE)


	

