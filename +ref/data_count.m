function [data, axd, props] = data_count( ftr, dimfun, data, formargs )
% token count
%
% [data, axd, props] = DATA_COUNT( ftr, dimfun, data, formargs )
%
% INPUT
% ftr : file transfer structure (scalar struct)
% dimfun : panel dimension functions [horiz, vert] (cell function handle)
% data : raw data (cell struct)
% formargs : data form arguments (cell)
%
% OUTPUT
% data : derived data (cell struct)
% axd : axes description (struct)
% props : axes properties (cell)

		% safeguard
	if nargin < 1 || ~isscalar( ftr ) || ~io.isftr( ftr )
		error( 'invalid argument: ftr' );
	end

	if nargin < 2 || ~iscell( dimfun ) || numel( dimfun ) ~= 2
		error( 'invalid argument: dimfun' );
	end

	if nargin < 3 || ~iscell( data ) || ~all( cellfun( @( d ) isstruct( d ), data(:) ) )
		error( 'invalid argument: data' );
	end

	if nargin < 4 || ~iscell( formargs )
		error( 'invalid argument: formargs' );
	end

	logger = hLogger.instance();

		% set axes
	[axd, props] = axes_();

		% proceed data
	logger.progress( 'determine token count...' );

	for di = 1:numel( data )
		if isempty( data{di} )
			logger.progress( di, numel( data ) );
			continue;
		end

			% proceed bundles
		naxes = numel( io.decfcol( data{di}.fcol, data{di}.fc, 'axes' ) );
		nbundles = numel( data{di}.sigs )/naxes;

		fpos = [true, false];
		count = zeros( [1, 2] );

		for bi = [1:nbundles]

				% verify bundle
			sigs = data{di}.sigs(naxes*(bi-1)+[1:naxes]);
			movs = data{di}.movs(naxes*(bi-1)+[1:naxes]);

			if numel( sigs ) == 0
				continue;
			end
			if ~all( arrayfun( @( s ) isequal( sigs(1).time, s.time ), sigs(2:end) ) )
				error( 'invalid value: sigs' );
			end

			if ~all( cellfun( @( m ) isequal( movs{1}, m ), movs(2:end) ) )
				error( 'invalid value: movs' );
			end

			movs = movs{1};

				% accumulate data
			count(1) = count(1)+sum( [movs.fpos] );
			count(2) = count(2)+sum( ~[movs.fpos] );

		end

			% update data
		data{di}.fpos = fpos;
		data{di}.vals = count;
		data{di}.form = ref.form( data{di}.fcol, data{di}.fc, data{di}.fpos, formargs );

		logger.progress( di, numel( data ) );
	end

end % function

	% local functions
function [axd, props] = axes_()
	axd(1).label = {'Token count'};
	axd(1).ticks = [];
	axd(1).ticklabels = {};
	axd(1).limits = [0, Inf];
	axd(1).flimits = true;

	props = {};
end

