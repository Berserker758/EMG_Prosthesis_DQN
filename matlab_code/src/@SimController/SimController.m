classdef SimController < handle
    % SimController Mock class for Controller.
    % Includes a simulator of prosthesis dynamics.
    % Requires the Timing object for the simulation.

    %{
    Laboratorio de Inteligencia y Visión Artificial
    ESCUELA POLITÉCNICA NACIONAL
    Quito - Ecuador
    
    autor: ztjona
    jonathan.a.zea@ieee.org
    
    "I find that I don't understand things unless I try to program them."
    -Donald E. Knuth
    
    %}

    properties (SetAccess = protected)
        vels = [0 0 0 0];   % Current velocities (1-by-4 array)
        buffer = [0 0 0 0]; % Buffer for positions
        tocStop;            % Moment when the prosthesis stopped
        timing;             % Timing object for simulation
        sampling_period = 0.11; % Sampling period in seconds
        c0 = 0;             % Counter of periods
    end

    properties (Hidden = true)
        isConnected = false; % Connection status
    end

    methods
        %% Constructor
        function obj = SimController(timing)
            % SimController Constructor for the simulation controller.
            %
            % # USAGE
            %   obj = SimController(timing);
            %
            % # INPUTS
            %  timing   Timing object for simulation.

            % # ---- Initialize
            obj.isConnected = true;
            obj.timing = timing;
            obj.c0 = timing.c; % Initialize counter
        end

        %% Close Hand
        function completed = closeHand(obj)
            % Close all motors to maximum speed.
            obj.sendAllSpeed(255, 255, 255, 255);
            completed = true;
        end

        %% Send All Speed
        function completed = sendAllSpeed(obj, pwm1, pwm2, pwm3, pwm4)
            % Send speed commands to all motors.
            obj.updatePos();
            obj.vels = [pwm1, pwm2, pwm3, pwm4];
            completed = true;
        end

        %% Send Speed
        function completed = sendSpeed(obj, motor, pwm)
            % Send speed command to a specific motor.
            obj.updatePos();
            obj.vels(motor) = pwm;
            completed = true;
        end

        %% Reset Encoder
        function completed = resetEncoder(obj, v1, v2, v3, v4)
            % Reset encoder values.
            % # INPUTS
            %  v1, v2, v3, v4  Encoder values (integers).
            %
            % # OUTPUT
            %  completed       Status of the operation.

            % # ---- Data Validation
            arguments
                obj
                v1 (1, 1) double {mustBeInteger} = 0;
                v2 (1, 1) double {mustBeInteger} = 0;
                v3 (1, 1) double {mustBeInteger} = 0;
                v4 (1, 1) double {mustBeInteger} = 0;
            end

            obj.updatePos();
            obj.buffer(end + 1, :) = [v1, v2, v3, v4];
            completed = true;
        end

        %% Stop
        function completed = stop(obj)
            % Stop all motors.
            obj.updatePos();
            obj.vels = zeros(1, 4);
            completed = true;
        end

        %% Stop Motor
        function completed = stopMotor(obj, idxs)
            % Stop specific motors.
            % # INPUT
            %  idxs   Indices of motors to stop.
            %
            % # OUTPUT
            %  completed Status of the operation.

            obj.updatePos();
            obj.vels(idxs) = 0;
            completed = true;
        end

        %% Go Home Position
        function completed = goHomePosition(obj, ~, ~, ~)
            % Move to home position and reset buffer.
            obj.updatePos();
            obj.resetBuffer([0, 0, 0, 0]);
            completed = true;
        end

        %% Reset Buffer
        function resetBuffer(obj, last_pos)
            % Reset the buffer with the last position.
            % # INPUT
            %  last_pos  Position to reset buffer (1-by-4 array).

            % # ---- Data Validation
            arguments
                obj
                last_pos (1, 4) double = [0, 0, 0, 0];
            end

            obj.buffer = last_pos;
            obj.c0 = obj.timing.c;
        end

        %% Read Buffer
        function data = read(obj)
            % Read the current buffer and reset it.
            obj.updatePos();
            data = obj.buffer;
            obj.resetBuffer(data(end, :));
        end
    end

    methods (Access = protected)
        %% Update Position
        function updatePos(obj)
            % Update trajectory based on elapsed time and recorded speeds.
            cs = obj.timing.c - obj.c0;
            duration = cs * obj.timing.period();
            obj.c0 = obj.timing.c;

            if duration <= 0
                if duration < 0
                    warning('Duration is negative.');
                end
                return;
            end

            % Calculate trajectory based on the simulated prosthesis
            trajectory = SimController.prosthesis_simulator( ...
                obj.buffer(end, :), obj.vels, duration, ...
                obj.sampling_period);

            obj.buffer = [obj.buffer; trajectory];
        end
    end

    methods (Static)
        trajectory = prosthesis_simulator( ...
            initial_position, speeds, duration, sampling_period);
    end
end
