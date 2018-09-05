function panel( ftr, dimfun, opts, figdim, titlefun, movsfun, datafuns, datafunargs, formargs, plotfuns, plotfunargs )
% panel plot
%
% PANEL( ftr, dimfun, opts, figdim, titlefun, movsfun, datafuns, datafunargs, formargs, plotfuns, plotfunargs )
%
% INPUT
% ftr : file transfer structure (scalar struct)
% dimfun : panel dimension functions [horiz, vert] (cell function handle)
% opts : panel options [see remarks] (cell string)
% figdim : figure dimensions [horiz, vert] (numeric)
% titlefun : title function (function handle)
% movsfun : movements filter function (function handle)
% datafuns : data functions (cell function_handle)
% datafunargs : data function arguments (cell cell)
% formargs : data form arguments (cell)
% plotfuns : plot functions (cell function_handle)
% plotfunargs : plot functions arguments (cell cell)
%
% REMARKS
% - 'transpose' swap panel dimensions
% - 'legend{h, v}' add {horizontal, vertical} legend
% - '{h, v}split' split panel with respect to direction flag (fpos)
% - '{h, v}joint{x, y, z, c}' join dimensions {vertically, horizontally} and injects {x, y, z} labels
% - '{h, v, s}abs{x, y, z}' and '{h, v, s}rel{x, y, z}' control {horizontal, vertical, split} axes scaling
% - '{h, v, s}even{h, v} for even axes

		% safeguard
	if nargin < 1 || ~isscalar( ftr ) || ~io.isftr( ftr )
		error( 'invalid argument: ftr' );
	end

	if nargin < 2 || ~iscell( dimfun ) || numel( dimfun ) ~= 2
		error( 'invalid argument: dimfun' );
	end

	if nargin < 3 || ~iscellstr( opts )
		error( 'invalid argument: opts' );
	end

	if nargin < 4 || ~isnumeric( figdim ) || numel( figdim ) ~= 2
		error( 'invalid argument: figdim' );
	end

	if nargin < 5 || ~isa( titlefun, 'function_handle' )
		error( 'invalid argument: titlefun' );
	end

	if nargin < 6 || ~isa( movsfun, 'function_handle' )
		error( 'invalid argument: movsfun' );
	end

	if nargin < 7 || ~iscell( datafuns ) || any( cellfun( @( f ) ~isa( f, 'function_handle' ), datafuns ) )
		error( 'invalid argument: datafuns' );
	end

	if nargin < 8 || ~iscell( datafunargs ) || any( cellfun( @( args ) ~iscell( args ), datafunargs ) )
		error( 'invalid argument: datafunargs' );
	end

	if nargin < 9 || ~iscell( formargs )
		error( 'invalid argument: formargs' );
	end

	if nargin < 10 || ~iscell( plotfuns ) || any( cellfun( @( f ) ~isa( f, 'function_handle' ), plotfuns ) )
		error( 'invalid argument: plotfuns' );
	end

	if nargin < 11 || ~iscell( plotfunargs ) || any( cellfun( @( args ) ~iscell( args ), plotfunargs ) )
		error( 'invalid argument: plotfunargs' );
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

	logger.tab( 'panel plot...' );
	logger.module = util.chainstr( '@', util.basefun( datafuns{end} ), util.basefun( plotfuns{1} ) );

		% prepare data
	[fsplit, fjoint, fover, feven] = parseopts2_( opts, 'fsplit', 'fjoint', 'fover', 'feven' );

	[data, raxd] = readraw_( ftr, dimfun, movsfun ); % read raw

	if ismember( 'transpose', opts )
		data = transpose( data );
		raxd = flip( raxd );
		dimfun = flip( dimfun );
	end

	if ismember( 'hflip', opts )
		data = flipud( data );
		raxd(1).ticks = flip( raxd(1).ticks );
		raxd(1).ticklabels = flip( raxd(1).ticklabels );
	end
	if ismember( 'vflip', opts )
		data = fliplr( data );
		raxd(2).ticks = flip( raxd(2).ticks );
		raxd(2).ticklabels = flip( raxd(2).ticklabels );
	end

	for fi = [1:numel( datafuns )] % compute data
		[data, daxd, props] = datafuns{fi}( ftr, dimfun, data, formargs, datafunargs{fi}{:} );
	end

	[data, raxd, daxd, jprops] = joinaxes_( data, raxd, daxd, opts ); % inject joint axes
	props = [props, jprops];

	ndaxes = [];
	for di = 1:numel( data )
		if ~isempty( data{di} )
			ndaxes = union( ndaxes, size( data{di}.vals, 1 ) );
		end
	end

	if numel( ndaxes ) ~= 1
		error( 'invalid value: ndaxes' );
	end

	j0data.fcol = {}; % join data
	j0data.fc = io.genfcomp( ftr.srcfc );
	j0data.fpos = false( [1, 0] );
	j0data.vals = NaN( [ndaxes, 0] );
	j0data.form = ref.form(); % TODO: determine current package/namespace!

	jx = 1;
	for dx = 1:size( data, 1 )
		jy = 1;
		for dy = 1:size( data, 2 )
			jdata{jx, jy} = joindata_( j0data, data, dx, dy, opts );

			jy = jy+1; % continue
			if fjoint(2) || fover(2) 
				break;
			end
		end

		jx = jx+1; % continue
		if fjoint(1) || fover(1)
			break;
		end
	end

	for di = 1:numel( jdata ) % TODO: some elements were skipped above
		if ~isstruct( jdata{di} )
			jdata{di} = j0data;
		end
	end

		% reshape panel figure, TODO: inject dummy data on size mismatch!?
	dshape = size( jdata );
	jdata = reshape( jdata, figdim );

		% prepare figure
	fig = hFigure();

	hax = setpanel_( fig, opts, false, jdata, dshape, daxd, raxd, props ); % create axes
	if ~isequal( size( hax ), size( jdata ) )
		error( 'invalid value: hax' );
	end

	if any( fsplit )
		hbx = setpanel_( fig, opts, true, jdata, dshape, daxd, raxd, props );
		if ~isequal( size( hbx ), size( jdata ) )
			error( 'invalid value: hbx' );
		end
	end

	if ~any( fsplit ) % set axes limits
		setlimits_( hax, hax, jdata, jdata, daxd, opts );
	else
		setlimits_( hax, hbx, splitdir_( jdata, true ), splitdir_( jdata, false ), daxd, opts );
	end

	logger.progress( 'finish panel axes...' );

	for dx = 1:size( hax, 1 ) % align axes
		fig.align( hax(dx, :), 'v' );
		if fsplit(2)
			fig.align( [hax(dx, :), hbx(dx, :)], 'v' );
		elseif fsplit(1)
			fig.align( hbx(dx, :), 'v' );
		end

		logger.progress( dx, sum( size( hax ) )+1 );
	end
	for dy = 1:size( hax, 2 )
		fig.align( hax(:, dy), 'h' );
		if fsplit(1)
			fig.align( [hax(:, dy); hbx(:, dy)], 'h' );
		elseif fsplit(2)
			fig.align( hbx(:, dy), 'h' );
		end

		logger.progress( dx+dy, sum( size( hax ) )+1 );
	end

	mdata = [data{cellfun( @( d ) ~isempty( d ), data )}]; % set title
	title = titlefun( ftr.srcfc, srcfcol, [mdata.sigs], [mdata.info] );

	if ~isempty( title )
		fig.title( title )
	else
		fig.fit();
	end

	logger.progress( dx+dy+1, sum( size( hax ) )+1 );

	if feven % even axes
		fig.even( hax );
		if any( fsplit )
			fig.even( hbx );
		end
	end

		% plot joint data
	logger.progress( 'plot panel data...' );
	di = 1;

	for dx = 1:size( hax, 1 )
		for dy = 1:size( hax, 2 )

				% split data by direction
			splitpos = splitdir_( jdata(dx, dy), true );
			splitpos = splitpos{1};
			splitneg = splitdir_( jdata(dx, dy), false );
			splitneg = splitneg{1};

			if ~isequal( size( splitpos ), size( splitneg ) )
				error( 'invalid value: splitneg' );
			end

			remerge = splitpos; % remerge for non-split panels
			for ni = 1:numel( splitneg )
				remerge(ni).fpos = [remerge(ni).fpos, splitneg(ni).fpos];
				remerge(ni).vals = [remerge(ni).vals, splitneg(ni).vals];
				remerge(ni).form = [remerge(ni).form, splitneg(ni).form];
			end

				% plot data
			for fi = [1:numel( plotfuns )]
				if ~any( fsplit )
					tmp = plotfuns{fi}( fig, hax(dx, dy), remerge, plotfunargs{fi}{:} ); % merged
					if fi == 1
						hld = tmp;
					end
				else
					tmp = plotfuns{fi}( fig, hax(dx, dy), splitpos, plotfunargs{fi}{:} ); % positive
					if fi == 1
						hld = tmp;
					end
					tmp = plotfuns{fi}( fig, hbx(dx, dy), splitneg, plotfunargs{fi}{:} ); % negative
					if fi == 1
						hld = [hld, tmp];
					end
				end
			end

				% plot legend
			hld = legend_( fig, hax(dx, dy), hld, opts );
			delete( hld ); % delete supposed objects

			logger.progress( di, prod( size( hax ) ) );
			di = di+1;
		end
	end

		% print figure
	dst = fullfile( ftr.dstdir, dstfcol{:}, strcat( dstbase, '.png' ) );
	logger.log( 'print ''%s''...', dst );
	fig.print( dst );

		% done
	logger.module = '';
	logger.untab();

end % function

