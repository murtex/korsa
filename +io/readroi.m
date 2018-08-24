function roi = readroi( filename )
% read region of interest
%
% roi = READROI( filename )
%
% INPUT
% filename : input filename (char)
%
% OUTPUT
% roi : region of interest (numeric)

		% safeguard
	if nargin < 1 || ~ischar( filename )
		error( 'invalid argument: filename' );
	end

		% read roi
	roi = [-Inf, Inf];

	mf = matfile( filename );
	if ismember( 'roi', properties( mf ) )
		roi = mf.roi;
	end

end % function

