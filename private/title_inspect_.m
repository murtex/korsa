function ti = ti_inspect_( fc, fcol, sigs, info )
% inspection title function
%
% ti = TI_INSPECTION_( fc, fcol, sigs, info )
%
% INPUT
% fc : file composition (struct scalar)
% fcol : file collection (cell string)
% sigs : signals (object)
% info : signal information (struct)
%
% OUTPUT
% ti : title strings (cell string)

		% safeguard
	if nargin < 1 || ~io.isfcomp( fc )
		error( 'invalid argument: fc' );
	end

	if nargin < 2 || ~iscellstr( fcol )
		error( 'invalid argument: fcol' );
	end

	if nargin < 3 || ~all( arrayfun( @( sig ) isa( sig, 'hNSignal' ), sigs ) )
		error( 'invalid argument: sigs' );
	end
	
	if nargin < 4 || ~all( arrayfun( @( i ) io.isinfo( i ), info ) )
		error( 'invalid argument: info' );
	end

		% inspection title
	dims = fieldnames( fc );
	[vals{1:numel( dims )}] = io.decfcol( fcol, fc, dims{:} );

	ti = {''};
	for di = 1:numel( dims )
		if di > 1
			ti{1} = sprintf( '%s, ', ti{1} );
		end
		ti{1} = sprintf( '%s%s=%s', ti{1}, upper( dims{di} ), util.any2str( vals{di} ) );
	end	

end % function

