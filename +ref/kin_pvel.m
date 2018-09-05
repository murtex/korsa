function pvel = kin_pvel( sigs, movs, fq, sub )
% kinematics: movemnt peak velocities
%
% pvel = KIN_PVEL( sigs, movs, fq, sub )
%
% INPUT
% sigs : signals (object)
% movs : movements (struct)
% fq : q-delimiter flag (scalar logical)
% sub : movement subsampling (numeric scalar)
%
% OUTPUT
% pvel : peak velocities (numeric)
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

		% compute peak velocity
	pvel = max( ref.kin_vel( sigs, movs, fq, sub ), [], 1 );

end % function

