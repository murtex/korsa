% AG501 raw conversion

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

	% prepare dataset
logger.fcritical = false;
fcfull = fc_full_( rawdir_, procdir_, fieldnames( fc_ ), true );
logger.fcritical = true;

fc = fc_;
fc.sensors = {};
fc.axes = {};

fc = io.fixfcomp( fc, fcfull );

	% -----------------------------------------------------------------------
	% convert data
if true
	convert_( rawdir_, procdir_, 'raw', false, transpose( struct2cell( fc ) ) );
end

	% done
logger.untab( 'done' );
logger.done();

