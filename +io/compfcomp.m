function fc = compfcomp( fc, dirname, basename, ext )
% compact file composition
%
% fc = COMPFCOMP( fc, dirname, basename, ext )
%
% INPUT
% fc : file composition (scalar struct)
% dirname : input directory (char)
% basename : file basename (char)
% ext : file extension (char)
%
% OUTPUT
% fc : compacted file composition (scalar struct)

		% safeguard
	if nargin < 1 || ~isscalar( fc ) || ~io.isfcomp( fc )
		error( 'invalid argument: fc' );
	end

	if nargin < 2 || ~ischar( dirname )
		error( 'invalid argument: dirname' );
	end

	if nargin < 3 || ~ischar( basename )
		error( 'invalid argument: basename' );
	end

	if nargin < 4 || ~ischar( ext )
		error( 'invalid argument: ext' );
	end

		% compact composition
	fcol = io.genfcol( fc );
	fcol = io.valinfcol( fcol, dirname, basename, ext );

	dims = fieldnames( fc );
	[vals{1:numel( dims )}] = io.decfcol( fcol, fc, dims{:} );

	fc = cell2struct( vals, dims, 2 );

end % function
