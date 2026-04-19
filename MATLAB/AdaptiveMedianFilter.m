clc;
clear all;

% Read and display the original image
%I1 = imread("cameraman.tif");
%I1 = imread("coins.png");
%I1 = imread("rice.png");
I1 = imread("pout.tif");
figure, imshow(I1), title("Original IMAGE");

% Add noise to the image
I2 = I1;
[rows, cols] = size(I1);
for i = 1:rows
    for j = 1:cols
        a = rand;
        if a <= 0.3
            I2(i, j) = 0; % Black
        elseif a >= 0.7
            I2(i, j) = 255; % White
        end
    end
end
figure, imshow(I2), title("Noisy IMAGE");

% Convert to double for processing
I2 = double(I2);

% Initialize windows for adaptive filtering
W1 = zeros(9);
W4 = zeros(25);
W7 = zeros(49);

% Apply adaptive median filtering
for i = 4:rows-3
    for j = 4:cols-3
        W1 = I2(i-1:i+1, j-1:j+1);
        W2 = reshape(W1, [1 9]);
        W3 = sort(W2);
        A1 = I2(i, j) - W3(1);
        A2 = I2(i, j) - W3(9);
        if A1 == 0 || A2 == 0
            W4 = I2(i-2:i+2, j-2:j+2);
            W5 = reshape(W4, [1 25]);
            W6 = sort(W5);
            A3 = I2(i, j) - W6(1);
            A4 = I2(i, j) - W6(25);
            if A3 == 0 || A4 == 0
                W7 = I2(i-3:i+3, j-3:j+3);
                W8 = reshape(W7, [1 49]);
                W9 = sort(W8);
                A5 = I2(i, j) - W9(1);
                A6 = I2(i, j) - W9(49);
                if A5 == 0 || A6 == 0
                    I2(i, j) = W9(25);
                end
            end
        end
    end
end

% Convert filtered image back to uint8
final_image = uint8(I2(4:rows-3, 4:cols-3));

% Display the final filtered image
figure, imshow(final_image), title("Filtered Image");

% Calculate MSE and PSNR
E = double(final_image) - double(I1(4:rows-3, 4:cols-3));
mse = sum(sum(E.^2)) / ((rows-6) * (cols-6));
PSNR = 10 * log10(255^2 / mse);

% Display MSE and PSNR
disp(['MSE: ', num2str(mse)]);
disp(['PSNR: ', num2str(PSNR)]);

% Plot MSE and PSNR
%figure, plot(1, mse, 'o'), title("MSE"), xlabel("Iteration"), ylabel("MSE");
%figure, plot(1, PSNR, 'o'), title("PSNR"), xlabel("Iteration"), ylabel("PSNR");
