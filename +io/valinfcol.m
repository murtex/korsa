function [fcol, vals] = valinfcol( fcol, dirname, basename, extension )
% validate input files
%
% [fcol, vals] = VALINFCOL( fcol, dirname, basename, extension )
%
% INPUT
% fcol : file collection (cell string)
% dirname : input directory (char)
% basename : file basename (char)
% extension : file extension (char)
%
% OUTPUT
% fcol : validated file collection (cell string)
% vals : valid indices (numeric)
%
% TODO: MATLAB's exist function does not handle symlinks correctly!?

		% safeguard
	if nargin < 1 || ~iscellstr( fcol )
		error( 'invalid argument: fcol' );
	end

	if nargin < 2 || ~ischar( dirname )
		error( 'invalid argument: dirname' );
	end

	if nargin < 3 || ~ischar( basename )
		error( 'invalid argument: basename' );
	end

	if nargin < 4 || ~ischar( extension )
		error( 'invalid argument: extension' );
	end

		% validate input files
	fn = strcat( basename, extension );

	fcolp = cellfun( @( f ) fullfile( dirname, f, fn ), fcol, 'UniformOutput', false );
	fcolx = cellfun( @( f ) exist( f, 'file' ) == 2, fcolp );

	fcol = fcol(fcolx);
	vals = find( fcolx );

end % function

