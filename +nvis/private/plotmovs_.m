function plotmovs_( hfig )
% plot movements
%
% PLOTMOVS_( hfig )
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
	delete( findall( hfig, 'Tag', 'nvis:movement' ) );

		% prepare properties
	adata = getappdata( hfig, 'adata' );
	edata = getappdata( hfig, 'edata' );
	gdata = getappdata( hfig, 'gdata' );

	props = {'Tag', 'nvis:movement', 'Visible', 'off', 'HitTest', 'off'};

	zoffs = 0;

		% plot and link ema movements
	edata.link1 = cell( [numel( edata.sigs ), numel( edata.ch )] );
	edata.link2 = cell( [numel( edata.sigs ), numel( edata.ch )] );
	edata.link3 = cell( [numel( edata.sigs ), numel( edata.ch )] );

	if gdata.fema
		for si = 1:numel( edata.sigs )
			gdata.hmovs{si} = [];

			sig = edata.sigs(si);
			movs = edata.movs{si};

			ton = sig.time{[movs.onset]}; % temporal values
			toff = sig.time{[movs.offset]};
			tqon = sig.time{[movs.qonset]};
			tqoff = sig.time{[movs.qoffset]};
			tpk = sig.time{[movs.peak]};

			xmin = -Inf( [numel( edata.ch ), numel( movs )] ); % spatial extrema
			xmax = Inf( [numel( edata.ch ), numel( movs )] );
			for mi = 1:numel( movs )
				xl = getxlim_( sig, edata.ch, edata.pk(si, :), [ton(mi), toff(mi)] );
				xl = cat( 1, xl{:} );
				xmin(:, mi) = xl(:, 1);
				xmax(:, mi) = xl(:, 2);
			end

			for ci = 1:numel( edata.ch )
				z = (zoffs+edata.zorder(si, ci))+zeros( [4, numel( ton )] ); % depth

					% draw movements
				gdata.fig.axes( gdata.hmain(ci) );

				hmovs = fill3( [ton; ton; toff; toff], [xmin(ci, :); xmax(ci, :); xmax(ci, :); xmin(ci, :)], z, [1, 1, 1], props{:}, 'HitTest', 'off' );
				hqmovs = fill3( [tqon; tqon; tqoff; tqoff], [xmin(ci, :); xmax(ci, :); xmax(ci, :); xmin(ci, :)], z, [1, 1, 1], props{:}, 'HitTest', 'on' );
				hpkmovs = line( [tpk; tpk], [xmin(ci, :); xmax(ci, :)], z([1, 2], :), props{:}, 'HitTest', 'off' );
				gdata.hmovs{si} = cat( 1, gdata.hmovs{si}, hmovs, hqmovs, hpkmovs );

					% link movements
				edata.link1{si, ci} = hmovs;
				edata.link2{si, ci} = hqmovs;
				edata.link3{si, ci} = hpkmovs;

				for mi = 1:numel( movs )
					udata.si = si;
					udata.mi = mi;
					set( hqmovs(mi), 'UserData', udata );
				end
			end
		end
	end

	setappdata( hfig, 'edata', edata );

		% update immediately
	setappdata( hfig, 'gdata', gdata );

	updatemovs_( hfig, [] );

	wait_( hfig, false );

end % function

