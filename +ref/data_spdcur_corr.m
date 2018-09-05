function [data, axd, props] = data_spdcur_corr( ftr, dimfun, data, formargs, param )
% speed-curvature correlation
%
% [data, axd, props] = DATA_SPDCUR_CORR( ftr, dimfun, data, formargs, param )
%
% INPUT
% ftr : file transfer structure (scalar struct)
% dimfun : panel dimension functions [horiz, vert] (cell function handle)
% data : raw data (cell struct)
% formargs : data form arguments (cell)
% param : correlation parameter [intercept, slope, pearson] (char)
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

	if nargin < 5 || ~ischar( param )
		error( 'invalid argument: param' );
	end

	logger = hLogger.instance();

		% set axes
	[axd, props] = axes_( param );

		% proceed data
	logger.progress( 'determine speed-curvature correlation...' );

	for di = 1:numel( data )
		if isempty( data{di} )
			logger.progress( di, numel( data ) );
			continue;
		end

			% determine log-log correlation parameter
		fpos = [true, false];
		corr = NaN( [1, 2] );

		switch param
			case 'intercept'
				corr(1) = exp( util.corr( log( data{di}.vals(1, data{di}.fpos) ), log( data{di}.vals(2, data{di}.fpos) ), 0 ) );
				corr(2) = exp( util.corr( log( data{di}.vals(1, ~data{di}.fpos) ), log( data{di}.vals(2, ~data{di}.fpos) ), 0 ) );
			case 'slope'
				corr(1) = -util.corr( log( data{di}.vals(1, data{di}.fpos) ), log( data{di}.vals(2, data{di}.fpos) ), 1 );
				corr(2) = -util.corr( log( data{di}.vals(1, ~data{di}.fpos) ), log( data{di}.vals(2, ~data{di}.fpos) ), 1 );
			case 'pearson'
				corr(1) = util.corr( log( data{di}.vals(1, data{di}.fpos) ), log( data{di}.vals(2, data{di}.fpos) ), 2 );
				corr(2) = util.corr( log( data{di}.vals(1, ~data{di}.fpos) ), log( data{di}.vals(2, ~data{di}.fpos) ), 2 );
			otherwise
				error( 'invalid value: param' );
		end

			% update data
		data{di}.fpos = fpos;
		data{di}.vals = corr;
		data{di}.form = ref.form( data{di}.fcol, data{di}.fc, data{di}.fpos, formargs );

		logger.progress( di, numel( data ) );
	end

end % function

	% local functions
function [axd, props] = axes_( param )
	% TODO: hard-coded units!
	switch param
		case 'intercept'
			axd(1).label = {'Velocity gain factor k'};
			axd(1).ticks = [];
			axd(1).ticklabels = {};
			axd(1).limits = [-Inf, Inf];
			axd(1).flimits = false;

			props = {};

		case 'slope'
			axd(1).label = {'Power law exponent \beta'};
			axd(1).ticks = [];
			axd(1).ticklabels = {};
			axd(1).limits = [-Inf, Inf];
			axd(1).flimits = false;

			props = {};

		case 'pearson'
			axd(1).label = {'Correlation strength'};
			axd(1).ticks = [];
			axd(1).ticklabels = {};
			axd(1).limits = [0, 1];
			axd(1).flimits = false;

			props = {};

		otherwise
			error( 'invalid value: param' );
	end
end

