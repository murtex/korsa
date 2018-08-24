function decimate( ftr, rate )
% downsample signals (~100 hertz)
%
% DECIMATE( ftr, rate )
%
% INPUT
% ftr : file transfer (struct scalar)
% rate : target rate (numeric scalar)

		% safeguard
	if nargin < 1 || ~io.isftr( ftr ) || ~isscalar( ftr )
		error( 'invalid argument: ftr' );
	end

	if nargin < 2 || ~isnumeric( rate ) || ~isscalar( rate )
		error( 'invalid argument: rate' );
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

		% downsample signals
	logger.tab( 'downsample signals...' );
	logger.module = util.module();

	srcfn = strcat( ftr.srcbase, '.mat' );
	dstfn = strcat( ftr.dstbase, '.mat' );

	for fi = 1:numel( srcfcol )
		src = fullfile( ftr.srcdir, srcfcol{fi}, srcfn ); % read signal
		sig = io.readparts( src, {'sig'} );

		for q = sort( factor( ceil( sig.rate/rate ) ), 'descend' ) % multi-stage decimation
			sig = decimate_( sig, q );
		end

		dst = fullfile( ftr.dstdir, dstfcol{fi}, dstfn ); % write signal
		io.writeparts( dst, {'sig'}, sig );
	end

		% done
	logger.module = '';
	logger.untab();

end % function

	% local functions
function sig = decimate_( sig, q )
	sig.time = sig.time([1:q:end]);
	sig.data = decimate( sig.data(1, :), q, 'fir' ); % implies fir1( 30, 1/q )
	sig.rate = sig.rate/q;
end % function

