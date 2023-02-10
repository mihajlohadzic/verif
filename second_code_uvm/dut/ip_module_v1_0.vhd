library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

entity ip_module_v1_0 is
	generic (
		-- Users to add parameters here
            WIDTH : integer := 8;
            SIZE : integer := 10;
            WIDTH_KERNEL : integer := 5;
            SIZE_KERNEL: integer := 5;
		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 5;

		-- Parameters of Axi Slave Bus Interface S01_AXI
		C_S01_AXI_ID_WIDTH	: integer	:= 1;
		C_S01_AXI_DATA_WIDTH	: integer	:= 32;
		C_S01_AXI_ADDR_WIDTH	: integer	:= 12;
		C_S01_AXI_AWUSER_WIDTH	: integer	:= 1;
		C_S01_AXI_ARUSER_WIDTH	: integer	:= 1;
		C_S01_AXI_WUSER_WIDTH	: integer	:= 1;
		C_S01_AXI_RUSER_WIDTH	: integer	:= 1;
		C_S01_AXI_BUSER_WIDTH	: integer	:= 1
	);
	port (
		-- Users to add ports here

		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic;

		-- Ports of Axi Slave Bus Interface S01_AXI
		s01_axi_aclk	: in std_logic;
		s01_axi_aresetn	: in std_logic;
		s01_axi_awid	: in std_logic_vector(C_S01_AXI_ID_WIDTH-1 downto 0);
		s01_axi_awaddr	: in std_logic_vector(C_S01_AXI_ADDR_WIDTH-1 downto 0);
		s01_axi_awlen	: in std_logic_vector(7 downto 0);
		s01_axi_awsize	: in std_logic_vector(2 downto 0);
		s01_axi_awburst	: in std_logic_vector(1 downto 0);
		s01_axi_awlock	: in std_logic;
		s01_axi_awcache	: in std_logic_vector(3 downto 0);
		s01_axi_awprot	: in std_logic_vector(2 downto 0);
		s01_axi_awqos	: in std_logic_vector(3 downto 0);
		s01_axi_awregion	: in std_logic_vector(3 downto 0);
		s01_axi_awuser	: in std_logic_vector(C_S01_AXI_AWUSER_WIDTH-1 downto 0);
		s01_axi_awvalid	: in std_logic;
		s01_axi_awready	: out std_logic;
		s01_axi_wdata	: in std_logic_vector(C_S01_AXI_DATA_WIDTH-1 downto 0);
		s01_axi_wstrb	: in std_logic_vector((C_S01_AXI_DATA_WIDTH/8)-1 downto 0);
		s01_axi_wlast	: in std_logic;
		s01_axi_wuser	: in std_logic_vector(C_S01_AXI_WUSER_WIDTH-1 downto 0);
		s01_axi_wvalid	: in std_logic;
		s01_axi_wready	: out std_logic;
		s01_axi_bid	: out std_logic_vector(C_S01_AXI_ID_WIDTH-1 downto 0);
		s01_axi_bresp	: out std_logic_vector(1 downto 0);
		s01_axi_buser	: out std_logic_vector(C_S01_AXI_BUSER_WIDTH-1 downto 0);
		s01_axi_bvalid	: out std_logic;
		s01_axi_bready	: in std_logic;
		s01_axi_arid	: in std_logic_vector(C_S01_AXI_ID_WIDTH-1 downto 0);
		s01_axi_araddr	: in std_logic_vector(C_S01_AXI_ADDR_WIDTH-1 downto 0);
		s01_axi_arlen	: in std_logic_vector(7 downto 0);
		s01_axi_arsize	: in std_logic_vector(2 downto 0);
		s01_axi_arburst	: in std_logic_vector(1 downto 0);
		s01_axi_arlock	: in std_logic;
		s01_axi_arcache	: in std_logic_vector(3 downto 0);
		s01_axi_arprot	: in std_logic_vector(2 downto 0);
		s01_axi_arqos	: in std_logic_vector(3 downto 0);
		s01_axi_arregion	: in std_logic_vector(3 downto 0);
		s01_axi_aruser	: in std_logic_vector(C_S01_AXI_ARUSER_WIDTH-1 downto 0);
		s01_axi_arvalid	: in std_logic;
		s01_axi_arready	: out std_logic;
		s01_axi_rid	: out std_logic_vector(C_S01_AXI_ID_WIDTH-1 downto 0);
		s01_axi_rdata	: out std_logic_vector(C_S01_AXI_DATA_WIDTH-1 downto 0);
		s01_axi_rresp	: out std_logic_vector(1 downto 0);
		s01_axi_rlast	: out std_logic;
		s01_axi_ruser	: out std_logic_vector(C_S01_AXI_RUSER_WIDTH-1 downto 0);
		s01_axi_rvalid	: out std_logic;
		s01_axi_rready	: in std_logic
	);
end ip_module_v1_0;

architecture arch_imp of ip_module_v1_0 is

--SIGNAL

signal reset_s: std_logic;
--interface to the axi controllers
signal reg_data_s   :std_logic_vector(log2c(SIZE)-1 downto 0);
signal w_wr_s   :std_logic;
signal h_wr_s   :std_logic;
signal b1_wr_s   :std_logic;
signal l1_wr_s   :std_logic;
signal cmd1_wr_s   :std_logic;
signal cmd2_wr_s   :std_logic;

signal w_axi_s  :std_logic_vector(log2c(SIZE)-1  downto 0);
signal h_axi_s  :std_logic_vector(log2c(SIZE)-1  downto 0);
signal b1_axi_s  :std_logic_vector(3 downto 0);
signal l1_axi_s  :std_logic_vector(3 downto 0);
signal cmd1_axi_s  :std_logic;
signal cmd2_axi_s  :std_logic;
signal status_axi_s: std_logic;

signal mem_addr_s : std_logic_vector(10-1 downto 0);
signal mem_data_s : std_logic_vector(32-1 downto 0);
signal mem_wr_s :  std_logic;
    
 signal   matrix_axi_data_s : std_logic_vector(WIDTH-1 downto 0);
 signal   log_axi_data_s : std_logic_vector(WIDTH_KERNEL-1 downto 0);
 signal   im_axi_data_s : std_logic_vector(WIDTH-1 downto 0);

 --Interface to the laplacian module
    
 signal   w_s      :  std_logic_vector(log2c(SIZE)-1  downto 0); --NECE SE SLAGATI SIRINA !
 signal   h_s      :  std_logic_vector(log2c(SIZE)-1  downto 0);
 signal   b1_s     : std_logic_vector(3 downto 0);
 signal   l1_s     :  std_logic_vector(3 downto 0);
 signal   start1_s  :  std_logic;
 signal   start2_s  :  std_logic;
 signal   ready_s  :  std_logic;
    
    
    --Memory interface
signal    matrix_addr_s  :std_logic_vector(log2c(SIZE*SIZE)-1 downto 0);
signal    matrix_wr_s    :std_logic;
signal    matrix_data_s  :std_logic_vector(WIDTH-1 downto 0);
     --Kernel interface
signal    log_addr_s     :std_logic_vector(log2c(SIZE_KERNEL*SIZE_KERNEL)-1 downto 0);
signal    log_wr_s       :std_logic;
signal    log_data_s     :std_logic_vector(WIDTH_KERNEL-1 downto 0);
     --Result memory interface
signal    im_addr_s      :std_logic_vector(log2c(SIZE*SIZE)-1 downto 0);
signal   im_wr_s         :std_logic;
signal   im_we_s         :std_logic;

signal   im_data_s       :std_logic_vector(WIDTH-1 downto 0);

	-- component declaration
	component ip_module_v1_0_S00_AXI is
		generic (
		WIDTH             : integer := 8;
	    SIZE              : integer := 10;
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 5
		);
		port (
		     reg_data_o       :out std_logic_vector(log2c(SIZE)-1 downto 0);
            w_wr_o           : out std_logic;
            h_wr_o           : out std_logic;
            b1_wr_o          : out std_logic;
            l1_wr_o          : out std_logic;
            cmd1_wr_o        : out std_logic;
            cmd2_wr_o        : out std_logic;

            w_axi_i          :in std_logic_vector(log2c(SIZE)-1  downto 0);
            h_axi_i          :in std_logic_vector(log2c(SIZE)-1  downto 0);
            b1_axi_i         :in std_logic_vector(3 downto 0);
            l1_axi_i         :in std_logic_vector(3 downto 0);
            cmd1_axi_i       :in std_logic;
            cmd2_axi_i       :in std_logic;
            status_axi_i     :in std_logic;
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component ip_module_v1_0_S00_AXI;

	component ip_module_v1_0_S01_AXI is
		generic (
		WIDTH : integer := 8;
		SIZE : integer := 10;
		C_S_AXI_ID_WIDTH	: integer	:= 1;
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 10;
		C_S_AXI_AWUSER_WIDTH	: integer	:= 0;
		C_S_AXI_ARUSER_WIDTH	: integer	:= 0;
		C_S_AXI_WUSER_WIDTH	: integer	:= 0;
		C_S_AXI_RUSER_WIDTH	: integer	:= 0;
		C_S_AXI_BUSER_WIDTH	: integer	:= 0
		);
		port (
		
		       
		mem_addr_o : out std_logic_vector(C_S_AXI_ADDR_WIDTH- ((C_S_AXI_DATA_WIDTH/32)+ 1)-1 downto 0);
        mem_data_o : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        mem_wr_o : out std_logic;
        
		matrix_axi_data_i : in std_logic_vector(WIDTH-1 downto 0);
        log_axi_data_i :    in std_logic_vector(WIDTH_KERNEL-1 downto 0);
        im_axi_data_i :     in std_logic_vector(WIDTH-1 downto 0);
        
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWID	: in std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWLEN	: in std_logic_vector(7 downto 0);
		S_AXI_AWSIZE	: in std_logic_vector(2 downto 0);
		S_AXI_AWBURST	: in std_logic_vector(1 downto 0);
		S_AXI_AWLOCK	: in std_logic;
		S_AXI_AWCACHE	: in std_logic_vector(3 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWQOS	: in std_logic_vector(3 downto 0);
		S_AXI_AWREGION	: in std_logic_vector(3 downto 0);
		S_AXI_AWUSER	: in std_logic_vector(C_S_AXI_AWUSER_WIDTH-1 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WLAST	: in std_logic;
		S_AXI_WUSER	: in std_logic_vector(C_S_AXI_WUSER_WIDTH-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BID	: out std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BUSER	: out std_logic_vector(C_S_AXI_BUSER_WIDTH-1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARID	: in std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARLEN	: in std_logic_vector(7 downto 0);
		S_AXI_ARSIZE	: in std_logic_vector(2 downto 0);
		S_AXI_ARBURST	: in std_logic_vector(1 downto 0);
		S_AXI_ARLOCK	: in std_logic;
		S_AXI_ARCACHE	: in std_logic_vector(3 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARQOS	: in std_logic_vector(3 downto 0);
		S_AXI_ARREGION	: in std_logic_vector(3 downto 0);
		S_AXI_ARUSER	: in std_logic_vector(C_S_AXI_ARUSER_WIDTH-1 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RID	: out std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RLAST	: out std_logic;
		S_AXI_RUSER	: out std_logic_vector(C_S_AXI_RUSER_WIDTH-1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component ip_module_v1_0_S01_AXI;

begin

-- Instantiation of Axi Bus Interface S00_AXI
ip_module_v1_0_S00_AXI_inst : ip_module_v1_0_S00_AXI
	generic map (
	    WIDTH => WIDTH,
	    SIZE => SIZE,
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
	   
	    reg_data_o => reg_data_s,
	    w_wr_o => w_wr_s,
	    h_wr_o => h_wr_s,
	    b1_wr_o => b1_wr_s,
	    l1_wr_o => l1_wr_s,
	    cmd1_wr_o => cmd1_wr_s,
	    cmd2_wr_o => cmd2_wr_s,
	    
	    w_axi_i => w_axi_s,
	    h_axi_i => h_axi_s,
	    b1_axi_i => b1_axi_s,
	    l1_axi_i => l1_axi_s,
	    cmd1_axi_i => cmd1_axi_s,
	    cmd2_axi_i => cmd2_axi_s,
	    status_axi_i => status_axi_s,
	    
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);

-- Instantiation of Axi Bus Interface S01_AXI
ip_module_v1_0_S01_AXI_inst : ip_module_v1_0_S01_AXI
	generic map (
		C_S_AXI_ID_WIDTH	=> C_S01_AXI_ID_WIDTH,
		C_S_AXI_DATA_WIDTH	=> C_S01_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S01_AXI_ADDR_WIDTH,
		C_S_AXI_AWUSER_WIDTH	=> C_S01_AXI_AWUSER_WIDTH,
		C_S_AXI_ARUSER_WIDTH	=> C_S01_AXI_ARUSER_WIDTH,
		C_S_AXI_WUSER_WIDTH	=> C_S01_AXI_WUSER_WIDTH,
		C_S_AXI_RUSER_WIDTH	=> C_S01_AXI_RUSER_WIDTH,
		C_S_AXI_BUSER_WIDTH	=> C_S01_AXI_BUSER_WIDTH
	)
	port map (
	
	    mem_addr_o => mem_addr_s,
	    mem_data_o => mem_data_s,
	    mem_wr_o => mem_wr_s,
	    
	    matrix_axi_data_i => matrix_axi_data_s,
	    log_axi_data_i => log_axi_data_s,
	    im_axi_data_i => im_axi_data_s,
	    
		S_AXI_ACLK	=> s01_axi_aclk,
		S_AXI_ARESETN	=> s01_axi_aresetn,
		S_AXI_AWID	=> s01_axi_awid,
		S_AXI_AWADDR	=> s01_axi_awaddr,
		S_AXI_AWLEN	=> s01_axi_awlen,
		S_AXI_AWSIZE	=> s01_axi_awsize,
		S_AXI_AWBURST	=> s01_axi_awburst,
		S_AXI_AWLOCK	=> s01_axi_awlock,
		S_AXI_AWCACHE	=> s01_axi_awcache,
		S_AXI_AWPROT	=> s01_axi_awprot,
		S_AXI_AWQOS	=> s01_axi_awqos,
		S_AXI_AWREGION	=> s01_axi_awregion,
		S_AXI_AWUSER	=> s01_axi_awuser,
		S_AXI_AWVALID	=> s01_axi_awvalid,
		S_AXI_AWREADY	=> s01_axi_awready,
		S_AXI_WDATA	=> s01_axi_wdata,
		S_AXI_WSTRB	=> s01_axi_wstrb,
		S_AXI_WLAST	=> s01_axi_wlast,
		S_AXI_WUSER	=> s01_axi_wuser,
		S_AXI_WVALID	=> s01_axi_wvalid,
		S_AXI_WREADY	=> s01_axi_wready,
		S_AXI_BID	=> s01_axi_bid,
		S_AXI_BRESP	=> s01_axi_bresp,
		S_AXI_BUSER	=> s01_axi_buser,
		S_AXI_BVALID	=> s01_axi_bvalid,
		S_AXI_BREADY	=> s01_axi_bready,
		S_AXI_ARID	=> s01_axi_arid,
		S_AXI_ARADDR	=> s01_axi_araddr,
		S_AXI_ARLEN	=> s01_axi_arlen,
		S_AXI_ARSIZE	=> s01_axi_arsize,
		S_AXI_ARBURST	=> s01_axi_arburst,
		S_AXI_ARLOCK	=> s01_axi_arlock,
		S_AXI_ARCACHE	=> s01_axi_arcache,
		S_AXI_ARPROT	=> s01_axi_arprot,
		S_AXI_ARQOS	=> s01_axi_arqos,
		S_AXI_ARREGION	=> s01_axi_arregion,
		S_AXI_ARUSER	=> s01_axi_aruser,
		S_AXI_ARVALID	=> s01_axi_arvalid,
		S_AXI_ARREADY	=> s01_axi_arready,
		S_AXI_RID	=> s01_axi_rid,
		S_AXI_RDATA	=> s01_axi_rdata,
		S_AXI_RRESP	=> s01_axi_rresp,
		S_AXI_RLAST	=> s01_axi_rlast,
		S_AXI_RUSER	=> s01_axi_ruser,
		S_AXI_RVALID	=> s01_axi_rvalid,
		S_AXI_RREADY	=> s01_axi_rready
	);

	-- Add user logic here
reset_s <= not s00_axi_aresetn;
 -- Memory subsystem
 memory_subsystem: entity work.mem_subsystem(Behavioral)
 generic map
(
 WIDTH => WIDTH,
 SIZE => SIZE

)
 port map
(
 clk => s00_axi_aclk,
 reset => reset_s,

 -- Interface to the AXI controllers
 reg_data_i => reg_data_s,
 w_wr_i => w_wr_s,
 h_wr_i => h_wr_s,
 b1_wr_i => b1_wr_s,
 l1_wr_i => l1_wr_s,
 cmd1_wr_i => cmd1_wr_s,
 cmd2_wr_i => cmd2_wr_s,
 
 
 w_axi_o => w_axi_s,
 h_axi_o => h_axi_s,
 b1_axi_o => b1_axi_s,
 l1_axi_o => l1_axi_s,
 
 cmd1_axi_o => cmd1_axi_s,
 cmd2_axi_o => cmd2_axi_s,
 status_axi_o => status_axi_s,

 mem_addr_i => mem_addr_s,
 mem_data_i => mem_data_s,
 mem_wr_i => mem_wr_s,

 matrix_axi_data_o => matrix_axi_data_s,
 log_axi_data_o => log_axi_data_s,
 im_axi_data_o => im_axi_data_s,
 
 -- Interface to the matrix multiply module
 w_o => w_s,
 h_o => h_s,
 b1_o => b1_s,
 l1_o => l1_s,
 start1_o => start1_s,
 start2_o => start2_s,
 ready_i => ready_s,

 matrix_addr_i => matrix_addr_s,
 matrix_wr_i => matrix_wr_s,
 matrix_data_o => matrix_data_s,

 log_addr_i => log_addr_s,
 log_wr_i => log_wr_s,
 log_data_o => log_data_s,

 im_addr_i => im_addr_s,
 im_wr_i => im_wr_s,
 im_data_i => im_data_s);
 
 top: entity work.top(struct)
 generic map(
 
    WIDTH_KERNEL => WIDTH_KERNEL,
    SIZE_KERNEL => SIZE_KERNEL,
    WIDTH_PIC => WIDTH,
    SIZE_PIC => SIZE)

 port map(
 
 top_clk => s00_axi_aclk,
 top_rst => reset_s,
 
 top_matrix_addr_o => matrix_addr_s,
 top_matrix_data_i => matrix_data_s,
 top_matrix_wr_o => matrix_wr_s,
 
 top_log_addr_o => log_addr_s,
 top_log_data_i => log_data_s,
 top_log_wr_o => log_wr_s,
 
 top_l1_in => l1_s,
 top_border1_in => b1_s,
 
 top_width_in => w_s,
 top_height_in => h_s,
 
 top_im_addr_o => im_addr_s,
 top_im_data_o => im_data_s,
 top_im_wr_o => im_wr_s,
 top_im_we_o => im_we_s,
 
 top_start => start1_s,
 top_start2 => start2_s,
  
 top_ready => ready_s
);
 
 
 
 
 
 
	-- User logic ends

end arch_imp;
