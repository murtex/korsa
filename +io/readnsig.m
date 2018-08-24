function sig = readnsig( filename )
% read interpolated signal
%
% sig = READNSIG( filename )
%
% INPUT
% filename : input filename (char)
%
% OUTPUT
% sig : signal (scalar object)

		% safeguard
	if nargin < 1 || ~ischar( filename )
		error( 'invalid argument: filename' );
	end

		% read signal
	load( filename, 'sig' );

end % function

