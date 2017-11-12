% predict function which uses sigmoid function to classify the data
function resSigmoid = predict(theta_val,mat)
m = size(mat, 1);
% output result matrics
resSigmoid = zeros(m, 1);
% result is > .5 then class is 1 else class is 0
g = zeros(size(mat*theta_val));
g = 1./(1 + exp(-(mat*theta_val)));
resSigmoid = (g >= 0.5);
end