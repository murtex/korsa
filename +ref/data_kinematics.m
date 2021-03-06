function [data, axd, props] = data_kinematics( ftr, dimfun, data, formargs, sub, svar )
% kinematic variables
%
% [data, axd, props] = DATA_KINEMATICS_( ftr, dimfun, data, formargs, sub, svar )
%
% INPUT
% ftr : file transfer structure (scalar struct)
% dimfun : panel dimension functions [horiz, vert] (cell function handle)
% data : raw data (cell struct)
% formargs : data form arguments (cell)
% sub : subsampling (numeric scalar)
% svar : kinematic variable [dur, amp, pvel, rttp] (char)
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

	if nargin < 6 || ~ischar( svar )
		error( 'invalid argument: svar' );
	end

	logger = hLogger.instance();

		% set axes
	[axd, props] = axes_( svar );

		% proceed data
	logger.progress( 'determine kinematic variable (%s)...', svar );

	for di = 1:numel( data )
		if isempty( data{di} )
			logger.progress( di, numel( data ) );
			continue;
		end

			% proceed bundles
		naxes = numel( io.decfcol( data{di}.fcol, data{di}.fc, 'axes' ) );
		nbundles = numel( data{di}.sigs )/naxes;

		fpos = false( [1, 0] );
		var = NaN( [1, 0] );

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

			switch svar
				case 'dur'
					var = [var, ref.kin_dur( sigs(1), movs, true )];
				case 'amp'
					var = [var, ref.kin_amp( sigs, movs, true, sub )];
				case 'pvel'
					var = [var, ref.kin_pvel( sigs, movs, true, sub )];
				case 'rttp'
					var = [var, ref.kin_rttp( sigs, movs, true, sub )];

				otherwise
					error( 'invalid value: svar' );
			end

		end

			% store derived data
		data{di}.fpos = fpos;
		data{di}.vals = var;
		data{di}.form = ref.form( data{di}.fcol, data{di}.fc, data{di}.fpos, formargs );

		logger.progress( di, numel( data ) );
	end

end % function

	% local functions
function [axd, props] = axes_( svar )
	% TODO: hard-coded units!
	switch svar
		case 'dur'
			axd(1).label = {'Movement duration in s'};
			axd(1).ticks = [];
			axd(1).ticklabels = {};
			axd(1).limits = [0, Inf];
			axd(1).flimits = true;

			props = {};

		case 'amp'
			axd(1).label = {'Movement amplitude in mm'};
			axd(1).ticks = [];
			axd(1).ticklabels = {};
			axd(1).limits = [0, Inf];
			axd(1).flimits = true;

			props = {};

		case 'pvel'
			axd(1).label = {'Peak velocity in mm/s'};
			axd(1).ticks = [];
			axd(1).ticklabels = {};
			axd(1).limits = [0, Inf];
			axd(1).flimits = true;

			props = {};

		case 'rttp'
			axd(1).label = {'Relative time to peak'};
			axd(1).ticks = [];
			axd(1).ticklabels = {};
			axd(1).limits = [0, 1];
			axd(1).flimits = true;

			props = {};

		otherwise
			error( 'invalif value: svar' );
	end
end

