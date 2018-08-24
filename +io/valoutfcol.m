function valoutfcol( fcol, dirname )
% validate output files
%
% VALOUTFCOL( fcol, dirname )
%
% INPUT
% fcol : file collection (cell string)
% dirname : output directory (char)
%
% TODO: MATLAB's exist function does not handle symlinks correctly!?

		% safeguard
	if nargin < 1 || ~iscellstr( fcol )
		error( 'invalid argument: fcol' );
	end

	if nargin < 2 || ~ischar( dirname )
		error( 'invalid argument: dirname' );
	end

		% validate output files
	fdir = cellfun( @( f ) fullfile( dirname, f ), fcol, 'UniformOutput', false );
	fdirx = cellfun( @( f ) exist( f, 'dir' ) == 7, fdir );

	cellfun( @( f ) mkdir( f ), fdir(~fdirx) );

end % function

