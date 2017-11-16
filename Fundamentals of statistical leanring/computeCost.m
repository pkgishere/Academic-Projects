function [ J,Grad ] = computeCost( Theta,X,Y)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

hypothesis=sigmoid(X*Theta);
m=size(X,1);
%J=1/m*sum(-Y.*(log (1+exp(X*Theta))))
%J=(1/(size(X,1)))*sum(log(1+exp(-Y.*(a))));

%J=(1/(size(X,1)))*sum(log(1+exp(-Y.*(X*Theta))));

J=(1/(size(X,1)))*sum(log(1+exp(-Y.*(X*Theta))));
%J = (1/m)*(-sum(temp(:,1))-sum(temp(:,2))) + (lambda/(2*m))*sum(theta(2:end,1).^2);

%
%J=(1/(size(X,1)-1))*sum(Y .* log(1+exp(-a)) + (1-Y) .* log(1+exp(a)));
grad=zeros(size(Theta,1),1);

%grad(2:end,1)=((1/m)*((sigmoid(X*theta)-y)'*X(:,2:end)))'+(1/m)*theta(2:end);
%y=Y;
%grad(1,1) = (1/m)*sum((sigmoid(X*Theta)-y).*X(:,1));
%grad(2:end,1)=((1/m)*((sigmoid(X*Theta)-y)'*X(:,2:end)))'+(1/m)*Theta(2:end);

%
for j=1:m
    grad=grad-((1/m)*(sigmoid(Y(j).*(X(j,:)*Theta)).*(-Y(j)*X(j,:)))');
    %grad = grad +( -hypothesis(i) + Y(i) ) * X(i, :)';
end
Grad=(1/m).*grad;
%grad(j)=1/m*sum(-Y.*sigmoid(X*Theta).*X(:,j));
%grad(j)=(1/m)sum(sigmoid(-Y.*a)).*(-Y.*a.*(1-a).*X(:,j));

