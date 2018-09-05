function [data, axd, props] = data_pvelampdur_slope( ftr, dimfun, data, formargs )
% peak velocity-amplitude-duration slope
%
% [data, axd, props] = DATA_PVELAMPDUR_SLOPE( ftr, dimfun, data, formargs )
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
	logger.progress( 'determine peak velocity-amplitude-duration slope...' );

	for di = 1:numel( data )
		if isempty( data{di} )
			logger.progress( di, numel( data ) );
			continue;
		end

			% update data
		data{di}.vals = data{di}.vals(2, :).*data{di}.vals(1, :)/pi;

		logger.progress( di, numel( data ) );
	end

end % function

	% local functions
function [axd, props] = axes_()
	% TODO: hard-coded units!
	axd(1).label = {'Proportionality c in \pi'};
	axd(1).ticks = [];
	axd(1).ticklabels = {};
	axd(1).limits = [-Inf, Inf];
	axd(1).flimits = false;

	props = {};
end

