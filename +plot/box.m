function hld = box( fig, hax, data )
% box plot
%
% hld = BOX( fig, hax, data )
%
% INPUT
% fig : figure reference (scalar object)
% hax : axes handle (scalar handle)
% data : data (struct)
%
% OUTPUT
% hld : legend handles (handle)

		% safeguard
	if nargin < 1 || ~isscalar( fig ) || ~isa( fig, 'hFigure' )
		error( 'invalid argument: fig' );
	end

	if nargin < 2 || ~isscalar( hax ) || ~ishandle( hax )
		error( 'invalid argument: hax' );
	end

	if nargin < 3 || ~isstruct( data )
		error( 'invalid argument: data' );
	end

	style = hStyle.instance();

	hld = [];

		% merge data
	for di = [2:numel( data )]
		data(1).fcol = [data(1).fcol; data(di).fcol];
		data(1).fc = io.joinfcomp( data(1).fc, data(di).fc );
		data(1).fpos = [data(1).fpos, data(di).fpos];
		data(1).vals = [data(1).vals, data(di).vals];
		data(1).form = [data(1).form, data(di).form];
	end

	data = data(1);

		% prepare box data
	ux = unique( data.vals(1, :) );
	nux = numel( ux );
	
	qpos = NaN( [nux, 5] );
	qneg = NaN( [nux, 5] );

	for ui = [1:nux]
		qpos(ui, :) = tukey_( data.vals(2, data.fpos & data.vals(1, :) == ux(ui)) );
		qneg(ui, :) = tukey_( data.vals(2, ~data.fpos & data.vals(1, :) == ux(ui)) );
	end

		% prepare box styling
	huepos = NaN( [1, nux] );
	hueneg = NaN( [1, nux] );

	for ui = [1:nux]
		huepos(ui) = mean( [data.form(data.fpos & data.vals(1, :) == ux(ui)).hue] );
		hueneg(ui) = mean( [data.form(~data.fpos & data.vals(1, :) == ux(ui)).hue] );
	end

		% interleave directions
	x = NaN( [1, 0] );
	w = NaN( [1, 0] );
	q = NaN( [0, 5] );
	hue = NaN( [1, 0] );

	fpos = ~all( isnan( qpos(:) ) );
	fneg = ~all( isnan( qneg(:) ) );

	Q = 0.618;
	W = Q*min( diff( ux ) );
	W2 = W/2;

	if fpos && fneg % bi-directional
		x = [ux-W2/2, ux+W2/2];
		w = repmat( W2, size( x ) );
		q = [qpos; qneg];
		hue = [huepos, hueneg];
	elseif fpos % mono-directional, positive
		x = ux;
		w = repmat( W, size( x ) );
		q = qpos;
		hue = huepos;
	elseif fneg % mono-directional, negative
		x = ux;
		w = repmat( W, size( x ) );
		q = qneg;
		hue = hueneg;
	end

		% plot boxes
	fig.axes( hax );

	for xi = [1:numel( x )]
		box_( x(xi), w(xi), q(xi, :), hue(xi) );
	end

		% adjust axis limits
	set( hax, 'YLim', style.limits( q, 0.1, get( hax, 'YLim' ) ) );

end % function

	% local functions
function q = tukey_( v )
	q = NaN( [1, 5] );
	q([2:4]) = quantile( v, [0.25, 0.5, 0.75] );
	iqr = abs( q(4)-q(2) );
	if iqr > 0
		q(1) = min( v(v >= q(3)-1.5*iqr) );
		q(5) = max( v(v <= q(3)+1.5*iqr) );
	end
end % function

function box_( x, w, q, hue )
	style = hStyle.instance();

	xp = [x, x, NaN]; % candle
	yp = [q(1), q(5), NaN];
	patch( 'XData', xp, 'YData', yp, 'FaceColor', 'none', 'EdgeColor', style.color( NaN, style.shadelo ), 'LineWidth', style.lwthin );

	xp = [x-w/2, x-w/2, x+w/2, x+w/2]; % box
	yp = [q(2), q(4), q(4), q(2)];
	patch( 'XData', xp, 'YData', yp, 'FaceColor', style.color( hue, style.shademed ), 'EdgeColor', style.color( NaN, style.shadelo ), 'LineWidth', style.lwthin );

	Q = 0.618; % whiskers
	xp = repmat( [x-w/2, x+w/2, NaN], [1, 3] );
	xp = [x-Q*w/2, x+Q*w/2, NaN, x-w/2, x+w/2, NaN, x-Q*w/2, x+Q*w/2, NaN];
	yp = [q([1, 1]), NaN, q([3, 3]), NaN, q([5, 5]), NaN];
	patch( 'XData', xp, 'YData', yp, 'FaceColor', 'none', 'EdgeColor', style.color( NaN, style.shadelo ), 'LineWidth', style.lwthin );
end % function

