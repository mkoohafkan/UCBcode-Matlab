function Out = csv2struct(filename)
% Copyright (c) 2009, Jaroslaw Tuszynski
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
%     * Redistributions of source code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright 
%       notice, this list of conditions and the following disclaimer in 
%       the documentation and/or other materials provided with the distribution
%       
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.


%CSV2STRUCT reads Excel's files stored in .xls or .csv file formats and 
% stores results as a struct.
%
% DESCRIPTION
% The Excel file is assumed to have a single header row. The output struct
% will have a field for each column and the field name will be based on the
% column name read from the header.
%
% Unlike csvread, csv2struct is able to read files with both text and
% number fields. Unlike xlsread, csv2struct is able to read .csv files 
% with more than 65536 rows.
% 
% See also:
%   MATLAB's csvread and xlsread functions
%   xml_read from my xml_io_tools which creates struct out of xml files
%
% Written by Jarek Tuszynski, SAIC, jaroslaw.w.tuszynski_at_saic.com
% Code covered by BSD License

%% read xls file with a single header row
[tmp tmp raw] = xlsread(filename);
clear tmp
nRow = size(raw,1);
nCol = size(raw,2);
header = raw(1,:);
raw(1,:) = [];

%% Split data into txt & num parts
format = '';
num = [];
txt = [];
for c = 1:nCol
  col = raw(:,c);
  ColNumeric(c) = true;
  for r = 1:nRow-1
    if(~isnumeric(col{r}) || isnan(col{r})), ColNumeric(c) = false; break; end
  end
  if (ColNumeric(c)), 
    num    = [num cell2mat(col)];
    format = [format '%f']; 
  else
    txt    = [txt col];
    format = [format '%s']; 
  end
end
clear raw

%% In case of csv file with more than 2^16 rows read the rest of the file
[tmp tmp ext] = fileparts(filename);
if (nRow==2^16 && strcmpi(ext, '.csv')),
  % read the rest of the file
  fid = fopen(filename);
  for i=1:2^16, fgetl(fid); end
  data = textscan(fid, format, 'Delimiter',',', 'CollectOutput', 1);
  fclose(fid);
  % concatenate to txt and num 
  ridx = nRow-1 + (1:size(data{1},1));
  num2=[]; txt2=[];
  for i = 1:length(data)
    if isnumeric(data{i}), num2 = [num2 data{i}]; end
    if iscell   (data{i}), txt2 = [txt2 data{i}]; end
  end
  txt(ridx,:) = txt2;
  num(ridx,:) = num2;
  clear data
end

%% Create struct with fields derived from column names from header
iNum = 1;
iTxt = 1;
for c=1:nCol
  if ischar(header{c})
    name = strtrim(header{c});
    name(name==' ') = '_';
    name = genvarname(name);
  else
    name = char('A'-1+i);
  end
  
  if (ColNumeric(c))
    Out.(name) = num(:,iNum);
    iNum = iNum+1;
  else
    Out.(name) = txt(:,iTxt);
    iTxt = iTxt+1;
  end
end
