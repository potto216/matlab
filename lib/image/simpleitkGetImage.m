function imMatlab=simpleitkGetImage(imItk)

if imItk.getDimension~=2
    error('Function on works with 2 dimensions.');
end

pixelLocation=org.itk.simple.VectorUInt32(2);
imMatlab=zeros(imItk.getHeight,imItk.getWidth);

for ww=1:imItk.getWidth
    disp(['Processing row ' num2str(ww)]);
    for hh=1:imItk.getHeight
        pixelLocation.set(0,ww-1)
        pixelLocation.set(1,hh-1)
        
        switch(char(imItk.getPixelID.toString))
            case 'sitkUInt8'
                pixelValue=imItk.getPixelAsUInt8(pixelLocation);
            case 'sitkVectorUInt8'
                pixelValue=imItk.getPixelAsVectorUInt8(pixelLocation);
            case 'sitkFloat32'
                pixelValue=imItk.getPixelAsFloat(pixelLocation);
            case 'sitkVectorFloat32'
                pixelValue=imItk.getPixelAsVectorFloat(pixelLocation);
            otherwise
                error(['Pixel type ' char(imItk.getPixelID.toString) ' is not supported.']);
        end
        
        switch class(pixelValue)
            case 'double'
                imMatlab(hh,ww)=pixelValue;
            otherwise
                imMatlab(hh,ww)=pixelValue.get(0);
        end
    end
end
end