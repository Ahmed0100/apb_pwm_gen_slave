// Code your design here
module apb_pwm #(parameter DATA_WIDTH=32)
(
	input logic PCLK, PRESETn,
	input logic [DATA_WIDTH-1:0] PADDR,
	input logic PSEL,
	input logic PENABLE,
	input logic PWRITE,
	input logic [DATA_WIDTH-1:0] PWDATA,
	//APB READ INTERFACE
	output logic PREADY,
	output logic PSERR,
  output logic [DATA_WIDTH-1:0] PRDATA,
	output logic pwm_out
);

//pwm registers. memory mapped.
logic [DATA_WIDTH-1:0] PWM_DUTY; //addr = 0
logic [DATA_WIDTH-1:0] PWM_PERIOD; //addr = 0x4
logic PWM_ENABLE; //addr = 0x8
logic [DATA_WIDTH-1:0] PWM_LENGTH; //addr = 0xc


  logic [31:0] pwm_period_count, pwm_length_count;

//apb interface write body
always_ff @(posedge PCLK or negedge PRESETn) begin : proc_apb_write_logic
	if(~PRESETn)
	begin
		PWM_LENGTH <= 0;
		PWM_DUTY <= 0;
		PWM_ENABLE <= 0;
		PWM_PERIOD <= 0;
	end 
	else
	begin
		if(PSEL && PENABLE && PWRITE && PREADY)
		begin
			if(PADDR == 32'h0)
			begin
				PWM_DUTY <= PWDATA;
			end
			else if(PADDR == 32'h4)
			begin
				PWM_PERIOD <= PWDATA;
			end
			else if(PADDR == 32'h8)
			begin
				PWM_ENABLE <= PWDATA[0];
			end
			else if(PADDR == 32'hc)
			begin
				PWM_LENGTH <= PWDATA;
			end
		end
	end
end
//apb interface read body.
assign PSERR = 0;
always_ff @(posedge PCLK or negedge PRESETn) begin : proc_apb_read_logic
	if(~PRESETn) 
	begin
		PRDATA <= 0;
	end 
	else 
	begin
      if(PSEL && PENABLE && PREADY && !PWRITE)
		begin
			if(PADDR == 0)
				PRDATA <= PWM_DUTY;
			else if(PADDR == 32'h4)
				PRDATA <= PWM_PERIOD;
			else if (PADDR == 32'h8)
				PRDATA <= PWM_ENABLE;
			else if(PADDR == 32'hc)
				PRDATA <= PWM_LENGTH;
		end
	end
end
//pwm logic
  int pwm_rising_edge;
  assign pwm_rising_edge = (int'(PWM_PERIOD)*(int'(PWM_DUTY)/100.0));

always_ff @(posedge PCLK or negedge PRESETn) begin : proc_pwm_out
	if(~PRESETn) 
	begin
		pwm_out <= 0;
	end 
	else if(PWM_ENABLE)
	begin
		if(pwm_length_count == PWM_LENGTH-1)
			pwm_out <= 0;
		else if(pwm_period_count == PWM_PERIOD-1)
			pwm_out <= 0;
      else if(pwm_period_count >= PWM_PERIOD - pwm_rising_edge - 1)
			pwm_out <= 1;
	end
end

always_ff @(posedge PCLK or negedge PRESETn) begin : proc_pwm_period_count
	if(~PRESETn) begin
		pwm_period_count <= '0;
	end else begin
		if(PWM_ENABLE)
		begin
			if(pwm_period_count == PWM_PERIOD - 1)
				pwm_period_count <= '0;
			else
				pwm_period_count <= pwm_period_count + 1;
		end
	end
end

  assign PREADY = (pwm_length_count == '0);

always_ff @(posedge PCLK or negedge PRESETn) begin : proc_pwm_length_count
	if(~PRESETn) begin
		pwm_length_count <= '0;
	end else begin
		if(PWM_ENABLE)
		begin
			if(pwm_length_count == PWM_LENGTH - 1)
				pwm_length_count <= '0;
			else
				pwm_length_count <= pwm_length_count + 1;
		end
	end
end
endmodule : apb_pwm