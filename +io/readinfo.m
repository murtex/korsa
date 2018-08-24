function info = readinfo( filename )
% read signal information
%
% info = READINFO( filename )
%
% INPUT
% filename : input filename (char)
%
% OUTPUT
% info : signal information structure (scalar object)

		% safeguard
	if nargin < 1 || ~ischar( filename )
		error( 'invalid argument: filename' );
	end

		% read info
	info = io.geninfo();

	mf = matfile( filename );
	if ismember( 'info', properties( mf ) )
		info = mf.info;
	end

		% DEBUG: compatibility
	if ~isfield( info, 'layout' )
		info.layout = struct();
	end

end % function

