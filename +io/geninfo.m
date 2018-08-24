function info = geninfo()
% create (empty) signal information structure
%
% info = GENINFO()
%
% OUTPUT
% info : signal information structure (scalar struct)

		% create structure
	info = struct( ...
		'trial', {}, ...
		'sweep', {}, ...
		'layout', {} );

end % function

