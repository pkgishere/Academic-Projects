function [ Return ] = Array2Image(C)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
Answer=[];
for lemda=1:size(C,1)
    Image=zeros(sqrt(size(C,2)),sqrt(size(C,2)));
    for i=1:int64(sqrt(size(C,2)))
        Image(i,:)=C(lemda,((i-1)*int64(sqrt(size(C,2))))+1:((i-1)*int64(sqrt(size(C,2)))+(sqrt(size(C,2)))));
    end
    Image=Image';
    Answer=cat(3,Answer,Image);
end
Return = Answer;
end
