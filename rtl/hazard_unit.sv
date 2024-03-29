module hazard_unit (
    input logic [4:0] Rs1_E,
    input logic [4:0] Rs2_E,
    input logic [4:0] Rs1_D, 
    input logic [4:0] Rs2_D, 
    input logic [4:0] Rd_E,
    input logic [4:0] Rd_M,
    input logic [4:0] Rd_W,
    input logic RegWrite_M,
    input logic RegWrite_W,
    input logic MemRead_E, 
    input logic branch,
    output logic [1:0] forwardA_E,
    output logic [1:0] forwardB_E,
    output logic stall,
    output logic flush

);

    // Data hazard
    always_comb begin

        // Initializing signals

        stall = 1'b0;
        flush = 1'b0;
        forwardA_E = 2'b00;
        forwardB_E = 2'b00;

        // Read After Write (RAW) hazard --> Forwarding

            // forwardA_E
            // 00 : RD1_E : no forwarding
            // 01 : Result_W : forwarding from EX/MEM (after data memory)
            // 10 : ALUResult_M : forwarding from MEM/WB (after ALU)

        if (RegWrite_M && (Rd_M != 0) && (Rd_M == Rs1_E)) begin
            forwardA_E = 2'b10;
        end 
        else if (RegWrite_W && (Rd_W != 0) && (Rd_W == Rs1_E)) begin
            forwardA_E = 2'b01;
        end 
        else begin
            forwardA_E = 2'b00;
        end

            // forwardB_E
            // 00 : RD2_E : no forwarding
            // 01 : Result_W : forwarding from EX/MEM (after data memory)
            // 10 : ALUResult_M : forwarding from MEM/WB (after ALU)

        if (RegWrite_M && (Rd_M != 0) && (Rd_M == Rs2_E)) begin
            forwardB_E = 2'b10;
        end 
        else if (RegWrite_W && (Rd_W != 0) && (Rd_W == Rs2_E)) begin
            forwardB_E = 2'b01;
        end 
        else begin
            forwardB_E = 2'b00;
        end

            // RegWrite = RegWrite
            // WriteReg = Rd
            // RegisterRs = Rs1
            // RegisterRt = Rs2

        // Load word data dependency hazard --> Stalling

            // Is the instruction in the EX stage a load word?
            // Is the instruction in the EX stage using the same register as the instruction in the ID stage?
            // If both are true, then stall the pipeline

        if (MemRead_E && ((Rd_E == Rs1_D) || (Rd_E == Rs2_D))) begin
            stall = 1'b1;
        end 
        else begin
            stall = 1'b0;
        end

        // Control hazard

        // Branch taken --> Flush the pipeline
        // Branch not taken --> Do nothing
        // JAL --> Flush the pipeline
        // JALR --> Flush the pipeline

        // Branch detected in ? stage
        // Assume that the branch isn't taken
            // Let the pipeline continue
        // If the branch is taken, then flush the instructions in the pipeline datapath (3-4 cycles)
            // Flush by setting the control lines to 0 when they reach the EX stage

        if (branch) begin
            flush = 1;
        end

    end
     

endmodule
