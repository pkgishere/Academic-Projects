data = load('data.mat');
fprintf('Starting ......\n');
fprintf('Loading Data....\n');

X=data.trainImages;
sel = randperm(size(X, 1));
sel = sel(1:100);
displayData(X(sel, :));% function taken from Andrew NG



% Loading the training data and Training Labels
training_Data = data.trainImages; 
training_labels = data.trainLabels; 
test_labels=data.testLabels;
Origional_test_Images= data.testImages;
[row, col] = size(training_Data);


ZZ= data;
TestImages=Array2Image(ZZ.testImages);
TrainImages=Array2Image(ZZ.trainImages);
fprintf('Testing Images in TestImages Folder....\n');
workingDir=pwd;
mkdir (pwd,'TestImages');
delete './TestImages/*.jpg';
for i=1:size(TestImages,3)
    filename = [sprintf('TestImage%d',i) '.jpg'];
    fullname = fullfile(workingDir,'TestImages',filename);
    imwrite(TestImages(:,:,i),fullname)
end

fprintf('Training Images in TrainImages FOlder....\n');

workingDir=pwd;
mkdir (pwd,'TrainImages');
delete './TrainImages/*.jpg';
for i=1:size(TestImages,3)
    filename = [sprintf('TrainImage%03d',i) '.jpg'];
    fullname = fullfile(workingDir,'TrainImages',filename);
    imwrite(TestImages(:,:,i),fullname)%
end


% Adding intercept term 
training_Data = [ones(row, 1) training_Data];
% new fitting parameters
initial_theta_val = zeros(col + 1, 1);
fprintf('Training the model....\n');
% initial cost and gradient
[cost_val, gradient] = cost(initial_theta_val, training_Data, training_labels);
%  optimizing structure
options = optimset('GradObj', 'on', 'MaxIter', 400);
%  fminunc function to minisize and optimise the results
[theta_val, cost_val] = fminunc(@(t)(cost(t,training_Data, training_labels)), initial_theta_val, options);
% Loading testing Data
Origional_test_Images = [ones(size(Origional_test_Images,1), 1) Origional_test_Images];
fprintf('Testing Data....\n');
%%
% Predict function to test the origional testing testing data.
result_origional = predict(theta_val, Origional_test_Images);
res =  mean(double(result_origional==test_labels))*100;
xplot(1)=0;
yplot(1) = res;
% generating afversial images with noise = .0025
test_Images_One = zeros(size(Origional_test_Images,1),size(Origional_test_Images,2));
n=.0025;
gradmat = sign(gradient);
for i = 1:size(Origional_test_Images,2)
    if(gradmat(i)>=0)
        for j= 1:size(Origional_test_Images,1)
            test_Images_One(j,i)= n+Origional_test_Images(j,i);
        end
    end    
    if(gradmat(i)<0)
        for j= 1:size(Origional_test_Images,1)
            test_Images_One(j,i)= Origional_test_Images(j,i)-n;
        end
    end    
end
result_origional = predict(theta_val, test_Images_One);
res =  mean(double(result_origional==test_labels));
res= res*100;
xplot(2)=.0025;
yplot(2) = res;
%%
fprintf('Accuracy of the model with Adversial images with noise .0025 is %f\n',res);
%%
% Adversial Images with Noise = .025
test_Images_Two = zeros(size(Origional_test_Images,1),size(Origional_test_Images,2));
n=.025;
for i = 1:size(Origional_test_Images,2)
    if(gradmat(i)>=0)
        for j= 1:size(Origional_test_Images,1)
            test_Images_Two(j,i)= n+Origional_test_Images(j,i);
        end
    end    
    if(gradmat(i)<0)
        for j= 1:size(Origional_test_Images,1)
            test_Images_Two(j,i)= Origional_test_Images(j,i)-n;
        end
    end    
end
result_origional = predict(theta_val, test_Images_Two);
res =  mean(double(result_origional==test_labels));
res= res*100;
xplot(3)=.025;
yplot(3) = res;
fprintf('Accuracy of the model with Adversial images with noise .025 is %f\n',res);


test_Images_Three = zeros(size(Origional_test_Images,1),size(Origional_test_Images,2));
n=.25;
for i = 1:size(Origional_test_Images,2)
    if(gradmat(i)>=0)
        for j= 1:size(Origional_test_Images,1)
            test_Images_Three(j,i)= n+Origional_test_Images(j,i);
        end
    end    
    if(gradmat(i)<0)
        for j= 1:size(Origional_test_Images,1)
            test_Images_Three(j,i)= Origional_test_Images(j,i)-n;
        end
    end    
end
result_origional = predict(theta_val, test_Images_Three);
res =  mean(double(result_origional==test_labels));
res= res*100;
xplot(3)=.025;
yplot(3) = res;
fprintf('Accuracy of the model with Adversial images with noise .25 is %f\n',res);


% Adversial Images with Noise = .5
test_Images_Four = zeros(size(Origional_test_Images,1),size(Origional_test_Images,2));
n=.5;
for i = 1:size(Origional_test_Images,2)
    if(gradmat(i)>=0)
        for j= 1:size(Origional_test_Images,1)
            test_Images_Four(j,i)= n+Origional_test_Images(j,i);
        end
    end    
    if(gradmat(i)<0)
        for j= 1:size(Origional_test_Images,1)
            test_Images_Four(j,i)= Origional_test_Images(j,i)-n;
        end
    end   
end
result_origional = predict(theta_val, test_Images_Four);
res =  mean(double(result_origional==test_labels));
res= res*100;
xplot(4)=.5;
yplot(4) = res;
fprintf('Accuracy of the model with Adversial images with noise .5 is %f\n',res);

% plotting graph
title('Graph Showing accuracy of logistic regression with adversial image')
xlabel('Value of n for Adversial Images') % x-axis label
ylabel('Accuracy') % y-axis label

plot(xplot,yplot,':bs')
title('Graph Showing accuracy of logistic regression with adversial image')
xlabel('Value of n for Adversial Images') % x-axis label
ylabel('Accuracy Percentage (%)') % y-axis label











