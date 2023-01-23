library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.fixed_pkg.all;
use IEEE.numeric_std.all;
--use IEEE.std_logic_arith.all;
use work.utils_pkg.all;

entity zero_crossing_trsh is
 generic(
    SIZE: integer := 10;
    WIDTH: integer := 8;
    WIDTH_PIC: integer := 8;
    --BORDER2_IN: integer :=2;
    SIZE_PIC: integer := 10
  );

port(
    clk : in std_logic;
    reset: in std_logic;
    start: in std_logic;
    max_value: in std_logic_vector(2*WIDTH_PIC+SIZE_PIC-1 downto 0);
    
    height_in: in std_logic_vector(log2c(SIZE)-1  downto 0);
    width_in: in std_logic_vector(log2c(SIZE)-1  downto 0);

    --NEW INPUT MEMORY INTERFACE
    c_addr_o : out std_logic_vector(log2c(SIZE*SIZE)-1 downto 0);
    c_data_i : in std_logic_vector(2*WIDTH_PIC+SIZE_PIC-1 downto 0);
    c_en_o: out std_logic;
    c_wr_o: out std_logic;
    
    --RESULT IM MEMORY INTERFACE
    im_addr_o : out std_logic_vector(log2c(SIZE*SIZE)-1 downto 0);
    im_data_o : out std_logic_vector(WIDTH-1 downto 0);
    im_en_o: out std_logic;
    im_wr_o: out std_logic;

    ready: out std_logic

);
end zero_crossing_trsh;

architecture Behavioral of zero_crossing_trsh is

attribute use_dsp : string;
attribute use_dsp of Behavioral: architecture is "yes"; 

type state_type is(idle,zerro_crossing, l5, l6, reg1, reg2, reg3, reg4,reg5, reg6, reg7, reg8, reg9, up_up);

signal state_reg, state_next: state_type;
signal i_next,i_reg: unsigned((SIZE)-1 downto 0);
signal j_next,j_reg: unsigned((SIZE)-1 downto 0);

signal zeros                                :std_logic_vector(2*WIDTH_PIC + SIZE_PIC downto 0) := (others => '0');
signal zero                                 :std_logic_vector(2*WIDTH_PIC + SIZE_PIC-1 downto 0) := (others => '0');
signal value                                :std_logic_vector(2*WIDTH_PIC+SIZE_PIC downto 0);
signal up_one, down_one                     :std_logic_vector(2*WIDTH_PIC+SIZE_PIC downto 0);
signal plus_one, minus_one                  :std_logic_vector(2*WIDTH_PIC+SIZE_PIC downto 0);
signal corner_down_left, corner_up_right    :std_logic_vector(2*WIDTH_PIC+SIZE_PIC downto 0);
signal corner_down_right, corner_up_left    :std_logic_vector(2*WIDTH_PIC+SIZE_PIC downto 0);
--Two integer for finding tresholding value
signal four1  :  integer := 4;
signal three1 : integer  := 3;
--signal zero : integer    := 0;


begin
process(clk,reset)
begin
    if reset = '1' then
     state_reg <= idle;
     i_reg <= (others => '0');
     j_reg <= (others => '0');
     
    elsif(clk'event and clk = '1')then
      state_reg <= state_next;
      i_reg <= i_next;
      j_reg <= j_next;
       
    end if;
end process;
    
--Combination logic
process(start,zeros,four1,value,three1,max_value,down_one,up_one,corner_down_right,corner_down_left,corner_up_right,corner_up_left,plus_one, minus_one, i_reg, i_next, j_reg, j_next, state_next, state_reg, c_data_i,height_in,width_in)

begin
--default
    
    i_next <= i_reg;
   
    j_next <= j_reg;
    c_wr_o <= '0';
    
    im_wr_o <= '0';
    im_en_o <= '1';
    
    ready <= '0';
    
    case state_reg is
    
      when idle =>
        ready <= '1';
        if start = '1' then
            i_next <= to_unsigned(0, (SIZE));
            state_next <= l5;
        else
            state_next <= idle;
        end if;
      when l5 =>
    
        j_next <= to_unsigned(0, (SIZE));
        state_next <= l6;
    
      when reg1=>
        if c_data_i(c_data_i'left) = '1'then
            value <= std_logic_vector(signed('1'&c_data_i));
        else
            value <= std_logic_vector(signed('0'&c_data_i));
        end if;
        c_wr_o <= '1';
        c_addr_o <= std_logic_vector(resize(unsigned(width_in) + (j_reg+1) + (unsigned(width_in)*(i_reg)), c_addr_o'length)); --plus_one
        state_next <= reg2;
        
      when reg2 =>
      if c_data_i(c_data_i'left) = '1'then
            plus_one <= std_logic_vector(signed('1'&c_data_i));
        else
            plus_one <= std_logic_vector(signed('0'&c_data_i));
        end if;
      
        c_wr_o <= '1';
        c_addr_o <= std_logic_vector(resize(unsigned(width_in) + j_reg-1  + (unsigned(width_in)*(i_reg)) ,c_addr_o'length)); --minus_one
        state_next <= reg3;
        
      when reg3 =>
       
       if c_data_i(c_data_i'left) = '1'then
            minus_one <= std_logic_vector(signed('1'&c_data_i));
        else
            minus_one <= std_logic_vector(signed('0'&c_data_i));
        end if;
        
        c_wr_o <= '1';
        c_addr_o <=std_logic_vector(resize(2*unsigned(width_in) + j_reg  + unsigned(width_in)*i_reg,c_addr_o'length)); --down_one
        state_next <= reg4;
      when reg4 =>
        
       if c_data_i(c_data_i'left) = '1'then
            down_one <= std_logic_vector(signed('1'&c_data_i));
        else
            down_one <= std_logic_vector(signed('0'&c_data_i));
        end if;
        
        c_wr_o <= '1';
        c_addr_o <=std_logic_vector(resize(unsigned(width_in)*i_reg + j_reg ,c_addr_o'length)); --up_one
        state_next <= reg5;
      when reg5 =>
        if c_data_i(c_data_i'left) = '1'then
            up_one <= std_logic_vector(signed('1'&c_data_i));
        else
            up_one <= std_logic_vector(signed('0'&c_data_i));
        end if;
        
        c_wr_o <= '1';
        c_addr_o <= std_logic_vector(resize(2*unsigned(width_in) + (j_reg+1) + unsigned(width_in)*i_reg,c_addr_o'length)); --corner_down_right
        
        state_next <= reg6;
      when reg6 =>
       if c_data_i(c_data_i'left) = '1'then
            corner_down_right <= std_logic_vector(signed('1'&c_data_i));
        else
            corner_down_right <= std_logic_vector(signed('0'&c_data_i));
        end if;
        
        c_wr_o <= '1';
        c_addr_o <= std_logic_vector(resize(j_reg - 1 + unsigned(width_in)*i_reg, c_addr_o'length)); --corner_up_left
        
        state_next <= reg7;
      when reg7 =>
        if c_data_i(c_data_i'left) = '1'then
            corner_up_left <= std_logic_vector(signed('1'&c_data_i));
        else
            corner_up_left <= std_logic_vector(signed('0'&c_data_i));
        end if;
        c_wr_o <= '1';
        c_addr_o <= std_logic_vector(resize(j_reg +1  + unsigned(width_in)*i_reg,c_addr_o'length)); --corner_up_right     
        state_next <= reg8;
      when reg8 =>
      if c_data_i(c_data_i'left) = '1'then
            corner_up_right <= std_logic_vector(signed('1'&c_data_i));
        else
            corner_up_right <= std_logic_vector(signed('0'&c_data_i));
        end if;
       
        c_wr_o <= '1';
        c_addr_o <= std_logic_vector(resize(2*unsigned(width_in) + j_reg -1 + unsigned(width_in)*i_reg,c_addr_o'length)); --corner_down_left
        state_next <= reg9;
        
      when reg9=>
      if c_data_i(c_data_i'left) = '1'then
            corner_down_left <= std_logic_vector(signed('1'&c_data_i));
        else
            corner_down_left <= std_logic_vector(signed('0'&c_data_i));
        end if;
       
       
        state_next <= zerro_crossing;
        
      when zerro_crossing =>
         if (signed(plus_one) >= signed(zeros) and signed(minus_one) < signed(zeros)) or (signed(plus_one) < signed(zeros) and signed(minus_one) >= signed(zeros))then
            if to_signed(four1,value'length)*signed(value)  >= to_signed(three1,max_value'length)*signed(max_value)then
              im_addr_o <= std_logic_vector(resize(unsigned(width_in) + (j_next)  + unsigned(width_in)*(i_reg), im_addr_o'length));
              im_data_o <= (others => '1');
              im_en_o <= '1';
              im_wr_o <= '1';
              state_next <= up_up;
            else
              state_next <= up_up;
            end if;
          elsif (signed(down_one) >= signed(zeros) and signed(up_one) < signed(zeros)) or (signed(down_one) < signed(zeros) and signed(up_one) >= signed(zeros)) then
            
            if to_signed(four1,value'length)*signed(value)  >= to_signed(three1,max_value'length)*signed(max_value) then
              im_addr_o <= std_logic_vector(resize(unsigned(width_in) + (j_next)  + unsigned(width_in)*(i_reg), im_addr_o'length));
              im_data_o <= (others => '1');
              im_en_o <= '1';
              im_wr_o <= '1';
              state_next <= up_up;
            else
              state_next <= up_up;
            end if;
          elsif (signed(corner_down_right) >= signed(zeros) and signed(corner_up_left)  < signed(zeros)) or (signed(corner_down_right) < signed(zeros) and signed(corner_up_left)  >= signed(zeros))then
            
            if to_signed(four1,value'length)*signed(value)  >= to_signed(three1,max_value'length)*signed(max_value) then
              im_addr_o <= std_logic_vector(resize(unsigned(width_in) + (j_next)  + unsigned(width_in)*(i_reg), im_addr_o'length));
              im_data_o <= (others => '1');
              im_en_o <= '1';
              im_wr_o <= '1';
              state_next <= up_up;
            else
                state_next <= up_up;
            end if;
          elsif (signed(corner_up_right) >= signed(zeros) and signed(corner_down_left) < signed(zeros)) or (signed(corner_up_right) < signed(zeros) and signed(corner_down_left) >= signed(zeros))then
            
            if to_signed(four1,value'length)*signed(value)  >= to_signed(three1,max_value'length)*signed(max_value) then
              im_addr_o <= std_logic_vector(resize(unsigned(width_in) + (j_next)  + unsigned(width_in)*(i_reg), im_addr_o'length));
              im_data_o <= (others => '1');
              im_en_o <= '1';
              im_wr_o <= '1';
              state_next <= up_up;
            else
              state_next <= up_up;
            end if;
          else
            state_next <= up_up;
          end if;
           

      when l6 =>
       
        c_addr_o <= std_logic_vector(resize(unsigned(width_in) + (j_next)  + unsigned(width_in)*(i_reg), c_addr_o'length)); --1
        c_wr_o <= '1';
      
        case (c_data_i) is
         when "00000000000000000000000000" =>
           state_next <= up_up;
         
         when others =>
         state_next <= reg1;
         
         end case;

       when up_up =>
            j_next <= j_reg + 1 ;
             if(j_next = unsigned(width_in) -1)then
               i_next <= i_reg + 1;
            
               if i_next = unsigned(height_in)-1 then
                 state_next <= idle;
               else
                 state_next <= l5;
               end if;
            else
                state_next <= l6;  
            end if;
               
       when others =>
       
        up_one <= up_one;
        down_one <= down_one;     
           
    end case;    
end process;
end architecture;

 
        