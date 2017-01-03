#define F_CPU 16000000UL
#define BAUD 9600
#include <pbn.h>
#include <avr/interrupt.h>
#include <avr/io.h>
#include <string.h>
#include <stdbool.h>
#include <util/delay.h>

ISR(PCINT1_vect) {

serial_put('X');
}

bool comprovaBoto(pin_t Boto) {
	return !pin_r(Boto);
}

void envia(char p[]){
	for(int i=0;p[i]!='\0';i++){
		serial_put(p[i]);
	}
}


volatile int contador;

int main(void){
pin_t P0 = pin_create(&PORTB,5,Output);
pin_t P0P = pin_create(&PORTC,0,Input);
pin_t P1 = pin_create(&PORTB,4,Output);
pin_t P1P = pin_create(&PORTC,1,Input);
pin_t P2 = pin_create(&PORTB,3,Output);
pin_t P2P = pin_create(&PORTC,2,Input);
pin_t P3 = pin_create(&PORTB,2,Output);
pin_t P3P = pin_create(&PORTC,3,Input);
pin_t P4 = pin_create(&PORTB,1,Output);
pin_t P4P = pin_create(&PORTC,4,Input);
pin_t P5 = pin_create(&PORTB,0,Output);
pin_t P5P = pin_create(&PORTC,5,Input);

pin_t TANCARPORTES = pin_create(&PORTD,2,Input);
pin_t OBRIRPORTES = pin_create(&PORTD,3,Input);

PCICR =0x02;          // Enable PCINT1 interrupt
PCMSK1 = 0b00000111;
sei();

//serial_open();

while(1){
	_delay_ms(120);
}

return 0;
}


