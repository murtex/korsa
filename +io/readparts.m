function varargout = readparts( filename, parts )
% read data parts
%
% ... = READPARTS( filename, parts )
%
% INPUT
% filename : data filename (char)
% parts : data parts [sig, info, roi, movs] (cell string)
%
% OUTPUT
% ... : data (cell)

		% safeguard
	if nargin < 1 || ~ischar( filename )
		error( 'invalid argument: filename' );
	end

	if nargin < 2 || ~io.isparts( parts )
		error( 'invalid argument: parts' );
	end

	logger = hLogger.instance();

		% read parts
	varargout = {};

	for pj = 1:numel( parts )
		switch parts{pj}
			case 'sig'
				logger.log( 'read signal ''%s''..', filename );
				varargout{end+1} = io.readnsig( filename );
			case 'info'
				logger.log( 'read info ''%s''..', filename );
				varargout{end+1} = io.readinfo( filename );
			case 'roi'
				logger.log( 'read roi ''%s''..', filename );
				varargout{end+1} = io.readroi( filename );
			case 'movs'
				logger.log( 'read movements ''%s''..', filename );
				varargout{end+1} = io.readmovs( filename );
			otherwise
				error( 'invalid value: parts' );
		end
	end

end % function

