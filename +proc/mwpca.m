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

	logger.tab( 'moving window pca...' );
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
		nwnd = 1;
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
		[r0(:, ti), vec(:, :, ti), val(:, ti)] = pca_( method, r(:, [ti-nwndh:ti+nwndh]) ); % pca

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

	% local functions
function [r0, vec, val] = pca_( method, r )

		% safeguard
	if nargin < 1 || ~ischar( method )
		error( 'invalid argument: method' );
	end

	if nargin < 2 || ~isnumeric( r ) || ~ismatrix( r )
		error( 'invalid argument: r' );
	end

		% compute output
	[nx, nt] = size( r );

	if nx ~= 3
		error( 'invalid value: nx' );
	end

	switch method
		case 'inertia'
			m = ones( [1, nt] ); % barycentric system
			r0 = sum( repmat( m, [nx, 1] ).*r, 2 )/sum( m );
			rp = r-r0;

			xx = sum( m.*(rp(2, :).^2+rp(3, :).^2) ); % intertia tensor
			yy = sum( m.*(rp(1, :).^2+rp(3, :).^2) );
			zz = sum( m.*(rp(1, :).^2+rp(2, :).^2) );
			xy = -sum( m.*rp(1, :).*rp(2, :) );
			xz = -sum( m.*rp(1, :).*rp(3, :) );
			yz = -sum( m.*rp(2, :).*rp(3, :) );

			theta = [xx, xy, xz; xy, yy, yz; xz, yz, zz];

			[vec, val] = eig( theta ); % eigenvectors
			val = 1./diag( val ); % and (inverse) eigenvalues

		case 'cov'
			r0 = mean( r, 2 ); % centering
			rp = r-r0;

			cov = rp*transpose( rp )/nt; % covariances

			[vec, val] = eig( cov ); % eigenvectors
			val = diag( val ); % and eigenvalues

		case 'svd'
			error( 'invalid value: method' ); % TODO

		otherwise
			error( 'invalid value: method' );
	end

	if any( val < 0 ) % TODO: semi-definite matrix!?
		error( 'invalid value: val' );
	end

	[val, perm] = sort( val, 'descend' ); % sort by eigenvalues (most principal first)
	vec = vec(:, perm);

	[~, md] = max( abs( vec ), [], 1 ); % positive major directions
	s = sign( vec(md + [0:nx:(nx-1)*nx]) );
	vec = bsxfun( @times, vec, s );

end % function

