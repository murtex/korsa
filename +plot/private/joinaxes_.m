function [data, raxd, daxd, props] = joinaxes_( data, raxd, daxd, opts )
% inject joint axes
%
% [data, raxd, daxd, props] = JOINAXES_( data, raxd, daxd, opts )
%
% INPUT
% data : data (cell struct)
% raxd : raw axes description (struct)
% daxd : derived axes description (struct)
% opts : panel options (cell string)
%
% OUTPUT
% data : data (cell struct)
% raxd : raw axes description (struct)
% daxd : derived axes description (struct)
% props : general axes properties (cell)

		% safeguard
	if nargin < 1 || ~iscell( data ) || ~all( cellfun( @( d ) isstruct( d ), data(:) ) )
		error( 'invalid argument: data' );
	end

	if nargin < 2 || ~isstruct( raxd )
		error( 'invalid argument: raxd' );
	end

	if nargin < 3 || ~isstruct( daxd )
		error( 'invalid argument: daxd' );
	end

	if nargin < 4 || ~iscellstr( opts )
		error( 'invalid argument: opts' );
	end

		% inject axes descriptions
	props = {};

	shape = size( data );
	joint = parseopts2_( opts, 'joint' );

	if ismember( 'x', joint{1} ) % horizontal
		daxd = [raxd(1), daxd];
		% props = [props, 'XGrid', 'off'];
	end
	if ismember( 'y', joint{1} )
		daxd = [daxd(1), raxd(1), daxd(2:end)];
		% props = [props, 'YGrid', 'off'];
	end
	if ismember( 'z', joint{1} )
		daxd = [daxd(1:2), raxd(1), daxd(3:end)];
		% props = [props, 'ZGrid', 'off'];
	end

	if ismember( 'x', joint{2} ) % vertical
		daxd = [raxd(2), daxd];
		% props = [props, 'XGrid', 'off'];
	end
	if ismember( 'y', joint{2} )
		daxd = [daxd(1), raxd(2), daxd(2:end)];
		% props = [props, 'YGrid', 'off'];
	end
	if ismember( 'z', joint{2} )
		daxd = [daxd(1:2), raxd(2), daxd(3:end)];
		% props = [props, 'ZGrid', 'off'];
	end

		% inject data
	for dx = 1:shape(1)
		for dy = 1:shape(2)
			if isempty( data{dx, dy} )
				continue;
			end

			if ismember( 'x', joint{1} ) % horizontal
				data{dx, dy}.vals = [zeros( [1, size( data{dx, dy}.vals, 2 )] )+daxd(1).ticks(dx); data{dx, dy}.vals];
			end
			if ismember( 'y', joint{1} )
				data{dx, dy}.vals = [data{dx, dy}.vals(1, :); zeros( [1, size( data{dx, dy}.vals, 2 )] )+daxd(2).ticks(dx); data{dx, dy}.vals(2:end, :)];
			end
			if ismember( 'z', joint{1} )
				data{dx, dy}.vals = [data{dx, dy}.vals(1:2, :); zeros( [1, size( data{dx, dy}.vals, 2 )] )+daxd(3).ticks(dx); data{dx, dy}.vals(3:end, :)];
			end

			if ismember( 'x', joint{2} ) % vertical
				data{dx, dy}.vals = [zeros( [1, size( data{dx, dy}.vals, 2 )] )+daxd(1).ticks(dy); data{dx, dy}.vals];
			end
			if ismember( 'y', joint{2} )
				data{dx, dy}.vals = [data{dx, dy}.vals(1, :); zeros( [1, size( data{dx, dy}.vals, 2 )] )+daxd(2).ticks(dy); data{dx, dy}.vals(2:end, :)];
			end
			if ismember( 'z', joint{2} )
				data{dx, dy}.vals = [data{dx, dy}.vals(1:2, :); zeros( [1, size( data{dx, dy}.vals, 2 )] )+daxd(3).ticks(dy); data{dx, dy}.vals(3:end, :)];
			end
		end
	end

end % function

