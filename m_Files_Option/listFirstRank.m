function optionFirstRank = listFirstRank(OptionSet)

optionFirstRank = 1;
for i = 2 : size(OptionSet,1)
    if OptionSet(i,10) ~= OptionSet(i-1,10) || OptionSet(i,5) ~= OptionSet(i-1,5)
        optionFirstRank = [optionFirstRank; i]; %#ok<AGROW>
    end
end