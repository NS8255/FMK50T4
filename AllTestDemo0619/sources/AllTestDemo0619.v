 module AllTestDemo0619(
    input sys_clk,
    output reg [7:0] leds,
    output reg [7:0] lcd_data,   // LCD显示选手姓名（ASCII码）
    output  reg[5:0] sel,
    output  reg[6:0] seg_l,
    output  reg[6:0] seg_r,
    input wire player1_btn, // 选手1抢答按键
    input wire player2_btn, // 选手2抢答按键
    input wire start_btn,   // 抢答开始按键
    input wire reset_btn,    // 重置按键
    input wire add_btn,     // 加分按键
    input wire sub_btn     // 减分按键
);

    reg [31:0] timer_cnt;

    parameter   IDLE = 3'b000;
    parameter   STARTED = 3'b001;
    parameter   PLAYER1_WIN = 3'b010;
    parameter   PLAYER2_WIN = 3'b011;
    parameter   TIMEOUT = 3'b100;

    reg [4:0] score_A = 5'd0;            // 积分计数器
    reg [4:0] score_B = 5'd0;            // 积分计数器
    
    parameter   COUNT0 = 7'b011_1111;      //数码管显示数字
    parameter   COUNT1 = 7'b000_0110;
    parameter   COUNT2 = 7'b101_1011;
    parameter   COUNT3 = 7'b100_1111;
    parameter   COUNT4 = 7'b110_0110;
    parameter   COUNT5 = 7'b110_1101;
    parameter   COUNT6 = 7'b111_1101;
    parameter   COUNT7 = 7'b000_0111;
    parameter   COUNT8 = 7'b111_1111;
    parameter   COUNT9 = 7'b110_1111;
    
    
    reg [3:0] countdown;        // 倒计时计数器
    reg  [2:0]state ;
    reg  [2:0]next_state = IDLE;
    parameter T1s = 50_000_000; //led计时器 灯一秒灭一个
    reg [25:0] cnt = 'd0;
    
    reg [3:0] btn_state;
    
always @(posedge clk_50M) begin
    if(cnt==T1s-1)begin
        cnt <= 'd0;
    end
    else begin 
        cnt <= cnt + 1;
    end
end 
   
always@(posedge clk_50M) begin
    sel <= 6'b110110;
    state <= next_state;
    case(state)
    IDLE:begin //空闲状态下
        if(start_btn == 4'b0000)begin   //开始按键按下，灯全亮
            countdown <= 8;
            leds <= 8'b00000000;
            next_state <= STARTED;
        end
        else begin 
            leds <= 8'b11111111;
            next_state <= IDLE; 
        end
    end
    STARTED:begin 
        if(player1_btn == 4'b0000)begin  //玩家1按下按键
            next_state <= PLAYER1_WIN;
        end
        else if(player2_btn == 4'b0000)begin  //玩家2按下按键
            next_state <= PLAYER2_WIN;
        end
        else if(countdown == 0) begin //超时转变成下一个状态
            next_state <= TIMEOUT;
        end 
        else begin 
        next_state <= STARTED;
            //LED一个个灭
            if(cnt==T1s-1) begin 
                leds <= {leds[6:0],1'd1};
                countdown <= countdown - 1;
            end 
            else begin
                leds <= leds;
            end
        end
    end
    PLAYER1_WIN:begin
        if(add_btn == 4'b0000)begin 
            score_A <= score_A + 5'd1;
            next_state <= IDLE;
        end
        else if(sub_btn == 4'b0000)begin
            score_A <= score_A - 5'd1;
            next_state <= IDLE; //给出结果之后转换到空闲状态，随后等待主持人出题目按下开始抢答按键
        end
        else begin 
        next_state <= PLAYER1_WIN;
        end
    end
    PLAYER2_WIN:begin
        if(add_btn == 4'b0000)begin 
            score_B <= score_B + 5'd1;
            next_state <= IDLE;
        end
        else if(sub_btn == 4'b0000)begin
            score_B <= score_B - 5'd1;
            next_state <= IDLE; //给出结果之后转换到空闲状态，随后等待主持人出题目按下开始抢答按键
        end
        else begin 
        next_state <= PLAYER2_WIN;
        end
    end
    TIMEOUT:begin 
        if(reset_btn == 4'b0000)begin //重置按钮被按下
            next_state <= IDLE;
            //得分清零
            //自锁取消
            //灯全灭？有无必要？
        end 
        else begin 
            next_state <= TIMEOUT;
        end 
    end
    default:begin //回归默认状态：空闲
        next_state <= IDLE;
    end 
    endcase
end

always @(posedge clk_50M) begin 
    case(score_A)
            5'd0: begin seg_r <= COUNT0; end
            5'd2: begin seg_r <= COUNT1; end
            5'd4: begin seg_r <= COUNT2; end
            5'd6: begin seg_r <= COUNT3; end
            5'd8: begin seg_r <= COUNT4; end
            5'd10: begin seg_r <= COUNT5; end
            5'd12: begin seg_r <= COUNT6; end
            5'd14: begin seg_r <= COUNT7; end
            5'd16: begin seg_r <= COUNT8; end
            5'd18: begin seg_r <= COUNT9; end
    endcase
end
always @(posedge clk_50M) begin 
    case(score_B)
            5'd0: begin seg_l <= COUNT0; end
            5'd2: begin seg_l <= COUNT1; end
            5'd4: begin seg_l <= COUNT2; end
            5'd6: begin seg_l <= COUNT3; end
            5'd8: begin seg_l <= COUNT4; end
            5'd10: begin seg_l <= COUNT5; end
            5'd12: begin seg_l <= COUNT6; end
            5'd14: begin seg_l <= COUNT7; end
            5'd16: begin seg_l <= COUNT8; end
            5'd18: begin seg_l <= COUNT9; end
    endcase
end

clk_wiz_0 clk1(
.clk_in1(sys_clk),
.clk_out1(clk_50M) //频率太大灯的亮度会暗
);
endmodule
