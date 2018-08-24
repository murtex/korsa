function tf = isinfo( var )
% check for signal information structure type
%
% tf = ISINFO( var )
%
% INPUT
% var : variable (struct)
%
% OUTPUT
% tf : check result (logical)

		% safeguard
	if nargin < 1 || ~isstruct( var )
		error( 'invalid argument: var' );
	end

		% check type
	tf = repmat( isfield( var, 'trial' ) & isfield( var, 'sweep' ), size( var ) );

end % function
