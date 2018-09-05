% finalize signals

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
fc.sensors = {};
fc.axes = {};

fc = io.fixfcomp( fc, fcfull );

	% -----------------------------------------------------------------------
	% duplicate signals
if true

		% pre signals, TODO: do not overwrite on existence!
	fcp = fc;
	ftr = io.genftr( fcp, procdir_, 'pre', fcp, procdir_, 'occ' );
	fexp = ~io.expfcomp( fcp, trialdims_ );

	io.mapftr( ftr, fexp, @proc.copy, {'sig', 'info'} );

		% seg movements
	fcp = io.filtfcomp( fc, trialdims_, {fc_.sensors, axpca_}, true );

	for ai = [1:numel( axema_ )]
		fcpp = io.filtfcomp( fc, trialdims_, {fc_.sensors, axema_(ai)}, true );

		ftr = io.genftr( fcp, procdir_, 'seg', fcpp, procdir_, 'occ' );
		fexp = ~io.expfcomp( fcp, trialdims_ );

		io.mapftr( ftr, fexp, @proc.copy, {'movs'} );
	end

end

	% -----------------------------------------------------------------------
	% spline approximation
if true
	fcp = io.filtfcomp( fc, trialdims_, {fc_.sensors, axema_}, true );
	ftr = io.genftr( fcp, procdir_, 'occ' );
	fexp = ~io.expfcomp( fcp, trialdims_ );

	io.mapftr( ftr, fexp, @proc.spline, seg_spline_ );
end

	% -----------------------------------------------------------------------
	% minimize roi
if true
	fcp = fc;
	ftr = io.genftr( fcp, procdir_, 'occ' );
	fexp = ~io.expfcomp( fcp, trialdims_ );

	io.mapftr( ftr, fexp, @proc.minroi, {'gest'} );
end

	% done
logger.untab( 'done' );
logger.done();

