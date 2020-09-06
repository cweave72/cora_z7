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
use work.Utils_v010_P.all;
use work.RV32_sys_CMP.all;

entity System_top is
    generic (
        IMEM_DEPTH      : integer;
        DMEM_DEPTH      : integer;
        GPIO_PORT_WIDTH : integer;
        USE_CORE_MGR_ROM : integer;
        USE_M_EXTENSION : integer := 1;
        -- Timer generics
        SWTIMER_ONLY    : integer;
        SWTIMER_WIDTH   : integer := 32;
        TIMER_WIDTH     : integer := 32;
        NUM_TIMERS      : integer;
        TICKS_PER_US    : integer
    );
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

    --signal PL_Gpio : std_logic_vector(5 downto 0);

    signal s_axi_aclk    : std_logic;
    signal s_axi_aresetn : std_logic;
    signal s_axi_awaddr  : std_logic_vector(31 downto 0);
    signal s_axi_awprot  : std_logic_vector(2 downto 0);
    signal s_axi_awvalid : std_logic;
    signal s_axi_awready : std_logic;
    signal s_axi_wdata   : std_logic_vector(31 downto 0);
    signal s_axi_wstrb   : std_logic_vector(3 downto 0);
    signal s_axi_wvalid  : std_logic;
    signal s_axi_wready  : std_logic;
    signal s_axi_bresp   : std_logic_vector(1 downto 0);
    signal s_axi_bvalid  : std_logic;
    signal s_axi_bready  : std_logic;
    signal s_axi_araddr  : std_logic_vector(31 downto 0);
    signal s_axi_arprot  : std_logic_vector(2 downto 0);
    signal s_axi_arvalid : std_logic;
    signal s_axi_arready : std_logic;
    signal s_axi_rdata   : std_logic_vector(31 downto 0);
    signal s_axi_rresp   : std_logic_vector(1 downto 0);
    signal s_axi_rvalid  : std_logic;
    signal s_axi_rready  : std_logic;

    signal M_Debug_TVALID : std_logic;
    signal M_Debug_TREADY : std_logic;
    signal M_Debug_TDATA  : std_logic_vector(7 downto 0);
    signal M_Debug_TLAST  : std_logic;

    signal Rv_Gpio        : std_logic_vector(GPIO_PORT_WIDTH-1 downto 0);

    signal AXI_STR_RXD_tdata : std_logic_vector(31 downto 0);

    --signal Test_Addr : unsigned(Utils_numBits(RAM_DEPTH-1)-1 downto 0);
    --signal Test_RdData : std_logic_vector(31 downto 0);

    component system_wrapper is
        port (
            AXI_STR_RXD_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
            AXI_STR_RXD_tlast : in STD_LOGIC;
            AXI_STR_RXD_tready : out STD_LOGIC;
            AXI_STR_RXD_tvalid : in STD_LOGIC;
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
            FIXED_IO_ps_srstb : inout STD_LOGIC;
            M01_AXI_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
            M01_AXI_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
            M01_AXI_arready : in STD_LOGIC_VECTOR ( 0 to 0 );
            M01_AXI_arvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
            M01_AXI_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
            M01_AXI_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
            M01_AXI_awready : in STD_LOGIC_VECTOR ( 0 to 0 );
            M01_AXI_awvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
            M01_AXI_bready : out STD_LOGIC_VECTOR ( 0 to 0 );
            M01_AXI_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
            M01_AXI_bvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
            M01_AXI_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
            M01_AXI_rready : out STD_LOGIC_VECTOR ( 0 to 0 );
            M01_AXI_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
            M01_AXI_rvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
            M01_AXI_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
            M01_AXI_wready : in STD_LOGIC_VECTOR ( 0 to 0 );
            M01_AXI_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
            M01_AXI_wvalid : out STD_LOGIC_VECTOR ( 0 to 0 )
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

    U_system_wrapper: system_wrapper
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
            FIXED_IO_ps_srstb => open,
            --In0               => "0",
            --gpio_rtl_0_tri_o  => PL_Gpio,
            -- Master AXI port.
            M01_AXI_araddr     => s_axi_araddr,
            M01_AXI_arprot     => s_axi_arprot,
            M01_AXI_arready(0) => s_axi_arready,
            M01_AXI_arvalid(0) => s_axi_arvalid,
            M01_AXI_awaddr     => s_axi_awaddr,
            M01_AXI_awprot     => s_axi_awprot,
            M01_AXI_awready(0) => s_axi_awready,
            M01_AXI_awvalid(0) => s_axi_awvalid,
            M01_AXI_bready(0)  => s_axi_bready,
            M01_AXI_bresp      => s_axi_bresp,
            M01_AXI_bvalid(0)  => s_axi_bvalid,
            M01_AXI_rdata      => s_axi_rdata,
            M01_AXI_rready(0)  => s_axi_rready,
            M01_AXI_rresp      => s_axi_rresp,
            M01_AXI_rvalid(0)  => s_axi_rvalid,
            M01_AXI_wdata      => s_axi_wdata,
            M01_AXI_wready(0)  => s_axi_wready,
            M01_AXI_wstrb      => s_axi_wstrb,
            M01_AXI_wvalid(0)  => s_axi_wvalid,
            -- AXIS interface
            AXI_STR_RXD_tdata  => AXI_STR_RXD_tdata,
            AXI_STR_RXD_tlast  => M_Debug_TLAST,
            AXI_STR_RXD_tready => M_Debug_TREADY,
            AXI_STR_RXD_tvalid => M_Debug_TVALID
        );

    Led0_r <= '0';
    Led0_g <= '0';
    Led0_b <= '0';

    Led1_r <= '0';
    Led1_g <= '0';
    Led1_b <= '0';

    AXI_STR_RXD_tdata <= x"000000" & M_Debug_TDATA;

    U_RV32_sys: RV32_sys
        generic map(
            IMEM_DEPTH       => IMEM_DEPTH,
            DMEM_DEPTH       => DMEM_DEPTH,
            GPIO_PORT_WIDTH  => GPIO_PORT_WIDTH,
            USE_CORE_MGR_ROM => USE_CORE_MGR_ROM,
            USE_M_EXTENSION  => USE_M_EXTENSION,
            -- Timer generics
            SWTIMER_ONLY    =>  SWTIMER_ONLY,
            SWTIMER_WIDTH   =>  SWTIMER_WIDTH,
            TIMER_WIDTH     =>  TIMER_WIDTH,
            NUM_TIMERS      =>  NUM_TIMERS,
            TICKS_PER_US    =>  TICKS_PER_US
        )
        port map(
            Clk           => Clk,
            Reset_n       => Reset_n,
            -- External irqs
            Irq_ext       => "00",
            -- AXI slave interface.
            S_AXI_AWADDR  => s_axi_awaddr,
            S_AXI_AWPROT  => s_axi_awprot,
            S_AXI_AWVALID => s_axi_awvalid,
            S_AXI_AWREADY => s_axi_awready,
            S_AXI_WDATA   => s_axi_wdata,
            S_AXI_WSTRB   => s_axi_wstrb,
            S_AXI_WVALID  => s_axi_wvalid,
            S_AXI_WREADY  => s_axi_wready,
            S_AXI_BRESP   => s_axi_bresp,
            S_AXI_BVALID  => s_axi_bvalid,
            S_AXI_BREADY  => s_axi_bready,
            S_AXI_ARADDR  => s_axi_araddr,
            S_AXI_ARPROT  => s_axi_arprot,
            S_AXI_ARVALID => s_axi_arvalid,
            S_AXI_ARREADY => s_axi_arready,
            S_AXI_RDATA   => s_axi_rdata,
            S_AXI_RRESP   => s_axi_rresp,
            S_AXI_RVALID  => s_axi_rvalid,
            S_AXI_RREADY  => s_axi_rready,
            -- GPIO
            Gpio_port     => Rv_Gpio,
            -- Debug Message Stream
            M_Debug_TVALID => M_Debug_TVALID,
            M_Debug_TREADY => M_Debug_TREADY,
            M_Debug_TDATA  => M_Debug_TDATA,
            M_Debug_TLAST  => M_Debug_TLAST
        );

end architecture;
