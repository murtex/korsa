function segment( ftr, tags )
% segment signals
%
% SEGMENT( ftr, tags )
%
% INPUT
% ftr : file transfer (struct scalar)
% tags : movement tags (cell string)

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

		% segment signals
	logger.tab( 'segment signals...' );
	logger.module = util.module();

	srcfn = strcat( ftr.srcbase, '.mat' );
	dstfn = strcat( ftr.dstbase, '.mat' );

	for fi = 1:numel( srcfcol )
		src = fullfile( ftr.srcdir, srcfcol{fi}, srcfn ); % read signal
		sig = io.readparts( src, {'sig'} );

		movs = io.genmovs();

		zc = sig.polyroot( 2, 0 ); % velocity peaks and zero crossings
		pk = sig.polyroot( 3, 0 );

		% zct = sig.time{zc}; % roi restriction
		% zc(zct < roi(1) | zct > roi(2)) = [];
		% pkt = sig.time{pk};
		% pk(pkt < roi(1) | pkt > roi(2)) = [];

		logger.progress();
		for gi = [1:numel( zc )-1]
			m0on = zc(gi); % 0-delimiters
			m0off = zc(gi+1);

			mcpk = pk(pk >= m0on & pk <= m0off); % candidate peaks
			mcpkv = sig.data{2, mcpk};

			if ~isempty( mcpk )
				[~, mpk] = max( abs( mcpkv ) ); % maximum peak

				mi = numel( movs )+1; % add movement
				movs(mi).onset = m0on;
				movs(mi).offset = m0off;
				movs(mi).peak = mcpk(mpk);
				movs(mi).q = 0;
				movs(mi).qonset = m0on;
				movs(mi).qoffset = m0off;
				movs(mi).fpos = mcpkv(mpk) > 0;
				movs(mi).tags = tags;
			end

			logger.progress( gi, numel( zc )-1 ); % continue
		end

		dst = fullfile( ftr.dstdir, dstfcol{fi}, dstfn ); % write movements
		io.writeparts( dst, {'movs'}, movs );
	end

		% done
	logger.module = '';
	logger.untab();

end % function

