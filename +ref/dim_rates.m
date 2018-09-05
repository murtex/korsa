function varargout = dim_rates( varargin )
% rates dimension function
%
% ... = DIM_RATES( ... )
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
				varargout{end+1} = 'rates';
				varargin(1) = [];

			case 'label'
				varargout{end+1} = 'Metronome rate in bpm';
				varargin(1) = [];

			case 'display'
				if numel( varargin ) < 2
					error( 'invalid value: varargin' );
				end

				vals = varargin{2};
				varargin([1, 2]) = [];

				numvals = cellfun( @( v ) sscanf( v, 'bpm%d' ), vals ); % sort by rate value
				numvals(numvals == 0) = Inf; % afap at far end
				[numvals, perm] = sort( numvals );

				vals = arrayfun( @( v ) sprintf( '%d', v ), numvals, 'UniformOutput', false );
				vals(isinf( numvals )) = {'AFAP'};

				varargout{end+1} = vals;
				varargout{end+1} = perm;

			case 'numeric'
				if numel( varargin ) < 2
					error( 'invalid value: varargin' );
				end

				vals = varargin{2};
				varargin([1, 2]) = [];

				numvals = cellfun( @( v ) sscanf( v, 'bpm%d' ), vals ); % sort by rate value
				numvals(numvals == 0) = Inf; % afap at far end
				[numvals, perm] = sort( numvals );

				varargout{end+1} = numvals;
				varargout{end+1} = perm;

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
			case 'bpm30'
				form(vi).symbol = '+';
				form(vi).label = '30 bpm';
				form(vi).hue = 0;
				form(vi).shade = 7/7;
				form(vi).depth = 0/7;

			case 'bpm90'
				form(vi).symbol = 'o';
				form(vi).label = '90 bpm';
				form(vi).hue = 0;
				form(vi).shade = 6/7;
				form(vi).depth = 1/7;

			case 'bpm150'
				form(vi).symbol = '*';
				form(vi).label = '150 bpm';
				form(vi).hue = 0;
				form(vi).shade = 5/7;
				form(vi).depth = 2/7;

			case 'bpm210'
				form(vi).symbol = 'x';
				form(vi).label = '210 bpm';
				form(vi).hue = 0;
				form(vi).shade = 4/7;
				form(vi).depth = 3/7;

			case 'bpm300'
				form(vi).symbol = 's';
				form(vi).label = '300 bpm';
				form(vi).hue = 0;
				form(vi).shade = 3/7;
				form(vi).depth = 4/7;

			case 'bpm390'
				form(vi).symbol = 'd';
				form(vi).label = '390 bpm';
				form(vi).hue = 0;
				form(vi).shade = 2/7;
				form(vi).depth = 5/7;

			case 'bpm480'
				form(vi).symbol = 'p';
				form(vi).label = '480 bpm';
				form(vi).hue = 0;
				form(vi).shade = 1/7;
				form(vi).depth = 6/7;

			case 'bpm570'
				form(vi).symbol = 'h';
				form(vi).label = '570 bpm';
				form(vi).hue = 0;
				form(vi).shade = 0/7;
				form(vi).depth = 7/7;

			case 'bpm0'
				form(vi).symbol = '^';
				form(vi).label = 'AFAP';
				form(vi).hue = 1/2;
				form(vi).shade = 1/2;
				form(vi).depth = 2;

		end
	end
end % function

