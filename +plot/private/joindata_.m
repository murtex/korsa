function jdata = joindata_( j0data, data, x, y, opts )
% join data based upon panel options
%
% jdata = JOINDATA_( j0data, data, x, y, opts )
%
% INPUT
% j0data : joint data initialization (scalar struct)
% data : primary data (cell struct)
% x : horizontal data index (scalar numeric)
% y : horizontal data index (scalar numeric)
% opts : panel options (cell string)
%
% OUTPUT
% jdata : joint data (struct)
%
% REMARKS
% - true axes joins {x, y, z} cat data column-wise
% - color axes joins (overlays) {c} cat data row-wise

		% safeguard
	if nargin < 1 || ~isscalar( j0data ) || ~isstruct( j0data )
		error( 'invalid argument: j0data' );
	end

	if nargin < 2 || ~iscell( data ) || ~all( cellfun( @( d ) isstruct( d ), data(:) ) )
		error( 'invalid argument: data' );
	end

	if nargin < 3 || ~isscalar( x ) || ~isnumeric( x )
		error( 'invalid argument: x' );
	end

	if nargin < 4 || ~isscalar( y ) || ~isnumeric( y )
		error( 'invalid argument: y' );
	end

	if nargin < 5 || ~iscellstr( opts )
		error( 'invalid argument: opts' );
	end

		% join data
	shape = size( data );
	ndaxes = size( j0data.vals, 1 );

	[fjoint, fover] = parseopts2_( opts, 'fjoint', 'fover' );

	if ~any( fjoint ) && ~any( fover ) % singular cell
		jdata = join_( j0data, data{x, y} );

	elseif all( fjoint ) % full cat
		jdata = j0data;
		for di = 1:numel( data )
			jdata = join_( jdata, data{di} );
		end

	elseif fjoint(1) || (~fover(1) && fover(2)) % horizontal cat
		dys = y;
		if fover(2)
			dys = 1:shape(2);
		end
		for dy = dys
			jdata(dy-dys(1)+1) = j0data;

			dxs = x;
			if fjoint(1)
				dxs = 1:shape(1);
			end
			for dx = dxs
				jdata(dy-dys(1)+1) = join_( jdata(dy-dys(1)+1), data{dx, dy} );
			end
		end

	elseif fjoint(2) || (fover(1) && ~fover(2)) % vertical cat
		dxs = x;
		if fover(1)
			dxs = 1:shape(1);
		end
		for dx = dxs
			jdata(dx-dxs(1)+1) = j0data;

			dys = y;
			if fjoint(2)
				dys = 1:shape(2);
			end
			for dy = dys
				jdata(dx-dxs(1)+1) = join_( jdata(dx-dxs(1)+1), data{dx, dy} );
			end
		end

	elseif all( fover ) % full split
		for di = 1:numel( data )
			jdata(di) = join_( j0data, data{di} );
		end
	end

end % function

	% local functions
function jdata = join_( jdata, data )
	if isempty( data )
		return;
	end

	jdata.fcol = [jdata.fcol; data.fcol];
	jdata.fc = io.joinfcomp( jdata.fc, data.fc );
	jdata.fpos = [jdata.fpos, data.fpos];
	jdata.vals = [jdata.vals, data.vals];
	jdata.form = [jdata.form, data.form];
end % function

