library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.utils_pkg.all;

entity laplacian is
generic(
    WIDTH_KERNEL: integer := 5;
    SIZE_KERNEL: integer := 5;
    
    WIDTH_PIC: integer := 8;
    SIZE_PIC: integer := 10;
    
    SIGNED_UNSIGNED: string := "unsigned"

);
port (
    clk: in std_logic;
    rst: in std_logic;
    --Input picture--
    matrix_addr_o: out std_logic_vector(log2c(SIZE_PIC*SIZE_PIC)-1 downto 0);
    matrix_data_i: in std_logic_vector(WIDTH_PIC-1 downto 0);
    matrix_wr_o:    out std_logic;
    --Log Kernel mask
    log_addr_o: out std_logic_vector(log2c(SIZE_KERNEL*SIZE_KERNEL)-1 downto 0);
    log_data_i: in std_logic_vector(WIDTH_KERNEL-1 downto 0);
    log_wr_o:    out std_logic;
    --Inputs
    l1_in: in std_logic_vector(3 downto 0);
    --l2_in: in std_logic_vector(2 downto 0);
    border1_in: in std_logic_vector(3 downto 0);
    --border2_in: in std_logic_vector(3 downto 0);
    width_in: in std_logic_vector(log2c(SIZE_PIC)-1  downto 0);
    height_in: in std_logic_vector(log2c(SIZE_PIC)-1  downto 0);
    --Newinp picture--
    new_addr_o: out std_logic_vector(log2c(SIZE_PIC*SIZE_PIC)-1 downto 0);
    new_data_o: out std_logic_vector(2*WIDTH_PIC+SIZE_PIC-1 downto 0);
    new_wr_o:    out std_logic;
    new_we_o :  out std_logic;

    max_value: out std_logic_vector(2*WIDTH_PIC+SIZE_PIC-1 downto 0);
    --Command interface--
    start: in std_logic;
    --Status interface--
    ready: out std_logic
);

end laplacian;

architecture two_seg_arch of laplacian is

attribute use_dsp : string;
attribute use_dsp of two_seg_arch : architecture is "yes"; 

type state_type is(idle, l1, l2, l3, l4,lZero, lZero1,lZero2,lZero3, lZero4, lZero5);
signal state_reg, state_next: state_type;
signal i_reg, i_next: unsigned(log2c(SIZE_PIC)-1 downto 0);
signal j_reg, j_next: unsigned(log2c(SIZE_PIC)-1 downto 0);
signal k_reg, k_next: unsigned(log2c(SIZE_PIC)-1 downto 0);
signal m_reg, m_next: unsigned(log2c(SIZE_PIC)-1 downto 0);

signal side_reg, side_next: unsigned(log2c(SIZE_PIC*SIZE_PIC)-1 downto 0);
signal zero_reg, zero_next: unsigned(log2c(SIZE_PIC*SIZE_PIC)-1 downto 0);
signal top_reg, top_next:   unsigned(log2c(SIZE_PIC*SIZE_PIC)-1 downto 0);
signal spix_reg, spix_next, pre: std_logic_vector(2*WIDTH_PIC+SIZE_PIC-1 downto 0) :=  (others => '0');
signal uns, sig: std_logic_vector(2*WIDTH_PIC+SIZE_PIC-1 downto 0) :=  (others => '0');
signal max_reg, max_next: std_logic_vector(2*WIDTH_PIC+SIZE_PIC-1 downto 0);

signal integer_for_multiply: integer;

begin
--State and data registers
process(clk,rst)
begin
    if rst = '1' then
     state_reg <= idle;
     i_reg <= (others => '0');
     j_reg <= (others => '0');
     k_reg <= (others => '0');
     m_reg <= (others => '0');
     spix_reg <= (others => '0');   
     max_reg <= (others => '0');
     zero_reg <= (others => '0');
     top_reg <= (others => '0');
     side_reg <= (others => '0');
    elsif(clk'event and clk = '1')then
      state_reg <= state_next;
      i_reg <= i_next;
      j_reg <= j_next;
      k_reg <= k_next;
      m_reg <= m_next;
      spix_reg <= spix_next;
      max_reg <= max_next;
      top_reg <= top_next;
      zero_reg <= zero_next;
      side_reg <= side_next;
    end if;
end process;

--Combinatorial circuits
process(state_reg, start, side_reg,side_next,top_reg, top_next,log_data_i, matrix_data_i, i_reg,i_next, j_reg,j_next, k_reg, k_next,m_reg,m_next,spix_reg,spix_next,max_reg,max_next, zero_reg, zero_next, width_in, height_in,l1_in,integer_for_multiply)
begin
    --default
    i_next <= i_reg;
    j_next <= j_reg;
    k_next <= k_reg;
    m_next <= m_reg;
    spix_next <= spix_reg;
    max_next <= max_reg;
    zero_next <= zero_reg;
    top_next <= top_reg;
    side_next <= side_reg;
    --log_addr_o <= (others =>'0');
    log_wr_o <= '1';
    
   -- matrix_addr_o <= (others => '0');
    matrix_wr_o <= '1';
    
    --new_addr_o <= (others => '0');
    --new_data_o <= (others => '0');
    new_wr_o <= '0';
    new_we_o <= '0';
    
    ready <= '0';
    
    
    case state_reg is
      when lZero =>

        zero_next <= zero_reg + 1;
        
        new_addr_o <= std_logic_vector(resize(zero_next-1, new_addr_o'length));  
        new_data_o <= (others => '0');
        new_wr_o <= '1';
        new_we_o <= '1'; 

        if zero_next < (2*unsigned(width_in)) then
          state_next <= lZero;
        else
          state_next <= lZero1;
        end if;
        
      when lZero1 =>
        
        zero_next <= zero_reg + 1;

        new_addr_o <= std_logic_vector(resize(zero_next-(2*unsigned(width_in)+1) + (unsigned(height_in) - 2)*unsigned(width_in), new_addr_o'length));
       new_data_o <= (others => '0');
        new_wr_o <= '1';
        new_we_o <= '1'; 

        if (zero_next > (2*unsigned(width_in))-1) and (zero_next <= (4*unsigned(width_in))-1) then
          state_next <= lZero1;
        else
          state_next <= lZero2;
        end if; 

      when lZero2 =>

        side_next <= side_reg + 1;  --1    -2                                      
       
        new_addr_o <= std_logic_vector(resize(2*unsigned(width_in) + (side_next-1)*unsigned(width_in), new_addr_o'length));
        new_data_o <= (others => '0');
        new_wr_o <= '1';
        new_we_o <= '1';

        if side_next < unsigned(height_in)-4 then
          state_next <= lZero2;
        else
          
          state_next <= lZero3;
        end if;
        
      when lZero3 =>
        side_next <= side_reg  + 1;                                       
       
        new_addr_o <= std_logic_vector(resize(2*unsigned(width_in) + (side_next-unsigned(height_in)+3)*unsigned(width_in) + (unsigned(width_in)-2), new_addr_o'length));
        new_data_o <= (others => '0');
        new_wr_o <= '1';
        new_we_o <= '1';

        if side_next < 2*(unsigned(height_in)-4) then
          state_next <= lZero3;
        else
          state_next <= lZero4;
        end if;
        
      when lZero4 =>
        
        top_next <= top_reg + 1;                                      
       
        new_addr_o <= std_logic_vector(resize(2*unsigned(width_in)+1 + (top_next-2)*unsigned(width_in), new_addr_o'length));
        new_data_o <= (others => '0');
        new_wr_o <= '1';
        new_we_o <= '1';

        if top_next < unsigned(height_in)-3 then
          state_next <= lZero4;
        else
          
          state_next <= lZero5;
        end if;
        
      when lZero5 =>

        top_next <= top_reg  + 1;                                       
       
        new_addr_o <= std_logic_vector(resize(2*unsigned(width_in)+1 + (top_next-unsigned(height_in)+2)*unsigned(width_in) + (unsigned(width_in)-2), new_addr_o'length));
        new_data_o <= (others => '0');
        new_wr_o <= '1';
        new_we_o <= '1';

        if top_next <= 2*(unsigned(height_in)-4) then
          state_next <= lZero5;
        else
          state_next <= idle;
        end if;
    
        
      when idle =>
        ready <= '1';
        if start = '1' then
          i_next <= to_unsigned(0, log2c(SIZE_PIC));
          zero_next <= to_unsigned(0, log2c(SIZE_PIC*SIZE_PIC));
          top_next <= to_unsigned(1, log2c(SIZE_PIC*SIZE_PIC));
          side_next <= to_unsigned(0, log2c(SIZE_PIC*SIZE_PIC));
            state_next <= l1;
        else
            state_next <= idle;
        end if;
     
     when l1 =>
            j_next <= to_unsigned(0, log2c(SIZE_PIC));
            state_next <= l2;
     
     when l2 =>
        spix_next <= (others =>'0');
        k_next <= to_unsigned(0, log2c(SIZE_PIC));
        state_next <= l3;
       
     
     when l3 =>
        m_next <= to_unsigned(0, log2c(SIZE_PIC));
        
        
        log_addr_o <= std_logic_vector(resize((unsigned(l1_in))*k_reg + m_next, log_addr_o'length));       
       
        --matrix_addr_o <= std_logic_vector(i_reg*10+ (10*k_reg + j_reg) + (m_next)); --0 ,10
         matrix_addr_o <= std_logic_vector(resize( i_reg*10 + (10*k_reg + j_reg) + (m_next), matrix_addr_o'length));
        
        if (log_data_i /= "10000") then
  
             integer_for_multiply <= to_integer(signed(spix_reg)) + to_integer(unsigned(matrix_data_i))*to_integer(signed(log_data_i));
         
          if integer_for_multiply < 0 then
             --xpre <= std_logic_vector(signed('1' & integer_for_multiply));
             spix_next <= std_logic_vector(to_signed(integer_for_multiply,2*WIDTH_PIC+SIZE_PIC));
          else
             spix_next <= std_logic_vector(to_unsigned(integer_for_multiply,2*WIDTH_PIC+SIZE_PIC));
         end if;
         else
            integer_for_multiply <= to_integer(signed(spix_reg)) + to_integer(unsigned(matrix_data_i))*to_integer(signed('0' & log_data_i));
         
          if integer_for_multiply < 0 then
            spix_next <= std_logic_vector(to_signed(integer_for_multiply,2*WIDTH_PIC+SIZE_PIC));
          else
            spix_next <= std_logic_vector(to_unsigned(integer_for_multiply,2*WIDTH_PIC+SIZE_PIC));
        end if;
        end if;
        
        
        
        state_next <= l4;
     
     when l4 =>
        --log_addr_o <= std_logic_vector(resize((unsigned(l1_in))*k_reg + m_next, log_addr_o'length));
       -- integer_for_multiply <= to_integer(signed(spix_reg)) + to_integer(unsigned(matrix_data_i))*to_integer(signed(log_data_i));
        if (log_data_i /= "10000") then
  
             integer_for_multiply <= to_integer(signed(spix_reg)) + to_integer(unsigned(matrix_data_i))*to_integer(signed(log_data_i));
         
          if integer_for_multiply < 0 then
             --xpre <= std_logic_vector(signed('1' & integer_for_multiply));
             spix_next <= std_logic_vector(to_signed(integer_for_multiply,2*WIDTH_PIC+SIZE_PIC));
          else
             spix_next <= std_logic_vector(to_unsigned(integer_for_multiply,2*WIDTH_PIC+SIZE_PIC));
         end if;
         else
            integer_for_multiply <= to_integer(signed(spix_reg)) + to_integer(unsigned(matrix_data_i))*to_integer(signed('0' & log_data_i));
         
          if integer_for_multiply < 0 then
            spix_next <= std_logic_vector(to_signed(integer_for_multiply,2*WIDTH_PIC+SIZE_PIC));
          else
            spix_next <= std_logic_vector(to_unsigned(integer_for_multiply,2*WIDTH_PIC+SIZE_PIC));
       end if;
        end if;        
      
        m_next <= m_reg + 1;  
        log_addr_o <= std_logic_vector(resize((unsigned(l1_in))*k_reg + m_next-1, log_addr_o'length));
        matrix_addr_o <= std_logic_vector(resize( i_reg*10 + (10*k_reg + j_reg) + (m_next-1), matrix_addr_o'length)); --0,1,2,3,4,
        
         if (m_next = unsigned(l1_in)) then
            k_next <= k_reg + 1;

            if(k_next = unsigned(l1_in))then
               --First addres is 23
              new_addr_o <= std_logic_vector(resize(2*unsigned(width_in)+2, new_addr_o'length)+j_reg + resize(unsigned(height_in)*(i_reg), new_addr_o'length));
              new_data_o <= (spix_next);
              new_wr_o <= '1';
              new_we_o <= '1'; 
                
                j_next <= j_reg + 1;
                
                if(signed(spix_next) > signed(max_reg))then
                  max_next <= spix_next;
                  max_value <= std_logic_vector(max_next);
                end if;
         
                 if(j_next = unsigned(width_in)-4) then
                     i_next <= i_reg + 1;                 
                  
                     if(i_next = unsigned(height_in)-4)then
                            state_next <= lZero;
                     else 
                      state_next <= l1;  
                      end if;
                  else
                     state_next <= l2;
                    end if;
            else
                state_next <= l3;
            end if;    
        
        else
            state_next <= l4;
            
        end if;
  
                    
    end case; 
   
end process;



end two_seg_arch;
