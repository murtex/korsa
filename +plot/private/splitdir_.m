function data = splitdir_( data, tf )
% split data by direction
%
% data = SPLITDIR_( data, tf )
%
% INPUT
% data : data (cell struct)
%
% OUTPUT
% data : split data cell (struct)

		% safeguard
	if nargin < 1 || ~iscell( data ) || ~all( cellfun( @( d ) isstruct( d ), data(:) ) )
		error( 'invalid argument: data' );
	end

		% split data by direction
	shape = size( data );

	for dx = 1:shape(1)
		for dy = 1:shape(2)
			for di = 1:numel( data{dx, dy} )
				f = data{dx, dy}(di).fpos == tf;

				data{dx, dy}(di).fpos = data{dx, dy}(di).fpos(f);
				data{dx, dy}(di).vals = data{dx, dy}(di).vals(:, f);
				data{dx, dy}(di).form = data{dx, dy}(di).form(f);
			end
		end
	end

end % function

