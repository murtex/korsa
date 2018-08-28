function len = movs_len( sigs, movs, fq, sub )
% movement path lengths
%
% len = MOVS_LEN( sigs, movs, fq, sub )
%
% INPUT
% sigs : signals (object)
% movs : movements (struct)
% fq : q-delimiter flag (scalar logical)
% sub : movement subsampling (numeric scalar)
%
% OUTPUT
% len : path lengths (numeric)

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

		% compute path lengths
	len = NaN( [1, numel( movs )] );

	for mi = 1:numel( movs )
		if fq
			ti = linspace( movs(mi).qonset, movs(mi).qoffset, sub );
		else
			ti = linspace( movs(mi).onset, movs(mi).offset, sub );
		end

		r = transpose( reshape( cell2mat( arrayfun( @( s ) s.data{1, ti}, sigs, 'UniformOutput', false ) ), [numel( ti ), numel( sigs )] ) );
		len(mi) = sum( sqrt( sum( diff( r, 1, 2 ).^2, 1 ) ) );
	end

end % function

