function fc = trimfcomp( fc, dirname, basename, extension )
% trim file composition
% 
% fc = TRIMFCOMP( fc )
%
% INPUT
% fc : dataspace (struct scalar)
%
% OUTPUT
% fc : dataspace (struct scalar)

		% safeguard
	if nargin < 1 || ~io.isfcomp( fc ) || ~isscalar( fc )
		error( 'invalid argument: fc' );
	end

		% trim file composition
	fcol = io.genfcol( fc );
	fcol = io.valinfcol( fcol, dirname, basename, extension );

	fcdims = fieldnames( fc );
	for di = 1:numel( fcdims )
		fc.(fcdims{di}) = io.decfcol( fcol, fc, fcdims{di} );
	end

end % function

