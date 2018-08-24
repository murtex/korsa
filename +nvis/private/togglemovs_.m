function movs = togglemovs_( hfig, movs )
% toggle movement tags
%
% movs = TOGGLEMOVS_( hfig, movs )
%
% INPUT
% hfig : figure handle (TODO)
% movs : movements (struct)
%
% OUTPUT
% mov : movement structure (scalar struct)

		% safeguard
	if nargin < 1
		error( 'invalid argument: hfig' );
	end

	if nargin < 2 || ~io.ismovs( movs )
		error( 'invalid argument: movs' );
	end

		% toggle tags
	gdata = getappdata( hfig, 'gdata' );

	for mi = 1:numel( movs )
		sel = ismember( movs(mi).tags, gdata.filtsel );
		if any( sel )
			movs(mi).tags(sel) = [];
		else
			movs(mi).tags(end+1:end+numel( gdata.filtsel )) = gdata.filtsel;
		end
	end

end % function

