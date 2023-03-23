function rates = dielFit(dates,conc,lat,lon,timezone,EmaxEk,EmaxEb,alpha)
%
% function rates = dielFit(dates,conc,lat,lon,timezone)
%          rates = dielFit(dates,conc,lat,lon,timezone,EmaxEk,EmaxEb)
%          rates = dielFit(dates,conc,lat,lon,timezone,EmaxEk,EmaxEb,alpha)
%
%   Computes gross production and respiration rates from diel cycles of
%   oxygen or particle concentration using three models:
%       1. Linear model - constant production during daytime
%       2. Sinusoidal model - production scales linearly with light intensity
%       3. P vs. E model - includes light saturation and photoinhibition
%
%   This function requires Optimization Toolbox, Statistics Toolbox, and 
%   the routine suncycle.m to compute solar elevation
%   (available at http://mooring.ucsd.edu/software/matlab/doc/toolbox/geo/suncycle.html)
%
% INPUT:
%   dates: local date and time in Matlab format (datenum)
%   conc: concentration of oxygen or particles at each value of dates
%   lat: latitude in degrees North (Station ALOHA = 22.75)
%   lon: longitude in degrees East (Station ALOHA = -158)
%   timezone: hours from GMT time to local time (Station ALOHA = -10)
%   EmaxEk (optional): light saturation parameter, maximum daily irradiance divided by Ek (DEFAULT = 1)
%   EmaxEb (optional): photoinhibition parameter (DEFAULT = 0)
%   alpha (optional): defines level of percent confidence intervals as 100*(alpha-1) (DEFAULT = 0.05)
% OUTPUT:
%   rates: a table containing the values of gross production and
%       respiration for the three models plus fit statistics (coefficient
%       of determination, p-value, 95% confidence intervals for GPP and R).
%       Rate units are the same as input variable 'conc' per day.
% EXAMPLE:
%   x = 736497+(0:0.1:2.9);
%   y = [5.5 4.5 3.8 4.0 5.4 6.4 7.7 8.3 8 6 5.3 4.4 4 4.2 5.6 6.7 7.9 ...
%        8.4 8.1 6.3 5.5 4.8 4 4.0 5.6 6.3 8 8.4 8.5 6.9];
%   rates = dielFit(x,y,22.75,-158,-10);
%
% ACKNOWLEDGEMENT:
% This routine builds on code provided by David Nicholson and on the method
% published in:
% Nicholson, D. P., S. T. Wilson, S. C. Doney, and D. M. Karl (2015),
% Quantifying subtropical North Pacific gyre mixed layer primary
% productivity from Seaglider observations of diel oxygen cycles. Geophys.
% Res. Lett., 42, 4032?4039. doi: 10.1002/2015GL063065.
%
% VERSION HISTORY
%   r0.12: adds computation of 95% confidence intervals using nlparci.m
%   r0.13: the percent level for confidence intervals can now be assigned
%
% Benedetto Barone - Oct 10, 2016 - Revision 0.13

% Set default parameters for P vs E curve
if nargin < 8, alpha = 0.05; end% 95% confidence intervals
if nargin < 7, EmaxEb = 0; end % no photoinhibition
if nargin < 6, EmaxEk = 1; end % Ek = maximum daily irradiance

nt = 240; % number of time points per day
% Extract solar elevation cycle
[~,t,~,z] = suncycle(lat,lon,nanmean(dates) - timezone/24,nt);
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
% Respiration model (common for the three production models)
Rmod = -ones(nt+1,1);

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
    Rmod = [Rmod; repmat(Rmod(2:end),nday-1,1)];
end

xfit = dates - fix(min(dates)); yfit = conc;
% Costfunctions  for the 3 models
costfun_lin = @(param_lin) interp1(tt,param_lin(1)+cumtrapz(tt,param_lin(2)*Plin+param_lin(3)*Rmod),xfit)-yfit;
costfun_sin = @(param_sin) interp1(tt,param_sin(1)+cumtrapz(tt,param_sin(2)*Psin+param_sin(3)*Rmod),xfit)-yfit;
costfun_sat = @(param_sat) interp1(tt,param_sat(1)+cumtrapz(tt,param_sat(2)*Psat+param_sat(3)*Rmod),xfit)-yfit;
% Parameter optimization
opts = optimset('Algorithm','trust-region-reflective','TolFun',1e-9,'TolX',1e-9,'MaxIter',40000,'MaxFunEval',20000); %optimization options
[par_lin,resnorm_lin,residual_lin,exitflag,output,lambda,jacobian_lin] = lsqnonlin(costfun_lin,[mean(conc) 1 1],[-Inf 0 0],[Inf Inf Inf],opts);
ci_lin = nlparci(par_lin,residual_lin,'jacobian',jacobian_lin,'alpha',alpha);
[par_sin,resnorm_sin,residual_sin,exitflag,output,lambda,jacobian_sin] = lsqnonlin(costfun_sin,[mean(conc) 1 1],[-Inf 0 0],[Inf Inf Inf],opts);
ci_sin = nlparci(par_sin,residual_sin,'jacobian',jacobian_sin,'alpha',alpha);
[par_sat,resnorm_sat,residual_sat,exitflag,output,lambda,jacobian_sat] = lsqnonlin(costfun_sat,[mean(conc) 1 1],[-Inf 0 0],[Inf Inf Inf],opts);
ci_sat = nlparci(par_sat,residual_sat,'jacobian',jacobian_sat,'alpha',alpha);

% Model statistics
y_lin = interp1(tt,par_lin(1)+cumtrapz(tt,par_lin(2)*Plin+par_lin(3)*Rmod),xfit);
y_sin = interp1(tt,par_sin(1)+cumtrapz(tt,par_sin(2)*Psin+par_sin(3)*Rmod),xfit);
y_sat = interp1(tt,par_sat(1)+cumtrapz(tt,par_sat(2)*Psat+par_sat(3)*Rmod),xfit);
[r_temp,p_temp] = corrcoef(yfit,y_lin);
rsq_lin = r_temp(2)^2; pval_lin = p_temp(2);
[r_temp,p_temp] = corrcoef(yfit,y_sin);
rsq_sin = r_temp(2)^2; pval_sin = p_temp(2);
[r_temp,p_temp] = corrcoef(yfit,y_sat);
rsq_sat = r_temp(2)^2; pval_sat = p_temp(2);

% Output variable
rates = [par_lin(2:3);par_sin(2:3);par_sat(2:3)];
rates = table(rates(:,1),rates(:,2),[rsq_lin;rsq_sin;rsq_sat],[pval_lin;pval_sin;pval_sat]);
rates.Properties.VariableNames = {'GPP','Res','R2','p'};
rates.GPPci = [ci_lin(2,:);ci_sin(2,:);ci_sat(2,:)];
rates.Resci = [ci_lin(3,:);ci_sin(3,:);ci_sat(3,:)];
rates.Properties.RowNames = {'linear','sinusoidal','P vs E'};

% Plot results
yy_lin = par_lin(1)+cumtrapz(tt,par_lin(2)*Plin+par_lin(3)*Rmod);
yy_sin = par_sin(1)+cumtrapz(tt,par_sin(2)*Psin+par_sin(3)*Rmod);
yy_sat = par_sat(1)+cumtrapz(tt,par_sat(2)*Psat+par_sat(3)*Rmod);
plot(xfit,yfit,'ko',tt,[yy_lin yy_sin yy_sat])
xlabel('decimal day'); ylabel('concentration')
set(gca,'Fontsize',18)
lg = legend('data points','linear model','sinusoidal model','P vs E model','location','NorthWest'); set(lg,'Fontsize',18)
xlim([min(xfit) max(xfit)])

end

