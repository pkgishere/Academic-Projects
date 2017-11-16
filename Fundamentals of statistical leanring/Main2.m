clear;
clc;
ZZ = importdata('data.mat');

trainImages = ZZ.trainImages;
trainLabels = ZZ.trainLabels;

TestImages=Array2Image(ZZ.testImages);
TrainImages=Array2Image(ZZ.trainImages);

Z=ZZ;
workingDir=pwd;
mkdir (pwd,'TestImages');
delete './TestImages/*.jpg';
for i=1:size(TestImages,3)
    filename = [sprintf('TestImage%d',i) '.jpg'];
    fullname = fullfile(workingDir,'TestImages',filename);
    imwrite(TestImages(:,:,i),fullname)
end



workingDir=pwd;
mkdir (pwd,'TrainImages');
delete './TrainImages/*.jpg';
for i=1:size(TestImages,3)
    filename = [sprintf('TrainImage%03d',i) '.jpg'];
    fullname = fullfile(workingDir,'TrainImages',filename);
    imwrite(TestImages(:,:,i),fullname)%
end



% Label = 1  => Digit 1
% Label = 0  => Digit 7
% image = reshape(trainImages(2,:), [28, 28]);

[trainLen, pixels]  = size(trainImages);
% Label = +1  => Digit 1
% Label = -1  => Digit 7
for i=1:trainLen
    if ~trainLabels(i)
        trainLabels(i) = -1;
    end
end

% Set seed=1
rng(1);

% Shuffle data randomly
perm = randperm(trainLen);
trainImages = trainImages(perm,:);
trainLabels = trainLabels(perm);

% Learning Rate
rate = 0.5;

% Iterations
iterations = 19;

% Error Storage
Error = zeros(iterations, 1);
WrongPredictions = zeros(iterations, 1);

% W => 784 X 1
W = randn(pixels, 1);

% b => 1 X 1 (scalar)
b = randn(1);

tic;
for i = 1:iterations
    tmpError = 0;
    for j = 1:trainLen
        % X => 1 X 784 (row)
        X = trainImages(j, :);
        
        % Label y of X.
        y = trainLabels(j);
        
        % Forward Propagation
        z = X * W + b;
        
        % Prediction (SIGMOID)
        yHat = sigmoid(z);
        
        % Error = softplus(y*sigmoid(XW+b)) = softplus(y*yHat)
        J = log(1 + exp(y*yHat));
        
        if sign(y*yHat) == -1
            WrongPredictions(i) = WrongPredictions(i)+1;
            
            % Back Propagate only if wrongly predicted
            
            % dJ/dW or Gradient(J) = sigmoid(y*yHat).y.X = delta*X
            % => delta =  sigmoid(y*yHat).y
            delta = sigmoid(y * yHat) * y;
            gradJ = delta * X';
            
            % Back Propagation
            W = W + rate * gradJ;
            b = b + rate * delta;
        end
        tmpError = tmpError + J;
    end
    Error(i) = tmpError;
end
toc;

% figure;
% plot(1:iterations, Error);
% xlabel('Iterations  -------->');
% ylabel('Error  --------->');
figure;
plot(1:iterations, WrongPredictions);
xlabel('Iterations  -------->');
ylabel('Wrong Predictions  --------->');
title('Predictions on training set');

%% Testing---------------------------------------------
% 
testImages = ZZ.testImages;
testLabels = ZZ.testLabels;

[testLen, jnk ] = size(testImages);
TestWrongPredictions = 0;

% Class Labels +1/-1
for i = 1:testLen
    if ~testLabels(i)
        testLabels(i) = -1;
    end
end

tic;
for j = 1:testLen
    X = testImages(j, :);
    
    y = testLabels(j);
    
    z = X * W + b;
    
    yHat = sigmoid(z);
    if sign(y*yHat) == -1
        TestWrongPredictions = TestWrongPredictions+1;
    end
end
toc;

% TestWrongPredictions
W=[b;W];
delta = sigmoid(y * yHat) * y;
gradJ = delta * W';
r='The Value of noise = ';

n=(input(r)); 
test_images=ZZ.testImages;
gradmat = sign(gradJ);
for i = 1:size(ZZ.testImages,2)
    if(gradmat(i)>=0)
        for j= 1:size(ZZ.testImages,1)
            test_Images(j,i)= n+ZZ.testImages(j,i);
        end
    end
    if(gradmat(i)<0)
        for j= 1:size(ZZ.testImages,1)
            test_Images(j,i)= ZZ.testImages(j,i)-n;
        end
    end
end
%%
result_origional = predict(W, test_Images);
res =  mean(double(result_origional==ZZ.testLabels));
res= res*100;
xplot(2)=.0025;
yplot(2) = res;
fprintf('Accuracy of the model with Adversial images with noise %f is %f\n',n,res);


