% Print table as latex into a txt file
%
% Input:
%
%        T                       Table
%
%        ftxt                    Txt file name

function table2latex(T,ftxt)
    
    % Error detection and default parameters
    if nargin < 1, error('Not enough parameters.'); end
    if ~istable(T), error('Input must be a table.'); end
    
    % Parameters
    n_row = size(T,1);
    n_col = size(T,2);
    col_spec = [];
    for c = 1:n_col, col_spec = [col_spec 'l']; end
    col_names = strjoin(T.Properties.VariableNames, ' & ');
    row_names = T.Properties.RowNames;
    if ~isempty(row_names)
        col_spec = ['l' col_spec]; 
        col_names = ['& ' col_names];
    end
    
    % Writing header
    fprintf(ftxt,'\\begin{tabular}{%s}\n', col_spec);
    fprintf(ftxt,'%s \\\\ \n', col_names);
    fprintf(ftxt,'\\hline \n');
    
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
            end
            if ~isempty(row_names)
                temp = [row_names{row}, temp];
            end
            fprintf(ftxt,'%s \\\\ \n', strjoin(temp, ' & '));
            clear temp;
        end
    catch
        error('Unknown error. Make sure that table only contains chars, strings or numeric values.');
    end
    
    % Closing the file
    fprintf(ftxt,'\\hline \n');
    fprintf(ftxt,'\\end{tabular}');
end

