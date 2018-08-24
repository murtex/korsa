function minroi( ftr, tags )
% minimize roi
%
% MINROI( ftr, tags )
%
% INPUT
% ftr : file transfer (struct scalar)
% tags : movement tags (cell string)
%
% REMARKS
% - ftr must be mapped by individual trials (sensors and axes)

		% safeguard
	if nargin < 1 || ~io.isftr( ftr ) || ~isscalar( ftr )
		error( 'invalid argument: ftr' );
	end

	if nargin < 2 || ~iscellstr( tags )
		error( 'invalid argument: tags' );
	end

	logger = hLogger.instance();

		% prepare i/o
	srcfcol = io.genfcol( ftr.srcfc );
	[srcfcol, srcval] = io.valinfcol( srcfcol, ftr.srcdir, ftr.srcbase, '.mat' );

	if numel( srcfcol ) == 0
		return;
	end

	dstfcol = io.genfcol( ftr.dstfc );
	dstfcol = dstfcol(srcval);
	io.valoutfcol( dstfcol, ftr.dstdir );

	logger.tab( 'minimize roi...' );
	logger.module = util.module();

		% read trial signals
	srcfn = strcat( ftr.srcbase, '.mat' );

	for fi = [1:numel( srcfcol )]
		src = fullfile( ftr.srcdir, srcfcol{fi}, srcfn );
		[sigs(fi), movs{fi}] = io.readparts( src, {'sig', 'movs'} );

		movs{fi} = movs{fi}(io.filtmovs( movs{fi}, tags, {} )); % tag filter
	end

		% determine minimum roi
	roi = NaN( [1, 2] );

	for si = [1:numel( sigs )]
		if isempty( movs{si} )
			continue;
		end

		onsets = [movs{si}.onset];
		offsets = [movs{si}.offset];
		padding = mean( offsets-onsets );

		roi(1) = min( roi(1), sigs(si).time{max( 1, min( onsets )-padding )} );
		roi(2) = max( roi(2), sigs(si).time{min( numel( sigs(si).time ), max( onsets )+padding )} );
	end

	if any( isnan( roi ) )
		roi = [-Inf, Inf];
	end

		% write roi
	dstfn = strcat( ftr.dstbase, '.mat' );

	for fi = 1:numel( dstfcol )
		dst = fullfile( ftr.dstdir, dstfcol{fi}, dstfn );
		io.writeparts( dst, {'roi'}, roi );
	end

		% done
	logger.module = '';
	logger.untab();

end % function


