clear
clc

%Setting Path value and pwd
cd C:\Users\'Prashant garg'\Dropbox\'GRADUATION ASU'\'MULTI MEDIA WEB DATABASES'\project\DataR\
path(path,'C:\Users\Prashant garg\Dropbox\GRADUATION ASU\MULTI MEDIA WEB DATABASES\project\DataR')

%Fetching aall video files
VideoNames=FetchNameFromExtension('.mp4');

FrameHist=[];
Count=0;


%Getting input from User
Message='Enter the Value of r(integer) = ';
r=int64(input(Message));

%Opening Write File
FILE= fopen('Phase1Q1.txt','w');

%Entering the input for r In output file
fprintf(FILE,'INPUT GIVEN FOR CELLS AS %d\n\n',r);

for i=1: numel(VideoNames)
    %Reading Videos
    VR=VideoReader(VideoNames{i});
    
    %file formating 
    fprintf(FILE,'_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ \n_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ \n Name of the Video :-');
    fprintf(FILE,VideoNames{i});
    fprintf(FILE,'\n_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ \n_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ \n\n');
    
    %frames extraction and manipulation 
    for j=1:VR.NumberOfFrames
        Count=Count+1;
        
        %file Formatiing and entering Frame no 
        fprintf(FILE,'\n\t_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ \n\t Frame no :-');
        fprintf(FILE,'%d',Count);
        fprintf(FILE,'\n\t_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ \n');
        filename=strcat(pwd,'\output\',VideoNames{i},'_FrameNo_',num2str(j),'.jpg');
        
        %Reading Particular Frame and Converting it into GrayScale
        b=read(VR,j);
        I = rgb2gray(b);
        
        %getting cell wise histogram
        FrameHist=HistogramByCell(I,r);
        
        %file formatiing and cell histogram input
        CellNo=0;
        for l=1:size(FrameHist,1)
            CellNo=CellNo + 1;
            fprintf(FILE,'\n\t\t Cell no :- %d = [',CellNo);
            fprintf(FILE,'%d ',FrameHist(l,:));
            fprintf(FILE,' ]');
        end
        
    end
    Count=0;
end



