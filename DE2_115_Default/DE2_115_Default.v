// ============================================================================
// Copyright (c) 2012 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// ============================================================================
//           
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//
//
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// ============================================================================
//
// Major Functions:	DE2_115_Default
//
// ============================================================================
//
// Revision History :
// ============================================================================
//   Ver  :| Author              :| Mod. Date :| Changes Made:
//   V1.1 :| HdHuang             :| 05/12/10  :| Initial Revision
//   V2.0 :| Eko       				:| 05/23/12  :| version 11.1
// ============================================================================

module DE2_115_Default(

	//////// CLOCK //////////
   write_clock,CLOCK_50,
	
	/////// ADDRESS ////////
	vga_data_write,vga_data_addr,vga_wren_enable,

	//////// VGA //////////
	VGA_B,
	VGA_BLANK_N,
	VGA_CLK,
	VGA_G,
	VGA_HS,
	VGA_R,
	VGA_SYNC_N,
	VGA_VS

);

//=======================================================
//  PARAMETER declarations
//=======================================================

//=======================================================
//  PORT declarations
//=======================================================

//////////// CLOCK //////////
input		          		write_clock,CLOCK_50;

/////////// ADDR ///////////
input vga_wren_enable;
input[18:0] vga_data_addr;
input[23:0] vga_data_write;

//////////// VGA //////////
output		   [7:0]		VGA_B;
output		        		VGA_BLANK_N;
output		        		VGA_CLK;
output		   [7:0]		VGA_G;
output	          		VGA_HS;
output	      [7:0]		VGA_R;
output	         		VGA_SYNC_N;
output	          		VGA_VS;


wire		   VGA_CTRL_CLK;
wire		   DLY_RST;

//	For VGA Controller
wire			mVGA_CLK;


//	Reset Delay Timer
Reset_Delay			r0	(	.iCLK(CLOCK_50),.oRESET(DLY_RST)	);

VGA_Audio_PLL 		p1	(	.areset(~DLY_RST),.inclk0(CLOCK_50),.c0(VGA_CTRL_CLK),.c2(mVGA_CLK)	);

//	VGA Controller
assign VGA_CLK = VGA_CTRL_CLK;
vga_controller vga_ins(.iRST_n(DLY_RST),
                      .iVGA_CLK(VGA_CTRL_CLK),
                      .oBLANK_n(VGA_BLANK_N),
                      .oHS(VGA_HS),
                      .oVS(VGA_VS),
                      .b_data(VGA_B),
                      .g_data(VGA_G),
                      .r_data(VGA_R),
							 .write_clock(write_clock),
							 .write_addr(vga_data_addr),
							 .write_data(vga_data_write),
							 .wren_signal(vga_wren_enable));
					


endmodule
