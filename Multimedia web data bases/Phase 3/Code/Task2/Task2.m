clc
clear

%Converting Previous Task Files
system('perl Formatting_new.pl');
Z = importdata('OUTPUT.txt');

fprintf('Reading..');

fprintf('How many "K"-Similar Nodes, Enter the value of K :- ');
K=int64(input(''));



[noOfCells, information] = size(Z);


videoNumber =1 ;
A{max(Z(:,1))} = [];
for i=1:noOfCells
    if(Z(i,1) == videoNumber)
        A{videoNumber} = cat(1,A{videoNumber},Z(i,:));
    else
        videoNumber = videoNumber + 1;
        A{videoNumber} = cat(1,A{videoNumber},Z(i,:));
    end
 end
  

for i=1:size(A,2)
    for j=1:size(A,2)
        if(i == j)
        else
            B{i,j} = Sift_EuclideanSimilarityMatrix(A{i},A{j});
        end
        
    end
end

TotalFrameSimilarityMatrix = [];


for k=1:size(B,1)
    for l=1:size(B,2)
        if(k==l)
            flag = true;
        else
            for i=1:size(B{k,l},1)
                FrameSimilarityMatrix = [];
                sortedmatrix = [];
                for X=1:size(B,2)
                    if (~isempty(B{k,X}))
                    for j=1:size(B{k,X},2)
                        FrameSimilarityMatrix= cat(1,FrameSimilarityMatrix,[k,i,X,j,B{k,X}(i,j)]);
                        
                    end
                    end
                end
                [values, order] = sort(FrameSimilarityMatrix(:,5),'descend');
                sortedmatrix = FrameSimilarityMatrix(order,:);
                TotalFrameSimilarityMatrix = cat(1,TotalFrameSimilarityMatrix,sortedmatrix(1:K,:));
            end
           break; 
        end
        
    end
end


load('Phase3Task2.mat');
FILE=fopen('Phase3Q2.txt','w');
fprintf(FILE,'Va \t\t    Vb \t\t Similarity(a,b)\n');
fprintf(FILE,'---------------------------------------\n');

for i=1:size(TotalFrameSimilarityMatrix,1)
    for j=1:size(TotalFrameSimilarityMatrix,2)
        if (j == 1 || j == 3)
            fprintf(FILE,'(');
            fprintf(FILE,'%d',TotalFrameSimilarityMatrix(i,j));
            fprintf(FILE,',');
        elseif (j == 2 || j == 4)
            fprintf(FILE,'%d',TotalFrameSimilarityMatrix(i,j));
            fprintf(FILE,')\t\t');
        else
            fprintf(FILE,'%f',TotalFrameSimilarityMatrix(i,j));
        end
    end
    fprintf(FILE,'\n');
end

filename = 'Phase3Task2.mat';
save('Phase3Task2.mat','TotalFrameSimilarityMatrix');



