library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.utils_pkg.all;

entity top is
generic(
    WIDTH_KERNEL: integer := 5;
    SIZE_KERNEL: integer := 5;
    
    WIDTH_PIC: integer := 8;
    SIZE_PIC: integer := 10
);
port(
    top_clk: in std_logic;
    top_rst: in std_logic;
    --Input picture--
    top_matrix_addr_o: out std_logic_vector(log2c(SIZE_PIC*SIZE_PIC)-1 downto 0);
    top_matrix_data_i: in std_logic_vector(WIDTH_PIC-1 downto 0);
    top_matrix_wr_o:    out std_logic;
    --Log Kernel mask
    top_log_addr_o: out std_logic_vector(log2c(SIZE_KERNEL*SIZE_KERNEL)-1 downto 0);
    top_log_data_i: in std_logic_vector(WIDTH_KERNEL-1 downto 0);
    top_log_wr_o:    out std_logic;
    --Inputs
    top_l1_in: in std_logic_vector(3 downto 0);
    --top_l2_in: in std_logic_vector(2 downto 0);
  
    top_border1_in: in std_logic_vector(3 downto 0);
    --top_border2_in: in std_logic_vector(3 downto 0);
    
    top_width_in: in std_logic_vector(log2c(SIZE_PIC)-1  downto 0);
    top_height_in: in std_logic_vector(log2c(SIZE_PIC)-1  downto 0);
    --Newinp picture--
    top_im_addr_o: out std_logic_vector(log2c(SIZE_PIC*SIZE_PIC)-1 downto 0);
    top_im_data_o: out std_logic_vector(WIDTH_PIC-1 downto 0);
    top_im_wr_o:    out std_logic;
    top_im_we_o :  out std_logic; 
    --Command interface--
    top_start: in std_logic;
    top_start2: in std_logic;
    --Status interface--
    top_ready: out std_logic
);

end top;

architecture struct of top is

attribute use_dsp : string;
attribute use_dsp of struct : architecture is "yes"; 

signal new_addresa_s:  std_logic_vector(log2c(SIZE_PIC*SIZE_PIC)-1 downto 0);
signal new_data_s:  std_logic_vector(2*WIDTH_PIC+SIZE_PIC-1 downto 0);
signal new_wr_s:    std_logic;
signal new_we_s :   std_logic; 
signal max_value_s: std_logic_vector(2*WIDTH_PIC+SIZE_PIC-1 downto 0);

signal ready_s: std_logic;
signal ready1_s: std_logic;


signal c_addr_s:  std_logic_vector(log2c(SIZE_PIC*SIZE_PIC)-1 downto 0);
signal c_data_s:  std_logic_vector(2*WIDTH_PIC+SIZE_PIC-1 downto 0);
signal c_wr_s:    std_logic;
signal c_we_s :   std_logic; 

begin
    
    laplacian: entity work.laplacian(two_seg_arch)
    generic map(
        SIZE_KERNEL => SIZE_KERNEL,
        WIDTH_KERNEL => WIDTH_KERNEL,
        WIDTH_PIC => WIDTH_PIC,
        SIZE_PIC => SIZE_PIC,
        SIGNED_UNSIGNED => "signed"
    )
    port map (
        clk => top_clk,
        rst => top_rst,
        
        matrix_addr_o => top_matrix_addr_o,
        matrix_data_i => top_matrix_data_i,
        matrix_wr_o => top_matrix_wr_o,
        
        log_addr_o => top_log_addr_o,
        log_data_i => top_log_data_i,
        log_wr_o => top_log_wr_o,
        --Inputs
        l1_in => top_l1_in,
        --l2_in => top_l2_in,
  
        border1_in => top_border1_in,
       -- border2_in => top_border2_in,
    
        width_in => top_width_in,
        height_in => top_height_in,
        --Newinp picture--
        new_addr_o => new_addresa_s,
        new_data_o => new_data_s,
        new_wr_o => new_wr_s,
        new_we_o  => new_we_s,
        
        max_value => max_value_s,
        --Command interface--
        start => top_start,
        --Status interface--
        ready => top_ready
    );
    ZERO_CROSSING: entity work.zero_crossing_trsh(Behavioral)
    generic map(
        SIZE => SIZE_PIC,
        WIDTH => WIDTH_PIC    
    )
    port map(
            clk => top_clk, 
            reset => top_rst,
            
            start => top_start2,
            max_value => max_value_s,
    
            height_in => top_height_in,
            width_in => top_width_in,

            --NEW INPUT MEMORY INTERFACE
            c_addr_o => c_addr_s,
            c_data_i => c_data_s,
            c_en_o => c_we_s,
            c_wr_o => c_wr_s,
    
            --RESULT IM MEMORY INTERFACE
            im_addr_o => top_im_addr_o,
            im_data_o => top_im_data_o,
            im_en_o => top_im_we_o,
            im_wr_o => top_im_wr_o,
            ready => ready1_s
    );
  
    new_inp_mem: entity work.memory_beh(beh)
    generic map (
      width_g => 2*WIDTH_PIC+SIZE_PIC,
        size_g => SIZE_PIC)
    port map (
        clka => top_clk,
        clkb => top_clk,
        --upis
        ena => new_wr_s,
        wea => new_we_s,
        addra => new_addresa_s,
        dia => new_data_s,
        doa => open,
        --citanje
        enb => c_wr_s,
        web => '0',
        addrb => c_addr_s,
        dib => (others =>'0'),
        dob => c_data_s);

end struct;










