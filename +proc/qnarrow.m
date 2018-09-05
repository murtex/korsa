function qnarrow( ftr, q )
% q-narrowing (analytical)
%
% QNARROW( ftr, q )
%
% INPUT
% ftr : file transfer (struct scalar)
% q : q-value (numeric scalar)
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
	logger.tab( 'q-narrowing (analytical)...' );
	logger.module = util.module();

	srcfn = strcat( ftr.srcbase, '.mat' );
	dstfn = strcat( ftr.dstbase, '.mat' );

	for fi = 1:numel( srcfcol )
		src = fullfile( ftr.srcdir, srcfcol{fi}, srcfn ); % read signal
		[sig, movs] = io.readparts( src, {'sig', 'movs'} );

		if numel( movs ) == 0
			continue;
		end

		for mi = [1:numel( movs )] % q-narrow delimiters
			qczc = sig.polyroot( 2, -q*sig.data{2, movs(mi).peak}, [movs(mi).onset, movs(mi).offset] ); % candidate delimiters
			qczc(qczc < movs(mi).onset | qczc > movs(mi).offset) = [];

			qon = min( qczc(qczc < movs(mi).peak) ); % widest delimiters
			qoff = max( qczc(qczc > movs(mi).peak) );

			if ~isempty( qon ) && ~isempty( qoff ) % update movements
				movs(mi).q = q;
				movs(mi).qonset = qon;
				movs(mi).qoffset = qoff;
			else
				movs(mi).q = 0;
				movs(mi).qonset = movs(mi).onset;
				movs(mi).qoffset = movs(mi).offset;
			end
		end

		dst = fullfile( ftr.dstdir, dstfcol{fi}, dstfn ); % write movements
		io.writeparts( dst, {'movs'}, movs );
	end

		% done
	logger.module = '';
	logger.untab();

end % function

