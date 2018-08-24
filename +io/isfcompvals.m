function tf = isfcompvals( var )
% check for file composition values type (cell cell string)
%
% tf = ISFCOMPVALS( var )
%
% INPUT
% var : variable
%
% OUTPUT
% tf : check result (scalar logical)

		% safeguard
	if nargin < 1
		error( 'invalid argument: var' );
	end

		% check type
	tf = false;

	if ~iscell( var )
		return;
	end

	if ~all( cellfun( @( v ) iscellstr( v ), var ) )
		return;
	end

		% check passed
	tf = true;

end % function

