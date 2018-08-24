function fc = convert_( srcdir, dstdir, basename, fdry, valfilt )
% convert ag501 data
%
% convert_( srcdir, dstdir, basename, fdry, valfilt )
%
% INPUT
% srcdir : input directory (char)
% dstdir : output directory (char)
% basename : output base filename (char)
% fdry : dry run flag (scalar logical)
% valfilt : file composition value filter (cell cell string)
%
% OUTPUT
% fc : file composition (scalar struct)

		% safeguard
	if nargin < 1 || ~ischar( srcdir )
		error( 'invalid argument: srcdir' );
	end

	if nargin < 2 || ~ischar( dstdir )
		error( 'invalid argument: dstdir' );
	end

	if nargin < 3 || ~ischar( basename )
		error( 'invalid argument: basename' );
	end

	if nargin < 4 || ~isscalar( fdry ) || ~islogical( fdry )
		error( 'invalid argument: fdry' );
	end

	if nargin < 5 || ~iscell( valfilt ) || ~all( cellfun( @( vf ) iscellstr( vf ), valfilt ) )
		error( 'invalid argument: valfilt' );
	end

	logger = hLogger.instance();
	logger.tab( 'convert ag501 data...' );
	logger.module = util.module();

		% -------------------------------------------------------------------
		% initialize file composition

	fc.subjects = {};
	fc.targets = {};
	fc.rates = {};
	fc.trials = {};
	fc.sensors = {};
	fc.axes = {};

		% proceed sessions
	sessions = util.listdir( srcdir );

	% sessions(~cellfun( @( s ) contains( s, '-st' ), sessions )) = []; % DEBUG

	for si = 1:numel( sessions )
		logger.tab( 'convert session (''%s'')...', fullfile( srcdir, sessions{si}, '/' ) );

			% ---------------------------------------------------------------
			% gather prompted trials

		trials = struct( 'target', {}, 'rate', {}, 'trial', {}, 'valid', {}, 'sweepid', {}, 'time', {} );

		pfiles = cellfun( @( pd ) fullfile( srcdir, sessions{si}, 'prompters/', pd, 'prompter.log' ), util.listdir( fullfile( srcdir, sessions{si}, 'prompters/' ) ), 'UniformOutput', false );

		for pfi = 1:numel( pfiles )
			logger.log( 'gather prompted trials (''%s'')...', pfiles{pfi} );

			fid = fopen( pfiles{pfi} );
			while ~feof( fid )
				pl = textscan( fgetl( fid ), '%n %*n %s %*n %s' );
				if any( cellfun( @isempty, pl ) )
					continue;
				end

				ti = numel( trials )+1; % add trial

				trials(ti).sweepid = pl{1};
				trials(ti).time = datenum( pl{2}, 'HH:MM:SS' );
				[trials(ti).target, trials(ti).rate, trials(ti).trial, trials(ti).valid] = decode_( pl{3} );
			end
			fclose( fid );
		end

		trials = unique_( trials ); % adjust duplicates

		logger.tablog( '%d prompted trials found', numel( trials ) ); % logging
		log_( @logger.tablog, trials );

			% gather sweeps
		sweeps = struct( 'sweepdir', {}, 'sweepid', {}, 'audio', {}, 'cutaudio', {}, 'time', {} );

		swdirs = cellfun( @( swd ) sweepdir_( srcdir, sessions{si}, swd ), util.listdir( sweepdir_( srcdir, sessions{si}, '' ) ), 'UniformOutput', false );

		for swi = 1:numel( swdirs )
			logger.log( 'gather sweeps (''%s'')...', swdirs{swi} );

			swfiles = util.listfile( fullfile( swdirs{swi}, 'rawpos/' ), '*.pos' );
			for swj = 1:numel( swfiles )
				swk = numel( sweeps )+1; % add sweep

				sweeps(swk).sweepdir = swdirs{swi};
				sweeps(swk).sweepid = str2num( swfiles{swj}(1:4) );
				sweeps(swk).audio = exist( fullfile( swdirs{swi}, 'wavall/', sprintf( '%04d.all.wav', sweeps(swk).sweepid ) ), 'file' ) == 2;
				sweeps(swk).cutaudio = exist( fullfile( swdirs{swi}, 'wav/', sprintf( '%04d.wav', sweeps(swk).sweepid ) ), 'file' ) == 2;
				sweeps(swk).time = sweeptime_( fullfile( swdirs{swi}, 'rawpos/', swfiles{swj} ) );
			end
		end

		logger.tablog( '%d sweep files found', numel( sweeps ) ); % logging
		logger.tablog( '%d audio files found', sum( [sweeps.audio] ) );
		logger.tablog( '%d cut audio files found', sum( [sweeps.cutaudio] ) );

			% verify session description
		domfile = fullfile( srcdir, sessions{si}, 'session.xml' );
		logger.log( 'verify session description (''%s'')...', domfile );
		dom = xmlread( domfile );

		tlist = dom.getElementsByTagName( 'target' ); % complete targets
		lastswdir = '';
		for ti = 1:tlist.getLength()
			tnode = tlist.item( ti-1 ); % add sweepdir
			swlist = tnode.getElementsByTagName( 'sweepdir' );
			if swlist.getLength() == 0
				swnode = tnode.appendChild( dom.createElement( 'sweepdir' ) );
				swnode.setAttribute( 'name', lastswdir );
			else
				swnode = swlist.item( swlist.getLength()-1 );
				lastswdir = char( swnode.getAttribute( 'name' ) );
			end

			if ~tnode.hasAttribute( 'audio' ) % add audio
				tnode.setAttribute( 'audio', 'true' );
			end
		end

		sslist = dom.getElementsByTagName( 'sensors' ); % complete sensors
		for ssi = 1:sslist.getLength()
			ssnode = sslist.item( ssi-1 );
			if ~ssnode.hasAttribute( 'sweepid' )
				ssnode.setAttribute( 'sweepid', '1' );
			end
		end

		subject = char( dom.getElementsByTagName( 'subject' ).item( 0 ).getAttribute( 'name' ) ); % read info
		language = char( dom.getElementsByTagName( 'subject' ).item( 0 ).getAttribute( 'language' ) );
		sex = char( dom.getElementsByTagName( 'subject' ).item( 0 ).getAttribute( 'sex' ) );

		logger.tablog( 'subject: ''%s''', subject );
		logger.tablog( 'language: ''%s''', language );
		logger.tablog( 'sex: ''%s''', sex );

			% gather sensor layouts
		layouts = struct( 'labels', {}, 'channels', {}, 'sweep', {} );

		logger.tab( 'gather sensor layouts...' );

		[~, perm] = sort( [sweeps.time] );
		sweeps = sweeps(perm);

		sslist = dom.getElementsByTagName( 'sensors' ); % gather layout changes
		for ssi = 1:sslist.getLength()
			ssnode = sslist.item( ssi-1 );

			swdir = sweepdir_( srcdir, sessions{si}, char( ssnode.getParentNode().getAttribute( 'name' ) ) );
			swid = str2num( char( ssnode.getAttribute( 'sweepid' ) ) );
			swi = find( strcmp( swdir, {sweeps.sweepdir} ) & [sweeps.sweepid] == swid );

			li = numel( layouts )+1; % add layout change
			layouts(li).labels = {};
			layouts(li).channels = [];
			layouts(li).sweep = swi;

			slist = ssnode.getElementsByTagName( 'sensor' );
			for ssj = 1:slist.getLength()
				snode = slist.item( ssj-1 );
				schan = str2num( char( snode.getAttribute( 'channel' ) ) );
				sname = char( snode.getAttribute( 'name' ) );

				layouts(li).labels{end+1} = sname;
				layouts(li).channels(end+1) = schan;
			end
		end

		[~, perm] = sort( [sweeps([layouts.sweep]).time] ); % expand layout changes
		layouts = layouts(perm);

		for li = 2:numel( layouts )
			dlabels = layouts(li).labels;
			dchans = layouts(li).channels;

			layouts(li).labels = layouts(li-1).labels;
			layouts(li).channels = layouts(li-1).channels;

			for di = 1:numel( dlabels )
				[~, ichan] = ismember( dchans(di), layouts(li).channels );
				if isempty( dlabels{di} ) && ichan > 0 % dropped sensor
					layouts(li).labels(ichan) = [];
					layouts(li).channels(ichan) = [];
				elseif ~isempty( dlabels{di} ) && ichan > 0 % rededicated sensor
					layouts(li).labels{ichan} = dlabels{di};
				elseif ~isempty( dlabels{di} ) && ichan == 0 % new sensor
					layouts(li).labels{end+1} = dlabels{di};
					layouts(li).channels(end+1) = dchans(di);
				end
			end
		end

		[sweeps.layout] = deal( NaN ); % link layouts
		for li = 1:numel( layouts )
			[sweeps(layouts(li).sweep:end).layout] = deal( li );
		end

		logger.log( '%d layouts found', numel( layouts ) ); % logging
		logger.log( 'used channels: %s', util.any2str( unique( cat( 2, layouts.channels ) ) ) );
		logger.log( 'used labels: %s', util.any2str( unique( cat( 2, layouts.labels ) ) ) );

		if any( isnan( [sweeps.layout] ) )
			arrayfun( @( sw ) logger.log( 'Warning: unspecified sweep %s', util.any2str( sw ) ), sweeps(isnan( [sweeps.layout] )) );
			warn_( subject, valfilt, '%d unspecified sweeps found!', sum( isnan( [sweeps.layout] ) ) );
		end

		logger.untab();

			% map sweeps to trials
		logger.tab( 'map sweeps to trials...' );

		[~, perm] = sort( [trials.time] );
		trials = trials(perm);

		[sweeps.targets] = deal( {} ); % extend structures
		[sweeps.trial] = deal( NaN );
		[sweeps.omit] = deal( false );

		[trials.sweep] = deal( NaN );
		[trials.synth] = deal( false );

		tlist = dom.getElementsByTagName( 'target' ); % update sweeps
		for ti = 1:tlist.getLength()
			tnode = tlist.item( ti-1 );
			tname = char( tnode.getAttribute( 'name' ) );

			swlist = tnode.getElementsByTagName( 'sweepdir' );
			for swi = 1:swlist.getLength()
				swnode = swlist.item( swi-1 );
				swdir = sweepdir_( srcdir, sessions{si}, char( swnode.getAttribute( 'name' ) ) );

				swj = find( strcmp( swdir, {sweeps.sweepdir} ) ); % link targets and adjust audio
				for swk = swj
					sweeps(swk).targets = union( sweeps(swk).targets, {tname} );
					if strcmp( char( tnode.getAttribute( 'audio' ) ), 'false' )
						sweeps(swk).audio = false;
						sweeps(swk).cutaudio = false;
					end
				end

				olist = swnode.getElementsByTagName( 'omit' ); % omit sweepid
				for oi = 1:olist.getLength()
					onode = olist.item( oi-1 );
					swid = str2num( char( onode.getAttribute( 'sweepid' ) ) );

					swj = find( strcmp( swdir, {sweeps.sweepdir} ) & [sweeps.sweepid] == swid );
					for swk = swj
						sweeps(swk).omit = true;
					end
				end
			end
		end

		for swi = 1:numel( sweeps ) % map sweeps to prompted trials
			if sweeps(swi).omit
				continue;
			end

			ti = find( [trials.sweepid] == sweeps(swi).sweepid & ismember( {trials.target}, sweeps(swi).targets ) & isnan( [trials.sweep] ) );

			if numel( ti ) > 0
				trials(ti(1)).sweep = swi;
				sweeps(swi).trial = ti(1);
			end
		end

		swi = find( isnan( [sweeps.trial] ) & ~[sweeps.omit] ); % synthesize unprompted trials
		for swj = swi
			if numel( sweeps(swj).targets ) ~= 1
				continue;
			end

			ti = numel( trials )+1; % add trial
			trials(ti).sweepid = sweeps(swj).sweepid;
			trials(ti).time = 0;
			trials(ti).target = sweeps(swj).targets{1};
			trials(ti).rate = 'bpm0';
			trials(ti).trial = 'trial1';
			trials(ti).valid = true;
			trials(ti).sweep = swj;
			trials(ti).synth = true;

			sweeps(swj).trial = ti; % link sweep
		end

		trials = unique_( trials ); % adjust duplicates

		iptrials = find( ~[trials.synth] & ~isnan( [trials.sweep] ) );
		iuptrials = find( [trials.synth] & ~isnan( [trials.sweep] ) );

		if any( [sweeps.omit] ) % logging
			logger.log( '%d sweeps omitted', sum( [sweeps.omit] ) );
		end

		logger.log( '%d prompted trials mapped', numel( iptrials ) );
		log_( @logger.tablog, trials(iptrials) );
		logger.log( '%d synthetic trials mapped', numel( iuptrials ) );
		log_( @logger.tablog, trials(iuptrials) );

		fdub = ismember( {trials(iuptrials).target}, {trials(iptrials).target} );
		if any( fdub )
			arrayfun( @( tr ) loger.tablog( 'Warning: dubious synthetic trial %s', util.any2str( tr ) ), trials(iuptrials(fdub)) );
			warn_( subject, valfilt, 'dubious synthetic trials found!' );
		end

		if any( isnan( [trials.sweep] ) )
			arrayfun( @( tr ) logger.log( 'Warning: unmapped trial %s', util.any2str( tr ) ), trials(isnan( [trials.sweep] )) );
			warn_( subject, valfilt, '%d unmapped trials found!', sum( isnan( [trials.sweep] ) ) );
		end

		if any( isnan( [sweeps.trial] ) & ~[sweeps.omit] )
			arrayfun( @( sw ) logger.log( 'Warning: unmapped sweep %s', util.any2str( sw ) ), sweeps(isnan( [sweeps.trial] ) & ~[sweeps.omit]) );
			warn_( subject, valfilt, '%d unmapped sweeps found!', sum( isnan( [sweeps.trial] ) & ~[sweeps.omit] ) );
		end

		logger.untab();

		if ~isequal( [sweeps.audio], [sweeps.cutaudio] )
			arrayfun( @( sw ) logger.tablog( 'Warning: uncut audio file %s', util.any2str( sw ) ), sweeps([sweeps.audio] & ~[sweeps.cutaudio]) );
			warn_( subject, valfilt, '%d uncut audio files found!', sum( [sweeps.audio] )-sum( [sweeps.cutaudio] ) );
		end

			% ---------------------------------------------------------------
			% filter trials

		trials(~[trials.valid]) = [];
		trials(isnan( [trials.sweep] )) = [];

		logger.log( 'filter trials...' );

		if ~isempty( valfilt{1} ) && ~ismember( subject, valfilt{1} ) % subjects
			trials(:) = [];
		end
		if ~isempty( valfilt{2} ) % targets
			trials(~ismember( {trials.target}, valfilt{2} )) = [];
		end
		if ~isempty( valfilt{3} ) % rates
			trials(~ismember( {trials.rate}, valfilt{3} )) = [];
		end
		if ~isempty( valfilt{4} ) % trials
			trials(~ismember( {trials.trial}, valfilt{4} )) = [];
		end

			% ---------------------------------------------------------------
			% convert trials

		logger.tab( 'convert trials...' );

		for ti = 1:numel( trials ) % convert
			trial = trials(ti);
			sweep = sweeps(trial.sweep);
			layout = layouts(sweep.layout);

			fccur = convert__( dstdir, basename, subject, trial, sweep, layout, fdry, valfilt );
			fc = io.joinfcomp( fc, fccur );
		end

		logger.untab();

			% continue next session
		logger.untab();

	end

		% done
	logger.module = '';
	logger.untab();

end % function

	% local functions
function [target, rate, trial, valid] = decode_( pl )
	pl = pl{1}(2:end-1);
	isep = strfind( pl, '-' );

	target = pl(1:isep(end-1)-1);
	rate = pl(isep(end-1)+1:isep(end)-1);
	trial = strrep( strrep( pl(isep(end)+1:end), '!!Repeat!!', '' ), '!!Rubbish!!', '' );
	valid = isempty( strfind( pl(isep(end)+1:end), '!!Rubbish!!' ) );
end % function

function trials = unique_( trials )
	targets = unique( {trials.target} );
	rates = unique( {trials.rate} );

	for ti = 1:numel( targets )
		for ri = 1:numel( rates )
			tj = find( strcmp( targets{ti}, {trials.target} ) & strcmp( rates{ri}, {trials.rate} ) );
			tj(~[trials(tj).valid]) = [];

			[~, ui, ~] = unique( {trials(tj).trial} ); % advance trial ids
			while numel( tj ) ~= numel( ui )
				for uj = setdiff( 1:numel( tj ), ui );
					trials(tj(uj)).trial = sprintf( 'trial%d', str2num( trials(tj(uj)).trial(6:end) )+1 );
				end
				[~, ui, ~] = unique( {trials(tj).trial} );
			end
		end
	end
end % function

function log_( logfun, trials )
	logfun( 'targets: %s', util.any2str( unique( {trials.target} ) ) );
	logfun( 'rates: %s', util.any2str( unique( {trials.rate} ) ) );
	logfun( 'trials: %s', util.any2str( unique( {trials.trial} ) ) );
end % function

function warn_( subject, valfilt, varargin )
	logger = hLogger.instance();
	fcritical = logger.fcritical;

	if ~isempty( valfilt{1} ) && ~ismember( subject, valfilt{1} )
		logger.fcritical = false;
	end
	logger.warn( varargin{:} );

	logger.fcritical = fcritical;
end

function time = sweeptime_( sweepfile )
	fid = fopen( sweepfile );
	fgetl( fid );
	fgetl( fid );
	fgetl( fid );
	fgetl( fid );
	fgetl( fid );
	recl = fgetl( fid );
	time = datenum( recl(10:end), 'yyyy-mm-ddTHH:MM:SS.FFF' );
	fclose( fid );
end % function

function swdir = sweepdir_( srcdir, session, swname )
	swdir = fullfile( srcdir, session, 'sweeps/', swname, '/' );
end

function fc = convert__( dstdir, basename, subject, trial, sweep, layout, fdry, valfilt )
	logger = hLogger.instance();

		% prepare file composition
	[layout.labels, perm] = sort( layout.labels ); % make compatible fc
	layout.channels = layout.channels(perm);

	fc.subjects = {subject};
	fc.targets = {trial.target};
	fc.rates = {trial.rate};
	fc.trials = {trial.trial};
	fc.sensors = layout.labels;
	fc.axes = {'x', 'y', 'z'};

	if sweep.cutaudio
		fc.sensors = union( fc.sensors, {'audio'} );
		fc.axes = union( fc.axes, {'ch1'} );
	end

		% apply final filter
	if ~isempty( valfilt{5} )
		fc.sensors = fc.sensors(ismember( fc.sensors, valfilt{5} ));
	end

	if ~isempty( valfilt{6} )
		fc.axes = fc.axes(ismember( fc.axes, valfilt{6} ));
	end

		% verify file composition
	if ismember( 'audio', fc.sensors ) ~= ismember( 'ch1', fc.axes )
		fc.sensors(ismember( fc.sensors, 'audio' )) = [];
		fc.axes(ismember( fc.axes, 'ch1' )) = [];
	end

	if any( ~ismember( fc.sensors, 'audio' ) ) ~= any( ~ismember( fc.axes, {'ch1'} ) )
		fc.sensors(~ismember( fc.sensors, 'audio' )) = [];
		fc.axes(~ismember( fc.axes, 'ch1' )) = [];
	end

	if fdry % finish dry run
		return;
	end

		% convert ema data
	poslen = NaN;

	sensors = fc.sensors(~ismember( fc.sensors, 'audio' ));
	axes = fc.axes(~ismember( fc.axes, 'ch1' ));

	if numel( sensors )*numel( axes ) > 0
		posfile = fullfile( sweep.sweepdir, 'rawpos/', sprintf( '%04d.pos', sweep.sweepid ) ); % read sweep data
		[posdata, posrate] = io.readag501( posfile );
		poslen = (size( posdata, 2 )-1)/posrate;

		logger.tab( 'convert sweep file ''%s''...', posfile );

		for si = 1:numel( sensors )
			ich = layout.channels(ismember( layout.labels, sensors{si} ));

			for ai = 1:numel( axes )
				fccur = io.filtfcomp( fc, {'sensors', 'axes'}, {sensors(si), axes(ai)} ); % prepare output
				fcol = io.genfcol( fccur );
				io.valoutfcol( fcol, dstdir );
				dstfile = fullfile( dstdir, fcol{:}, strcat( basename, '.mat' ) );

				logger.log( 'write signal ''%s''...', dstfile );

				switch axes{ai} % re-arrange axes
					case 'x'
						iax = 1;
						axsign = 1;
					case 'y'
						iax = 3;
						axsign = 1;
					case 'z'
						iax = 2;
						axsign = -1;
				end

				sig = hNSignal( posrate ); % create signal
				sig.time = linspace( 0, (size( posdata, 2 )-1)/posrate, size( posdata, 2 ) );
				sig.data = axsign*posdata((ich-1)*7 + iax, :);

				if numel( unique( sig.data ) ) == 1 % integrity check
					logger.log( 'dubious sweep %s', util.any2str( sweep ) );
					logger.warn( 'dubious sweep data found!' );
				end

				sig.setlabel( NaN, 'time', 'time', 't', 's' ); % set labels
				switch axes{ai}
					case 'x'
						sig.setlabel( 1, 'horizontal displacement', 'horiz. displ.', 'x', 'mm' );
						sig.setlabel( 2, 'horizontal velocity', 'horiz. vel.', 'dx/dt', 'mm/s' );
						sig.setlabel( 3, 'horizontal acceleration', 'horiz. accel.', 'd^2x/dt^2', 'mm/s^2' );
						sig.setlabel( 4, 'horizontal jerk', 'horiz. jerk', 'd^3x/dt^3', 'mm/s^3' );
						sig.setlabel( 5, 'horizontal jounce', 'horiz. jounce', 'd^4x/dt^4', 'mm/s^4' );
					case 'y'
						sig.setlabel( 1, 'vertical displacement', 'vert. displ.', 'y', 'mm' );
						sig.setlabel( 2, 'vertical velocity', 'vert. vel.', 'dy/dt', 'mm/s' );
						sig.setlabel( 3, 'vertical acceleration', 'vert. accel.', 'd^2y/dt^2', 'mm/s^2' );
						sig.setlabel( 4, 'vertical jerk', 'vert. jerk', 'd^3y/dt^3', 'mm/s^3' );
						sig.setlabel( 5, 'vertical jounce', 'vert. jounce', 'd^4y/dt^4', 'mm/s^4' );
					case 'z'
						sig.setlabel( 1, 'lateral displacement', 'lat. displ.', 'z', 'mm' );
						sig.setlabel( 2, 'lateral velocity', 'lat. vel.', 'dz/dt', 'mm/s' );
						sig.setlabel( 3, 'lateral acceleration', 'lat. accel.', 'd^2z/dt^2', 'mm/s^2' );
						sig.setlabel( 4, 'lateral jerk', 'lat. jerk', 'd^3z/dt^3', 'mm/s^3' );
						sig.setlabel( 5, 'lateral jounce', 'lat. jounce', 'd^4z/dt^4', 'mm/s^4' );
				end

				io.writensig( sig, dstfile ); % write signal

				logger.tablog( 'write signal info ''%s''...', dstfile ); % write signal info

				info.trial = trial;
				info.sweep = sweep;
				info.layout = layout;

				io.writeinfo( info, dstfile );
			end
		end

		logger.untab();
	end

		% convert audio data
	sensors = fc.sensors(ismember( fc.sensors, 'audio' ));
	axes = fc.axes(ismember( fc.axes, 'ch1' ));

	if numel( sensors )*numel( axes ) == 1
		wavfile = fullfile( sweep.sweepdir, 'wav/', sprintf( '%04d.wav', sweep.sweepid ) );
		[wavdata, wavrate] = io.readwav( wavfile );

		logger.tab( 'convert audio file ''%s''...', wavfile );

		fccur = io.filtfcomp( fc, {'sensors', 'axes'}, {sensors, axes} ); % prepare output
		fcol = io.genfcol( fccur );
		io.valoutfcol( fcol, dstdir );
		dstfile = fullfile( dstdir, fcol{:}, strcat( basename, '.mat' ) );

		logger.log( 'write signal ''%s''...', dstfile );

		sig = hNSignal( wavrate ); % create signal
		sig.time = linspace( 0, (size( wavdata, 2 )-1)/wavrate, size( wavdata, 2 ) );
		sig.data = wavdata;

		wavlen = (size( wavdata, 2 )-1)/wavrate; % integrity check
		if abs( wavlen/poslen-1 ) > 0.05
			logger.log( 'dubious sweep %s', util.any2str( sweep ) );
			logger.warn( 'dubious audio data found!' );
		end

		sig.setlabel( NaN, 'time', 'time', 't', 's' ); % set labels
		sig.setlabel( 1, 'audio channel #1', 'audio #1', 'ch1', '' );

		io.writensig( sig, dstfile ); % write signal

		logger.tablog( 'write signal info ''%s''...', dstfile ); % write signal info

		info.trial = trial;
		info.sweep = sweep;
		info.layout = layout;

		io.writeinfo( info, dstfile );

		logger.untab();
	end

end % function

