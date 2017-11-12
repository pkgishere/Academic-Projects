function [cost_val, gradient] = cost(theta_val, training_data, training_labels)
Count_Training_Data = length(training_labels); % = m
cost_val = 0;
gradient = zeros(size(theta_val));
hypothesis = zeros(size(training_data*theta_val));
% Softplus  function
hypothesis=log(1+(exp(training_data*theta_val)));


%cost_val = (-1/Count_Training_Data) * sum( training_labels .* log(hypothesis) + (1 - training_labels) .* log(1 - hypothesis) );
cost_val = (-1/Count_Training_Data) * sum( log(1+exp(-training_labels.*(training_data*theta_val))));
%Calculating gradient
for i = 1:Count_Training_Data
    gradient = gradient + ( hypothesis(i) - training_labels(i) ) * training_data(i, :)';
    %gradient = gradient + ( hypothesis(i) - training_labels(i) ) * training_data(i, :)';
end
gradient = (1/Count_Training_Data) * gradient;
end