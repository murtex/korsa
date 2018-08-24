function frameset( ftr, ftrget, fexpget )
% align reference frame
%
% FRAMESET( ftr, ftrget, fexpget )
%
% INPUT
% ftr : file transfer (struct scalar)
% ftrget : file transfer used while mapping refget (struct scalar)
% fexpget : file expansion flags used while mappin refget (logical)
%
% REMARKS
% - ftr must be mapped by individual trials (sensors and axes)
%
% REFERENCES
% [1] Horn, Closed-form solution of absolute orientation using unit quaternions, JOSA, 1987

		% safeguard
	if nargin < 1 || ~io.isftr( ftr ) || ~isscalar( ftr )
		error( 'invalid argument: ftr' );
	end

	if nargin < 2 || ~io.isftr( ftrget ) || ~isscalar( ftrget )
		error( 'invalid argument: ftrget' );
	end

	if nargin < 3 || ~islogical( fexpget )
		error( 'invalid argument: fexpget' );
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

	logger.tab( 'align reference frame...' );
	logger.module = util.module();

		% read reference frames
	ftrget.srcfc = io.filtfcomp( ftrget.srcfc, {'subjects'}, {ftr.srcfc.subjects}, true );
	ftrget.dstfc = io.filtfcomp( ftrget.dstfc, {'subjects'}, {ftr.srcfc.subjects}, true );

	frame = io.mapftr( ftrget, fexpget, @getframe_ );
	frame(cellfun( @isempty, frame )) = [];

	if numel( frame ) == 0
		error( 'invalid value: frame' );
	end

		% determin minimum-variance frame
	for fi = [1:numel( frame )]
		tmp = cell2mat( struct2cell( frame{fi}.occ ) );
		score(fi) = mean( var( tmp, 0, 2 ) )/size( tmp, 2 );
	end

	[~, iopt] = min( score );
	frame = frame{iopt};

		% read trial signals
	srcfn = strcat( ftr.srcbase, '.mat' );

	for fi = 1:numel( srcfcol )
		src = fullfile( ftr.srcdir, srcfcol{fi}, srcfn );
		sigs(fi) = io.readparts( src, {'sig'} );
	end

	dims = transpose( fieldnames( ftr.srcfc ) );
	trialdims = dims(~ftr.mapfexp);

	[sensvals, axvals] = io.decfcol( srcfcol, ftr.srcfc, trialdims{:} );

	refvals = fieldnames( frame.ref );
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

		% determine aligning quaternions and transform signals, Horn's method [1]
	for si = [1:nsens]
		for ai = [1:nax]
			r(si, ai, :) = sigs(sub2ind( [nax, nsens], ai, si )).data(1, :);
		end
	end

	r0 = mean( r(iref, :, :), 1 ); % source
	rs = r(iref, :, :)-r0;

	tmp = cell2mat( struct2cell( frame.ref ) ); % target
	for si = [1:numel( refvals )]
		for ai = [1:nax]
			rt(si, ai) = tmp(sub2ind( [nax, numel( refvals )], ai, si ), 1);
		end
	end
	rt = rt-mean( rt, 1 );

	for ti = [1:nt] % aligning quaternions
		q(:, ti) = norm_( util.absor( rt, rs(:, :, ti) ) );
	end

	for si = [1:nsens] % transform signals
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
function frame = getframe_( ftr )
	logger = hLogger.instance();

		% prepare i/o
	srcfcol = io.genfcol( ftr.srcfc );
	[srcfcol, srcval] = io.valinfcol( srcfcol, ftr.srcdir, ftr.srcbase, '.mat' );

	if numel( srcfcol ) == 0
		frame = [];
		return;
	end

	[dstfcol, dstbase] = io.subfcol( srcfcol, ftr.dstfc, ftr.dstbase );
	io.valoutfcol( dstfcol, ftr.dstdir );

		% read reference frame
	dst = fullfile( ftr.dstdir, dstfcol{:}, strcat( ftr.dstbase, '.mat' ) );
	logger.log( 'read reference frame ''%s''...', dst );
	load( dst, 'frame' );

end % function

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

