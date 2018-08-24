function [data, rate] = readwav( filename )
% read wave file
%
% INPUT
% filename : input filename (char)
%
% OUTPUT
% data : sample data (matrix numeric)
% rate : sampling rate (scalar numeric)
%
% TODO: implement wavread/audioread compatibility!

		% safeguard
	if nargin < 1 || ~ischar( filename )
		error( 'invalid argument: filename' );
	end

		% read wave file
	if exist( 'audioread', 'file' ) == 2
		[data, rate] = audioread( filename );
		data = transpose( data );
	else
		[data, rate] = wavread( filename );
		data = transpose( data );
	end

end % function

