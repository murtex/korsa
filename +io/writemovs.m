function writemovs( movs, filename )
% write movements structure
%
% WRITEMOVS( movs, filename )
%
% INPUT
% movs : movements structure (struct)
% filename : output filename (char)

		% safeguard
	if nargin < 1 || ~io.ismovs( movs )
		error( 'invalid argument: movs' );
	end

	if nargin < 2 || ~ischar( filename )
		error( 'invalid argument: filename' );
	end

		% write movements
	if exist( filename, 'file' ) == 2
		s = load( filename, '-mat' );
	end

	s.movs = movs;

	save( filename, '-struct', 's', '-mat', '-v7.3' );
	
end % function

