#define F_CPU 16000000UL
#define BAUD 9600
#include <pbn.h>
#include <avr/interrupt.h>
#include <avr/io.h>
#include <string.h>
#include <stdbool.h>
#include <util/delay.h>

static pin_t P0;
static pin_t P1;
static pin_t P2;
static pin_t P3;
static pin_t P4;
static pin_t P5;
static pin_t TANCARPORTES;
static pin_t OBRIRPORTES;

ISR(PCINT1_vect){
  if(!pin_r(P0)){
    serial_put('B');
    serial_put('0');
    serial_put('\n');
    serial_put('\r');
  }
  else if(!pin_r(P1)){
    serial_put('B');
    serial_put('1');
    serial_put('\n');
    serial_put('\r');
  }
  else if(!pin_r(P2)){
    serial_put('B');
    serial_put('2');
    serial_put('\n');
    serial_put('\r');
  }
  else if(!pin_r(P3)){
    serial_put('B');
    serial_put('3');
    serial_put('\n');
    serial_put('\r');
  }
  else if(!pin_r(P4)){
    serial_put('B');
    serial_put('4');
    serial_put('\n');
    serial_put('\r');
  }
  else if(!pin_r(P5)){
    serial_put('B');
    serial_put('5');
    serial_put('\n');
    serial_put('\r');
  }
  else{
    //serial_put('F');
  }
  _delay_ms(150);

}

ISR(PCINT2_vect){
  if(!pin_r(TANCARPORTES)){
    serial_put('T');
    serial_put('P');
    serial_put('\n');
    serial_put('\r');
  }

  else if(!pin_r(OBRIRPORTES)){
    serial_put('O');
    serial_put('P');
    serial_put('\n');
    serial_put('\r');
  }
  else{

  }

_delay_ms(150);
}



int main(void){

P0 = pin_create(&PORTC,0,Input);
P1 = pin_create(&PORTC,1,Input);
P2 = pin_create(&PORTC,2,Input);
P3 = pin_create(&PORTC,3,Input);
P4 = pin_create(&PORTC,4,Input);
P5 = pin_create(&PORTC,5,Input);
/*
pin_t P0LED = pin_create(&PORTB,5,Output);
pin_t P1LED = pin_create(&PORTB,4,Output);
pin_t P2LED = pin_create(&PORTB,3,Output);
pin_t P3LED = pin_create(&PORTB,2,Output);
pin_t P4LED = pin_create(&PORTB,1,Output);
pin_t P5LED = pin_create(&PORTB,0,Output);
*/

TANCARPORTES = pin_create(&PORTD,2,Input);
OBRIRPORTES = pin_create(&PORTD,3,Input);

//Activem les interrupcions PCI1 i PCI2
PCICR&=0b11111000;
PCICR|=0b00000110;

//Configuracio pisos
//PortC -> Necessitem interrupció PCI1
//PCMSK1 ->
PCMSK1&=0b10000000;
PCMSK1|=0b00111111;

//Configuracio portes
//PortD2/D3 -> Necessitem interrupció PCI2
//PCMSK -> Nomes
PCMSK2&=0b00000000;
PCMSK2|=0b00001100;

sei();

serial_open();

while(1);

return 0;
}
