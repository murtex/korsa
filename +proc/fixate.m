function fixate( ftr, refvals )
% fix reference signals (head movement correction)
%
% FIXATE( ftr, refvals )
%
% INPUT
% ftr : file transfer (struct scalar)
% refvals : reference values (cell string)
%
% REMARKS
% - ftr must be mapped by individual trials (sensors and axes)
% - reference signals are taken from the first dimension
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

	logger.tab( 'fix reference signals...' );
	logger.module = util.module();

		% read trial signals
	srcfn = strcat( ftr.srcbase, '.mat' );

	for fi = 1:numel( srcfcol )
		src = fullfile( ftr.srcdir, srcfcol{fi}, srcfn );
		sigs(fi) = io.readparts( src, {'sig'} );
	end

	dims = transpose( fieldnames( ftr.srcfc ) );
	trialdims = dims(~ftr.mapfexp);

	[sensvals, axvals] = io.decfcol( srcfcol, ftr.srcfc, trialdims{:} );

	iref = find( ismember( sensvals, refvals ) );
	nref = numel( iref );

	nsens = numel( sensvals );
	nax = numel( axvals );
	nt = unique( arrayfun( @( s ) numel( s.time ), sigs ) );

	if nref < 3
		error( 'invalid value: nref' );
	end
	if nax < 3
		error( 'invalid value: nax' );
	end
	if numel( nt ) ~= 1
		error( 'invalid value: nt' );
	end

		% determine fixating quaternions and transform signals, Horn's method [1]
	for si = 1:nsens
		for ai = 1:nax
			r(si, ai, :) = sigs(sub2ind( [nax, nsens], ai, si )).data(1, :);
		end
	end

	q = zeros( [4, nt] ); % fixating quaternion

	r0 = mean( r(iref, :, :), 1 ); % source centroid
	rs = r(iref, :, :)-r0; % source vectors
	rt = rs(:, :, 1); % target vector

	for ti = 1:nt
		q(:, ti) = norm_( util.absor( rt, rs(:, :, ti) ) );
	end

	for si = 1:nsens % transform signals
		r(si, :, :) = r(si, :, :)-r0;
		r(si, :, :) = qrot_( q, reshape( r(si, :, :), [nax, nt] ) );
	end

		% write trial signals
	dstfn = strcat( ftr.dstbase, '.mat' );

	for si = 1:nsens
		for ai = 1:nax
			fi = sub2ind( [nax, nsens], ai, si ); % update data
			sigs(fi).data = reshape( r(si, ai, :), [1, nt] );

			dst = fullfile( ftr.dstdir, dstfcol{fi}, dstfn ); % write data
			io.writeparts( dst, {'sig'}, sigs(fi) );
		end
	end

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

