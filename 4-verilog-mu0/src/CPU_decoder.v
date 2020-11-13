module CPU_decoder(
    input logic clk,
    input logic rst,
    output logic[11:0] address,
    output logic write,
    output logic read,
    output logic[15:0] writedata,
    input logic[15:0] readdata,
    input logic[1:0] flag,
    output logic[2:0] get_status
    );


// Decide what address to put out on the bus, and whether to write
    assign address = (flag == 0)||(flag ==1) ? pc : instr_constant;
    assign write = (flag == 3) ? instr_opcode==OPCODE_STO : 0;
    assign read = (flag == 0)||(flag==1) ? 1 : (((flag == 2) || (flag == 3))&& (instr_opcode==OPCODE_LDA || instr_opcode==OPCODE_ADD  || instr_opcode==OPCODE_SUB ));
    assign writedata = acc;

 /* Using an enum to define constants */
    typedef enum logic[3:0] {
        OPCODE_LDA = 4'd0,
        OPCODE_STO = 4'd1,
        OPCODE_ADD = 4'd2,
        OPCODE_SUB = 4'd3,
        OPCODE_JMP = 4'd4,
        OPCODE_JGE = 4'd5,
        OPCODE_JNE = 4'd6,
        OPCODE_STP = 4'd7,
        OPCODE_OUT = 4'd8
    } opcode_t;

       /* Another enum to define CPU states. */
    typedef enum logic[2:0] {
        FETCH_INSTR_ADDR = 3'b000,
        FETCH_INSTR_DATA = 3'b001,
        EXEC_INSTR_ADDR  = 3'b010,
        EXEC_INSTR_DATA  = 3'b011,
        HALTED =      3'b100
    } state_t;

    logic[11:0] pc, pc_next;
    logic[15:0] acc;

    logic[16:0] instr;
    opcode_t instr_opcode;
    logic[11:0] instr_constant;   

    
    // Break-down the instruction into fields
    // these are just wires for our convenience
    assign instr_opcode = instr[15:12];
    assign instr_constant = instr[11:0];

    // This is used in many places, as most instructions go forwards by one step.
    // Defining it once makes it more likely the synthesis tool will only create
    // one concrete instance.
    wire[11:0] pc_increment;
    assign pc_increment = pc + 1;

    initial begin
        get_status = FETCH_INSTR_ADDR;
    end

    always @(posedge clk) begin
        if(rst) begin
            pc <= 0;
            acc <= 0;
        end
        else if(flag == 1) begin
            $display("CPU : INFO  : Fetching (addr), address=%h.", pc);
            instr <= readdata;
        end
        else if(flag == 3)begin
            $display("CPU : INFO  : Executing (data), opcode=%h, acc=%h, imm=%h, readdata=%x, get_status=%b", instr_opcode, acc, instr_constant, readdata,get_status);
            case(instr_opcode)
                    OPCODE_LDA: begin
                        acc <= readdata;
                        pc <= pc_increment;
                        get_status <= 3'b000;
                    end
                    OPCODE_STO: begin
                        pc <= pc_increment;
                        get_status <= 3'b000;
                    end
                    OPCODE_ADD: begin
                        acc <= acc + readdata;
                        pc <= pc_increment;
                        get_status <= 3'b000;
                    end
                    OPCODE_SUB: begin
                        acc <= acc - readdata;
                        pc <= pc_increment;
                        get_status <= 3'b000;
                    end
                    OPCODE_JMP: begin
                        pc <= instr_constant;
                        get_status <= 3'b000;
                    end
                    OPCODE_JGE: begin
                        if (acc > 0) begin
                            pc <= acc;
                        end
                        else begin
                            pc <= pc_increment;
                        end
                        get_status <= 3'b000;
                    end
                    OPCODE_JNE: begin
                        if (acc != 0) begin
                            pc <= instr_constant;
                        end
                        else begin
                            pc <= pc_increment;
                        end
                        get_status <= 3'b000;
                    end
                    OPCODE_OUT: begin
                        $display("CPU : OUT   : %d", $signed(acc));
                        pc <= pc_increment;
                        get_status <= 3'b000;
                    end
                    OPCODE_STP: begin
                        // Stop the simulation
                        get_status <= 3'b100;
                    end
                endcase
        end
        else begin
            //do nothing
        end
    end
endmodule