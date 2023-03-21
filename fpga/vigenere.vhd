library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

-- rozhrani Vigenerovy sifry
entity vigenere is
   port(
         CLK : in std_logic;
         RST : in std_logic;
         DATA : in std_logic_vector(7 downto 0);
         KEY : in std_logic_vector(7 downto 0);

         CODE : out std_logic_vector(7 downto 0)
    );
end vigenere;

-- V souboru fpga/sim/tb.vhd naleznete testbench, do ktereho si doplnte
-- znaky vaseho loginu (velkymi pismeny) a znaky klice dle vaseho prijmeni.

architecture behavioral of vigenere is

    -- Sem doplnte definice vnitrnich signalu, prip. typu, pro vase reseni,
    -- jejich nazvy doplnte tez pod nadpis Vigenere Inner Signals v souboru
    -- fpga/sim/isim.tcl. Nezasahujte do souboru, ktere nejsou explicitne
    -- v zadani urceny k modifikaci.


    -- types

	type fsmState is (insert, remove);


    -- signals

	signal shift: std_logic_vector(7 downto 0);

	signal minusCor: std_logic_vector(7 downto 0);

	signal plusCor: std_logic_vector(7 downto 0);

	signal state: fsmState := insert;

	signal nstate: fsmState := remove;

	signal fsmOut: std_logic_vector(1 downto 0);

	signal hashtag: std_logic_vector(7 downto 0):= "00100011"; -- 35 written in binary, represent hashtag


    -- constants
	
	constant ASCIIShift: integer := 64; 	--capital letter A has ASCII value 65 so by substracting 64 from A
       					    	--we get the desired shift of size 1. B is 66 so shift for B will be 2 etc.

	constant smallestNumber: integer := 47; --ASCII value of / because 48 is 0

	constant biggestNumber: integer := 58;  --ASCII value of : because 49 is 9

	constant firstLetter: integer := 65;	--ASCII value of A

	constant lastLetter: integer := 90;	--ASCII value of Z

	


    --	signal Mealy: std_logic_vector(7 downto 0);

begin

    -- Sem doplnte popis obvodu. Doporuceni: pouzivejte zakladni obvodove prvky
    -- (multiplexory, registry, dekodery,...), jejich funkce popisujte pomoci
    -- procesu VHDL a propojeni techto prvku, tj. komunikaci mezi procesy,
    -- realizujte pomoci vnitrnich signalu deklarovanych vyse.

    -- DODRZUJTE ZASADY PSANI SYNTETIZOVATELNEHO VHDL KODU OBVODOVYCH PRVKU,
    -- JEZ JSOU PROBIRANY ZEJMENA NA UVODNICH CVICENI INP A SHRNUTY NA WEBU:
    -- http://merlin.fit.vutbr.cz/FITkit/docs/navody/synth_templates.html.




	statelogic: process (CLK, RST) is
	begin
		if (RST = '1') then
			state <= insert;
		elsif (CLK'event) and (CLK='1') then
			state <= nstate;
		end if;
	end process;

	fsmMealy: process (state, RST, DATA) is
	begin

		case state is 
			when insert =>
				nstate <= remove;
				fsmOut <= "00";    --"00" is plusCor
			when remove =>
				nstate <= insert;
				fsmOut <= "01";	   --"01" is minusCor
		end case;

		if (RST = '1') then
			fsmOut <= "10";
		end if;


		if ((DATA > smallestNumber) and (DATA < biggestNumber)) then
			fsmOut <= "10";		   --"10" is hashtag
		end if;
		

	end process;

	with fsmOut select
		
		CODE <= plusCor when "00",
			minusCor when "01",
			hashtag when others;

	----shift----
		shiftProcess: process (DATA, KEY) is
	begin
		shift <= KEY - ASCIIshift;
	end process;

	----s plus korekci----
	shiftRightProcess: process (shift, DATA) is
		variable foo: std_logic_vector(7 downto 0);
	begin
		foo := DATA;
		foo := foo + shift;

		if (foo > lastLetter) then
			foo := foo - (lastLetter - firstLetter);
		end if;

		plusCor <= foo;	
		
	end process;
	
	----s minus korekci----
	shiftLeftProcess: process (shift, DATA) is
		variable foo: std_logic_vector(7 downto 0);
	begin
		foo := DATA;
		foo := foo - shift;

		if (foo < firstLetter) then
			foo := foo + (lastLetter - firstLetter);
		end if;

		minusCor <= foo;	

	end process;

end behavioral;
