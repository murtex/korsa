% manual movement selection

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
style.ffull = true;
style.layout( 'screen', 72, '755px', '14pt' );
style.geometry( [1, 1], [1, 1], 1.0, [NaN, NaN, NaN, NaN] );

	% prepare dataset
logger.fcritical = false;
fcfull = fc_full_( rawdir_, procdir_, fieldnames( fc_ ), false );
logger.fcritical = true;

fc = fc_;
fc.sensors = [fc_.sensors, sensaudio_];
fc.axes = [axpca_, axaudio_];

fc = io.fixfcomp( fc, fcfull );

	% -----------------------------------------------------------------------
	% edit movements
if true
	fcp = fc;
	ftr = io.genftr( fcp, procdir_, 'pca' );
	fexp = ~io.expfcomp( fcp, trialdims_ );

	global NVIS_FILTIN NVIS_FILTEX NVIS_FILTSEL;
	NVIS_FILTIN = man_filtin_;
	NVIS_FILTEX = man_filtex_;
	NVIS_FILTSEL = man_filtsel_;

	global NVIS_BRIGHTEN;
	NVIS_BRIGHTEN = man_brighten_;

	io.mapftr( ftr, fexp, @nvis.nvis, 'editmovs', filtaudio_{1}, filtaudio_{2}, [1, 2], [false, false, false], @title_inspect_, fullfile( 'aux/', strcat( util.module(), '.cfg' ) ) );
end

	% done
logger.untab( 'done' );
logger.done();

