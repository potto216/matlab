function corrVal=corrNoMean(template,target)
template=template-mean(template);
target=target-mean(target);
    corrVal= (template'*target)/sqrt((template'*template)*(target'*target));
end 