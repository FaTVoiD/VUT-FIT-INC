-- uart_fsm.vhd: UART controller - finite state machine
-- Author(s): xbelov04
--
library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------
entity UART_FSM is
port(
   CLK :   in std_logic;
   RST :   in std_logic;
   DIN :   in std_logic;
   CNT7 :  in std_logic_vector(3 downto 0);
   CNT15 : in std_logic_vector(4 downto 0);
   CNT3 : in std_logic_vector(2 downto 0);
   RD_EN : out std_logic;
   VLD : out std_logic;
   CNT3_EN : out std_logic
   );
end entity UART_FSM;

-------------------------------------------------
architecture behavioral of UART_FSM is
type FSM_STATE is (START_BIT, READ_DIN, STOP_BIT, DOUT_VLD);
signal state : FSM_STATE := START_BIT; 
begin
	process (CLK) begin
		if RST = '1' then
			state <= START_BIT;
			RD_EN <= '0';
			CNT3_EN <= '0';
		elsif (CLK'event and CLK = '1') then
			case state is
			when START_BIT => 
				if DIN = '0' then
					CNT3_EN <= '1';
				end if;
				if CNT3 = "111" then
					state <= READ_DIN;
					RD_EN <= '1';
					CNT3_EN <= '0';
				end if;
			when READ_DIN => 
				if CNT7 = "1000" then
					state <= STOP_BIT;
				end if;
			when STOP_BIT => if CNT15 = "01110" then
					state <= DOUT_VLD;
				end if;
			when DOUT_VLD => if CNT15 = "01001" then
					state <= START_BIT;
					RD_EN <= '0';
				end if;
			when others => null;
			end case;
		end if;
		if state = DOUT_VLD and CNT15 = "01000" then
			VLD <= '1';
		else
			VLD <= '0';
		end if;
	end process;
end behavioral;
