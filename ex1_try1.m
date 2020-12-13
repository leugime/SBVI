imRGB = imread("5.png");
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
