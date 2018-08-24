function copy( ftr, parts )
% copy data parts
%
% COPY( ftr, parts )
%
% INPUT
% ftr : file transfer (struct scalar)
% parts : data parts [sig, info, roi, movs] (cell string)

		% safeguard
	if nargin < 1 || ~io.isftr( ftr ) || ~isscalar( ftr )
		error( 'invalid argument: ftr' );
	end

	if nargin < 2 || ~iscellstr( parts ) || ~io.isparts( parts )
		error( 'invalid argument: parts' );
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

		% copy data parts
	logger.tab( 'copy data parts...' );
	logger.module = util.module();

	srcfn = strcat( ftr.srcbase, '.mat' );
	dstfn = strcat( ftr.dstbase, '.mat' );

	for fi = 1:numel( srcfcol )
		src = fullfile( ftr.srcdir, srcfcol{fi}, srcfn ); % read data
		[data{1:numel( parts )}] = io.readparts( src, parts );

		dst = fullfile( ftr.dstdir, dstfcol{fi}, dstfn ); % write data
		io.writeparts( dst, parts, data{:} );
	end

		% done
	logger.module = '';
	logger.untab();

end % function

