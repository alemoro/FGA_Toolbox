%violinPlot ploting function
% This function is called for bar graphs or boxplot ready for publication
%
% violinPlot(varX, varG, varB) is the minumum required and will plot
% plain boxplots.
% violinPlot(varX, varG, varB, plotT) also accept different plot type,
% use 'dots' to overlay all data points aligned based on week, 'bar' if you
% prefer a bar graph instead of a boxplot, as bar grafs the option 'dots'
% is selected by default.
% violinPlot(___, NAME, VALUE) accept colormap, normalization, yaxis label
function violinPlot(varX, varG, varB, varargin)

bDots = any(strcmpi(varargin, 'dots'));
bNormal = any(strcmpi(varargin, 'normalize'));
bBar = any(strcmpi(varargin, 'bar'));
bViolin = any(strcmpi(varargin, 'violin'));
bLabel = any(strcmpi(varargin, 'label'));
bColor = any(strcmpi(varargin, 'color'));
bFlip = any(strcmpi(varargin, 'flipAxis'));
bExperiment = any(strcmpi(varargin, 'experiment')); % if the table is a collection of multiple experiments
bSecond = any(strcmpi(varargin, 'secondCondition'));
bSame = any(strcmpi(varargin, 'sameFigure'));
beforeAfter = any(strcmpi(varargin, 'beforeAfter'));
bMedian = any(strcmpi(varargin, 'median')); % normalization method, default is mean
bAxes = any(strcmpi(varargin, 'axes')); % declear which axes to plot

if bBar
    bDots = false;
end

if bExperiment
    expFilter = myTable.ExperimentID == varargin{find(strcmpi(varargin, 'experiment'))+1};
    myTable = myTable(expFilter,:);
    varG = varG(expFilter,:);
    varX = varX(expFilter,:);
end
weeks = unique(varB);
nWeek = numel(weeks);
if ~iscategorical(varG)
    varG = categorical(varG);
end
if iscell(varX)
    varX = cell2mat(varX);
end

if ~bSame
     if bAxes
        plotAx = varargin{find(strcmpi(varargin, 'axes'))+1};
    else
        figure('WindowStyle', 'docked');
        plotAx = axes;
        hold on;
     end
else
    plotAx = gca;
    hold on;
end
uniG = unique(varG);
nCond = size(uniG,1);

% assing the variable arguments
if bSecond
    scCond = varargin{find(strcmpi(varargin, 'secondCondition'))+1};
    if size(varX,2) > 1
        varB = repmat(varB,size(varX,2),1);
        varB = varB(:);
        myCond = repmat(varG,size(varX,2),1);
        scCond = varargin{find(strcmpi(varargin, 'secondCondition'))+1};
        if size(varX,1) > size(scCond,1)
            scCond = repmat(scCond, size(varX,1), 1);
            scCond = categorical(scCond(:));
        end
        if beforeAfter
            varG1 = myCond .* scCond;
            varX1 = varX(:);
            uniG = unique(varG1);
        else
            varG = myCond .* scCond;
            varX = varX(:);
            uniG = unique(varG);
        end
        nCond = size(uniG,1);
    else
        if numel(varG) == numel(scCond)
            varG = varG .* categorical(scCond);
            varG = removecats(varG);
            uniG = unique(varG);
            nCond = size(uniG,1);
        else
        end
    end
end

if bNormal
    control = varargin{find(strcmpi(varargin, 'normalize'))+1};
    tempData = varX;
    for w = 1:nWeek
        tempWeek = weeks(w);
        weekFltr = varB == tempWeek;
        if numel(control) == 2
            controlMaxFltr = varG == control(1);
            controlMinFltr = varG == control(2);
            if bMedian
                tempMaxMean = nanmedian(varX(controlMaxFltr & weekFltr));
                tempMinMean = nanmedian(varX(controlMinFltr & weekFltr));
            else
                tempMaxMean = nanmean(varX(controlMaxFltr & weekFltr));
                tempMinMean = nanmean(varX(controlMinFltr & weekFltr));
            end
        else
            controlMaxFltr = varG == control;
            if bMedian
                tempMaxMean = nanmedian(varX(controlMaxFltr & weekFltr));
            else
                tempMaxMean = nanmean(varX(controlMaxFltr & weekFltr));
            end
            tempMinMean = 0;
        end
        tempData(weekFltr) = (varX(weekFltr) - tempMinMean) / (tempMaxMean - tempMinMean);
    end
    varX = tempData;
end

if bLabel
    yLab = varargin{find(strcmpi(varargin, 'label'))+1};
end

if bColor
    cmap = varargin{find(strcmpi(varargin, 'color'))+1};
else
    cmap = colorcube;
end

if beforeAfter
    wisker(varG1, varX1, cmap, plotAx);
else
    wisker(varG, varX, cmap, plotAx);
end
%boxplot(varX, varG, 'Color', cmap(1:nCond,:), 'symbol','')

semC = 'w';
if bBar
    semC = 'k';
    cla;
end
tX=1;
legCond = cell(nCond,1);
if beforeAfter
    nCond = nCond / 2;
    uniG = unique(varG);
end
for c = 1:nCond
    tempCond = uniG(c);
    condFltr = varG == tempCond;
    for s = 1:size(varX,2)
        tempX = varX(condFltr,s);
        if bBar
            patch(plotAx, [tX-.2 tX+.2 tX+.2 tX-.2], [0 0 nanmean(tempX) nanmean(tempX)], cmap(c,:), 'EdgeColor', cmap(c,:), 'FaceAlpha',.3)
        else
            plot(plotAx, [tX-.125 tX+.125], [nanmean(tempX) nanmean(tempX)], 'Color', 'w', 'LineWidth', 2)
        end
        sem = @(x) nanstd(x) ./ sqrt(sum(~isnan(x)));
        plot(plotAx, [tX tX], [(nanmean(tempX)-sem(tempX)) (nanmean(tempX)+sem(tempX))], 'color', semC, 'LineWidth', 2)
        if bDots
            if beforeAfter
                if s == 1
                    nData = numel(tempX);
                    plotX = varX(condFltr,:);
                    plot(plotAx, repmat([tX + 0.15 tX + 0.85], nData, 1)',plotX', 'o-', 'color', cmap(c,:), 'MarkerEdgeColor', cmap(c,:), 'MarkerSize',4,'MarkerFaceColor','w')
                end
            else
                x = linspace(tX - 0.15, tX + 0.15, nWeek);
                for w=1:nWeek
                    tempWeek = weeks(w);
                    weekFltr = varB == tempWeek;
                    if sum(weekFltr & condFltr) > 0
                        y = varX(weekFltr & condFltr,s);
                        plot(plotAx, x(w),y, 'o', 'MarkerEdgeColor', cmap(c,:), 'MarkerSize',4,'MarkerFaceColor','w')
                    end
                end
            end
            legCond{c} = sprintf('%s (%d/%d)', char(tempCond), numel(tempX), nWeek);
        end
%         legCond{c} = sprintf('%s (%d/%d)', char(tempCond), numel(tempX), nWeek);
        legCond{c} = sprintf('%s', char(tempCond));
        tX = tX+1;
    end
    
end
if beforeAfter
    nCond = nCond * 2;
end
box(plotAx, 'off');
set(plotAx, 'TickDir', 'out');
ylim(plotAx, 'auto')
xlim(plotAx, [.5 nCond+.5])
if beforeAfter
    set(plotAx, 'XTick', 1.5:2:nCond+0.5);
    set(plotAx, 'XTickLabel', legCond);
else
    set(plotAx, 'XTick', 1:nCond);
    set(plotAx, 'XTickLabel', legCond);
end
if bLabel
    ylabel(plotAx, yLab);
end
if bFlip
    view([90 90]);
end
end

% wisker plot function
function wisker(varG, varY, cmap, plotAx)
% first divide the data on the varius groups
uniqueG = categories(varG);
nGroup = numel(uniqueG);
% get the data per group and calculate its values
for g=1:nGroup
    tempG = uniqueG(g);
    groupF = varG == tempG;
    tempY = varY(groupF);
    sortY = sort(tempY);
    quantY = quantile(sortY, [0.25 0.5 0.75]);
    minW = quantY(1) - 1.5*(quantY(3)-quantY(1));
    lowW = find(sortY>=minW,1,'first');
    minW = sortY(lowW);
    maxW = quantY(3) + 1.5*(quantY(3)-quantY(1));
    highW = find(sortY<=maxW,1,'last');
    maxW = sortY(highW);
    % plot
    patch(plotAx, [g-.25 g+.25 g+.25 g-.25], [quantY(1) quantY(1) quantY(3) quantY(3)], cmap(g,:), 'FaceAlpha', .3, 'EdgeColor', cmap(g,:));
    plot(plotAx, [g-.25 g+.25], [quantY(2) quantY(2)], 'color', cmap(g,:), 'LineWidth', 2);
    plot(plotAx, [g g], [minW quantY(1)], 'color', cmap(g,:));
    plot(plotAx, [g g], [quantY(3) maxW], 'color', cmap(g,:));
end
end