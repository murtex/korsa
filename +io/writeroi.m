function writeroi( roi, filename )
% write region of interest
%
% WRITEROI( roi, filename )
%
% INPUT
% roi : region of interest (numeric)
% filename : output filename (char)

		% safeguard
	if nargin < 1 || ~isnumeric( roi )
		error( 'invalid argument: roi' );
	end

	if nargin < 2 || ~ischar( filename )
		error( 'invalid argument: filename' );
	end

		% write roi
	if exist( filename, 'file' ) == 2
		s = load( filename, '-mat' );
	end

	s.roi = roi;

	save( filename, '-struct', 's', '-mat', '-v7.3' );
	
end % function

