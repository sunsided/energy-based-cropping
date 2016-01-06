y = 2.2;

values = cast(0:1:255, 'uint8');
corrected = cast(255*(double(values)/255).^(1/y), 'uint8')

