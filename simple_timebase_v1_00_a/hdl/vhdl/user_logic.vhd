
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;


entity user_logic is
	generic
	(
		C_SLV_DWIDTH                   : integer              := 32;
		C_NUM_REG                      : integer              := 1
	);
	port
	(
		Bus2IP_Clk                     : in  std_logic;
		Bus2IP_Reset                   : in  std_logic;
		Bus2IP_Data                    : in  std_logic_vector(C_SLV_DWIDTH-1 downto 0);
		Bus2IP_BE                      : in  std_logic_vector(C_SLV_DWIDTH/8-1 downto 0);
		Bus2IP_RdCE                    : in  std_logic_vector(C_NUM_REG-1 downto 0);
		Bus2IP_WrCE                    : in  std_logic_vector(C_NUM_REG-1 downto 0);
		IP2Bus_Data                    : out std_logic_vector(C_SLV_DWIDTH-1 downto 0);
		IP2Bus_RdAck                   : out std_logic;
		IP2Bus_WrAck                   : out std_logic;
		IP2Bus_Error                   : out std_logic
	);

	attribute SIGIS : string;
	attribute SIGIS of Bus2IP_Clk    : signal is "CLK";
	attribute SIGIS of Bus2IP_Reset  : signal is "RST";

end entity user_logic;

architecture IMP of user_logic is
	signal timer : std_logic_vector(C_SLV_DWIDTH - 1 downto 0);
begin
	
	process (Bus2IP_Clk, Bus2IP_Reset) is
	begin
		if Bus2IP_Reset = '1' then
			timer <= (others => '0');
		elsif rising_edge(Bus2IP_Clk) then
			timer <= timer + 1;
			if Bus2IP_WrCE(0) = '1' then
				timer <= (others => '0');
			end if;
		end if;
	end process;
	
	IP2Bus_Data  <= timer;
	IP2Bus_WrAck <= Bus2IP_WrCE(0);
	IP2Bus_RdAck <= Bus2IP_RdCE(0);
	IP2Bus_Error <= '0';

end IMP;
