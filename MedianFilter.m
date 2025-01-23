clc;
clear all;

% Read and display the original image
I1 = imread("cameraman.tif");
%I1 = imread("coins.png");
%I1 = imread("rice.png");
%I1 = imread("pout.tif");
figure, imshow(I1), title("Original IMAGE");

% Add noise to the image
I2 = I1;
[rows, cols] = size(I1);
for i = 1:rows
    for j = 1:cols
        a = rand;
        if a <= 0.1
            I2(i, j) = 0; % Black
        elseif a >= 0.9
            I2(i, j) = 255; % White
        end
    end
end
figure, imshow(I2), title("Noisy IMAGE");

% Convert to double for processing
I2 = double(I2);

% Apply standard median filtering
filtered_image = I2;
for i = 2:rows-1
    for j = 2:cols-1
        % Extract the 3x3 neighborhood
        window = I2(i-1:i+1, j-1:j+1);
        % Reshape and sort the values in the window
        window_sorted = sort(window(:));
        % Replace the pixel with the median value
        filtered_image(i, j) = window_sorted(5);
    end
end

% Convert filtered image back to uint8
final_image = uint8(filtered_image);

% Display the final filtered image
figure, imshow(final_image), title("Filtered Image");

% Calculate MSE and PSNR
E = double(final_image) - double(I1);
mse = sum(E(:).^2) / (rows * cols);
PSNR = 10 * log10(255^2 / mse);

% Display MSE and PSNR
disp(['MSE: ', num2str(mse)]);
disp(['PSNR: ', num2str(PSNR)]);
