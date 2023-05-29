int kroki=0;
int wejscie=-1;
int i=0;
int enable=1;


void setup() {
      Serial.begin(9600);
      pinMode(6,OUTPUT);        //STEP
      pinMode(9,OUTPUT);        //DIR
      pinMode(8,OUTPUT);        //ENABLE
}

void loop() {

while (wejscie<1) {
  wejscie = Serial.read();
}

digitalWrite(8,LOW);
if (wejscie>128) {
  kroki=wejscie-128;
  digitalWrite(9,LOW);
}
else { 
  kroki=wejscie;
  digitalWrite(9,HIGH);
}

for (i=0;i<kroki;i++) {
  digitalWrite(6,HIGH);
  delayMicroseconds(1000);
  digitalWrite(6,LOW);
  delayMicroseconds(1000);
}

Serial.print(kroki);
Serial.print(" ");
Serial.println(wejscie);

digitalWrite(8,HIGH);
wejscie=0;
}

