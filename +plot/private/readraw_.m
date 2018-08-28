function [data, axd] = readraw_( ftr, dimfun, movsfun )
% prepare raw data
%
% [data, axd] = READRAW_( ftr, dimfun, movsfun )
%
% INPUT
% ftr : file transfer structure (scalar struct)
% dimfun : panel dimensions functions [horiz, vert] (cell function handle)
% movsfun : movements filter function (function handle)
%
% OUTPUT
% data : raw data (cell struct)
% axd : axes description (struct)

		% safeguard
	if nargin < 1 || ~isscalar( ftr ) || ~io.isftr( ftr )
		error( 'invalid argument: ftr' );
	end

	if nargin < 2 || ~iscell( dimfun ) || numel( dimfun ) ~= 2
		error( 'invalid argument: dimfun' );
	end

	if nargin < 3 || ~isa( movsfun, 'function_handle' )
		error( 'invalid argument: movsfun' );
	end

	logger = hLogger.instance();
	logger.tab( 'read raw data...' );

	style = hStyle.instance();

		% read raw data
	srcdims = transpose( fieldnames( ftr.srcfc ) );
	dims = cellfun( @( df ) df( 'field' ), dimfun, 'UniformOutput', false );

	fcol = io.genfcol( ftr.srcfc ); % prepare i/o
	fcol = io.valinfcol( fcol, ftr.srcdir, ftr.srcbase, '.mat' );

	quickdata = struct( 'srcdir', {ftr.srcdir}, 'fcol', {fcol}, 'dims', {dims} ); % quick hash
	quickhash = other.DataHash( quickdata, struct( 'Method', 'SHA-384', 'Format', 'uint8' ) );
	quickname = cell2mat( arrayfun( @( v ) num2str( v ), quickhash, 'UniformOutput', false ) );
	quickfile = fullfile( ftr.srcdir, strcat( 'raw-', quickname, '.mat' ) );

	if exist( quickfile, 'file' ) ~= 2 % read data
		data = io.mapftr( ftr, ismember( srcdims, dims ), @readsigs_ );
		save( quickfile, 'data' );
	else
		logger.log( 'quick read ''%s''...', quickfile );
		load( quickfile, 'data' );
	end

		% filter movements
	for di = 1:numel( data )
		if isempty( data{di} )
			continue;
		end

		for si = 1:numel( data{di}.sigs )
			data{di}.movs{si}(~movsfun( data{di}.movs{si} )) = [];
		end
	end

		% align raw data
	shape = [1, 1];
	if ismember( dims(1), srcdims )
		shape(1) = numel( ftr.srcfc.(dims{1}) );
	end
	if ismember( dims(2), srcdims )
		shape(2) = numel( ftr.srcfc.(dims{2}) );
	end

	if ~any( shape == 1 ) && ~issorted( dims ) % change major order
		cmo = transpose( reshape( [1:numel( data )], fliplr( shape ) ) );
		data = data(cmo(:));
	end

		% set raw axes description
	axd = [axis_( {''}, [], {}, [-Inf, Inf] ), axis_( {''}, [], {}, [-Inf, Inf] )];
	perm = {[1:shape(1)], [1:shape(2)]};

	axd(1).label = dimfun{1}( 'label' ); % first axis
	axd(1).ticks = dimfun{1}( 'numeric', ftr.srcfc.(dims{1}) );
	axd(1).limits = style.limits( axd(1).ticks, 0.1 );
	if any( isnan( axd(1).ticks ) )
		axd(1).ticks = [1:numel( axd(1).ticks )];
		axd(1).limits = [1, numel( axd(1).ticks )] + 0.5*[-1, 1];
	end
	[axd(1).ticklabels, perm{1}] = dimfun{1}( 'display', ftr.srcfc.(dims{1}) );

	axd(2).label = dimfun{2}( 'label' ); % second axis
	axd(2).ticks = dimfun{2}( 'numeric', ftr.srcfc.(dims{2}) );
	axd(2).limits = style.limits( axd(2).ticks, 0.1 );
	if any( isnan( axd(2).ticks ) )
		axd(2).ticks = [1:numel( axd(2).ticks )];
		axd(2).limits = [1, numel( axd(2).ticks )] + 0.5*[-1, 1];
	end
	[axd(2).ticklabels, perm{2}] = dimfun{2}( 'display', ftr.srcfc.(dims{2}) );

		% shape and order raw data
	data = reshape( data, shape );
	data = data(perm{1}, perm{2});

		% done
	logger.untab();

end % function

	% local functions
function data = readsigs_( ftr )

		% prepare i/o
	fcol = io.genfcol( ftr.srcfc ); % prepare i/o
	fcol = io.valinfcol( fcol, ftr.srcdir, ftr.srcbase, '.mat' );

	if numel( fcol ) < 1
		data = struct( [] );
		return;
	end

		% read signals
	data.fc = ftr.srcfc;
	data.fcol = fcol;

	for fi = 1:numel( fcol )
		infile = fullfile( ftr.srcdir, fcol{fi}, strcat( ftr.srcbase, '.mat' ) ); % read data
		[data.sigs(fi), data.info(fi), data.movs{fi}, data.roi(fi, [1, 2])] = nprivy.readsig( infile, {'sig', 'info', 'movs', 'roi'} );
	end

end % function

function axis = axis_( label, ticks, ticklabels, limits )
	axis.label = label;
	axis.ticks = ticks;
	axis.ticklabels = ticklabels;
	axis.limits = limits;
	axis.flimits = true;
end % function

