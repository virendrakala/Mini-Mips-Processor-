module fibonacci32(
input clk,
input reset,
input [5:0] n,
output reg [31:0] fib,
output reg done
);

reg [31:0] fk;
reg [31:0] fk_1;
reg [5:0] count;

always @(posedge clk)
begin

if(reset==1)
begin

fk <= 32'd1;
fk_1 <= 32'd1;
count <= 6'd2;
done <= 0;

if(n==1)
begin
fib <= 32'd1;
done <= 1;
end

else if(n==2)
begin
fib <= 32'd1;
done <= 1;
end

end

else if(done==0)
begin

if(count < n)
begin

fib <= fk + fk_1;
fk_1 <= fk;
fk <= fk + fk_1;
count <= count + 1;

end

else
begin

fib <= fk;
done <= 1;

end

end

end

endmodule
