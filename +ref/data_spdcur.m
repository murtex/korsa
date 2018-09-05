function [data, axd, props] = data_spdcur( ftr, dimfun, data, formargs, kinsub, cursub, fsubarc )
% speed-curvature relation
%
% [data, axd, props] = DATA_SPDCUR( ftr, dimfun, data, formargs, kinsub, cursub, fsubarc )
%
% INPUT
% ftr : file transfer structure (scalar struct)
% dimfun : panel dimension functions [horiz, vert] (cell function handle)
% data : raw data (cell struct)
% formargs : data form arguments (cell)
% kinsub : subsampling (numeric scalar)
% cursub : subsampling (numeric scalar)
% fsubarc : arclength-base subsampling (logical scalar)
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

	if nargin < 5 || ~isnumeric( kinsub ) || ~isscalar( kinsub )
		error( 'invalid argument: kinsub' );
	end

	if nargin < 6 || ~isnumeric( cursub ) || ~isscalar( cursub )
		error( 'invalid argument: cursub' );
	end

	if nargin < 7 || ~islogical( fsubarc ) || ~isscalar( fsubarc )
		error( 'invalid argument: fsubarc' );
	end

	logger = hLogger.instance();

		% set axes
	[axd, props] = axes_( data );

		% proceed data
	logger.progress( 'determine speed-curvature relation...' );

	for di = 1:numel( data )
		if isempty( data{di} )
			logger.progress( di, numel( data ) );
			continue;
		end

			% proceed bundles
		naxes = numel( io.decfcol( data{di}.fcol, data{di}.fc, 'axes' ) );
		nbundles = numel( data{di}.sigs )/naxes;

		spd = NaN( [1, 0] ); % data
		cur = NaN( [1, 0] );

		fpos = false( [1, 0] ); % style
		form = ref.form();

		for bi = [1:nbundles]

				% verify bundle
			fcol = data{di}.fcol(naxes*(bi-1)+[1:naxes]);
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

				% subsample bundle
			ti = NaN( [1, 0] );

			for mi = [1:numel( movs )]
				if fsubarc % arclength-based subsampling
					tj = linspace( movs(mi).onset, movs(mi).offset, kinsub );
					amp = cumtrapz( tj, ref.kin_vel( sigs, movs(mi), false, kinsub ) );
					tk = arrayfun( @( camp ) find( abs( amp-camp ) == min( abs( amp-camp ) ), 1, 'first' ), linspace( amp(1), amp(end), cursub ) );
					ti = [ti, tj(tk)];

				else % time-based subsampling
					ti = [ti, linspace( movs(mi).onset, movs(mi).offset, cursub )];

				end
			end

			x = sigs(1).data{1, ti};
			y = sigs(2).data{1, ti};
			z = sigs(3).data{1, ti};

			xd = sigs(1).data{2, ti};
			yd = sigs(2).data{2, ti};
			zd = sigs(3).data{2, ti};

			xdd = sigs(1).data{3, ti};
			ydd = sigs(2).data{3, ti};
			zdd = sigs(3).data{3, ti};

				% accumulate data
			cspd = sqrt( xd.^2+yd.^2+zd.^2 );
			ccur = sqrt( (yd.*zdd-ydd.*zd).^2+(zd.*xdd-zdd.*xd).^2+(xd.*ydd-xdd.*yd).^2 )./cspd.^3;

			spd = [spd, cspd];
			cur = [cur, ccur];

				% accumulate style
			cfpos = logical( kron( [movs.fpos], ones( [1, cursub] ) ) );
			cform = ref.form( fcol, data{di}.fc, cfpos, formargs );

			fpos = [fpos, cfpos];
			form = [form, cform];

		end

			% update data
		data{di}.fpos = fpos;
		data{di}.vals = [cur; spd];
		data{di}.form = form;

		logger.progress( di, numel( data ) );
	end

end % function

	% local functions
function [axd, props] = axes_( data )
	style = hStyle.instance();

	axd(1).label = {'Curvature'};
	[axd(1).ticks, axd(1).ticklabels] = logticks_( [-8:2:8] ); % TODO: automate this!
	axd(1).limits = [0, Inf];
	axd(1).flimits = false;

	axd(2).label = {'Speed'};
	[axd(2).ticks, axd(2).ticklabels] = logticks_( [-4:4] ); % TODO: automate this!
	axd(2).limits = [0, Inf];
	axd(2).flimits = false;
	
	props = {'XScale', 'log', 'YScale', 'log'};

	if style.funits
		mdata = [data{cellfun( @( d ) ~isempty( d ), data )}];
		if ~isempty( mdata ) && ~isempty( mdata(1).sigs )
			axd(1).label{1} = sprintf( '%s in 1/%s', axd(1).label{1}, mdata(1).sigs(1).getlabel( 1, 'unit' ) );
			axd(2).label{1} = sprintf( '%s in %s', axd(2).label{1}, mdata(1).sigs(1).getlabel( 2, 'unit' ) );
		end
	end
end

function [ticks, labels] = logticks_( exp )
	ticks = 10.^exp;
	labels = arrayfun( @( e ) sprintf( '10^{%d}', e ), exp, 'UniformOutput', false );
end % function

