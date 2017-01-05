#define F_CPU 16000000UL
#define BAUD 9600
#include <pbn.h>
#include <avr/interrupt.h>
#include <avr/io.h>
#include <string.h>
#include <stdbool.h>
#include <util/delay.h>
#include <stdlib.h>

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

pin_t P0LED = pin_create(&PORTB,5,Output);
pin_t P1LED = pin_create(&PORTB,4,Output);
pin_t P2LED = pin_create(&PORTB,3,Output);
pin_t P3LED = pin_create(&PORTB,2,Output);
pin_t P4LED = pin_create(&PORTB,1,Output);
pin_t P5LED = pin_create(&PORTB,0,Output);

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
int estat=0;
char a;
char b;

while(1){
  switch(estat){
    case 0:
      //serial_put('0');
      a=serial_get();
      serial_put(a);
      if((a == 'E') || (a=='A') || (a=='D')){
        estat=1;
      }
      break;
    case 1:
      //serial_put('1');
      b=serial_get();
      serial_put(b);
      if((b == 'E') || (b=='A') || (b=='D')){
        estat=1;
        a=b;
      }
      else if(b == '0'){
        estat=2;
      }
      else if(!atoi(&b)){ //No es un numero
        estat=0;
      }
      else{
        estat=2;
      }
      break;
    case 2:
      //serial_put('2');
      switch(a){
        case 'E':
          switch(atoi(&b)){
            case 0:
              pin_w(P0LED,true);
              break;
            case 1:
              pin_w(P1LED,true);
              break;
            case 2:
              pin_w(P2LED,true);
              break;
              case 3:
              pin_w(P3LED,true);
              break;
            case 4:
              pin_w(P4LED,true);
              break;
            case 5:
              pin_w(P5LED,true);
              break;
            }
        break;

      case 'A':
        switch(atoi(&b)){
          case 0:
            pin_w(P0LED,false);
            break;
          case 1:
            pin_w(P1LED,false);
            break;
          case 2:
            pin_w(P2LED,false);
            break;
          case 3:
            pin_w(P3LED,false);
            break;
          case 4:
            pin_w(P4LED,false);
            break;
          case 5:
            pin_w(P5LED,false);
            break;
        }
      break;

      case 'D':
        switch(atoi(&b)){
          case 0:
            PORTD=0x00;
            break;
          case 1:
            PORTD=0x10;
            break;
          case 2:
            PORTD=0x80;
            break;
          case 3:
            PORTD=0x90;
            break;
          case 4:
            PORTD=0x40;
            break;
          case 5:
            PORTD=0x50;
            break;
          }

      break;


    }
    estat=0;


  }


}

return 0;
}
