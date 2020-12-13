
%->escolhe a imagem a ser lida 
x=getfield(ground_truth_store,{10},'ground_truth');
y=getfield(ground_truth_store,{10},'file');

%->le a imagem
test=imread(y);
figure(1),imshow(test);

%->converçao para escalas de cinza
test = rgb2gray(test);
figure(2),imshow(test);

%test2=imread('1_gt_visualization_do_not_use_for_evaluation.png');
%figure(2),imshow(test2);

%-> seleciona a cara 
test3=test(x(1):x(2),x(3):x(4));



%-> redimenciona a imagem da cara 
%z=4;
%resize=imresize(test3,[(x(2)-x(1))*z,(x(4)-x(3))*z]);

resize=imresize(test3,[440,336]);
figure(3),imshow(resize);

%test4=imopen(test3,ones(10,10));

%tres=multithresh(resize,1);

%cito1=imquantize(resize,tres);
tres=graythresh (resize);
%display(tres);
cito1=imbinarize(resize,tres);
figure(5),imshow(cito1);

cito1 = imclose(cito1, ones(49, 49));
%cito1 = imfill(cito1, 'holes');

figure(6),imshow(cito1);

% stat = regionprops(cito1,'Area', 'BoundingBox', 'Centroid', 'PixelList');
%     figure(7),imshow(cito1); hold on;
%     for cnt = 1 : numel(stat)
%         bb = stat(cnt).BoundingBox;
%         rectangle('position',bb,'edgecolor','r','linewidth',2);
%     end
% 

%-> passa a imagem para binario  
%test4=imbinarize(test3);
%test4=imbinarize(resize,'adaptive','ForegroundPolarity','bright','Sensitivity',0.5);;

% test4 = edge(resize, 'Canny', [0.15 0.37]);
% figure(4),imshow(test4);
% 


