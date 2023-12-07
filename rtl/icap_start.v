`timescale 1ns / 1ps

module icap_start(
    input                   sclk            ,
    input                   rst_n           ,
    input                   icap_flag       ,
    output  reg             icap_done 
);
 
wire                        csib            ;
reg                 [31:0]  con_data [ 7:0] ;
wire                [31:0]  con_data_r      ;
reg                 [ 2:0]  cnt             ;
reg                         busy_flag       ;
reg                         rdwrb           ;
 
initial begin
    con_data[0]             =       32'hFFFF_FFFF;
    con_data[1]             =       32'hAA99_5566;
    con_data[2]             =       32'h2000_0000;
    con_data[3]             =       32'h3002_0001;
    con_data[4]             =       32'h0007_D000;//M镜像的起始地址
    con_data[5]             =       32'h3000_8001;
    con_data[6]             =       32'h0000_000F;
    con_data[7]             =       32'h2000_0000;
end
assign      csib            =       rdwrb;
assign      con_data_r      =       {con_data[cnt][24],con_data[cnt][25],con_data[cnt][26],con_data[cnt][27],con_data[cnt][28],con_data[cnt][29],
                                     con_data[cnt][30],con_data[cnt][31],con_data[cnt][16],con_data[cnt][17],con_data[cnt][18],con_data[cnt][19],
                                     con_data[cnt][20],con_data[cnt][21],con_data[cnt][22],con_data[cnt][23],con_data[cnt][08],con_data[cnt][09],
                                     con_data[cnt][10],con_data[cnt][11],con_data[cnt][12],con_data[cnt][13],con_data[cnt][14],con_data[cnt][15],
                                     con_data[cnt][00],con_data[cnt][01],con_data[cnt][02],con_data[cnt][03],con_data[cnt][04],con_data[cnt][05],
                                     con_data[cnt][06],con_data[cnt][07]};

always @(posedge sclk or negedge rst_n)
    if(rst_n == 1'b0)
        busy_flag           <=      1'b0;
    else if(icap_flag == 1'b1 && busy_flag == 1'b0)
        busy_flag           <=      1'b1; 
    else if(cnt == 3'd7 && rdwrb == 1'b0)
        busy_flag           <=      1'b0;
    else
        busy_flag           <=      busy_flag;

always @(posedge sclk or negedge rst_n)
    if(rst_n == 1'b0)
        cnt                 <=      3'd0;
    else if(busy_flag == 1'b1 && rdwrb == 1'b0)
        cnt                 <=      cnt + 1'b1;
    else if(cnt == 3'd7 && rdwrb == 1'b0)
        cnt                 <=      3'd0;
    else
        cnt                 <=      cnt;

always @(posedge sclk or negedge rst_n)
    if(rst_n == 1'b0)
        icap_done           <=      1'b0;        
    else if(cnt == 3'd7 && rdwrb == 1'b0)
        icap_done           <=      1'b1;
    else
        icap_done           <=      1'b0;
          
always @(posedge sclk or negedge rst_n)
    if(rst_n == 1'b0)
        rdwrb               <=      1'b1; 
    else if(cnt == 3'd7 && rdwrb == 1'b0)
        rdwrb               <=      1'b1;       
    else if(busy_flag == 1'b1)
        rdwrb               <=      1'b0;
    else
        rdwrb               <=      rdwrb;

ICAPE2 #(
	.DEVICE_ID          (32'h362d093        ),                      
	.ICAP_WIDTH         ("X32"              ),  
	.SIM_CFG_FILE_NAME  ("NONE"             )   
)ICAPE2_inst(
	.O                  (                   ),  
	.CLK                (sclk               ), 
	.CSIB               (csib               ), 
	.I                  (con_data_r         ),  
	.RDWRB              (rdwrb              )  
);
 

endmodule

