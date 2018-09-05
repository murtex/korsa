function varargout = parseopts2_( opts, varargin )
% parse panel options
%
% ... = PARSEOPT2_( opts, ... )
%
% INPUT
% opts : panel options (cell string)
% ... : options to parse (char)
%
% OUTPUT
% ... : parsed option values

		% safeguard
	if nargin < 1 || ~iscellstr( opts )
		error( 'invalid argument: opts' );
	end

		% parse options
	varargout = {};

	for vi = [1:numel( varargin )]
		clear( 'val' );

		if ~ischar( varargin{vi} )
			error( 'invalid value: ...' );
		end

		switch varargin{vi}
			case 'fsplit' % split flags [horizontal, vertical] (logical)
				val = [ismember( 'hsplit', opts ), ismember( 'vsplit', opts )];
				if all( val )
					error( 'invalid value: fsplit' );
				end

			case 'legend' % legend description [h, v] (cell string)
				val = unique( postfix_( opts, 'legend', '' ) );
				if numel( val ) > 1
					error( 'invalid value: legend' );
				end

			case 'labpos' % label position [tl, tr, bl, br] (char)
				val = unique( opts(cellfun( @( opt ) ismember( opt, {'tl', 'tr', 'bl', 'br'} ), opts )) );
				if numel( val ) > 1
					error( 'invalid value: labpos' );
				elseif numel( val ) == 0
					val = {'tl'};
				end
				val = val{1};

			case 'joint' % joint description [horizontal, vertical], [x, y, z, c] (cell)
				val{1} = unique( postfix_( opts, 'hjoint', '' ) );
				val{2} = unique( postfix_( opts, 'vjoint', '' ) );

			case 'fjoint' % true axes joint flags [horizontal, vertical] (logical)
				joint = parseopts2_( opts, 'joint' );
				val = [any( ismember( {'x', 'y', 'z'}, joint{1} ) ), any( ismember( {'x', 'y', 'z'}, joint{2} ) )];

			case 'fover' % color axes joint (overlays) flags [horizontal, vertical] (logical)
				joint = parseopts2_( opts, 'joint' );
				val = [ismember( 'c', joint{1} ), ismember( 'c', joint{2} )];

			case 'feven' % even axes flag (scalar logical)
				val = ismember( 'even', opts );

			case 'scale' % scale description [horizontal, vertical] [abs, rel, even], [x, y, z] (cell)
				val{1} = [unique( postfix_( opts, 'habs', 'abs' ) ), unique( postfix_( opts, 'hrel', 'rel' ) ), unique( postfix_( opts, 'heven', 'even' ) )];
				val{2} = [unique( postfix_( opts, 'vabs', 'abs' ) ), unique( postfix_( opts, 'vrel', 'rel' ) ), unique( postfix_( opts, 'veven', 'even' ) )];

			case 'split' % split scale description [abs, rel, even] [x, y, z] (cell string)
				val = [unique( postfix_( opts, 'sabs', 'abs' ) ), unique( postfix_( opts, 'srel', 'rel' ) ), unique( postfix_( opts, 'seven', 'even' ) )];

			otherwise
				error( 'invalid value: opt' );
		end

		varargout{end+1} = val;
	end

end % function

	% local functions
function pf = postfix_( opts, base, prefix )
	pf = {};
	for oi = [1:numel( opts )]
		if strfind( opts{oi}, base ) == 1
			pf{end+1} = strcat( prefix, opts{oi}(numel( base )+1:end) );
		end
	end
end % function

