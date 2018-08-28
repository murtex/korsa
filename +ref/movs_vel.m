function vel = movs_vel( sigs, movs, fq, sub )
% movement velocities
%
% vel = MOVS_VEL( sigs, movs, fq, sub )
%
% INPUT
% sigs : signals (object)
% movs : movements (struct)
% fq : q-delimiter flag (scalar logical)
% sub : movement subsampling (numeric scalar)
%
% OUTPUT
% vel : velocities (numeric)

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

		% compute velocities
	vel = NaN( [sub, numel( movs )] );

	xp = NaN( [numel( sigs ), sub] );
	for mi = 1:numel( movs )
		if fq
			ti = linspace( movs(mi).qonset, movs(mi).qoffset, sub );
		else
			ti = linspace( movs(mi).onset, movs(mi).offset, sub );
		end

		for ni = 1:numel( sigs )
			xp(ni, :) = sigs(ni).data{2, ti};
		end

		vel(:, mi ) = sqrt( sum( xp.^2, 1 ) );
	end

end % function

