function [header,Im] = readB8file(fname)
    fid=fopen(fname, 'r');
%     fileExt = filename(end-3:end);
    if( fid == -1)
        error('Cannot open file');
    end
    % read the header info
    hinfo = fread(fid, 19, 'int32');

    % load the header information into a structure and save under a separate file
    header = struct('filetype', 0, 'nframes', 0, 'w', 0, 'h', 0, 'ss', 0, 'ul', [0,0], 'ur', [0,0], 'br', [0,0], 'bl', [0,0], 'probe',0, 'txf', 0, 'sf', 0, 'dr', 0, 'ld', 0, 'extra', 0);
    header.filetype = hinfo(1);
    header.nframes = hinfo(2);
    header.w = hinfo(3);
    header.h = hinfo(4);
    header.ss = hinfo(5);
    header.ul = [hinfo(6), hinfo(7)];
    header.ur = [hinfo(8), hinfo(9)];
    header.br = [hinfo(10), hinfo(11)];
    header.bl = [hinfo(12), hinfo(13)];
    header.probe = hinfo(14);
    header.txf = hinfo(15);
    header.sf = hinfo(16);
    header.dr = hinfo(17);
    header.ld = hinfo(18);
    header.extra = hinfo(19);
    header.nframes = 1;
    sampleSelect = 1:header.h;
    Im =uint8(zeros(length(sampleSelect),header.w,header.nframes));
    % load the data and save into individual .mat files
     for frame_count = 1:header.nframes
         [v,count] = fread(fid,header.w*header.h,'uint8');
         if (count<header.w*header.h)
             Im(:,:,frame_count) = uint8(zeros(length(sampleSelect),header.w));
         else
            temp = uint8(reshape(v,header.w,header.h));
            Im(:,:,frame_count) = imrotate(temp, -90); 
         end
     end

    fclose(fid);
    clear v;