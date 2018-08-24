function wait_( hfig, fbusy )
% indicate busy state
%
% WAIT_( hfig, f )
% 
% INPUT
% hfig : figure handle (TODO)
% fbusy : busy flag (scalar logical)

		% safeguard
	if nargin < 1
		error( 'invalid argument: hfig' );
	end

	if nargin < 2 || ~isscalar( fbusy ) || ~islogical( fbusy )
		error( 'invalid argument: fbusy' );
	end

		% update busy pointer
	if fbusy
		set( hfig, 'Pointer', 'watch' );
		drawnow();
	else
		set( hfig, 'Pointer', 'arrow' );
		drawnow();
	end

end

