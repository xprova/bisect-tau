function prepareBisectionParams(d_time)

fid = fopen('spice/bisection-params.cir', 'w');

fprintf(fid, '.param d_time = %1.10fn', d_time / 1e-9);

fclose(fid);

end