% Get folder name to save results and set folder if it does not exist
%
% Input:
%        Index_Name              Index name, like "SP500", "DAX" or "FTSE"
%
%        Working_Date            To control version, like '_20220811' for
%                                date 20220811 of running time
%
%
% Output:
%
%    results_folder              Folder name to save results

function results_folder = get_results_folder(Index_Name,Working_Date,varargin)

parseObj = inputParser;
functionName='Save_VolFcst_to_Mat';
addParameter(parseObj,'Window_Size',750,@(x)validateattributes(x,{'numeric'},{'scalar','integer','positive'},functionName));
addParameter(parseObj,'Cluster_Min_Length',50,@(x)validateattributes(x,{'numeric'},{'scalar','integer','positive'},functionName));
addParameter(parseObj,'Innovation_Distribution','NORMAL',@(x)validateattributes(x,{'string','char'},{''},functionName));
parse(parseObj,varargin{:});
window_size=parseObj.Results.Window_Size;
innovation_distribution=parseObj.Results.Innovation_Distribution;


results_folder=['results_',[innovation_distribution,'_',Index_Name,'_size',num2str(window_size),'_',Working_Date]];
[~,~]=mkdir(results_folder); 
addpath(results_folder);

end
