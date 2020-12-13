close all
clear
clc

InputImg = imread( '4.png');
InputImg = im2double( InputImg );

figure(1)
hold on
title( sprintf('Imagem Original') )
imshow( InputImg )
hold off

size_mask = 7;
sigma = 1;
ImgGauss(:,:,1) = adapthisteq( InputImg(:,:,1), 'ClipLimit', 0.005, 'NumTiles', [4 4] );
ImgGauss(:,:,2) = adapthisteq( InputImg(:,:,2), 'ClipLimit', 0.005, 'NumTiles', [4 4] );
ImgGauss(:,:,3) = adapthisteq( InputImg(:,:,3), 'ClipLimit', 0.005, 'NumTiles', [4 4] );

ImgGauss(:,:,1) = imgaussfilt( ImgGauss(:,:,1), sigma, 'FilterSize', size_mask );
ImgGauss(:,:,2) = imgaussfilt( ImgGauss(:,:,2), sigma, 'FilterSize', size_mask );
ImgGauss(:,:,3) = imgaussfilt( ImgGauss(:,:,3), sigma, 'FilterSize', size_mask );

figure(2)
hold on
imshowpair( InputImg, ImgGauss, 'montage' )
title( 'Comparação entre a imagem original e a pré-processada' )
hold off

Img_CompRed    = ImgGauss(:,:,1) -  ImgGauss(:,:,2);
Img_CompBlue   = ImgGauss(:,:,3) -  ImgGauss(:,:,2);
Img_CompYellow = ImgGauss(:,:,1) .* ImgGauss(:,:,2);

figure(3)
subplot(1,3,1)
hold on
title( sprintf('Componente Vermelha') )
imshow( Img_CompRed )
hold off
subplot(1,3,2)
hold on
title( sprintf('Componente Azul') )
imshow( Img_CompBlue )
hold off
subplot(1,3,3)
hold on
title( sprintf('Componenete Amarela') )
imshow( Img_CompYellow )
hold off

thresholdRedLow     = 0.1;
thresholdRedHigh    = 0.3;
binaryImg_red       = ...
    ( Img_CompRed >= thresholdRedLow  ) & ...
    ( Img_CompRed <= thresholdRedHigh );
binaryImg_red       = bwpropfilt( binaryImg_red, 'Area', [200 12000] );

thresholdBlueLow    = 0.1500;
thresholdBlueHigh   = 0.3200;
binaryImg_blue      = ...
    ( Img_CompBlue >= thresholdBlueLow  ) & ...
    ( Img_CompBlue <= thresholdBlueHigh );
binaryImg_blue      = bwpropfilt( binaryImg_blue, 'Area', [200 12000] );

thresholdYellowLow  = 0.5;
thresholdYellowHigh = 0.8;
binaryImg_yellow    = ...
    ( Img_CompYellow >= thresholdYellowLow  ) & ...
    ( Img_CompYellow <= thresholdYellowHigh );
binaryImg_yellow      = bwpropfilt( binaryImg_yellow, 'Area', [200 12000] );

figure(4)
subplot(1,3,1)
hold on
title( sprintf('Componente Vermelha Binarizada') )
imshow( binaryImg_red )
hold off
subplot(1,3,2)
hold on
title( sprintf('Componente Azul Binarizada') )
imshow( binaryImg_blue )
hold off
subplot(1,3,3)
hold on
title( sprintf('Componenete Amarela Binarizada') )
imshow( binaryImg_yellow )
hold off

filtImgMedian_red = medfilt2( imdilate( binaryImg_red, strel('disk', 2) ) );
filtImgMedian_blue = medfilt2( imdilate( binaryImg_blue, strel('disk', 2) ) );
filtImgMedian_yellow = medfilt2( imdilate( binaryImg_yellow, strel('disk', 2) ) );

figure(5)
subplot(1,3,1)
hold on
title( sprintf('Imagem Filtrada com Mediana - Sinais Vermelhos') )
imshow( filtImgMedian_red )
hold off
subplot(1,3,2)
hold on
title( sprintf('Imagem Filtrada com Mediana - Sinais Azuis') )
imshow( filtImgMedian_blue )
hold off
subplot(1,3,3)
hold on
title( sprintf('Imagem Filtrada com Mediana - Sinais Amarelos') )
imshow( filtImgMedian_yellow )
hold off

weightSmallObjArea  = 0.001;

smallObjArea_red    = size( find( filtImgMedian_red ) );
smallObjArea_red    = smallObjArea_red(1,1);
smallObjArea_red    = round( smallObjArea_red * weightSmallObjArea );
ImgCanny_Red = bwareaopen( filtImgMedian_red, smallObjArea_red );
ImgCanny_Red = edge( ImgCanny_Red, 'Canny' ); 
ImgCanny_Red = imfill( ImgCanny_Red, 'holes' );

smallObjArea_blue   = size( find( filtImgMedian_blue ) );
smallObjArea_blue   = smallObjArea_blue(1,1);
smallObjArea_blue   = round( smallObjArea_blue * weightSmallObjArea );
ImgCanny_Blue = bwareaopen( filtImgMedian_blue, smallObjArea_blue );
ImgCanny_Blue = edge( ImgCanny_Blue, 'Canny' );
ImgCanny_Blue = imfill( ImgCanny_Blue, 'holes' );

smallObjArea_yellow = size( find( filtImgMedian_yellow ) );
smallObjArea_yellow = smallObjArea_yellow(1,1);
smallObjArea_yellow = round( smallObjArea_yellow * weightSmallObjArea );
ImgCanny_Yellow = bwareaopen( filtImgMedian_yellow, smallObjArea_yellow );
ImgCanny_Yellow = edge( ImgCanny_Yellow, 'Canny' );
ImgCanny_Yellow = imfill( ImgCanny_Yellow, 'holes' );

figure(6)
subplot(2,3,1)
hold on
title( sprintf('Imagem Filtrada com Mediana - Sinais Vermelhos') )
imshow( filtImgMedian_red )
hold off
subplot(2,3,2)
hold on
title( sprintf('Imagem Filtrada com Mediana - Sinais Azuis') )
imshow( filtImgMedian_blue )
hold off
subplot(2,3,3)
hold on
title( sprintf('Imagem Filtrada com Mediana - Sinais Amarelos') )
imshow( filtImgMedian_yellow )
hold off
subplot(2,3,4)
hold on
title( sprintf('Imagem Segmentação Canny - Sinais Vermelhos') )
imshow( ImgCanny_Red )
hold off
subplot(2,3,5)
hold on
title( sprintf('Imagem Segmentação Canny - Sinais Azuis') )
imshow( ImgCanny_Blue )
hold off
subplot(2,3,6)
hold on
title( sprintf('Imagem Segmentação Canny - Sinais Amarelos') )
imshow( ImgCanny_Yellow )
hold off

ImgCanny_Red    = imerode( imclose( ImgCanny_Red, strel( 'disk', 5 ) ), strel( 'disk', 2 ) );
ImgCanny_Red    = bwpropfilt( ImgCanny_Red, 'Area', [300 15000] );
ImgCanny_Blue   = imerode( imclose( ImgCanny_Blue, strel( 'disk', 5 ) ), strel( 'disk', 2 ) );
ImgCanny_Blue   = bwpropfilt( ImgCanny_Blue, 'Area', [300 15000] );
ImgCanny_Yellow = imerode( imclose( ImgCanny_Yellow, strel( 'disk', 5 ) ), strel( 'disk', 2 ) );
ImgCanny_Yellow = bwpropfilt( ImgCanny_Yellow, 'Area', [300 15000] );

figure(7)
subplot(1,3,1)
hold on
title( sprintf('Imagem Segmentação Canny (restrição Área) - Sinais Vermelhos') )
imshow( ImgCanny_Red )
hold off
subplot(1,3,2)
hold on
title( sprintf('Imagem Segmentação Canny (restrição Área) - Sinais Azuis') )
imshow( ImgCanny_Blue )
hold off
subplot(1,3,3)
hold on
title( sprintf('Imagem Segmentação Canny (restrição Área) - Sinais Amarelos') )
imshow( ImgCanny_Yellow )
hold off

Relat_LenX_LenY_MIN = 0.80;
Relat_LenX_LenY_MAX = 1.20;
Relat_Area_ConvexArea_MIN = 0.85;

                  
ImgCanny_Red    = bwpropfilt( ImgCanny_Red, 'Eccentricity', [0 0.5] ) & ...
                  bwpropfilt( ImgCanny_Red, 'Extent', [0.65 0.81] );
              
                  bwpropfilt( ImgCanny_Red, 'Eccentricity', [0 0.5] ) & ...
                  bwpropfilt( ImgCanny_Red, 'Extent', [0.35 0.65] );
                
ImgCanny_Blue   = bwpropfilt( ImgCanny_Blue, 'Eccentricity', [0 0.5] ) & ...
                  bwpropfilt( ImgCanny_Blue, 'Extent', [0.5 0.81] );
                 
ImgCanny_Yellow = bwpropfilt( ImgCanny_Yellow, 'Eccentricity', [0 0.4] ) & ...
                  bwpropfilt( ImgCanny_Yellow, 'Extent', [0.43 0.57] );

% ImgFiltradaFinal = ImgCanny_Red | ImgCanny_Blue | ImgCanny_Yellow;
ImgFiltradaFinal = ImgCanny_Red | ImgCanny_Yellow;

figure(8)
hold on
title( sprintf('Imagem Binarizada Final Filtrada por propriedades') )
imshow( ImgFiltradaFinal )
hold off

labelImg     = bwlabel( ImgFiltradaFinal, 4 );
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
Relat_LenXLenY_AreaConvexArea = [ BoundBoxes(:,3)./BoundBoxes(:,4) ...
    Area_ConvexArea(:,1)./Area_ConvexArea(:,2) ];
idx_ROIs = find( Relat_LenXLenY_AreaConvexArea(:,1) > Relat_LenX_LenY_MIN & ...
    Relat_LenXLenY_AreaConvexArea(:,1) < Relat_LenX_LenY_MAX & ... 
    Relat_LenXLenY_AreaConvexArea(:,2) > Relat_Area_ConvexArea_MIN);
number_ROIs   = size( idx_ROIs );
number_ROIs   = number_ROIs( 1,1 );
InputImg_ROIs = InputImg;
if number_ROIs > 0
    BoundBoxes        = floor( BoundBoxes );
    BoundBoxes(:,1:2) = BoundBoxes(:,1:2) + ( BoundBoxes(:,1:2) == 0 );
    % Passagem das ROIs encontradas para uma variável independente
    for j = 1 : number_ROIs
        InputImg_ROIs( BoundBoxes( idx_ROIs(j,1) ,2):BoundBoxes( idx_ROIs(j,1) ,2)+BoundBoxes( idx_ROIs(j,1) ,4), ...
            BoundBoxes( idx_ROIs(j,1) ,1):BoundBoxes( idx_ROIs(j,1) ,1)+BoundBoxes( idx_ROIs(j,1) ,3), 2) =       ...
                InputImg_ROIs( BoundBoxes( idx_ROIs(j,1) ,2):BoundBoxes( idx_ROIs(j,1) ,2)+BoundBoxes( idx_ROIs(j,1) ,4), ...
                BoundBoxes( idx_ROIs(j,1) ,1):BoundBoxes( idx_ROIs(j,1) ,1)+BoundBoxes( idx_ROIs(j,1) ,3), 2) +           ...
                0.8;
        InputImg_ROIs( BoundBoxes( idx_ROIs(j,1) ,2):BoundBoxes( idx_ROIs(j,1) ,2)+BoundBoxes( idx_ROIs(j,1) ,4), ...
            BoundBoxes( idx_ROIs(j,1) ,1):BoundBoxes( idx_ROIs(j,1) ,1)+BoundBoxes( idx_ROIs(j,1) ,3), 1) =       ...
                InputImg_ROIs( BoundBoxes( idx_ROIs(j,1) ,2):BoundBoxes( idx_ROIs(j,1) ,2)+BoundBoxes( idx_ROIs(j,1) ,4), ...
                BoundBoxes( idx_ROIs(j,1) ,1):BoundBoxes( idx_ROIs(j,1) ,1)+BoundBoxes( idx_ROIs(j,1) ,3), 1) -           ...
                0.5;
        InputImg_ROIs( BoundBoxes( idx_ROIs(j,1) ,2):BoundBoxes( idx_ROIs(j,1) ,2)+BoundBoxes( idx_ROIs(j,1) ,4), ...
            BoundBoxes( idx_ROIs(j,1) ,1):BoundBoxes( idx_ROIs(j,1) ,1)+BoundBoxes( idx_ROIs(j,1) ,3), 3) =       ...
                InputImg_ROIs( BoundBoxes( idx_ROIs(j,1) ,2):BoundBoxes( idx_ROIs(j,1) ,2)+BoundBoxes( idx_ROIs(j,1) ,4), ...
                BoundBoxes( idx_ROIs(j,1) ,1):BoundBoxes( idx_ROIs(j,1) ,1)+BoundBoxes( idx_ROIs(j,1) ,3), 3) -           ...
                0.5;
    end
end

figure(9)
imshow(InputImg_ROIs);