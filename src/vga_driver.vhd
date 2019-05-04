
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_driver is
    Port ( 
	       CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC; -- sw0
           HSYNC : out  STD_LOGIC;
           VSYNC : out  STD_LOGIC;
              R : out  STD_LOGIC;
			  G : out  STD_LOGIC;
			  B : out  STD_LOGIC; 
			  RGB_RENK : IN STD_LOGIC_VECTOR(2 downto 0);-- color arrangement pins  sw0->R sw1->G sw2->B 
			  harf_secilsinmi: in std_LOGIC; ---- button(buttn[1]) that allows you to print the specified letter 
			  secilen_harf :in std_LOGIC_VECTOR(4 downto 0) ---- it will be used to keep the letter from which it is 
			  );
end vga_driver;

architecture Behavioral of vga_driver is

   -----this is the standart array that contains the characters as 8x16bits
	type rom_type is array (0 to 271) of std_logic_vector(0 to 7);
	-- ROM definition
	signal ROM: rom_type := (   -- 2^11-by-8
	-- NUL: 
		"00000000", -- 0
		"00000000", -- 1
		"00000000", -- 2
		"00000000", -- 3
		"00000000", -- 4
		"00000000", -- 5
		"00000000", -- 6
		"00000000", -- 7
		"00000000", -- 8
		"00000000", -- 9
		"00000000", -- a
		"00000000", -- b
		"00000000", -- c
		"00000000", -- d
		"00000000", -- e
		"00000000", -- f
	
	-- A: 
		"00000000", -- 0
		"00000000", -- 1
		"00010000", -- 2    *
		"00111000", -- 3   ***
		"01101100", -- 4  ** **
		"11000110", -- 5 **   **
		"11000110", -- 6 **   **
		"11111110", -- 7 *******
		"11000110", -- 8 **   **
		"11000110", -- 9 **   **
		"11000110", -- a **   **
		"11000110", -- b **   **
		"00000000", -- c
		"00000000", -- d
		"00000000", -- e
		"00000000", -- f
		-- B: 
		"00000000", -- 0
		"00000000", -- 1
		"11111100", -- 2 ******
		"01100110", -- 3  **  **
		"01100110", -- 4  **  **
		"01100110", -- 5  **  **
		"01111100", -- 6  *****
		"01100110", -- 7  **  **
		"01100110", -- 8  **  **
		"01100110", -- 9  **  **
		"01100110", -- a  **  **
		"11111100", -- b ******
		"00000000", -- c
		"00000000", -- d
		"00000000", -- e
		"00000000", -- f
		-- C: 
		"00000000", -- 0
		"00000000", -- 1
		"00111100", -- 2   ****
		"01100110", -- 3  **  **
		"11000010", -- 4 **    *
		"11000000", -- 5 **
		"11000000", -- 6 **
		"11000000", -- 7 **
		"11000000", -- 8 **
		"11000010", -- 9 **    *
		"01100110", -- a  **  **
		"00111100", -- b   ****
		"00000000", -- c
		"00000000", -- d
		"00000000", -- e
		"00000000", -- f
			-- D: 
		"00000000", -- 0
		"00000000", -- 1
		"11111000", -- 2 *****
		"01101100", -- 3  ** **
		"01100110", -- 4  **  **
		"01100110", -- 5  **  **
		"01100110", -- 6  **  **
		"01100110", -- 7  **  **
		"01100110", -- 8  **  **
		"01100110", -- 9  **  **
		"01101100", -- a  ** **
		"11111000", -- b *****
		"00000000", -- c
		"00000000", -- d
		"00000000", -- e
		"00000000", -- f
		-- E:
		"00000000", -- 0
		"00000000", -- 1
		"11111110", -- 2 *******
		"01100110", -- 3  **  **
		"01100010", -- 4  **   *
		"01101000", -- 5  ** *
		"01111000", -- 6  ****
		"01101000", -- 7  ** *
		"01100000", -- 8  **
		"01100010", -- 9  **   *
		"01100110", -- a  **  **
		"11111110", -- b *******
		"00000000", -- c
		"00000000", -- d
		"00000000", -- e
		"00000000", -- f
		-- F:
		"00000000", -- 0
		"00000000", -- 1
		"11111110", -- 2 *******
		"01100110", -- 3  **  **
		"01100010", -- 4  **   *
		"01101000", -- 5  ** *
		"01111000", -- 6  ****
		"01101000", -- 7  ** *
		"01100000", -- 8  **
		"01100000", -- 9  **
		"01100000", -- a  **
		"11110000", -- b ****
		"00000000", -- c
		"00000000", -- d
		"00000000", -- e
		"00000000", -- f
		-- G:
		"00000000", -- 0
		"00000000", -- 1
		"00111100", -- 2   ****
		"01100110", -- 3  **  **
		"11000010", -- 4 **    *
		"11000000", -- 5 **
		"11000000", -- 6 **
		"11011110", -- 7 ** ****
		"11000110", -- 8 **   **
		"11000110", -- 9 **   **
		"01100110", -- a  **  **
		"00111010", -- b   *** *
		"00000000", -- c
		"00000000", -- d
		"00000000", -- e
		"00000000", -- f
		-- H:
		"00000000", -- 0
		"00000000", -- 1
		"11000110", -- 2 **   **
		"11000110", -- 3 **   **
		"11000110", -- 4 **   **
		"11000110", -- 5 **   **
		"11111110", -- 6 *******
		"11000110", -- 7 **   **
		"11000110", -- 8 **   **
		"11000110", -- 9 **   **
		"11000110", -- a **   **
		"11000110", -- b **   **
		"00000000", -- c
		"00000000", -- d
		"00000000", -- e
		"00000000", -- f
		
		-- K: 
		"00000000", -- 0
		"00000000", -- 1
		"11100110", -- 2 ***  **
		"01100110", -- 3  **  **
		"01100110", -- 4  **  **
		"01101100", -- 5  ** **
		"01111000", -- 6  ****
		"01111000", -- 7  ****
		"01101100", -- 8  ** **
		"01100110", -- 9  **  **
		"01100110", -- a  **  **
		"11100110", -- b ***  **
		"00000000", -- c
		"00000000", -- d
		"00000000", -- e
		"00000000", -- f
		-- L: 
		"00000000", -- 0
		"00000000", -- 1
		"11110000", -- 2 ****
		"01100000", -- 3  **
		"01100000", -- 4  **
		"01100000", -- 5  **
		"01100000", -- 6  **
		"01100000", -- 7  **
		"01100000", -- 8  **
		"01100010", -- 9  **   *
		"01100110", -- a  **  **
		"11111110", -- b *******
		"00000000", -- c
		"00000000", -- d
		"00000000", -- e
		"00000000", -- f
		
		-- O: 
		"00000000", -- 0
		"00000000", -- 1
		"01111100", -- 2  *****
		"11000110", -- 3 **   **
		"11000110", -- 4 **   **
		"11000110", -- 5 **   **
		"11000110", -- 6 **   **
		"11000110", -- 7 **   **
		"11000110", -- 8 **   **
		"11000110", -- 9 **   **
		"11000110", -- a **   **
		"01111100", -- b  *****
		"00000000", -- c
		"00000000", -- d
		"00000000", -- e
		"00000000", -- f
		-- P: 
		"00000000", -- 0
		"00000000", -- 1
		"11111100", -- 2 ******
		"01100110", -- 3  **  **
		"01100110", -- 4  **  **
		"01100110", -- 5  **  **
		"01111100", -- 6  *****
		"01100000", -- 7  **
		"01100000", -- 8  **
		"01100000", -- 9  **
		"01100000", -- a  **
		"11110000", -- b ****
		"00000000", -- c
		"00000000", -- d
		"00000000", -- e
		"00000000", -- f
		
		
		-- S:
		"00000000", -- 0
		"00000000", -- 1
		"01111100", -- 2  *****
		"11000110", -- 3 **   **
		"11000110", -- 4 **   **
		"01100000", -- 5  **
		"00111000", -- 6   ***
		"00001100", -- 7     **
		"00000110", -- 8      **
		"11000110", -- 9 **   **
		"11000110", -- a **   **
		"01111100", -- b  *****
		"00000000", -- c
		"00000000", -- d
		"00000000", -- e
		"00000000", -- f
		-- T:
		"00000000", -- 0
		"00000000", -- 1
		"11111111", -- 2 ********
		"11011011", -- 3 ** ** **
		"10011001", -- 4 *  **  *
		"00011000", -- 5    **
		"00011000", -- 6    **
		"00011000", -- 7    **
		"00011000", -- 8    **
		"00011000", -- 9    **
		"00011000", -- a    **
		"00111100", -- b   ****
		"00000000", -- c
		"00000000", -- d
		"00000000", -- e
		"00000000", -- f

		-- X:
		"00000000", -- 0
		"00000000", -- 1
		"11000011", -- 2 **    **
		"11000011", -- 3 **    **
		"01100110", -- 4  **  **
		"00111100", -- 5   ****
		"00011000", -- 6    **
		"00011000", -- 7    **
		"00111100", -- 8   ****
		"01100110", -- 9  **  **
		"11000011", -- a **    **
		"11000011", -- b **    **
		"00000000", -- c
		"00000000", -- d
		"00000000", -- e
		"00000000", -- f
		-- Y:
		"00000000", -- 0
		"00000000", -- 1
		"11000011", -- 2 **    **
		"11000011", -- 3 **    **
		"11000011", -- 4 **    **
		"01100110", -- 5  **  **
		"00111100", -- 6   ****
		"00011000", -- 7    **
		"00011000", -- 8    **
		"00011000", -- 9    **
		"00011000", -- a    **
		"00111100", -- b   ****
		"00000000", -- c
		"00000000", -- d
		"00000000", -- e
		"00000000" -- f
		
	  );
   	
	signal char_v_poscur : integer:= 160 ; --- it keeps the where it start the vertical position of character 
	signal char_h_poscur : integer:= 280 ;  ---it keeps the where it start the horizontal position of character 
   type array_type is array (0 to 10) of integer;
	--signal char_h_poscur: array_type := (0,8,16,24,32,40,48,56,64,72,80);  -- 
	-- signal char_h_poscur: array_type := (300,40,80,120,160,200,240,280,320,360,400);
	--signal char_rom_pos  : integer:= 0 ;  -- karakterlerin fontromdaki başlangıç adreslerini tutacak
	signal char_rom_pos: array_type := (0,0,0,0,0,0,0,0,0,0,0);
	
	             ---****************VGA variables ***************---
	constant HD : integer := 639;  --  639   Horizontal Display (640)
	constant HFP : integer := 16;         --   16   Right border (front porch)
	constant HSP : integer := 96;       --   96   Sync pulse (Retrace)
	constant HBP : integer := 48;        --   48   Left boarder (back porch)
	
	
	constant VD : integer := 479;   --  479   Vertical Display (480)
	constant VFP : integer := 10;       	 --   10   Right border (front porch)
	constant VSP : integer := 2;				 --    2   Sync pulse (Retrace)
	constant VBP : integer := 33;       --   33   Left boarder (back porch)
	
	signal hPos : integer := 0;
	signal vPos : integer := 0;
	
	signal videoOn : std_logic := '0';
	------------------------------------------------------------------------------------
	
	             ----***************letter  choice variables***************------
	signal kacinci_harf_kontrol: std_LOGIC:='0';				 
	signal harf_secilsinmi_kontrol: std_LOGIC;				 
	signal bekleme_sinyali : std_LOGIC_VECTOR(0 to 22);	--- we use this signal for waiting
	signal bekleme_sinyali2 : std_LOGIC_VECTOR(0 to 22);	--- we use this signal for waiting2
	signal kacinci_harf: integer:=0;
	------------------------------------------------------------------------------------
	----- draw_func  this is the function that using for driving a character on monitor ------
	function draw_func(  signal h,v,h_cur,v_cur, rom_pos: integer ; signal func_rom :rom_type) return boolean is
	 variable temp: boolean;
	begin
	   if(         (((h>h_cur+0 and h<=h_cur+10) and (v>v_cur+0 and v<=v_cur+10))  and (func_rom(rom_pos+0)(0)='1')) or 
                   (((h>h_cur+10 and h<=h_cur+20) and (v>v_cur+0 and v<=v_cur+10)) and (func_rom(rom_pos+0)(1)='1')) or
                   (((h>h_cur+20 and h<=h_cur+30) and (v>v_cur+0 and v<=v_cur+10)) and (func_rom(rom_pos+0)(2)='1')) or
                   (((h>h_cur+30 and h<=h_cur+40) and (v>v_cur+0 and v<=v_cur+10)) and (func_rom(rom_pos+0)(3)='1')) or
                   (((h>h_cur+40 and h<=h_cur+50) and (v>v_cur+0 and v<=v_cur+10)) and (func_rom(rom_pos+0)(4)='1')) or
                   (((h>h_cur+50 and h<=h_cur+60) and (v>v_cur+0 and v<=v_cur+10)) and (func_rom(rom_pos+0)(5)='1')) or
                   (((h>h_cur+60 and h<=h_cur+70) and (v>v_cur+0 and v<=v_cur+10)) and (func_rom(rom_pos+0)(6)='1')) or
                   (((h>h_cur+70 and h<=h_cur+80) and (v>v_cur+0 and v<=v_cur+10)) and (func_rom(rom_pos+0)(7)='1')) or
                    --- karakterin 2. satırı
                   (((h>h_cur+0 and h<=h_cur+10) and (v>v_cur+10 and v<=v_cur+20))  and (func_rom(rom_pos+1)(0)='1')) or 
                   (((h>h_cur+10 and h<=h_cur+20) and (v>v_cur+10 and v<=v_cur+20)) and (func_rom(rom_pos+1)(1)='1')) or
                   (((h>h_cur+20 and h<=h_cur+30) and (v>v_cur+10 and v<=v_cur+20)) and (func_rom(rom_pos+1)(2)='1')) or
                   (((h>h_cur+30 and h<=h_cur+40) and (v>v_cur+10 and v<=v_cur+20)) and (func_rom(rom_pos+1)(3)='1')) or
                   (((h>h_cur+40 and h<=h_cur+50) and (v>v_cur+10 and v<=v_cur+20)) and (func_rom(rom_pos+1)(4)='1')) or
                   (((h>h_cur+50 and h<=h_cur+60) and (v>v_cur+10 and v<=v_cur+20)) and (func_rom(rom_pos+1)(5)='1')) or
                   (((h>h_cur+60 and h<=h_cur+70) and (v>v_cur+10 and v<=v_cur+20)) and (func_rom(rom_pos+1)(6)='1')) or
                   (((h>h_cur+70 and h<=h_cur+80) and (v>v_cur+10 and v<=v_cur+20)) and (func_rom(rom_pos+1)(7)='1')) or
                    --- karakterin 3. satırı
                   (((h>h_cur+0 and h<=h_cur+10) and (v>v_cur+20 and v<=v_cur+30))  and (func_rom(rom_pos+2)(0)='1')) or 
                   (((h>h_cur+10 and h<=h_cur+20) and (v>v_cur+20 and v<=v_cur+30)) and (func_rom(rom_pos+2)(1)='1')) or
                   (((h>h_cur+20 and h<=h_cur+30) and (v>v_cur+20 and v<=v_cur+30)) and (func_rom(rom_pos+2)(2)='1')) or
                   (((h>h_cur+30 and h<=h_cur+40) and (v>v_cur+20 and v<=v_cur+30)) and (func_rom(rom_pos+2)(3)='1')) or
                   (((h>h_cur+40 and h<=h_cur+50) and (v>v_cur+20 and v<=v_cur+30)) and (func_rom(rom_pos+2)(4)='1')) or
                   (((h>h_cur+50 and h<=h_cur+60) and (v>v_cur+20 and v<=v_cur+30)) and (func_rom(rom_pos+2)(5)='1')) or
                   (((h>h_cur+60 and h<=h_cur+70) and (v>v_cur+20 and v<=v_cur+30)) and (func_rom(rom_pos+2)(6)='1')) or
                   (((h>h_cur+70 and h<=h_cur+80) and (v>v_cur+20 and v<=v_cur+30)) and (func_rom(rom_pos+2)(7)='1')) or
                    --- karakterin 4. satırı
                   (((h>h_cur+0 and h<=h_cur+10) and (v>v_cur+30 and v<=v_cur+40))  and (func_rom(rom_pos+3)(0)='1')) or 
                   (((h>h_cur+10 and h<=h_cur+20) and (v>v_cur+30 and v<=v_cur+40)) and (func_rom(rom_pos+3)(1)='1')) or
                   (((h>h_cur+20 and h<=h_cur+30) and (v>v_cur+30 and v<=v_cur+40)) and (func_rom(rom_pos+3)(2)='1')) or
                   (((h>h_cur+30 and h<=h_cur+40) and (v>v_cur+30 and v<=v_cur+40)) and (func_rom(rom_pos+3)(3)='1')) or
                   (((h>h_cur+40 and h<=h_cur+50) and (v>v_cur+30 and v<=v_cur+40)) and (func_rom(rom_pos+3)(4)='1')) or
                   (((h>h_cur+50 and h<=h_cur+60) and (v>v_cur+30 and v<=v_cur+40)) and (func_rom(rom_pos+3)(5)='1')) or
                   (((h>h_cur+60 and h<=h_cur+70) and (v>v_cur+30 and v<=v_cur+40)) and (func_rom(rom_pos+3)(6)='1')) or
                   (((h>h_cur+70 and h<=h_cur+80) and (v>v_cur+30 and v<=v_cur+40)) and (func_rom(rom_pos+3)(7)='1')) or
                    --- karakterin 5. satırı
                   (((h>h_cur+0 and h<=h_cur+10) and (v>v_cur+40 and v<=v_cur+50))  and (func_rom(rom_pos+4)(0)='1')) or 
                   (((h>h_cur+10 and h<=h_cur+20) and (v>v_cur+40 and v<=v_cur+50)) and (func_rom(rom_pos+4)(1)='1')) or
                   (((h>h_cur+20 and h<=h_cur+30) and (v>v_cur+40 and v<=v_cur+50)) and (func_rom(rom_pos+4)(2)='1')) or
                   (((h>h_cur+30 and h<=h_cur+40) and (v>v_cur+40 and v<=v_cur+50)) and (func_rom(rom_pos+4)(3)='1')) or
                   (((h>h_cur+40 and h<=h_cur+50) and (v>v_cur+40 and v<=v_cur+50)) and (func_rom(rom_pos+4)(4)='1')) or
                   (((h>h_cur+50 and h<=h_cur+60) and (v>v_cur+40 and v<=v_cur+50)) and (func_rom(rom_pos+4)(5)='1')) or
                   (((h>h_cur+60 and h<=h_cur+70) and (v>v_cur+40 and v<=v_cur+50)) and (func_rom(rom_pos+4)(6)='1')) or
                   (((h>h_cur+70 and h<=h_cur+80) and (v>v_cur+40 and v<=v_cur+50)) and (func_rom(rom_pos+4)(7)='1')) or
                    --- karakterin 6. satırı
                   (((h>h_cur+0 and h<=h_cur+10) and (v>v_cur+50 and v<=v_cur+60))  and (func_rom(rom_pos+5)(0)='1')) or 
                   (((h>h_cur+10 and h<=h_cur+20) and (v>v_cur+50 and v<=v_cur+60)) and (func_rom(rom_pos+5)(1)='1')) or
                   (((h>h_cur+20 and h<=h_cur+30) and (v>v_cur+50 and v<=v_cur+60)) and (func_rom(rom_pos+5)(2)='1')) or
                   (((h>h_cur+30 and h<=h_cur+40) and (v>v_cur+50 and v<=v_cur+60)) and (func_rom(rom_pos+5)(3)='1')) or
                   (((h>h_cur+40 and h<=h_cur+50) and (v>v_cur+50 and v<=v_cur+60)) and (func_rom(rom_pos+5)(4)='1')) or
                   (((h>h_cur+50 and h<=h_cur+60) and (v>v_cur+50 and v<=v_cur+60)) and (func_rom(rom_pos+5)(5)='1')) or
                   (((h>h_cur+60 and h<=h_cur+70) and (v>v_cur+50 and v<=v_cur+60)) and (func_rom(rom_pos+5)(6)='1')) or
                   (((h>h_cur+70 and h<=h_cur+80) and (v>v_cur+50 and v<=v_cur+60)) and (func_rom(rom_pos+5)(7)='1')) or
                    --- karakterin 7. satırı
                   (((h>h_cur+0 and h<=h_cur+10) and (v>v_cur+60 and v<=v_cur+70))  and (func_rom(rom_pos+6)(0)='1')) or 
                   (((h>h_cur+10 and h<=h_cur+20) and (v>v_cur+60 and v<=v_cur+70)) and (func_rom(rom_pos+6)(1)='1')) or
                   (((h>h_cur+20 and h<=h_cur+30) and (v>v_cur+60 and v<=v_cur+70)) and (func_rom(rom_pos+6)(2)='1')) or
                   (((h>h_cur+30 and h<=h_cur+40) and (v>v_cur+60 and v<=v_cur+70)) and (func_rom(rom_pos+6)(3)='1')) or
                   (((h>h_cur+40 and h<=h_cur+50) and (v>v_cur+60 and v<=v_cur+70)) and (func_rom(rom_pos+6)(4)='1')) or
                   (((h>h_cur+50 and h<=h_cur+60) and (v>v_cur+60 and v<=v_cur+70)) and (func_rom(rom_pos+6)(5)='1')) or
                   (((h>h_cur+60 and h<=h_cur+70) and (v>v_cur+60 and v<=v_cur+70)) and (func_rom(rom_pos+6)(6)='1')) or
                   (((h>h_cur+70 and h<=h_cur+80) and (v>v_cur+60 and v<=v_cur+70)) and (func_rom(rom_pos+6)(7)='1')) or
                    --- karakterin 8. satırı
                   (((h>h_cur+0 and h<=h_cur+10) and (v>v_cur+70 and v<=v_cur+80))  and (func_rom(rom_pos+7)(0)='1')) or 
                   (((h>h_cur+10 and h<=h_cur+20) and (v>v_cur+70 and v<=v_cur+80)) and (func_rom(rom_pos+7)(1)='1')) or
                   (((h>h_cur+20 and h<=h_cur+30) and (v>v_cur+70 and v<=v_cur+80)) and (func_rom(rom_pos+7)(2)='1')) or
                   (((h>h_cur+30 and h<=h_cur+40) and (v>v_cur+70 and v<=v_cur+80)) and (func_rom(rom_pos+7)(3)='1')) or
                   (((h>h_cur+40 and h<=h_cur+50) and (v>v_cur+70 and v<=v_cur+80)) and (func_rom(rom_pos+7)(4)='1')) or
                   (((h>h_cur+50 and h<=h_cur+60) and (v>v_cur+70 and v<=v_cur+80)) and (func_rom(rom_pos+7)(5)='1')) or
                   (((h>h_cur+60 and h<=h_cur+70) and (v>v_cur+70 and v<=v_cur+80)) and (func_rom(rom_pos+7)(6)='1')) or
                   (((h>h_cur+70 and h<=h_cur+80) and (v>v_cur+70 and v<=v_cur+80)) and (func_rom(rom_pos+7)(7)='1')) or
                    --- karakterin 9. satırı
                   (((h>h_cur+0 and h<=h_cur+10) and (v>v_cur+80 and v<=v_cur+90))  and (func_rom(rom_pos+8)(0)='1')) or 
                   (((h>h_cur+10 and h<=h_cur+20) and (v>v_cur+80 and v<=v_cur+90)) and (func_rom(rom_pos+8)(1)='1')) or
                   (((h>h_cur+20 and h<=h_cur+30) and (v>v_cur+80 and v<=v_cur+90)) and (func_rom(rom_pos+8)(2)='1')) or
                   (((h>h_cur+30 and h<=h_cur+40) and (v>v_cur+80 and v<=v_cur+90)) and (func_rom(rom_pos+8)(3)='1')) or
                   (((h>h_cur+40 and h<=h_cur+50) and (v>v_cur+80 and v<=v_cur+90)) and (func_rom(rom_pos+8)(4)='1')) or
                   (((h>h_cur+50 and h<=h_cur+60) and (v>v_cur+80 and v<=v_cur+90)) and (func_rom(rom_pos+8)(5)='1')) or
                   (((h>h_cur+60 and h<=h_cur+70) and (v>v_cur+80 and v<=v_cur+90)) and (func_rom(rom_pos+8)(6)='1')) or
                   (((h>h_cur+70 and h<=h_cur+80) and (v>v_cur+80 and v<=v_cur+90)) and (func_rom(rom_pos+8)(7)='1')) or
                    --- karakterin 10. satırı
                   (((h>h_cur+0 and h<=h_cur+10) and (v>v_cur+90 and v<=v_cur+100))  and (func_rom(rom_pos+9)(0)='1')) or 
                   (((h>h_cur+10 and h<=h_cur+20) and (v>v_cur+90 and v<=v_cur+100)) and (func_rom(rom_pos+9)(1)='1')) or
                   (((h>h_cur+20 and h<=h_cur+30) and (v>v_cur+90 and v<=v_cur+100)) and (func_rom(rom_pos+9)(2)='1')) or
                   (((h>h_cur+30 and h<=h_cur+40) and (v>v_cur+90 and v<=v_cur+100)) and (func_rom(rom_pos+9)(3)='1')) or
                   (((h>h_cur+40 and h<=h_cur+50) and (v>v_cur+90 and v<=v_cur+100)) and (func_rom(rom_pos+9)(4)='1')) or
                   (((h>h_cur+50 and h<=h_cur+60) and (v>v_cur+90 and v<=v_cur+100)) and (func_rom(rom_pos+9)(5)='1')) or
                   (((h>h_cur+60 and h<=h_cur+70) and (v>v_cur+90 and v<=v_cur+100)) and (func_rom(rom_pos+9)(6)='1')) or
                   (((h>h_cur+70 and h<=h_cur+80) and (v>v_cur+90 and v<=v_cur+100)) and (func_rom(rom_pos+9)(7)='1')) or
                    --- karakterin 11. satırı
                   (((h>h_cur+0 and h<=h_cur+10) and (v>v_cur+100 and v<=v_cur+110))  and (func_rom(rom_pos+10)(0)='1')) or 
                   (((h>h_cur+10 and h<=h_cur+20) and (v>v_cur+100 and v<=v_cur+110)) and (func_rom(rom_pos+10)(1)='1')) or
                   (((h>h_cur+20 and h<=h_cur+30) and (v>v_cur+100 and v<=v_cur+110)) and (func_rom(rom_pos+10)(2)='1')) or
                   (((h>h_cur+30 and h<=h_cur+40) and (v>v_cur+100 and v<=v_cur+110)) and (func_rom(rom_pos+10)(3)='1')) or
                   (((h>h_cur+40 and h<=h_cur+50) and (v>v_cur+100 and v<=v_cur+110)) and (func_rom(rom_pos+10)(4)='1')) or
                   (((h>h_cur+50 and h<=h_cur+60) and (v>v_cur+100 and v<=v_cur+110)) and (func_rom(rom_pos+10)(5)='1')) or
                   (((h>h_cur+60 and h<=h_cur+70) and (v>v_cur+100 and v<=v_cur+110)) and (func_rom(rom_pos+10)(6)='1')) or
                   (((h>h_cur+70 and h<=h_cur+80) and (v>v_cur+100 and v<=v_cur+110)) and (func_rom(rom_pos+10)(7)='1')) or
                    --- karakterin 12. satırı
                   (((h>h_cur+0 and h<=h_cur+10) and (v>v_cur+110 and v<=v_cur+120))  and (func_rom(rom_pos+11)(0)='1')) or 
                   (((h>h_cur+10 and h<=h_cur+20) and (v>v_cur+110 and v<=v_cur+120)) and (func_rom(rom_pos+11)(1)='1')) or
                   (((h>h_cur+20 and h<=h_cur+30) and (v>v_cur+110 and v<=v_cur+120)) and (func_rom(rom_pos+11)(2)='1')) or
                   (((h>h_cur+30 and h<=h_cur+40) and (v>v_cur+110 and v<=v_cur+120)) and (func_rom(rom_pos+11)(3)='1')) or
                   (((h>h_cur+40 and h<=h_cur+50) and (v>v_cur+110 and v<=v_cur+120)) and (func_rom(rom_pos+11)(4)='1')) or
                   (((h>h_cur+50 and h<=h_cur+60) and (v>v_cur+110 and v<=v_cur+120)) and (func_rom(rom_pos+11)(5)='1')) or
                   (((h>h_cur+60 and h<=h_cur+70) and (v>v_cur+110 and v<=v_cur+120)) and (func_rom(rom_pos+11)(6)='1')) or
                   (((h>h_cur+70 and h<=h_cur+80) and (v>v_cur+110 and v<=v_cur+120)) and (func_rom(rom_pos+11)(7)='1')) or
                    --- karakterin 13. satırı
                   (((h>h_cur+0 and h<=h_cur+10) and (v>v_cur+120 and v<=v_cur+130))  and (func_rom(rom_pos+12)(0)='1')) or 
                   (((h>h_cur+10 and h<=h_cur+20) and (v>v_cur+120 and v<=v_cur+130)) and (func_rom(rom_pos+12)(1)='1')) or
                   (((h>h_cur+20 and h<=h_cur+30) and (v>v_cur+120 and v<=v_cur+130)) and (func_rom(rom_pos+12)(2)='1')) or
                   (((h>h_cur+30 and h<=h_cur+40) and (v>v_cur+120 and v<=v_cur+130)) and (func_rom(rom_pos+12)(3)='1')) or
                   (((h>h_cur+40 and h<=h_cur+50) and (v>v_cur+120 and v<=v_cur+130)) and (func_rom(rom_pos+12)(4)='1')) or
                   (((h>h_cur+50 and h<=h_cur+60) and (v>v_cur+120 and v<=v_cur+130)) and (func_rom(rom_pos+12)(5)='1')) or
                   (((h>h_cur+60 and h<=h_cur+70) and (v>v_cur+120 and v<=v_cur+130)) and (func_rom(rom_pos+12)(6)='1')) or
                   (((h>h_cur+70 and h<=h_cur+80) and (v>v_cur+120 and v<=v_cur+130)) and (func_rom(rom_pos+12)(7)='1')) or
                    --- karakterin 14. satırı
                   (((h>h_cur+0 and h<=h_cur+10) and (v>v_cur+130 and v<=v_cur+140))  and (func_rom(rom_pos+13)(0)='1')) or 
                   (((h>h_cur+10 and h<=h_cur+20) and (v>v_cur+130 and v<=v_cur+140)) and (func_rom(rom_pos+13)(1)='1')) or
                   (((h>h_cur+20 and h<=h_cur+30) and (v>v_cur+130 and v<=v_cur+140)) and (func_rom(rom_pos+13)(2)='1')) or
                   (((h>h_cur+30 and h<=h_cur+40) and (v>v_cur+130 and v<=v_cur+140)) and (func_rom(rom_pos+13)(3)='1')) or
                   (((h>h_cur+40 and h<=h_cur+50) and (v>v_cur+130 and v<=v_cur+140)) and (func_rom(rom_pos+13)(4)='1')) or
                   (((h>h_cur+50 and h<=h_cur+60) and (v>v_cur+130 and v<=v_cur+140)) and (func_rom(rom_pos+13)(5)='1')) or
                   (((h>h_cur+60 and h<=h_cur+70) and (v>v_cur+130 and v<=v_cur+140)) and (func_rom(rom_pos+13)(6)='1')) or
                   (((h>h_cur+70 and h<=h_cur+80) and (v>v_cur+130 and v<=v_cur+140)) and (func_rom(rom_pos+13)(7)='1')) or
                    --- karakterin 15. satırı
                   (((h>h_cur+0 and h<=h_cur+10) and (v>v_cur+140 and v<=v_cur+150))  and (func_rom(rom_pos+14)(0)='1')) or 
                   (((h>h_cur+10 and h<=h_cur+20) and (v>v_cur+140 and v<=v_cur+150)) and (func_rom(rom_pos+14)(1)='1')) or
                   (((h>h_cur+20 and h<=h_cur+30) and (v>v_cur+140 and v<=v_cur+150)) and (func_rom(rom_pos+14)(2)='1')) or
                   (((h>h_cur+30 and h<=h_cur+40) and (v>v_cur+140 and v<=v_cur+150)) and (func_rom(rom_pos+14)(3)='1')) or
                   (((h>h_cur+40 and h<=h_cur+50) and (v>v_cur+140 and v<=v_cur+150)) and (func_rom(rom_pos+14)(4)='1')) or
                   (((h>h_cur+50 and h<=h_cur+60) and (v>v_cur+140 and v<=v_cur+150)) and (func_rom(rom_pos+14)(5)='1')) or
                   (((h>h_cur+60 and h<=h_cur+70) and (v>v_cur+140 and v<=v_cur+150)) and (func_rom(rom_pos+14)(6)='1')) or
                   (((h>h_cur+70 and h<=h_cur+80) and (v>v_cur+140 and v<=v_cur+150)) and (func_rom(rom_pos+14)(7)='1')) or
                    --- karakterin 16. satırı
                   (((h>h_cur+0 and h<=h_cur+10) and (v>v_cur+150 and v<=v_cur+160))  and (func_rom(rom_pos+15)(0)='1')) or 
                   (((h>h_cur+10 and h<=h_cur+20) and (v>v_cur+150 and v<=v_cur+160)) and (func_rom(rom_pos+15)(1)='1')) or
                   (((h>h_cur+20 and h<=h_cur+30) and (v>v_cur+150 and v<=v_cur+160)) and (func_rom(rom_pos+15)(2)='1')) or
                   (((h>h_cur+30 and h<=h_cur+40) and (v>v_cur+150 and v<=v_cur+160)) and (func_rom(rom_pos+15)(3)='1')) or
                   (((h>h_cur+40 and h<=h_cur+50) and (v>v_cur+150 and v<=v_cur+160)) and (func_rom(rom_pos+15)(4)='1')) or
                   (((h>h_cur+50 and h<=h_cur+60) and (v>v_cur+150 and v<=v_cur+160)) and (func_rom(rom_pos+15)(5)='1')) or
                   (((h>h_cur+60 and h<=h_cur+70) and (v>v_cur+150 and v<=v_cur+160)) and (func_rom(rom_pos+15)(6)='1')) or
                   (((h>h_cur+70 and h<=h_cur+80) and (v>v_cur+150 and v<=v_cur+160)) and (func_rom(rom_pos+15)(7)='1')) ) then
				temp:= true;
				else
				temp:=false;
				end if;
	  
	  
	 return temp; 
	end draw_func;
	


	
	begin
------ Horizontal and vertical Positon counter is perform these processes ------
Horizontal_position_counter:process(CLK, RST)
begin
    
	if(RST = '1')then
		hpos <= 0;
	elsif(CLK'event and CLK = '1')then
		if (hPos = (HD + HFP + HSP + HBP)) then
			hPos <= 0;
		else
			hPos <= hPos + 1;
		end if;
	end if;
end process;

Vertical_position_counter:process(CLK, RST, hPos)
begin
	if(RST = '1')then
		vPos <= 0;
	elsif(CLK'event and CLK = '1')then
		if(hPos = (HD + HFP + HSP + HBP))then
			if (vPos = (VD + VFP + VSP + VBP)) then
				vPos <= 0;
			else
				vPos <= vPos + 1;
			end if;
		end if;
	end if;
end process;
-------Horizontal and vertical Positon counter END -------

-------Horizontal and vertical Synchronisation is perform in these processes-----
Horizontal_Synchronisation:process(CLK, RST, hPos)
begin
	if(RST = '1')then
		HSYNC <= '0';
	elsif(CLK'event and CLK = '1')then
		if((hPos <= (HD + HFP)) OR (hPos > HD + HFP + HSP))then
			HSYNC <= '1';
		else
			HSYNC <= '0';
		end if;
	end if;
end process;

Vertical_Synchronisation:process(CLK, RST, vPos)
begin
	if(RST = '1')then
		VSYNC <= '0';
	elsif(CLK'event and CLK = '1')then
		if((vPos <= (VD + VFP)) OR (vPos > VD + VFP + VSP))then
			VSYNC <= '1';
		else
			VSYNC <= '0';
		end if;
	end if;
end process;
------Horizontal and vertical Synchronisation END ------

----- Checkin whether in Display area or not -------
video_on:process(CLK, RST, hPos, vPos)
begin
	if(RST = '1')then
		videoOn <= '0';
	elsif(CLK'event and CLK = '1')then
		if(hPos <= HD and vPos <= VD)then
			videoOn <= '1';
		else
			videoOn <= '0';
		end if;
	end if;
end process;
---------- Checkin whether in Display area or not END -------

-----Drawing or driving character on monitor----------
draw:process(CLK, RST, hPos, vPos, videoOn)
begin
	if(RST = '1')then
		R <= '0';
		G <= '0';
		B <= '0';
		
	elsif(CLK'event and CLK = '1')then
		if(videoOn = '1')then
	
			if (draw_func(hpos,vpos,char_h_poscur,char_v_poscur,char_rom_pos(0), ROM)) then
		
			  R<=RGB_RENK(0);
		      G<=RGB_RENK(1);
		      B<=RGB_RENK(2);
				
				
			else
				R<='0';
                G<='0';
                B<='0';
				
			end if;
			
		else
				R<='0';
                G<='0';
                B<='0';
				
		end if;
	end if;
end process;
-----Drawing or driving character on monitor END----------

----Determining which letter is come from the gesture glove  and sending it to monitor-----
harf_secimi: process(CLK)
begin

if(RST = '1')then
   kacinci_harf <=0;
	char_rom_pos<=(0,0,0,0,0,0,0,0,0,0,0);
	elsif( CLK'event and CLK = '1')then
	
			 harf_secilsinmi_kontrol<=harf_secilsinmi;
	
	  if((harf_secilsinmi_kontrol='1')and (kacinci_harf_kontrol='0')) then -- when drawing letter is requested
		char_rom_pos(kacinci_harf)<=(to_integer(unsigned(secilen_harf))*16);
		bekleme_sinyali<=bekleme_sinyali+1;
		    if(bekleme_sinyali="11111111111111111111111") then
				kacinci_harf_kontrol<='1';
			 bekleme_sinyali<="00000000000000000000000";
			end if; 
	 
	  elsif((kacinci_harf_kontrol='1') and (harf_secilsinmi_kontrol='0'))then
	  bekleme_sinyali2<=bekleme_sinyali2+1;
	    if(bekleme_sinyali2="11111111111111111111111") then
	        kacinci_harf_kontrol<='0'; 
			 bekleme_sinyali2<="00000000000000000000000";
			end if; 
	  end if;
	  
	 
	end if;

end process;
----Determining which letter is come from the gesture glove END -----

end Behavioral;
