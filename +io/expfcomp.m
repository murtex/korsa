function fexp = expfcomp( fc, dims )
% file composition expansion flags
%
% fexp = EXPFCOMP( fc, dims )
%
% INPUT
% fc : file composition (scalar struct)
% dims : file composition dimensions (cell string)
%
% OUTPUT
% fexp : expansion flags (logical)

		% safeguard
	if nargin < 1 || ~io.isfcomp( fc )
		error( 'invalid argument: fc' );
	end

	if nargin < 2 || ~iscellstr( dims )
		error( 'invalid argument: dims' );
	end

		% set expansion flag
	fexp = cellfun( @( fname ) ismember( fname, dims ), transpose( fieldnames( fc ) ) );
	
end % function

