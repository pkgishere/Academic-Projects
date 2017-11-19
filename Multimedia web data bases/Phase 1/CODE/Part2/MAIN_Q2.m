clear
clc

%Setting Path value and pwd
cd C:\Users\'Prashant garg'\Dropbox\'GRADUATION ASU'\'MULTI MEDIA WEB DATABASES'\project\sift\sift
path(path,'C:\Users\Prashant garg\Dropbox\GRADUATION ASU\MULTI MEDIA WEB DATABASES\project\sift\sift')

%Fetching aall video files
VideoNames=FetchNameFromExtension('.mp4');



%Getting input from User
Message='Enter the Value of r(integer) = ';
r=int64(input(Message));

FILE=fopen('Phase1Q2.txt','w');
fprintf(FILE,'INPUT GIVEN FOR CELLS AS %d\n\n',r);

CountFrame=0;
for i=1: numel(VideoNames)
    %Reading Videos
    VR=VideoReader(VideoNames{i});
    
    %file formating
    fprintf(FILE,'_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ \n_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ \n Name of the Video :-');
    fprintf(FILE,VideoNames{i});
    fprintf(FILE,'\n_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ \n_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ \n\n');
    
    %frames extraction and manipulation
    CountFrame=0;
    for j=1:VR.NumberOfFrames
        CountFrame=CountFrame+1;
        
        %file Formatiing and entering Frame no
        fprintf(FILE,'\n\t_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ \n\t Frame no :-');
        fprintf(FILE,'%d',CountFrame);
        fprintf(FILE,'\n\t_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ \n');
        
        %Reading Particular Frame and Converting it into GrayScale
        b=read(VR,j);
        I = rgb2gray(b);
        
        [frames1,descr1,gss1,dogss1] = sift( I, 'Verbosity', 0 ) ;
        a=[transpose(frames1),transpose(descr1)];
        b=a(:,1:2);
        
        IM=I;
        r=double(r);
        
        %Setting the inital cell Values
        CellxMin=0;
        CellxMax=(size(IM,1)/r);
        CellyMin=0;
        CellyMax=size(IM,2)/r;
        
        
        %Declaring Inputs
        CountX=0;
        m=0;
        n=0;
        FinalX=zeros(r,1);
        FinalY=zeros(r,1);
        %Looping into Matrix to create Histograms
        while m<=size(IM,1)
            CountY=1;
            CountX=CountX+1;
            while n<=size(IM,2)
                
                %setting the Upper bound Of X for the present cell
                m1=floor(CellxMax);
                if( size(IM,1) -m  == 1)
                    m1= m1 + 1;
                end
                
                
                %setting the Upper Bound of y for the present cell
                n1=floor(CellyMax);
                if(size(IM,2) -n1 == 1)
                    n1=n1+1;
                end
                
                %Fetching the Histogram from inhist and then appending it to
                %Histogram
                if(CountY==1)
                    FinalX(CountX,1)=m1;
                end
                
                if(CountX==1)
                    FinalY(CountY,1)=n1;
                end
                CountY=CountY+1;
                
                %Setting Y for next iteration cell
                CellyMin=n1;
                CellyMax=CellyMax+(size(IM,2)/r);
                n=int64(CellyMax);
                
            end
            
            %Setting X for next iteration cell
            CellxMin=m1;
            CellxMax=CellxMax+(size(IM,1)/r);
            m=floor(CellxMax);
            
            %Resetting Y for Next innner loop
            CellyMax=(size(IM,2)/r);
            n=0;
            CellyMin=0;
            
        end
        
        Cell=zeros(r.*r,133);
        count=0;
        for i=1:size(b,1)
            X=0;
            Y=0;
            for j=1:r
                
                if(Y==0)
                    if(b(i,1)<FinalY(j))
                        Y=j;
                    end
                end
                if(X==0)
                    if(b(i,2)<FinalX(j))
                        X=j;
                    end
                end
            end
            count=count+1;
            Cell(count,:)=[((r*(X-1))+Y),a(i,:)];
        end
        
        
        
        CellNo=0;
        for i=1:r*r
            Count=0;
            for j=1:size(Cell,1)
                
                if(Cell(j,1)==i)
                    Count=Count+1;
                    fprintf(FILE,'\n\t\t Cellno:%d    ',i);
                    fprintf(FILE,'%f ',Cell(j,2:end));
                end
            end
            if Count == 0
                fprintf(FILE,'\n\t\t Cellno:%d    NO SIFT IN THIS CELL',i);
            end
            
        end
    end
end










