function spline( ftr, nmk )
% signal spline approximation
%
% SPLINE( ftr, nmk )
%
% INPUT
% ftr : file transfer (struct scalar)
% nmk : spline settings [order, knots, continuity] (numeric)

		% safeguard
	if nargin < 1 || ~io.isftr( ftr ) || ~isscalar( ftr )
		error( 'invalid argument: ftr' );
	end

	if nargin < 2 || ~isnumeric( nmk ) || numel( nmk ) ~= 3
		error( 'invalid argument: nmk' );
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

		% spline approximation
	logger.tab( 'spline approximation...' );
	logger.module = util.module();

	srcfn = strcat( ftr.srcbase, '.mat' );
	dstfn = strcat( ftr.dstbase, '.mat' );

	for fi = 1:numel( srcfcol )
		src = fullfile( ftr.srcdir, srcfcol{fi}, srcfn ); % read signal
		sig = io.readparts( src, {'sig'} );

		sig.approx( nmk(1), nmk(2), nmk(3) ); % approximate signal

		dst = fullfile( ftr.dstdir, dstfcol{fi}, dstfn ); % write signal
		io.writeparts( dst, {'sig'}, sig );
	end

		% done
	logger.module = '';
	logger.untab();

end % function

