function plotsigs_( hfig )
% plot signals
%
% PLOTSIGS_( hfig )
%
% INPUT
% hfig : figure handle (TODO)

		% safeguard
	if nargin < 1
		error( 'invalid argument: hfig' );
	end

	wait_( hfig, true );

	style = hStyle.instance();

		% clear figure
	delete( findall( hfig, 'Tag', 'nvis:signal' ) );

		% prepare properties
	adata = getappdata( hfig, 'adata' );
	edata = getappdata( hfig, 'edata' );
	gdata = getappdata( hfig, 'gdata' );

	props = {'Tag', 'nvis:signal', 'Visible', 'off', 'HitTest', 'off'};
	ps = {'EdgeColor', 'flat', 'LineWidth', style.lwnorm};

	zoffs = 100;

	collo = style.color( 0, style.shadelo );

		% plot audio signals
	if gdata.faudio
		for si = 1:numel( adata.sigs )
			sig = adata.sigs(si);

			t = [sig.time, NaN]; % discrete data
			x = [sig.data(adata.ch, :), NaN( [numel( adata.ch ), 1] )];
			z = (zoffs+adata.zorder(si, 1))+[zeros( size( t )-[0, 1] ), NaN];

			udata.t = t; % additional info
			udata.si = si;
			udata.collo = style.color( 0, style.shadelo );
			udata.colhi = style.color( 0, style.shadehi );

			gdata.fig.axes( gdata.haudio(si) ); % plot
			patch( 'XData', t, 'YData', x, 'ZData', z, props{:}, ps{:}, 'UserData', udata );
		end
	end
	
		% plot ema signals
	if gdata.fema
		for si = 1:numel( edata.sigs )
			gdata.hsigs{si} = [];

			sig = edata.sigs(si);

			ti = linspace( 1, numel( sig.time ), gdata.vres*numel( sig.time )-(gdata.vres-1) ); % interpolated data
			ti = union( ti, [2:numel( sig.time )]-1/1024 );

			t = [sig.time{ti}, NaN];
			x = [sig.data{edata.ch, ti}, NaN( [numel( edata.ch ), 1] )];

			udata.t = t; % additional info
			udata.si = si;
			udata.collo = style.color( (si-1)/numel( edata.sigs ), style.shadelo );
			udata.colhi = style.color( (si-1)/numel( edata.sigs ), style.shadehi );
			%udata.collo = style.color( NaN, style.shadelo ); % DEBUG
			%udata.colhi = style.color( NaN, style.shadehi );

			for ci = 1:numel( edata.ch )
				z = (zoffs+edata.zorder(si, ci))+[zeros( size( t )-[0, 1] ), NaN]; % depth

				gdata.fig.axes( gdata.hmain(ci) ); % main panel
				h = patch( 'XData', t, 'YData', x(ci, :), 'ZData', z, props{:}, ps{:}, 'UserData', udata );
				gdata.hsigs{si} = cat( 1, gdata.hsigs{si}, h );

				if gdata.fdetail % detail panels
					h = copyobj( h, [gdata.hldet(ci), gdata.hrdet(ci)] );
					gdata.hsigs{si} = cat( 1, gdata.hsigs{si}, h );
				end

				if gdata.fportrait && ismember( ci, edata.iport ) % portrait panel
					gdata.fig.axes( gdata.hport(find( ci == edata.iport )) );
					patch( 'XData', x(edata.ibase, :), 'YData', x(ci, :), 'ZData', z, props{:}, ps{:}, 'UserData', udata );
				end
			end
		end
	end

	if gdata.fcart % assuming uniform timing
		six = 1;
		siy = 2;
		sigx = edata.sigs(six);
		sigy = edata.sigs(siy);

		ti = linspace( 1, numel( sigx.time ), gdata.vres*numel( sigx.time )-(gdata.vres-1) ); % interpolated data
		ti = union( ti, [2:numel( sigx.time )]-1/1024 );

		t = [sigx.time{ti}, NaN];
		x = [sigx.data{edata.ch, ti}, NaN( [numel( edata.ch ), 1] )];
		y = [sigy.data{edata.ch, ti}, NaN( [numel( edata.ch ), 1] )];

		udata.t = t; % additional info
		udata.si = six;
		udata.collo = style.color( (six-1)/numel( edata.sigs ), style.shadelo );
		udata.colhi = style.color( (six-1)/numel( edata.sigs ), style.shadehi );

		for ci = 1:numel( edata.ch )
			z = (zoffs+edata.zorder(six, ci))+[zeros( size( t )-[0, 1] ), NaN]; % depth

			gdata.fig.axes( gdata.hcart(ci) );
			patch( 'XData', x(ci, :), 'YData', y(ci, :), 'ZData', z, props{:}, ps{:}, 'UserData', udata );
		end
	end

		% update immediately
	setappdata( hfig, 'gdata', gdata );

	updaterois_( hfig, true, false, false );
	updatevis_( hfig, true, false, false );

	wait_( hfig, false );

end % function

