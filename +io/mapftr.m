function ret = mapftr( ftr, fexp, ftrfun, varargin )
% map file compositions
%
% ret = MAPFTR( ftr, fexp, ftrfun, varargin )
%
% INPUT
% ftr : file transfer structure (scalar struct)
% fexp : file composition expansion flags (vector logical)
% fcsfun : target function (function handle)
% ... : additional target function arguments
%
% OUTPUT
% ret : cumulated target function outputs
%
% REMARKS
% - listens to 'io:mapftr:stop' exception to stop mapping

		% safeguard
	if nargin < 1 || ~io.isftr( ftr )
		error( 'invalid argument: ftr' );
	end

	if nargin < 2 || ~isvector( fexp ) || ~islogical( fexp )
		error( 'invalid argument: fexp' );
	end

	if nargin < 3 || ~isa( ftrfun, 'function_handle' )
		error( 'invalid argument: ftrfun' );
	end

	logger = hLogger.instance();

		% expand composition dimensions
	[srctokens, ndims, dims] = expand_( ftr.srcfc, fexp );
	[dsttokens, ndims, dims] = expand_( ftr.dstfc, fexp );

		% map file collection structure
	ret = cell( [1, size( srctokens, 1 )] );

	for i = 1:size( srctokens, 1 )
		ftrtmp = ftr;
		ftrtmp.mapftr = ftr;
		ftrtmp.mapfexp = fexp;
		for j = 1:ndims
			ftrtmp.srcfc.(dims{j}) = srctokens{i, j};
			ftrtmp.dstfc.(dims{j}) = dsttokens{i, j};
		end

		try % call target function
			if nargout( ftrfun ) > 0
				ret{i} = ftrfun( ftrtmp, varargin{:} );
			else
				ftrfun( ftrtmp, varargin{:} );
			end
		catch exception % handle exceptions
			if strcmp( exception.identifier, 'io:mapftr:stop' )
				logger.log( 'successfully received exception ''%s''.', exception.identifier );
				break;
			else
				rethrow( exception );
			end
		end

		if logger.fprogress
			logger.progress( i, size( srctokens, 1 ) );
		end
	end

end % function

	% local functions
function [tokens, ndims, dims] = expand_( fc, fexp )
	dims = fieldnames( fc );
	ndims = numel( dims );

	if numel( fexp ) ~= ndims
		error( 'invalid value: fexp' );
	end

	nsrcvals = cellfun( @( fname ) numel( fc.(fname) ), dims );
	ndstvals = nsrcvals;
	ndstvals(~fexp) = 1;

	tokens = cell( [prod( ndstvals ), ndims] );
	for i = 1:ndims
		tmp1 = {};
		if fexp(i)
			for j = 1:nsrcvals(i)
				tmp1{end+1} = fc.(dims{i})(j);
			end
		else
			tmp1 = {fc.(dims{i})};
		end

		tmp2 = {};
		rep1 = prod( ndstvals(i+1:end) );
		rep2 = prod( ndstvals(1:i-1) );
		for j = 1:ndstvals(i)
			tmp2 = cat( 1, tmp2, repmat( tmp1(j), [rep1, 1] ) );
		end
		tokens(:, i) = repmat( tmp2, [rep2, 1] );
	end
end % function

