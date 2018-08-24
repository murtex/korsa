function movs = genmovs()
% create (empty) movements structure
%
% movs = GENMOVS()
%
% OUTPUT
% movs : empty movements structure (struct)

		% create structure
	movs = struct( ...
		'onset', cell( [1, 0] ), ... % general delimiters
		'peak', cell( [1, 0] ), ...
		'offset', cell( [1, 0] ), ...
		'q', cell( [1, 0] ), ... % q-fraction delimiters
		'qonset', cell( [1, 0] ), ...
		'qoffset', cell( [1, 0] ), ...
		'tags', cell( [1, 0] ), ...
		'fpos', cell( [1, 0] ) );

end % function

