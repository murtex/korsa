% raw preprocessing

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
fc.sensors = {};
fc.axes = {};

fc = io.fixfcomp( fc, fcfull );

	% -----------------------------------------------------------------------
	% duplicate data
if true
	fcp = fc;
	ftr = io.genftr( fcp, procdir_, 'raw', fcp, procdir_, 'pre' );
	fexp = ~io.expfcomp( fcp, trialdims_ );

	io.mapftr( ftr, fexp, @proc.copy, {'sig', 'info'} );
end

	% -----------------------------------------------------------------------
	% downsample signals
if true
	fcp = io.filtfcomp( fc, filtema_{:} );
	ftr = io.genftr( fcp, procdir_, 'pre' );
	fexp = ~io.expfcomp( fcp, trialdims_ );

	io.mapftr( ftr, fexp, @proc.decimate, pre_rate_ );
end

	% -----------------------------------------------------------------------
	% filter signals
if true
	fcp = io.filtfcomp( fc, filtema_{:} );
	ftr = io.genftr( fcp, procdir_, 'pre' );
	fexp = ~io.expfcomp( fcp, trialdims_ );

	io.mapftr( ftr, fexp, @proc.filter, pre_cutoff_ );
end

	% -----------------------------------------------------------------------
	% fix reference signals
if true
	fcp = io.filtfcomp( fc, filtema_{:} );
	ftr = io.genftr( fcp, procdir_, 'pre' );
	fexp = ~io.expfcomp( fcp, trialdims_ );

	io.mapftr( ftr, fexp, @proc.fixate, sensref_ );
end

	% -----------------------------------------------------------------------
	% determine reference frame
fcbp = io.fixfcomp( io.filtfcomp( fcbp_, filtema_{:} ), fcfull );
ftrbp = io.genftr( fcbp, procdir_, 'pre' );
fexpbp = ~io.expfcomp( fcbp, trialdims_ );

if true && ismember( 'bplate', fc.targets )

		% roi editing
	fcp = fcbp;
	fcp.sensors = sensbplate_;

	ftr = io.genftr( fcp, procdir_, 'pre' );
	fexp = ~io.expfcomp( fcp, trialdims_ );

	global NVIS_ZSCORE;
	NVIS_ZSCORE = true;

	io.mapftr( ftr, fexp, @nvis.nvis, 'editroi', filtaudio_{1}, filtaudio_{2}, [1], [false, false, false], @title_inspect_, fullfile( 'aux/', strcat( util.module(), '.cfg' ) ) );

		% determine frame
	io.mapftr( ftrbp, fexpbp, @proc.frameget, sensref_, sensbplate_, senssag_ );

end

	% -----------------------------------------------------------------------
	% align reference frame
if true
	fcp = io.filtfcomp( fc, filtema_{:} );
	ftr = io.genftr( fcp, procdir_, 'pre' );
	fexp = ~io.expfcomp( fcp, trialdims_ );

	io.mapftr( ftr, fexp, @proc.frameset, ftrbp, fexpbp );
end

	% done
logger.untab( 'done' );
logger.done();

