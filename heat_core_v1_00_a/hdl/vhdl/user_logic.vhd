
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;

library unisim;
use UNISIM.VComponents.all;

entity user_logic is
  generic
  (
    C_SLV_DWIDTH                   : integer              := 32;
    C_NUM_REG                      : integer              := 8;
    C_NUM_LUTS	                   : integer 	          := 1024
  );
  port
  (
    Bus2IP_Clk                     : in  std_logic;
    Bus2IP_Reset                   : in  std_logic;
    Bus2IP_Data                    : in  std_logic_vector(0 to C_SLV_DWIDTH-1);
    Bus2IP_BE                      : in  std_logic_vector(0 to C_SLV_DWIDTH/8-1);
    Bus2IP_RdCE                    : in  std_logic_vector(0 to C_NUM_REG-1);
    Bus2IP_WrCE                    : in  std_logic_vector(0 to C_NUM_REG-1);
    IP2Bus_Data                    : out std_logic_vector(0 to C_SLV_DWIDTH-1);
    IP2Bus_RdAck                   : out std_logic;
    IP2Bus_WrAck                   : out std_logic;
    IP2Bus_Error                   : out std_logic
  );

  attribute SIGIS : string;
  attribute SIGIS of Bus2IP_Clk    : signal is "CLK";
  attribute SIGIS of Bus2IP_Reset  : signal is "RST";
  
  attribute keep_hierarchy : string;
  attribute keep_hierarchy of user_logic : entity is "true";
  
end entity user_logic;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of user_logic is
  
  signal slv_reg0                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg1                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg2                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg3                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg4                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg5                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg6                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg7                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg_write_sel              : std_logic_vector(0 to 7);
  signal slv_reg_read_sel               : std_logic_vector(0 to 7);
  signal slv_ip2bus_data                : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_read_ack                   : std_logic;
  signal slv_write_ack                  : std_logic;
  signal offset								 : integer;
  constant C_MAX_OFFSET                 : integer := C_NUM_LUTS - 31;

	component lut_oscilator is
    Port ( en     : in  STD_LOGIC;
			  Q 		: out STD_LOGIC);
	end component;

  signal inout_bit 	 : std_logic;
  signal inout_vector : std_logic_vector (C_NUM_LUTS downto 0) := (others=>'0');
  signal and_value	 :	std_logic;
	
	signal direction : std_logic_vector(32 downto 0) := (others => '0');


  attribute keep : string;
  attribute keep of inout_vector : signal is "true";
  attribute keep of IMP : architecture is "true";
  
  signal adjust : std_logic_vector (31 downto 0);
  signal adjust_heaters : std_logic_vector (31 downto 0) := (others => '0');
  constant block_items : integer := C_NUM_LUTS / 32;
  signal enable_heater : std_logic;
  signal enable_vector : std_logic_vector (C_NUM_LUTS - 1 downto 0);
  signal j : integer := 0;
  signal enabled_count : integer := 0;
  signal temp : std_logic_vector (5 downto 0);
  signal enable_count : std_logic_vector (31 downto 0);
  signal int_adjust : integer := 0;
  signal adjust_temp : integer;

  
begin
	
  adjust_heaters <= slv_reg1;


  init_proc : process( adjust_heaters, enable_heater ) is
  begin		
	for i in 0 to 31 loop
		for j in 0 to block_items - 1 loop
			enable_vector(block_items * i + j) <= adjust_heaters(i) and enable_heater;
		end loop;
	end loop;
  end process init_proc;

  enable : process ( slv_reg0 ) is
  begin
		if slv_reg0 = 1 then
			enable_heater <= '1';
		else
			enable_heater <= '0';
		end if;
  end process enable;


	luts : for bit_index in 0 to C_NUM_LUTS - 1 generate
	begin

		lut_osc : lut_oscilator
		port map (	en 	=> enable_vector(bit_index),
				Q 		=> inout_vector(bit_index));
						

		
	end generate luts;

  slv_reg_write_sel <= Bus2IP_WrCE(0 to 7);
  slv_reg_read_sel  <= Bus2IP_RdCE(0 to 7);
  slv_write_ack     <= Bus2IP_WrCE(0) or Bus2IP_WrCE(1) or Bus2IP_WrCE(2) or Bus2IP_WrCE(3) or Bus2IP_WrCE(4) or Bus2IP_WrCE(5) or Bus2IP_WrCE(6) or Bus2IP_WrCE(7);
  slv_read_ack      <= Bus2IP_RdCE(0) or Bus2IP_RdCE(1) or Bus2IP_RdCE(2) or Bus2IP_RdCE(3) or Bus2IP_RdCE(4) or Bus2IP_RdCE(5) or Bus2IP_RdCE(6) or Bus2IP_RdCE(7);

  SLAVE_REG_WRITE_PROC : process( Bus2IP_Clk ) is
  begin

    if Bus2IP_Clk'event and Bus2IP_Clk = '1' then
      if Bus2IP_Reset = '1' then
        slv_reg0 <= (others => '0');
        slv_reg1 <= (others => '0');
        slv_reg2 <= (others => '0');
        slv_reg3 <= (others => '0');
        slv_reg4 <= (others => '0');
        slv_reg5 <= (others => '0');
        slv_reg6 <= (others => '0');
        slv_reg7 <= (others => '0');
      else
        case slv_reg_write_sel is
          when "10000000" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
				    slv_reg0(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
				
          when "01000000" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg1(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;

         if slv_reg2 = 0 then
	    adjust_heaters <= adjust_heaters(30 downto 0) & '0';
		
	 elsif slv_reg2 = 1 then
	    adjust_heaters <= '1' & adjust_heaters(31 downto 1);
	 end if;			
				
			
          when "00100000" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg2(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
	 			
          when "00010000" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg3(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "00001000" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg4(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "00000100" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg5(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "00000010" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg6(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "00000001" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg7(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when others => null;
        end case;
      end if;
    end if;

  end process SLAVE_REG_WRITE_PROC;
  
  offset <= conv_integer(slv_reg3);

  SLAVE_REG_READ_PROC : process( slv_reg_read_sel, slv_reg0, slv_reg1, slv_reg2, slv_reg3, slv_reg4, slv_reg5, slv_reg6, slv_reg7 ) is
  begin

    case slv_reg_read_sel is
      when "10000000" => slv_ip2bus_data <= "0000000000000000000000000000000" & enable_heater;
      when "01000000" => slv_ip2bus_data <= adjust_heaters;
      when "00100000" => slv_ip2bus_data <= slv_reg2;
      when "00010000" => slv_ip2bus_data <= slv_reg3;
      when "00001000" => slv_ip2bus_data <= slv_reg4;
      when "00000100" => slv_ip2bus_data <= slv_reg5;
      when "00000010" => slv_ip2bus_data <= slv_reg6;
      when "00000001" => slv_ip2bus_data <= inout_vector(C_NUM_LUTS - offset - 1 downto C_NUM_LUTS - offset - 32);
      when others => slv_ip2bus_data <= (others => '0');
    end case;

  end process SLAVE_REG_READ_PROC;

  IP2Bus_Data  <= slv_ip2bus_data when slv_read_ack = '1' else
                  (others => '0');

  IP2Bus_WrAck <= slv_write_ack;
  IP2Bus_RdAck <= slv_read_ack;
  IP2Bus_Error <= '0';

end IMP;

