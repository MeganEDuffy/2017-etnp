function [rates,residuals,varmat,fitline] = dielFit(dates,conc,lat,lon,timezone,EmaxEk,EmaxEb,alpha)
%
% Computes rates of gross production and community respiration from diel
% cycles of oxygen concentration thorough ordinary linear least squares.
% Parameter confidence intervals and the variance-covariance matrix are
% computed via bootstrapping of residual with 200 iterations
% Residual autocorrelation is tested using the Durbin-Watson test.
%
% Three models are used for rate estimation:
% 1. Linear model - constant production during daytime
% 2. Sinusoidal model - production scales linearly with light intensity
% 3. P vs. E model - includes light saturation and photoinhibition
%
% This function requires MATLAB ver 2013b or above, the Statistics and
% Machine Learning Toolbox, and the routine suncycle.m to compute solar
% elevation
% (by C. Begler, available at
% http://mooring.ucsd.edu/software/matlab/doc/toolbox/geo/suncycle.html)
%
% INPUT:
% dates: local date and time in Matlab format (datenum)
% conc: concentration of oxygen or particles at each value of dates
% lat: latitude in degrees North (Station ALOHA = 22.75)
% lon: longitude in degrees East (Station ALOHA = -158)
% timezone: hours from GMT time to local time (Station ALOHA = -10)
% EmaxEk (optional): light saturation parameter, maximum daily irradiance
% divided by Ek (DEFAULT = 1)
% EmaxEb (optional): photoinhibition parameter (DEFAULT = 0)
% alpha (optional): defines level of percent confidence intervals as
% 100*(alpha-1) (DEFAULT = 0.317)
% OUTPUT:
% rates: a table containing the values of gross production and
% respiration for the three models plus fit statistics (coefficient
% of determination, p-value, (1-alpha)x100% confidence intervals for
% GPP and R, p-value from the Durbin-Watson test).
% Rate units are the same as input variable 'conc' per day.
% residuals: a matrix with the residuals from the three models reported
% in separate rows: linear on the 1st row, sinusoidal on the second
% row, and P vs.E on the third row
% varmat: a structure with the variance-covariance matrix from the three
% models. The variance-covariance matrix is obtained using the
% parameters obtained from bootstrapping the residuals
% fitline: a table with the model line obtained using the three models
% and the vector of the dates with 240 points per day
% EXAMPLE:
% x = 736497 + [0.1 0.25 0.4 0.7 1.1 1.25 1.35 1.65 1.8 2.05 2.15 2.45 2.6
% 2.9];
% y = 200 + [0.121 -0.240 -0.223 0.259 -0.017 -0.051 -0.107 0.307 0.324
% 0.063 -0.026 -0.226 0.426 0.373];
% [rates,residuals,varmat,fitline] = dielFit(x,y,22.75,-158,-10);
%
% ACKNOWLEDGEMENT:
% This routine builds on code provided by David P. Nicholson (WHOI).
%
% REFERENCES:
% Draper, N. R., and H. Smith, (2014), Applied regression analysis, Third
% ed. John Wiley & Sons. doi: 10.1002/9781118625590
%
% Durbin, J., and G. S. Watson, (1950), Testing for serial correlation in
% least squares regression. I, Biometrika, 37, 409?428,
% doi: 10.1093/biomet/37.3-4.409.
%
% Nicholson, D. P., S. T. Wilson, S. C. Doney, and D. M. Karl (2015),
% Quantifying subtropical North Pacific gyre mixed layer primary
% productivity from Seaglider observations of diel oxygen cycles. Geophys.
% Res. Lett., 42, 4032?4039. doi: 10.1002/2015GL063065.
%
% VERSION HISTORY
% r0.11: First release (non-linear least squares)
% r0.12: Adds computation of 95% confidence intervals using nlparci.m
% r0.13: The percent level for confidence intervals can now be assigned
% r0.14: Change method to linear least squares with nonnegativity
%constraints
% Bootstrapping residuals to compute confidence intervals
% Adds p-value from Durbin-Watson test (residual autocorrelation)
% r0.15: Change method to ordinary linear least squares
% Input dates and conc now accept NaNs that are removed from the
% vector before the fit
% r0.16: Output 'rates' now contains third fit parameter, C0
% New output variable 'fitline' with lines from fit results
% r0.17: Computation of variance-covariance matrix (output 'varmat')
% 'alpha' default is now 0.317
% r0.18: Computation of variance-covariance matrix is now done by
% bootstrapping the residuals
%
% Benedetto Barone - September 2018 - Revision 0.18

% Set default parameters for P vs E curve
if nargin < 8, alpha = 0.317; end % 68.3% confidence intervals
if nargin < 7, EmaxEb = 0; end % no photoinhibition
if nargin < 6, EmaxEk = 1; end % Ek = maximum daily irradiance

nt = 240; % number of time points per day
% Extract solar elevation cycle
[~,t,~,z] = suncycle_md(lat,lon,nanmean(dates) - timezone/24,nt);
% Transform t in local time and sort
t = rem(t + timezone/24,1);
[t,ind_row] = sort(t);
% Normalized light intensity from solar elevation (1 is maximum light, Emax)
z = z(ind_row);
z(z < 0) = 0;
Erel = sind(z);

tt = linspace(0,1,nt+1)';
% 1. Linear production model
Plin = zeros*t; Plin(Erel>0) = 1;
Plin = interp1(t,Plin,tt,'linear','extrap');
Plin = Plin./trapz(tt,Plin);
% 2. Sinusoidal producion model (linear with light)
Psin = Erel;
Psin = interp1(t,Psin,tt,'linear','extrap');
Psin = Psin./trapz(tt,Psin);
% 3. PvsE producion model
Psat = (1-exp(-EmaxEk.*Erel)).*exp(-EmaxEb.*Erel);
Psat = interp1(t,Psat,tt,'linear','extrap');
Psat = Psat./trapz(tt,Psat);

% Allow model fit on multiple days
nday = max(dates - min(fix(dates)));
nday = ceil(nday);
if nday > 1
tt_new = tt;
    for i = 2:nday
        tt_new = [tt_new; tt(2:end)+(i-1)];
    end
    tt = tt_new;
    Plin = [Plin; repmat(Plin(2:end),nday-1,1)];
    Psin = [Psin; repmat(Psin(2:end),nday-1,1)];
    Psat = [Psat; repmat(Psat(2:end),nday-1,1)];
end

i_nan = isnan(dates) | isnan(conc);
xfit = dates(~i_nan) - fix(min(dates(~i_nan))); yfit = conc(~i_nan);
% Define fit type using Linear Model Terms
Alin = [ones(length(xfit),1) interp1(tt,cumtrapz(tt,Plin),xfit)' -xfit'];
Asin = [ones(length(xfit),1) interp1(tt,cumtrapz(tt,Psin),xfit)' -xfit'];
Asat = [ones(length(xfit),1) interp1(tt,cumtrapz(tt,Psat),xfit)' -xfit'];
% Fit moddels
par_lin = Alin\yfit';
par_sin = Asin\yfit';
par_sat = Asat\yfit';
% Residuals
res_lin = yfit'-Alin*par_lin;
res_sin = yfit'-Asin*par_sin;
res_sat = yfit'-Asat*par_sat;
% Y from the models
y_lin = Alin*par_lin;
y_sin = Asin*par_sin;
y_sat = Asat*par_sat;
% Bootstrap residual to compute parameter confidence intervals (200
%iterations)
boot_lin = bootstrp(200,@(bootr) Alin\(y_lin+bootr),res_lin);
boot_sin = bootstrp(200,@(bootr) Asin\(y_sin+bootr),res_sin);
boot_sat = bootstrp(200,@(bootr) Asat\(y_sat+bootr),res_sat);
% Confidence intervals
ci_lin = [prctile(boot_lin,(alpha/2)*100)' prctile(boot_lin,(1-alpha/2)*100)'];
ci_sin = [prctile(boot_sin,(alpha/2)*100)' prctile(boot_sin,(1-alpha/2)*100)'];
ci_sat = [prctile(boot_sat,(alpha/2)*100)' prctile(boot_sat,(1-alpha/2)*100)'];
% Model statistics (R^2 and p value)
[r_temp,p_temp] = corrcoef(yfit,y_lin);
rsq_lin = r_temp(2)^2; pval_lin = p_temp(2);
[r_temp,p_temp] = corrcoef(yfit,y_sin);
rsq_sin = r_temp(2)^2; pval_sin = p_temp(2);
[r_temp,p_temp] = corrcoef(yfit,y_sat);
rsq_sat = r_temp(2)^2; pval_sat = p_temp(2);
% Variance-covariance matrix from bootstrap
varmat.lin = cov(boot_lin);
varmat.sin = cov(boot_sin);
varmat.sat = cov(boot_sat);
% Durbin-Watson test for residual autocorrelation
[pdw_lin,~] = dwtest(res_lin,Alin);
[pdw_sin,~] = dwtest(res_sin,Asin);
[pdw_sat,~] = dwtest(res_sat,Asat);
% Output variables
rates = [par_lin(2:3)';par_sin(2:3)';par_sat(2:3)'];
rates = table(rates(:,1),rates(:,2),[par_lin(1);
par_sin(1);par_sat(1)],[rsq_lin;rsq_sin;rsq_sat],[pval_lin;pval_sin;pval_sat]);
rates.Properties.VariableNames = {'GPP','CR','C0','R2','p'};
rates.GPPci = [ci_lin(2,:);ci_sin(2,:);ci_sat(2,:)];
rates.CRci = [ci_lin(3,:);ci_sin(3,:);ci_sat(3,:)];
rates.C0ci = [ci_lin(1,:);ci_sin(1,:);ci_sat(1,:)];
rates.pdw = [pdw_lin; pdw_sin; pdw_sat];
rates.Properties.RowNames = {'linear','sinusoidal','P vs E'};
residuals = [res_lin'; res_sin' ; res_sat'];
% Plot results
yy_lin = par_lin(1)+cumtrapz(tt,par_lin(2)*Plin)-par_lin(3)*tt;
yy_sin = par_sin(1)+cumtrapz(tt,par_sin(2)*Psin)-par_sin(3)*tt;
yy_sat = par_sat(1)+cumtrapz(tt,par_sat(2)*Psat)-par_sat(3)*tt;
plot(xfit,yfit,'ko',tt,[yy_lin yy_sin yy_sat],'MarkerFaceColor',[0.7 0.7 0.7])
xlabel('decimal day'); ylabel('concentration')
set(gca,'Fontsize',18)
lg = legend('data points','linear model','sinusoidal model','P vs E model','location','NorthWest'); set(lg,'Fontsize',18)
xlim([min(xfit) max(xfit)])
% Fit line output
fitline = table(tt+fix(min(dates(~i_nan))), yy_lin, yy_sin, yy_sat);
fitline.Properties.VariableNames = {'date','linear','sinusoidal','PvsE'};
end