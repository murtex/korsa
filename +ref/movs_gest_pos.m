function movs = movs_gest_pos( sig, movs )
% filter: reliable gestural, paired positives
%
% movs = MOVS_GEST_POS( sig, movs )
%
% INPUT
% sig : signal (object scalar)
% movs : movements (struct)
%
% OUTPUT
% movs : filtered movements (struct)
%
% REMARKS
% - reliability is measured in terms of q-movement duration (< 0.5s)

		% safeguard
	if nargin < 1 || ~isa( sig, 'hNSignal' ) || ~isscalar( sig )
		error( 'invalid argument: sig' );
	end

	if nargin < 2 || ~io.ismovs( movs )
		error( 'invalid argument: movs' );
	end

		% filter movements
	frel = (ref.kin_dur( sig, movs, true ) < 0.5);
	fgest = arrayfun( @( mov ) ismember( 'gest', mov.tags ), movs ); % TODO: hard-coded tag!
	fpos = [movs.fpos];

	onset = [movs.onset];
	offset = [movs.offset];

	tmpa = frel & fgest & fpos & arrayfun( @( offs ) any( offs == onset ), offset ); % reliable gestural, paired positives

	movs = movs(tmpa);
	
end % function

