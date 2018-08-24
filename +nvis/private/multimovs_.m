function multimovs_( hfig, ch )
% select multiple movements
%
% MULTIMOVS_( hfig, ch )
%
% INPUT
% hfig : figure handle (TODO)
% ch : channel (scalar numeric)

		% safeguard
	if nargin < 1
		error( 'invalid argument: hfig' );
	end

	if nargin < 2 || ~isscalar( ch ) || ~isnumeric( ch )
		error( 'invalid argument: ch' );
	end

		% restrict applicability to displacement and velocity channel
	edata = getappdata( hfig, 'edata' );

	if ~ismember( ch, edata.ch ) || ~ismember( ch, [1, 2] )
		return;
	end

		% drag-and-drop capturing
	gdata = getappdata( hfig, 'gdata' );
	pstart = gdata.pointer;

	rbbox();

	gdata = getappdata( hfig, 'gdata' );
	pstop = gdata.pointer;

	r = [min( pstart(1), pstop(1) ), min( pstart(2), pstop(2) ), max( pstart(1), pstop(1) ), max( pstart(2), pstop(2) )];

		% toggle movements
	wait_( hfig, true );

	for si = 1:numel( edata.sigs )
		if ~gdata.fgroup(si)
			continue;
		end

		sig = edata.sigs(si);
		movs = edata.movs{si};

		sel = []; % determine selected movements
		switch ch
			case 1
				for mi = 1:numel( movs )
					ton = sig.time{[movs(mi).onset, movs(mi).qonset]};
					toff = sig.time{[movs(mi).qoffset, movs(mi).offset]};
					xon = sig.data{ch, [movs(mi).onset, movs(mi).qonset]};
					xoff = sig.data{ch, [movs(mi).qoffset, movs(mi).offset]};
					if inside_( [ton', xon'], r ) ~= inside_( [toff', xoff'], r )
						sel(end+1) = mi;
					end
				end
			case 2
				tpk = sig.time{[movs.peak]}; % peak velocity
				xpk = sig.data{ch, [movs.peak]};

				for mi = 1:numel( movs )
					if inside_( [tpk(mi), xpk(mi)], r )
						sel(end+1) = mi;
					end
				end
		end

		edata.movs{si}(sel) = togglemovs_( hfig, edata.movs{si}(sel) ); % toggle selected movements
		setappdata( hfig, 'edata', edata );
		updatemovs_( hfig, [repmat( si, [numel( sel ), 1] ), sel'] );
	end

	wait_( hfig, false );

		% TODO
	return

		% select movements inside
	for si = 1:numel( edata.sigs )
		if ~gdata.fgroup(si)
			continue;
		end

		sig = edata.sigs(si);
		movs = edata.movs{si};

		tpk = sig.time{[movs.peak]}; % instant of peak velocity
		xpk = sig.data{ch, [movs.peak]};

		sel = []; % determine selected movements
		for mi = 1:numel( movs )
			if r(1) <= tpk(mi) && tpk(mi) <= r(3) && r(2) <= xpk(mi) && xpk(mi) <= r(4)
				sel(end+1) = mi;
			end
		end

		edata.movs{si}(sel) = togglemovs_( hfig, edata.movs{si}(sel) ); % toggle selected movements
		setappdata( hfig, 'edata', edata );
		updatemovs_( hfig, [repmat( si, [numel( sel ), 1] ), sel'] );
	end

end % function

	% local functions
function tf = inside_( qs, r )
	tf = false;
	for qi = 1:size( qs, 1 )
		if r(1) <= qs(qi, 1) && qs(qi, 1) <= r(3) && r(2) <= qs(qi, 2) && qs(qi, 2) <= r(4)
			tf = true;
			break;
		end
	end
end % function

