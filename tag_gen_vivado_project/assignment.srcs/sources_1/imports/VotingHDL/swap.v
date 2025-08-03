`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.07.2025 16:33:50
// Design Name: 
// Module Name: swap
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module swap
#(parameter TAG_SIZE=4, RECORD_SIZE=16, SECRET_KEY_SIZE=16, CEIL2_TAG=$clog2(TAG_SIZE), CEIL2_BLOCK=$clog2(RECORD_SIZE/TAG_SIZE))
(input clk, input reset, input [RECORD_SIZE-1:0] i_record, input [SECRET_KEY_SIZE-1:0] secret_key, output [RECORD_SIZE-1:0] o_record);
	wire [CEIL2_BLOCK - 1:0] bf = secret_key[CEIL2_BLOCK - 1:0];
	wire [CEIL2_BLOCK - 1:0] bx = secret_key[CEIL2_BLOCK* 2 - 1:CEIL2_BLOCK];
	wire [CEIL2_BLOCK - 1:0] by = secret_key[CEIL2_BLOCK * 3 - 1:CEIL2_BLOCK*2 ];
	wire [CEIL2_TAG - 1:0] px = secret_key[CEIL2_BLOCK * 3 + CEIL2_TAG - 1:CEIL2_BLOCK*3];
	wire [CEIL2_TAG - 1:0] py = secret_key[CEIL2_BLOCK * 3 + CEIL2_TAG * 2 - 1:CEIL2_BLOCK * 3 + CEIL2_TAG];
    wire [CEIL2_TAG - 1:0] s = secret_key[CEIL2_BLOCK * 3 + CEIL2_BLOCK * 3 - 1:CEIL2_BLOCK * 3 + CEIL2_TAG * 2];
	wire [CEIL2_TAG - 1:0] r = secret_key[CEIL2_BLOCK * 3 + CEIL2_TAG * 4 - 1:CEIL2_BLOCK * 3 + CEIL2_TAG * 3];
	wire [CEIL2_BLOCK - 1:0] bs = secret_key[CEIL2_BLOCK * 3 + CEIL2_TAG * 5 - 1:CEIL2_BLOCK * 3 + CEIL2_TAG * 4];

	//wire [TAG_SIZE-1:0] block1 = i_record[TAG_SIZE*(bx+1) - 1:TAG_SIZE*bx];
    wire [TAG_SIZE-1:0] block1 = i_record[TAG_SIZE*bx+:TAG_SIZE];
	//wire [TAG_SIZE-1:0] block2 = i_record[TAG_SIZE*(by+1) - 1:TAG_SIZE*by];	
    wire [TAG_SIZE-1:0] block2 = i_record[TAG_SIZE*by+:TAG_SIZE];
    reg [TAG_SIZE-1:0] new_block1;
    reg [TAG_SIZE-1:0] new_block2;
    reg [RECORD_SIZE-1:0] modified_record;
    assign o_record = modified_record;


    integer i;
    reg [TAG_SIZE-1:0] seg1, seg2;
    always @* begin
        new_block1 = block1;
        new_block2 = block2;

        for (i = 0; i < TAG_SIZE; i = i + 1) begin
            if (i < s) begin
                seg1[i] = block1[(px % TAG_SIZE + i) % TAG_SIZE];
                seg2[i] = block2[(py % TAG_SIZE + i) % TAG_SIZE];
            end
        end
        for (i = 0; i < TAG_SIZE; i = i + 1) begin
           if (i < s) begin
               new_block1[(px % TAG_SIZE + i) % TAG_SIZE] = seg2[i];
               new_block2[(py % TAG_SIZE + i) % TAG_SIZE] = seg1[i];
           end
        end 
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            modified_record <= {RECORD_SIZE{1'b0}};
        end else begin
            modified_record <= i_record;
            modified_record[TAG_SIZE*(bx)+:TAG_SIZE] <= new_block1;
            modified_record[TAG_SIZE*(by)+:TAG_SIZE] <= new_block2;
        end
    end


endmodule