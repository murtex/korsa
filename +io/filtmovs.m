function fin = filtmovs( movs, filtin, filtex )
% filter movements
%
% fin = FILTMOVS( movs, filtin, filtex )
%
% INPUT
% movs : movements (struct)
% filtin : inclusion filter (cell string)
% filtex : exclusion filter (cell string)
%
% OUTPUT
% fin : inclusion flags (logical)

		% safeguard
	if nargin < 1 || ~all( io.ismovs( movs ) )
		error( 'invalid argument: movs' );
	end

	if nargin < 2 || ~iscellstr( filtin )
		error( 'invalid argument: filtin' );
	end

	if nargin < 3 || ~iscellstr( filtex )
		error( 'invalid argument: filtex' );
	end

		% filter movements
	fin = false( size( movs ) );

	for mi = 1:numel( movs )
		mov = movs(mi);

		if any( ismember( mov.tags, filtin ) ) && ~any( ismember( mov.tags, filtex ) )
			fin(mi) = true;
		end
	end

end % function

