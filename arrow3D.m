classdef arrow3D < handle 
    % A = arrow3D(XData, YData, ZData)
    %   arrow3D is a ...3D arrow with a "solid" head. It is a graphical 
    %   object composed by a  line and a 3D surface, which represents the 
    %   arrow head.
    %   arrow3D is defined by a starting poing P0 and a final point P1. 
    %   It looks different from quiver3D, which has a flat aspect, and 
    %   arrow3D's head can be customized.
    %
    %   The thickness of the line and the size of the head can be 
    %   specified, as well as its colour.
    %
    % Example:
    %
    %    figure
    %    h = arrow3D([0, 10], [0, 0], [0, 0]);
    %    h.LineWidth = 10;
    %    h.ArrowHeadLength = 5;
    %    h.Color = 'g';
    %    lighting gouraud;  light;  axis equal;
    %
    % arrow3D coordinates can be initialized at instancing, or later.
    %
    % Example:
    %
    %    figure;  axis equal; hold on; grid on;
    %    for k = 1 : 3  % Initialize objects
    %        h(k) = arrow3D();
    %        h(k).Color = 'b';
    %        h(k).LineWidth = 5;
    %        h(k).ArrowHeadLength = 5;
    %    end
    %    h(1).XData = [0 10];   h(1).YData = [0 0];   h(1).ZData  = [0 0];
    %    h(2).XData = [0 0];    h(2).YData = [0 10];  h(2).ZData = [0 0];
    %    h(3).XData = [0 0];    h(3).YData = [0 0];   h(3).ZData  = [0 10];
    %    view([45 45])
    %


    properties (Access = private, Transient, NonCopyable)        
        % Chart axes.
        Axes(1, 1)   % Parent axes
        Figure(1, 1)         % Parent figure
        HandleLine(1,1) matlab.graphics.primitive.Line  %  Handle of the primitive *line* object
        HandleSurface(1,1) matlab.graphics.primitive.Surface
    end

    properties
        % Arrow x-data.
        XData(2, 1) double {mustBeReal} = [NaN, NaN]
        % Arrow y-data.
        YData(2, 1) double {mustBeReal} = [NaN, NaN]
        % Arrow y-data.
        ZData(2, 1) double {mustBeReal} = [NaN, NaN]
        %  Colour of the arrow
        Color;
        % Thickness of the arrow line
        LineWidth;   
        ArrowHeadRadius; % Radius of the arrow head
        ArrowHeadLength; % Length of the arrow head
    end % properties (Dependent)



    methods (Access = protected)
        function update(this)
            if isempty(this.XData) || isempty(this.YData) || isempty(this.ZData)
                return
            end
            if any(isnan(this.XData)) || any(isnan(this.YData)) || any(isnan(this.ZData))
                return
            end

            % Store figure and axis
            this.Axes = gca;
            this.Figure = gcf;

            % Initialize graphic objects if it was not plot yet
            if isempty(this.HandleLine.Parent)
                this.HandleLine = line(NaN, NaN, NaN);
                this.HandleSurface = surface(NaN, NaN, NaN);
            end
            
            % Should only update the graphical object
            % Update arrow head
            [X, Y, Z] = defineArrowhead(this);
            this.HandleSurface.XData = X;
            this.HandleSurface.YData = Y;
            this.HandleSurface.ZData = Z;

            % Line should be shorter than the full vector, to avoid having
            % the tip of the line coming out of the arrow head.
            V = [this.XData, this.YData, this.ZData];
            Vn = V(2,:) - V(1,:);
            L = norm(Vn);
            
            % SHorten the vector by half the arrow head length
            V = V(1,:) + (Vn / L) * (L - this.ArrowHeadLength/2);
            % Make the vector shorter
            this.HandleLine.XData = [this.XData(1) ; V(1)];
            this.HandleLine.YData = [this.YData(1) ; V(2)];
            this.HandleLine.ZData = [this.ZData(1) ; V(3)];

            set(this.HandleSurface,'FaceColor',this.Color,'EdgeColor','none');

            set(this.HandleLine, 'LineWidth',this.LineWidth, ...
                'Color', this.Color);

        end % update

    end % methods (Access = protected)


    methods
        
        function this = arrow3D(varargin)
            % Initialize parameters

            this.Color = 'r';
            this.LineWidth = 2;   
            this.ArrowHeadRadius = 2; % Radius of the arrow head
            this.ArrowHeadLength = 3; % Length of the arrow head
            
            % If arguments were passed, initialize arrow coordinates
            if isempty(varargin)
                return
                
            elseif length(varargin) == 3
                this.XData = varargin{1};
                this.YData = varargin{2};
                this.ZData = varargin{3};
            else
                error('Arguments error. Arrow3D can be initialized with no arguments or as "A = arrow3D([x0 x1], [y0, y1], [z0, z1])"')
            end
            
        end
        
        function demo(~)
            % demo() demonstrates the use of arrow3D
            %    It creates ten random arrows.
            % 
            % Example:
            %
            %    A = arrow3D;
            %    A.demo()

            % Random points
            x = randn(10,1)*10;
            y = randn(10,1)*10;
            z = randn(10,1)*10;
            
            arrowhead_size = abs(rand(10,1) * 5 + 1);
            arrowhead_length = abs(rand(10,1) * 5 + 1);
            
            % Create arrows
            c = lines(10);
            for k = 1 : length(x) - 1
                h(k) = arrow3D(x(k:k+1),y(k:k+1),z(k:k+1));
                h(k).Color = c(k,:);  % change arrow color
                h(k).ArrowHeadRadius = arrowhead_size(k);
                h(k).ArrowHeadLength = arrowhead_length(k);
            
            end
            
            lighting gouraud;
            light;
            axis equal;
        end


        function set.XData(this, value)
            % Set data and update graphical object
            this.XData = value;   
            this.update();

        end % set.XData

        function set.YData(this, value)
            % Set data and update graphical object
            this.YData = value;    
            this.update();

        end % set.YData

        function set.ZData(this, value)
            % Set data and update graphical object
            this.ZData = value;      
            this.update();

        end % set.ZData        
        
        function set.ArrowHeadRadius(this , ArrowHeadRadius)
            this.ArrowHeadRadius = ArrowHeadRadius;
            this.update();
        end
        function set.ArrowHeadLength(this , ArrowHeadLength)
            this.ArrowHeadLength = ArrowHeadLength;
            this.update();
        end
        function r = get.ArrowHeadLength(this)
            r = this.ArrowHeadLength;
        end
        
        function set.Color(this, c)
            this.Color = c;
            set(this.HandleSurface,'FaceColor',c)
            set(this.HandleLine,'Color',c)
        end    
        function set.LineWidth(this, l)
            this.LineWidth = l;
            set(this.HandleLine,'LineWidth',l);
        end        
        function r = get.LineWidth(this)
            r = this.LineWidth;
        end  
        
    end
    
    methods (Access = private)
       
        function  [X, Y, Z] = defineArrowhead(this)
        % This function prepares the coorodinates of the arrowhead; the arrowhead
        % is a tridimensional conic surface, rotated and displaced to the right
        % place (the tip of the vertebral vector)

            % Standard cylinder. Note that we exchange Z and X to have a
            % cone lying on its side. It will be easier to transform it
            % later
            nElements = 10;
            [Z, Y, X] = cylinder(fliplr(linspace(0, this.ArrowHeadRadius, nElements)));
            
            % The initial and final cone position
            P0 = [this.XData(1) ; this.YData(1); this.ZData(1)];
            P1 = [this.XData(2) ; this.YData(2); this.ZData(2)];
            
            % The vector of the final cone orientation
            u = (P1 - P0)/ norm(P1-P0);   
            if any(isnan(u))
                error('There is an error with the input coordinates')
            elseif any(isnan(P0)) || any(isnan(P1))
                error('There is an error with the input coordinates')
            elseif norm(P1 - P0) == 0
                error('The arrow has zero length')
            end
            
            % Lenghten the cone, and put its point to zero
            X = X * this.ArrowHeadLength - this.ArrowHeadLength;
            
            % Make a frame for the final position of the cone
            M = [u, null(u'), P1 ; 0 0 0 1];
            
            % Transform homogeneous coordinate
            s = size(X);
            X = [X(:), Y(:), Z(:), ones(numel(X),1)];
            
            X = M * X';
            % I recycled the X variable...now put the coordinates back in
            % their original shape
            Z = reshape(X(3,:), s);
            Y = reshape(X(2,:), s);
            X = reshape(X(1,:), s);

        end
        
    end % Private Methods    
    
end
