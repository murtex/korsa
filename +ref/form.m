function form = form( fcol, fc, fpos, formargs )
% form data
%
% form = FORM()
% form = FORM( fcol, fc, fpos, formargs )
%
% INPUT
% fcol : file collection (cell string)
% fc : file composition (scalar struct)
% fpos : movement direction (logcial)
% formargs : form arguments (cell)

		% safeguard
	if nargin == 0
		form = struct( 'symbol', {}, 'label', {}, 'hue', {}, 'shade', {}, 'depth', {} );
		return;
	end

	if nargin < 1 || ~iscellstr( fcol )
		error( 'invalid argument: fcol' );
	end

	if nargin < 2 || ~isscalar( fc ) || ~io.isfcomp( fc )
		error( 'invalid argument: fc' );
	end

	if nargin < 3 || ~islogical( fpos )
		error( 'invalid argument: fpos' );
	end

	if nargin < 4 || ~iscell( formargs )
		error( 'invalid argument: formargs' );
	end

		% symbol and label
	dim = formargs{1}( 'field' );
	if ismember( dim, fieldnames( fc ) )
		cform{1} = formargs{1}( 'form', io.decfcol( fcol, fc, dim ) );
	else
		cform{1} = formargs{1}( 'form', {dim} );
	end
	cform{1} = unique_( cform{1} );

		% color and depth
	dim = formargs{2}( 'field' );
	if ismember( dim, fieldnames( fc ) )
		cform{2} = formargs{2}( 'form', io.decfcol( fcol, fc, dim ) );
	else
		cform{2} = formargs{2}( 'form', {dim} );
	end
	cform{2} = unique_( cform{2} );

		% pack and adjust by movement direction
	form.symbol = cform{1}.symbol;
	form.label = cform{1}.label;
	form.hue = cform{2}.hue;
	form.shade = shade_( cform{2}.shade );
	form.depth = cform{2}.depth;

	form = repmat( form, [1, numel( fpos )] );
	for fi = 1:numel( fpos )
		form(fi).hue = ~fpos(fi)/2+form(fi).hue;
	end

end % function

	% local functions
function shade = shade_( shade )
	style = hStyle.instance();
	shade = shade*(style.shadehi-style.shadelo)+style.shadelo;
end % function

function uform = unique_( form )
	symbol = unique( [form.symbol], 'stable' );
	label = unique( {form.label}, 'stable' );
	hue = unique( [form.hue], 'stable' );
	shade = unique( [form.shade], 'stable' );
	depth = unique( [form.depth], 'stable' );

	uform.symbol = symbol(1);
	uform.label = label{1};
	uform.hue = hue(1);
	uform.shade = shade(1);
	uform.depth = depth(1);
end % function

