function fcol = genfcol( fc )
% create file collection
%
% fcol = GENFCOL( fc )
%
% INPUT
% fc : file composition (struct)
%
% OUTPUT
% fcol : file collection (cell string)

		% safeguard
	if nargin < 1 || ~io.isfcomp( fc )
		error( 'invalid argument: fc' );
	end

		% create file collection
	dims = fieldnames( fc );
	ndims = numel( dims );
	nvals = cellfun( @( fname ) numel( fc.(fname) ), dims );

	if any( nvals == 0 )
		fcol = {};
		return;
	end

	tokens = cell( [prod( nvals ), ndims] );
	for i = 1:ndims
		tmp = {};
		rep1 = prod( nvals(i+1:end) );
		rep2 = prod( nvals(1:i-1) );
		for j = 1:nvals(i)
			tmp = cat( 1, tmp, repmat( fc.(dims{i})(j), [rep1, 1] ) );
		end
		tokens(:, i) = repmat( tmp, [rep2, 1] );
	end

	fcol = cell( [prod( nvals ), 1] );
	for i = 1:prod( nvals )
		fcol{i} = fullfile( tokens{i, :} );
	end

end % function

