--------------------------------------------------------------------------------
-- File   : system_top.vhd
-- Author : Craig D. Weaver
-- Created: 04-28-2020
--
-- Description: Top level
--
--------------------------------------------------------------------------------
-- Revision history    :
-- 04-28-2020 : cdw
-- Initial coding.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
--use work.Utils_v010_P.all;

entity System_top is
    port(
        -- Tri-color LEDs
        Led0_r : out std_logic;
        Led0_g : out std_logic;
        Led0_b : out std_logic;
        Led1_r : out std_logic;
        Led1_g : out std_logic;
        Led1_b : out std_logic;
        -- Push buttons
        Btn_0  : in std_logic;
        Btn_1  : in std_logic;
        -- User Header J1
        User_dio : inout std_logic_vector(12 downto 1)
    );
end entity;

architecture rtl of System_top is

    constant FCLK_TICKS_PER_us : integer := 50;
    constant FCLK_TICKS_PER_ms : integer := FCLK_TICKS_PER_us*1000;
    constant FCLK_TICKS_PER_s  : integer := FCLK_TICKS_PER_ms*1000;

    signal Clk     : std_logic;
    signal Reset_n : std_logic;

    signal Counter    : unsigned(15 downto 0);
    signal Counter_ms : unsigned(9 downto 0);

    signal OneSecondPulse : std_logic;
    signal HalfSecondPulse : std_logic;
    signal QuarterSecondPulse : std_logic;

    signal OneSecond : std_logic;
    signal HalfSecond : std_logic;

    --signal PL_Gpio : std_logic_vector(5 downto 0);

    --signal s_axi_aclk    : std_logic;
    --signal s_axi_aresetn : std_logic;
    --signal s_axi_awaddr  : std_logic_vector(31 downto 0);
    --signal s_axi_awprot  : std_logic_vector(2 downto 0);
    --signal s_axi_awvalid : std_logic;
    --signal s_axi_awready : std_logic;
    --signal s_axi_wdata   : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
    --signal s_axi_wstrb   : std_logic_vector((AXI_DATA_WIDTH/8)-1 downto 0);
    --signal s_axi_wvalid  : std_logic;
    --signal s_axi_wready  : std_logic;
    --signal s_axi_bresp   : std_logic_vector(1 downto 0);
    --signal s_axi_bvalid  : std_logic;
    --signal s_axi_bready  : std_logic;
    --signal s_axi_araddr  : std_logic_vector(31 downto 0);
    --signal s_axi_arprot  : std_logic_vector(2 downto 0);
    --signal s_axi_arvalid : std_logic;
    --signal s_axi_arready : std_logic;
    --signal s_axi_rdata   : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
    --signal s_axi_rresp   : std_logic_vector(1 downto 0);
    --signal s_axi_rvalid  : std_logic;
    --signal s_axi_rready  : std_logic;

    --signal Test_Addr : unsigned(Utils_numBits(RAM_DEPTH-1)-1 downto 0);
    --signal Test_RdData : std_logic_vector(31 downto 0);

    component cora_z7_wrapper is
        port (
          DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
          DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
          DDR_cas_n : inout STD_LOGIC;
          DDR_ck_n : inout STD_LOGIC;
          DDR_ck_p : inout STD_LOGIC;
          DDR_cke : inout STD_LOGIC;
          DDR_cs_n : inout STD_LOGIC;
          DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
          DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
          DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
          DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
          DDR_odt : inout STD_LOGIC;
          DDR_ras_n : inout STD_LOGIC;
          DDR_reset_n : inout STD_LOGIC;
          DDR_we_n : inout STD_LOGIC;
          FCLK_CLK0 : out STD_LOGIC;
          FCLK_RESET0_N : out STD_LOGIC;
          FIXED_IO_ddr_vrn : inout STD_LOGIC;
          FIXED_IO_ddr_vrp : inout STD_LOGIC;
          FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
          FIXED_IO_ps_clk : inout STD_LOGIC;
          FIXED_IO_ps_porb : inout STD_LOGIC;
          FIXED_IO_ps_srstb : inout STD_LOGIC
        );
    end component;

    --component ila_1
    --port (
    --    clk : IN STD_LOGIC;
    --    probe0 : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    --    probe1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0)
    --);
    --end component;

begin

    --Test_Gpio <= PL_Gpio(2 downto 0);

    U_cora_z7_wrapper: cora_z7_wrapper
        port map(
            DDR_addr          => open,
            DDR_ba            => open,
            DDR_cas_n         => open,
            DDR_ck_n          => open,
            DDR_ck_p          => open,
            DDR_cke           => open,
            DDR_cs_n          => open,
            DDR_dm            => open,
            DDR_dq            => open,
            DDR_dqs_n         => open,
            DDR_dqs_p         => open,
            DDR_odt           => open,
            DDR_ras_n         => open,
            DDR_reset_n       => open,
            DDR_we_n          => open,
            FCLK_CLK0         => Clk,
            FCLK_RESET0_N     => Reset_n,
            FIXED_IO_ddr_vrn  => open,
            FIXED_IO_ddr_vrp  => open,
            FIXED_IO_mio      => open,
            FIXED_IO_ps_clk   => open,
            FIXED_IO_ps_porb  => open,
            FIXED_IO_ps_srstb => open
            --In0               => "0",
            --gpio_rtl_0_tri_o  => PL_Gpio,
            ---- Master AXI port.
            --M01_AXI_araddr     => s_axi_araddr,
            --M01_AXI_arprot     => s_axi_arprot,
            --M01_AXI_arready(0) => s_axi_arready,
            --M01_AXI_arvalid(0) => s_axi_arvalid,
            --M01_AXI_awaddr     => s_axi_awaddr,
            --M01_AXI_awprot     => s_axi_awprot,
            --M01_AXI_awready(0) => s_axi_awready,
            --M01_AXI_awvalid(0) => s_axi_awvalid,
            --M01_AXI_bready(0)  => s_axi_bready,
            --M01_AXI_bresp      => s_axi_bresp,
            --M01_AXI_bvalid(0)  => s_axi_bvalid,
            --M01_AXI_rdata      => s_axi_rdata,
            --M01_AXI_rready(0)  => s_axi_rready,
            --M01_AXI_rresp      => s_axi_rresp,
            --M01_AXI_rvalid(0)  => s_axi_rvalid,
            --M01_AXI_wdata      => s_axi_wdata,
            --M01_AXI_wready(0)  => s_axi_wready,
            --M01_AXI_wstrb      => s_axi_wstrb,
            --M01_AXI_wvalid(0)  => s_axi_wvalid
        );

    Led0_r <= '0';
    Led0_g <= OneSecond or Btn_0;
    Led0_b <= '0';

    Led1_r <= '0';
    Led1_g <= '0';
    Led1_b <= HalfSecond or Btn_1;

    MyProc_proc: process (Clk, Reset_n)
    begin
        if (Reset_n = '0') then
            OneSecond <= '0';
            HalfSecond <= '0';
        elsif (rising_edge(Clk)) then
            if (HalfSecondPulse = '1') then
                OneSecond <= not OneSecond;
            end if;

            if (QuarterSecondPulse = '1') then
                HalfSecond <= not HalfSecond;
            end if;
    
        end if;
    end process;

    Counter_proc: process (Clk, Reset_n)
    begin
        if (Reset_n = '0') then
            Counter <= (others => '0');
            Counter_ms <= (others => '0');
            HalfSecondPulse <= '0';
            QuarterSecondPulse <= '0';
        elsif (rising_edge(Clk)) then
            HalfSecondPulse <= '0';
            QuarterSecondPulse <= '0';

            Counter <= Counter + 1;

            if (Counter = FCLK_TICKS_PER_ms-1) then
                Counter <= (others => '0');
                Counter_ms <= Counter_ms + 1;
                if (Counter_ms = 999) then
                    Counter_ms <= (others => '0');
                    HalfSecondPulse <= '1';
                    QuarterSecondPulse <= '1';
                elsif (Counter_ms = 749) then
                    QuarterSecondPulse <= '1';
                elsif (Counter_ms = 499) then
                    HalfSecondPulse <= '1';
                    QuarterSecondPulse <= '1';
                elsif (Counter_ms = 249) then
                    QuarterSecondPulse <= '1';
                end if;
            end if;
        end if;
    end process;

end architecture;
