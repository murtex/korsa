function fc = genfcomp( fc )
% create (empty) file composition
%
% fc = GENFCOMP( fc )
%
% INPUT
% fc : file composition (scalar struct)
%
% OUTPUT
% fc : (empty) file composition (scalar struct)

		% safeguard
	if nargin < 1 || ~isscalar( fc ) || ~all( io.isfcomp( fc ) )
		error( 'invalid argument: fc' );
	end

		% empty structure
	dims = fieldnames( fc );
	for di = 1:numel( dims )
		fc.(dims{di}) = {};
	end

end % function

