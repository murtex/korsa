function roipca( ftr, method )
% region of interest pca
%
% ROIPCA( ftr, method )
%
% INPUT
% ftr : file transfer (struct scalar)
% method : pca method [inertia, cov, svd] (char)
%
% REMARKS
% - ftr must be mapped by individual sensors

		% safeguard
	if nargin < 1 || ~io.isftr( ftr ) || ~isscalar( ftr )
		error( 'invalid argument: ftr' );
	end

	if nargin < 2 || ~ischar( method )
		error( 'invalid argument: method' );
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

	logger.tab( 'principal component analysis (roi)...' );
	logger.module = util.module();

		% read signals
	srcfn = strcat( ftr.srcbase, '.mat' );

	for fi = 1:numel( srcfcol )
		src = fullfile( ftr.srcdir, srcfcol{fi}, srcfn );
		[sigs(fi), roi(fi, :)] = io.readparts( src, {'sig', 'roi'} );
	end

	nax = numel( sigs );
	nt = unique( arrayfun( @( s ) numel( s.time ), sigs ) );

	if nax < 3
		error( 'invalid value: nax' );
	end
	if numel( nt ) ~= 1
		error( 'invalid value: nt' );
	end

		% roi restriction
	if ~all( arrayfun( @( s ) isequal( sigs(1).time, s.time ), sigs(2:end) ) )
		error( 'invalid value: sigs' );
	end

	iroi = find( sigs(1).time >= max( roi(:, 1 ) ) & sigs(1).time <= min( roi(:, 2) ) ); % minimum roi
	nroi = numel( iroi );

	if nroi < nax
		error( 'invalid value: nroi' );
	end

		% principal component analysis
	for si = [1:nax]
		r(si, :) = sigs(si).data(1, :);
	end

	[r0, vec, val] = util.pca( method, r(:, iroi) ); % pca

	if det( vec ) < 0 % ensure proper rotation (assumes 3d)
		vec = -vec;
	end

	if vec(1, 1) < 0 % align axes (assumes 3d)
		vec(:, 1) = -vec(:, 1);
		vec(:, 3) = -vec(:, 3);
	end
	if vec(2, 2) < 0
		vec(:, 2) = -vec(:, 2);
		vec(:, 3) = -vec(:, 3);
	end

		% transform signals
	for ti = [1:nt]
		r(:, ti) = transpose( transpose( r(:, ti)-r0 )*vec );
	end

		% write signals
	dstfn = strcat( ftr.dstbase, '.mat' );

	for si = 1:nax
		sigs(si).data = r(si, :); % update data

		dst = fullfile( ftr.dstdir, dstfcol{si}, dstfn ); % write data
		io.writeparts( dst, {'sig'}, sigs(si) );
	end

		% done
	logger.module = '';
	logger.untab();

end % function


