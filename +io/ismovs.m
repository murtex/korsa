function tf = ismov( var )
% check for movements structure type
%
% tf = ISMOV( var )
%
% INPUT
% var : variable (struct)
%
% OUTPUT
% tf : check result (scalar logical)

		% safeguard
	if nargin < 1
		error( 'invalid argument: var' );
	end

		% check type
	tf = isstruct( var );

	if tf
		tf = ...
			isfield( var, 'onset' ) & isfield( var, 'peak' ) & isfield( var, 'offset' ) & ...
			isfield( var, 'q' ) & isfield( var, 'qonset' ) & isfield( var, 'qoffset' ) & ...
			isfield( var, 'tags' ) & ...
			isfield( var, 'fpos' );
	end

end % function

