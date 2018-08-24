function nvis( ftr, wmode, trdims, traudio, emach, fpanel, titlefun, cfgfile )
% nvis editing tool
%
% NVIS( ftr, wmode, trdims, traudio, emach, fpanel, titlefun, cfgfile )
%
% INPUT
% ftr : file transfer structure (scalar struct)
% wmode : work mode [passive, editroi, editmovs] (char)
% trdims : trial file composition dimensions (cell string)
% traudio : trial audio file composition values (cell cell string)
% emach : ema channels (numeric)
% fpanel : panel flags [detail, cartesian, portrait] (logical)
% titlefun : title function (function handle)
% cfgfile : configuration filename (char)

		% safeguard
	if nargin < 1 || ~isscalar( ftr ) || ~io.isftr( ftr )
		error( 'invalid argument: ftr' );
	end

	if nargin < 2 || ~ischar( wmode ) || ~ismember( wmode, {'passive', 'editroi', 'editmovs'} )
		error( 'invalid argument: wmode' );
	end

	if nargin < 3 || ~iscellstr( trdims )
		error( 'invalid argument: trdims' );
	end

	if nargin < 4 || ~iscell( traudio ) || ~all( cellfun( @( v ) iscellstr( v ), traudio ) )
		error( 'invalid argument: traudio' );
	end

	if nargin < 5 || ~isnumeric( emach )
		error( 'invalid argument: emach' );
	end

	if nargin < 6 || numel( fpanel ) ~= 3 || ~islogical( fpanel )
		error( 'invalid argument: fpanel' );
	end

	if nargin < 7 || ~isa( titlefun, 'function_handle' )
		error( 'invalid argument: titlefun' );
	end

	if nargin < 8 || ~ischar( cfgfile )
		error( 'invalid argument: cfgfile' );
	end

	logger = hLogger.instance();
	style = hStyle.instance();

		% prepare globals
	global NVIS_ZSCORE;
	if ~islogical( NVIS_ZSCORE ) || ~isscalar( NVIS_ZSCORE )
		NVIS_ZSCORE = false;
	end

	global NVIS_FILTIN NVIS_FILTEX NVIS_FILTSEL;
	if ~iscellstr( NVIS_FILTIN )
		NVIS_FILTIN = {'auto'};
	end
	if ~iscellstr( NVIS_FILTEX )
		NVIS_FILTEX = {};
	end
	if ~iscellstr( NVIS_FILTSEL )
		NVIS_FILTSEL = {'gest'};
	end

	global NVIS_BRIGHTEN;
	if ~isnumeric( NVIS_BRIGHTEN ) || ~isscalar( NVIS_BRIGHTEN )
		NVIS_BRIGHTEN = 0.2;
	end

		% prepare i/o
	srcfcaudio = io.filtfcomp( ftr.srcfc, trdims, traudio, true );
	dstfcaudio = io.filtfcomp( ftr.dstfc, trdims, traudio, true );
	
	srcfcolaudio = io.genfcol( srcfcaudio );
	[srcfcolaudio, srcvalaudio] = io.valinfcol( srcfcolaudio, ftr.srcdir, ftr.srcbase, '.mat' );
	dstfcolaudio = io.genfcol( dstfcaudio );
	dstfcolaudio = dstfcolaudio(srcvalaudio);
	io.valoutfcol( dstfcolaudio, ftr.dstdir );
	
	srcfcema = io.filtfcomp( ftr.srcfc, trdims, traudio, false );
	dstfcema = io.filtfcomp( ftr.dstfc, trdims, traudio, false );
	
	srcfcolema = io.genfcol( srcfcema );
	[srcfcolema, srcvalema] = io.valinfcol( srcfcolema, ftr.srcdir, ftr.srcbase, '.mat' );
	dstfcolema = io.genfcol( dstfcema );
	dstfcolema = dstfcolema(srcvalema);
	io.valoutfcol( dstfcolema, ftr.dstdir );

	if numel( srcfcolaudio ) + numel( srcfcolema ) < 1
		return;
	end
	
	logger.tab( 'nvis editing...' );
	logger.module = util.module();

		% initialize data structures
	adata = setdata_( ftr, srcfcaudio, srcfcolaudio, 1, false );
	edata = setdata_( ftr, srcfcema, srcfcolema, emach, NVIS_ZSCORE );

	if numel( edata.sigs ) > 9
		error( 'invalid value: edata' );
	end

	lroi = [adata.rois(:, 1); edata.rois(:, 1)]; % data roi
	rroi = [adata.rois(:, 2); edata.rois(:, 2)];

		% prepare figure
	gdata.fig = hFigure( ...
		'Visible', 'on', ...
		'Interruptible', 'on', 'BusyAction', 'cancel' ); % TODO: interruption might cause issues!

	set( gdata.fig.hfig, 'MenuBar', 'none' );
	[adata, edata, gdata] = setpanels_( adata, edata, gdata, fpanel, titlefun );

		% read configuration
	cfgfdyn = false;
	cfgfmovs = [true, true, true];
	cfgfsigs = true;
	cfgfdata = false;
	cfgfdebug = false;

	cfgfgroup = true( [1, 9] );

	cfgvres = 1;

	try
		load( cfgfile, '-mat', 'cfgfdyn', 'cfgfmovs', 'cfgfsigs', 'cfgfdata', 'cfgfdebug' );
		load( cfgfile, '-mat', 'cfgfgroup' );
		load( cfgfile, '-mat', 'cfgvres' );
	end

		% finalize data structures
	gdata.fdone = false;
	gdata.fstop = false;

	gdata.cfgfile = cfgfile;

	gdata.fdyn = cfgfdyn; % toggles
	gdata.fmovs = cfgfmovs;
	gdata.fsigs = cfgfsigs;
	gdata.fdata = cfgfdata;
	gdata.fdebug = cfgfdebug;

	gdata.fgroup = cfgfgroup([1:numel( edata.sigs )]);
	gdata.hmovs = {};
	gdata.hsigs = {};
	gdata.hdata = {};
	gdata.hdebug = {};
	
	gdata.vres = cfgvres; % view
	gdata.vtmargin = 0.025;
	gdata.vxmargin = 0.1;
	gdata.vdetail = 20;
	gdata.vtl = style.limits( [adata.tl(:); edata.tl(:)] );
	gdata.vroi = style.limits( [lroi, rroi], 0, gdata.vtl );
	gdata.vcenter = mean( style.limits( gdata.vroi, gdata.vtmargin, gdata.vtl ) );
	gdata.vwidth = diff( style.limits( gdata.vroi, gdata.vtmargin, gdata.vtl ) );

	gdata.filtin = NVIS_FILTIN; % filters
	gdata.filtex = NVIS_FILTEX;
	gdata.filtsel = NVIS_FILTSEL;

	gdata.wmode = wmode; % other
	gdata.wavfile = sprintf( '%s.wav', tempname() );
	gdata.plotdir = fileparts( cfgfile );

	gdata.hpointer = NaN;
	gdata.pointer = NaN( [1, 3] );

	setappdata( gdata.fig.hfig, 'adata', adata );
	setappdata( gdata.fig.hfig, 'edata', edata );
	setappdata( gdata.fig.hfig, 'gdata', gdata );

		% editing loop
	setview_( gdata.fig.hfig, true );

	plotmovs_( gdata.fig.hfig );
	plotsigs_( gdata.fig.hfig );
	plotdata_( gdata.fig.hfig );
	plotdebug_( gdata.fig.hfig );

	set( gdata.fig.hfig, ... % start dispatching
		'UserData', false, ...
		'CloseRequestFcn', {@dispatch_, 'close'}, ...
		'WindowKeyPressFcn', {@dispatch_, 'keypress'}, ...
		'WindowButtonDownFcn', {@dispatch_, 'buttonpress'}, ...
		'WindowButtonUpFcn', {@dispatch_, 'buttonup'} );

	while true % loop dispatcher
		waitfor( gdata.fig.hfig, 'UserData' );

		if ishandle( gdata.fig.hfig )
			adata = getappdata( gdata.fig.hfig, 'adata' );
			edata = getappdata( gdata.fig.hfig, 'edata' );
			gdata = getappdata( gdata.fig.hfig, 'gdata' );

			if gdata.fdone
				break;
			end
		else
			break;
		end
	end

		% cleanup
	gdata.fig.close();

	if exist( gdata.wavfile, 'file' ) == 2
		delete( gdata.wavfile );
	end

		% write data
	switch gdata.wmode
		case 'editroi'
			for fi = 1:numel( dstfcolaudio )
				dstfile = fullfile( ftr.dstdir, dstfcolaudio{fi}, strcat( ftr.dstbase, '.mat' ) );
				io.writeparts( dstfile, {'roi'}, adata.rois(fi, :) );
			end
			for fi = 1:numel( dstfcolema )
				dstfile = fullfile( ftr.dstdir, dstfcolema{fi}, strcat( ftr.dstbase, '.mat' ) );
				io.writeparts( dstfile, {'roi'}, edata.rois(fi, :) );
			end
		case 'editmovs'
			for fi = 1:numel( dstfcolema )
				dstfile = fullfile( ftr.dstdir, dstfcolema{fi}, strcat( ftr.dstbase, '.mat' ) );
				io.writeparts( dstfile, {'movs'}, edata.movs{fi} );
			end
	end

		% write configuration
	cfgfdyn = gdata.fdyn;
	cfgfmovs = gdata.fmovs;
	cfgfsigs = gdata.fsigs;
	cfgfdata = gdata.fdata;
	cfgfdebug = gdata.fdebug;

	cfgfgroup([1:numel( edata.sigs )]) = gdata.fgroup;

	cfgvres = gdata.vres;

	args = {'-mat'};
	if exist( cfgfile )
		args{end+1} = '-append';
	end
	save( cfgfile, 'cfgfdyn', 'cfgfmovs', 'cfgfsigs', 'cfgfdata', 'cfgfdebug', args{:} );
	save( cfgfile, 'cfgfgroup', args{:} );
	save( cfgfile, 'cfgvres', args{:} );

		% done
	logger.module = '';
	logger.untab();

		% stop mapping
	if gdata.fstop
		throw( MException( 'io:mapftr:stop', 'stop mapping' ) );
	end

end % function

