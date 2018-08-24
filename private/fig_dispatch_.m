function fig_dispatch_( hfig, event, msg )
% figure message dispatcher
%
% FIG_DISPATCH_( hfig, event, msg )
%
% INPUT
% hfig : figure handle (TODO)
% event : TODO
% msg : message string (char)

		% safeguard
	if nargin < 1
		error( 'invalid argument: hfig' );
	end
	
	if nargin < 2
		error( 'invalid argument: event' );
	end

	if nargin < 3 || ~ischar( msg )
		error( 'invalid argument: msg' );
	end

	style = hStyle.instance();

		% dispatch messages
	gdata = getappdata( hfig, 'gdata' );

	if ismember( msg, {'close'} ) % close request
		delete( hfig );

	elseif ismember( msg, {'keypress'} ) % keyboard

		if iskey_( event, {'space'}, {} )
			gdata.fdone = true;
			setappdata( hfig, 'gdata', gdata );
			update_( hfig );

		elseif iskey_( event, {'escape'}, {} )
			gdata.fdone = true;
			gdata.fstop = true;
			setappdata( hfig, 'gdata', gdata );
			update_( hfig );

		end

	end
	
end % function

	% local functions
function tf = iskey_( event, keys, chars )
	tf = false;
	if (isempty( keys ) || ismember( event.Key, keys )) && (isempty( chars ) || ismember( event.Character, chars ))
		tf = true;
	end
end % function

function update_( hfig )
	set( hfig, 'UserData', ~get( hfig, 'UserData' ) );
end % function

