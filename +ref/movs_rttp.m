function rttp = movs_rttp( sigs, movs, fq, sub )
% releative times to peak
%
% rttp = MOVS_RTTP( sigs, movs, fq, sub )
%
% INPUT
% sigs : signals (object)
% movs : movements (struct)
% fq : q-delimiter flag (scalar logical)
% sub : movement subsampling (numeric scalar)
%
% OUTPUT
% rttp : relative times to peak (numeric)
%
% TODO: determine current package (ref)!

		% safeguard
	if nargin < 1 || ~all( arrayfun( @( s ) isa( s, 'hNSignal' ), sigs ) )
		error( 'invalid argument: sigs' );
	end

	if nargin < 2 || ~io.ismovs( movs )
		error( 'invalid argument: movs' );
	end

	if nargin < 3 || ~isscalar( fq ) || ~islogical( fq )
		error( 'invalid argument: fq' );
	end

	if nargin < 4 || ~isscalar( sub ) || ~isnumeric( sub )
		error( 'invalid argument: sub' );
	end

		% compute relative times
	vel = ref.movs_vel( sigs, movs, fq, sub );
	[~, pvel] = max( ref.movs_vel( sigs, movs, fq, sub ), [], 1 );
	rttp = (pvel-1)/(sub-1);

end % function

