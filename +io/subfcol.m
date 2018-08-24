function [fcol, basename] = subfcol( fcol, fc, basename )
% subsume file collection
%
% [fcol, basename] = SUBFCOL( fcol, fc, basename )
%
% INPUT
% fcol : file collection (cell string)
% fc : file composition (scalar struct)
% basename : file basename (char)
%
% OUTPUT
% fcol : subsumed file collection (cell string)
% basename : subsumed file basename (char)

		% safeguard
	if nargin < 1 || ~iscellstr( fcol )
		error( 'invalid argument: fcol' );
	end

	if nargin < 2 || ~io.isfcomp( fc )
		error( 'invalid argument: fc' );
	end

	if nargin < 3 || ~ischar( basename )
		error( 'invalid argument: basename' );
	end

		% subsume file collection
	dims = fieldnames( fc );
	ndims = numel( dims );
	[vals{1:ndims}] = io.decfcol( fcol, fc, dims{:} );
	nvals = cellfun( @numel, vals );

	nsi = find( nvals ~= 1, 1, 'first' ); % consecutive singleton values
	if isempty( nsi )
		nsi = ndims+1;
	end

	fcol = {''};
	tokens = [vals{1:nsi-1}];
	if numel( tokens )
		fcol = {fullfile( tokens{:} )};
	end

	tmp = ''; % subsumed non-singleton values
	for i = nsi:ndims
		tmp = strcat( tmp, sprintf( '%s-', vals{i}{:} ) );
	end
	basename = strcat( tmp, basename );

end % function

