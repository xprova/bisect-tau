function lines = getFile(file)

fid = fopen(file);

lines = {};

if fid == -1

    error('could not read file %s', file);

else

    while ~feof(fid)

        lines{end+1} = fgetl(fid);

    end

    fclose(fid);

end

end