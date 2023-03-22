function rasterPlot(varY, varargin)
%RASTERPLOT Create raster plots based on data and inputs
%   RASTERPLOT(VARY) plots the data in varY as a n-by-m with dots and each line separated by 1 unit

% First check the arguments
bAxes = false | any(strcmpi(varargin, 'axes'));
bVarX = false | any(strcmpi(varargin, 'varX'));
bArea = false | any(strcmpi(varargin, 'area'));
bThreshold = false | any(strcmpi(varargin, 'threshold'));
bXLabel = false | any(strcmpi(varargin, 'xlabel'));
bYLabel = false | any(strcmpi(varargin, 'ylabel'));

% Get the axes were to plot the data
if bAxes
    axPlot = varargin{find(strcmpi(varargin, 'axes'))+1};
else
    axPlot = axes;
end
hold(axPlot, 'on');

% The data should be divided in column (one cell per column). Most likely there are more frames than points
if size(varY,1) < size(varY,2)
    varY = varY';
end
if bVarX
    varX = varargin{find(strcmpi(varargin, 'varX'))+1};
else
    varX = 1:size(varY,1);
end

% See if we need to plot the area underneath the raster and start the plot
if bArea
    areaRaster = varY;
    areaRaster(~isnan(areaRaster)) = 1;
    areaRaster(isnan(areaRaster)) = 0;
    areaRaster = sum(areaRaster,2);
    smoothWindow = gausswin(10);
    smoothWindow = smoothWindow / sum(smoothWindow);
    areaRaster = filter(smoothWindow, 1, areaRaster);
    area(axPlot, varX, areaRaster, 'FaceColor', 'k', 'FaceAlpha', 0.3, 'EdgeColor', 'none')
end

% See if we need a threshold and plot it
if bThreshold
    thr = varargin{find(strcmpi(varargin, 'threshold'))+1};
    isActive = sum(any(~isnan(varY)));
    plot(axPlot, varX, ones(numel(varX),1)*thr*isActive, '--r')
end

% Now plot the actual data
plot(axPlot, varX, varY, '-k')

% Garnish the plot
axPlot.Box = 'off';
axPlot.TickDir = 'out';
if bXLabel
    xlabel(axPlot, varargin{find(strcmpi(varargin, 'xlabel'))+1});
end
if bYLabel
    ylabel(axPlot, varargin{find(strcmpi(varargin, 'ylabel'))+1});
end
end