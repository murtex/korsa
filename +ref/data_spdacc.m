function [data, axd, props] = data_spdacc( ftr, dimfun, data, formargs, sub, method )
% speed-accuracy relation
%
% [data, axd, props] = DATA_SPDACC( ftr, dimfun, data, formargs, sub, method )
%
% INPUT
% ftr : file transfer structure (scalar struct)
% dimfun : panel dimension functions [horiz, vert] (cell function handle)
% data : raw data (cell struct)
% formargs : data form arguments (cell)
% sub : subsampling (numeric scalar)
% method : index of difficulty method [fitts, welford, shannon] (char)
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

	if nargin < 6 || ~ischar( method )
		error( 'invalid argument: method' );
	end

	logger = hLogger.instance();

		% set axes
	[axd, props] = axes_();

		% proceed data
	logger.progress( 'determine speed-accuracy relation...' );

	for di = 1:numel( data )
		if isempty( data{di} )
			logger.progress( di, numel( data ) );
			continue;
		end

			% proceed bundles
		naxes = numel( io.decfcol( data{di}.fcol, data{di}.fc, 'axes' ) );
		nbundles = numel( data{di}.sigs )/naxes;

		if naxes ~= 3
			error( 'invalid value: naxes' );
		end

		dur = NaN( [1, 0] ); % data
		amp = NaN( [1, 0] );
		ep = NaN( [naxes, 0] );

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

				% accumulate data
			cdur = ref.kin_dur( sigs(1), movs, true );
			camp = ref.kin_amp( sigs, movs, true, sub );
			cep = [sigs(1).data{1, [movs.qoffset]}; sigs(2).data{1, [movs.qoffset]}; sigs(3).data{1, [movs.qoffset]}];

			dur = [dur, cdur];
			amp = [amp, camp];
			ep = [ep, cep];

				% accumulate style
			cfpos = [movs.fpos];
			cform = ref.form( fcol, data{di}.fc, cfpos, formargs );

			fpos = [fpos, cfpos];
			form = [form, cform];

		end

			% determine index of difficulty
		wid = NaN( size( amp ) );
		wid(fpos) = effwidth_( ep(:, fpos) );
		wid(~fpos) = effwidth_( ep(:, ~fpos) );

		switch method
			case 'fitts'
				id = log2( 2*amp./wid );
			case 'welford'
				id = log2( amp./wid+0.5 );
			case 'shannon'
				id = log2( amp./wid+1 );
			otherwise
				error( 'invalid value: method' );
		end

			% update data
		data{di}.fpos = fpos;
		data{di}.vals = [id; dur];
		data{di}.form = form;

		logger.progress( di, numel( data ) );
	end

end % function

	% local functions
function [axd, props] = axes_()
	% TODO: hard-coded units!
	axd(1).label = {'Index of difficulty in bit'};
	axd(1).ticks = [];
	axd(1).ticklabels = {};
	axd(1).limits = [0, Inf];
	axd(1).flimits = true;

	axd(2).label = {'Duration in s'};
	axd(2).ticks = [];
	axd(2).ticklabels = {};
	axd(2).limits = [0, Inf];
	axd(2).flimits = true;

	props = {};
end

function w = effwidth_( ep )
	w = sqrt( 2*pi*exp( 1 ) )*sqrt( sum( sum( (ep-mean( ep, 2 )).^2, 1 ), 2 )/(size( ep, 2 )-1) );
end % function

