function fc = readfcomp( filename )
% read file composition
%
% fc = READFCOMP( filename )
%
% INPUT
% filename : input filename (char)
%
% OUTPUT
% fc : file composition (scalar struct)

		% safeguard
	if nargin < 1 || ~ischar( filename )
		error( 'invalid argument: filename' );
	end

		% read signal
	load( filename, 'fc' );

end % function

