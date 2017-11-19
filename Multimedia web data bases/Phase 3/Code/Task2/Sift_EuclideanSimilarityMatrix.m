function [similarityMatrix] = Sift_EuclideanSimilarityMatrix( firstVideo,secondVideo)
%This function takes input two 'special video matrix'[1] and R Value (the r*r cells),and outputs a Intersection similarity Matrix
%   The Matrix returned conatins Frame wise intersection similarity but taking into account the cell wise Histogram Distribution.


firstHeight = size(firstVideo,1);
secondHeight = size(secondVideo,1);
total_frame_v1 = max(firstVideo(:,2));
total_frame_v2 = max(secondVideo(:,2));
total_cell_v1 = max(firstVideo(:,3));
total_cell_v2 =max(secondVideo(:,3));
%secondVideo = secondVideo';

similarityMatrix = zeros(total_frame_v1,total_frame_v2);
f1_count=0;
f2_count=0;

for p=1:total_frame_v1
    f2_count = 0;
    flag_f1 = true;
    for m=1:total_frame_v2
        cell_percent = 0;
        total_cell_count = 0;
        flag_f2 = true;
        for q=1:total_cell_v1
            flag_cell = true;
            vector_match_count = 0;
            vector1=0;
            for y=1:firstHeight
                vectorMatch = [];
                if (firstVideo(y,2)==p) && (firstVideo(y,3)==q)
                    if flag_cell == true
                        total_cell_count = total_cell_count +1;
                    end
                    if flag_cell == true && flag_f1 == true
                        f1_count = f1_count +1;
                    end
                    flag_cell = false;
                    flag_f1 = false;
                    vector1=vector1+1;
                    for n=1:total_cell_v2
                        vector2=0;
                        for z=1:secondHeight
                            if  (secondVideo(z,2)==m)&& (secondVideo(z,3)==n && (firstVideo(y,3) == secondVideo(z,3)))
                                vector2=vector2+1;
                                eucDist = sqrt(sum((firstVideo(y,8:end)-secondVideo(z,8:end)).^2));
                                vectorMatch = cat(2,vectorMatch,eucDist);
                            end
                            if flag_f2 == true
                                f2_count = f2_count +1;
                            end
                            flag_f2 = false;
                        end
                    end
                    vectorMatch = sort(vectorMatch);
                    if (size(vectorMatch,2) > 1)
                        if ( (vectorMatch(1) < 0.8 * vectorMatch(2)))
                            vector_match_count = vector_match_count + 1;
                        else
                        end
                    end
                end
            end
            if (vector1 ~=0 )
                cell_percent = cell_percent + (vector_match_count / vector1);
            end
            
        end
        if total_cell_count ~=0
            similarityMatrix(p,m) =   (cell_percent / total_cell_count);
        end
    end
end

end

