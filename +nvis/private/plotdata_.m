function plotdata_( hfig )
% plot data points
%
% PLOTDATA_( hfig )
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
	delete( findall( hfig, 'Tag', 'nvis:data' ) );

		% prepare properties
	edata = getappdata( hfig, 'edata' );
	gdata = getappdata( hfig, 'gdata' );

	props = {'Tag', 'nvis:data', 'Visible', 'off', 'HitTest', 'off'};

	ps = {'LineStyle', 'none', 'LineWidth', style.lwthin, 'Marker', 'o', 'MarkerEdgeColor', 'flat', 'MarkerFaceColor', 'flat', 'MarkerSize', style.msnorm};

	zoffs = 200;

		% plot ema signals
	if gdata.fema
		for si = 1:numel( edata.sigs )
			gdata.hdata{si} = [];

			sig = edata.sigs(si);

			t = [sig.time, NaN]; % discrete data
			x = [sig.data, NaN( [size( sig.data, 1 ), 1] )];

			udata.t = t; % additional info
			udata.si = si;
			udata.collo = style.color( (si-1)/numel( edata.sigs ), style.shadelo );
			udata.colhi = style.color( (si-1)/numel( edata.sigs ), style.shadehi );

			for ci = 1:numel( edata.ch )
				z = (zoffs+edata.zorder(si, ci))+[zeros( size( t )-[0, 1] ), NaN]; % depth

				if edata.ch(ci) <= size( sig.data, 1 ) % main panel
					gdata.fig.axes( gdata.hmain(ci) );
					h = patch( 'XData', t, 'YData', x(ci, :), 'ZData', z, props{:}, ps{:}, 'UserData', udata );
					gdata.hdata{si} = cat( 1, gdata.hdata{si}, h );

					if gdata.fdetail % detail panels
						h = copyobj( h, [gdata.hldet(ci), gdata.hrdet(ci)] );
						gdata.hdata{si} = cat( 1, gdata.hdata{si}, h );
					end

					if gdata.fportrait && ismember( ci, edata.iport ) % portrait panel
						gdata.fig.axes( gdata.hport(find( ci == edata.iport )) );
						patch( 'XData', x(edata.ibase, :), 'YData', x(ci, :), 'ZData', z, props{:}, ps{:}, 'UserData', udata );
					end
				end
			end
		end
	end

		% TODO: cartesian panels!

		% update immediately
	setappdata( hfig, 'gdata', gdata );

	updaterois_( hfig, false, true, false );
	updatevis_( hfig, false, true, false );

	wait_( hfig, false );

end % function

