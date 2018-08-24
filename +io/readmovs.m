function movs = readmovs( filename )
% read movements structure
%
% movs = READMOVS( filename )
%
% INPUT
% filename : input filename (char)
%
% OUTPUT
% movs : movements structure (struct)

		% safeguard
	if nargin < 1 || ~ischar( filename )
		error( 'invalid argument: filename' );
	end

	logger = hLogger.instance();

		% read movements
	movs = io.genmovs();

	mf = matfile( filename );
	if ismember( 'movs', properties( mf ) )
		movs = mf.movs;
	end

		% TODO: there were some movements missing the fpos field in the database!
	if ~io.ismovs( movs )
		logger.warn( 'errornous movement in file ''%s''...', filename );

		if numel( movs ) == 0 % try to fix the problem temporarily
			movs = io.genmovs();
		else
			error( 'invalid value: movs' );
		end
	end

end % function

