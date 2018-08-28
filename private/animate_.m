function animate_( ftr, titlefun, fmp4, fwnd, framerate, wndcycles, polyvals )
% animate signals
%
% ANIMATE_( ftr, titlefun, fmp4, fwnd, framerate, wndcycles, polyvals )
%
% INPUT
% ftr : file transfer (struct scalar)
% titlefun : title function (function handle)
% fmp4 : mp4 flag (logical scalar)
% framerate : animation speed (numeric scalar)
% wndcycles : window size (numeric scalar)
% polyvals : polygons values (cell cell string)

		% safeguard
	if nargin < 1 || ~io.isftr( ftr ) || ~isscalar( ftr )
		error( 'invalid argument: ftr' );
	end

	if nargin < 2 || ~isa( titlefun, 'function_handle' )
		error( 'invalid argument: titlefun' );
	end

	if nargin < 3 || ~islogical( fmp4 ) || ~isscalar( fmp4 )
		error( 'invalid argument: fmp4' );
	end

	if nargin < 4 || ~islogical( fwnd ) || ~isscalar( fwnd )
		error( 'invalid value: fwnd' );
	end

	if nargin < 5 || ~isnumeric( framerate ) || ~isscalar( framerate )
		error( 'invalid value: framerate' );
	end

	if nargin < 6 || ~isnumeric( wndcycles ) || ~isscalar( wndcycles )
		error( 'invalid argument: wndcycles' );
	end

	if nargin < 7 || ~iscell( polyvals ) || ~all( cellfun( @( pv ) iscellstr( pv ), polyvals ) )
		error( 'invalid argument: polyvals' );
	end

	logger = hLogger.instance();
	style = hStyle.instance();

		% prepare i/o
	srcfcol = io.genfcol( ftr.srcfc );
	[srcfcol, srcval] = io.valinfcol( srcfcol, ftr.srcdir, ftr.srcbase, '.mat' );

	if numel( srcfcol ) == 0
		return;
	end

	[dstfcol, dstbase] = io.subfcol( srcfcol, ftr.dstfc, ftr.dstbase );
	io.valoutfcol( dstfcol, ftr.dstdir );

	logger.tab( 'animate signals...' );
	logger.module = util.module();

		% read trial signals
	srcfn = strcat( ftr.srcbase, '.mat' );

	for fi = [1:numel( srcfcol )]
		src = fullfile( ftr.srcdir, srcfcol{fi}, srcfn );
		[sigs(fi), info(fi), movs{fi}] = io.readparts( src, {'sig', 'info', 'movs'} );

		movs{fi}(~arrayfun( @( m ) ismember( 'gest', m.tags ), movs{fi} )) = []; % gestural only
	end

	dims = transpose( fieldnames( ftr.srcfc ) );
	trialdims = dims(~ftr.mapfexp);

	[sensvals, axvals] = io.decfcol( srcfcol, ftr.srcfc, trialdims{:} );

	nsens = numel( sensvals );
	nax = numel( axvals );
	nt = unique( arrayfun( @( s ) numel( s.time ), sigs ) );

	if nax < 3
		error( 'invalid value: nax' );
	end
	if numel( nt ) ~= 1
		error( 'invalid value: nt' );
	end

		% prepare polygons
	npoly = numel( polyvals );

	for pj = [1:npoly]
		ipoly{pj} = find( ismember( sensvals, polyvals{pj} ) );
	end

		% interpolate signals
	rate = unique( arrayfun( @( sig ) sig.rate, sigs ) );

	if numel( rate ) ~= 1
		error( 'invalid value: rate' );
	end

	ntp = nt;
	ti = linspace( 1, nt, round( nt*framerate/rate ) );
	nt = numel( ti );

	for si = [1:nsens]
		for ai = [1:nax]
			sig = sigs(sub2ind( [nax, nsens], ai, si ));
			if isempty( sig.coeff )
				r(si, ai, :) = interp1( [1:ntp], sig.data(1, :), ti, 'spline' );
			else
				r(si, ai, :) = sig.data{1, ti};
			end
		end
	end

		% determine window size
	cycrate = io.decfcol( srcfcol, ftr.srcfc, {'rates'} );

	if numel( cycrate ) ~= 1
		error( 'invalid value: cycrate' );
	end

	cycrate = sscanf( cycrate{1}, 'bpm%d', 1 )/60;
	nwnd = wndcycles*framerate/cycrate;

	if nwnd == 0 || isinf( nwnd ) % finite size
		nwnd = 1;
	end

	nwnd = 2*ceil( nwnd/2 )-1; % odd size
	nwndh = (nwnd-1)/2; % half size

		% TODO: determine axes labels
	xlab = 'Horizontal';
	ylab = 'Vertical';
	zlab = 'Lateral';

		% prepare figure
	fig = hFigure( 'Visible', 'on' );
	fig.framerate = framerate;

	hax = subplot_( fig, r, xlab, ylab, zlab ); % traces
	hbx = subplot_( fig, r, xlab, ylab, zlab, 'Visible', 'off' ); % windows
	hxc = subplot_( fig, r, xlab, ylab, zlab, 'Visible', 'off' ); % polygons

	fig.linkprop( [hax, hbx, hxc], {'View'} );
	fig.linkprop( [hax, hbx, hxc], {'CameraPosition', 'CameraTarget', 'CameraUpVector', 'CameraViewAngle'} );
	fig.linkprop( [hax, hbx, hxc], {'XLim', 'YLim', 'ZLim'} ); % TODO: this seems to be not enough!

	title = titlefun( ftr.srcfc, srcfcol, sigs, info ); % title
	if ~isempty( title )
		fig.title( title, true );
	else
		fig.fit();
	end

		% prepare plot
	for si = [1:nsens]
		xp = [reshape( r(si, 1, :), [1, nt] ), NaN];
		yp = [reshape( r(si, 2, :), [1, nt] ), NaN];
		zp = [reshape( r(si, 3, :), [1, nt] ), NaN];

		fig.axes( hax ); % traces

		cp = style.color( NaN, repmat( style.shadehi, [1, numel( xp )] ) );
		
		for mi = [1:numel( movs{si} )]
			[~, t0] = min( abs( ti-movs{si}(mi).qonset ) );
			if t0 < movs{si}(mi).qonset
				t0 = t0+1;
			end
			[~, t1] = min( abs( ti-movs{si}(mi).qoffset ) );
			if t1 > movs{si}(mi).qoffset
				t1 = t1-1;
			end
			shade = linspace( style.shademed, style.shadelo, t1-t0+1 );
			cp([t0:t1], :) = style.color( ~movs{si}(mi).fpos/2, shade );
		end

		hap(si) = patch( 'XData', xp, 'YData', yp, 'ZData', zp, 'CData', cp, 'FaceVertexCData', cp, 'FaceColor', 'none', 'EdgeColor', 'flat', 'LineWidth', style.lwnorm );

		fig.axes( hbx ); % windows

		if fwnd
			cp = style.color( NaN, repmat( style.shadelo, [1, numel( xp )] ) ); % traces
			hbp(si) = patch( 'XData', xp, 'YData', yp, 'ZData', zp, 'CData', cp, 'FaceVertexCData', cp, 'FaceColor', 'none', 'EdgeColor', 'interp', 'LineWidth', style.lwthick );
		end

		cp = style.color( 2/3, style.shadelo ); % markers
		hbm(si) = patch( 'XData', xp(1), 'YData', yp(1), 'ZData', zp(1), 'FaceColor', 'none', 'EdgeColor', 'none', 'LineWidth', style.lwnorm, 'Marker', 'o', 'MarkerSize', style.mslarge, 'MarkerFaceColor', 'none', 'MarkerEdgeColor', cp );
	end

	fig.axes( hxc ); % polygons

	for pj = [1:npoly]
		xp = r(ipoly{pj}, 1, 1);
		yp = r(ipoly{pj}, 2, 1);
		zp = r(ipoly{pj}, 3, 1);

		cp = style.color( 2/3, style.shadelo );
		hcp(pj) = patch( 'XData', xp, 'YData', yp, 'ZData', zp, 'FaceColor', 'none', 'EdgeColor', cp, 'LineWidth', style.lwnorm );
	end

		% plot animation
	logger.progress();
	for tj = [1:nt]

			% update traces
		for si = [1:nsens]
			xp = [reshape( r(si, 1, [1:tj]), [1, tj] ), NaN( [1, nt-tj+1] )];
			yp = [reshape( r(si, 2, [1:tj]), [1, tj] ), NaN( [1, nt-tj+1] )];
			zp = [reshape( r(si, 3, [1:tj]), [1, tj] ), NaN( [1, nt-tj+1] )];

			% xp([1:max( 1, tj-nwnd )]) = NaN; % fade out
			% yp([1:max( 1, tj-nwnd )]) = NaN;
			% zp([1:max( 1, tj-nwnd )]) = NaN;

			set( hap(si), 'XData', xp, 'YData', yp, 'ZData', zp );
		end

			% update windows
		for si = [1:nsens]
			if fwnd
				xp = NaN( [1, nt+1] ); % traces
				yp = NaN( [1, nt+1] );
				zp = NaN( [1, nt+1] );

				twnd = [max( 1, tj-nwndh ):min( nt, tj+nwndh )];
				xp(twnd) = r(si, 1, twnd);
				yp(twnd) = r(si, 2, twnd);
				zp(twnd) = r(si, 3, twnd);
				set( hbp(si), 'XData', xp, 'YData', yp, 'ZData', zp );
			end

			xp = r(si, 1, tj); % markers
			yp = r(si, 2, tj);
			zp = r(si, 3, tj);
			set( hbm(si), 'XData', xp, 'YData', yp, 'ZData', zp );
		end

			% update polygons
		for pj = [1:npoly]
			xp = r(ipoly{pj}, 1, tj);
			yp = r(ipoly{pj}, 2, tj);
			zp = r(ipoly{pj}, 3, tj);
			set( hcp(pj), 'XData', xp, 'YData', yp, 'ZData', zp );
		end

			% update frame
		drawnow();
		if fmp4
			fig.addframe( true );
		end

		logger.progress( tj, nt );
	end

		% print
	if fmp4
		ext = '.mp4';
	else
		ext = '.png';
	end

	dst = fullfile( ftr.dstdir, dstfcol{:}, strcat( ftr.dstbase, ext ) );
	logger.tablog( 'print ''%s''...', dst );

	fig.print( dst );

		% done
	logger.module = '';
	logger.untab();

end % function

	% local functions
function h = subplot_( fig, r, xlab, ylab, zlab, varargin )
	style = hStyle.instance();

	h = fig.subplot( 1, 1, 1, 'DataAspectRatio', [1, 1, 1], varargin{:} );

	fig.xlabel( xlab );
	fig.ylabel( ylab );
	fig.zlabel( zlab );

	xlim( style.limits( r(:, 1, :), 0.1 ) );
	ylim( style.limits( r(:, 2, :), 0.1 ) );
	zlim( style.limits( r(:, 3, :), 0.1 ) );

	view( [225, 60] );
	camup( [0, 1, 0] );
end

