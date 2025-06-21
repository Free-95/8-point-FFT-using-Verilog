module top #(parameter N = 8, WORD_SIZE = 32, SIO_SIZE = 32) (
    input [PIO_SIZE-1:0] input_data,
    input start, reset_n, clk,
    output [SIO_SIZE+$clog2(N)-1:0] serial_out,
    output output_valid, done
);

    // SIO_SIZE : Serial i/o data width
    localparam PIO_SIZE = N*WORD_SIZE; // Parallel i/o data width

    wire serial_start; // start_serialization signal of serializer
    wire [PIO_SIZE-1:0] fft_out;  // FFT output (to be feeded to serializer)
    reg [PIO_SIZE-1:0] buffer_in; // Buffer register to store output of fft

    fft_fp #(N, WORD_SIZE) fft_inst (
        .inputs(input_data),
        .clk(clk), .start(start), .reset_n(reset_n),
        .outputs(fft_out),
        .done(serial_start)
    );

    // Load buffer_in and start serialization when fft gives output
    always @(posedge clk) begin
        if (serial_start) begin
            buffer_in <= fft_out;
        end
    end

    serializer #(PIO_SIZE, SIO_SIZE, WORD_SIZE) serial_inst (
        .input_data(buffer_in),
        .clk(clk), .reset_n(reset_n), .start_serialize(serial_start),
        .output_data(serial_out),
        .output_valid(output_valid), .serialization_done(done)
    );

endmodule