clc;
clear all;
close all;
covimg=rgb2gray(imread('E:\M Tech\Semester 2\Multimedia Security\Mini Project\lena.jpg'));
covimg=imresize(covimg,[504 504]); 

N=3;
e=1;
P=N+e;
%%%%%%%%%%%%%%DCT Type II
% for n=0:N-1
%     for k=0:N-1
%         if(k==0)
%             A(k+1,n+1)= (sqrt(1/N))*cos((pi*(n+0.5)*(k))/P);
%         else
%             A(k+1,n+1)= (sqrt(2/N))*cos((pi*(n+0.5)*(k))/P);
%         end
%     end
% end
%%%%%%%%%%%%%%%%DCT Type IV
for n=0:N-1
    for k=0:N-1
            A(k+1,n+1)= (sqrt(2/N))*cos((pi*(n+0.5)*(k+0.5))/P);
    end
 end
[V,D] = eig(A);
noi=10;
alpha=V*(D^(4))*(V');
beta=V*(D^(-4))*(V');
G=kron(alpha,alpha);
invG=kron(beta,beta);
blocksize=9;

for noi=1:10
	wmark=9*randn(1,7000);
	b=randperm(47040);
	c=b(1:7000);
	n=1;
	for y=1:56
		for z=1:56
            imgblock=covimg(((y-1)*blocksize)+1:((y*blocksize)),((z-1)*blocksize)+1:((z*blocksize)));
            mpdctblock=G*double(imgblock)*G';
            
            vect=mpdctblock(:);          
            for k=2:81
                vect1(k-1)=vect(k);
            end
            [val, ix] = sort(((vect1)),'descend');
			for l=11:25
				reqcoeff(n)=val(l);
				n=n+1;
			end
        end
    end

	for i=1:7000
		reqcoeff(c(i))=reqcoeff(c(i))+wmark(i);
	end

	n=1;
	for y=1:56
		for z=1:56
			imgblock=covimg(((y-1)*blocksize)+1:((y*blocksize)),((z-1)*blocksize)+1:((z*blocksize)));
			mpdctblock=G*double(imgblock)*G';
			vect=mpdctblock(:);          
			for k=2:81
				vect1(k-1)=vect(k);
			end
			[val, ix] = sort(((vect1)),'descend');
			for l=11:25
				val(l)=reqcoeff(n);
				n=n+1;
			end
			vect1(ix)=val;
			for k=2:81
				vect(k)=vect1(k-1);
			end
			mpdctblock(:)=vect;          
			recimg(((y-1)*blocksize)+1:((y*blocksize)),((z-1)*blocksize)+1:((z*blocksize)))=uint8(floor(invG*double(mpdctblock)*invG'));
		end
	end
	str = int2str(noi);
	str = strcat('E:\M Tech\Semester 4\Hybrid Images\',str,'.bmp');
	imwrite(uint8(recimg),str,'BMP');
end
figure;
imshow(covimg);
title('original image');
figure;
imshow(uint8(recimg));
title('Watermarked image');