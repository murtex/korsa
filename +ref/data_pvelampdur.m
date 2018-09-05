function [data, axd, props] = data_pvelampdur( ftr, dimfun, data, formargs, sub )
% peak velocity-amplitude-duration relation
%
% [data, axd, props] = DATA_PVELAMPDUR( ftr, dimfun, data, formargs, sub )
%
% INPUT
% ftr : file transfer structure (scalar struct)
% dimfun : panel dimension functions [horiz, vert] (cell function handle)
% data : raw data (cell struct)
% formargs : data form arguments (cell)
% sub : subsampling (numeric scalar)
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

	if nargin < 5 || ~isnumeric( sub ) || ~isscalar( sub )
		error( 'invalid argument: sub' );
	end

	logger = hLogger.instance();

		% set axes
	[axd, props] = axes_();

		% proceed data
	logger.progress( 'determine peak velocity-amplitude-duration relation...' );

	for di = 1:numel( data )
		if isempty( data{di} )
			logger.progress( di, numel( data ) );
			continue;
		end

			% proceed bundles
		naxes = numel( io.decfcol( data{di}.fcol, data{di}.fc, 'axes' ) );
		nbundles = numel( data{di}.sigs )/naxes;

		fpos = false( [1, 0] );
		pvel = NaN( [1, 0] );
		amp = NaN( [1, 0] );
		dur = NaN( [1, 0] );

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
			fpos = [fpos, [movs.fpos]];
			pvel = [pvel, ref.kin_pvel( sigs, movs, true, sub )];
			amp = [amp, ref.kin_amp( sigs, movs, true, sub )];
			dur = [dur, ref.kin_dur( sigs(1), movs, true )];

		end

			% store derived data
		data{di}.fpos = fpos;
		data{di}.vals = [dur; pvel./amp];
		data{di}.form = ref.form( data{di}.fcol, data{di}.fc, data{di}.fpos, formargs );

		logger.progress( di, numel( data ) );
	end

end % function

	% local functions
function [axd, props] = axes_()
	% TODO: hard-coded units!
	axd(1).label = {'Movement length in mm'};
	[axd(1).ticks, axd(1).ticklabels] = logticks_( [-4:0.25:4] ); % TODO: automate this!
	axd(1).limits = [0, Inf];
	axd(1).flimits = false;

	axd(2).label = {'Peak velocity in mm/s'};
	[axd(2).ticks, axd(2).ticklabels] = logticks_( [-4:0.25:4] ); % TODO: automate this!
	axd(2).limits = [0, Inf];
	axd(2).flimits = false;

	props = {'XScale', 'log', 'YScale', 'log'};
end

function [ticks, labels] = logticks_( exp )
	ticks = 10.^exp;
	labels = arrayfun( @( e ) sprintf( '10^{%.2f}', e ), exp, 'UniformOutput', false );
end % function

