`timescale 1ns / 1ps
define HIGH 1'b1
define LOW 1'b0

module i2c_master(
    input                   clk,
    input                   rst,
    output                  scl,
    input                   sda_i,           // sda input
    output                  sda_o,           // sda output
    input       [6:0]       address_w,
    input                   rd_wr_w,
    input       [7:0]       write_data_w,
    input       [2:0]       num_read_w,
    output      [31:0]      read_data_w,
    input                   start_w,
    output                  ready_w,
    output                  read_ready_w,
    output                  error_w
    );
    

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
    
    assign scl = scl_r;
    assign sda_o = sda_drive ? sda_r : 1'bZ;    // Output control for sda_o

    reg [9:0]   delay_ctr, delay_ctr_ns;
    reg [9:0]   prescale = 10'd250;
    
    /*
    50 MHz için prescale = 250 (20ns*250*4 = 20000ns = 50 kbit/s)
    */ 

    reg [3:0]   ctr, ctr_ns;
    reg [1:0]   bit_ctr, bit_ctr_ns;
    
    reg [3:0]   state, state_ns;
    
    reg [3:0]   sample_buf, sample_buf_ns;
            
    reg [6:0]   address_r, address_ns_r;
    reg [7:0]   read_data_r, read_data_ns_r;
    reg [7:0]   write_data_r, write_data_ns_r;
    reg         rd_wr_r, rd_wr_ns_r;
    reg [2:0]   num_read_r, num_read_ns_r;
    reg         read_ready_r, read_ready_ns_r;
    
    reg [31:0]  read_queue, read_queue_ns;    
    assign read_data_w = read_queue;
    
    assign ready_w = state == IDLE;
    assign read_ready_w = read_ready_r;

    reg     error;
    assign  error_w = error;

    always @* begin
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
        read_queue_ns       = read_queue;
        num_read_ns_r       = num_read_r;
        read_ready_ns_r     = `LOW;
        if(delay_ctr > 0) begin
            delay_ctr_ns = delay_ctr - 1;
        end else if(delay_ctr == 0) begin
            case(state)
                IDLE: begin
                    delay_ctr_ns = 0;
                    sda_drive_ns = `LOW;
                    if(start_w) begin
                        // Load data to registers from the queue
                        address_ns_r = address_w;
                        rd_wr_ns_r = rd_wr_w;
                        write_data_ns_r = write_data_w;
                        num_read_ns_r = num_read_w;
                        state_ns = START;
                        bit_ctr_ns = 0;
                        read_queue_ns = 0;
                    end
                end
                START: begin
                    bit_ctr_ns = bit_ctr + 1;
                    delay_ctr_ns = prescale - 1;
                    case(bit_ctr)
                        2'h0: begin
                            sda_drive_ns = `HIGH;
                            sda_ns_r = `HIGH;
                            scl_ns_r = `HIGH;
                        end                       
                        2'h1: begin
                            sda_ns_r = `LOW;
                            scl_ns_r = `HIGH;
                        end
                        2'h2: begin
                            sda_ns_r = `LOW;
                            scl_ns_r = `LOW;
                        end
                        2'h3: begin
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
                            end
                        end
                    endcase
                end
                RD_WR: begin
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
                            read_data_ns_r[ctr] = (sample_buf[0]&sample_buf[1]) | (sample_buf[0]&sda_i) | (sample_buf[1]&sda_i);    // Read from sda_i
                            if(ctr == 0) begin
                                if(num_read_r == 1) begin
                                    state_ns = SEND_NACK;    
                                end else begin
                                    state_ns = SEND_ACK;
                                    num_read_ns_r = num_read_r - 1;
                                end
                                bit_ctr_ns = 0;
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
                            sda_ns_r = write_data_r[ctr];
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
                            end
                        end
                    endcase                
                end
                SEND_ACK: begin
                    bit_ctr_ns = bit_ctr + 1;
                    delay_ctr_ns = prescale - 1;
                    case(bit_ctr)
                        2'h0: begin
                            read_queue_ns = (read_queue | {24'h000000, read_data_r}) << 8;
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
                            read_queue_ns = read_queue | {24'h000000, read_data_r};
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
                            state_ns = STOP;
                            bit_ctr_ns = 0;
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
                            if((sample_buf[0]|sample_buf[1]) & (sample_buf[0]|sda_i) & (sample_buf[1]|sda_i)) begin // NOT ACKED ERROR
                                state_ns = IDLE;
                                error = `HIGH;
                            end
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
                            state_ns = STOP;    
                            bit_ctr_ns = 0;
                            error = `LOW;
                            if((sample_buf[0]|sample_buf[1]) & (sample_buf[0]|sda_i) & (sample_buf[1]|sda_i)) begin // NOT ACKED ERROR
                                state_ns = IDLE;
                                error = `HIGH;
                            end                    
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
                            read_ready_ns_r = rd_wr_r? `HIGH: `LOW; // okuma yapıldıysa read ready olucak
                        end
                    endcase                   
                end
            endcase    
        end
    end
    
    always @(posedge clk) begin
        if(rst) begin
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
            num_read_r      <= 0;
            sample_buf      <= 3'b0;
            read_queue      <= 0;
            read_ready_r    <= `LOW;
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
            num_read_r      <= num_read_ns_r;
            sample_buf      <= sample_buf_ns;
            read_queue      <= read_queue_ns;
            read_ready_r    <= read_ready_ns_r;
        end
    end
    
endmodule
