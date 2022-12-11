module apb_pwm_tb;
parameter DATA_WIDTH = 32;

initial
begin
	$dumpfile("dump.vcd");
	$dumpvars;
end

logic PCLK;
logic PRESETn;

logic [DATA_WIDTH-1:0] PADDR;
logic PSEL;
logic PENABLE;
logic PWRITE;
logic [DATA_WIDTH-1:0] PWDATA;

logic PREADY;
logic PSERR;
logic [DATA_WIDTH-1:0] PRDATA;
logic pwm_out;

apb_pwm apb_pwm_inst(.*);
initial
begin
	PCLK = 0;
	PRESETn= 0;
	PWRITE = 0;
	PSEL = 0;
	PENABLE = 0;
	repeat(10) @(posedge PCLK);
	PRESETn = 1;
	@(posedge PCLK);
	//write duty cycle
	PADDR = 32'h0; PSEL = 1; PENABLE = 1;
	PWRITE = 1; PWDATA = 32'd30;
	@(posedge PCLK);
	//write pwm period
	PADDR = 32'h4; PSEL = 1; PENABLE = 1;
	PWRITE = 1; PWDATA = 32'd10;
 	//write pwm length
	@(posedge PCLK);
	PADDR = 32'hc; PSEL = 1; PENABLE = 1;
	PWRITE = 1; PWDATA = 32'd20;
 
	//PWM ENABLE
	@(posedge PCLK);
	PADDR = 32'h8; PSEL = 1; PENABLE = 1;
	PWRITE = 1; PWDATA = 32'd1;
    repeat(30) @(posedge PCLK);
	PADDR = 32'h8; PSEL = 1; PENABLE = 1;
	PWRITE = 1; PWDATA = 32'd0;
	#50 $finish;
end
always #1 PCLK = !PCLK;

endmodule