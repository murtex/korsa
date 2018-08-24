function ti = ti_none_( fc, fcol, sigs, info )
% empty title function
%
% ti = TI_NONE_( fc, fcol, sigs, info )
%
% INPUT
% fc : file composition (struct scalar)
% fcol : file collection (cell string)
% sigs : signals (object)
% info : signal information structures (struct)
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

		% empty title
	ti = {};

end % function

