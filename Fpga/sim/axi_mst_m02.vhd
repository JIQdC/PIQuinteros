library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_mst_m02 is
    generic (
        TEST_TARGET_SLAVE_BASE_ADDR  : std_logic_vector  := x"44A00000"
    );
    port (
        -- Señales MASTER AXI4 LITE 32 bits
        -- AXI clock signal
        M_AXI_ACLK      : in std_logic;
        -- AXI active low reset signal
        M_AXI_ARESETN   : in std_logic;
        -- Master Interface Write Address Channel ports. Write address (issued by master)
        M_AXI_AWADDR    : out std_logic_vector(31 downto 0);
        -- Write channel Protection type.
        -- This signal indicates the privilege and security level of the transaction,
        -- and whether the transaction is a data access or an instruction access.
        M_AXI_AWPROT    : out std_logic_vector(2 downto 0);
        -- Write address valid. 
        -- This signal indicates that the master signaling valid write address and control information.
        M_AXI_AWVALID   : out std_logic;
        -- Write address ready. 
        -- This signal indicates that the slave is ready to accept an address and associated control signals.
        M_AXI_AWREADY   : in std_logic;
        -- Master Interface Write Data Channel ports. Write data (issued by master)
        M_AXI_WDATA : out std_logic_vector(31 downto 0);
        -- Write strobes. 
        -- This signal indicates which byte lanes hold valid data.
        -- There is one write strobe bit for each eight bits of the write data bus.
        M_AXI_WSTRB : out std_logic_vector(3 downto 0);
        -- Write valid. This signal indicates that valid write data and strobes are available.
        M_AXI_WVALID    : out std_logic;
        -- Write ready. This signal indicates that the slave can accept the write data.
        M_AXI_WREADY    : in std_logic;
        -- Master Interface Write Response Channel ports. 
        -- This signal indicates the status of the write transaction.
        M_AXI_BRESP : in std_logic_vector(1 downto 0);
        -- Write response valid. 
        -- This signal indicates that the channel is signaling a valid write response
        M_AXI_BVALID    : in std_logic;
        -- Response ready. This signal indicates that the master can accept a write response.
        M_AXI_BREADY    : out std_logic;
        -- Master Interface Read Address Channel ports. Read address (issued by master)
        M_AXI_ARADDR    : out std_logic_vector(31 downto 0);
        -- Protection type. 
        -- This signal indicates the privilege and security level of the transaction, 
        -- and whether the transaction is a data access or an instruction access.
        M_AXI_ARPROT    : out std_logic_vector(2 downto 0);
        -- Read address valid. 
        -- This signal indicates that the channel is signaling valid read address and control information.
        M_AXI_ARVALID   : out std_logic;
        -- Read address ready. 
        -- This signal indicates that the slave is ready to accept an address and associated control signals.
        M_AXI_ARREADY   : in std_logic;
        -- Master Interface Read Data Channel ports. Read data (issued by slave)
        M_AXI_RDATA : in std_logic_vector(31 downto 0);
        -- Read response. This signal indicates the status of the read transfer.
        M_AXI_RRESP : in std_logic_vector(1 downto 0);
        -- Read valid. This signal indicates that the channel is signaling the required read data.
        M_AXI_RVALID    : in std_logic;
        -- Read ready. This signal indicates that the master can accept the read data and response information.
        M_AXI_RREADY    : out std_logic
    );
end axi_mst_m02;

architecture rtl of axi_mst_m02 is

    -- AXI4LITE signals
    --write address valid
    signal axi_awvalid  : std_logic;
    --write data valid
    signal axi_wvalid   : std_logic;
    --read address valid
    signal axi_arvalid  : std_logic;
    --read data acceptance
    signal axi_rready   : std_logic;
    --write response acceptance
    signal axi_bready   : std_logic;
    --write address
    signal axi_awaddr   : std_logic_vector(31 downto 0);
    --write data
    signal axi_wdata    : std_logic_vector(31 downto 0);
    --read addresss
    signal axi_araddr   : std_logic_vector(31 downto 0);
    
    -- ******************************************************************************************
    -- SEÑALES DE USUARIO
    
    -- Definiciones y señales para test de usuario. Deberian reemplazarse según la funcionalidad que se requiere
    type tipo_acceso is (ACCESS_READ, ACCESS_WRITE); 
    
    type td_axi_access is record
      acct  : tipo_acceso;
      addr  : std_logic_vector(31 downto 0);
      data  : std_logic_vector(31 downto 0);
    end record td_axi_access; 

    type td_access_list is array (natural range <>) of td_axi_access;
    
    -- Accesos de escritura - lectura para pruebas
    constant NUM_ACCESOS : integer := 6;
    
--    constant operaciones : td_access_list(0 to NUM_ACCESOS-1) :=
    constant operaciones : td_access_list := (
      -- --LECTURA DE DATOS DE CONTADOR EN DEBUG
      -- --selecciono clk de la FPGA
      -- (ACCESS_WRITE,  x"00000000", x"00000001"),
      -- (ACCESS_READ,  x"00000000", x"00000001"),
      -- --secuencia de control F para contador
      -- (ACCESS_WRITE,  x"00000004", x"0000000f"),
      -- (ACCESS_READ,  x"00000004", x"0000000f"),
      -- --lectura de varios datos de FIFO
      -- (ACCESS_READ,  x"00000018", x"00000001"),
      -- (ACCESS_READ,  x"00000018", x"00000001"),
      -- (ACCESS_READ,  x"00000018", x"00000001"),
      -- (ACCESS_READ,  x"00000018", x"00000001"),
      -- (ACCESS_READ,  x"00000018", x"00000001"),
      --LECTURA DE DATOS DE CONTADOR EN ADC
      -- --selecciono clk del ADC
      -- (ACCESS_WRITE,  x"00000000", x"00000000"),
      -- (ACCESS_READ,  x"00000000", x"00000000"),
      -- --secuencia de control D para datos de deserializador
      -- (ACCESS_WRITE,  x"00000004", x"0000000d"),
      -- (ACCESS_READ,  x"00000004", x"0000000d"),
      --reset general
      (ACCESS_WRITE, x"00000020", x"00000003"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001"),
      (ACCESS_READ,  x"00000018", x"00000001")
      
      --PRUEBA DE RESET POR AXI
      -- -- reseteo general
      -- (ACCESS_WRITE, x"00000020", x"00000001"),
      -- (ACCESS_READ, x"00000020", x"00000001")
      --PRUEBA DE PIN CONTROL
      -- (ACCESS_WRITE,  x"00000000", x"00000001"),
      -- (ACCESS_WRITE,  x"00000000", x"00000001"),
      -- (ACCESS_WRITE,  x"00000004", x"00000001"),
      -- (ACCESS_WRITE,  x"00000004", x"00000001") 
      -- PRUEBA DE AXI QUAD SPI
      -- (ACCESS_WRITE, x"00020040", x"0000000A"), --reset
      -- (ACCESS_WRITE, x"00020060", x"00000006"), --config
      -- (ACCESS_READ, x"00020060", x"00000002"),  --config
      -- (ACCESS_READ, x"00020064", x"00000000"),  --state reg   
      -- (ACCESS_WRITE, x"00020070", x"00000002"), --ssel
      -- (ACCESS_WRITE, x"00010004", x"00000000"), --read_en OFF
      -- (ACCESS_WRITE, x"00020068", x"000000C0"), --instruction MSByte
      -- (ACCESS_WRITE, x"00020068", x"00000001"), --instruction LSByte
      -- (ACCESS_WRITE, x"00010004", x"00000001"), --read_en ON
      -- (ACCESS_READ, x"00010004", x"00000001"),  --check tristate
      -- (ACCESS_READ, x"00010004", x"00000001"),  --check tristate
      -- (ACCESS_READ, x"00010004", x"00000001"),  --check tristate
      -- (ACCESS_READ, x"00010004", x"00000001"),  --check tristate
      -- (ACCESS_READ, x"00010004", x"00000001"),  --check tristate
      -- (ACCESS_READ, x"00010004", x"00000001"),  --check tristate
      -- (ACCESS_READ, x"00010004", x"00000001"),  --check tristate
      -- --(ACCESS_READ, x"00010004", x"00000001")  --check tristate
      -- --(ACCESS_WRITE, x"00020070", x"00000003"),  --deassert ssel
      -- --(ACCESS_WRITE, x"00020060", x"00000106"), --config
      -- (ACCESS_WRITE, x"00020068", x"0000000d"),
      -- (ACCESS_READ, x"0002006C", x"00000000")   --leo (algo)
            ); -- Fin de las operaciones

    type td_estado is (START, INIT_ACCESO, LECTURA1, LECTURA2, ESCRITURA1, FIN_ACCESO, IDLE);

    signal user_estado  : td_estado ; 
    
    -- Señales de indicacion y para contener datos
    signal user_start_write, user_start_read, user_fin_read, user_fin_write, user_read_mismatch : std_logic;
    signal user_addr, user_wdata, user_rdata, user_rxdata   : std_logic_vector(31 downto 0);


    --Asserts when there is a write response error
    signal write_resp_error : std_logic;
    --Asserts when there is a read response error
    signal read_resp_error  : std_logic;

    --The error register is asserted when any of the write response error, read response error or the data mismatch flags are asserted.
    signal error_reg    : std_logic;


begin
    -- I/O Connections assignments

    --La dirección de usuario se pasa a axi_awaddr que se suma como offset a la dirección base del esclavo
    M_AXI_AWADDR    <= std_logic_vector (unsigned(TEST_TARGET_SLAVE_BASE_ADDR) + unsigned(axi_awaddr));
    --AXI 4 write data
    M_AXI_WDATA     <= axi_wdata;
    M_AXI_AWPROT    <= "000";
    M_AXI_AWVALID   <= axi_awvalid;
    --Write Data(W)
    M_AXI_WVALID    <= axi_wvalid;
    --Set all byte strobes in this example
    M_AXI_WSTRB     <= "1111";
    --Write Response (B)
    M_AXI_BREADY    <= axi_bready;
    --Read Address (AR)
    M_AXI_ARADDR    <= std_logic_vector(unsigned(TEST_TARGET_SLAVE_BASE_ADDR) + unsigned(axi_araddr));
    M_AXI_ARVALID   <= axi_arvalid;
    M_AXI_ARPROT    <= "001";
    --Read and Read Response (R)
    M_AXI_RREADY    <= axi_rready;
    
    ----------------------------------
    --User Logic
    ----------------------------------

    --Address/Data Stimulus

    --Address/data pairs for this example. The read and write values should
    --match.
    --Modify these as desired for different address patterns.
    
    --implement master command interface state machine                                           
    MASTER_TEST_PROC:process(M_AXI_ACLK) 
      variable v_cta_accesos : integer := 0; 
      variable v_acceso : tipo_acceso;
      variable v_addr, v_data : std_logic_vector(31 downto 0);
      
    begin                                                                                             
      if (rising_edge (M_AXI_ACLK)) then                                                              
        if (M_AXI_ARESETN = '0' ) then -- reset condition                                                                
          -- All the signals are set to default values under reset condition  
          v_cta_accesos      := 0; 
          
          user_estado        <= START;                                                            
          user_start_write   <= '0';                                                                  
          user_start_read    <= '0';
                             
          user_start_write   <= '0';                
          user_start_read    <= '0'; 
          user_read_mismatch <= '0';         

        else                                                                                          
          -- state transition                                                                         
          case (user_estado) is                                                                    
                                                                                                      
            when START =>  
              v_cta_accesos    := 0;
                                                    
              user_start_write <= '0';                
              user_start_read  <= '0'; 

              user_estado      <= INIT_ACCESO; 
              
            when INIT_ACCESO =>
              -- Operacion a ejecutar
              v_acceso := operaciones(v_cta_accesos).acct;
              v_addr   := operaciones(v_cta_accesos).addr;
              v_data   := operaciones(v_cta_accesos).data;
              
              user_read_mismatch <= '0';
              
              user_start_write   <= '0';                
              user_start_read    <= '0'; 
                                 
              user_addr <= v_addr;
              
              if (v_acceso = ACCESS_READ) then                                                             
                user_start_read  <= '1';
                user_rxdata      <= v_data; -- Dato esperado
                user_estado      <= LECTURA1;                                                       
              else -- ACCESS_WRITE                                                                                 
                user_start_write <= '1';
                user_wdata       <= v_data; -- Dato a escribir
                user_estado      <= ESCRITURA1;
              end if;  

            when  LECTURA1 =>                                                                         
              user_start_write <= '0';                
              user_start_read  <= '0'; 

              user_estado <= LECTURA1;
              if user_fin_read = '1' then
                user_estado <= LECTURA2;
              end if;

            when  LECTURA2 =>                                                                         
              if user_rxdata /= user_rdata then
                user_read_mismatch <= '1'; 
              else
                user_read_mismatch <= '0';
              end if;
              
              user_estado <= FIN_ACCESO;
                            
            when  ESCRITURA1 =>                                                                         
              user_start_write <= '0';                
              user_start_read  <= '0'; 
              
              user_estado <= ESCRITURA1;
              if user_fin_write = '1' then
                user_estado <= FIN_ACCESO;
              end if;
              
            when FIN_ACCESO =>
              user_start_write <= '0';                
              user_start_read  <= '0'; 

              -- Numero de accesos
              v_cta_accesos := v_cta_accesos + 1;               

              -- Verifico si es ultimo acceso de la lista
              if v_cta_accesos = operaciones'length then -- NUM_ACCESOS
                user_estado <= IDLE;
              else
                user_estado <= INIT_ACCESO;
              end if;
 
            when IDLE =>
              user_start_write <= '0';                
              user_start_read  <= '0';  
              user_estado      <= IDLE;
              
            when others  =>                                                                           
              user_estado  <= IDLE;                                                      
          end case  ;                                                                                 
        end if;                                                                                       
      end if;                                                                                         
    end process;                                                                                      
                                                                                     
    ------------------------------/                                                                     
    --Example design error register                                                                     
    ------------------------------/                                                                     
                                                                                                        
    --En operación de lectura comparar dato leido con el dato esperado 
    -- SE HACE EN LA FSM PPAL DE CONTROL DE OPERACIONES
    -- process(M_AXI_ACLK)                                                                               
    -- begin                                                                                             
      -- if (rising_edge (M_AXI_ACLK)) then                                                              
        -- if (M_AXI_ARESETN = '0') then                                                                
          -- read_mismatch <= '0';                                                                       
        -- else                                                                                          
          -- if ((M_AXI_RVALID = '1' and axi_rready = '1') and  M_AXI_RDATA /= user_rdata) then      
            -- --The read data when available (on axi_rready) is compared with the expected data         
            -- read_mismatch <= '1';                                                                     
          -- end if;                                                                                     
        -- end if;                                                                                       
      -- end if;                                                                                         
    -- end process;                                                                                      
                                                                                                        
    -- Register and hold any data mismatches, or read/write interface errors                            
    process(M_AXI_ACLK)                                                                               
    begin                                                                                             
      if (rising_edge (M_AXI_ACLK)) then                                                              
        if (M_AXI_ARESETN = '0') then                                                                
          error_reg <= '0';                                                                           
        else                                                                                          
          if (write_resp_error = '1' or read_resp_error = '1') then            
            --Capture any error types                                                                 
            error_reg <= '1';                                                                         
          end if;                                                                                     
        end if;                                                                                       
      end if;                                                                                         
    end process; 
      
    -- ************************************************************************************  
    -- PROCESOS DE AXI MASTER   
      
    ----------------------
    --Write Address Channel
    ----------------------

    -- The purpose of the write address channel is to request the address and 
    -- command information for the entire transaction.  It is a single beat
    -- of information.

    -- Note for this example the axi_awvalid/axi_wvalid are asserted at the same
    -- time, and then each is deasserted independent from each other.
    -- This is a lower-performance, but simplier control scheme.

    -- AXI VALID signals must be held active until accepted by the partner.

    -- A data transfer is accepted by the slave when a master has
    -- VALID data and the slave acknoledges it is also READY. While the master
    -- is allowed to generated multiple, back-to-back requests by not 
    -- deasserting VALID, this design will add rest cycle for
    -- simplicity.

    -- Since only one outstanding transaction is issued by the user design,
    -- there will not be a collision between a new request and an accepted
    -- request on the same clock cycle. 

    process(M_AXI_ACLK)                                                          
    begin                                                                             
      if (rising_edge (M_AXI_ACLK)) then                                              
        --Only VALID signals must be deasserted during reset per AXI spec             
        --Consider inverting then registering active-low reset for higher fmax        
        if (M_AXI_ARESETN = '0') then                                                
          axi_awvalid <= '0';             
        else                                                                          
          --Signal a new address/data command is available by user logic              
          if (user_start_write = '1') then                                          
            axi_awvalid <= '1'; 
            axi_awaddr  <= user_addr;
          elsif (M_AXI_AWREADY = '1' and axi_awvalid = '1') then                      
            --Address accepted by interconnect/slave (issue of M_AXI_AWREADY by slave)
            axi_awvalid <= '0';                                                       
          end if;                                                                     
        end if;                                                                       
      end if;                                                                         
    end process;                                                                      

    ----------------------
    --Write Data Channel
    ----------------------

    --The write data channel is for transfering the actual data.
    --The data generation is speific to the example design, and 
    --so only the WVALID/WREADY handshake is shown here

    process(M_AXI_ACLK)                                                 
    begin                                                                         
      if (rising_edge (M_AXI_ACLK)) then                                          
        if (M_AXI_ARESETN = '0' ) then                                            
          axi_wvalid <= '0';                                                      
        else                                                                      
          if (user_start_write = '1') then                                      
            --Signal a new address/data command is available by user logic        
            axi_wvalid <= '1'; 
            axi_wdata  <= user_wdata;            
          elsif (M_AXI_WREADY = '1' and axi_wvalid = '1') then                    
            --Data accepted by interconnect/slave (issue of M_AXI_WREADY by slave)
            axi_wvalid <= '0';                                                    
          end if;                                                                 
        end if;                                                                   
      end if;                                                                     
    end process;                                                                  


    ------------------------------
    --Write Response (B) Channel
    ------------------------------

    --The write response channel provides feedback that the write has committed
    --to memory. BREADY will occur after both the data and the write address
    --has arrived and been accepted by the slave, and can guarantee that no
    --other accesses launched afterwards will be able to be reordered before it.

    --The BRESP bit [1] is used indicate any errors from the interconnect or
    --slave for the entire write burst. This example will capture the error.

    --While not necessary per spec, it is advisable to reset READY signals in
    --case of differing reset latencies between master/slave.

    process(M_AXI_ACLK)                                            
    begin                                                                
      if (rising_edge (M_AXI_ACLK)) then                                 
        if (M_AXI_ARESETN = '0') then                                   
          axi_bready <= '0';
          user_fin_write <= '0';           
        else                                                             
          if (M_AXI_BVALID = '1' and axi_bready = '0') then              
            -- accept/acknowledge bresp with axi_bready by the master    
            -- when M_AXI_BVALID is asserted by slave                    
             axi_bready      <= '1';
             user_fin_write <= '1';            
          elsif (axi_bready = '1') then                                  
            -- deassert after one clock cycle                            
            axi_bready      <= '0';  
            user_fin_write <= '0';
          end if;                                                        
        end if;                                                          
      end if;                                                            
    end process;                                                         
    --Flag write errors                                                    
    write_resp_error <= (axi_bready and M_AXI_BVALID and M_AXI_BRESP(1));

    ------------------------------
    --Read Address Channel
    ------------------------------
                                                                                       
    -- A new axi_arvalid is asserted when there is a valid read address              
    -- available by the master. user_start_read triggers a new read                
    -- transaction                                                                   
    process(M_AXI_ACLK)                                                              
    begin                                                                            
      if (rising_edge (M_AXI_ACLK)) then                                             
        if (M_AXI_ARESETN = '0') then                                               
          axi_arvalid <= '0'; 
        else                                                                         
          if (user_start_read = '1') then                                          
            --Signal a new read address command is available by user logic           
            axi_arvalid <= '1';  
            axi_araddr  <= user_addr;            
          elsif (M_AXI_ARREADY = '1' and axi_arvalid = '1') then                     
          --RAddress accepted by interconnect/slave (issue of M_AXI_ARREADY by slave)
            axi_arvalid <= '0';                                                      
          end if;                                                                    
        end if;                                                                      
      end if;                                                                        
    end process;                                                                     

    ----------------------------------
    --Read Data (and Response) Channel
    ----------------------------------

    --The Read Data channel returns the results of the read request 
    --The master willaxi_wid accept the read data by asserting axi_rready
    --when there is a valid read data available.
    --While not necessary per spec, it is advisable to reset READY signals in
    --case of differing reset latencies between master/slave.

    process(M_AXI_ACLK)                                             
    begin                                                                 
      if (rising_edge (M_AXI_ACLK)) then                                  
        if (M_AXI_ARESETN = '0') then                                    
          axi_rready     <= '0'; 
          user_fin_read  <= '0';
        else                                                              
          if (M_AXI_RVALID = '1' and axi_rready = '0') then               
            -- accept/acknowledge rdata/rresp with axi_rready by the master
            -- when M_AXI_RVALID is asserted by slave                      
            axi_rready    <= '1'; 
            user_rdata    <= M_AXI_RDATA; -- Guarda el dato leido   
            user_fin_read <= '1';              
          elsif (axi_rready = '1') then                                   
            -- deassert after one clock cycle                             
            axi_rready     <= '0'; 
            user_fin_read <= '0';               
          end if;                                                         
        end if;                                                           
      end if;                                                             
    end process;                                                          
                                                                            
    --Flag write errors                                                     
    read_resp_error <= (axi_rready and M_AXI_RVALID and M_AXI_RRESP(1));  
                  

end rtl;
