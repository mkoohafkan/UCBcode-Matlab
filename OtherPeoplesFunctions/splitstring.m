% Copyright (c) 2012, Ivar Eskerud Smith
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


function rv = splitstring( str, varargin )
%SPLITSTRING Split string into cell array
%    ARRAY = SPLITSTRING( STR, DELIM, ALLOWEMPTYENTRIES ) splits the
%    character string STR, using the delimiter DELIM (which must be a
%    character array). ARRAY is a cell array containing the resulting
%    strings. If DELIM is not specified, space delimiter is assumed (see
%    ISSPACE documentation). ALLOWEMPTYENTRIES should be a logical single
%    element, specifying weather empty elements should be included in the
%    results. If not specified, the value of ALLOWEMPTYENTRIES is false.
%
%    Example:
%         arr = splitstring( 'a,b,c,d', ',' )

delim = '';
AllowEmptyEntries = false;

if numel(varargin) == 2
        delim = varargin{1};
        AllowEmptyEntries = varargin{2};
elseif numel(varargin) == 1
        if islogical(varargin{1})
                AllowEmptyEntries = varargin{1};
        else
                delim = varargin{1};
        end
end

if isempty(delim)
        delim = ' ';
        ind = find( isspace( str ) );
else
        ind = strfind( str, delim );
end

startpos = [1, ind+length(delim)];
endpos = [ind-1, length(str)];

rv = cell( 1, length(startpos) );
for i=1:length(startpos)
        rv{i} = str(startpos(i):endpos(i));
end

if ~AllowEmptyEntries
        rv = rv( ~strcmp(rv,'') );
end
