module sw_decoder (
    output logic [6:0] data_a, data_b, 
    input  logic [7:0] address
);

seven_seg_decoder ssd0 (
    .address(address[3:0]),
    .data   (data_a      )
);

seven_seg_decoder ssd1 (
    .address(address[7:4]),
    .data   (data_b      )
);

endmodule