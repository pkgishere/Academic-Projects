%program reduces number of dimensions using pca for sift vectors. 
clear;
clc;
fprintf('Reading file....\n');
system('perl Formatting.pl');
Z = importdata('OUTPUT.txt');
%%
fprintf('File Read\n\n');
[noOfCells, information] = size(Z);
fprintf('Number of dimensions in original file is- %d \n', (information-5));
[coeff, score, latent] = pca(Z(:,6:end));
%varianceValue = cumsum(var(score)) / sum(var(score));
d = input('Enter the targetted dimensionality \n');
newDimensions = coeff(:,1:d);
finalMatrix= [Z(:,1:5) score(:,1:d)];
fileID = fopen('Sift_Reduced_Formatted.txt', 'w');
fprintf(fileID, '<Video; Frame; Cell; X; Y; ');
for k=1:d
    fprintf(fileID, 'nd-%d; ',k);
end
fprintf(fileID, '>\r\n');

for i=1:size(Z,1)
    fprintf(fileID, '<');
  fprintf(fileID, ' %d,', finalMatrix(i,:));
  fprintf(fileID, '>\r\n');
end
fileNewDimensions = fopen('Sift_New_Dimensions.txt', 'w');
for i=1:d
    tempDim = newDimensions(:, i);
    [val, ind] = sort(tempDim, 'descend');
    fprintf(fileNewDimensions, 'New Dimension- %d = <', i);
    for j=1:size(val,1)
        fprintf(fileNewDimensions, 'od%d = %f; ', ind(j,1),val(j,1));
    end
    fprintf(fileNewDimensions, '> \r\n\r\n');
end