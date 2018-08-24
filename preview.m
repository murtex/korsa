% AG501 raw inspection

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
style.layout( 'screen', get( 0, 'ScreenPixelsPerInch' ), '755px', '16pt' );
style.geometry( [1, 1], [1, 1], 1.0, [NaN, NaN, NaN, NaN] );

	% specify dataset
% session = '20180702-lt';
% session = '20180704-it';
% session = '20180706-cz';
% session = '20170712-st';

session = '20180628-dg';
reference = [4, 2, 3, 10];
biteplate = [5, 6, 7];
visible = setdiff( [1:16], [biteplate, 11] );
sweepdir = 'r0-1';

session = '20180702-lt';
reference = [2, 3, 5];
biteplate = [6, 7, 8];
visible = setdiff( [1:16], biteplate );
sweepdir = 'r1';

sweepids = [53:400];

	% proceed sweep ids
for si = sweepids

		% read data
	rawfile = fullfile( rawdir_, session, 'sweeps/', sweepdir, 'rawpos/', sprintf( '%04d.pos', si ) );

	if exist( rawfile, 'file' ) ~= 2
		logger.log( 'skipping non-existent raw file ''%s''...', rawfile );
		continue;
	else
		logger.log( 'inspecting raw file ''%s''...', rawfile );
	end

	[data, rate] = io.readag501( rawfile );

	ntmp = size( data, 2 );
	nch = size( data, 1 )/7;

		% check data
	conch = [];
	malch = [];
	nanch = [];

	r = NaN( [nch, 3, ntmp] );

	for ci = [1:nch]
		r(ci, :, :) = data((ci-1)*7+[1:3], :);

		nx = numel( unique( r(ci, 1, :) ) );
		ny = numel( unique( r(ci, 2, :) ) );
		nz = numel( unique( r(ci, 3, :) ) );

		if any( [nx, ny, nz] == 1 ) % constant signals
			conch(end+1) = ci;
		end
		if any( [nx, ny, nz] < 0.1*ntmp ) % malicious signals
			malch(end+1) = ci;
		end
		if any( any( isnan( r(ci, [1:3], :) ) ) ) % nan signals
			nanch(end+1) = ci;
		end
	end

	r(:, 2, :) = -r(:, 2, :); % natural orientation
	r(:, [2, 3], :) = r(:, [3, 2], :);

	visch = intersect( visible, setdiff( [1:nch], unique( [conch, malch, nanch] ) ) );
	fixch = intersect( reference, setdiff( [1:nch], unique( [conch, malch, nanch] ) ) );

		% downsampling (~100 hertz)
	ratehint = 100;
	q = floor( rate/ratehint );

	attenuation = 80; % 80 desibel
	passband = 1/q; % normalized cutoff (as specified by MATLAB's decimate)
	stopband = 2/q; % twice as high stopband
	order = ceil( attenuation/(22*(stopband-passband)) ); % Fred Harris' "rule of thumb"

	rp = [];
	for ci = [1:nch]
		rp(ci, 1, :) = decimate( reshape( r(ci, 1, :), [1, ntmp] ), q, order, 'fir' );
		rp(ci, 2, :) = decimate( reshape( r(ci, 2, :), [1, ntmp] ), q, order, 'fir' );
		rp(ci, 3, :) = decimate( reshape( r(ci, 3, :), [1, ntmp] ), q, order, 'fir' );
	end

	r = rp;
	ntmp = size( r, 3 );
	rate = rate/q;

		% lowpass filter (25 hertz)
	cutoff = 25;
	attenuation = 80; % 80 desibel
	passband = cutoff/rate; % normalized cutoff
	stopband = 1.5*passband; % one and a half as high stopband
	order = ceil( attenuation/(22*(stopband-passband)) ); % Fred Harris' "rule of thumb"

	[b, a] = butter( order, passband ); % apply lowpass
	for ci = union( visch, fixch )
		for ai = 1:3
			r(ci, ai, :) = filtfilt( b, a, r(ci, ai, :) );
		end
	end

		% head movement correction
	if numel( fixch ) > 2
		q = zeros( [4, ntmp] );

		r0 = mean( r(fixch, :, :), 1 ); % source centroid
		rs = r(fixch, :, :)-r0; % source vectors
		rt = rs(:, :, 1); % target vectors

		for ti = 1:ntmp
			q(:, ti) = norm_( util.absor( rt, rs(:, :, ti) ) );
		end

		for ci = visch
			r(ci, :, :) = r(ci, :, :)-r0;
			r(ci, :, :) = qrot_( q, reshape( r(ci, :, :), [3, ntmp] ) );
		end
	end

		% prepare figure
	gdata.fdone = false;
	gdata.fstop = false;

	fig = hFigure( ...
		'Visible', 'on', ...
		'UserData', false, ...
		'CloseRequestFcn', {@fig_dispatch_, 'close'}, ...
		'WindowKeyPressFcn', {@fig_dispatch_, 'keypress'} );

	hax = fig.subplot( 1, 1, 1, 'DataAspectRatio', [1, 1, 1] );
	fig.xlabel( 'Horizontal' );
	fig.ylabel( 'Vertical' );
	fig.zlabel( 'Lateral' );
	xlim( style.limits( r(visch, 1, :), 0.1 ) );
	ylim( style.limits( r(visch, 2, :), 0.1 ) );
	zlim( style.limits( r(visch, 3, :), 0.1 ) );
	view( [225, 60] );
	camup( [0, 1, 0] );

	fig.title( {...
		sprintf( 'sweep file: ''%s''', rawfile ), ...
		sprintf( 'constant: %s, malicious: %s, NaN: %s, visible: %s', util.any2str( conch ), util.any2str( malch ), util.any2str( nanch ), util.any2str( visch ) ) } );

		% draw data
	fig.axes( hax );

	for ci = visch
		xp = [reshape( r(ci, 1, :), [1, ntmp] ), NaN];
		yp = [reshape( r(ci, 2, :), [1, ntmp] ), NaN];
		zp = [reshape( r(ci, 3, :), [1, ntmp] ), NaN];

		if ismember( ci, biteplate ) % blue
			hue = 0/3 + (find( ci == biteplate )-1)/(numel( biteplate )-1)/6;
		elseif ismember( ci, reference ) % red
			hue = 1/3 + (find( ci == reference )-1)/(numel( reference )-1)/6;
		else % green
			s = setdiff( setdiff( [1:nch], reference ), biteplate );
			hue = 2/3 + (find( ci == s )-1)/(numel( s )-1)/6;
		end
		cp = repmat( style.color( hue, style.shadelo ), [numel( xp ), 1] );

		patch( 'XData', mean( xp(1:end-1) ), 'YData', mean( yp(1:end-1) ), 'ZData', mean( zp(1:end-1) ), 'CData', cp(1, :), 'FaceVertexCData', cp(1, :), 'LineStyle', 'none', 'LineWidth', style.lwthin, 'Marker', 'o', 'MarkerSize', style.msnorm, 'MarkerEdgeColor', 'flat' );
		patch( 'XData', xp, 'YData', yp, 'ZData', zp, 'CData', cp, 'FaceVertexCData', cp, 'LineWidth', style.lwnorm, 'EdgeColor', 'flat', 'FaceColor', 'none' );
	end

		% add legend
	hb = fig.blank( 'HitTest', 'off' );
	ht = text( 0.99, 0.01, {'blue: biteplate', 'red: reference', 'green: other'}, ...
		'Units', 'normalized', 'BackgroundColor', style.color( NaN, style.shadehi ), ...
		'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', ...
		'FontSize', style.fsnorm, 'FontWeight', 'bold' );

		% application loop
	setappdata( fig.hfig, 'gdata', gdata );

	while true
		waitfor( fig.hfig, 'UserData' );

		if ishandle( fig.hfig )
			gdata = getappdata( fig.hfig, 'gdata' );

			if gdata.fdone || gdata.fstop
				break;
			end
		else
			break;
		end
	end

		% clean up
	fig.close();

	if gdata.fstop
		break;
	end

end

	% done
logger.untab( 'done' );
logger.done();

	% local functions
function x = norm_( x )
	x = x/sqrt( sum( x.^2 ) );
end % function

function vp = qrot_( q, v )
	nt = size( q, 2 );

	w = reshape( q(1, :), [1, 1, nt] );
	x = reshape( q(2, :), [1, 1, nt] );
	y = reshape( q(3, :), [1, 1, nt] );
	z = reshape( q(4, :), [1, 1, nt] );

	M11 = 1 - 2*y.^2 - 2*z.^2;
	M12 = 2*x.*y - 2*z.*w;
	M13 = 2*x.*z + 2*y.*w;
	M21 = 2*x.*y + 2*z.*w;
	M22 = 1 - 2*x.^2 - 2*z.^2;
	M23 = 2*y.*z - 2*x.*w;
	M31 = 2*x.*z - 2*y.*w;
	M32 = 2*y.*z + 2*x.*w;
	M33 = 1 - 2*x.^2 - 2*y.^2;;

	M = cat( 2, cat( 1, M11, M21, M31 ), cat( 1, M12, M22, M32 ), cat( 1, M13, M23, M33 ) );

	for ti = 1:nt
		vp(:, ti) = M(:, :, ti)*v(:, ti);
	end
end % function


