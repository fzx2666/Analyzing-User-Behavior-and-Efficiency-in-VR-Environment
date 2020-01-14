function [x, y, button, ax] = my_ginputc(varargin)
try
    if verLessThan('matlab', '7.5')
        error('ginputc:Init:IncompatibleMATLAB', ...
            'GINPUTC requires MATLAB R2007b or newer');
    end%¼ì²ématlab°æ±¾
catch %#ok<CTCH>
    error('ginputc:Init:IncompatibleMATLAB', ...
        'GINPUTC requires MATLAB R2007b or newer');
end
p = inputParser();
addOptional(p, 'N', inf, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'integer', 'positive'}));
addParamValue(p, 'FigHandle', [], @(x) numel(x)==1 && ishandle(x));
addParamValue(p, 'Color', 'k', @colorValidFcn);
addParamValue(p, 'LineWidth', 0.5 , @(x) validateattributes(x, ...
    {'numeric'}, {'scalar', 'positive'}));
addParamValue(p, 'LineStyle', '-' , @(x) validatestring(x, ...
    {'-', '--', '-.', ':'}));
addParamValue(p, 'ShowPoints', false, @(x) validateattributes(x, ...
    {'logical'}, {'scalar'}));
addParamValue(p, 'ConnectPoints', true, @(x) validateattributes(x, ...
    {'logical'}, {'scalar'}));
parse(p, varargin{:});
N = p.Results.N;
hFig = p.Results.FigHandle;
color = p.Results.Color;
linewidth = p.Results.LineWidth;
linestyle = p.Results.LineStyle;
showpoints = p.Results.ShowPoints;
connectpoints = p.Results.ConnectPoints;
    function tf = colorValidFcn(in)
   validateattributes(in, {'char', 'double'}, {'nonempty'});
        if ischar(in)
            validatestring(in, {'b', 'g', 'r', 'c', 'm', 'y', 'k', 'w'});
        else
            assert(isequal(size(in), [1 3]) && all(in>=0 & in<=1), ...
                'ginputc:InvalidColorValues', ...
                'RGB values for "Color" must be a 1x3 vector between 0 and 1');
        end
        tf = true;
    end
%--------------------------------------------------------------------------
if isempty(hFig)
    hFig = gcf;
end
hAx = get(hFig, 'CurrentAxes');
if isempty(hAx)
    allAx = findall(hFig, 'Type', 'axes');
    if ~isempty(allAx)
        hAx = allAx(1);
    else
        hAx = axes('Parent', hFig);
    end
end
allHG = findall(hFig);
propsToChange = {...
    'WindowButtonUpFcn', ...
    'WindowButtonDownFcn', ...
    'WindowButtonMotionFcn', ...
    'WindowKeyPressFcn', ...
    'WindowKeyReleaseFcn', ...
    'ButtonDownFcn', ...
    'KeyPressFcn', ...
    'KeyReleaseFcn', ...
    'ResizeFcn'};
validObjects = false(length(allHG), length(propsToChange));
curCallbacks = cell(1, length(propsToChange));
for id = 1:length(propsToChange)
    validObjects(:, id) = isprop(allHG, propsToChange{id});
    curCallbacks{id} = get(allHG(validObjects(:, id)), propsToChange(id));
    set(allHG(validObjects(:, id)), propsToChange{id}, '');
end
curPointer = get(hFig, 'Pointer');
curPointerShapeCData = get(hFig, 'PointerShapeCData');
set(hFig, ...
    'WindowButtonDownFcn', @mouseClickFcn, ...
    'WindowButtonMotionFcn', @mouseMoveFcn, ...
    'KeyPressFcn', @keyPressFcn, ...
    'ResizeFcn', @resizeFcn, ...
    'Pointer', 'custom', ...
    'PointerShapeCData', nan(16, 16));
hInvisibleAxes = axes(...
    'Parent', hFig, ...
    'Units', 'normalized', ...
    'Position', [0 0 1 1], ...
    'XLim', [0 1], ...
    'YLim', [0 1], ...
    'HitTest', 'off', ...
    'HandleVisibility', 'off', ...
    'Visible', 'off');
if showpoints
    if connectpoints
        pointsLineStyle = '-';
    else
        pointsLineStyle = 'none';
    end
    
    selectedPoints = [];
    hPoints = line(nan, nan, ...
        'Parent', hInvisibleAxes, ...
        'HandleVisibility', 'off', ...
        'HitTest', 'off', ...
        'Color', [1 0 0], ...
        'Marker', 'o', ...
        'MarkerFaceColor', [1 .7 .7], ...
        'MarkerEdgeColor', [1 0 0], ...
        'LineStyle', pointsLineStyle);
end
hTooltipControl = text(0, 1, 'HIDE', ...
    'Parent', hInvisibleAxes, ...
    'HandleVisibility', 'callback', ...
    'FontName', 'FixedWidth', ...
    'VerticalAlignment', 'top', ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', [.5 1 .5]);
hTooltip = text(0, 0, 'No points', ...
    'Parent', hInvisibleAxes, ...
    'HandleVisibility', 'off', ...
    'HitTest', 'off', ...
    'FontName', 'FixedWidth', ...
    'VerticalAlignment', 'top', ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 .5]);
resizeFcn();
hCursor = line(nan, nan, ...
    'Parent', hInvisibleAxes, ...
    'Color', color, ...
    'LineWidth', linewidth, ...
    'LineStyle', linestyle, ...
    'HandleVisibility', 'off', ...
    'HitTest', 'off');
x = [];
y = [];
button = [];
ax = [];
uiwait(hFig);
%--------------------------------------------------------------------------
    function mouseMoveFcn(varargin)
   cursorPt = get(hInvisibleAxes, 'CurrentPoint');  
        set(hCursor, ...
            'XData', [0 1 nan cursorPt(1) cursorPt(1)], ...
            'YData', [cursorPt(3) cursorPt(3) nan 0 1]);
    end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
    function mouseClickFcn(varargin)
        if isequal(gco, hTooltipControl)
            tooltipClickFcn();
        else
            updatePoints(get(hFig, 'SelectionType'));
        end
    end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
    function keyPressFcn(obj, edata)  
        key = double(edata.Character);
        if isempty(key)
            return;
        end
        
        switch key
            case 13  
                exitFcn();
                
            case {8, 127}  
                if ~isempty(x)
                    x(end) = [];
                    y(end) = [];
                    button(end) = [];
                    ax(end) = [];
                    
                    if showpoints
                        selectedPoints(end, :) = [];
                        set(hPoints, ...
                            'XData', selectedPoints(:, 1), ...
                            'YData', selectedPoints(:, 2));
                    end
                    
                    displayCoordinates();
                end
                
            otherwise
                updatePoints(key);
                
        end
    end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
    function updatePoints(clickType)
hAx = gca;
        pt = get(hAx, 'CurrentPoint');
        x = [x; pt(1)];
        y = [y; pt(3)];
        ax = [ax; hAx];

        if ischar(clickType)   
            switch lower(clickType)
                case 'open'
                    clickType = 1;
                case 'normal'
                    clickType = 1;
                case 'extend'
                    clickType = 2;
                case 'alt'
                    clickType = 3;
            end
        end
        button = [button; clickType];
        
        displayCoordinates();
        
        if showpoints
            cursorPt = get(hInvisibleAxes, 'CurrentPoint');
            selectedPoints = [selectedPoints; cursorPt([1 3])];
            set(hPoints, ...
                'XData', selectedPoints(:, 1), ...
                'YData', selectedPoints(:, 2));
        end
        if length(x) == N
            exitFcn();
        end
    end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
    function tooltipClickFcn()
   if strcmp(get(hTooltipControl, 'String'), 'SHOW')
            set(hTooltipControl, 'String', 'HIDE');
            set(hTooltip, 'Visible', 'on');
        else
            set(hTooltipControl, 'String', 'SHOW');
            set(hTooltip, 'Visible', 'off');
        end
    end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
    function displayCoordinates()
  if isempty(x)
            str = 'No points';
        else
            str = sprintf('%d: %0.3f, %0.3f\n', [1:length(x); x'; y']);
            k=numel(x);
             text(x(end),y(end),'¡Á','fontsize',15);
             text(x(end)+0.03,y(end),num2str(k));
            str(end) = '';
        end
        set(hTooltip, ...
            'String', str);
    end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
    function resizeFcn(varargin)
     sz = get(hTooltipControl, 'Extent');
        set(hTooltip, 'Position', [0 sz(2)]);
    end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
    function exitFcn()
     for idx = 1:length(propsToChange)
            set(allHG(validObjects(:, idx)), propsToChange(idx), curCallbacks{idx});
     end
        set(hFig, 'Pointer', curPointer);
        set(hFig, 'PointerShapeCData', curPointerShapeCData);
        delete(hInvisibleAxes);
        uiresume(hFig);
    end
%--------------------------------------------------------------------------

end