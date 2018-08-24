function varargout = decfcol( fcol, fc, varargin )
% decompose file collection
%
% ... = DECFCOL( fcol, fc, ... )
%
% INPUT
% fcol : file collection (cell string)
% fc : file composition (scalar struct)
% ... : composition dimensions (char)
%
% OUTPUT
% ... : composition values (cell string)

		% safeguard
	if nargin < 1 || ~iscellstr( fcol )
		error( 'invalid argument: fcol' );
	end

	if nargin < 2 || ~io.isfcomp( fc )
		error( 'invalid argument: fc' );
	end

		% decompose file collection
	dims = fieldnames( fc );
	tokens = cell( [numel( fcol ), numel( dims )] );
	for f = 1:numel( fcol )
		tokens(f, :) = regexp( fcol{f}, filesep(), 'split' );
	end

		% select output dimensions
	for i = 1:numel( varargin )
		varargout{i} = {};

		li = find( strcmp( varargin{i}, dims ) );
		if ~isempty( li )
			varargout{i} = transpose( unique( tokens(:, li) ) );
		end
	end

end % function

