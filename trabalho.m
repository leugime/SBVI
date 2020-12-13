clc; close all;
% RGB = im2double(imread('25.png'));
% figure
% imshow(RGB,[])
% BW = rgb2gray(RGB);
% % level = multithresh(BW);
% seg_I = imquantize(BW,0.3);
% figure
% imshow(BW-seg_I,[])
% [BW1,threshOut1] = edge(seg_I, 'Sobel');
% figure
% imshow(BW1,[])

% read the original image
I = im2double(imread('21.png'));
% call createMask function to get the mask and the filtered image
[BW,maskedRGBImage] = createMask(I);
% plot the original image, mask and filtered image all in one figure
subplot(1,3,1);imshow(I);title('Original Image');
subplot(1,3,2);imshow(BW);title('Mask');
subplot(1,3,3);imshow(maskedRGBImage);title('Filtered Image');

BW = rgb2gray(maskedRGBImage);
seg_I = imquantize(BW,0.3);
se = strel('disk',2);
figure
imshow(BW-seg_I,[])
[BW1,threshOut1] = edge(seg_I, 'canny');
BW1 = imfill(imdilate(BW1, se), 'holes');
figure
imshow(BW1,[])

function [BW,maskedRGBImage] = createMask(RGB) 
% Convert RGB image to HSV image
I = rgb2hsv(RGB);
% Define thresholds for 'Hue'. Modify these values to filter out different range of colors.
channel1Min = 0.9;
channel1Max = 0.1;
% Define thresholds for 'Saturation'
channel2Min = 0.000;
channel2Max = 1.000;
% Define thresholds for 'Value'
channel3Min = 0.000;
channel3Max = 1.000;
% Create mask based on chosen histogram thresholds
BW = ( (I(:,:,1) >= channel1Min) | (I(:,:,1) <= channel1Max) ) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
% Initialize output masked image based on input image.
maskedRGBImage = RGB;
% Set background pixels where BW is false to zero.
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;
end