

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

module CPU_MU0_delay1(
    input logic clk,
    input logic rst,
    output logic running,
    input logic[2:0] get_status,
    output logic[1:0] flag
    );

    /* Another enum to define CPU states. */
    typedef enum logic[2:0] {
        FETCH_INSTR_ADDR = 3'b000,
        FETCH_INSTR_DATA = 3'b001,
        EXEC_INSTR_ADDR  = 3'b010,
        EXEC_INSTR_DATA  = 3'b011,
        HALTED =      3'b100
    } state_t;

    logic[2:0] state;

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
            $display("CPU : INFO  : Resetting.");
            state <= FETCH_INSTR_ADDR;
            running <= 1;
            flag<=0;
        end
        else if (state==FETCH_INSTR_ADDR) begin
            //$display("CPU : INFO  : Fetching (addr), address=%h.", pc);
            state <= FETCH_INSTR_DATA;
            flag <= 1;
        end
        else if (state==FETCH_INSTR_DATA) begin
            //$display("CPU : INFO  : Fetching (data), address=%h.", pc);
            state <= EXEC_INSTR_ADDR;
            flag <= 2;
        end
        else if (state==EXEC_INSTR_ADDR) begin
            //$display("CPU : INFO  : Executing (addr), opcode=%h, acc=%h, imm=%h, readdata=%x", instr_opcode, acc, instr_constant, readdata);
            state <= EXEC_INSTR_DATA;
            flag <= 3;
        end
        else if (state==EXEC_INSTR_DATA) begin
            $display("CPU : INFO  : Executing (data), state =%b",state);
            flag<=0;
            state <= get_status;
            if(get_status==HALTED)begin
                running = 0;
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

