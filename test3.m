
close all;
sem=0;
com=0;
no_y=0;
no_n=0;
vet=[];
mat_yes=[,];
for cont=3:3
    x=getfield(ground_truth_store,{cont},'ground_truth');
    y=getfield(ground_truth_store,{cont},'file');

    test=imread(y);
        %figure,imshow(test);
    [l,c]=size(x);
    
    ini = rgb2gray(test);
    test = rgb2gray(test);
        %figure,imshow(test);
    
     if l>1
       %test = medfilt2(test);
       %test= imadjust(test,[],[0,0.9],1);
       test = histeq(test);
       test = medfilt2(test);
     end
     %figure,imshow(test);
     
     
     %test = imclearborder(test);
%     [rows, columns, numberOfColorChannels] = size(test);
%     [counts,binlocations] = imhist(imcrop(test, [round((1/6)*columns) (rows/2) round((4/6)*columns) (rows/2)]));
%     if (max(counts) > 20*mean(counts)) 
%             test = histeq(test);
%     end
    
    
    %valor anterior 190
    %cito1=imbinarize(test,206/255);
        %figure,imshow(cito1);
    %valor anterior 40
    %cito2=imbinarize(test,20/255);
        %figure,imshow(cito2);
    one=1;
    for i=1:l
        %->preto
        %i
        test1=test(x(i,1):x(i,2),x(i,3):x(i,4));
        
        media=(x(i,2)-x(i,1))*(x(i,4)-x(i,3));
        media1=median(test1(:));
        %figure,imshow(imresize(test(x(i,1):x(i,2),x(i,3):x(i,4)),[440,336]));
             if media<450 && 125>media1<210
               %test1 = medfilt2(test1);
               test1= imadjust(test1,[],[0,0.9],1);
               %test1 = histeq(test1);
               
             end
             
             if media<450 && media1<125
               %test1 = medfilt2(test1);
               test1= imadjust(test1,[0.2,1],[0,1],6);
               %test1 = histeq(test1);
               
             end
             %figure,imshow(test1)
            %figure,imshow(imresize(test1,[440,336]));
        test1=imbinarize(test1,206/255);
            %figure,imshow(imresize(test1(x(i,1):x(i,2),x(i,3):x(i,4)),[440,336]));
            
        test2=imresize(test1,[440,336]);
        %test2=imbinarize(test2,206/255);
        %figure,imshow(test2);
        
        %test2=imerode(test2,ones(2,2));
        %figure,imshow(test2);    
        %cito1_2 = bwareaopen(cito1_2,30);
        %test2=imfill(test2);
        %test2 = bwmorph(test2,'majority');
        cito1_2 = imclose(test2, strel('rectangle',[3,6]));
        %cito1_2 = imdilate(cito1_2,ones(3,3));
        %cito1_2 = bwareaopen(cito1_2,30);
            %figure,imshow(cito1_2);
        
        %->branco
        
        test1=test(x(i,1):x(i,2),x(i,3):x(i,4));
        
             if media<450 && 125>media1<210
               %test1 = medfilt2(test1);
               test1= imadjust(test1,[],[0,0.9],1);
               %test1 = histeq(test1);
               
             end
             
             if media<450 && media1<125
               %test1 = medfilt2(test1);
               test1= imadjust(test1,[0.2,1],[0,1],6);
               %test1 = histeq(test1);
               
             end
        
        
        test1=imbinarize(test1,20/255);
            %figure,imshow(imresize(test(x(i,1):x(i,2),x(i,3):x(i,4)),[440,336]));
            
        test2=imresize(test1,[440,336]);
        %test2=imbinarize(test2,20/255);
        
        %figure,imshow(test2);
        %test2 = bwareaopen(test2,30);
        %test2=imerode(test2,ones(2,2));
        %test2=imfill(test2);
        %test2 = bwmorph(test2,'majority');
        cito2_2 = imclose(test2, strel('rectangle',[3,6]));
        %cito2_2 = imdilate(cito2_2,ones(3,3));
            %figure,imshow(cito2_2);
        
        t=(440*336);
        %cito2=imresize(cito1_2,[440*3/4,336]);
        %cito2=imresize(cito2_2,[440*3/4,336]);
        %cito1_2=cito1_2(440*1/4:440,1:336);
        %cito2_2=cito2_2(440*1/4:440,1:336);
%         figure,imshow(cito1_2);
%         figure,imshow(cito2_2);
        np=(440*336)-sum(cito1_2(:));
        nb=sum(cito2_2(:));
        
        r=abs(nb-np);
        %t*1/8
        if (r<9000) || (r==147840) || (r==0)
            s=0;
            sem=sem+1;
        else
            s=1;
            com=com+1;
        end
        
        str=getfield(ground_truth_store,{cont},'mask');
        
        if (s==0 && 1==strcmp(str(i),'without_mask') )|| (s==1 && 0==strcmp(str(i),'without_mask'))
           sf='yes';
           no_y=no_y+1;
           %[mat_l,mat_c]=size(mat_yes);
           if s==1 && 0==strcmp(str(i),'without_mask')
               %linhas nº da imagem | colunas nº da cara na imagem 
                mat_yes(cont,i)=1;
                ini=ini(x(i,1):x(i,2),x(i,3):x(i,4));
                tenente=imresize(ini,[440,336]);
                figure,imshow(tenente);
                
                
                %figure,imshow(tenente);
           end
           
           
        else
           sf='nop';
           i;
           no_n=no_n+1;
           vet(no_n)=cont;
        end
        

        
    end
        
end
sem
com
no_y
no_n
vet