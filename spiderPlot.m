function spiderPlot(Data, varargin)
% function spiderPlot(Data,param)
% -------------------------
% Data: matrix with N (observations)x M (angles)
% param: (optional) structure with parameters for plotting configuration
% -- center: mean or median
% -- superior: interval superior value % percentile (e.g. 75)
% -- inferior: interval inferior value % percentile (e.g. 25)
% -- circleRadius: radius of the radar outer circle. Change to hide
% outliers
% -- plotDots: flag to overlay raw data points or not 
% -- angleLabels: numeric or cell array containing labels for each angle
%--------------------------
% David Romero-Bascones 24/04/2020 (@drombas)
% 
% Modifications:
% - 09/09/2022: added labels to each angle

% Set default params
center = 'mean';
superior = 75;
inferior = 25;
circleRadius = max(Data(:));
plotDots = true;
gridWidth = 0.3;
nPoints = 50;
nRing = 3;
jitter = 0.04;
labels = [];

ColorBackground = 'none'; 
ColorGridBack = [220 220 220]./255;
ColorGrid = [151 172 191]./255;
ColorText = [90 100 91]./255;%ColorText = [120 150 160]./255;
ColorFill= [239 92 84]./255;

% Check input parameters
if nargin == 0
    error('SpiderPlot requires at least 1 input');
elseif nargin > 2
    error('Number of input parameters exceeded');
elseif nargin ==2 
    param = varargin{1};
    % Adjust for user params
    if isfield(param,'center')
        center = param.center;
    end
    if isfield(param,'superior')
        superior = param.superior;
    end
    if isfield(param,'inferior')
        inferior = param.inferior;
    end
    if isfield(param,'circleRadius')
        circleRadius = param.circleRadius;
    end
    if isfield(param,'plotDots')
        plotDots = param.plotDots;
    end
    if isfield(param,'angleLabels')
        labels = param.angleLabels;
        if isnumeric(labels)
            labels = arrayfun(@num2str, labels, 'UniformOutput', false);
        end
    end
end

% Compute center line and inferior and superior intervals
switch center
    case 'mean'
        Valmean = mean(Data);
    case 'median'
        Valmean = median(Data);        
    case 'otherwise'
        error('Wrong value for center parameter');
end

ValInf = prctile(Data,inferior);
ValSup = prctile(Data,superior);

% Ge max circle radius and number of directions
rhoMax = circleRadius;
nAngle = size(Data,2);
theta = linspace(0,2*pi - 2*pi/nAngle,nAngle);

% hide points out of the main circle
Data(Data>rhoMax) = nan;


% Prepare grid
set(gca,'Color',ColorBackground);
set(gca,'XColor','none');
set(gca,'YColor','none');
axis equal;

% Draw outer circle
[Xr,Yr] = pol2cart(linspace(0,2*pi - 2*pi/nPoints,nPoints),repmat(rhoMax,1,nPoints));
patch(Xr,Yr,ColorGridBack,'EdgeColor',ColorGrid,'LineWidth',gridWidth);hold on;
Ytext = rhoMax - rhoMax/nRing*0.1;
Xtext = (rhoMax/nRing*(nRing+1) - rhoMax/nRing*nRing)*0.05;
text(Xtext,Ytext,num2str(round(rhoMax/nRing*nRing)),'Color',ColorText,'FontWeight','Bold');
    
% Draw radial lines in each direction
[Xg,Yg] = pol2cart(theta,rhoMax*ones(1,nAngle));
for n=1:nAngle
    plot([0 Xg(n)],[0 Yg(n)],'Color',ColorGrid,'LineWidth',gridWidth); 
end

% Draw Rings with numeric text
for n=1:nRing-1
    [Xr,Yr] = pol2cart(linspace(0,2*pi - 2*pi/nPoints,nPoints),repmat(rhoMax/nRing*n,1,nPoints));
    plot([Xr Xr(1)],[Yr Yr(1)],'Color',ColorGrid,'LineWidth',gridWidth);
    
    Ytext = rhoMax/nRing*n - rhoMax/nRing*0.1;
    Xtext = (rhoMax/nRing*(n+1) - rhoMax/nRing*n)*0.05;
    text(Xtext,Ytext,num2str(round(rhoMax/nRing*n)),'Color',ColorText,'FontWeight','Bold');
end


% Plot data
[X,Y] = pol2cart(theta,Valmean);
[XInf,YInf] = pol2cart(theta,ValInf);
[XSup,YSup] = pol2cart(theta,ValSup);

patch([XSup XSup(1) X X(1)],[YSup YSup(1) Y Y(1)],ColorFill,'FaceAlpha',0.25,'EdgeColor','none');hold on;
patch([X X(1) XInf XInf(1)],[Y Y(1) YInf YInf(1)],ColorFill,'FaceAlpha',0.25,'EdgeColor','none');
p = plot([X X(1)],[Y Y(1)],'Color',ColorFill,'LineWidth',2.5);

cd = [uint8(colormap(hot)*255) uint8(ones(256,1))].';

minVal = min(ValInf);
maxVal = max(ValSup);
range =round((Valmean-minVal)./(maxVal-minVal).*255+1);
range = [range range(1)];
pause(0);
set(p.Edge,'ColorBinding','interpolated','ColorData',cd(:,range));

% Overlay dots
if plotDots
    for n=1:nAngle
        [Xp,Yp] = pol2cart(theta(n)+jitter*randn(1,size(Data,1)),Data(:,n)');
        scatter(Xp,Yp,5,'r','filled','MarkerFaceAlpha',0.3);
    end
end

if ~isempty(labels)
   [Xg, Yg] = pol2cart(theta, 2 + rhoMax*ones(1,nAngle));
   for n=1:nAngle
       text(Xg(n), Yg(n), labels{n}, 'Color', ColorGrid, ...
           'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle'); 
   end
end

