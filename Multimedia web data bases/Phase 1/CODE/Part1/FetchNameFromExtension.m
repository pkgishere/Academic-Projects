function [ NameOfFiles ] = FetchNameFromExtension(extension)
%Outputs File with tthe particular extension
%This function takes an argument, extension, and produces a
%list of files with that extension in a present working directory dir as output 
%

%getting name of files
dirList=dir(pwd);
dirIndex =[dirList.isdir];
names={dirList(~dirIndex).name};

%Fetching name of the files with the particular extension 
outNames={};
 for i=1:numel(names)
      [~,name,ext] =fileparts(names{i});
      if isequal(ext,extension)
          outNames{end+1}= strcat(name,ext);
      end
 end 
 NameOfFiles=transpose(outNames);
end

