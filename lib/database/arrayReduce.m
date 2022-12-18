function result=arrayReduce(binaryFun,list)


result=list{1};
for ii=2:numel(list)
    result=binaryFun(result,list{ii});
end

end