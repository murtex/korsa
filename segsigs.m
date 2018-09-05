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
fc.axes = {};

fc = io.fixfcomp( fc, fcfull );

	% -----------------------------------------------------------------------
	% duplicate signals
if true
	fcp = fc;
	ftr = io.genftr( fcp, procdir_, 'pre', fcp, procdir_, 'seg' );
	fexp = ~io.expfcomp( fcp, trialdims_ );

	io.mapftr( ftr, fexp, @proc.copy, {'sig', 'info'} );
end

	% -----------------------------------------------------------------------
	% segmentation pre-transform
if true
	switch seg_method_
		case {'mwpca', 'vert'}
			% nop

		case 'roipca' % roi editing
			fcp = io.joinfcomp( io.filtfcomp( fc, filtaudio_{:} ), io.filtfcomp( fc, filtvert_{:} ) );
			ftr = io.genftr( fcp, procdir_, 'seg' );
			fexp = ~io.expfcomp( fcp, trialdims_ );

			while true
				io.mapftr( ftr, fexp, @nvis.nvis, 'editroi', filtaudio_{1}, filtaudio_{2}, [1], [false, false, false], @title_inspect_, fullfile( 'aux/', strcat( util.module(), '.cfg' ) ) );

				if strcmp( 'no', questdlg( 'reiterate this task?', util.module(), 'yes', 'no', 'yes' ) )
					break;
				end
			end

		otherwise
			error( 'invalid value: seg_method_' );
	end
end

	% -----------------------------------------------------------------------
	% segmentation post-transform
if true
	switch seg_method_
		case 'mwpca'
			fcp = io.filtfcomp( fc, filtema_{:} );
			ftr = io.genftr( fcp, procdir_, 'seg' );
			fexp = ~io.expfcomp( fcp, {'axes'} );

			io.mapftr( ftr, fexp, @proc.mwpca, seg_pca_, seg_cycles_ );

		case 'roipca'
			fcp = io.filtfcomp( fc, filtema_{:} );
			ftr = io.genftr( fcp, procdir_, 'seg' );
			fexp = ~io.expfcomp( fcp, {'axes'} );

			io.mapftr( ftr, fexp, @proc.roipca, seg_pca_ );

		case 'vert'
			% nop

		otherwise
			error( 'invalid value: seg_method_' );
	end
end

	% -----------------------------------------------------------------------
	% spline approximation
if true
	fcp = io.filtfcomp( fc, filtpca_{:} );
	ftr = io.genftr( fcp, procdir_, 'seg' );
	fexp = ~io.expfcomp( fcp, trialdims_ );

	io.mapftr( ftr, fexp, @proc.spline, seg_spline_ );
end

	% -----------------------------------------------------------------------
	% segmentation
if true
	fcp = io.filtfcomp( fc, filtpca_{:} );
	ftr = io.genftr( fcp, procdir_, 'seg' );
	fexp = ~io.expfcomp( fcp, trialdims_ );

	io.mapftr( ftr, fexp, @proc.segment, seg_tags_ );
end

	% -----------------------------------------------------------------------
	% q-narrowing
if true
	fcp = io.filtfcomp( fc, filtpca_{:} );
	ftr = io.genftr( fcp, procdir_, 'seg' );
	fexp = ~io.expfcomp( fcp, {'axes'} );

	io.mapftr( ftr, fexp, @proc.qnarrow, seg_q_ );
end

	% done
logger.untab( 'done' );
logger.done();

