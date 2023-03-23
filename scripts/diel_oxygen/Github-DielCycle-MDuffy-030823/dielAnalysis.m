
%Put the code you run in this script

%Example data from Barone script
x = 736497 + [0.1 0.25 0.4 0.7 1.1 1.25 1.35 1.65 1.8 2.05 2.15 2.45 2.6 2.9];
y = 200 + [0.121 -0.240 -0.223 0.259 -0.017 -0.051 -0.107 0.307 0.324 0.063 -0.026 -0.226 0.426 0.373];

%Run function with Megan's versions (minor updates from Hilary for typo issues)
[rates_md,residuals_md,varmat_md,fitline_md] = barone_md(x,y,22.75,-158,-10);
