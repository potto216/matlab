
function [ kullbackLeibler1To2,kullbackLeibler2To1,pdf1, pdf2] = kullbackLeibler( reg1,reg2,numberOfBins )
%KULLBACKLEIBLER Computes the Kullback-Leibler divergence.  This is not a true distance measurement.
%INPUTS
%numberOfBins - this is the number of bins for the histograms

switch(nargin)
    case 2
        numberOfBins= max(floor(length(reg1)/16),5);  %assume samples per bin
    case 3
        %do nothing
    otherwise
        error('Invalid number of input arguments.');
end

if ~isvector(reg1) || ~isvector(reg2)
    error('Both reg1 and reg2 must be vectors');
end
        [pdf1,centers1]=hist(reg1,numberOfBins); 
        pdf1=pdf1(:);
        [pdf1]=histc(reg1,centers1);
        [pdf2]=histc(reg2,centers1);
        
        
        pdf2(pdf2==0)=1;
        pdf1(pdf1==0)=1;
        
        pdf1=pdf1/sum(pdf1);
        pdf2=pdf2/sum(pdf2);
        
        rr1=pdf1./pdf2;
        rr1(rr1<1)=1;        

        rr2=pdf2./pdf1;
        rr2(rr2<1)=1;        

        kullbackLeibler1To2=sum(pdf1.*log(rr1));
        kullbackLeibler2To1=sum(pdf2.*log(rr2));


end

