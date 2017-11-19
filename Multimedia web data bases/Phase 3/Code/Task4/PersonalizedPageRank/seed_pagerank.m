clc;
system('perl Formatting.pl');
matrixinput=importdata('OutPut.txt');
prompt = ('Enter how many significant frames you want to obtain?\n');
dlg_title = 'Input number of significant frames';
num_lines = 1;
defaultans = {'0'};
mframe = inputdlg(prompt,dlg_title,num_lines,defaultans);
mframe = str2double(mframe);
for i=1:3
    prompt = {'Enter Video Number:','Enter Frame Number:'};
    dlg_title = 'Input Seed Frames';
    num_lines = 1;
    defaultans = {'0','0'};
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
    seed(i,1) = str2num(answer{1});
    seed(i,2) = str2num(answer{2});
end
VideoNames=FetchNameFromExtension('.mp4');
for p=1:3
    VideoName=VideoNames{seed(p,1)};
    VR=VideoReader(strcat(pwd,'\Videos\',VideoName));
    SimilarImage=read(VR,seed(p,2));
    figure
    image(SimilarImage);
end
beta=0.85;
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
ppr=ones(uniqueRows,1);
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
% plot(G);
pr = centrality(G,'pagerank','MaxIterations',100,'FollowProbability',0.85);
for h = 1 : uniqueRows
    pr(h,2)=h;
end
%read seed frame assigned number from assignValues matrix
for i=1 : 3
    for j=1 : uniqueRows
        if (seed(i,1)==assignValues(j,1) && seed(i,2) == assignValues(j,2))
            seed(i,3)=assignValues(j,3);
        end
    end
end
seedprsum=0;
for i=1:3
    for j=1:uniqueRows
        if seed(i,3)==pr(j,2)
            seedprsum=seedprsum+pr(j,1);
        end
    end
end
s=zeros(uniqueRows,1);
for i=1:uniqueRows
    for j=1:3
        if i==seed(j,3)
            s(i)=(pr(i,1)/seedprsum);
        end
    end
end
for iteration=1:100
    ppr=((1-beta)*T*ppr)+(beta*s);
end
for h = 1 : uniqueRows
    ppr(h,2)=h;
end
newppr = sortrows(ppr,-1);

for sf=1 : mframe
    trow = newppr(sf,2);
    msig(sf,1)=assignValues(trow,1);
    msig(sf,2)=assignValues(trow,2);
end

for p=1:3
    VideoName=VideoNames{msig(p,1)};
    VR=VideoReader(strcat(pwd,'\Videos\',VideoName));
    SimilarImage=read(VR,msig(p,2));
    figure
    image(SimilarImage);
end