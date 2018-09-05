function [data, axd, props] = data_pvelampdur_corr( ftr, dimfun, data, formargs, param )
% peak velocity-amplitude-duration correlation
%
% [data, axd, props] = DATA_PVELAMPDUR_CORR( ftr, dimfun, data, formargs, param )
%
% INPUT
% ftr : file transfer structure (scalar struct)
% dimfun : panel dimension functions [horiz, vert] (cell function handle)
% data : raw data (cell struct)
% formargs : data form arguments (cell)
% param : correlation parameter [slope, pearson] (char)
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
	logger.progress( 'determine peak velocity-amplitude-duration correlation...' );

	for di = 1:numel( data )
		if isempty( data{di} )
			logger.progress( di, numel( data ) );
			continue;
		end

			% determine correlation parameter
		fpos = [true, false];
		corr = NaN( [1, 2] );

		switch param
			case 'slope'
				corr(1) = util.corr( 1./data{di}.vals(1, data{di}.fpos), data{di}.vals(2, data{di}.fpos), 1 )/pi;
				corr(2) = util.corr( 1./data{di}.vals(1, ~data{di}.fpos), data{di}.vals(2, ~data{di}.fpos), 1 )/pi;
			case 'pearson'
				corr(1) = util.corr( 1./data{di}.vals(1, data{di}.fpos), data{di}.vals(2, data{di}.fpos), 2 );
				corr(2) = util.corr( 1./data{di}.vals(1, ~data{di}.fpos), data{di}.vals(2, ~data{di}.fpos), 2 );
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
		case 'slope'
			axd(1).label = {'Proportionality c in \pi'};
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

