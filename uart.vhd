-- uart.vhd: UART controller - receiving part
-- Author(s): xbelov04
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------
entity UART_RX is
port(	
    CLK: 	    in std_logic;
	RST: 	    in std_logic;
	DIN: 	    in std_logic;
	DOUT: 	    out std_logic_vector(7 downto 0);
	DOUT_VLD: 	out std_logic;
	DIN_E:		out std_logic
);
end UART_RX;  

-------------------------------------------------
architecture behavioral of UART_RX is
signal cnt7  : std_logic_vector(3 downto 0):= "0000";
signal cnt15 : std_logic_vector(4 downto 0):= "00000";
signal cnt3 : std_logic_vector(2 downto 0):= "000";
signal din_en : std_logic;
signal dout_valid : std_logic;
signal cnt3_en : std_logic;
begin
	FSM: entity work.UART_FSM(behavioral)
	port map(
		CLK =>    CLK,
		RST =>    RST,
		DIN =>    DIN,
		CNT7 =>   cnt7,
		CNT15 =>  cnt15,
		CNT3 => cnt3,
		RD_EN => din_en,
		VLD => dout_valid,
		CNT3_EN => cnt3_en
	);
	process (CLK) begin
		if CLK'event and CLK = '1' then
			DIN_E <= din_en;
			if RST = '0' and din_en = '1' then
				DOUT_VLD <= dout_valid;
				cnt15 <= cnt15 + 1;
				if cnt15 = "01111" then
					cnt15 <= "00000";
				end if;
				if cnt15 = "01110" then
					case cnt7 is
						when "0000" => DOUT(0) <= DIN;
						when "0001" => DOUT(1) <= DIN;
						when "0010" => DOUT(2) <= DIN;
						when "0011" => DOUT(3) <= DIN;
						when "0100" => DOUT(4) <= DIN;
						when "0101" => DOUT(5) <= DIN;
						when "0110" => DOUT(6) <= DIN;
						when "0111" => DOUT(7) <= DIN;
						when others => null;
					end case;
					cnt7 <= cnt7 + 1;
				end if;
			else
				cnt7 <= "0000";
				cnt15 <= "00000";
			end if;
			if cnt3_en = '1' then
				cnt3 <= cnt3 + 1;
			else
				cnt3 <= "000";
			end if;
		end if;
	end process;
end behavioral;
