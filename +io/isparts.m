function tf = isparts( var )
% check for valid parts type
%
% tf = ISPARTS( var )
%
% INPUT
% var : variable (cell string)
%
% OUTPUT
% tf : check results (logical scalar)

		% safeguard
	if nargin < 1 || ~iscellstr( var )
		error( 'invalid argument: var' );
	end

		% check for type
	tf = all( ismember( var, {'sig', 'info', 'roi', 'movs'} ) );

end % function

