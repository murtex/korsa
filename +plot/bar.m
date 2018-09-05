function hld = bar( fig, hax, data, base )
% bar plot
%
% hld = BAR( fig, hax, data )
% hld = BAR( fig, hax, data, base )
%
% INPUT
% fig : figure reference (scalar object)
% hax : axes handle (scalar handle)
% data : data (struct)
% base : base value (numeric scalar)
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

	if nargin < 4
		base = 0;
	end
	if ~isnumeric( base ) || ~isscalar( base )
		error( 'invalid argument: base' );
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

		% prepare bar data
	ux = unique( data.vals(1, :) );
	nux = numel( ux );
	
	ypos = NaN( [1, nux] );
	yneg = NaN( [1, nux] );

	for ui = [1:nux]
		ypos(ui) = mean( data.vals(2, data.fpos & data.vals(1, :) == ux(ui)) );
		yneg(ui) = mean( data.vals(2, ~data.fpos & data.vals(1, :) == ux(ui)) );
	end

		% prepare bar styling
	ux = unique( data.vals(1, :) );
	nux = numel( ux );
	
	huepos = NaN( [1, nux] );
	hueneg = NaN( [1, nux] );

	for ui = [1:nux]
		huepos(ui) = mean( [data.form(data.fpos & data.vals(1, :) == ux(ui)).hue] );
		hueneg(ui) = mean( [data.form(~data.fpos & data.vals(1, :) == ux(ui)).hue] );
	end

		% interleave directions
	x = NaN( [1, 0] );
	w = NaN( [1, 0] );
	y = NaN( [1, 0] );
	hue = NaN( [1, 0] );

	fpos = ~all( isnan( ypos ) );
	fneg = ~all( isnan( yneg ) );

	Q = 0.618;
	W = Q*min( diff( ux ) );
	W2 = W/2;

	if fpos && fneg % bi-directional
		x = [ux-W2/2, ux+W2/2];
		w = repmat( W2, size( x ) );
		base = repmat( base, size( x ) );
		y = [ypos, yneg];
		hue = [huepos, hueneg];

	elseif fpos % mono-directional, positive
		x = ux;
		w = repmat( W, size( x ) );
		base = repmat( base, size( x ) );
		y = ypos;
		hue = huepos;

	elseif fneg % mono-directional, negative
		x = ux;
		w = repmat( W, size( x ) );
		base = repmat( base, size( x ) );
		y = yneg;
		hue = hueneg;

	end

		% plot bars
	fig.axes( hax );

	xp = [x-w/2; x-w/2; x+w/2; x+w/2];
	yp = [base; y; y; base];
	cp = style.color( kron( hue, ones( [1, 4] ) ), style.shademed );

	patch( 'XData', xp, 'YData', yp, 'CData', cp, 'FaceVertexCData', cp, 'FaceColor', 'flat', 'EdgeColor', style.color( NaN, style.shadelo ), 'LineWidth', style.lwthin );

end % function

