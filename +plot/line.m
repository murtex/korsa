function hld = line( fig, hax, data, varargin )
% line plot
%
% hld = LINE( fig, hax, data, ... )
%
% INPUT
% fig : figure reference (scalar object)
% hax : axes handle (scalar handle)
% data : data (struct)
% ... : additional arguments
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

		% proceed data
	fig.axes( hax );

	for di = [1:numel( data )]
		form = [data(di).form];

			% proceed symbols
		sym = [form.symbol];
		usym = unique( sym );

		for si = [1:numel( usym )]
			fsym = ismember( sym, usym(si) );
			lab = unique( {form(fsym).label} );

			if numel( lab ) ~= 1
				error( 'invalid value: lab' );
			end
			lab = lab{1};

				% line plot (per direction)
			for fpos = [true, false]
				fsymp = fsym & (data(di).fpos == fpos);

				x = [data(di).vals(1, fsymp), NaN];
				y = [data(di).vals(2, fsymp), NaN];
				z = [form(fsymp).depth, NaN];
				c = [style.color( [form(fsymp).hue], [form(fsymp).shade] ); NaN( [1, 3] )];

				hld = line_legend_( hld, usym(si), lab, x, y, z, c );
				line_( usym(si), x, y, z, c, varargin{:} );
			end
		end
	end

end % function

	% local functions
function hld = line_legend_( hld, sym, lab, x, y, z, c )
	style = hStyle.instance();

	if isempty( y(~isnan( y )) ) % TODO: possibly miss legend entries because of further data in other cells!
		return;
	end

	if strcmp( '?', sym ) % default
		ms = {'LineWidth', style.lwthin, 'Marker', 'o', 'MarkerEdgeColor', c(1, :), 'MarkerFaceColor', 'none', 'MarkerSize', style.mssmall};
	else % user
		ms = {'LineWidth', style.lwthin, 'Marker', sym, 'MarkerEdgeColor', style.color( NaN, style.shadelo ), 'MarkerFaceColor', c(1, :), 'MarkerSize', style.mslarge};
	end

	ls = {'LineStyle', 'none', 'DisplayName', lab, 'HandleVisibility', 'on'};
	hld = [hld, line( 'XData', x, 'YData', y, 'ZData', z, ls{:}, ms{:} )];
end % function

function line_( sym, x, y, z, c, varargin )
	style = hStyle.instance();

	if strcmp( '?', sym )
		ms = {'LineWidth', style.lwnorm, 'Marker', 'o', 'MarkerEdgeColor', 'flat', 'MarkerFaceColor', 'none', 'MarkerSize', style.mssmall};
	else
		ms = {'LineWidth', style.lwthin, 'Marker', sym, 'MarkerEdgeColor', style.color( NaN, style.shadelo ), 'MarkerFaceColor', 'flat', 'MarkerSize', style.mslarge};
	end

	ps = {'FaceColor', 'none', 'EdgeColor', 'interp', 'LineWidth', style.lwnorm, 'HandleVisibility', 'off'};
	patch( 'XData', x, 'YData', y, 'ZData', z, 'CData', c, 'FaceVertexCData', c, ps{:}, varargin{:} );

	ps = {'FaceColor', 'none', 'EdgeColor', 'none', 'HandleVisibility', 'off'};
	patch( 'XData', x, 'YData', y, 'ZData', z+1/10, 'CData', c, 'FaceVertexCData', c, 'HandleVisibility', 'off', ps{:}, ms{:}, varargin{:} );
end % function

