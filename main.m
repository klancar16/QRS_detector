% get names of all files .mat from /db folder
source_dir = [pwd '/db'];
d = dir([source_dir, '\*.mat']);
n = length(d);
matFiles = char(d.name);

t=cputime();
for i=1:n
    record = matFiles(i, 1:6); %all files are named like sxxxxxm.mat; x is a number
    fileName = sprintf('db/%sm.mat', record);
    m=7;
    idx = QRSChenDetect(fileName,m);
    asciName = sprintf('db/%s.asc',record);
    fid = fopen(asciName, 'wt');
    for j=1:size(idx,2)
        fprintf(fid,'0:00:00.00 %d N 0 0 0\n', idx(1,j) );
    end
    fclose(fid);
    [i n]
end
fprintf('Running time: %f\n', cputime() - t);

% Now convert the .asc text output to binary WFDB format:
% wrann -r record -a qrs <record.asc
% And evaluate against reference annotations (atr) using bxb:
% bxb -r record -a atr qrs
