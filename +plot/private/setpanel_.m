function hax = setpanel_( fig, opts, foffs, data, dshape, daxd, raxd, props )
% create panel axes
%
% hax = SETPANEL_( fig, opts, foffs, data, dshape, daxd, raxd, props )
%
% INPUT
% fig : figure reference (scalar object)
% opts : panel options (cell string)
% foffs : direction split offset flag (scalar logical)
% data : data (cell struct)
% dshape : original data shape (numeric)
% daxd : derived axes description (struct)
% raxd : raw axes description (struct)
% props : axes properties (cell)
%
% OUTPUT
% hax : panel axes (handle)

		% safeguard
	if nargin < 1 || ~isscalar( fig ) || ~isa( fig, 'hFigure' )
		error( 'invalid argument: fig' );
	end

	if nargin < 2 || ~iscellstr( opts )
		error( 'invalid argument: opts' );
	end

	if nargin < 3 || ~isscalar( foffs ) || ~islogical( foffs )
		error( 'invalid argument: foffs' );
	end

	if nargin < 4 || ~iscell( data ) || ~all( cellfun( @( d ) isstruct( d ), data(:) ) )
		error( 'invalid argument: data' );
	end

	if nargin < 5 || ~isnumeric( dshape ) || numel( dshape ) ~= 2
		error( 'invalid argument: dshape' );
	end

	if nargin < 6 || ~isstruct( daxd )
		error( 'invalid argument: daxd' );
	end

	if nargin < 7 || ~isstruct( raxd )
		error( 'invalid argument: raxd' );
	end

	if nargin < 8 || ~iscell( props )
		error( 'invalid argument: props' );
	end

	logger = hLogger.instance();
	style = hStyle.instance();

		% create panel axes
	[fsplit, fjoint, fover, joint, scale, split, labpos] = parseopts2_( opts, 'fsplit', 'fjoint', 'fover', 'joint', 'scale', 'split', 'labpos' );

	shape = size( data );
	sshape = (fsplit+1).*shape;

	logger.progress( 'create panel axes...' );

	for dx = 1:shape(1)
		for dy = 1:shape(2)
			sx = dx+foffs*fsplit(1)*shape(1);
			sy = dy+foffs*fsplit(2)*shape(2);

				% adjust tick labels (joint axes)
			cprops = props;

			if numel( daxd ) > 0 && (ismember( 'x', [joint{:}] ) || (~ismember( 'x', [joint{:}] ) && ~isempty( daxd(1).ticks )))
				cprops(end+[1:4]) = {'XTick', daxd(1).ticks, 'XTickLabel', daxd(1).ticklabels};
			end
			if numel( daxd ) > 1 && (ismember( 'y', [joint{:}] ) || (~ismember( 'y', [joint{:}] ) && ~isempty( daxd(2).ticks )))
				cprops(end+[1:4]) = {'YTick', daxd(2).ticks, 'YTickLabel', daxd(2).ticklabels};
			end
			if numel( daxd ) > 2 && (ismember( 'z', [joint{:}] ) || (~ismember( 'z', [joint{:}] ) && ~isempty( daxd(3).ticks )))
				cprops(end+[1:4]) = {'ZTick', daxd(3).ticks, 'ZTickLabel', daxd(3).ticklabels};
			end

				% adjust tick labels visibility (axes scale), TODO: z-axis!
			if ismember( 'absx', scale{2} ) || shape(2) == 1
				if dy ~= shape(2) || (fsplit(2) && ismember( 'absx', split ) && sy ~= sshape(2))
					cprops(end+[1:2]) = {'XTickLabel', {}};
				end
			end
			if ismember( 'absy', scale{1} ) || shape(1) == 1
				if dx ~= 1 || (fsplit(1) && ismember( 'absy', split ) && sx ~= 1)
					cprops(end+[1:2]) = {'YTickLabel', {}};
				end
			end

				% adjust general visibility (empty/nan data)
			if isempty( data{dx, dy} ) || isempty( [data{dx, dy}.vals] ) || any( all( transpose( isnan( [data{dx, dy}.vals] ) ) ) )
				if ~style.fmono
					cprops(end+[1:2]) = {'Color', style.background};
				end
			end

				% create axis
			hax(dx, dy) = fig.subplot( sshape(2), sshape(1), (sy-1)*sshape(1)+(sx-1)+1, cprops{:} );

				% set axes labels
			if numel( daxd ) > 0 && sy == sshape(2)
				fig.xlabel( daxd(1).label );
			end
			if numel( daxd ) > 1 && sx == 1
				fig.ylabel( daxd(2).label );
			end
			if numel( daxd ) > 2
				fig.zlabel( daxd(3).label );
			end

				% set panel label
			[ddx, ddy] = ind2sub( dshape, sub2ind( shape, dx, dy ) );

			%if ddx == dshape(1) || ddy == 1
				labx = '';
				if dshape(1) > 1
					labx = raxd(1).ticklabels{ddx};
				end
				laby = '';
				if dshape(2) > 1
					laby = raxd(2).ticklabels{ddy};
				end

				lab = util.chainstr( ', ', labx, laby );
				if ~isempty( lab )
					fig.plabel( 0.07, labpos, sprintf( '(%s)', lab ), 'FontSize', style.fssmall );
					%fig.plabel( 0.02, labpos, lab, 'FontSize', 0.9*style.fsnorm ); % DFG3
				end
			%end

			logger.progress( (dx-1)*shape(2)+dy, numel( data ) );
		end
	end

end % function

