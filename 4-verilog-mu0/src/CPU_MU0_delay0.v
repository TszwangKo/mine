

/*
STP 0111 stop
JNE S 0110 if ACC ≠ 0, PC := S
JGE S 0101 if ACC > 0, PC := S
JMP S 0100 PC := S
SUB S 0011 ACC := ACC – mem[S]
ADD S 0010 ACC := ACC + mem[S]
STO S 0001 mem[S] := ACC
LDA S 0000 ACC := mem[S]
OUT S 1000 print(Acc)
*/

module CPU_MU0_delay0(
    input logic clk,
    input logic rst,
    output logic running,
    input logic[2:0] get_status,
    output logic[1:0] flag
    );

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
    typedef enum logic[1:0] {
        FETCH_INSTR = 2'b00,
        EXEC_INSTR = 2'b01,
        HALTED = 2'b10
    } state_t; 

    logic[1:0] state;

    /* We are targetting an FPGA, which means we can specify the power-on value of the
        circuit. So here we set the initial state to 0, and set the output value to
        indicate the CPU is not running.
    */
    initial begin
        state = HALTED;
        running = 0;
    end
    
    /* Main CPU sequential update logic. Where combinational logic is simple, it
        has been incorporated directly here, rather than splitting it into another
        block.

        Note: this is always rather than always_ff due to limitations in the verilog
        simulator, which can't deal with $display in always_ff blocks.
    */
    always @(posedge clk) begin
        if (rst) begin
            $display("CPU : INFO  : Resetting");//.");
            state <= FETCH_INSTR;
            running <= 1;
            flag <= 1;
        end
        else if (state==FETCH_INSTR) begin
            $display("CPU : INFO  : Fetching");//, address=%h.", pc);
            state <= EXEC_INSTR;
            flag <= 3;
        end
        else if (state==EXEC_INSTR) begin
            $display("CPU : INFO  : Executing");//, opcode=%h, acc=%h, imm=%h, readdata=%x", instr_opcode, acc, instr_constant, readdata);
            flag <= 1 ;
            if(get_status==3'b100)begin
                state <=HALTED;
                running <=0;
            end
            else begin
                state <= FETCH_INSTR;
            end
        end
        else if (state==HALTED) begin
            // do nothing
        end
        else begin
            $display("CPU : ERROR : Processor in unexpected state %b", state);
            $finish;
        end
    end
endmodule

