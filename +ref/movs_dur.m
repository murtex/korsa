function dur = movs_dur( sig, movs, fq )
% movment durations
%
% dur = MOVS_DUR( sig, movs, fq )
%
% INPUT
% sig : signal (scalar object)
% movs : movements (struct)
% fq : q-delimiter flag (scalar logical)
%
% OUTPUT
% dur : durations (numeric)

		% safeguard
	if nargin < 1 || ~isscalar( sig ) || ~isa( sig, 'hNSignal' )
		error( 'invalid argument: sig' );
	end

	if nargin < 2 || ~io.ismovs( movs )
		error( 'invalid argument: movs' );
	end

	if nargin < 3 || ~isscalar( fq ) || ~islogical( fq )
		error( 'invalid argument: fq' );
	end

		% compute durations
	if fq
		dur = sig.time{[movs.qoffset]}-sig.time{[movs.qonset]};
	else
		dur = sig.time{[movs.offset]}-sig.time{[movs.onset]};
	end

end % function

