clc;
clear;
% This program performs task 5 of the phase 3. 
%converting into a format we require.
system('Formatting.pl');
%importing data
Z=importdata('Output.txt');
Message='Enter the no of Layers(L) = ';
%taking input of the number of layers
L=input(Message);
L=int64(L);
%taking input of the number of buckets. 
Message='Enter (no of bits for Hashing) or buckets per layer in terms of exp(K) :-';
K=input(Message);
K=int64(K);
Answer=[];
%Answer=zeros(L*size(Z,1),7);
FILE= fopen('Result.txt','w');
fprintf(FILE,'{layer_num,bucket_num,<i;j;l;x;y>}\r\n');

Count =0;%TEST
for i=1:L
    ANS=zeros(size(Z,1),K + 5);
    ANS(:,1:5)=Z(:,1:5);
    for j=1:K
        %generating a random equation of the hyperplane. 
        Equation= -100 + rand(1,size(Z,2)-4).*200; 
        % taking a point with all zeros
        Point=zeros(1,size(Equation,2)-1);
        % taking a point which lies in the hyperplane. 
        Point(1,end)= -(Equation(1,end)/(Equation(1,end-1)));
        for k=1:size(Z,1)
            %calculating the dot product. 
            DOT=dot(Equation(1,1:end-1),(Z(k,6:end)-Point));
            if(DOT >= 0)
                ANS(k,5+j)=1;
            end
        end
    end
    Answer=[Answer; ones(size(ANS,1),1).*double(i) ANS(:,:)];
end

for i=1:size(Answer,1)
    %converting the matrix to string. 
    a=mat2str(Answer(i,7:end));
    a(ismember(a,' []')) = [];
    % storing the output in the file. 
    fprintf(FILE,'{%d,%s,<%d,%d,%d,%f,%f>}\r\n',Answer(i,1),a,Answer(i,2),Answer(i,3),Answer(i,4),Answer(i,5),Answer(i,6));
end
