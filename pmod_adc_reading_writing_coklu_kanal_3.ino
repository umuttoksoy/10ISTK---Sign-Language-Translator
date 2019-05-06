int SCL_Clock = 11;
int SDA_Data = 12;
boolean led_durumu = LOW;
boolean wStart=LOW,wStop=LOW,rStart=LOW,rStop=LOW,clk=0;
boolean address[17]={0,1,0,1,0,0,0,0,0,1,1,1,1,0,0,0,0};
boolean readingAdress[8]={0,1,0,1,0,0,0,1};
boolean okunanData[64];
int okunan_kanal_sayisi=0;
int writeSayac=0;
boolean readAckFlag=0;
int readCounter=0,okunanCounter=0;

//-----------------------------------------
int k=0;
int i=15;
int ii=31;
int iii=47;
int iiii=63;
boolean olcmeyi_durdur=0;
int olcmeyi_durdur_pin=10;
int dec_data=0;
int dec_data_kanal;
int dec_data2_kanal;
int dec_data3_kanal;
int dec_data4_kanal;
boolean a,b;
int dec_data2=0;
int dec_data3=0;
int dec_data4=0;
int sayacc=0;
int p1,p2,p3,p4;
void setup(){

  Serial.begin(19200);
  pinMode(SCL_Clock,OUTPUT);
  pinMode(SDA_Data,OUTPUT);
  digitalWrite(SCL_Clock,1);
  digitalWrite(SDA_Data,1);
  
  cli();
  // Timer1 
  TCNT1  = 0;
  TCCR1A = 0;
  TCCR1B = 0;
  //OCR1A = 62499; 
  OCR1A = 1599;
  TCCR1B |= (1 << WGM12);
  TCCR1B |= (0 << CS12) | (0 << CS11) | (1 << CS10);
  TIMSK1 |= (1 << OCIE1A);
  sei();
}


ISR(TIMER1_COMPA_vect){     
 clk=!clk;
 digitalWrite(SCL_Clock,clk);
 writing();
 reading();  
 }

void writing(){
  if(!wStop){
   if((wStart==0)&& (wStop==0)&&digitalRead(SDA_Data)&&digitalRead(SCL_Clock)){
    digitalWrite(SDA_Data,0);
    wStart=1;
  }
  else if((digitalRead(SCL_Clock)==0)&&(writeSayac!=8)&&!(writeSayac>=17)){
    digitalWrite(SDA_Data,address[writeSayac]);
    Serial.println(writeSayac);
    writeSayac++;
  }
  else if(!(writeSayac>17)){
    if(!digitalRead(SCL_Clock)){
      pinMode(SDA_Data,INPUT);
      if((!digitalRead(SDA_Data))){
      writeSayac++;
      
      Serial.println("  ***first ack received succesfully***");  
    }
    else{
      Serial .begin("ack doesn't received");
     }
    pinMode(SDA_Data,OUTPUT);
    }
   }
 if(!digitalRead(SCL_Clock)&&(writeSayac==18)){
   digitalWrite(SDA_Data,0);
 }
else if(digitalRead(SCL_Clock)&&(writeSayac==18)){
  digitalWrite(SDA_Data,1);
 // writeSayac=0;
  Serial.println("adrress and configuraitons are done");
  wStop=1;
  }
 } 
}

void reading(){
         
if(!rStop){

  if((wStop==1) && (rStart==0) && (rStop==0)){ 
    //Serial.println("if 1");
    if(digitalRead(SCL_Clock)==1){ 
      //Serial.println("if 2");
      pinMode(SDA_Data, OUTPUT);
      digitalWrite(SDA_Data,1);
      delay(1);
      digitalWrite(SDA_Data,0);
      rStart=1; 
    }
   }  
   else if((wStop==1) && (rStart==1) && (rStop==0)) { // 
   
           if((digitalRead(SCL_Clock)==0) && (readCounter<8)){ 
              digitalWrite(SDA_Data,readingAdress[readCounter]);
              readCounter++;
              
            } 
           else if((digitalRead(SCL_Clock)==0) && (readCounter==8)){ 
            //Serial.println("if 5");
           // Serial.println(readCounter);
            readAckFlag=1;
                  // inputa çek 
                  pinMode(SDA_Data, INPUT);                  
            }
            else if((readAckFlag)&&(digitalRead(SCL_Clock)==1) && (readCounter==8)){
                 
                 // Serial.println("if 6");
                  if( !digitalRead(SDA_Data)){
                 
                   readCounter++; 
                   readAckFlag=0;
                  }
                  else{
                    Serial.println("reading ack couldn't sent");
                  }
            } 
            else if((digitalRead(SCL_Clock)==1) && (readCounter>8) &&(readCounter<17) ){ 
              
              okunanData[okunanCounter]=digitalRead(SDA_Data);
              okunanCounter++;
              readCounter++;
             // Serial.println("if 7");
            }
            else if((digitalRead(SCL_Clock)==0) && (readCounter==17)){ 
              
              pinMode(SDA_Data, OUTPUT);
              digitalWrite(SDA_Data, 0);
               
              
            } 
            else if((digitalRead(SCL_Clock)==1)&& (readCounter==17)){
                readCounter++;
                //Serial.println("if 8");
              }
            else if((digitalRead(SCL_Clock)==0) && (readCounter==18)){ 
              
              pinMode(SDA_Data, INPUT);
            
            }
            else if((digitalRead(SCL_Clock)==1) && (readCounter>17) && (readCounter<26)){ 
              
              okunanData[okunanCounter]=digitalRead(SDA_Data);
               okunanCounter++;
              readCounter++;
            
            }
            else if((digitalRead(SCL_Clock)==0) &&  (readCounter==26)){ 
              
              pinMode(SDA_Data, OUTPUT);
              digitalWrite(SDA_Data, 0);
              
              readCounter++;
              
            }
            else if(digitalRead(SCL_Clock)==0 &&(readCounter==27) ){ 
               
               okunan_kanal_sayisi++;
               readCounter=9;
               pinMode(SDA_Data, INPUT);
               if(okunan_kanal_sayisi==4){
                rStop=1;
               }
             
              }
             else if(digitalRead(SCL_Clock)==1 &&(readCounter==27)&&(rStop==1) )  {
               pinMode(SDA_Data, OUTPUT);
              digitalWrite(SDA_Data, 1);
             }
            
  }
 } 
}

void loop(){
  
  if(rStop){
    for(int l=0;l<64;l++){
      
      if(l==15 || l==31 || l== 47  ){
        
      }
    }
    Serial.println();
    
    while(i>3){
     
      dec_data= dec_data + pow(2,(15-i))*int(okunanData[i]);
      i=i-1; 
        
    }
   
     while(ii>19){
    
      dec_data2= dec_data2 + pow(2,(31-ii))*int(okunanData[ii]);
      ii=ii-1;   
    }
    
     
     while(iii>35){
    
      dec_data3= dec_data3 + pow(2,(47-iii))*int(okunanData[iii]);
      iii=iii-1;   
    }
     
     while(iiii>51){
    
      dec_data4= dec_data4 + pow(2,(63-iiii))*int(okunanData[iiii]);
      iiii=iiii-1;   
    }
     
    
    if(okunanData[2]==0 &&  okunanData[3]==0){
    dec_data_kanal=1;
    p1=dec_data;
    }
    else if(okunanData[2]==0 &&  okunanData[3]==1){
     dec_data_kanal=2; 
     p2=dec_data;
    }
    else if(okunanData[2]==1 &&  okunanData[3]==0){
     dec_data_kanal=3; 
     p3=dec_data;
    }
    else if(okunanData[2]==1 &&  okunanData[3]==1){
     dec_data_kanal=4; 
     p4=dec_data;
    }
//---------------------------------------------------
     if(okunanData[18]==0 &&  okunanData[19]==0){
    dec_data2_kanal=1;
    p1=dec_data2;
    }
    else if(okunanData[18]==0 &&  okunanData[19]==1){
     dec_data2_kanal=2; 
     p2=dec_data2;
    }
    else if(okunanData[18]==1 &&  okunanData[19]==0){
     dec_data2_kanal=3; 
     p3=dec_data2;
    }
    else if(okunanData[18]==1 &&  okunanData[19]==1){
     dec_data2_kanal=4; 
     p4=dec_data2;
    }
    
    //---------------------------------------------------
     if(okunanData[34]==0 &&  okunanData[35]==0){
    dec_data3_kanal=1;
    p1=dec_data3;
    }
    else if(okunanData[34]==0 &&  okunanData[35]==1){
     dec_data3_kanal=2;
     p2=dec_data3; 
    }
    else if(okunanData[34]==1 &&  okunanData[35]==0){
     dec_data3_kanal=3; 
     p3=dec_data3;
    }
    else if(okunanData[34]==1 &&  okunanData[35]==1){
     dec_data3_kanal=4;
     p4=dec_data3; 
    }
    //---------------------------------------------------
     if(okunanData[50]==0 &&  okunanData[51]==0){
    dec_data4_kanal=1;
    p1=dec_data4;
    }
    else if(okunanData[50]==0 &&  okunanData[51]==1){
     dec_data4_kanal=2; 
     p2=dec_data4;
    }
    else if(okunanData[50]==1 &&  okunanData[51]==0){
     dec_data4_kanal=3;
     p3=dec_data4; 
    }
    else if(okunanData[50]==1 &&  okunanData[51]==1){
     dec_data4_kanal=4; 
     p4=dec_data4;
    }
   
    
   

    Serial.print("p1: ");
    Serial.println(p1);
    Serial.print("p2: ");
    Serial.println(p2);
    Serial.print("p3: ");
    Serial.println(p3);
    Serial.print("p4: ");
    Serial.println(p4);

    if(((p1>2600)&&(p1<2720)) && ((p2>1500)&&(p2<2100)) && ((p3>1500)&&(p3<2100)) && ((p4>1500)&&(p4<2150))){
      Serial.println("A");
    }
    if(((p1>2150)&&(p1<2550)) && ((p2>2650)&&(p2<4000)) && ((p3>2700)&&(p3<4000)) && ((p4>2800)&&(p4<4000))){
      Serial.println("B");
    }
    if(((p1>2450)&&(p1<2750)) && ((p2>2400)&&(p2<2700)) && ((p3>2450)&&(p3<2750)) && ((p4>2550)&&(p4<2800))){
      Serial.println("C");
    }
    if(((p1>2270)&&(p1<2550)) && ((p2>2750)&&(p2<4000)) && ((p3>2200)&&(p3<2400)) && ((p4>2200)&&(p4<2450))){
      Serial.println("D");
    }
    if(((p1>2100)&&(p1<2400)) && ((p2>1900)&&(p2<2340)) && ((p3>2150)&&(p3<2420)) && ((p4>2000)&&(p4<2300))){
      Serial.println("E");
    }
    if(((p1>2250)&&(p1<2600)) && ((p2>1850)&&(p2<2250)) && ((p3>2650)&&(p3<4000)) && ((p4>2850)&&(p4<4000))){
      Serial.println("F");
    }
    if(((p1>2520)&&(p1<2700)) && ((p2>2700)&&(p2<4000)) && ((p3>2000)&&(p3<2250)) && ((p4>2000)&&(p4<2250))){
      Serial.println("G");
    }
    if(((p1>2400)&&(p1<2700)) && ((p2>2680)&&(p2<4000)) && ((p3>2650)&&(p3<4000)) && ((p4>2000)&&(p4<2340))){
      Serial.println("H");
    }
    
    if(((p1>2700)&&(p1<2855)) && ((p2>2660)&&(p2<4000)) && ((p3>2600)&&(p3<4000)) && ((p4>2080)&&(p4<2315))){
      Serial.println("K");
    }
    if(((p1>2700)&&(p1<4000)) && ((p2>2650)&&(p2<4000)) && ((p3>1900)&&(p3<2200)) && ((p4>1900)&&(p4<2200))){
      Serial.println("L");
    }
    
    if(((p1>2400)&&(p1<2650)) && ((p2>2010)&&(p2<2390)) && ((p3>2220)&&(p3<2440)) && ((p4>2280)&&(p4<2520))){
      Serial.println("O");
    }
    if(((p1>2600)&&(p1<2750)) && ((p2>2735)&&(p2<4000)) && ((p3>2350)&&(p3<2500)) && ((p4>2100)&&(p4<2340))){
      Serial.println("P");
    }
   
    if(((p1>2000)&&(p1<2500)) && ((p2>1500)&&(p2<2040)) && ((p3>1800)&&(p3<2100)) && ((p4>1900)&&(p4<2240))){
      Serial.println("S");
    }
    if(((p1>2400)&&(p1<2690)) && ((p2>2050)&&(p2<2335)) && ((p3>2000)&&(p3<2275)) && ((p4>2000)&&(p4<2265))){
      Serial.println("T");
    }
    if(((p1>2250)&&(p1<2420)) && ((p2>2820)&&(p2<4000)) && ((p3>2700)&&(p3<4000)) && ((p4>2115)&&(p4<2300))){
      Serial.println("U");
    }
   
    if(((p1>1700)&&(p1<2240)) && ((p2>2230)&&(p2<2600)) && ((p3>2140)&&(p3<2340)) && ((p4>2140)&&(p4<2400))){
      Serial.println("X");
    }
    if(((p1>2710)&&(p1<4000)) && ((p2>1500)&&(p2<2215)) && ((p3>1500)&&(p3<2260)) && ((p4>1500)&&(p4<2390))){
      Serial.println("Y");
    }
    
    
      
    rStart=0;
    rStop=0;
    readCounter=0;
    okunanCounter=0;
    readAckFlag=0;
    i=15;
    dec_data=0;
    ii=31;
    dec_data2=0;
    iii=47;
    dec_data3=0;
    iiii=63;
    dec_data4=0;
    okunan_kanal_sayisi=0;
    dec_data_kanal=0;
    dec_data2_kanal=0;
    dec_data3_kanal=0;
    dec_data4_kanal=0; 
  }
 if(sayacc==1000){
   while(1);
 }
 delay(1000);
sayacc++;
}
