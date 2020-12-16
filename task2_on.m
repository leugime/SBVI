close all;

gt = load('ground_truth.mat');
gt = gt.ground_truth_store;
nb_imgs = length(gt);

for nb = 4:21
   
    im_name = gt(nb).file;
    im = imread (im_name);
    
    %Imagens de uma cara
    size = gt(nb).ground_truth;
    im_face = im(size(1):size(2), size(3):size(4));
    im_face = imresize(im_face,[640 480]);
    
    %CENAS PARA OS OLHOS
    im_eye = imadjust(im_face);    
    level = graythresh(im_eye);
    im_eye = imbinarize(im_eye, level);   

    im_eye = imdilate (im_eye, ones (5,5));

    im_eye = bwareaopen(im_eye, 4);
    se = strel('disk',8);
    im_eye = imclose(im_eye,se);
    
    im_eye = bwmorph(im_eye, 'remove',10);
    
    %CENAS PARA AS NARINAS
    im_nose = adapthisteq(im_face,'NumTiles',[8 8],'ClipLimit',0.0001);   
    level = graythresh(im_nose);
    im_nose = imbinarize(im_nose, level);   

    im_nose = imdilate (im_nose, ones (8,8));

    
    im_nose = bwmorph(im_nose, 'remove',10);
    figure, imshow (im_nose);

    %ENCONTRAR CIRCULOS E ISSO DOS OLHOS
    s_o = regionprops('table',im_eye,'Centroid','MajorAxisLength','MinorAxisLength');
    centers_o = s_o.Centroid;
    diameters_o = mean([s_o.MajorAxisLength s_o.MinorAxisLength],2);
    radii_o = diameters_o/2;
 
    figure, imshow (im_face);
    hold on
    
    eye = zeros(1,1);
    cont = 1;
    for nb_o = 1:length(radii_o)
        %DESCOBRE OS OLHINHOS
        if (centers_o (nb_o ,2) < 230) && (centers_o (nb_o ,2) > 90)
            if (radii_o(nb_o) < 70) && (radii_o(nb_o) > 11)
                
                c1 = centers_o (nb_o);
                c2 = centers_o (nb_o,2);
                c = [c1, c2];
                viscircles(c, radii_o(nb_o));
                
                eye(cont) = nb_o;
                cont = cont+1;
            end
        end    
    end
    
    %ENCONTRAR CIRCULOS E ISSO DAS NARINAS
    s_n = regionprops('table',im_nose,'Centroid','MajorAxisLength','MinorAxisLength');
    centers_n = s_n.Centroid;
    diameters_n = mean([s_n.MajorAxisLength s_n.MinorAxisLength],2);
    radii_n = diameters_n/2;
    
    nose = zeros(1,1);
    cont = 1;
    for nb_n = 1:length(radii_n)
        %DESCOBRE AS NHANHAS
        if (centers_n (nb_n ,2) < 350) && (centers_n (nb_n ,2) > 270)
            if (radii_n(nb_n) < 30) && (radii_n(nb_n) > 1)
                
                c1 = centers_n (nb_n);
                c2 = centers_n (nb_n,2);
                c = [c1, c2];
                viscircles(c, radii_n (nb_n));
                
                nose(cont, 1) = nb_n;
                cont = cont+1;
            end
        end    
    end 
    hold off
    
    %VE SE O CABRAO ESTA COM A MASCARA DIREITA
    cont = 1;
    mask_good = true;
    
    if length (eye) == 2
        if centers_o (eye(1), 1) > centers_o (eye(2), 1)
            eye_e = centers_o (eye(2), 1);
            eye_d = centers_o (eye(1), 1);
        else
            eye_e = centers_o (eye(1), 1);
            eye_d = centers_o (eye(2), 1);
        end
        
        
        while (cont <= length (nose)) && (mask_good == true) && (nose(1) > 0)
            if  (centers_n (nose(cont),1) > eye_e) && (centers_n (nose(cont),1) < eye_d)
                mask_good = false;
            end
            cont = cont +1;
        end
    
    elseif length (eye) == 1
        if centers_o (eye(1), 1) > 240
            eye_e = centers_o (eye(1), 1);
        else
            eye_d = centers_o (eye(1), 1);
        end
        
        while (cont <= length (nose)) && (mask_good == true) && (nose(1) > 0)
            if  centers_n (nose(cont),1) > eye_e
                mask_good = false;
            elseif  centers_n (nose(cont),1) < eye_d
                mask_good = false;        
            end
            cont = cont+1;
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
        
        while (cont <= length (nose)) && (mask_good == true) && (nose(1) > 0)
            if  (centers_n (nose(cont),1) > eye_e) && (centers_n (nose(cont),1) < eye_d)
                mask_good = false;
            end
            cont = cont +1;
        end
    end
    
    display (mask_good);
end


