function writensig( sig, filename )
% write interpolated signal
%
% WRITENSIG( sig, filename )
%
% INPUT
% sig : signal (scalar object)
% filename : output filename (char)

		% safeguard
	if nargin < 1 || ~isa( sig, 'hNSignal' )
		error( 'invalid argument: sig' );
	end

	if nargin < 2 || ~ischar( filename )
		error( 'invalid argument: filename' );
	end

		% write signal
	if exist( filename, 'file' ) == 2
		s = load( filename, '-mat' );
	end

	s.sig = sig;

	save( filename, '-struct', 's', '-mat', '-v7.3' );

end % function

