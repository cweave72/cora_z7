--------------------------------------------------------------------------------
-- File   : RV32_sys.vhd
-- Author : Craig D. Weaver
-- Created: 08-27-2020
--
-- Description: Top-level wrapper for Risc-V core.
--
--------------------------------------------------------------------------------
-- Revision history    :
-- 08-27-2020 : cdw
-- Initial coding.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package RV32_sys_CMP is
component RV32_sys is
    generic (
        IMEM_DEPTH      : integer;
        DMEM_DEPTH      : integer;
        GPIO_PORT_WIDTH : integer;
        USE_CORE_MGR_ROM : integer := 1;
        USE_M_EXTENSION : integer := 1;
        -- Timer generics
        SWTIMER_ONLY    : integer;
        SWTIMER_WIDTH   : integer := 32;
        TIMER_WIDTH     : integer := 32;
        NUM_TIMERS      : integer;
        NUM_PWM_OUTPUTS : integer;
        PWM_TIMER_WIDTH : integer;
        TICKS_PER_US    : integer
    );
    port (
        Clk           : in std_logic;
        Reset_n       : in std_logic;
        -- External irqs
        Irq_ext       : in std_logic_vector(1 downto 0);
        -- AXI slave interface.
        S_AXI_AWADDR  : in std_logic_vector(31 downto 0);
        S_AXI_AWPROT  : in std_logic_vector(2 downto 0);
        S_AXI_AWVALID : in std_logic;
        S_AXI_AWREADY : out std_logic;
        S_AXI_WDATA   : in std_logic_vector(31 downto 0);
        S_AXI_WSTRB   : in std_logic_vector(3 downto 0);
        S_AXI_WVALID  : in std_logic;
        S_AXI_WREADY  : out std_logic;
        S_AXI_BRESP   : out std_logic_vector(1 downto 0);
        S_AXI_BVALID  : out std_logic;
        S_AXI_BREADY  : in std_logic;
        S_AXI_ARADDR  : in std_logic_vector(31 downto 0);
        S_AXI_ARPROT  : in std_logic_vector(2 downto 0);
        S_AXI_ARVALID : in std_logic;
        S_AXI_ARREADY : out std_logic;
        S_AXI_RDATA   : out std_logic_vector(31 downto 0);
        S_AXI_RRESP   : out std_logic_vector(1 downto 0);
        S_AXI_RVALID  : out std_logic;
        S_AXI_RREADY  : in std_logic;
        -- GPIO
        Gpio_port     : inout std_logic_vector(GPIO_PORT_WIDTH-1 downto 0);
        -- PWM out
        Pwm_out       : out std_logic_vector(NUM_PWM_OUTPUTS-1 downto 0);
        -- Debug Message Stream
        M_Debug_TVALID : out std_logic;
        M_Debug_TREADY : in std_logic;
        M_Debug_TDATA  : out std_logic_vector(7 downto 0);
        M_Debug_TLAST  : out std_logic;
        -- Debug Trace
        DebugTrace       : out std_logic_vector(31 downto 0);
        DebugTrace_valid : out std_logic
    );
end component;
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Utils_v010_P.all;
use work.AXI_CoreMgr_CMP.all;
use work.Rom_Init_P.all;
use work.Rom_CMP.all;
use work.RV32Core_v010_CMP.all;
use work.Stream_Config_P.all;
use work.TraceProbes_P.all;

entity RV32_sys is
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
        NUM_PWM_OUTPUTS : integer;
        PWM_TIMER_WIDTH : integer;
        TICKS_PER_US    : integer
    );
    port (
        Clk           : in std_logic;
        Reset_n       : in std_logic;
        -- External irqs
        Irq_ext       : in std_logic_vector(1 downto 0);
        -- AXI slave interface.
        S_AXI_AWADDR  : in std_logic_vector(31 downto 0);
        S_AXI_AWPROT  : in std_logic_vector(2 downto 0);
        S_AXI_AWVALID : in std_logic;
        S_AXI_AWREADY : out std_logic;
        S_AXI_WDATA   : in std_logic_vector(31 downto 0);
        S_AXI_WSTRB   : in std_logic_vector(3 downto 0);
        S_AXI_WVALID  : in std_logic;
        S_AXI_WREADY  : out std_logic;
        S_AXI_BRESP   : out std_logic_vector(1 downto 0);
        S_AXI_BVALID  : out std_logic;
        S_AXI_BREADY  : in std_logic;
        S_AXI_ARADDR  : in std_logic_vector(31 downto 0);
        S_AXI_ARPROT  : in std_logic_vector(2 downto 0);
        S_AXI_ARVALID : in std_logic;
        S_AXI_ARREADY : out std_logic;
        S_AXI_RDATA   : out std_logic_vector(31 downto 0);
        S_AXI_RRESP   : out std_logic_vector(1 downto 0);
        S_AXI_RVALID  : out std_logic;
        S_AXI_RREADY  : in std_logic;
        -- GPIO
        Gpio_port     : inout std_logic_vector(GPIO_PORT_WIDTH-1 downto 0);
        -- PWM out
        Pwm_out       : out std_logic_vector(NUM_PWM_OUTPUTS-1 downto 0);
        -- Debug Message Stream
        M_Debug_TVALID : out std_logic;
        M_Debug_TREADY : in std_logic;
        M_Debug_TDATA  : out std_logic_vector(7 downto 0);
        M_Debug_TLAST  : out std_logic;
        -- Debug Trace
        DebugTrace       : out std_logic_vector(31 downto 0);
        DebugTrace_valid : out std_logic
    );
end entity;

architecture rtl of RV32_sys is

    signal Core_reset          : std_logic;
    signal Core_reset_n        : std_logic;

    signal CoreMgr_IMem_Ena    : std_logic;
    signal CoreMgr_IMem_Addr   : std_logic_vector(31 downto 0);
    signal CoreMgr_IMem_RdData : std_logic_vector(31 downto 0);

    signal Rom_IMem_Addr       : std_logic_vector(Utils_numBits(ROM_SIZE_BYTES-1)-1 downto 0);
    signal IMem_Ena            : std_logic;
    signal IMem_Addr           : std_logic_vector(31 downto 0);
    signal IMem_RdData         : std_logic_vector(31 downto 0);

    signal Gpio                : std_logic_vector(GPIO_PORT_WIDTH-1 downto 0);
    signal TimerExpired        : std_logic_vector(NUM_TIMERS-1 downto 0);
    signal TimerThresh         : std_logic_vector(NUM_TIMERS-1 downto 0);
    signal TraceProbes         : TraceProbes_rec;

    signal M_TVALID            : std_logic_vector(NUM_STREAMS-1 downto 0);
    signal M_TREADY            : std_logic_vector(NUM_STREAMS-1 downto 0);
    signal M_TDATA             : WordArray_type(NUM_STREAMS-1 downto 0);
    signal M_TLAST             : std_logic_vector(NUM_STREAMS-1 downto 0);

    signal S_TVALID            : std_logic_vector(NUM_STREAMS-1 downto 0);
    signal S_TREADY            : std_logic_vector(NUM_STREAMS-1 downto 0);
    signal S_TDATA             : WordArray_type(NUM_STREAMS-1 downto 0);
    signal S_TLAST             : std_logic_vector(NUM_STREAMS-1 downto 0);

begin

    U_AXI_CoreMgr: AXI_CoreMgr
        generic map(
            IMEM_DEPTH   => IMEM_DEPTH,
            USE_FOR_IMEM => USE_CORE_MGR_ROM
        )
        port map(
            -- AXI slave interface.
            S_AXI_ACLK    => Clk,
            S_AXI_ARESETN => Reset_n,
            S_AXI_AWADDR  => S_AXI_AWADDR,
            S_AXI_AWPROT  => S_AXI_AWPROT,
            S_AXI_AWVALID => S_AXI_AWVALID,
            S_AXI_AWREADY => S_AXI_AWREADY,
            S_AXI_WDATA   => S_AXI_WDATA,
            S_AXI_WSTRB   => S_AXI_WSTRB,
            S_AXI_WVALID  => S_AXI_WVALID,
            S_AXI_WREADY  => S_AXI_WREADY,
            S_AXI_BRESP   => S_AXI_BRESP,
            S_AXI_BVALID  => S_AXI_BVALID,
            S_AXI_BREADY  => S_AXI_BREADY,
            S_AXI_ARADDR  => S_AXI_ARADDR,
            S_AXI_ARPROT  => S_AXI_ARPROT,
            S_AXI_ARVALID => S_AXI_ARVALID,
            S_AXI_ARREADY => S_AXI_ARREADY,
            S_AXI_RDATA   => S_AXI_RDATA,
            S_AXI_RRESP   => S_AXI_RRESP,
            S_AXI_RVALID  => S_AXI_RVALID,
            S_AXI_RREADY  => S_AXI_RREADY,
            -- Control Output
            Core_reset    => Core_reset,
            -- IMem interface
            IMem_Clk      => Clk,
            IMem_Ena      => CoreMgr_IMem_Ena,
            IMem_Addr     => CoreMgr_IMem_Addr,
            IMem_RdData   => CoreMgr_IMem_RdData
        );

    UseCoreMgrRom_gen: if USE_CORE_MGR_ROM = 1 generate
    begin
        CoreMgr_IMem_Ena  <= IMem_Ena;
        CoreMgr_IMem_Addr <= IMem_Addr;
        IMem_RdData       <= CoreMgr_IMem_RdData;
    end generate;

    NoCoreMgrRom_gen: if USE_CORE_MGR_ROM = 0 generate
    begin
        CoreMgr_IMem_Ena  <= '0';
        CoreMgr_IMem_Addr <= (others => '0');
        Rom_IMem_Addr <= Utils_resize(IMem_Addr, Rom_IMem_Addr'length);

        U_Rom: Rom
            port map (
                Clk    => Clk,
                Ena    => IMem_Ena,
                Addr   => Rom_IMem_Addr,
                Data_o => IMem_RdData
            );
    end generate;

    Core_reset_n <= '0' when (Core_reset = '1' or Reset_n = '0') else '1';

    U_RV32Core_v010: RV32Core_v010
        generic map(
            DMEM_DEPTH      => DMEM_DEPTH,
            GPIO_PORT_WIDTH => GPIO_PORT_WIDTH,
            USE_M_EXTENSION => USE_M_EXTENSION,
            -- Timer generics
            SWTIMER_ONLY    => SWTIMER_ONLY,
            SWTIMER_WIDTH   => SWTIMER_WIDTH,
            TIMER_WIDTH     => TIMER_WIDTH,
            NUM_TIMERS      => NUM_TIMERS,
            NUM_PWM_OUTPUTS => NUM_PWM_OUTPUTS,
            PWM_TIMER_WIDTH => PWM_TIMER_WIDTH,
            NUM_STREAMS     => NUM_STREAMS,
            TICKS_PER_US    => TICKS_PER_US   
        )
        port map(
            Reset_n      => Core_reset_n,
            Clk          => Clk,
            -- External irqs
            Irq_ext      => Irq_ext,
            -- IMem interface (to byte-addressed memory)
            IMem_Addr    => IMem_Addr,
            IMem_Ena     => IMem_Ena,
            IMem_Data    => IMem_RdData,
            --
            GPIO_io      => Gpio,
            TimerExpired => TimerExpired,
            TimerThresh  => TimerThresh,
            Pwm_out      => Pwm_out,
            -- Outbound streams
            M_TVALID      => M_TVALID,
            M_TREADY      => M_TREADY,
            M_TDATA       => M_TDATA,
            M_TLAST       => M_TLAST,
            -- Inbound streams
            S_TVALID      => S_TVALID,
            S_TREADY      => S_TREADY,
            S_TDATA       => S_TDATA,
            S_TLAST       => S_TLAST,
            -- DebugTrace
            DebugTrace        => DebugTrace,
            DebugTrace_valid  => DebugTrace_valid,
            -- Trace
            TraceProbes  => TraceProbes
        );

    -- Stream 0: used as debug print stream.
    M_Debug_TVALID <= M_TVALID(0);
    M_TREADY(0)    <= M_Debug_TREADY;
    M_Debug_TDATA  <= M_TDATA(0)(7 downto 0);
    M_Debug_TLAST  <= M_TLAST(0);

    -- Loopback Port 1
    S_TVALID(1) <= M_TVALID(1);
    M_TREADY(1) <= S_TREADY(1);
    S_TDATA(1)  <= M_TDATA(1);
    S_TLAST(1)  <= M_TLAST(1);

end architecture;
