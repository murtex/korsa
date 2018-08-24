function fc = fixfcomp( fc, fcref )
% fix file compositions
%
% fc = FIXFCOMP( fc, fcref )
%
% INPUT
% fc : file composition (struct scalar)
% fcref : reference dataspace (struct scalar)
%
% OUTPUT
% fc : file composition (struct scalar)

		% safeguard
	if nargin < 1 || ~io.isfcomp( fc, false ) || ~isscalar( fc )
		error( 'invalid argument: fc' );
	end

	if nargin < 2 || ~io.isfcomp( fcref ) || ~isscalar( fcref )
		error( 'invalid argument: fcref' );
	end

		% fix file composition
	dims = fieldnames( fcref );

	for di = 1:numel( dims )
		if ~isfield( fc, dims{di} )
			error( 'invalid value: fc' );
		end

		if isempty( fc.(dims{di}) )
			fc.(dims{di}) = fcref.(dims{di});
		else
			[~, dj] = ismember( fc.(dims{di}), fcref.(dims{di}) );
			fc.(dims{di}) = fcref.(dims{di})(sort( dj(dj > 0) ));
		end
	end

end % function

