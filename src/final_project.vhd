library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity final_project is
Port ( 
        ----error trial leds
     hata_ledleri  : out std_logic:='0';
	 ----final_project variables
	 main_clk_125 : in std_logic; 
	 sda_data_output : inout  std_logic;
	 scl_clock : out std_logic:='0'; 
	 error_writing_reading : out std_logic_vector(1 downto 0):="00";
	 kontrol_ledleri : inout std_logic_vector(3 downto 0):="0000";
	 ---------------------------------------------------------------
	 ----vga_driver variables----
	 rst_main :in std_LOGIC; -- button[0]
	 hsync_main :out std_logic;
	 vsync_main :out std_logic;
	 r_main :out std_logic;
	 g_main :out std_logic;
	 b_main :out std_logic;
	 rgb_renk_main :in std_logic_vector(2 downto 0); -- color arrangement pins  sw0->R sw1->G sw2->B 
	 harf_secilsinmi_main: in std_logic ---- button(buttn[1]) that allows you to print the specified letter 
	----------------------------------------------------------------------------
	);

end final_project;

architecture Behavioral of final_project is

	signal counter_clk :integer range 0 to 3 :=0;
	signal scl_clock_signal : std_logic :='1';
	type state_names is ( writing_state , writing_error_state, reading_state , reading_error_state,okuma_tamamlandimi_state,seperation_ve_analyzing_tamamlandimi_state,tekrar_okumaya_don_state); ---the states that are used for writing and reading
	signal state : state_names := writing_state; ---------  the states that are used for writing and reading
	type state_names2 is ( seperation_state ,analyzing_state ,seperation_ve_analyzing_tamamlandi_state );  ------- the states that are used for separation and analyzing
	signal state2 : state_names2 := seperation_state; ------the states that are used for separation and analyzing
	signal write_sayac : integer range 0 to 18 :=0; --- the bit counter of writing
	signal write_adres: std_logic_vector(16 downto 0):= "01010000011110000"; -- adress and configuration register(settings) writing
	signal read_sayac : integer  :=0; --- the bit counter of reading
	signal okunan_sayac:integer range 0 to 63:=0; ----- the counter for counting the read bits
	signal read_adres: std_logic_vector(7 downto 0):= "01010001"; -- adress and configuration register(settings) reading
	signal w_start : std_logic:='0';
	signal w_stop: std_logic:='0';
	signal r_start: std_logic:='0';
	signal r_stop : std_logic :='0';  -------- variables that keep whether writing and reading has started and finished
	signal read_adress_ack_flag : std_logic:='0'; ------ to be used when checking the incoming ack after sending reading adress
	signal write_ack_flag:std_logic:='0';  ----- to use when checking ack in writing
	signal okunan_data : std_logic_vector(63 downto 0);
	signal clock_div_counter_adc : integer range 0 to 1562:=0; -- for altera =>3125 for zybo =>1562
	signal clock_for_adc: std_logic:='0';
	signal sda_data: std_logic;
	signal ack_signal: std_logic_vector(1 downto 0):="00";
	signal okunan_kanal_sayisi: integer range 0 to 4:=0;
	signal okuma_tamamlandimi: std_logic:='0'; ----- checking completion of reading
	signal analiz_tamamlandimi:std_logic:='0'; ------check if the analysis is finished after reading
	signal seperation_tamamlandimi: std_logic:='0'; -------check whether seperation is finished after reading
	signal p1,p2,p3,p4 :integer; ----------- it keep adc values of fingers
	signal p1_logic,p2_logic,p3_logic,p4_logic :std_logic_vector(15 downto 0);
	signal gelen_harf : std_logic_vector(4 downto 0):="00000"; ----- this variable will be used to keep the letter from which it is and transfer it to the vga module

	-------------------creating vga component -----------------
	component vga_driver is
		PORT(
			  CLK : in  STD_LOGIC;
	        RST : in  STD_LOGIC; -- sw0
           HSYNC : out  STD_LOGIC;
           VSYNC : out  STD_LOGIC;
               R : out  STD_LOGIC;
			  G : out  STD_LOGIC;
			  B : out  STD_LOGIC;
			  
			  RGB_RENK : IN STD_LOGIC_VECTOR(2 downto 0);
			  harf_secilsinmi: in std_LOGIC;
			  secilen_harf :in std_LOGIC_VECTOR(4 downto 0) 
			);
		end component;
--------------------------------------------------------------	
-------------------clock creating component-------------------
     component clk_wiz_0
   port
    (-- Clock in ports
     -- Clock out ports
     clk_out1          : out    std_logic;
     -- Status and control signals
     reset             : in     std_logic;
     locked            : out    std_logic;
     clk_in1           : in     std_logic
    );
   end component;
   
   signal my_clk_25 : std_logic;
   signal reset_for_component : std_logic:='0';
   signal locked_for_component : std_logic;
  -------------------------------------------------------- 	
begin
    -------------------clock creating component pin assignment------
     your_instance_name : clk_wiz_0
      port map ( 
     -- Clock out ports  
      clk_out1 => my_clk_25,
     -- Status and control signals                
      reset => reset_for_component,
      locked => locked_for_component,
      -- Clock in ports
      clk_in1 => main_clk_125
    );
   --------------------------------------------------------------- 

----------------vga variables and top module matching part-----------
	vga_driver_variables : vga_driver PORT MAP(
		CLK => my_clk_25,
		RST => rst_main,
		HSYNC => hsync_main,
		VSYNC => vsync_main,
		R => r_main,
		G => g_main,
		B => b_main,
		RGB_RENK => rgb_renk_main,
		HARF_SECILSINMI => harf_secilsinmi_main,
		SECILEN_HARF => gelen_harf
	);
------------------------------------------------------------

 sda_data_output<= '0' WHEN sda_data = '0' ELSE 'Z';  -----  when sda_data is 1 sda_data_output  will be z , when sda_data is 0 sda_data_output  will be 0 
 --- while reading we have to make sda_data 1 after sending ack . Because in othewise the last sending data is remains and we cannot read
 ------------ADC Clock generation-------------------
 clk_div_for_adc: process (my_clk_25)
begin
	if(rising_edge(my_clk_25)) then
		clock_div_counter_adc<= clock_div_counter_adc+1;
		if(clock_div_counter_adc=0) then
			clock_for_adc<= not clock_for_adc;
			
		end if;
	end if;
end process;
 ------------ADC Clock generation END-------------------
 
 -------------ADC  writing and reading ------------------
writing_reading_from_adc: process (clock_for_adc)
 
 begin
	if(rising_edge(clock_for_adc)) then
	
	  scl_clock<=scl_clock_signal;
	  counter_clk <= counter_clk+1;
	  
	   if(counter_clk=0) then --- when counter_clk is 0 scl_clock_signal will change. It mean clock_for_adc/8 = scl_clock_signal
	   scl_clock_signal <= not scl_clock_signal;
		end if;
		
		if(counter_clk=2) then  --- when counter_clk is 2 we perform writing and reading 
			
		 case state is 
		   
		  when writing_state => -------- WRITING STATE
			error_writing_reading(1)<='0';
			 hata_ledleri<='1';
			----------------------------------------------------- WRITING START PART.
			if((w_start='0') and (w_stop='0') and (scl_clock_signal='0')) then 
				sda_data<='1';
			elsif((w_start='0') and (w_stop='0') and (scl_clock_signal='1') and (sda_data='1')) then --- start cond
				sda_data<='0';
				w_start<='1';	
			-----------------------------------------------------WRITING 1. BYTE PART.
			elsif((w_start='1') and (w_stop='0') and (scl_clock_signal='0') and (write_sayac<8)) then
				sda_data<=write_adres(16-write_sayac);
				write_sayac<=write_sayac+1;
			--------------------------------------------------- 1. ACKNOWLEDGE  PART OF WRITING.
			elsif((w_start='1') and (w_stop='0') and (write_sayac=8) and (scl_clock_signal='0')and(write_ack_flag='0')) then
			   write_ack_flag<='1';	
				sda_data<='1'; ---- we make the sda_data_output high z because after that we are going to perform reading. 
			elsif((w_start='1') and (w_stop='0') and (write_sayac=8) and (scl_clock_signal='1') and(write_ack_flag='1')) then
				write_ack_flag<='0';
				if(sda_data_output='0') then
					write_sayac<=write_sayac+1;
				
				else
					state<=writing_error_state;  ------ if ack is not came pass the writing_error state
				end if;
			-----------------------------------------------------WRITING 2. BYTE PART.
			elsif((w_start='1') and (w_stop='0') and (write_sayac>8) and (write_sayac<17) and (scl_clock_signal='0')) then
				sda_data<=write_adres(16-write_sayac);
				write_sayac<=write_sayac+1;
				
			--------------------------------------------------- 2. ACKNOWLEDGE  PART OF WRITING.	
			elsif((w_start='1') and (w_stop='0') and (write_sayac=17) and (scl_clock_signal='0')) then
				write_ack_flag<='1';
			elsif((w_start='1') and (w_stop='0') and (write_sayac=17) and (scl_clock_signal='1') and(write_ack_flag='1')) then
				write_ack_flag<='0';
			
				if(sda_data_output='0') then
				
					write_sayac<=write_sayac+1;
					
				else
					state<=writing_error_state;  ------ if ack is not came pass the writing_error state
				end if;	
			--------------------------------------WRITING STOP PART.
			elsif((w_start='1') and (w_stop='0')and (scl_clock_signal='0') and (write_sayac=18)) then
				sda_data<='0';
			
			elsif((w_start='1') and (w_stop='0')and (scl_clock_signal='1') and (write_sayac=18)) then
				sda_data<='1';
				w_stop<='1';
				state<=reading_state;
			
			end if;
			
	
		 when reading_state =>   --------------------------------------------------------- READING STATE
			--------------------------------------------------------------------------------READING START PART
			if((w_stop='1') and (r_start='0') and (r_stop='0') and (scl_clock_signal='1') and (sda_data='1')) then
				sda_data<='0';
				r_start<='1';
				
			--------------------------------------------- -----------------------------------SENDING ADRESS FOR READING PART.	
			elsif((w_stop='1') and (r_start='1') and (r_stop='0') and  (scl_clock_signal='0') and (read_sayac<8))then
					sda_data<=read_adres(7-read_sayac);
					read_sayac<=read_sayac+1;
					
			--------------------------------------------- -----------------------------------READING ADRESS ACKNOWLEDGEMENT PART.	
			elsif((w_stop='1') and (r_start='1') and (r_stop='0') and  (scl_clock_signal='0') and (read_sayac=8) and(read_adress_ack_flag='0')) then 
				read_adress_ack_flag<='1';
				sda_data<='1'; ----- we make the sda_data_output high z because after that we are going to perform reading for ack.
				
			elsif	((w_stop='1') and (r_start='1') and (r_stop='0') and  (scl_clock_signal='1') and (read_sayac=8) and(read_adress_ack_flag='1')) then
				read_adress_ack_flag<='0';
				 if(sda_data_output='0') then
					
					read_sayac<=read_sayac+1;
				 else
					state<=reading_error_state;
				end if;
				
			-----------------------------------------------------------------------------------READING  OF 1. BYTE PART
			elsif((w_stop='1') and (r_start='1') and (r_stop='0') and  (scl_clock_signal='1') and (read_sayac>8) and (read_sayac<17) )then
				okunan_data(63-okunan_sayac)<=sda_data_output;
				okunan_sayac<=okunan_sayac+1;
				read_sayac<=read_sayac+1;
				
			-----------------------------------------------------------------------------------READING 1. BYTE ACKNOWLEDGEMENT PART.
			elsif((w_stop='1') and (r_start='1') and (r_stop='0') and  (scl_clock_signal='0') and (read_sayac=17)and(read_adress_ack_flag='0')) then
				sda_data<='0';
				read_adress_ack_flag<='1';
		
			elsif((w_stop='1') and (r_start='1') and (r_stop='0') and  (scl_clock_signal='0') and (read_sayac=17) and (read_adress_ack_flag='1')) then
				read_sayac<=read_sayac+1;
				read_adress_ack_flag<='0';
				sda_data<='1'; ----  before start  data reading  we make sda_data_output high Z by making sda_data 1.  dont forget !!!!!
				
			-----------------------------------------------------------------------------------READING OF 2. BYTE PART	
			elsif((w_stop='1') and (r_start='1') and (r_stop='0')and (scl_clock_signal='1')and(read_sayac>17) and (read_sayac<26)) then
				okunan_data(63-okunan_sayac)<=sda_data_output;
				okunan_sayac<=okunan_sayac+1;
				read_sayac<=read_sayac+1;
				 if(read_sayac=25) then
				 okunan_kanal_sayisi<= okunan_kanal_sayisi+1;
				 end if;
			-----------------------------------------------------------------------------------SENDING ACK FOR READING AGAIN PART
			elsif((w_stop='1') and (r_start='1') and (r_stop='0')and (scl_clock_signal='0') and (read_sayac=26) and (okunan_kanal_sayisi<4) and (read_adress_ack_flag='0'))then
			sda_data<='0';
			read_adress_ack_flag<='1';	
			elsif((w_stop='1') and (r_start='1') and (r_stop='0')and (scl_clock_signal='0') and (read_sayac=26) and (okunan_kanal_sayisi<4) and (read_adress_ack_flag='1'))then
			sda_data<='1'; ---- before start  data reading  we make sda_data_output high Z by making sda_data 1.
			read_adress_ack_flag<='0';	
			read_sayac<=9;
			--------------------------------------------------------------------------------------READING STOP PART.
			elsif((w_stop='1') and (r_start='1') and (r_stop='0') and (scl_clock_signal='0') and(read_sayac=26)and(read_adress_ack_flag='0') and (okunan_kanal_sayisi=4)) then
				sda_data<='0';
				read_adress_ack_flag<='1';		
			elsif((w_stop='1') and (r_start='1') and (r_stop='0') and (scl_clock_signal='1') and(read_sayac=26) and(read_adress_ack_flag='1') and (okunan_kanal_sayisi=4)) then
				read_adress_ack_flag<='0';
				sda_data<='1';
				r_stop<='1';
				
				state<= okuma_tamamlandimi_state;	
			end if;
		-----------------------------------------------------------------------------------------	
		when okuma_tamamlandimi_state =>
			okuma_tamamlandimi<='1';
			state<= seperation_ve_analyzing_tamamlandimi_state;
		------------------------------------------------------------------------------------------
		when 	seperation_ve_analyzing_tamamlandimi_state =>-------------WAITING FOR ANALYZING DONE STATE
			if ((analiz_tamamlandimi='1')and (seperation_tamamlandimi='1')) then
				state<=tekrar_okumaya_don_state;
			else 
				state<=seperation_ve_analyzing_tamamlandimi_state;
			end if;
			
		------------------------------------------------------------------------------------------
	
		------------------------------------------------------------------------------------------	
		when tekrar_okumaya_don_state => ------------- GOING TO READING AGAIN	
		if(r_stop='1') then
			sda_data<='1';
			r_start<='0';
			r_stop<='0';
			read_sayac<=0;
			okunan_sayac<=0;
			okunan_kanal_sayisi<=0;
			okuma_tamamlandimi<='0';
			okunan_data<=(others => '0');
			state<=reading_state;
		else 
			state<=tekrar_okumaya_don_state;
		end if;	
		------------------------------------------------------------------------------------------	
		when writing_error_state =>  -----------------  ERROR OF WRITING STATE
			error_writing_reading(1)<='1';
			
			if (w_start='0') then
				state<=writing_state;
			end if;	
		------------------------------------------------------------------------------------------	
		 when reading_error_state =>  -----------------  ERROR OF READING STATE
		   error_writing_reading(0)<='1';
			if (r_start='0') then
				state<=reading_state;
			end if;
		-----------------------------------------------------------------------------------------	
		 end case;
		end if;	
	end if;
 end process;
 -------------ADC  writing and reading END ----------------------------
 
 
 -------------Seperation and analysing of reading data-------------------------
 seperation_and_analysing_of_reading_data: process (my_clk_25) ------ in this process it determines that reading data come from which fingers   and which letter is compatible with this data
  begin															  

	 if(rising_edge(my_clk_25)) then
		
		case state2 is 
	-------------------------------------------------------------------------	
		 when seperation_state => --- we take data as a set of 64 bit(16 bit for each finger) and the 12 bit of each 16 bit include adc value 
								  --- in this seperation_state we perform division to get the meaningfull adc data for each finger 
								  --- Also we convert these 12 bit data to integer  for easy analysing
 			if((okuma_tamamlandimi='1') and(seperation_tamamlandimi='0')) then
			-----------------------------------------------------------
				if((okunan_data(61)='0')and (okunan_data(60)='0') )then
					p1<=to_integer(unsigned(okunan_data(59 downto 48)));
					p1_logic<=okunan_data(63 downto 48);
				elsif	((okunan_data(61)='0')and (okunan_data(60)='1') )then
					p2<=to_integer(unsigned(okunan_data(59 downto 48)));
					p2_logic<=okunan_data(63 downto 48);
				elsif	((okunan_data(61)='1')and (okunan_data(60)='0') )then
					p3<=to_integer(unsigned(okunan_data(59 downto 48)));
					p3_logic<=okunan_data(63 downto 48);	
				elsif	((okunan_data(61)='1')and (okunan_data(60)='1') )then
					p4<=to_integer(unsigned(okunan_data(59 downto 48)));
					p4_logic<=okunan_data(63 downto 48);
				end if;
			-----------------------------------------------------------
				if((okunan_data(45)='0')and (okunan_data(44)='0') )then
					p1<=to_integer(unsigned(okunan_data(43 downto 32)));
					p1_logic<=okunan_data(47 downto 32);
				elsif	((okunan_data(45)='0')and (okunan_data(44)='1') )then
					p2<=to_integer(unsigned(okunan_data(43 downto 32)));
					p2_logic<=okunan_data(47 downto 32);
				elsif	((okunan_data(45)='1')and (okunan_data(44)='0') )then
					p3<=to_integer(unsigned(okunan_data(43 downto 32)));
					p3_logic<=okunan_data(47 downto 32);
				elsif	((okunan_data(45)='1')and (okunan_data(44)='1') )then
					p4<=to_integer(unsigned(okunan_data(43 downto 32)));
					p4_logic<=okunan_data(47 downto 32);
				end if;	
			-----------------------------------------------------------
				if((okunan_data(29)='0')and (okunan_data(28)='0') )then
					p1<=to_integer(unsigned(okunan_data(27 downto 16)));
					p1_logic<=okunan_data(31 downto 16);
				elsif	((okunan_data(29)='0')and (okunan_data(28)='1') )then
					p2<=to_integer(unsigned(okunan_data(27 downto 16)));
					p2_logic<=okunan_data(31 downto 16);
				elsif	((okunan_data(29)='1')and (okunan_data(28)='0') )then
					p3<=to_integer(unsigned(okunan_data(27 downto 16)));	
					p3_logic<=okunan_data(31 downto 16);
				elsif	((okunan_data(29)='1')and (okunan_data(28)='1') )then
					p4<=to_integer(unsigned(okunan_data(27 downto 16)));
					p4_logic<=okunan_data(31 downto 16);
				end if;
			-----------------------------------------------------------
				if((okunan_data(13)='0')and (okunan_data(12)='0') )then
					p1<=to_integer(unsigned(okunan_data(11 downto 0)));
					p1_logic<=okunan_data(15 downto 0);
				elsif	((okunan_data(13)='0')and (okunan_data(12)='1') )then
					p2<=to_integer(unsigned(okunan_data(11 downto 0)));
					p2_logic<=okunan_data(15 downto 0);
				elsif	((okunan_data(13)='1')and (okunan_data(12)='0') )then
					p3<=to_integer(unsigned(okunan_data(11 downto 0)));
					p3_logic<=okunan_data(15 downto 0);	
				elsif	((okunan_data(13)='1')and (okunan_data(12)='1') )then
					p4<=to_integer(unsigned(okunan_data(11 downto 0)));
					p4_logic<=okunan_data(15 downto 0);
				end if;
			-----------------------------------------------------------	
				state2<= analyzing_state;
			else 
				state2<=seperation_state;
			end if;
	------------------------------------------------------------------------------		
		 when analyzing_state=>  ---- each finger have numerical range for open and close position and for each letter the fingers have spesific position.
								 ---- Also thesespesfic positions have spesific numerical range.
								 ---- So we perform analyze to understand which letter is the data store for spesific position of each finger. 
			if((analiz_tamamlandimi='0') and (okuma_tamamlandimi='1')) then 
				
				if (((p1>2600)and(p1<2720)) and ((p2>1500)and(p2<2100)) and ((p3>1500)and(p3<2100)) and ((p4>1500)and(p4<2150))) then
				--A
					kontrol_ledleri<="0001";
					gelen_harf<="00001";
				elsif(((p1>2150)and(p1<2550)) and ((p2>2650)and(p2<4000)) and ((p3>2700)and(p3<4000)) and ((p4>2800)and(p4<4000))) then
				--B
					kontrol_ledleri<="0010";
					gelen_harf<="00010";
				
				elsif(((p1>2450)and(p1<2750)) and ((p2>2400)and(p2<2700)) and ((p3>2450)and(p3<2750)) and ((p4>2550)and(p4<2800))) then
				--C
					kontrol_ledleri<="0011";
					gelen_harf<="00011";
				elsif(((p1>2270)and(p1<2550)) and ((p2>2750)and(p2<4000)) and ((p3>2200)and(p3<2400)) and ((p4>2200)and(p4<2450))) then
				--D
					kontrol_ledleri<="0100";
					gelen_harf<="00100";
				elsif(((p1>2100)and(p1<2400)) and ((p2>1900)and(p2<2340)) and ((p3>2150)and(p3<2420)) and ((p4>2000)and(p4<2300))) then
				--E
					kontrol_ledleri<="0101";
					gelen_harf<="00101";
				elsif(((p1>2250)and(p1<2600)) and ((p2>1850)and(p2<2250)) and ((p3>2650)and(p3<4000)) and ((p4>2850)and(p4<4000))) then
				--F
					kontrol_ledleri<="0110";
					gelen_harf<="00110";
				elsif(((p1>2520)and(p1<2700)) and ((p2>2700)and(p2<4000)) and ((p3>2000)and(p3<2250)) and ((p4>2000)and(p4<2250))) then
				--G
					kontrol_ledleri<="0111";
					gelen_harf<="00111";
				elsif(((p1>2400)and(p1<2700)) and ((p2>2680)and(p2<4000)) and ((p3>2650)and(p3<4000)) and ((p4>2000)and(p4<2340))) then
				--H
					kontrol_ledleri<="1000";
					gelen_harf<="01000";
				elsif(((p1>2700)and(p1<2855)) and ((p2>2660)and(p2<4000)) and ((p3>2600)and(p3<4000)) and ((p4>2080)and(p4<2315))) then
				--K
					kontrol_ledleri<="1001";
					gelen_harf<="01001"; 
				
				elsif(((p1>2700)and(p1<4000)) and ((p2>2650)and(p2<4000)) and ((p3>1900)and(p3<2200)) and ((p4>1900)and(p4<2200))) then
				--L
					kontrol_ledleri<="1010";
					gelen_harf<="01010";
				elsif(((p1>2400)and(p1<2650)) and ((p2>2010)and(p2<2390)) and ((p3>2220)and(p3<2440)) and ((p4>2280)and(p4<2520))) then
				--O
					kontrol_ledleri<="1011";
					gelen_harf<="01011";
				elsif(((p1>2600)and(p1<2750)) and ((p2>2735)and(p2<4000)) and ((p3>2350)and(p3<2500)) and ((p4>2100)and(p4<2340))) then
				--P
					kontrol_ledleri<="1100";
					gelen_harf<="01100";
	 
				elsif(((p1>2000)and(p1<2500)) and ((p2>1500)and(p2<2040)) and ((p3>1800)and(p3<2100)) and ((p4>1900)and(p4<2240))) then
				--S
					kontrol_ledleri<="1101";
					gelen_harf<="01101";
				elsif(((p1>2400)and(p1<2690)) and ((p2>2050)and(p2<2335)) and ((p3>2000)and(p3<2275)) and ((p4>2000)and(p4<2265))) then
				--T 
				    kontrol_ledleri<="1110"; 
					gelen_harf<="01110";
				elsif(((p1>1700)and(p1<2240)) and ((p2>2230)and(p2<2600)) and ((p3>2140)and(p3<2340)) and ((p4>2140)and(p4<2400))) then
				--X
					kontrol_ledleri<="1111";
					gelen_harf<="01111";
				elsif(((p1>2710)and(p1<4000)) and ((p2>1500)and(p2<2215)) and ((p3>1500)and(p3<2260)) and ((p4>1500)and(p4<2390))) then
				--Y
					kontrol_ledleri<="0001";
					gelen_harf<="10000";
				else 
					kontrol_ledleri<="0000";
					gelen_harf<="00000";
				end if;
				state2<=seperation_ve_analyzing_tamamlandi_state;
			else	
				state2<=analyzing_state;
			end if;
	-------------------------------------------------------------------------------		
		 when seperation_ve_analyzing_tamamlandi_state=>
			analiz_tamamlandimi<='1';
			seperation_tamamlandimi<='1';
			if(okuma_tamamlandimi='0') then
				analiz_tamamlandimi<='0';
				seperation_tamamlandimi<='0';
				state2 <= seperation_state;
			else
				state2 <= seperation_ve_analyzing_tamamlandi_state;
			end if;
	--------------------------------------------------------------------------------		
		end case;
	 end if;
  end process;
  ------------Seperation and analysing of reading data  END---------------------------
end Behavioral;