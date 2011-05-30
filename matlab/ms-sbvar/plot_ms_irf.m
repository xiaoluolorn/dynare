function plot_ms_irf(M_,options_,irf,names,title_,varlist)
% function [] = plot_ms_irf(irf,names)
% plots the impulse responses from the output from a ms-sbvar
%
% INPUTS
%   M_
%   irf should be in the form (percentile x horizon x (nvar x nvar)), if banded otherwise
%     ( horizon x (nvar x nvar) )
%
%   names: character list of the names of the variables
%
%   title: optional super title
%
% The element in position (k,i+j*nvars) of ir is the response of the ith 
% variable to the jth shock at horizon k.  Horizon 0 is the contemporaneous 
% response.

% Copyright (C) 2011 Dynare Team
%
% This file is part of Dynare.
%
% Dynare is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Dynare is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <http://www.gnu.org/licenses/>.

    if nargin < 4
        title_ = '';
    end
    
    nc = 2;
    nr = 2;
    nvars = M_.endo_nbr;
    endo_names = M_.endo_names;
    fname = M_.fname;
    
    if isempty(varlist)
        var_list = endo_names(1:M_.orig_endo_nbr,:);
    end
    
    i_var = [];
    names = {};
    tex_names = {};
    m = 1;
    for i = 1:size(var_list)
        tmp = strmatch(var_list(i,:),endo_names,'exact');
        if isempty(tmp)
            error([var_list(i,:) ' isn''t and endogenous variable'])
        end
        i_var = [i_var; tmp];
        tex_name = deblank(M_.endo_names_tex(tmp,:));
        if ~isempty(tex_name)
            names{m} = deblank(var_list(i,:));
            tex_names{m} = tex_name;
            m = m + 1;
        end
    end

    for i=1:M_.exo_nbr
        tex_name = deblank(M_.exo_names_tex(i,:));
        if ~isempty(tex_name)
            names{m} = deblank(M_.exo_names(i,:));
            tex_names{m} = tex_name;
            m = m + 1;
        end
    end
    
    nvar = length(i_var);

    dims = size(irf);
    
    if (length(dims) == 2)
        % Point IRF (horizon x (nvarsxnvars) )
        horizon = dims(1);
        num_percentiles = 1;
    elseif (length(dims) == 3)
        % Banded IRF
        horizon = dims(2);
        num_percentiles = dims(1);
    else
        error('The impulse response matrix passed to be plotted does not appear to be the correct size');
    end
    
    if size(endo_names,1) ~= nvars
        error('The names passed are not the same length as the number of variables')
    end
    
    if num_percentiles == 1
        % loop through the shocks
        for s=1:nvars
            shock = zeros(horizon,nvars);
            for i=1:nvars
                shock(:,i) = irf(:,((i-1) + ((s-1)*nvars)+1));
            end
            plot_point_irf_for_shock(shock,nvars,endo_names,deblank(endo_names(s,:)),title_,fname,options_,names,tex_names);
        end
    else
        for s=1:nvars
            shock = zeros(horizon,nvars,num_percentiles);
            for n=1:num_percentiles
                for i=1:nvars
                    shock(:,i,n) = irf(n,:,((i-1) + ((s-1)*nvars)+1));
                end
            end
            plot_banded_irf_for_shock(shock,nvars,endo_names,deblank(endo_names(s,:)),title_,fname,options_,names,tex_names);
        end
    end
    
end

function [fig] = plot_point_irf_for_shock(irf,nvars,endo_names,shock_name,title_,dirname,options_,names,tex_names)
    fig = figure('Name',title_);
    for k=1:nvars
        subplot(ceil(sqrt(nvars)), ceil(sqrt(nvars)),k);
        plot(irf(:,k))
        disp([endo_names(k,:) ' shock from ' shock_name]);
        title([endo_names(k,:) ' shock from ' shock_name]);
    end
    dyn_save_graph(dirname,['MS-IRF-' shock_name],options_.graph_save_formats, ...
                   options_.TeX,names,tex_names,['IRF ' shock_name]);
end

function [fig] = plot_banded_irf_for_shock(irf,nvars, endo_names, shock_name,title_,dirname,options_,names,tex_names)
    fig = figure('Name',title_);
    npercentiles = size(irf,3);
    for k=1:nvars
        subplot(ceil(sqrt(nvars)), ceil(sqrt(nvars)),k);
        for nn=1:npercentiles
            plot(irf(:,k,nn))
            hold on
        end
        hold off
        disp([endo_names(k,:) ' shock from ' shock_name]);
        title([endo_names(k,:) ' shock from ' shock_name]);
    end
    dyn_save_graph(dirname,['MS-IRF-' shock_name],options_.graph_save_formats, ...
                   options_.TeX,names,tex_names,['IRF ' shock_name]);
end


