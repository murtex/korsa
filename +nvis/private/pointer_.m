function [h, p] = pointer_( hfig )
% get pointer location
%
% [h, p] = POINTER_( hfig )
%
% INPUT
% hfig : figure handle (TODO)
%
% OUTPUT
% h : axes handle (TODO)
% p : pointer location (numeric)

		% safeguard
	if nargin < 1
		error( 'invalid argument: hfig' );
	end

		% get pointer location
	h = gco( hfig );
	while ~isempty( h ) && ~strcmp( 'axes', get( h, 'Type' ) )
		h = get( h, 'Parent' );
	end

	p = get( h, 'CurrentPoint' );
	
	if isempty( p )
		p = NaN( [1, 3] );
	else
		p = p(1, :);
	end

end % function

