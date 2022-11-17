% To convert a line into LeTeX saved in a .txt file


% Input:
%
%        T                       Could be a line or a table
%
%        SaveTxtName             Length of out-of-sample
%
%
% Output:
%


function line2latex(T,SaveTxtName)
    
    % Error detection and default parameters
    if nargin < 1, error('Not enough parameters.'); end
    
    % Parameters
    n_row = size(T,1);
    n_col = size(T,2);

    % Writing the data
    try
        for row = 1:n_row
            temp{1,n_col} = [];
            for col = 1:n_col
                value = T{row,col};
                if isstruct(value), error('Table must not contain structs.'), end
                while iscell(value), value = value{1,1}; end
                if isinf(value), value = '$\infty$'; end
                temp{1,col} = num2str(value);
                if value>chi2inv(0.99,1),temp{1,col} = ['\textbf{',num2str(value),'}$^{***}$'];
                elseif value>chi2inv(0.95,1),temp{1,col} = ['\textbf{',num2str(value),'}$^{**}$'];
                elseif value>chi2inv(0.9,1),temp{1,col} = ['\textbf{',num2str(value),'}$^{*}$'];
                else temp{1,col} = num2str(value);
                end
            end
            fprintf(SaveTxtName,'%s \\\\ \n', strjoin(temp, ' & '));
            clear temp;
        end
    catch
        error('Unknown error. Make sure that table only contains chars, strings or numeric values.');
    end
end


