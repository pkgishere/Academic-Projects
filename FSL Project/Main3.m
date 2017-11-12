Z=importdata('data.mat');

TestImages=Array2Image(Z.testImages);
TrainImages=Array2Image(Z.trainImages);


if 1
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
end

%%


TestLabels=Z.testLabels;
TrainLabels=Z.trainLabels;
%If you want to label them as -1 and 1
if 0
    for i=1:size(TestLabels,1)
        if(TestLabels(i,1)==0)
            TestLabels(i,1)=-1;
        end
    end
    
    for i=1:size(TrainLabels,1)
        if(TrainLabels(i,1)==0)
            TrainLabels(i,1)=-1;
        end
    end
end
TestImages=[ones(size(Z.testImages,1),1) Z.testImages];
TrainImages=[ones(size(Z.trainImages,1),1) Z.trainImages];

initialTheta= rand(size(TrainImages,2),1);
[J,grad]=computeCost(initialTheta,TrainImages,TrainLabels);
%options =optimoptions(@fminunc,'quasi-newton','GradObj','on','MaxIter',3);
%options =optimoptions('GradObj','on','MaxIter',400);

%options = optimoptions('fminunc','SpecifyObjectiveGradient',true); 
% indicate gradient is provided 
options=optimoptions(@fminunc,'Algorithm','quasi-newton','MaxIterations',1500);
Theta=initialTheta;
%options =optimoptions('fminunc','MaxIterations',400,'SpecifyObjectiveGradient',true,'CheckGradients',true);
%for i=1:10
 %   if J < 0.005 
  %      break
   % end
    %Theta = Theta- 0.25.*grad
    %[J,grad]=computeCost(Theta,TrainImages,TrainLabels);
%end
theta=fminunc(@(t)computeCost(t,TrainImages,TrainLabels),initialTheta,options);
%%
n=0.25;
test_images=Z.testImages;
gradmat = sign(grad);
for i = 1:size(Z.testImages,2)
    if(gradmat(i)>=0)
        for j= 1:size(Z.testImages,1)
            test_Images(j,i)= n+Z.testImages(j,i);
        end
    end
    if(gradmat(i)<0)
        for j= 1:size(Z.testImages,1)
            test_Images(j,i)= Z.testImages(j,i)-n;
        end
    end
end
%%
result_origional = predict(Theta, test_Images);
res =  mean(double(result_origional==Z.testLabels));
res= res*100;
xplot(2)=.0025;
yplot(2) = res;
fprintf('Accuracy of the model with Adversial images with noise %f is %f\n',n,res);













