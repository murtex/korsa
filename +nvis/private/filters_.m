function [filtin, filtex, filtsel] = filters_( hfig )
% edit tag filters
%
% FILTERS_( hfig )
%
% INPUT
% hfig : figure handle (TODO)
%
% OUTPUT
% filtin : tag inclusion filter (cell string)
% filtex : tag exclusion filter (cell string)

		% safeguard
	if nargin < 1
		error( 'invalid argument: hfig' );
	end

		% show filter dialog
	gdata = getappdata( hfig, 'gdata' );

	filtin = gdata.filtin;
	filtex = gdata.filtex;
	filtsel = gdata.filtsel;

	prompt = {'show:', 'hide:', 'select:'};
	filters = {util.any2str( filtin ), util.any2str( filtex ), util.any2str( filtsel )};
	filters = inputdlg( prompt, 'nvis:filters', 1, filters );

		% parse input
	if ~isempty( filters )
		try
			filtin = eval( filters{1} );
			filtex = eval( filters{2} );
			filtsel = eval( filters{3} );
		catch
			msgbox( 'invalid input, edit again!', 'nvis:filters', 'warn', 'modal' );
		end
	end

end % function

