function toStruct = copyFields(toStruct, fromStruct)
% Copies fields from fromStruct into toStruct without clearing fields,
% which are not existent in toStruct.
% 
% Example:
% A = struct('f1', 1, 'f2', 2, 'f3', 3);
% B = struct('f1', 4, 'f2', 5);
% 
% A = copyFields(A, B)
% 
% toStruct =
% 
%   struct with fields:
% 
%     f1: 4
%     f2: 5
%     f3: 3
%
% --------------------------------------------------
% 2020-08-07, Anatoli Ulmer, anatoli.ulmer@gmail.com

for fn = fieldnames(fromStruct)'
    toStruct.(fn{1}) = fromStruct.(fn{1});
end