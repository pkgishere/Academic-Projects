clc;
system('perl Formatting.pl');
matrixinput=importdata('OutPut.txt');
prompt = ('Enter how many significant frames you want to obtain?\n');
dlg_title = 'Input number of significant frames';
num_lines = 1;
defaultans = {'0'};
mframe = inputdlg(prompt,dlg_title,num_lines,defaultans);
mframe = str2double(mframe);
count=0;
[numRows,numCol] = size(matrixinput);
assignValues = [];
p=0;
q=0;
temp=1;
for i=1 : numRows
    if(p~=matrixinput(i,1)||q~=matrixinput(i,2))
        p=matrixinput(i,1);
        q=matrixinput(i,2);
        count=count+1;
        assignValues(temp,1)=matrixinput(i,1);
        assignValues(temp,2)=matrixinput(i,2);
        assignValues(temp,3)=count;
        temp=temp+1;
    end
end
[uniqueRows,uniqueColumn] = size(assignValues);
ascos=ones(uniqueRows,1);
T = zeros(uniqueRows);
tempRow=1;
p1=1;
q1=1;
for m=1 : numRows
    neighborsum = 0;
    for n=1 : uniqueRows
        if (matrixinput(m,3)==assignValues(n,1) && matrixinput(m,4)==assignValues(n,2))
            simFrame=assignValues(n,3);
            for i=1:numRows
                if ((matrixinput(m,1)==matrixinput(i,3))&&(matrixinput(m,2)==matrixinput(i,4)))
                    for j=1:numRows
                        if((matrixinput(j,1)==matrixinput(m,3))&&(matrixinput(j,2)==matrixinput(m,4)))
                            neighborsum = neighborsum+1;
                        elseif((matrixinput(i,1)==matrixinput(j,1))&&(matrixinput(i,2)==matrixinput(j,2))&&(matrixinput(m,3)==matrixinput(j,3))&&(matrixinput(m,4)==matrixinput(j,4)))
                            neighborsum = neighborsum+matrixinput(j,5);
                        else
                            neighborsum = neighborsum + 0;
                        end
                    end
                end
            end
            if neighborsum~=0
                T(tempRow,simFrame)=(matrixinput(m,5)/neighborsum);
            else
                T(tempRow,simFrame)=100;
            end
        end
        if(p1~=matrixinput(m,1) || q1~=matrixinput(m,2))
            p1=matrixinput(m,1);
            q1=matrixinput(m,2);
            tempRow=tempRow+1;
        end
    end
end
c=0.9;
P=T';
numNodes=0;
I=eye(uniqueRows,1);
G = digraph(T);
%  plot (G);
for iteration=1:100
    ascos=(c*P*ascos)+((1-c)*I);
end
for h = 1 : uniqueRows
    ascos(h,2)=h;
end
newascos = sortrows(ascos,-1);
msig = [];
for sf=1 : mframe
    trow = newascos(sf,2);
    msig(sf,1)=assignValues(trow,1);
    msig(sf,2)=assignValues(trow,2);
end

VideoNames=FetchNameFromExtension('.mp4');
for p=1:mframe
    VideoName=VideoNames{msig(p,1)};
    VR=VideoReader(strcat(pwd,'\Videos\',VideoName));
    SimilarImage=read(VR,msig(p,2));
    figure
    image(SimilarImage);
    
end
