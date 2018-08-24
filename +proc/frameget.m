function frameget( ftr, refvals, occvals, sagvals )
% determine reference frame
%
% FRAMEGET( ftr, refvals, occvals, sagvals )
%
% INPUT
% ftr : file transfer (struct scalar)
% refvals : reference values (cell string)
% occvals : occlusal plane values (cell string)
% sagvals : sagittal plane values (cell string)
%
% REMARKS
% - ftr must be mapped by individual trials (sensors and axes)
% - reference and biteplate signals are taken from the first dimension
%
% TODO: reference signals in second dimension!
%
% REFERENCES
% [1] Horn, Closed-form solution of absolute orientation using unit quaternions, JOSA, 1987

		% safeguard
	if nargin < 1 || ~io.isftr( ftr ) || ~isscalar( ftr )
		error( 'invalid argument: ftr' );
	end

	if nargin < 2 || ~iscellstr( refvals )
		error( 'invalid argument: refvals' );
	end

	if nargin < 3 || ~iscellstr( occvals )
		error( 'invalid argument: occvals' );
	end

	if nargin < 3 || ~iscellstr( sagvals )
		error( 'invalid argument: sagvals' );
	end

	logger = hLogger.instance();

		% prepare i/o
	srcfcol = io.genfcol( ftr.srcfc );
	[srcfcol, srcval] = io.valinfcol( srcfcol, ftr.srcdir, ftr.srcbase, '.mat' );

	if numel( srcfcol ) == 0
		return;
	end

	[dstfcol, dstbase] = io.subfcol( srcfcol, ftr.dstfc, ftr.dstbase );
	io.valoutfcol( dstfcol, ftr.dstdir );

	logger.tab( 'determine reference frame...' );
	logger.module = util.module();

		% read trial signals
	srcfn = strcat( ftr.srcbase, '.mat' );

	for fi = [1:numel( srcfcol )]
		src = fullfile( ftr.srcdir, srcfcol{fi}, srcfn );
		[sigs(fi), rois(fi, :)] = io.readparts( src, {'sig', 'roi'} );
	end

	dims = transpose( fieldnames( ftr.srcfc ) );
	trialdims = dims(~ftr.mapfexp);

	[sensvals, axvals] = io.decfcol( srcfcol, ftr.srcfc, trialdims{:} );

	iref = find( ismember( sensvals, refvals ) );
	nref = numel( iref );

	iocc = find( ismember( sensvals, occvals ) );
	nocc = numel( iocc );

	isag = find( ismember( sensvals, sagvals ) );
	nsag = numel( isag );

	nsens = numel( sensvals );
	nax = numel( axvals );
	nt = unique( arrayfun( @( s ) numel( s.time ), sigs ) );

	if nref < 3
		error( 'invalid value: nref' );
	end
	if nocc < 3
		error( 'invalid value: nocc' );
	end
	if nsag < 3
		error( 'invalid value: nsag' );
	end
	if nax < 3
		error( 'invalid value: nax' );
	end
	if numel( nt ) ~= 1
		error( 'invalid value: nt' );
	end

		% determine minimum roi
	roimin = max( arrayfun( @( sig, t ) sig.time2ind( t ), sigs, transpose( rois(:, 1) ) ) );
	roimax = min( arrayfun( @( sig, t ) sig.time2ind( t ), sigs, transpose( rois(:, 2) ) ) );

	if isinf( abs( roimin ) )
		roimin = 1;
	end
	if isinf( abs( roimax ) )
		roimax = nt;
	end

	iroi = [ceil( roimin ):floor( roimax )];
	nroi = numel( iroi );

		% determine occlusal plane normal
	for si = [1:nsens]
		for ai = [1:nax]
			r(si, ai, :) = sigs(sub2ind( [nax, nsens], ai, si )).data(1, :);
		end
	end

	for si = [1:nocc]
		ro(:, (si-1)*nroi+1:si*nroi) = r(iocc(si), :, iroi);
	end

	r0 = mean( ro, 2 ); % centering
	rp = ro-r0;

	cov = rp*transpose( rp )/nt; % covariances
	[vec, val] = eig( cov ); % eigenvectors
	[~, perm] = sort( diag( val ) );

	ro0 = transpose( vec(:, perm(1)) ); % plane normal
	if ro0(2) < 0
		ro0 = -ro0;
	end

		% align trial signals
	q = norm_( transpose( [1+ro0(2), cross( ro0, [0, 1, 0] )] ) ); % aligning quaternion
	q = repmat( q, [1, nt] );

	for si = [1:nsens] % transform signals
		r(si, :, :) = r(si, :, :)-reshape( r0, [1, nax, 1] );
		r(si, :, :) = qrot_( q, reshape( r(si, :, :), [nax, nt] ) );
	end

		% determine sagittal plane normal
	for si = [1:nsag]
		rs(:, (si-1)*nroi+1:si*nroi) = r(isag(si), :, iroi);
	end

	r0 = mean( rs, 2 ); % centering
	rp = rs-r0;
	rp(3, :) = rp(3, :)/100; % squeeze expected direction

	cov = rp*transpose( rp )/nt; % covariances
	[vec, val] = eig( cov ); % eigenvectors
	[~, perm] = sort( diag( val ) );

	rs0 = transpose( vec(:, perm(1)) ); % plane normal
	rs0 = norm_( [rs0(1), 0, rs0(3)] ); % parallel to occlusal plane
	if rs0(3) < 0
		rs0 = -rs0;
	end

		% align trial signals
	q = norm_( transpose( [1+rs0(3), cross( rs0, [0, 0, 1] )] ) ); % aligning quaternion
	q = repmat( q, [1, nt] );

	for si = [1:nsens] % transform signals
		r(si, :, :) = r(si, :, :)-reshape( r0, [1, nax, 1] );
		r(si, :, :) = qrot_( q, reshape( r(si, :, :), [nax, nt] ) );
	end

		% write reference frame
	for si = iocc
		frame.occ.(sensvals{si}) = reshape( r(si, :, iroi), [nax, nroi] );
	end

	for si = isag
		frame.sag.(sensvals{si}) = reshape( r(si, :, iroi), [nax, nroi] );
	end

	for si = iref
		frame.ref.(sensvals{si}) = reshape( r(si, :, iroi), [nax, nroi] );
	end

	dst = fullfile( ftr.dstdir, dstfcol{:}, strcat( ftr.dstbase, '.mat' ) );
	logger.tablog( 'write reference frame ''%s''...', dst );

	save( dst, 'frame' );

		% done
	logger.module = '';
	logger.untab();

end % function

	% local functions
function x = norm_( x )
	x = x/sqrt( sum( x.^2 ) );
end % function

function vp = qrot_( q, v )
	nt = size( q, 2 );

	w = reshape( q(1, :), [1, 1, nt] );
	x = reshape( q(2, :), [1, 1, nt] );
	y = reshape( q(3, :), [1, 1, nt] );
	z = reshape( q(4, :), [1, 1, nt] );

	M11 = 1 - 2*y.^2 - 2*z.^2;
	M12 = 2*x.*y - 2*z.*w;
	M13 = 2*x.*z + 2*y.*w;
	M21 = 2*x.*y + 2*z.*w;
	M22 = 1 - 2*x.^2 - 2*z.^2;
	M23 = 2*y.*z - 2*x.*w;
	M31 = 2*x.*z - 2*y.*w;
	M32 = 2*y.*z + 2*x.*w;
	M33 = 1 - 2*x.^2 - 2*y.^2;;

	M = cat( 2, cat( 1, M11, M21, M31 ), cat( 1, M12, M22, M32 ), cat( 1, M13, M23, M33 ) );

	for ti = 1:nt
		vp(:, ti) = M(:, :, ti)*v(:, ti);
	end
end % function

