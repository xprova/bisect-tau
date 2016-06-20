function prepareIncludeDUT(cirFile)

fid = fopen('./spice/dut_include.cir', 'w');

fprintf(fid, '.include "%s"', cirFile);

fclose(fid);

end