function qnarrowsub( ftr, q, sub )
% q-narrowing (subsampling)
%
% QNARROWSUB( ftr, q, sub )
%
% INPUT
% ftr : file transfer (struct scalar)
% q : q-value (numeric scalar)
% sub : subsampling (numeric scalar)
%
% REMARKS
% - ftr must be mapped by individual sensors
%
% TODO: hard-coded assumptions on file composition (rate)

		% safeguard
	if nargin < 1 || ~io.isftr( ftr ) || ~isscalar( ftr )
		error( 'invalid argument: ftr' );
	end

	if nargin < 2 || ~isnumeric( q ) || ~isscalar( q )
		error( 'invalid argument: q' );
	end

	if nargin < 3 || ~isnumeric( sub ) || ~isscalar( sub )
		error( 'invalid argument: sub' );
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

	logger.tab( 'q-narrowing (subsampled)...' );
	logger.module = util.module();

		% read signals
	srcfn = strcat( ftr.srcbase, '.mat' );

	for fi = 1:numel( srcfcol )
		src = fullfile( ftr.srcdir, srcfcol{fi}, srcfn );
		[sigs(fi), movs{fi}] = io.readparts( src, {'sig', 'movs'} );
	end

	nax = numel( sigs );
	nt = unique( arrayfun( @( s ) numel( s.time ), sigs ) );
	rate = unique( arrayfun( @( s ) s.rate, sigs ) );

	if nax < 3
		error( 'invalid value: nax' );
	end
	if numel( nt ) ~= 1
		error( 'invalid value: nt' );
	end
	if numel( rate ) ~= 1
		error( 'invalid value: rate' );
	end

	if numel( unique( cellfun( @numel, movs ) ) ) ~= 1
		error( 'invalid value: movs' );
	end
	movs = movs{1};

		% q-narrow movements
	for mi = [1:numel( movs )]
		% shift = (movs(mi).onset-movs(mi).offset)/2; % DEBUG: pi/2-shift
		% movs(mi).onset = movs(mi).onset+shift;
		% movs(mi).offset = min( numel( sigs(1).time ), movs(mi).offset+shift );

		ti = linspace( movs(mi).onset, movs(mi).offset, sub ); % subsampling
		vel = sqrt( sigs(1).data{2, ti}.^2+sigs(2).data{2, ti}.^2+sigs(3).data{2, ti}.^2 );

		[pvel, pk] = max( vel ); % peak velocity
		movs(mi).peak = ti(pk);

		movs(mi).q = q; % q-delimiters
		movs(mi).qonset = ti(find( vel >= q*(pvel-vel(1))+vel(1), 1, 'first' ));
		movs(mi).qoffset = ti(find( vel >= q*(pvel-vel(end))+vel(end), 1, 'last' ));
	end

		% write movements
	dstfn = strcat( ftr.dstbase, '.mat' );

	for si = 1:nax
		dst = fullfile( ftr.dstdir, dstfcol{si}, dstfn );
		io.writeparts( dst, {'movs'}, movs );
	end

		% done
	logger.module = '';
	logger.untab();

end % function

