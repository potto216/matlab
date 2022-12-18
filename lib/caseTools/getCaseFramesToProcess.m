%returns the valid frames in a case (frame number is zero based)
function framesToProcess=getCaseFramesToProcess(metadata)

framesToProcess=metadata.validFramesToProcess;

if isempty(framesToProcess)
    [header] = ultrasonixGetInfo(metadata.rfFilename);
    framesToProcess=(0:(header.nframes-1)); %remeber frame number is zero based
end