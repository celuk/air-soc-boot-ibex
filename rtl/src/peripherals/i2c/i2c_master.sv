`timescale 1ns / 1ps
`define HIGH 1'b1
`define LOW 1'b0

module i2c_master(
    input                   clk_i,
    input                   rst_i,
    input                   scl_i,           // TODO: scl input, multi master için kullanılabilir 
    output                  scl_o,
    input                   sda_i,           // sda input
    output                  sda_o,           // sda output
    input       [6:0]       address_i,
    input                   rd_wr_i,
    input       [31:0]      write_data_i,
    input       [2:0]       num_bytes_i,
    output      [31:0]      read_data_o,
    input                   start_i,
    output      reg         start_aldim_o,  
    output                  ready_o,
    output                  read_finished_o,
    output                  write_finished_o,
    output                  error_o,
    output                  sda_drive_o
    );
    reg debug_adres_gitti_r;

    localparam [3:0]
        IDLE                = 4'h0,
        START               = 4'h1,
        ADDRESS             = 4'h2,
        RD_WR               = 4'h3,
        READ                = 4'h4,
        WRITE               = 4'h5,
        SEND_ACK            = 4'h6,
        SEND_NACK           = 4'h7,
        RECEIVE_ADDR_ACK    = 4'h8,
        RECEIVE_DATA_ACK    = 4'h9,
        STOP                = 4'ha;
        
    reg     sda_r, sda_ns_r;
    reg     scl_r, scl_ns_r;
    reg     sda_drive, sda_drive_ns;
    
    assign scl_o = scl_r;
    assign sda_o = sda_drive ? sda_r : 1'bZ;    // Output control for sda_o
    assign  sda_drive_o = sda_drive;
    reg [5:0]   delay_ctr, delay_ctr_ns;
    reg [5:0]   prescale = 10'd62;//işemcinin 248 çevrimi bunun 1 çevrimi 100mhz ise
    
    /*
    50 MHz için prescale = 250 (20ns*250*4 = 20000ns = 50 kbit/s)
    */ 

    reg [3:0]   ctr, ctr_ns; //oku yaz durumlarında bitleri sayar 
    reg [1:0]   bit_ctr, bit_ctr_ns;
    
    reg [3:0]   state, state_ns;
    
    reg [3:0]   sample_buf, sample_buf_ns; // her bitin dört kez örneklenmesi için. 3 veya 4 örnekte aynı sonuç çıkarsa o bit kabul edilir.
            
    reg [6:0]   address_r, address_ns_r;
    reg [31:0]  read_data_r, read_data_ns_r;
    reg [31:0]  write_data_r, write_data_ns_r;
    reg         rd_wr_r, rd_wr_ns_r;
    reg [2:0]   num_bytes_r, num_bytes_ns_r;
    reg [2:0]   cur_bytes_r, cur_bytes_ns_r;
    reg         read_finish_r, read_finish_ns_r;
    reg         write_finish_r, write_finish_ns_r;
    
    assign read_data_o = read_data_r;
    
    assign ready_o = state == IDLE;
    assign read_finished_o = read_finish_r;
    assign write_finished_o = write_finish_r;

    reg     error;
    assign  error_o = error;

    always @* begin
        debug_adres_gitti_r = 0;
        state_ns            = state;
        sda_ns_r            = sda_r;
        scl_ns_r            = scl_r;
        sda_drive_ns        = sda_drive;
        delay_ctr_ns        = delay_ctr;
        ctr_ns              = ctr;
        bit_ctr_ns          = bit_ctr;
        address_ns_r        = address_r;
        read_data_ns_r      = read_data_r;
        write_data_ns_r     = write_data_r;
        rd_wr_ns_r          = rd_wr_r;
        sample_buf_ns       = sample_buf;
        num_bytes_ns_r      = num_bytes_r;
        cur_bytes_ns_r      = cur_bytes_r;
        read_finish_ns_r    = read_finish_r;
        write_finish_ns_r   = write_finish_r;
        start_aldim_o       = 0;
        if(delay_ctr > 0) begin
            delay_ctr_ns = delay_ctr - 1;
        end else if(delay_ctr == 0) begin
            case(state)
                IDLE: begin
                    delay_ctr_ns = 0;
                    sda_drive_ns = `LOW;
                    if(start_i) begin
                        // Load data to registers from the queue
                        address_ns_r = address_i;
                        rd_wr_ns_r = rd_wr_i;
                        write_data_ns_r = write_data_i;
                        num_bytes_ns_r = num_bytes_i;
                        state_ns = START;
                        bit_ctr_ns = 0;
                        cur_bytes_ns_r = 0;
                        read_finish_ns_r    = 0;
                        write_finish_ns_r   = 0;
                        start_aldim_o = 1;
                    end
                end
                START: begin
                    bit_ctr_ns = bit_ctr + 1;
                    delay_ctr_ns = prescale - 1;
                    case(bit_ctr)
                        2'h0: begin //sda hattı veri için hazırlanır.
                            sda_drive_ns = `HIGH;
                            sda_ns_r = `HIGH;
                            scl_ns_r = `HIGH;
                            start_aldim_o = 1;
                        end                       
                        2'h1: begin //scl yükseltilir. Verinin geçerli olduğu zaman dilimi.
                            sda_ns_r = `LOW;
                            scl_ns_r = `HIGH;
                        end
                        2'h2: begin //scl yüksek tutulur. Verinin stabil hale gelmesi için.
                            sda_ns_r = `LOW;
                            scl_ns_r = `LOW;
                        end
                        2'h3: begin //sda düşürülür. Sonraki bitin işlenmesi için.
                            state_ns = ADDRESS;
                            ctr_ns = 6;
                            bit_ctr_ns = 0;
                        end
                    endcase  
                end
                ADDRESS: begin
                    bit_ctr_ns = bit_ctr + 1;
                    delay_ctr_ns = prescale - 1;
                    case(bit_ctr)
                        2'h0: begin
                            sda_drive_ns = `HIGH;
                            sda_ns_r = address_r[ctr];
                            scl_ns_r = `LOW;
                        end
                        2'h1: begin
                            scl_ns_r = `HIGH;                        
                        end
                        2'h2: begin
                            scl_ns_r = `HIGH;                        
                        end
                        2'h3: begin
                            scl_ns_r = `LOW;
                            ctr_ns = ctr - 1;
                            if(ctr == 0) begin
                                state_ns = RD_WR;
                                bit_ctr_ns = 0;
                                debug_adres_gitti_r = 1;
                            end
                        end
                    endcase
                end
                RD_WR: begin
                    debug_adres_gitti_r = 0;
                    bit_ctr_ns = bit_ctr + 1;
                    delay_ctr_ns = prescale - 1;
                    case(bit_ctr)
                        2'h0: begin
                            sda_drive_ns = `HIGH;
                            sda_ns_r = rd_wr_r? `HIGH: `LOW;
                            scl_ns_r = `LOW;
                        end
                        2'h1: begin
                            scl_ns_r = `HIGH;                        
                        end
                        2'h2: begin
                            scl_ns_r = `HIGH;                        
                        end
                        2'h3: begin
                            scl_ns_r = `LOW;
                            state_ns = RECEIVE_ADDR_ACK;
                            ctr_ns = 7;
                            bit_ctr_ns = 0;
                        end
                    endcase
                end
                READ: begin
                    bit_ctr_ns = bit_ctr + 1;
                    delay_ctr_ns = prescale - 1;
                    case(bit_ctr)
                        2'h0: begin
                            sda_drive_ns = `LOW;
                            scl_ns_r = `LOW;
                        end
                        2'h1: begin
                            scl_ns_r = `HIGH;
                            sample_buf_ns[0] = sda_i;    // Read from sda_i
                        end
                        2'h2: begin
                            scl_ns_r = `HIGH;                        
                            sample_buf_ns[1] = sda_i;    // Read from sda_i
                        end
                        2'h3: begin
                            scl_ns_r = `LOW;
                            sample_buf_ns[2] = sda_i;    // Read from sda_i
                            ctr_ns = ctr - 1;
                            read_data_ns_r[ctr + cur_bytes_r*8] = (sample_buf[0]&sample_buf[1]) | (sample_buf[0]&sda_i) | (sample_buf[1]&sda_i);    // Read from sda_i
                            if(ctr == 0) begin
                                if(cur_bytes_r == num_bytes_r - 1) begin        /// BAK BUNA
                                    state_ns = SEND_NACK;    
                                end else begin
                                    state_ns = SEND_ACK;
                                    cur_bytes_ns_r = cur_bytes_r + 1;
                                end
                                bit_ctr_ns = 0;
                                ctr_ns = 7;
                            end
                        end
                    endcase
                end
                WRITE: begin
                    bit_ctr_ns = bit_ctr + 1;
                    delay_ctr_ns = prescale - 1;
                    case(bit_ctr)
                        2'h0: begin
                            sda_drive_ns = `HIGH;
                            sda_ns_r = write_data_r[ctr + cur_bytes_r*8];
                            scl_ns_r = `LOW;
                        end
                        2'h1: begin
                            scl_ns_r = `HIGH;                        
                        end
                        2'h2: begin
                            scl_ns_r = `HIGH;                        
                        end
                        2'h3: begin
                            scl_ns_r = `LOW;
                            ctr_ns = ctr - 1;
                            if(ctr == 0) begin
                                state_ns = RECEIVE_DATA_ACK;    
                                bit_ctr_ns = 0;
                                cur_bytes_ns_r = cur_bytes_r + 1;
                                ctr_ns = 7;
                            end
                        end
                    endcase                
                end
                SEND_ACK: begin
                    bit_ctr_ns = bit_ctr + 1;
                    delay_ctr_ns = prescale - 1;
                    case(bit_ctr)
                        2'h0: begin
                            sda_drive_ns = `HIGH;
                            sda_ns_r = `LOW;
                            scl_ns_r = `LOW;
                        end
                        2'h1: begin
                            scl_ns_r = `HIGH;                        
                        end
                        2'h2: begin
                            scl_ns_r = `HIGH;                        
                        end
                        2'h3: begin
                            scl_ns_r = `LOW;
                            state_ns = READ;
                            bit_ctr_ns = 0;
                            ctr_ns = 7;                            
                        end
                    endcase                
                end
                SEND_NACK: begin
                    bit_ctr_ns = bit_ctr + 1;
                    delay_ctr_ns = prescale - 1;
                    case(bit_ctr)
                        2'h0: begin
                            sda_drive_ns = `HIGH;
                            sda_ns_r = `HIGH;
                            scl_ns_r = `LOW;
                        end
                        2'h1: begin
                            scl_ns_r = `HIGH;                        
                        end
                        2'h2: begin
                            scl_ns_r = `HIGH;                        
                        end
                        2'h3: begin
                            scl_ns_r = `LOW;
                            state_ns = start_i ? IDLE : STOP;         // 1 çevrim kaybeder, çok sallamıyorum.
                            bit_ctr_ns = 0;
                            ctr_ns = 7;
                            read_finish_ns_r = 1;
                        end
                    endcase                
                end                
                RECEIVE_ADDR_ACK: begin
                    bit_ctr_ns = bit_ctr + 1;
                    delay_ctr_ns = prescale - 1;
                    case(bit_ctr)
                        2'h0: begin
                            sda_drive_ns = `LOW;
                            scl_ns_r = `LOW;
                        end
                        2'h1: begin
                            scl_ns_r = `HIGH;
                            sample_buf_ns[0] = sda_i;    // Read from sda_i
                        end
                        2'h2: begin
                            scl_ns_r = `HIGH;                        
                            sample_buf_ns[1] = sda_i;    // Read from sda_i
                        end
                        2'h3: begin
                            scl_ns_r = `LOW;
                            sample_buf_ns[2] = sda_i;    // Read from sda_i
                            state_ns = rd_wr_r? READ: WRITE;    
                            bit_ctr_ns = 0;
                            ctr_ns = 7;
                            error = `LOW;
                            // if((sample_buf[0]|sample_buf[1]) & (sample_buf[0]|sda_i) & (sample_buf[1]|sda_i)) begin // NOT ACKED ERROR
                            //     state_ns = IDLE;
                            //     error = `HIGH;
                            // end
                        end
                    endcase                
                end
                RECEIVE_DATA_ACK: begin
                    bit_ctr_ns = bit_ctr + 1;
                    delay_ctr_ns = prescale - 1;
                    case(bit_ctr)
                        2'h0: begin
                            sda_drive_ns = `LOW;
                            scl_ns_r = `LOW;
                        end
                        2'h1: begin
                            scl_ns_r = `HIGH;
                            sample_buf_ns[0] = sda_i;    // Read from sda_i
                        end
                        2'h2: begin
                            scl_ns_r = `HIGH;                        
                            sample_buf_ns[1] = sda_i;    // Read from sda_i
                        end
                        2'h3: begin
                            scl_ns_r = `LOW;
                            sample_buf_ns[2] = sda_i;    // Read from sda_i
                            bit_ctr_ns = 0;
                            error = `LOW;
                            write_finish_ns_r = (cur_bytes_r == num_bytes_r) ? `HIGH : `LOW;
                            state_ns = (cur_bytes_r != num_bytes_r) ? WRITE : (start_i ? IDLE : STOP);
                            ctr_ns = 7;
                            // if((sample_buf[0]|sample_buf[1]) & (sample_buf[0]|sda_i) & (sample_buf[1]|sda_i)) begin // NOT ACKED ERROR
                            //     state_ns = IDLE;            /// BUNA GEREK VAR MI IDK
                            //     error = `HIGH;
                            // end  
                                              
                        end
                    endcase                
                end                
                STOP: begin
                    bit_ctr_ns = bit_ctr + 1;
                    delay_ctr_ns = prescale - 1;
                    case(bit_ctr)
                        2'h0: begin
                            sda_drive_ns = `HIGH;
                            sda_ns_r = `LOW;
                            scl_ns_r = `HIGH;
                        end
                        2'h1: begin
                            sda_ns_r = `HIGH;
                            scl_ns_r = `HIGH;
                        end
                        2'h2: begin
                            sda_ns_r = `HIGH;
                            scl_ns_r = `HIGH;
                            state_ns = IDLE;
                            delay_ctr_ns = 0;
                        end
                    endcase                   
                end
            endcase    
        end
    end
    
    always @(posedge clk_i) begin
        if(rst_i) begin
            state       <= IDLE;
            sda_r       <= `HIGH;
            scl_r       <= `HIGH;
            sda_drive   <= `LOW;
            delay_ctr   <= 0;        
            ctr         <= 0;
            bit_ctr     <= 0;
            address_r       <= 0;
            read_data_r     <= 0;
            write_data_r    <= 0;
            rd_wr_r         <= 0;
            num_bytes_r     <= 0;
            cur_bytes_r     <= 0;
            sample_buf      <= 3'b0;
            
            read_finish_r   <= `LOW;
            write_finish_r  <= `LOW;
        end else begin
            state       <= state_ns;
            sda_r       <= sda_ns_r;
            scl_r       <= scl_ns_r;
            sda_drive   <= sda_drive_ns;
            delay_ctr   <= delay_ctr_ns;
            ctr         <= ctr_ns;
            bit_ctr     <= bit_ctr_ns;
            address_r       <= address_ns_r;
            read_data_r     <= read_data_ns_r;
            write_data_r    <= write_data_ns_r;
            rd_wr_r         <= rd_wr_ns_r;
            num_bytes_r     <= num_bytes_ns_r;
            cur_bytes_r     <= cur_bytes_ns_r;
            sample_buf      <= sample_buf_ns;
            read_finish_r   <= read_finish_ns_r;
            write_finish_r  <= write_finish_ns_r;
        end
    end
    
endmodule