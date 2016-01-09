y = 2.2;

input_values     = 0:1:255;
correction_table = cast( 255*(input_values/255).^(1/y), 'uint8')

mean((cast(correction_table,'double')-input_values)/255)
std((cast(correction_table,'double')-input_values)/255)