----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/07/2022 06:29:05 PM
-- Design Name: 
-- Module Name: mem_subsystem - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.utils_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mem_subsystem is
generic(
    SIZE_KERNEL : INTEGER := 5;
    WIDTH_KERNEL : INTEGER := 5;
    WIDTH   :integer := 8;
    SIZE    :integer :=10);
port(
    clk     :in std_logic;
    reset   :in std_logic;
  
    ---------Interface to the AXI controllers------------
    --BLACK
    reg_data_i       :in std_logic_vector(log2c(SIZE)-1 downto 0);
    w_wr_i           : in std_logic;
    h_wr_i           : in std_logic;
    b1_wr_i          : in std_logic;
    l1_wr_i          : in std_logic;
    cmd1_wr_i        : in std_logic;
    cmd2_wr_i        : in std_logic;
    
    
    --GREEN
    w_axi_o     :out std_logic_vector(log2c(SIZE)-1 downto 0);
    h_axi_o    :out std_logic_vector(log2c(SIZE)-1 downto 0);
    b1_axi_o   :out std_logic_vector(3 downto 0);
    l1_axi_o        :out std_logic_vector(3 downto 0);
    cmd1_axi_o       :out std_logic;
    cmd2_axi_o       :out std_logic;
    status_axi_o    :out std_logic;
   
    mem_addr_i : in std_logic_vector(10-1 downto 0);
    mem_data_i : in std_logic_vector(32-1 downto 0);
    mem_wr_i : in std_logic;
    
    matrix_axi_data_o : out std_logic_vector(WIDTH-1 downto 0);
    log_axi_data_o : out std_logic_vector(WIDTH_KERNEL-1 downto 0);
    im_axi_data_o : out std_logic_vector(WIDTH-1 downto 0);
    
    --Interface to the laplacian module
    
    w_o      : out std_logic_vector(log2c(SIZE)-1 downto 0); --NECE SE SLAGATI SIRINA !
    h_o      : out std_logic_vector(log2c(SIZE)-1 downto 0);
    b1_o     : out std_logic_vector(3 downto 0);
    l1_o     : out std_logic_vector(3 downto 0);
    start1_o  : out std_logic;
    start2_o  : out std_logic;
    ready_i  : in std_logic;
    
    
    --Memory interface
     matrix_addr_i : in std_logic_vector(log2c(SIZE*SIZE)-1 downto 0);
     matrix_wr_i : in std_logic;
     matrix_data_o : out std_logic_vector(WIDTH-1 downto 0);
     --Kernel interface
     log_addr_i : in std_logic_vector(log2c(SIZE_KERNEL*SIZE_KERNEL)-1 downto 0);
     log_wr_i : in std_logic;
     log_data_o : out std_logic_vector(WIDTH_KERNEL-1 downto 0);
     --Result memory interface
     im_addr_i : in std_logic_vector(log2c(SIZE*SIZE)-1 downto 0);
     im_wr_i : in std_logic;
     im_data_i : in std_logic_vector(WIDTH-1 downto 0)
);
end mem_subsystem;

architecture Behavioral of mem_subsystem is
 signal w_s, h_s       : std_logic_vector(log2c(SIZE)-1 downto 0);
 signal b1_s           : std_logic_vector(3 downto 0);
 signal l1_s            : std_logic_vector(3 downto 0);
    
    signal cmd1_s, cmd2_s, status_s : std_logic;
    signal en_matrix_s, en_log_s, en_im_s: std_logic;
begin

    w_o <= w_s;
    h_o <= h_s;
    b1_o <= b1_s;
    l1_o <= l1_s;
    start1_o <= cmd1_s;
    start2_o <= cmd2_s;

    --------------REGISTERS----------------
    w_axi_o <= w_s;
    h_axi_o <= h_s;
    b1_axi_o <= b1_s;
    l1_axi_o <= l1_s;
    cmd1_axi_o <= cmd1_s;
    cmd2_axi_o <= cmd2_s;
    status_axi_o <= status_s; --ovo je u sustini ready

     --WIDTH 
    process(clk)
    begin
     if clk'event and clk = '1' then
        if reset = '1' then
            w_s <= (others => '0');
        elsif w_wr_i = '1' then
            w_s <= reg_data_i;
        end if;
     end if;
     end process;
      --HEIGHT
    process(clk)
    begin
     if clk'event and clk = '1' then
        if reset = '1' then
            h_s <= (others => '0');
        elsif h_wr_i = '1' then
            h_s <= reg_data_i;
        end if;
     end if;
     end process;
     --BORDER1
    process(clk)
    begin
     if clk'event and clk = '1' then
        if reset = '1' then
            b1_s <= (others => '0');
        elsif b1_wr_i = '1' then
            b1_s <= reg_data_i;
        end if;
     end if;
     end process;
     --L1
    process(clk)
    begin
     if clk'event and clk = '1' then
        if reset = '1' then
            l1_s <= (others => '0');
        elsif l1_wr_i = '1' then
            l1_s <= reg_data_i;
        end if;
     end if;
     end process;
     
     --CMD1
    process(clk)
    begin
     if clk'event and clk = '1' then
        if reset = '1' then
            cmd1_s <= '0';
        elsif cmd1_wr_i = '1' then
            cmd1_s <= reg_data_i(0);
        end if;
     end if;
     end process;
     --CMD2
    process(clk)
    begin
     if clk'event and clk = '1' then
        if reset = '1' then
            cmd2_s <= '0';
        elsif cmd2_wr_i = '1' then
            cmd2_s <= reg_data_i(0);
        end if;
     end if;
     end process;
     --STATUS
    process(clk)
    begin
     if clk'event and clk = '1' then
        if reset = '1' then
           status_s <= '0';
        else
           status_s <= ready_i;
        end if;
     end if;
     end process;
     
     
     ------------------MEMORIES--------------------
     -- Address decoder
 addr_dec: process (mem_addr_i)
 begin
     -- Default assignments
     en_matrix_s <= '0';
     en_log_s <= '0';
     en_im_s <= '0';
    case mem_addr_i(9 downto 8) is
        when "00" =>
            en_matrix_s <= '1';
        when "01" =>
            en_log_s <= '1';
        when others =>
            en_im_s <= '1';    
    end case;
 end process;

--Memory for storing elements of picture
picture_memory: entity work.memory_beh(beh)
   generic map(
    width_g => WIDTH,
    size_g => SIZE
   )
   port map(
    clka => clk,
    clkb => clk,
    
    ena => en_matrix_s,
    wea => mem_wr_i,
    addra => mem_addr_i(log2c(SIZE*SIZE)-1 downto 0),
    dia => mem_data_i(WIDTH-1 downto 0),
    doa => matrix_axi_data_o,
    
    enb => '1', --menjano
    web => '0', --menjano
    addrb => matrix_addr_i,
    dib => (others => '0'),
    dob => matrix_data_o
   );
    
--Memory for storing elements of kernel
kernel_memory: entity work.memory_beh(beh)
   generic map(
    width_g => WIDTH_KERNEL,
    size_g => SIZE_KERNEL
   )
   port map(
    clka => clk,
    clkb => clk,
    
    ena => en_log_s,
    wea => mem_wr_i,
    addra => mem_addr_i(log2c(SIZE_kernel*SIZE_kernel)-1 downto 0),
    dia => mem_data_i(WIDTH_kernel-1 downto 0),
    doa => log_axi_data_o,
    
    enb => '1', --menjano
    web => '0', --menjano
    addrb => log_addr_i,
    dib => (others => '0'),
    dob => log_data_o
   );
   
--Memory for storing final elements of picture
im_memory: entity work.memory_beh(beh)
   generic map(
    width_g => WIDTH,
    size_g => SIZE
   )
   port map(
    clka => clk,
    clkb => clk,
    
    ena => en_im_s,
    wea => mem_wr_i,
    addra => mem_addr_i(log2c(SIZE*SIZE)-1 downto 0),
    dia => mem_data_i(WIDTH-1 downto 0),
    doa => im_axi_data_o,
    
    enb => '1', --menjano
    web => im_wr_i, --menjano
    addrb => im_addr_i,
    dib => im_data_i,
    dob => open
   );
end Behavioral;















