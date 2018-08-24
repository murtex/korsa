% general signal inspection

	% process specs
clear( 'all' );

flist = dir( fullfile( 'specs/', '*.m' ) );
flist([flist.isdir]) = [];
flist = sort( {flist.name} );

for li = [1:numel( flist )]
	eval( fileread( fullfile( 'specs/', flist{li} ) ) );
end

	% initialize framework
addpath( xisdir_ );

logger = hLogger.instance( fullfile( 'aux/', strcat( util.module(), '.log' ) ) );
logger.tab( '%s...', util.module() );

style = hStyle.instance();
style.fmenu = false;
style.layout( 'screen', 72, '755px', '14pt' );
style.geometry( [1, 1], [1, 1], 1.0, [NaN, NaN, NaN, NaN] );

	% prepare dataset
logger.fcritical = false;
fcfull = fc_full_( rawdir_, procdir_, fieldnames( fc_ ), false );
logger.fcritical = true;

fc = fc_;
fc.sensors = [fc_.sensors, sensaudio_];
fc.axes = [fc_.axes, axaudio_];

fc = io.fixfcomp( fc, fcfull );

	% -----------------------------------------------------------------------
	% inspect signals
if true
	fcp = fc;
	ftr = io.genftr( fcp, procdir_, ins_proc_ );
	fexp = ~io.expfcomp( fcp, trialdims_ );

	global NVIS_FILTIN NVIS_FILTEX NVIS_FILTSEL;
	NVIS_FILTIN = ins_filtin_;
	NVIS_FILTEX = ins_filtex_;
	NVIS_FILTSEL = ins_filtsel_;

	global NVIS_BRIGHTEN;
	NVIS_BRIGHTEN = ins_brighten_;

	io.mapftr( ftr, fexp, @nvis.nvis, 'passive', filtaudio_{1}, filtaudio_{2}, ins_chan_, [false, ins_spat_, ins_port_], @title_inspect_, fullfile( 'aux/', strcat( util.module(), '.cfg' ) ) );
end

	% done
logger.untab( 'done' );
logger.done();

