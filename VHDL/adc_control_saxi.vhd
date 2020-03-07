-- The entire notice above must be reproduced on all authorized copies.

-- File         : spi_master_rtl.vhd
-- Library      : et_serial_comm_lib
-- Company      : EmTech
-- Author       : Gast�n Rodriguez
-- Address      : <grodriguez@emtech.com.ar>
-- Created on   : 17:09:12-19/01/2012
-- Version      : 0.20
-- Description  : SPI master control

-- Modification History:
-- Date        By    Version    Change Description
-------------------------------------------------------------------------------
-- 19/01/2012  GER      0.10    Original
-- 18/10/2013  GER      0.20    Added slave sel configuration input and NSSEL 
--                              output port to control up to 16 slaves
-- 03/10/2014  MAP		0.30	Modificacion para CPHA=1
-- 16/11/2019  JIQdC	1.00	Modificación para aplicación en CIAA-ACC (pin control)
-- 19/12/2019  JIQdC	2.00	Modificación para aplicación en módulo de control de ADC con interfaz AXI
-- 13/02/2020  JIQdC	2.10	Modificación de mapa de memoria
-- 07/03/2020  JIQdC	2.20	Generación de reset para FIFO y debug
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_control_saxi is
	generic (
		-- Width of S_AXI data bus
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		-- Width of S_AXI address bus
		C_S_AXI_ADDR_WIDTH	: integer	:= 6;

		-- User constants
		-- Core ID and version
        USER_CORE_ID_VER    : std_logic_vector(31 downto 0) := X"00020003";
		-- ADC bit resolution
		N_ADC				: integer	:= 14;
		-- Reset width (in S_AXI_ACLK pulses, up to 7)
		RESET_WIDTH			: integer	:= 4;
		-- Reset active for outputs
		RST_ACTIVE_DEB		: std_logic := '1';
		RST_ACTIVE_FIFO		: std_logic	:= '1'
	);
	port (
		-- Global Clock Signal
		S_AXI_ACLK		: in std_logic;
		-- Global Reset Signal. This Signal is Active LOW
		S_AXI_ARESETN	: in std_logic;
		-- Write address (issued by master, acceped by Slave)
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Write channel Protection type. This signal indicates the
    		-- privilege and security level of the transaction, and whether
    		-- the transaction is a data access or an instruction access.
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		-- Write address valid. This signal indicates that the master signaling
    		-- valid write address and control information.
		S_AXI_AWVALID	: in std_logic;
		-- Write address ready. This signal indicates that the slave is ready
    		-- to accept an address and associated control signals.
		S_AXI_AWREADY	: out std_logic;
		-- Write data (issued by master, acceped by Slave) 
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Write strobes. This signal indicates which byte lanes hold
    		-- valid data. There is one write strobe bit for each eight
    		-- bits of the write data bus.    
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		-- Write valid. This signal indicates that valid write
    		-- data and strobes are available.
		S_AXI_WVALID	: in std_logic;
		-- Write ready. This signal indicates that the slave
    		-- can accept the write data.
		S_AXI_WREADY	: out std_logic;
		-- Write response. This signal indicates the status
    		-- of the write transaction.
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		-- Write response valid. This signal indicates that the channel
    		-- is signaling a valid write response.
		S_AXI_BVALID	: out std_logic;
		-- Response ready. This signal indicates that the master
    		-- can accept a write response.
		S_AXI_BREADY	: in std_logic;
		-- Read address (issued by master, acceped by Slave)
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Protection type. This signal indicates the privilege
    		-- and security level of the transaction, and whether the
    		-- transaction is a data access or an instruction access.
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		-- Read address valid. This signal indicates that the channel
    		-- is signaling valid read address and control information.
		S_AXI_ARVALID	: in std_logic;
		-- Read address ready. This signal indicates that the slave is
    		-- ready to accept an address and associated control signals.
		S_AXI_ARREADY	: out std_logic;
		-- Read data (issued by slave)
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Read response. This signal indicates the status of the
    		-- read transfer.
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		-- Read valid. This signal indicates that the channel is
    		-- signaling the required read data.
		S_AXI_RVALID	: out std_logic;
		-- Read ready. This signal indicates that the master can
    		-- accept the read data and response information.
		S_AXI_RREADY	: in std_logic;
        
		-- FIFO signals
		fifo_dout_i: in std_logic_vector((N_ADC-1) downto 0);
		fifo_empty_i: in std_logic;
		fifo_full_i: in std_logic;
		fifo_ov_i: in std_logic;
		fifo_rd_rst_busy_i: in std_logic;
		fifo_wr_rst_busy_i: in std_logic;
		fifo_rd_en_o: out std_logic;

		-- Control signals
		deb_control_o: out std_logic_vector(3 downto 0);
		deb_usr_w1_o, deb_usr_w2_o: out std_logic_vector((N_ADC-1) downto 0);
		deb_select_clk_o:out std_logic;

		-- Reset signals
		rst_fifo_o: out std_logic;
		rst_debug_o: out std_logic
	);
end adc_control_saxi;

architecture rtl of adc_control_saxi is
	-- Register inputs
	signal 	datain1_r, datain2_r: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	-- Register outputs
	signal dataout0_r, dataout1_r, dataout2_r, dataout3_r   : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	-- General purpose R/W register
	signal datarw_r                              			: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	-- Reset register output
	signal rst_select                            			: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);

	-- AXI4LITE signals
	signal axi_awaddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_awready	: std_logic;
	signal axi_wready	: std_logic;
	signal axi_bresp	: std_logic_vector(1 downto 0);
	signal axi_bvalid	: std_logic;
	signal axi_araddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_arready	: std_logic;
	signal axi_rdata	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal axi_rresp	: std_logic_vector(1 downto 0);
	signal axi_rvalid	: std_logic;

	-- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	-- ADDR_LSB is used for addressing 32/64 bit registers/memories
	-- ADDR_LSB = 2 for 32 bits (n downto 2)
	-- ADDR_LSB = 3 for 64 bits (n downto 3)
	constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
	constant OPT_MEM_ADDR_BITS : integer := 3;
	constant IO_RESET_VALUE : std_logic_vector(31 downto 0) := X"02FAF07F";
	------------------------------------------------
	---- Signals for user logic register space example
	--------------------------------------------------
	---- Number of Slave Registers 4
	signal slv_reg_rden	: std_logic;
	signal slv_reg_wren	: std_logic;
	signal reg_data_out	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal byte_index	: integer;
	signal aw_en	    : std_logic;

	-- user logic
	
	--aux signals for FIFO data formatting
	signal user_inputs1_i, user_inputs2_i: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0) := (others => '0');
	signal zeros_readdata: std_logic_vector (C_S_AXI_DATA_WIDTH-14-1 downto 0) := (others => '0');
	signal zeros_flags: std_logic_vector (C_S_AXI_DATA_WIDTH-5-1 downto 0) := (others => '0');

	--signals for reset generation
	signal rst_cont_reg: unsigned(2 downto 0) := (others => '0');
	signal rst_rst: std_logic := '0';
	signal rst_en: std_logic := '1';

begin
	-- I/O Connections assignments
	S_AXI_AWREADY	<= axi_awready;
	S_AXI_WREADY	<= axi_wready;
	S_AXI_BRESP		<= axi_bresp;
	S_AXI_BVALID	<= axi_bvalid;
	S_AXI_ARREADY	<= axi_arready;
	S_AXI_RDATA		<= axi_rdata;
	S_AXI_RRESP		<= axi_rresp;
	S_AXI_RVALID	<= axi_rvalid;

	-- Implement axi_awready generation
	-- axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	-- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	-- de-asserted when reset is low.

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_awready <= '0';
	      aw_en <= '1';
	    else
	      if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
	        -- slave is ready to accept write address when
	        -- there is a valid write address and write data
	        -- on the write address and data bus. This design 
	        -- expects no outstanding transactions. 
	           axi_awready <= '1';
	           aw_en <= '0';
	        elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then
	           aw_en <= '1';
	           axi_awready <= '0';
	      else
	        axi_awready <= '0';
	      end if;
	    end if;
	  end if;
	end process;

	-- Implement axi_awaddr latching
	-- This process is used to latch the address when both 
	-- S_AXI_AWVALID and S_AXI_WVALID are valid. 

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_awaddr <= (others => '0');
	    else
	      if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
	        -- Write Address latching
	        axi_awaddr <= S_AXI_AWADDR;
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement axi_wready generation
	-- axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	-- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	-- de-asserted when reset is low. 

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_wready <= '0';
	    else
	      if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1' and aw_en = '1') then
	          -- slave is ready to accept write data when 
	          -- there is a valid write address and write data
	          -- on the write address and data bus. This design 
	          -- expects no outstanding transactions.           
	          axi_wready <= '1';
	      else
	        axi_wready <= '0';
	      end if;
	    end if;
	  end if;
	end process; 

	-- Implement memory mapped register select and write logic generation
	-- The write data is accepted and written to memory mapped registers when
	-- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	-- select byte enables of slave registers while writing.
	-- These registers are cleared when reset (active low) is applied.
	-- Slave register write enable is asserted when valid address and data are available
	-- and the slave is ready to accept the write address and write data.
	slv_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID ;

	process (S_AXI_ACLK)
	variable loc_addr_w : std_logic_vector(OPT_MEM_ADDR_BITS downto 0); 
	begin
	  if rising_edge(S_AXI_ACLK) then 

		-- rst_rst default value
			rst_rst <= '0';

	    if S_AXI_ARESETN = '0' then
	      datarw_r 	    <= IO_RESET_VALUE;		--value on-reset for R/W register
	      dataout0_r    <= (others => '0');
		  dataout1_r    <= (others => '0');
		  dataout2_r    <= (others => '0');
		  dataout3_r    <= (others => '0');
		  --trigger general reset for FIFO and debug
		  rst_select	<= x"00000003";
		  rst_rst		<= '1';
	    else
	      loc_addr_w := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
	      if (slv_reg_wren = '1') then
	        case loc_addr_w is
	          when b"0000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave register 0
					dataout0_r(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"0001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave register 1
					dataout1_r(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"0010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave register 2
	                dataout2_r(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"0011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave register 3
	                dataout3_r(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
				end loop;
			when b"0101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave register 5
	                datarw_r(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
				end loop;
			when b"1000" =>
				for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
					if ( S_AXI_WSTRB(byte_index) = '1' ) then
					-- Respective byte enables are asserted as per write strobes                   
					-- reset register
					rst_select(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
					end if;
				end loop;
				--check if read data is not zero
				if(not(rst_select(1 downto 0) = "00")) then
					rst_rst <= '1';
				end if;
			when others =>
				null; -- Maintain actual values
			  end case;
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement write response logic generation
	-- The write response and response valid signals are asserted by the slave 
	-- when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	-- This marks the acceptance of address and indicates the status of 
	-- write transaction.
	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_bvalid  <= '0';
	      axi_bresp   <= "00"; --need to work more on the responses
	    else
	      if (axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0'  ) then
	        axi_bvalid <= '1';
	        axi_bresp  <= "00"; 
	      elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then   --check if bready is asserted while bvalid is high)
	        axi_bvalid <= '0';                                 -- (there is a possibility that bready is always asserted high)
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement axi_arready generation
	-- axi_arready is asserted for one S_AXI_ACLK clock cycle when
	-- S_AXI_ARVALID is asserted. axi_awready is 
	-- de-asserted when reset (active low) is asserted. 
	-- The read address is also latched when S_AXI_ARVALID is 
	-- asserted. axi_araddr is reset to zero on reset assertion.
	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_arready <= '0';
	      axi_araddr  <= (others => '1');
	    else
	      if (axi_arready = '0' and S_AXI_ARVALID = '1') then
	        -- indicates that the slave has acceped the valid read address
	        axi_arready <= '1';
	        -- Read Address latching 
	        axi_araddr  <= S_AXI_ARADDR;           
	      else
	        axi_arready <= '0';
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement axi_arvalid generation	
	-- axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	-- S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	-- data are available on the axi_rdata bus at this instance. The 
	-- assertion of axi_rvalid marks the validity of read data on the 
	-- bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	-- is deasserted on reset (active low). axi_rresp and axi_rdata are 
	-- cleared to zero on reset (active low).  
	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then
	    if S_AXI_ARESETN = '0' then
	      axi_rvalid <= '0';
	      axi_rresp  <= "00";
	    else
	      if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
	        -- Valid read data is available at the read data bus
	        axi_rvalid <= '1';
	        axi_rresp  <= "00"; -- 'OKAY' response
	      elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
	        -- Read data is accepted by the master
	        axi_rvalid <= '0';
	      end if;            
	    end if;
	  end if;
	end process;

	-- Implement memory mapped register select and read logic generation
	-- Slave register read enable is asserted when valid address is available
	-- and the slave is ready to accept the read address.
	slv_reg_rden <= axi_arready and S_AXI_ARVALID and (not axi_rvalid) ;

	-- Output register or memory read data
	process( S_AXI_ACLK, axi_araddr )
	variable loc_addr_r :std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
	begin
		-- Address decoding for reading registers
		loc_addr_r := axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
		if (rising_edge (S_AXI_ACLK)) then

			-- FIFO read_en default value
			fifo_rd_en_o <= '0';
			if ( S_AXI_ARESETN = '0' ) then
			axi_rdata  <= (others => '0');
			else
			if (slv_reg_rden = '1') then

				-- When there is a valid read address (S_AXI_ARVALID) with 
				-- acceptance of read address by the slave (axi_arready),
				-- output the read data matching the read address.

				case loc_addr_r is
					--readback of control outputs
					when b"0000" =>
						axi_rdata <= dataout0_r;
					when b"0001" =>
						axi_rdata <= dataout1_r;
					when b"0010" =>
						axi_rdata <= dataout2_r;
					when b"0011" =>
						axi_rdata <= dataout3_r;
					--core ID and version
					when b"0100" =>
						axi_rdata <= USER_CORE_ID_VER;
					--General purpose R/W register
					when b"0101" =>
						axi_rdata <= datarw_r;  
					--FIFO data input
					when b"0110" =>
						--assert FIFO is not empty
						if (fifo_empty_i = '0') then
							--read data and output read_en for data updating	
							axi_rdata <= datain1_r;
							fifo_rd_en_o <= '1';
						end if;
						--if FIFO is empty, nothing can be read
					-- FIFO flags	
					when b"0111" =>
						axi_rdata <= datain2_r; 			
					when others =>
						axi_rdata  <= (others => '0');
				  end case;
			end if;   
			end if;
		end if;
	end process;

	-- User logic

	-- FIFO data formatting to fit (C_S_AXI_DATA_WIDTH-1 downto 0) length
	-- FIFO read data
	user_inputs1_i <= zeros_readdata & fifo_dout_i;
	-- FIFO flags
	user_inputs2_i <= zeros_flags & fifo_empty_i & fifo_full_i & fifo_ov_i & fifo_rd_rst_busy_i & fifo_wr_rst_busy_i;

	-- Register inputs and outputs
	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then 
			--FIFO input
			datain1_r	    <= user_inputs1_i;
			datain2_r		<= user_inputs2_i;
			--Control outputs
			deb_select_clk_o	<= dataout0_r(0);
			deb_control_o		<= dataout1_r(3 downto 0);
            deb_usr_w1_o 		<= dataout2_r((N_ADC-1) downto 0);
            deb_usr_w2_o 		<= dataout3_r((N_ADC-1) downto 0);
		end if;
	end process;

	-- Reset generation
	process (S_AXI_ACLK, rst_rst)
	begin
		if(rst_rst = '1') then
			rst_cont_reg <= (others => '0');
			rst_en <= '1';
		elsif rising_edge(S_AXI_ACLK) then 
			rst_cont_reg <= rst_cont_reg + 1;
		end if;

		if(rst_cont_reg >= to_unsigned(RESET_WIDTH-1, 3)) then
			rst_en <= '0';
		end if;
	end process;

	-- Reset output
	rst_debug_o <= 	RST_ACTIVE_DEB when ((rst_select(1 downto 0)="01" or rst_select(1 downto 0)="11") and rst_en = '1') else
					not(RST_ACTIVE_DEB);

	rst_fifo_o <=		RST_ACTIVE_FIFO when ((rst_select(1 downto 0)="10" or rst_select(1 downto 0)="11") and rst_en = '1') else
					not(RST_ACTIVE_FIFO); 	
    
end rtl;
