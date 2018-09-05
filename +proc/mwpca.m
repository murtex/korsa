function mwpca( ftr, method, wndcycles )
% moving window pca
%
% MWPCA( ftr, method, wndcycles )
%
% INPUT
% ftr : file transfer (struct scalar)
% method : pca method [inertia, cov, svd] (char)
% wndcycles : window size (numeric scalar)
%
% REMARKS
% - ftr must be mapped by individual sensors
%
% TODO: hard-coded assumptions on file composition (rate)

		% safeguard
	if nargin < 1 || ~io.isftr( ftr ) || ~isscalar( ftr )
		error( 'invalid argument: ftr' );
	end

	if nargin < 2 || ~ischar( method )
		error( 'invalid argument: method' );
	end

	if nargin < 3 || ~isnumeric( wndcycles ) || ~isscalar( wndcycles )
		error( 'invalid argument: wndcycles' );
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

	logger.tab( 'principal component analysis (moving window)...' );
	logger.module = util.module();

		% read signals
	srcfn = strcat( ftr.srcbase, '.mat' );

	for fi = 1:numel( srcfcol )
		src = fullfile( ftr.srcdir, srcfcol{fi}, srcfn );
		sigs(fi) = io.readparts( src, {'sig'} );
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

		% determine window size
	cycrate = io.decfcol( srcfcol, ftr.srcfc, {'rates'} );

	if numel( cycrate ) ~= 1
		error( 'invalid value: cycrate' );
	end

	cycrate = sscanf( cycrate{1}, 'bpm%d', 1 )/60;
	nwnd = wndcycles*rate/cycrate;

	if isinf( nwnd ) % finite size
		nwnd = nt;
	end

	nwnd = 2*ceil( nwnd/2 )-1; % odd size
	nwndh = (nwnd-1)/2; % half size

		% moving window pca
	for si = [1:nax]
		r(si, :) = sigs(si).data(1, :);
	end

	r0 = NaN( [nax, nt] );
	vec = NaN( [nax, nax, nt] );
	val = NaN( [nax, nt] );

	for ti = [nwndh+1:nt-nwndh]
		[r0(:, ti), vec(:, :, ti), val(:, ti)] = util.pca( method, r(:, [ti-nwndh:ti+nwndh]) ); % pca

		if det( vec(:, :, ti) ) < 0 % ensure proper rotation
			vec(:, nax, ti) = -vec(:, nax, ti);
		end

		if ti == nwndh+1 % pad left edge
			r0(:, [1:nwndh]) = repmat( r0(:, ti), [1, nwndh] );
			vec(:, :, [1:nwndh]) = repmat( vec(:, :, ti), [1, 1, nwndh] );
			val(:, [1:nwndh]) = repmat( val(:, ti), [1, nwndh] );
		elseif ti == nt-nwndh % pad right edge
			r0(:, [nt-nwndh+1:end]) = repmat( r0(:, ti), [1, nwndh] );
			vec(:, :, [nt-nwndh+1:end]) = repmat( vec(:, :, ti), [1, 1, nwndh] );
			val(:, [nt-nwndh+1:end]) = repmat( val(:, ti), [1, nwndh] );
		end
	end

		% transform signals
	for ti = [1:nt]
		r(:, ti) = transpose( transpose( r(:, ti)-r0(:, ti) )*vec(:, :, ti) );
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

