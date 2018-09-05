function varargout = dim_targets( varargin )
% targets dimension function
%
% ... = DIM_TARGETS( ... )
%
% INPUT
% ... : see remarks
%
% OUTPUT
% ... : see remarks
%
% REMARKS
% field : file composition field (char)
% label : display label (char)
% [display, vals] : ordered display values and permutation (cell string, numeric)
% [numeric, vals] : ordered numeric values and permutation (numeric, numeric)
% [form, vals] : ordered display form (struct)

		% parse queries
	varargout = {};

	while numel( varargin ) > 0
		switch varargin{1}
			case 'field'
				varargout{end+1} = 'targets';
				varargin(1) = [];

			case 'label'
				varargout{end+1} = 'targets';
				varargin(1) = [];

			case 'display'
				if numel( varargin ) < 2
					error( 'invalid value: varargin' );
				end

				vals = varargin{2};
				varargin([1, 2]) = [];

				vals = cellfun( @( v ) sprintf( '[%s]', v ), vals, 'UniformOutput', false );
				[vals, perm] = sort( vals );

				varargout{end+1} = vals;
				varargout{end+1} = perm;

			case 'numeric'
				if numel( varargin ) < 2
					error( 'invalid value: varargin' );
				end

				vals = varargin{2};
				varargin([1, 2]) = [];

				varargout{end+1} = NaN( size( vals ) );
				varargout{end+1} = NaN( size( vals ) );

			case 'form'
				if numel( varargin ) < 2
					error( 'invalid value: varargin' );
				end

				vals = varargin{2};
				varargin([1, 2]) = [];

				varargout{end+1} = form_( vals );

			otherwise
				error( 'invalid value: varargin' );
		end
	end

end % function

	% local functions
function form = form_( vals )
	form = struct( 'symbol', {}, 'label', {}, 'hue', {}, 'shade', {}, 'depth', {} );

	for vi = 1:numel( vals )
		form(vi) = struct( 'symbol', {'?'}, 'label', {vals{vi}}, 'hue', {0}, 'shade', {0}, 'depth', {0} );

		switch vals{vi}
		end
	end
end % function

