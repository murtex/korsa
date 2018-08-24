function writewav( data, rate, filename )
% write wave file
%
% WRITEWAV( data, rate, filename )
%
% INPUT
% data : sample data (matrix numeric)
% rate : sampling rate (scalar numeric)
% filename : output filename (char)
%
% TODO: implement wavwrite/audiowrite compatibility!

		% safeguard
	if nargin < 1 || ~ismatrix( data ) || ~isnumeric( data )
		error( 'invalid argument: data' );
	end

	if nargin < 2 || ~isscalar( rate ) || ~isnumeric( rate )
		error( 'invalid argument: rate' );
	end

	if nargin < 3 || ~ischar( filename )
		error( 'invalid argument: filename' );
	end

		% write wave file
	if exist( 'audiowrite', 'file' ) == 2
		audiowrite( filename, data, rate );
	else
		wavwrite( data, rate, filename );
	end
	
end % function

