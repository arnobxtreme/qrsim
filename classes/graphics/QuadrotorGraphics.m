classdef QuadrotorGraphics<handle
    % Class that handles the 3D visualization of a quadrotor helicopter
    % This implementation is very basic but has the advantage of not
    % depending on any additional toolbox
    %
    % QuadrotorGraphics Properties:
    %    AL              - arm length m
    %    AT              - arm width m
    %    AW              - arm thickness m
    %    BW              - body width m
    %    BT              - body thickness m
    %    R               - rotor radius m
    %    DFT             - distance from truss m
    %    X               - state [px;py;pz;phi;theta;psi] three position (NED coordinates m)
    %                      and 3 Euler angles right hand ZYX convention rad
    %
    % QuadrotorGraphics Methods:
    %   QuadrotorGraphics(initX,params)  - constructs the object
    %   updateGraphics()                 - updates the visualization according to the current state
    %   plotTrajectory(flag)             - enables/disables the plotting of the hecopter trajectory
    %
    
    properties (Access = private)
        % arms
        AL = 0.4;  % arm length m
        AT = 0.01; % arm width m
        AW = 0.02; % arm thickness m
        
        % body
        BW = 0.12; % body width m
        BT = 0.08; % body thickness m
        
        % rotors
        R = 0.08; % rotor radius m
        DFT = 0.02; % distance from truss m
        
        gHandle         % graphic handle
        plotTrj = 0;    % 1 to enable trajectory plotting
        on              % 1 if 3d dispaly is enabled
        X               % state
    end
    
    methods (Sealed)
        function obj=QuadrotorGraphics(objparams,initX)
            % constructs the object
            %
            % Example:
            %   obj =  QuadrotorGraphics(initX,params);
            %          initX - initial state [px;py;pz;phi;theta;psi]
            %          objparams - objparams.display3don enable/disaple graphics
            %
            
            % arms
            obj.AL = objparams.AL;  % arm length m
            obj.AT = objparams.AT; % arm width m
            obj.AW = objparams.AW; % arm thickness m
            
            % body
            obj.BW = objparams.BW; % body width m
            obj.BT = objparams.BT; % body thickness m
            
            % rotors
            obj.R = objparams.R; % rotor radius m
            obj.DFT = objparams.DFT; % distance from truss m
            
            obj.X=initX(1:6);

            obj.on  = objparams.on;
            
            if(obj.on)
                obj.initGlobalGraphics();
                obj.createGraphicsHandlers();
            end
        end
        
        function obj = plotTrajectory(obj,flag)
            % enables/disables the plotting of the hecopter trajectory
            %
            % Example:
            %   plotTrajectory(flag)
            %          flag - 1 to enable
            %
            obj.plotTrj = flag;
        end
        
        function update(obj,X)
            % updates the visualization according to the current state
            %
            % Example:
            %   updateGraphics()
            %
            global state;
            
            obj.X = X(1:6);
            
            if(obj.on)
                
                set(0,'CurrentFigure',state.display3d.figure)
                % body rotations translation
                C = angle2dcm(obj.X(6),obj.X(5),obj.X(4));
                T = [obj.X(1),obj.X(2),obj.X(3)];
                
                TT = repmat(T,size(state.display3d.uavgraphicobject.b1,1),1);
                
                b1 = (state.display3d.uavgraphicobject.b1*C)+TT;
                b2 = (state.display3d.uavgraphicobject.b2*C)+TT;
                b3 = (state.display3d.uavgraphicobject.b3*C)+TT;
                
                % update body
                set(obj.gHandle.b1,'Vertices',b1);
                set(obj.gHandle.b2,'Vertices',b2);
                set(obj.gHandle.b3,'Vertices',b3);
                
                % rotors rotations translation
                TT = repmat(T,size(state.display3d.uavgraphicobject.rotor1,1),1);
                r1 = (state.display3d.uavgraphicobject.rotor1*C)+TT;
                r2 = (state.display3d.uavgraphicobject.rotor2*C)+TT;
                r3 = (state.display3d.uavgraphicobject.rotor3*C)+TT;
                r4 = (state.display3d.uavgraphicobject.rotor4*C)+TT;
                
                % update rotors
                set(obj.gHandle.r1,'XData',r1(:,1));
                set(obj.gHandle.r1,'YData',r1(:,2));
                set(obj.gHandle.r1,'ZData',r1(:,3));
                
                set(obj.gHandle.r2,'XData',r2(:,1));
                set(obj.gHandle.r2,'YData',r2(:,2));
                set(obj.gHandle.r2,'ZData',r2(:,3));
                
                set(obj.gHandle.r3,'XData',r3(:,1));
                set(obj.gHandle.r3,'YData',r3(:,2));
                set(obj.gHandle.r3,'ZData',r3(:,3));
                
                set(obj.gHandle.r4,'XData',r4(:,1));
                set(obj.gHandle.r4,'YData',r4(:,2));
                set(obj.gHandle.r4,'ZData',r4(:,3));
                
                if (obj.plotTrj)
                    s = max(0,length(obj.gHandle.trjData.x-100));
                    obj.gHandle.trjData.x = [obj.gHandle.trjData.x(s:end) obj.X(1)];
                    obj.gHandle.trjData.y = [obj.gHandle.trjData.y(s:end) obj.X(2)];
                    obj.gHandle.trjData.z = [obj.gHandle.trjData.z(s:end) obj.X(3)];
                    
                    obj.gHandle.trjLine = line(obj.gHandle.trjData.x,obj.gHandle.trjData.y,...
                        obj.gHandle.trjData.z,'LineWidth',2,'LineStyle','-');
                end
            end
        end
    end
    
    methods (Sealed,Access=private)
        
        function createGraphicsHandlers(obj)
            % creates the necessary graphics handlers and stores them
            %
            % Example:
            %    createGraphicsHandlers()
            %
            global state;
            
            set(0,'CurrentFigure',state.display3d.figure)
            
            % initial translation and orientation
            C = angle2dcm(obj.X(6),obj.X(5),obj.X(4));
            T = [obj.X(1),obj.X(2),obj.X(3)];
            
            TT = repmat(T,size(state.display3d.uavgraphicobject.b1,1),1);
            
            b1 = (state.display3d.uavgraphicobject.b1*C)+TT;
            b2 = (state.display3d.uavgraphicobject.b2*C)+TT;
            b3 = (state.display3d.uavgraphicobject.b3*C)+TT;
            
            obj.gHandle.b1 = patch('Vertices',b1,'Faces',state.display3d.uavgraphicobject.bf);
            obj.gHandle.b2 = patch('Vertices',b2,'Faces',state.display3d.uavgraphicobject.bf);
            obj.gHandle.b3 = patch('Vertices',b3,'Faces',state.display3d.uavgraphicobject.bf);
            
            TT = repmat(T,size(state.display3d.uavgraphicobject.rotor1,1),1);
            r1 = (state.display3d.uavgraphicobject.rotor1*C)+TT;
            r2 = (state.display3d.uavgraphicobject.rotor2*C)+TT;
            r3 = (state.display3d.uavgraphicobject.rotor3*C)+TT;
            r4 = (state.display3d.uavgraphicobject.rotor4*C)+TT;
            
            obj.gHandle.r1 = patch(r1(:,1),r1(:,2),r1(:,3),'r');
            obj.gHandle.r2 = patch(r2(:,1),r2(:,2),r2(:,3),'b');
            obj.gHandle.r3 = patch(r3(:,1),r3(:,2),r3(:,3),'b');
            obj.gHandle.r4 = patch(r4(:,1),r4(:,2),r4(:,3),'b');
            
            obj.gHandle.trjData.x = obj.X(1);
            obj.gHandle.trjData.y = obj.X(2);
            obj.gHandle.trjData.z = obj.X(3);
        end
    end
    
    methods (Sealed, Static,Access=private)
        
        function initGlobalGraphics()
            % creates the necessary graphics primitives only once for all helicopters
            % Dimension according to the constants AL,AT,AW,BW,BT,R,DFT
            %
            % Example:
            %    initGlobalGraphics()
            %
            global state;
            
            if(~exist('state.display3d.heliGexists','var'))
                %%% body
                al = obj.AL/2;  % half arm length
                at = obj.AT/2; % half arm width
                aw = obj.AW/2; % half arm thickness
                
                cube = [-1, 1, 1;-1, 1,-1;-1,-1,-1;-1,-1, 1; 1, 1, 1; 1, 1,-1; 1,-1,-1;1,-1, 1];
                
                state.display3d.uavgraphicobject.b1 = cube.*repmat([aw,al,at],size(cube,1),1);
                
                state.display3d.uavgraphicobject.b2 = state.display3d.uavgraphicobject.b1*angle2dcm(0,0,pi/2,'XYZ');
                
                bw = obj.BW/2; % half body width
                bt = obj.BT/2; % half body thickness
                
                state.display3d.uavgraphicobject.b3 =  (cube.*repmat([bw,bw,bt],size(cube,1),1))*angle2dcm(0,0,pi/4,'XYZ');
                
                state.display3d.uavgraphicobject.bf = [1 2 3 4; 5 6 7 8; 4 3 7 8; 1 5 6 2; 1 4 8 5; 6 7 3 2];
                
                %%% rotors
                r = 0:pi/8:2*pi;
                sr = size(r,2);
                disc = [sin(r).*obj.R;cos(r).*obj.R;-ones(1,sr).*obj.DFT]';
                
                state.display3d.uavgraphicobject.rotor1 = disc + repmat([al,0,0],sr,1);
                state.display3d.uavgraphicobject.rotor2 = disc + repmat([0,al,0],sr,1);
                state.display3d.uavgraphicobject.rotor3 = disc + repmat([0,-al,0],sr,1);
                state.display3d.uavgraphicobject.rotor4 = disc + repmat([-al,0,0],sr,1);
                state.display3d.uavgraphicobject.waypoint = (disc + repmat([-al,0,0],sr,1))*10;
                
                state.display3d.heliGexists=1;
                
            end
        end
    end
    
end

