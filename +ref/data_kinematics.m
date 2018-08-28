function [data, axd, labpos, props] = data_kinematics( ftr, dimfun, data, formargs, sub, svar )
% kinematic data
%
% [data, axd, labpos, props] = DATA_KINEMATICS_( ftr, dimfun, data, formargs, sub, svar )
%
% INPUT
% ftr : file transfer structure (scalar struct)
% dimfun : panel dimension functions [horiz, vert] (cell function handle)
% data : raw data (cell struct)
% formargs : data form arguments (cell)
% sub : subsampling (numeric scalar)
% svar : kinematic variable [dur, len, pvel, rttp] (char)
%
% OUTPUT
% data : derived data (cell struct)
% axd : axes description (struct)
% labpos : panel label position (char)
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
	[axd, labpos, props] = axes_( svar );

		% proceed raw data
	logger.progress( 'compute kinematics data (%s)...', svar );

	for di = 1:numel( data )
		if isempty( data{di} )
			logger.progress( di, numel( data ) );
			continue;
		end

			% check data consistency
		naxes = numel( io.decfcol( data{di}.fcol, data{di}.fc, 'axes' ) );

		if naxes ~= 3
			error( 'invalid value: naxes' );
		end

			% proceed tokens
		fpos = false( [1, 0] );
		var = NaN( [1, 0] );

		ntokens = numel( data{di}.sigs )/naxes;

		for ti = [1:ntokens]
			sigs = data{di}.sigs(naxes*(ti-1)+[1:naxes]);
			movs = data{di}.movs(naxes*(ti-1)+[1:naxes]);

			if ~all( diff( cellfun( @numel, movs ) ) == 0 )
				error( 'invalid value: movs' );
			end

				% verify movements
			if numel( unique( cellfun( @numel, movs ) ) ) ~= 1
				error( 'invalid value: movs' );
			end
			movs = movs{1};

			cdur = ref.movs_dur( sigs(1), movs, true ); % TODO: exclude too long movements
			movs(cdur > 0.5) = [];
			cdur(cdur > 0.5) = [];

			if isempty( movs )
				continue;
			end

				% accumulate data
			fpos = [fpos, [movs.fpos]];

			switch svar
				case 'dur'
					var = [var, cdur];
				case 'len'
					var = [var, ref.movs_len( sigs, movs, true, sub )];
				case 'pvel'
					var = [var, ref.movs_pvel( sigs, movs, true, sub )];
				case 'rttp'
					var = [var, ref.movs_rttp( sigs, movs, true, sub )];

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
function [axd, labpos, props] = axes_( svar )
	% TODO: hard-coded units!
	switch svar
		case 'dur'
			axd(1).label = {'Movement duration in s'};
			axd(1).ticks = [];
			axd(1).ticklabels = {};
			axd(1).limits = [0, Inf];
			axd(1).flimits = true;

			labpos = 'tr';
			props = {};

		case 'len'
			axd(1).label = {'Movement length in mm'};
			axd(1).ticks = [];
			axd(1).ticklabels = {};
			axd(1).limits = [0, Inf];
			axd(1).flimits = true;

			labpos = 'tr';
			props = {};

		case 'pvel'
			axd(1).label = {'Peak velocity in mm/s'};
			axd(1).ticks = [];
			axd(1).ticklabels = {};
			axd(1).limits = [0, Inf];
			axd(1).flimits = true;

			labpos = 'tr';
			props = {};

		case 'rttp'
			axd(1).label = {'Relative time to peak'};
			axd(1).ticks = [];
			axd(1).ticklabels = {};
			axd(1).limits = [0, 1];
			axd(1).flimits = true;

			labpos = 'tr';
			props = {};

		otherwise
			error( 'invalif value: svar' );
	end
end

