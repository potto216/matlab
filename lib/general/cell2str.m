function strOut=cell2str(cellArray)
strOut='';
for ii=1:length(cellArray)
    strOut=[strOut cellArray{ii}];
end

end