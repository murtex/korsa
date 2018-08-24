function parts = valparts( parts )
% validate signal part names
%
% parts = VALPARTS( parts )
%
% INPUT
% parts : signal part names (cell string)
%
% OUTPUT
% parts : validated signal part names (cell string)

		% safeguard
	if nargin < 1 || ~iscellstr( parts )
		error( 'invalid argument: parts' );
	end

		% validate names
	parts(~ismember( parts, {'sig', 'info', 'roi', 'movs'} )) = [];

end % function

