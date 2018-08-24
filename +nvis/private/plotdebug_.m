function plotdebug_( hfig )
% plot debuggings
%
% PLOTDEBUG_( hfig )
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
	delete( findall( hfig, 'Tag', 'nvis:debug' ) );

		% prepare properties
	edata = getappdata( hfig, 'edata' );
	gdata = getappdata( hfig, 'gdata' );

	props = {'Tag', 'nvis:debug', 'Visible', 'off', 'HitTest', 'off'};

	pszc = {'LineStyle', 'none', 'LineWidth', style.lwthin, 'Marker', 'o', 'MarkerEdgeColor', 'flat', 'MarkerFaceColor', 'flat', 'MarkerSize', style.msnorm};
	pspk = {'LineStyle', 'none', 'LineWidth', style.lwthin, 'Marker', 'o', 'MarkerEdgeColor', 'flat', 'MarkerFaceColor', 'none', 'MarkerSize', style.msnorm};

	zoffs = 300;

		% plot ema signals
	if gdata.fema
		for si = 1:numel( edata.sigs )
			gdata.hdebug{si} = [];

			sig = edata.sigs(si);

			for ci = 1:numel( edata.ch )

				zc = edata.zc{si, ci}; % zero crossings and peaks
				pk = edata.pk{si, ci};

				tzc = [sig.time{zc}, NaN];
				tpk = [sig.time{pk}, NaN];

				xzc = [sig.data{edata.ch(ci), zc}, NaN];
				xpk = [sig.data{edata.ch(ci), pk}, NaN];

				zzc = (zoffs+edata.zorder(si, ci))+[zeros( size( tzc )-[0, 1] ), NaN];
				zpk = (zoffs+edata.zorder(si, ci))+[zeros( size( tpk )-[0, 1] ), NaN];

				udatazc.t = tzc; % additional info
				udatazc.si = si;
				udatazc.collo = style.color( (si-1)/numel( edata.sigs ), style.shadelo );
				udatazc.colhi = style.color( (si-1)/numel( edata.sigs ), style.shadehi );

				udatapk.t = tpk;
				udatapk.si = si;
				udatapk.collo = style.color( (si-1)/numel( edata.sigs ), style.shadelo );
				udatapk.colhi = style.color( (si-1)/numel( edata.sigs ), style.shadehi );

				gdata.fig.axes( gdata.hmain(ci) ); % main panel
				hzc = patch( 'XData', tzc, 'YData', xzc, 'ZData', zzc, props{:}, pszc{:}, 'UserData', udatazc );
				hpk = patch( 'XData', tpk, 'YData', xpk, 'ZData', zpk, props{:}, pspk{:}, 'UserData', udatapk );
				gdata.hdebug{si} = cat( 1, gdata.hdebug{si}, hzc, hpk );

				if gdata.fdetail % detail panels
					h1 = copyobj( hzc, [gdata.hldet(ci), gdata.hrdet(ci)] );
					h2 = copyobj( hpk, [gdata.hldet(ci), gdata.hrdet(ci)] );
					gdata.hdebug{si} = cat( 1, gdata.hdebug{si}, h1, h2 );
				end

				if gdata.fportrait % TODO: portrait panel
				end
			end
		end
	end

		% TODO: cartesian panels!

		% update immediately
	setappdata( hfig, 'gdata', gdata );

	updaterois_( hfig, false, false, true );
	updatevis_( hfig, false, false, true );

	wait_( hfig, false );

end % function

