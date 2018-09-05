function hld = plot_const( fig, hax, data, const, varargin )
% plot constant
%
% hld = PLOT_CONST( fig, hax, data, const, ... )
%
% INPUT
% fig : figure reference (scalar object)
% hax : axes handle (scalar handle)
% data : data (struct)
% const : constant (numeric scalar)
% .. : additional arguments
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

	if nargin < 4 || ~isnumeric( const ) || ~isscalar( const )
		error( 'invalid argument: const' );
	end

	style = hStyle.instance();

	hld = [];

		% plot constant
	fig.axes( hax );
	xl = get( hax, 'XLim' );

	xp = [xl, NaN];
	yp = repmat( const, size( xp ) );

	h = patch( 'XData', xp, 'YData', yp, 'FaceColor', 'none', varargin{:} );
	uistack( h, 'bottom' );

end % function

