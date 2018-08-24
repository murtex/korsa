function updatemovs_( hfig, imovs )
% update movements
%
% UPDATEMOVS_( hfig, imovs )
%
% INPUT
% hfig : figure handle (TODO)
% imovs : specific movement indices [sis, mis] (numeric)

		% safeguard
	if nargin < 1
		error( 'invalid argument: hfig' );
	end

	if nargin < 2 || ~isnumeric( imovs )
		error( 'invalid argument: imovs' );
	end

	style = hStyle.instance();

	global NVIS_BRIGHTEN;

		% fast visibility shortcut
	edata = getappdata( hfig, 'edata' );
	gdata = getappdata( hfig, 'gdata' );

	if ~any( gdata.fmovs )
		set( findall( hfig, 'Tag', 'nvis:movement' ), 'Visible', 'off' );
		return;
	end

	wait_( hfig, true );

		% prepare styles
	colunsello = style.color( NaN, style.shadelo + 0.3 ); % unselected
	colunselhi = style.color( NaN, style.shadehi + 0.3 );

	fsunsel = {'EdgeColor', colunsello, 'FaceColor', 'none', 'LineWidth', style.lwthin, 'LineStyle', '-.'};
	qfsunsel = {'EdgeColor', colunsello, 'FaceColor', colunselhi, 'LineWidth', style.lwthin};
	lsunsel = {'Color', colunsello, 'LineWidth', style.lwthin, 'LineStyle', '-.'};

		% update movements
	sis = 1:numel( edata.sigs );
	if ~isempty( imovs )
		sis = transpose( imovs(:, 1) );
	end

	for si = sis;
		sig = edata.sigs(si);
		movs = edata.movs{si};

			% prepare inclusion and exclusion sets
		ins = [];
		exs = [];
		sels = [];
		neg = [];

		mis = 1:numel( movs );
		if ~isempty( imovs )
			mis = transpose( imovs(:, 2) );
		end

		for mi = mis
			fsel = any( ismember( movs(mi).tags, gdata.filtsel ) );
			if fsel || (any( ismember( movs(mi).tags, gdata.filtin ) ) && ~any( ismember( movs(mi).tags, gdata.filtex ) ))
				if fsel
					sels(end+1) = mi;
					if ~movs(mi).fpos
						neg(end+1) = mi;
					end
				else
					ins(end+1) = mi;
				end
			else
				exs(end+1) = mi;
			end
		end

			% style sets
		vis1 = {'Visible', 'on', 'HitTest', 'off'};
		vis2 = {'Visible', 'on', 'HitTest', 'on'};
		vis3 = {'Visible', 'on', 'HitTest', 'off'};
		if ~gdata.fmovs(1) || ~gdata.fgroup(si)
			vis1 = {'Visible', 'off', 'HitTest', 'off'};
		end
		if ~gdata.fmovs(2) || ~gdata.fgroup(si)
			vis2 = {'Visible', 'off', 'HitTest', 'off'};
		end
		if ~gdata.fmovs(3) || ~gdata.fgroup(si)
			vis3 = {'Visible', 'off', 'HitTest', 'off'};
		end

		colsello = style.color( (si-1)/numel( edata.sigs ), style.shadelo + NVIS_BRIGHTEN ); % selected
		colselhi = style.color( (si-1)/numel( edata.sigs ), shade_( style.shadehi ) + NVIS_BRIGHTEN );

		colselloneg = style.color( 1/2+(si-1)/numel( edata.sigs ), style.shadelo + NVIS_BRIGHTEN ); % openings
		colselhineg = style.color( 1/2+(si-1)/numel( edata.sigs ), shade_( style.shadehi ) + NVIS_BRIGHTEN );

		fssel = {'EdgeColor', colsello, 'FaceColor', 'none', 'LineWidth', style.lwthin, 'LineStyle', '-.'};
		qfssel = {'EdgeColor', colsello, 'FaceColor', colselhi, 'LineWidth', style.lwthin};
		lssel = {'Color', colsello, 'LineWidth', style.lwthin, 'LineStyle', '-.'};

		fsselneg = {'EdgeColor', colselloneg, 'FaceColor', 'none', 'LineWidth', style.lwthin, 'LineStyle', '-.'};
		qfsselneg = {'EdgeColor', colselloneg, 'FaceColor', colselhineg, 'LineWidth', style.lwthin};
		lsselneg = {'Color', colselloneg, 'LineWidth', style.lwthin, 'LineStyle', '-.'};

		for ci = 1:numel( edata.ch )
			set( edata.link1{si, ci}(exs), 'Visible', 'off', 'HitTest', 'off' );
			set( edata.link2{si, ci}(exs), 'Visible', 'off', 'HitTest', 'off' );
			set( edata.link3{si, ci}(exs), 'Visible', 'off', 'HitTest', 'off' );

			set( edata.link1{si, ci}(ins), vis1{:}, fsunsel{:} );
			set( edata.link2{si, ci}(ins), vis2{:}, qfsunsel{:} );
			set( edata.link3{si, ci}(ins), vis3{:}, lsunsel{:} );

			set( edata.link1{si, ci}(sels), vis1{:}, fssel{:} );
			set( edata.link2{si, ci}(sels), vis2{:}, qfssel{:} );
			set( edata.link3{si, ci}(sels), vis3{:}, lssel{:} );

			%set( edata.link1{si, ci}(neg), vis1{:}, fsselneg{:} ); % re-color negative direction
			%set( edata.link2{si, ci}(neg), vis2{:}, qfsselneg{:} );
			%set( edata.link3{si, ci}(neg), vis3{:}, lsselneg{:} );
		end

	end

	wait_( hfig, false );

end % function

	% local functions
function shade = shade_( shade )
	style = hStyle.instance();
	shade = shade*(style.shadehi-style.shadelo)+style.shadelo;
end % function

