`ifndef LOG_SIMPLE_SEQ_SV
 `define LOG_SIMPLE_SEQ_SV

class log_simple_seq extends log_base_seq;

   `uvm_object_utils (log_simple_seq)

   function new(string name = "log_simple_seq");
      super.new(name);
   endfunction

    virtual task body();
      log_seq_item log_it;// prvi korak kreiranje transakcije

      log_it = log_seq_item::type_id::create("log_it");// drugi korak-start

    for(int i = 0; i < 100; i++)
    begin
              start_item(log_it);// treci korak priprema// po potrebi moguce prosiriti sa npr. inline ogranicenjima

            assert(log_it.randomize());// cetvrti korak-finish

            finish_item(log_it);
    end
   endtask
    
 /*  virtual task body();
 
    log_seq_item item;
    int num_txn;
    bit type_txn;
    bit type_txn1;
    bit [4 : 0] brust_mode;
    
    num_txn = $urandom_range(5,20);
    repeat(num_txn) begin
    `uvm_create(item)
        item.cycles = $urandom_range(1,5);
        item.addr = $urandom();
        item.data = $urandom();
        type_txn = $urandom();
        item.trans =$urandom();
        //*******AXI FULL*********
        item.addr1 = $urandom() & 32'hffff_fffc;
        item.data1 = $urandom();
        brust_mode = $urandom();
        item.trans1 = $urandom();
        item.length = $urandom();
        
        case (brust_mode[2:1])
            2'b00: item.btype = 0; //fixed
            2'b10: item.btype = 2; //wrap
            default: item.btype = 1; //incr
        endcase
        
        if (brust_mode [2:1] == 2'b10 ) begin
            case (brust_mode[4:3])
            2'b00: item.bsize = 1;
            2'b01: item.bsize = 3;
            2'b10: item.bsize = 7;
            2'b11: item.bsize = 15;
            endcase
        end
        
        else begin
            item.bsize = $urandom();
        end
        
        
        `uvm_send(item);
    end
   endtask : body*/

endclass : log_simple_seq


`endif
