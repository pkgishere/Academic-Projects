clc;
system('perl Formatting.pl');
matrixinput=importdata('OutPut.txt');
prompt = ('Enter how many significant frames you want to obtain?');
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
T = zeros(uniqueRows);
tempRow=1;
p1=1;
q1=1;
for m=1 : numRows
    for n=1 : uniqueRows
        if (matrixinput(m,3)==assignValues(n,1) && matrixinput(m,4)==assignValues(n,2))
            simFrame=assignValues(n,3);
            T(tempRow,simFrame)=matrixinput(m,5);
        end
        if(p1~=matrixinput(m,1) || q1~=matrixinput(m,2))
            p1=matrixinput(m,1);
            q1=matrixinput(m,2);
            tempRow=tempRow+1;
        end
    end
end
numNodes=0;
G = digraph(T);
% plot (G);
pr = centrality(G,'pagerank','MaxIterations',100,'FollowProbability',0.85);
for h = 1 : uniqueRows
    pr(h,2)=h;
end
newpr = sortrows(pr,-1);
msig = [];
for sf=1 : mframe
    trow = newpr(sf,2);
    msig(sf,1)=assignValues(trow,1);
    msig(sf,2)=assignValues(trow,2);
end

[xu, m, k] = unique(matrixinput(:,3:4), 'rows');
for j=1:size(xu)
    count= 0;
    for p=1:numRows
        if xu(j,1)==matrixinput(p,3)&& xu(j,2)==matrixinput(p,4)
            count=count+1;
        end
    end
    xu(j,3)=count;
end
xu = sortrows(xu,3);
vn=[];

VideoNames=FetchNameFromExtension('.mp4');
for p=1:mframe
    VideoName=VideoNames{msig(p,1)};
    VR=VideoReader(strcat(pwd,'\Videos\',VideoName));
    SimilarImage=read(VR,msig(p,2));
    figure
    image(SimilarImage);
end
