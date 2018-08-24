function writeinfo( info, filename )
% write signal information
%
% WRITEINFO( info, filename )
%
% INPUT
% info : signal information structure (scalar object)
% filename : output filename (char)

		% safeguard
	if nargin < 1 || ~isscalar( info ) || ~io.isinfo( info )
		error( 'invalid argument: info' );
	end

	if nargin < 2 || ~ischar( filename )
		error( 'invalid argument: filename' );
	end

		% write info
	if exist( filename, 'file' ) == 2
		s = load( filename, '-mat' );
	end

	s.info = info;

	save( filename, '-struct', 's', '-mat', '-v7.3' );

end % function

