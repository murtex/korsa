function updatevis_( hfig, fsigs, fdata, fdebug )
% update visibility
%
% UPDATEVIS_( hfig, fsigs, fdata, fdebug )
%
% INPUT
% hfig : figure handle (TODO)
% fsigs : style signals flag (scalar logical)
% fdata : style data flag (scalar logical)
% fdebug : style debuggings flag (scalar logical)

		% safeguard
	if nargin < 1
		error( 'invalid argument: hfig' );
	end

	if nargin < 2 || ~isscalar( fsigs ) || ~islogical( fsigs )
		error( 'invalid argument: fsigs' );
	end

	if nargin < 3 || ~isscalar( fdata ) || ~islogical( fdata )
		error( 'invalid argument: fdata' );
	end

	if nargin < 4 || ~isscalar( fdebug ) || ~islogical( fdebug )
		error( 'invalid argument: fdebug' );
	end

		% update visibility
	edata = getappdata( hfig, 'edata' );
	gdata = getappdata( hfig, 'gdata' );

	if fsigs
		h = findall( hfig, 'Tag', 'nvis:signal' );
		set( h, 'HitTest', 'off' );

		if gdata.fsigs
			set( h, 'Visible', 'on' );
		else
			set( h, 'Visible', 'off' );
		end

		for si = 1:numel( edata.sigs )
			if gdata.fgroup(si) && gdata.fsigs
				set( gdata.hsigs{si}, 'Visible', 'on' );
			else
				set( gdata.hsigs{si}, 'Visible', 'off' );
			end
		end
	end

	if fdata
		h = findall( hfig, 'Tag', 'nvis:data' );
		set( h, 'HitTest', 'off' );

		if gdata.fdata
			set( h, 'Visible', 'on' );
		else
			set( h, 'Visible', 'off' );
		end

		for si = 1:numel( edata.sigs )
			if gdata.fgroup(si) && gdata.fdata
				set( gdata.hdata{si}, 'Visible', 'on' );
			else
				set( gdata.hdata{si}, 'Visible', 'off' );
			end
		end
	end

	if fdebug
		h = findall( hfig, 'Tag', 'nvis:debug' );
		set( h, 'HitTest', 'off' );

		if gdata.fdebug
			set( h, 'Visible', 'on' );
		else
			set( h, 'Visible', 'off' );
		end

		for si = 1:numel( edata.sigs )
			if gdata.fgroup(si) && gdata.fdebug
				set( gdata.hdebug{si}, 'Visible', 'on' );
			else
				set( gdata.hdebug{si}, 'Visible', 'off' );
			end
		end
	end

end % function

