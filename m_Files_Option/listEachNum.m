function optionEachNum = listEachNum(OptionSet,optionFirstRank)

optionEachNum = zeros(size(optionFirstRank)); % optionEachNum��ʾÿ����Ȩ��������
for i = 1 : size(optionFirstRank,1) -1
    optionEachNum(i) = optionFirstRank(i+1) - optionFirstRank(i);
end
optionEachNum(end) = size(OptionSet,1)-optionFirstRank(end) + 1;