 function playTone(obj, pin, varargin)
            %   Play a tone on piezo speaker
            %
            %   Syntax:
            %   playTone(a,pin)                    Plays a 1000Hz, 1s tone on a piezo speaker attached to
            %                                   the Arduino hardware at a specified pin.
            %   playTone(a,pin,frequency)          Plays a 1s tone at specified frequency.
            %   playTone(a,pin,frequency,duration) Plays a tone at specified frequency and duration.
            %
            %   Example:
            %   Play a tone connected to pin 5 on the Arduino for 30 seconds at 2400Hz.
            %       a = arduino();
            %       playTone(a,5,2400,30);
            %
            %   Example:
            %   Stop playing tone.
            %       a = arduino();
            %       playTone(a,5,0,0);
            %
            %   Input Arguments:
            %   a         - Arduino
            %   pin       - Digital pin number (numeric)
            %   frequency - Frequency of tone (numeric, 0 - 32767Hz)
            %   duration  - Duration of tone to be played (numeric, 0 - 30s)

            %   defaults
            frequency = 1000;
            duration = 1;
            
            try
                if (nargin < 2)
                    obj.localizedError('MATLAB:minrhs');
                end

                if nargin > 4
                    obj.localizedError('MATLAB:maxrhs');
                end
            catch e
                throwAsCaller(e);
            end
            
            if nargin > 3
                duration = varargin{2};
            end
            
            if nargin > 2
                frequency = round(varargin{1});
            end

            subsystem = 'Digital';
            try
                configurePin(obj.ResourceManager, pin, subsystem, obj.ResourceOwner, 'PWM', false);
                frequency = arduinoio.internal.validateDoubleParameterRanged('tone frequency', frequency, 0, 32767, 'Hz');
                duration = arduinoio.internal.validateDoubleParameterRanged('tone duration', duration, 0, 30, 's');
                playTone(obj.Protocol, pin, frequency, duration);
            catch e
                throwAsCaller(e);
            end
        end