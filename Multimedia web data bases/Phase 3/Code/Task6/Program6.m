clc;
clear;
delete *.jpg;
%fetching file
VideoNames=FetchNameFromExtension('.mp4');
for i=1:size(VideoNames,1)
    fprintf('%d.  %s  \n',i,VideoNames{i})
end
fprintf('\nSelect 1st Video:- ');
V1=int64(input(''));
VideoName=VideoNames{V1};
VR=VideoReader(strcat(pwd,'\Videos\',VideoName));
fprintf('Kindly Select Frame no from 1 to %d \n',VR.NumberOfFrames);
Frame=int64(input(''));
clc;
fprintf('\t | \n\t |\n\t V\n');
fprintf('Kindly Select Start X(Height) From 1 to %d \n',VR.Height);
Xstart=int64(input(''));
fprintf('Kindly Select End X(Height) From %d to %d \n',Xstart,VR.Height);
Xend=int64(input(''));
clc;
fprintf('\t ----------->\n');
fprintf('Kindly Select Start Y(Width) From 1 to %d \n',VR.Height);
Ystart=int64(input(''));
fprintf('Kindly Select End Y(Width) From %d to %d \n',Ystart,VR.Height);
Yend=int64(input(''));
clc;
n=input('Enter the value of n \n');
clc;
fprintf('Query Image is %s with Frame no %d from %d to %d in X and %d to %d in Y\n',VR.name,Frame,Xstart,Xend,Ystart,Yend);
QueryImage=read(VR,Frame);
QueryImage=QueryImage(Xstart:Xend,Ystart:Yend,:);
image(QueryImage);
filename = [sprintf('QueryImage') '.jpg'];
fullname = fullfile(pwd,filename);
imwrite(QueryImage,fullname);
command=strcat('perl FormattingQ6.pl ',{' '},num2str(V1),{' '},num2str(Frame),{' '},num2str(Xstart),{' '},num2str(Xend),{' '},num2str(Ystart),{' '},num2str(Yend));
system(char(command));
query = importdata('Query.txt');
database = importdata('Final.txt');
commonElements = database(:,3:4);
for j=1:size(query,1)
    newC =1;
    firstVector = [];
    for i=1:size(database,1)
        if(database(i,2) == query(j,7))
            firstVector(newC,:) = database(i,3:4);
            newC = newC+1;
        end
        
    end
    commonElements = intersect(commonElements, firstVector, 'rows');
end
countMatrix = zeros(max(database(:,3),[],1),max(database(:,4),[],1));
for j=1:size(query,1)
    newC =1;
    firstVector = [];
    for i=1:size(database,1)
        if(database(i,2) == query(j,7))
            firstVector(newC,:) = database(i,3:4);
            countMatrix(firstVector(newC,1),firstVector(newC,2)) =countMatrix(firstVector(newC,1),firstVector(newC,2)) +1;
            newC = newC+1;
        end
    end
end
[sortedValue, sortedIndex] = sort(countMatrix(:), 'descend');
maxIndex = sortedIndex(1:n);
VideoNumbers = [];
for k=1:n
    VideoNumbers(k,1) = mod(maxIndex(k),size(countMatrix,1));
    FrameNumbers(k,1) = ceil(maxIndex(k)/ size(countMatrix,1));
    VideoName=VideoNames{VideoNumbers(k,1)};
    VR=VideoReader(strcat(pwd,'\Videos\',VideoName));
    fprintf('Similar Image/Frame no. %d is of Video %s with Frame no %d\n',k,VR.name,FrameNumbers(k,1));
    SimilarImage=read(VR,FrameNumbers(k,1));
    image(SimilarImage);
    pause(2);
    filename = [sprintf('SimilarImage%03d',k) '.jpg'];
    fullname = fullfile(pwd,filename);
    imwrite(SimilarImage,fullname);
end
system('perl Answer.pl');
ME=importdata('Lines.txt');
Bytes=dir('Final.txt');
Bytes=Bytes.bytes;
fprintf('\n\nThe number of unique SIFT vectors considered are %d \n ',size(database,1));
fprintf('\nThe overall number of SIFT vectors considered are %d \n ',ME(1,1));
fprintf('\nThe number of bytes of data from the index accessed to process the query %d',Bytes);