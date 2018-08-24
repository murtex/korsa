function tf = isfcomp( var, fsorted )
% check for file composition type
%
% tf = ISFCOMP( var, fsorted=true )
%
% INPUT
% var : variable (struct)
% fsorted : check for sorted order (logical scalar)
%
% OUTPUT
% tf : check result (logical)
%
% TODO: avoid repetitions in values (uniqueness)!

		% safeguard
	if nargin < 1 || ~isstruct( var )
		error( 'invalid argument: var' );
	end

	if nargin < 2
		fsorted = true;
	end
	if ~islogical( fsorted ) || ~isscalar( fsorted )
		error( 'invalid argument: fsorted' );
	end

		% check type
	dims = fieldnames( var );

	tf = arrayfun( @( v ) all( cellfun( @( d ) iscellstr( v.(d) ), dims ) ), var );
	if fsorted
		tf = tf & arrayfun( @( v ) all( cellfun( @( d ) issorted( v.(d) ), dims ) ), var );
	end

end % function

