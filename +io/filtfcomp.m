function fc = filtfcomp( fc, dims, vals, fin )
% filter file composition
%
% fc = FILTFCOMP( fc, dims, vals, fin )
%
% INPUT
% fc : file composition (scalar struct)
% dims : file composition dimensions (cell string)
% vals : file composition values (cell cell string)
% fin : inclusion flag (scalar logical)
%
% OUTPUT
% fc : filtered file composition (scalar struct)
%
% TODO: make fin argument mandatory!

		% safeguard
	if nargin < 1 || ~io.isfcomp( fc )
		error( 'invalid argument: fc' );
	end

	if nargin < 2 || ~iscellstr( dims )
		error( 'invalid argument: dims' );
	end

	if nargin < 3 || ~iscell( vals ) || ~all( cellfun( @iscellstr, vals ) )
		error( 'invalid argument: vals' );
	end

	if nargin < 4
		fin = true;
	end
	if ~isscalar( fin ) || ~islogical( fin )
		error( 'invalid argument: fin' );
	end

		% filter composition
	if fin && numel( dims ) == 0
		fcdims = fieldnames( fc );
		for di = 1:numel( fcdims )
			fc.(fcdims{di}) = {};
		end
	end

	for di = 1:numel( dims )
		if isfield( fc, dims{di} )
			if fin
				fc.(dims{di})(~ismember( fc.(dims{di}), vals{di} )) = [];
			else
				fc.(dims{di})(ismember( fc.(dims{di}), vals{di} )) = [];
			end
		end
	end

end % funciton

