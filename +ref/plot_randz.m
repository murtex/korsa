function hld = plot_randz( fig, hax, data, dist )
% randomize plot z-data
%
% PLOT_RANDZ( fig, hax, data, dist )
%
% INPUT
% fig : figure reference (scalar object)
% hax : axes handle (scalar handle)
% data : data (struct)
% dist : z-data distance (numeric scalar)
%
% OUTPUT
% hld : handles for the legend (TODO)

		% safeguard
	if nargin < 1 || ~isscalar( fig ) || ~isa( fig, 'hFigure' )
		error( 'invalid argument: fig' );
	end

	if nargin < 2 || ~isscalar( hax )% || ~ishandle( hax )
		error( 'invalid argument: hax' );
	end

	if nargin < 3 || ~isstruct( data )
		error( 'invalid argument: data' );
	end

	if nargin < 4 || ~isnumeric( dist ) || ~isscalar( dist )
		error( 'invalid argument: dist' );
	end

	hld = [];

		% randomize z-data
	hobj = findall( hax );

	for hi = [1:numel( hobj )]
		if ~strcmp( 'patch', get( hobj(hi), 'Type' ) )
			continue;
		end

		z = get( hobj(hi), 'ZData' );
		z = z+(rand( size( z ) )-1/2)*(0.9*dist);
		set( hobj(hi), 'ZData', z );
	end

end % function

