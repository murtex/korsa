function movs = movs_gest( sig, movs )
% filter: reliable gestural, paired positives, any negative
%
% movs = MOVS_GEST( sig, movs )
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
	tmpb = frel & fgest & ~fpos; % reliable gestural, any negatives

	movs = movs(tmpa | tmpb);
	
end % function

