function writeparts( filename, parts, varargin )
% write data parts
%
% WRITEPARTS( filename, parts, ... )
%
% INPUT
% filename : data filename (char)
% parts : data parts [sig, info, roi, movs] (cell string)
% ... : data (cell)

		% safeguard
	if nargin < 1 || ~ischar( filename )
		error( 'invalid argument: filename' );
	end

	if nargin < 2 || ~iscellstr( parts )
		error( 'invalid argument: parts' );
	end

	if numel( varargin ) ~= numel( parts )
		error( 'invalid argument: ...' );
	end

	logger = hLogger.instance();

		% write data parts
	for pj = 1:numel( parts )
		switch parts{pj}
			case 'sig'
				logger.tablog( 'write signal ''%s''..', filename );
				io.writensig( varargin{pj}, filename );
			case 'info'
				logger.tablog( 'write info ''%s''..', filename );
				io.writeinfo( varargin{pj}, filename );
			case 'roi'
				logger.tablog( 'write roi ''%s''..', filename );
				io.writeroi( varargin{pj}, filename );
			case 'movs'
				logger.tablog( 'write movements ''%s''..', filename );
				io.writemovs( varargin{pj}, filename );
			otherwise
				error( 'invalid value: parts' );
		end
	end

end % function

