%This function returns true if the path is absolute
function isAbsolutePathFlag=isAbsolutePath(filePath)
import java.io.File;
fileObject=File(filePath);
isAbsolutePathFlag=fileObject.isAbsolute();
end
