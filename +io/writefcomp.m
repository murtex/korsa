function writefcomp( fc, filename )
% write file composition
%
% WRITEFCOMP( fc, filename )
%
% INPUT
% fc : file composition (scalar struct)
% filename : output filename (char)

		% safeguard
	if nargin < 1 || ~io.isfcomp( fc )
		error( 'invalid argument: fc' );
	end

	if nargin < 2 || ~ischar( filename )
		error( 'invalid argument: filename' );
	end

		% write composition
	save( filename, 'fc' );

end % function

