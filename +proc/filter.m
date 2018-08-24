function filter( ftr, cutoff )
% filter signals
%
% FILTER( ftr, cutoff )
%
% INPUT
% ftr : file transfer (struct scalar)
% cutoff : cutoff frequency (numeric scalar)

		% safeguard
	if nargin < 1 || ~io.isftr( ftr ) || ~isscalar( ftr )
		error( 'invalid argument: ftr' );
	end

	if nargin < 2 || ~isnumeric( cutoff ) || ~isscalar( cutoff )
		error( 'invalid argument: cutoff' );
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
	logger.tab( 'filter signals...' );
	logger.module = util.module();

	srcfn = strcat( ftr.srcbase, '.mat' );
	dstfn = strcat( ftr.dstbase, '.mat' );

	for fi = 1:numel( srcfcol )
		src = fullfile( ftr.srcdir, srcfcol{fi}, srcfn ); % read signal
		sig = io.readparts( src, {'sig'} );

		[z, p, k] = butter( 4, cutoff/(sig.rate/2) ); % 80dB/dec attenuation
		[sos, g] = zp2sos( z, p, k );

		sig.data = filtfilt( sos, g, sig.data(1, :) ); % zero-phase delay
		
		dst = fullfile( ftr.dstdir, dstfcol{fi}, dstfn ); % write signal
		io.writeparts( dst, {'sig'}, sig );
	end

		% done
	logger.module = '';
	logger.untab();

end % function

