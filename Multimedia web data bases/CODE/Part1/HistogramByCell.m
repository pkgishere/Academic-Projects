turnfunction [ ImHistogram ] = HistogramByCell(Image,Cells)
%This Function returns the Histogram  with R*R cells
%   The functions takes two inputs, Image name in current working directory
%   and Value of R which is no of cells to be used

%setting input to local variables;
IM=Image;
r=double(Cells);

%Setting the inital cell Values
CellxMin=0;
CellxMax=(size(IM,1)/r);
CellyMin=0;
CellyMax=size(IM,2)/r;

%Declaring the size of Histogram
Histogram=zeros(256,(r.*r));

%Declaring Inputs
count=0;
m=0;
n=0;

%Looping into Matrix to create Histograms
while m<=size(IM,1)
    while n<=size(IM,2)
        count=count+1;
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
        Value=imhist(IM(floor(CellxMin+1):(m1),floor(CellyMin+1):(n1)),256);
        Histogram(:,count)=Value;
        
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
%returning Final Value
ImHistogram=transpose(Histogram);

end

