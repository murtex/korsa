% general signal animation

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
fc.axes = {};

fc = io.fixfcomp( fc, fcfull );

	% -----------------------------------------------------------------------
	% animate signals
if true
	fcp = io.filtfcomp( fc, filtema_{:} ); % TODO: audio track!
	ftr = io.genftr( fcp, procdir_, ani_proc_, fcp, plotdir_, sprintf( '%s-ani', ani_proc_ ) );
	fexp = ~io.expfcomp( fcp, trialdims_ );

	io.mapftr( ftr, fexp, @animate_, @title_none_, ani_mp4_, ani_rate_, pca_cycles_, {senstongue_, sensbplate_} );
end

	% done
logger.untab( 'done' );
logger.done();

