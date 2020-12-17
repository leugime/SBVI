close all;
correct = 0;
incorrect = 0;
m1=0;
m2=0;
sem=0;
com=0;
no_y=0;
no_n=0;
vet=[];
mat_yes=[,];
%PARTE I   -   DESCOBRE SE TEM MASCARA OU NAO
for cont=1:30
    x=getfield(ground_truth_store,{cont},'ground_truth');
    y=getfield(ground_truth_store,{cont},'file');
    
    test=imread(y);
    ini=imread(y);
    [l,c]=size(x);
    
    test = rgb2gray(test);
    
     if l>1
       test = histeq(test);
       test = medfilt2(test);
     end

    one=1;
    for i=1:l
        test1=test(x(i,1):x(i,2),x(i,3):x(i,4));
        
        media=(x(i,2)-x(i,1))*(x(i,4)-x(i,3));
        media1=median(test1(:));

             if media<450 && 125>media1<210
               test1= imadjust(test1,[],[0,0.9],1);
               
             end
             
             if media<450 && media1<125
               test1= imadjust(test1,[0.2,1],[0,1],6);
               
             end

        test1=imbinarize(test1,206/255);
            
        test2=imresize(test1,[440,336]);

        cito1_2 = imclose(test2, strel('rectangle',[3,6]));
        
        %->branco
        
        test1=test(x(i,1):x(i,2),x(i,3):x(i,4));
        
             if media<450 && 125>media1<210
               test1= imadjust(test1,[],[0,0.9],1);
               
             end
             
             if media<450 && media1<125
               test1= imadjust(test1,[0.2,1],[0,1],6);               
             end
        
        
        test1=imbinarize(test1,20/255);
            
        test2=imresize(test1,[440,336]);

        cito2_2 = imclose(test2, strel('rectangle',[3,6]));
        
        t=(440*336);

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
                
                %PARTE II   -   DESCOBRE SE A MASCARA ESTA BEM OU NAO
                ini1=ini(x(i,1):x(i,2),x(i,3):x(i,4));
                im_face = imresize(ini1,[640 480]);
                
                %CENAS PARA OS OLHOS
                im_eye = adapthisteq(im_face,'NumTiles',[8 8],'ClipLimit',0.0001);
                
                level = graythresh(im_eye);
                im_eye = imbinarize(im_eye, level);   

                se = strel('disk',8);
                im_eye = imclose(im_eye,se);

                im_eye = bwmorph(im_eye, 'remove',10);
                

                %CENAS PARA AS NARINAS
                im_nose = adapthisteq(im_face,'NumTiles',[8 8],'ClipLimit',0.0001);
 
                level = graythresh(im_nose);
                im_nose = imbinarize(im_nose, level);   

                im_nose = imdilate (im_nose, ones (8,8));
                im_nose = bwmorph(im_nose, 'remove',10);
     

                %ENCONTRAR CIRCULOS E ISSO DOS OLHOS
                s_o = regionprops('table',im_eye,'Centroid','MajorAxisLength','MinorAxisLength');
                centers_o = s_o.Centroid;
                diameters_o = mean([s_o.MajorAxisLength s_o.MinorAxisLength],2);
                radii_o = diameters_o/2;

                %figure, imshow (im_face);
                %hold on

                eye = zeros(1,1);
                con = 1;
                for nb_o = 1:length(radii_o)
                    %DESCOBRE OS OLHINHOS
                    if (centers_o (nb_o ,2) < 230) && (centers_o (nb_o ,2) > 90)
                        if (radii_o(nb_o) < 70) && (radii_o(nb_o) > 11)

                            c1 = centers_o (nb_o);
                            c2 = centers_o (nb_o,2);
                            c = [c1, c2];
                            %viscircles(c, radii_o(nb_o));

                            eye(con) = nb_o;
                            con = con+1;
                        end
                    end    
                end

                %ENCONTRAR CIRCULOS E ISSO DAS NARINAS
                s_n = regionprops('table',im_nose,'Centroid','MajorAxisLength','MinorAxisLength');
                centers_n = s_n.Centroid;
                diameters_n = mean([s_n.MajorAxisLength s_n.MinorAxisLength],2);
                radii_n = diameters_n/2;

                nose = zeros(1,1);
                con = 1;
                for nb_n = 1:length(radii_n)
                    %DESCOBRE AS NARINAS
                    if (centers_n (nb_n ,2) < 400) && (centers_n (nb_n ,2) > 270)
                        if (radii_n(nb_n) < 40) && (radii_n(nb_n) > 1)

                            c1 = centers_n (nb_n);
                            c2 = centers_n (nb_n,2);
                            c = [c1, c2];
                            %viscircles(c, radii_n (nb_n));

                            nose(con, 1) = nb_n;
                            con = con+1;
                        end
                    end    
                end 
                %hold off

                %VE SE ESTA COM A MASCARA DIREITA
                con = 1;
                mask_good = true;

                if length (eye) == 2
                    if centers_o (eye(1), 1) > centers_o (eye(2), 1)
                        eye_e = centers_o (eye(2), 1);
                        eye_d = centers_o (eye(1), 1);
                    else
                        eye_e = centers_o (eye(1), 1);
                        eye_d = centers_o (eye(2), 1);
                    end


                    while (con <= length (nose)) && (mask_good == true) && (nose(1) > 0)
                        if  (centers_n (nose(con),1) > eye_e) && (centers_n (nose(con),1) < eye_d)
                            mask_good = false;
                        end
                        con = con +1;
                    end

                elseif (length (eye) == 1) && (eye > 0) && (centers_o (eye(1), 1) > 320) && (centers_o (eye(1), 1) < 150)
                    if centers_o (eye(1), 1) > 300
                        eye_e = centers_o (eye(1), 1);
                    elseif centers_o (eye(1), 1) < 180
                        eye_d = centers_o (eye(1), 1);
                    end

                    while (con <= length (nose)) && (mask_good == true) && (nose(1) > 0)
                        if  centers_n (nose(con),1) > eye_e
                            mask_good = false;
                        elseif  centers_n (nose(con),1) < eye_d
                            mask_good = false;        
                        end
                        con = con+1;
                    end

                elseif length (eye) > 2
                    r1=0;
                    r2=0;
                    for no = 1:length (eye)
                        if r1 == 0
                            r1 = no;
                            r2 = no+1;
                        elseif radii_o (eye(no)) > radii_o (eye(r1))
                            r2 = r1;
                            r1 = no;
                        elseif radii_o (eye(no)) > radii_o (eye(r2))
                            r2 = no;
                        end
                    end

                    if centers_o (eye(r1), 1) > centers_o (eye(r2), 1)
                        eye_e = centers_o (eye(r2), 1);
                        eye_d = centers_o (eye(r1), 1);
                    else
                        eye_e = centers_o (eye(r1), 1);
                        eye_d = centers_o (eye(r2), 1);
                    end

                    while (con <= length (nose)) && (mask_good == true) && (nose(1) > 0)
                        if  (centers_n (nose(con),1) > eye_e) && (centers_n (nose(con),1) < eye_d)
                            mask_good = false;
                        end
                        con = con +1;
                    end
                end
                
                if (mask_good == true)
                    mask = 'with_mask';
                    m1 = m1+1;
                else
                    mask = 'mask_weared_incorrect';
                    m2 = m2+1;
                end

                figure, imshow(im_face);
                title (mask);
                
                
                gt_mask = getfield(ground_truth_store,{cont},'mask');
                
                if 1 == strcmp (mask, gt_mask (i))
                    correct = correct +1;
                else
                    incorrect = incorrect +1;
                end
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
