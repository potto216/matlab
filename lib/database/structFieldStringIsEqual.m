%This function checks to see if field value strings are equal
%Example of using:
%findList=find(structFieldStringIsEqual(this.nodeDB,@(x) x.name,nodeName));
function results=structFieldStringIsEqual(nodeDB,fieldFunction,valueToTest)
  
  results=arrayfun(@(ndb) strcmp(fieldFunction(ndb),valueToTest),nodeDB);
end