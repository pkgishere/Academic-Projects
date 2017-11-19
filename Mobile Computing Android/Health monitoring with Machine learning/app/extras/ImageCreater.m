a=importdata('output.txt');

for i=1:size(a,1)
    if(a(i,1)==1)
        count=1;
        for j=1:50
            x(i,j)=a(i,count+1);
            y(i,j)=a(i,count+2);
            z(i,j)=a(i,count+3);
            count=(j*3)+1;
        end
        plot3(x(i,:),y(i,:),z(i,:),'r')
        hold on;
    end
    if(a(i,1)==2)
         count=1;
        for j=1:50
            x(i,j)=a(i,count+1);
            y(i,j)=a(i,count+2);
            z(i,j)=a(i,count+3);
            count=(j*3)+1;
        end
        plot3(x(i,:),y(i,:),z(i,:),'b')
        hold on;
    end
    if(a(i,1)==3)
         count=1;
        for j=1:50
            x(i,j)=a(i,count+1);
            y(i,j)=a(i,count+2);
            z(i,j)=a(i,count+3);
            count=(j*3)+1;
        end
        plot3(x(i,:),y(i,:),z(i,:),'g')
        hold on;
    end
end