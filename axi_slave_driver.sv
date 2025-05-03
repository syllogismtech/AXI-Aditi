class axi_read_driver extends uvm_driver #(axi_read_xtn);
  virtual axi_if vif;
  int case_sel;       // case 1, 2, or 3 based on required behavior
  bit rvalid_delay;      // Used only for case 3

  `uvm_component_utils(axi_read_driver) 

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif)) // fetch virtual interface from database 
      `uvm_fatal("NOVIF", "Virtual interface not set")

      // for delay and case_sel different values and behaviours
    if (!uvm_config_db#(int)::get(this, "", "case_sel", case_sel))
      case_sel = 1; // default to case 1

    if (!uvm_config_db#(bit)::get(this, "", "rvalid_delay", rvalid_delay))
      rvalid_delay = 0;
  endfunction

  task run_phase(uvm_phase phase);
    axi_read_xtn xtn; //gets read request from sequencer
    forever begin
      seq_item_port.get_next_item(xtn); // to get next transaction from sequencer
      
      @(posedge vif.clk iff vif.arvalid); // arvalid = high, wait for posedge of clock
      vif.arready <= 1; // slave is ready to accept address info
      xtn.araddr = vif.araddr; // captures id and address info. in transaction object
      xtn.arid = vif.arid;
      #1; // delay of 1 clock cycle
      vif.arready <= 0; // ready is low after acknowledgemnt of request

      foreach (int i in [0:xtn.arlen]) begin // 0 to burst length upto which loop should iterate
        @(posedge vif.clk);

     case (case_select)
        // CASE 1: Drive rvalid after 3 cycles only when rready is high
          1: begin
            wait (vif.rready);                // Wait for master to be ready  
            repeat (3) @(posedge vif.clk);    // wait for 3 cycles when ready is high to make transaction and send below data
            vif.rdata  <= $random;
            vif.rid    <= xtn.arid;
            vif.rresp  <= 0;
            vif.rlast  <= (i == xtn.arlen);
            vif.rvalid <= 1;
            wait (vif.rready);                // Wait again to complete handshake
            @(posedge vif.clk);
            vif.rvalid <= 0;
          end
        
          // CASE 2: Drive rvalid immediately, but wait for rready
          2: begin
            vif.rvalid <= 1; //rvalid is high so we will drive the data immediately
            vif.rdata  <= $random;
            vif.rid    <= xtn.arid;
            vif.rresp  <= 0;
            vif.rlast  <= (i == xtn.arlen);
            wait (vif.rready);                // Wait until rready is high
            @(posedge vif.clk);
            vif.rvalid <= 0;
          end
        
          // CASE 3:  delay rvalid based on rvalid_delay variable
          3: begin
            if (rvalid_delay == 0) begin // this shows that there is nodelay so, drive immediately
              vif.rdata  <= $random;
              vif.rid    <= xtn.arid;
              vif.rresp  <= 0;
              vif.rlast  <= (i == xtn.arlen);
              vif.rvalid <= 1;
              wait (vif.rready); // wait for rvalid to deassert
              @(posedge vif.clk);
              vif.rvalid <= 0; // rvalid is also low 
            end else begin // when (rvalid_delay == 1)
              // Delay — wait one extra cycle after rready
              wait (vif.rready); // wait until rready is highand drive at posedge
              @(posedge vif.clk);
              vif.rvalid <= 1;
              vif.rdata  <= $random;
              vif.rid    <= xtn.arid;
              vif.rresp  <= 0;
              vif.rlast  <= (i == xtn.arlen);
              wait (vif.rready); // wait for rready to get low
              @(posedge vif.clk);
              vif.rvalid <= 0;
            end
          end
        
          // DEFAULT CASE: Invalid selection
          default: begin
            `uvm_error("READ_DRIVER", "Invalid case value")
          end
        endcase
      end

      seq_item_port.item_done(); //notify sequencer that transaction is completed
    end
  endtask

  task drive_rvalid(bit [3:0] arid, bit last_beat);
    vif.rid   <= arid; // rid is assigned with the read request id the master asked for 
    vif.rdata <= $random; 
    vif.rresp <= 0; // result of the operation is OKAY (2'b00)
    vif.rlast <= last_beat; // to specify the last transfer
    vif.rvalid <= 1; // to tell master that read data is available to master
  endtask
endclass
