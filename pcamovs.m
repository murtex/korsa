% movement segmentation

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
style.layout( 'screen', get( 0, 'ScreenPixelsPerInch' ), '755px', '14pt' );
style.geometry( [1, 1], [1, 1], 1.0, [NaN, NaN, NaN, NaN] );

	% prepare dataset
logger.fcritical = false;
fcfull = fc_full_( rawdir_, procdir_, fieldnames( fc_ ), false );
logger.fcritical = true;

fc = fc_;
fc.sensors = [fc_.sensors, sensaudio_];
fc.axes = {};

fc = io.fixfcomp( fc, fcfull );

	% -----------------------------------------------------------------------
	% duplicate signals
if true
	fcp = fc;
	ftr = io.genftr( fcp, procdir_, 'pre', fcp, procdir_, 'pca' );
	fexp = ~io.expfcomp( fcp, trialdims_ );

	io.mapftr( ftr, fexp, @proc.copy, {'sig', 'info'} );
end

	% -----------------------------------------------------------------------
	% moving window pca
if true
	fcp = io.filtfcomp( fc, filtema_{:} );
	ftr = io.genftr( fcp, procdir_, 'pca' );
	fexp = ~io.expfcomp( fcp, {'axes'} );

	io.mapftr( ftr, fexp, @proc.mwpca, pca_method_, pca_cycles_ );
end

	% -----------------------------------------------------------------------
	% spline approximation
if true
	fcp = io.filtfcomp( fc, filtema_{:} );
	ftr = io.genftr( fcp, procdir_, 'pca' );
	fexp = ~io.expfcomp( fcp, trialdims_ );

	io.mapftr( ftr, fexp, @proc.spline, pca_spline_ );
end

	% -----------------------------------------------------------------------
	% segment signals
if true
	fcp = io.filtfcomp( fc, filtpca_{:} );
	ftr = io.genftr( fcp, procdir_, 'pca' );
	fexp = ~io.expfcomp( fcp, trialdims_ );

	io.mapftr( ftr, fexp, @proc.segment, pca_tags );
end

	% done
logger.untab( 'done' );
logger.done();

