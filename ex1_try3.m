close all
clear
clc

imRGB = imread("32.png");
iminput = im2double(imRGB);
imHSV = rgb2hsv(imRGB);
imYCbCr = rgb2ycbcr(imRGB);
imCopy=imRGB;
imgray=rgb2gray(imRGB);
[ro, co, ch] = size(imRGB);
Ravg = mean(mean(imRGB(:,:,1)));
Gavg = mean(mean(imRGB(:,:,2)));
Bavg = mean(mean(imRGB(:,:,3)));
Tavg = (Ravg+Gavg+Bavg)/3;



figure(1);
imshow(imRGB);
for i=1:ro
    for j=1:co
        R = imRGB(i, j, 1);
        G = imRGB(i, j, 2);
        B = imRGB(i, j, 3);
        H = imHSV(i, j, 1);
        S = imHSV(i, j, 2);
        I = (R+G+B)/3;  
        lum = imYCbCr(i, j, 1);
        Cb = imYCbCr(i, j, 2);
        Cr = imYCbCr(i, j, 3);
        %&& ~(B<65 && G<65 && R<145)
        if (R>95) && (G>40) && (B>20) && (R>G) && (R>B) && ((abs(R-G))>15) && (R-G<130) && (R-B<150)
            if(0<=H) &&(H<=50) &&(0.23<=S) &&(S<=0.68)
            elseif(Cr>130) && (Cr<175) &&(Cb>100) && (Cb<135) && (lum>80)
            else
                imRGB(i,j,1) = 0;
                imRGB(i,j,2) = 0;
                imRGB(i,j,3) = 0;
            end
        else
            imRGB(i,j,1) = 0;
            imRGB(i,j,2) = 0;
            imRGB(i,j,3) = 0;
        end
    end
end
se = strel('diamond',1);
s2 = strel('disk',1);

%imtool(imRGB);
imedge = rgb2gray(imRGB);
figure(2);
imshow(imedge);
imedge = imopen(imedge, s2);
imedge = imopen(imedge, se);
figure(3);
imshow(imedge);

imedge = edge(imedge,'Canny', [0.18 0.22]);
figure(4)
imshow(imedge);
imedge2 = imdilate(imedge, se);
imskel = imedge2 - imedge;

figure(6);
imshow(imskel);


imedge = imclose(imskel, se);
figure(7);
imshow(imedge);
imedgelog = logical(imedge);

imedge = bwareafilt(imedgelog,[100 10000000000]);
%imedge = bwmorph(imedge, 'skel');


figure(9);
imshow(imedge);

se = strel('disk',8);
% BW1 = medfilt2(imdilate(imedge, se));
BW1 = medfilt2(imedge);
BW1 = imfill(BW1, 'holes');
se = strel('disk',8);
BW1 = imerode(BW1, se);
figure(10)
imshow(BW1,[])

labelImg     = bwlabel( BW1, 4 );
possibleROIs = regionprops(labelImg, ...
            'BoundingBox','Centroid','Extent','Eccentricity','ConvexArea','Area');
size_posbROI = size( possibleROIs );
size_posbROI = size_posbROI(1,1);
BoundBoxes   = zeros( size_posbROI, 4 );
for j = 1 : size_posbROI 
    BoundBoxes(j, 1:4) = [ possibleROIs(j).BoundingBox(1,1), ...
                               possibleROIs(j).BoundingBox(1,2), ...
                               possibleROIs(j).BoundingBox(1,3), ...
                               possibleROIs(j).BoundingBox(1,4), ...
                              ];
end
Area_ConvexArea   = zeros( size_posbROI, 2 );
for j = 1 : size_posbROI 
    Area_ConvexArea(j, 1:2) = [ possibleROIs(j).Area, ...
                               possibleROIs(j).ConvexArea
                              ];
end

figure(11)
imshow(iminput);

for j = 1 : length(possibleROIs) 
    nrois = size(possibleROIs, 1);
%     if(nrois > 10)
        if(possibleROIs(j).Area > 3000)
            thisBB = possibleROIs(j).BoundingBox;
            rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
            'FaceColor', [1, 0, 0, 0.3], 'EdgeColor','r','LineWidth',2 )
        end
%     end
%     if(nrois <= 10)
%         if(possibleROIs(j).Area > 30000)
%             thisBB = possibleROIs(j).BoundingBox;
%             rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
%             'FaceColor', [1, 0, 0, 0.3], 'EdgeColor','r','LineWidth',2 )
%         end
%     end

end