function [adata, edata, gdata] = setpanels_( adata, edata, gdata, fpanel, titlefun )
% create figure panels
%
% [adata, edata, gdata] = SETPANELS_( adata, edata, gdata, fpanel, titlefun )
%
% INPUT
% adata : audio data structure (scalar struct)
% edata : ema data structure (scalar struct)
% gdata : general data structure (scalar struct)
% fpanel : panel flags [detail, portrait] (logical)
% titlefun : title function (function handle)
%
% OUTPUT
% adata : audio data structure (scalar struct)
% edata : ema data structure (scalar struct)
% gdata : general data structure (scalar struct)

		% safeguard
	if nargin < 1
		error( 'invalid argument: adata' );
	end

	if nargin < 2
		error( 'invalid argument: edata' );
	end

	if nargin < 3
		error( 'invalid argument: gdata' );
	end

	if nargin < 4 || numel( fpanel ) ~= 3 || ~islogical( fpanel )
		error( 'invalid argument: fpanel' );
	end

	if nargin < 5 || ~isa( titlefun, 'function_handle' )
		error( 'invalid argument: titlefun' );
	end

	fig = gdata.fig;

		% adjust flags
	gdata.faudio = numel( adata.sigs ) > 0 & numel( adata.ibase ) > 0;
	gdata.fema = numel( edata.sigs ) > 0 & numel( edata.ch ) > 0;
	gdata.fdetail = gdata.fema & fpanel(1);
	gdata.fcart = gdata.fema & fpanel(2) & numel( edata.sigs ) == 2; % TODO: 3d?
	gdata.fportrait = gdata.fema & fpanel(3) & numel( edata.iport ) > 0;

		% prepare grid layout
	naudiorows = gdata.faudio*numel( adata.sigs );
	nmainrows = gdata.fema*numel( edata.ch );
	ncartrows = gdata.fcart*numel( edata.ch );
	nportrows = gdata.fportrait*numel( edata.iport );

	millerrows = [1, 2]; % [audio, ema]
	millercols = [1, 3, 1, 1, 1]; % [ldet, main, rdet, cart, port]

	facmain = 1;
	facport = 1;
	if nmainrows > 0 && nportrows > 0
		facmain = lcm( nmainrows, nportrows )/nmainrows;
		facport = lcm( nmainrows, nportrows )/nportrows;
	end

	audiorows = repmat( millerrows(1)*facmain, [1, naudiorows] );
	mainrows = repmat( millerrows(2)*facmain, [1, nmainrows] );
	cartrows = repmat( millerrows(2)*facmain, [1, ncartrows] );
	portrows = repmat( millerrows(2)*facport, [1, nportrows] );
	nrows = sum( [audiorows, mainrows] );

	cols = millercols .* [gdata.fdetail, gdata.faudio | gdata.fema, gdata.fdetail, gdata.fcart, gdata.fportrait];
	ncols = sum( cols );

		% create audio panels
	gdata.haudio = [];

	for ri = 1:naudiorows
		props = {};
		if gdata.fema || ri ~= naudiorows
			props([end+1, end+2]) = {'XTickLabel', {}};
		end

		gdata.haudio(ri) = subplot_( fig, nrows, ncols, 0, audiorows, cols, ri, 2, props{:} );
		fig.ylabel( unique( adata.xlab(ri, :), 'stable' ) );
		if ~gdata.fema && ri == naudiorows
			fig.xlabel( unique( {adata.tlab{:}, edata.tlab{:}}, 'stable' ) );
		end
	end

		% create ema detail and main panels
	gdata.hldet = [];
	gdata.hmain = [];
	gdata.hrdet = [];

	for ri = 1:nmainrows

			% left detail
		props = {};
		if ri ~= nmainrows
			props([end+1, end+2]) = {'XTickLabel', {}};
		end

		gdata.hldet(ri) = subplot_( fig, nrows, ncols, sum( audiorows ), mainrows, cols, ri, 1, props{:} );
		if gdata.fdetail
			fig.ylabel( unique( edata.xlab(:, ri), 'stable' ) );
		end
		if ri == nmainrows
			fig.xlabel( unique( {adata.tlab{:}, edata.tlab{:}}, 'stable' ) );
		end

			% right detail
		if gdata.fdetail
			props([end+1, end+2]) = {'YTickLabel', {}};
		end

		gdata.hrdet(ri) = subplot_( fig, nrows, ncols, sum( audiorows ), mainrows, cols, ri, 3, props{:} );
		if ri == nmainrows
			fig.xlabel( unique( {adata.tlab{:}, edata.tlab{:}}, 'stable' ) );
		end

			% main panel
		gdata.hmain(ri) = subplot_( fig, nrows, ncols, sum( audiorows ), mainrows, cols, ri, 2, props{:} );
		if ~gdata.fdetail
			fig.ylabel( unique( edata.xlab(:, ri), 'stable' ) );
		end
		if ri == nmainrows
			fig.xlabel( unique( {adata.tlab{:}, edata.tlab{:}}, 'stable' ) );
		end

	end

		% create ema cartesian panels
	gdata.hcart = [];

	for ri = 1:ncartrows
		props = {'DataAspectRatio', [1, 1, 1], 'YAxisLocation', 'right'};

		gdata.hcart(ri) = subplot_( fig, nrows, ncols, sum( audiorows ), mainrows, cols, ri, 4, props{:} );

		fig.xlabel( edata.xlab(1, ri) );
		fig.ylabel( edata.xlab(2, ri) );
	end

		% create ema portrait panels
	gdata.hport = [];

	for ri = 1:nportrows
		props = {'YAxisLocation', 'right'};
		if ri ~= nportrows
			props([end+1, end+2]) = {'XTickLabel', {}};
		end

		gdata.hport(ri) = subplot_( fig, nrows, ncols, sum( audiorows ), portrows, cols, ri, 5, props{:} );
		fig.ylabel( unique( edata.xlab(:, edata.iport(ri)), 'stable' ) );
		if ri == nportrows
			fig.xlabel( unique( edata.xlab(:, edata.ibase), 'stable' ) );
		end
	end

		% alignment and title
	fig.align( [gdata.haudio, gdata.hmain], 'v' ); % vertical
	fig.align( gdata.hldet, 'v' );
	fig.align( gdata.hrdet, 'v' );
	fig.align( gdata.hcart, 'v' );
	fig.align( gdata.hport, 'v' );

	for ri = 1:nmainrows % horizontal
		hax = [gdata.hldet(ri), gdata.hmain(ri), gdata.hrdet(ri)];
		if ncartrows > 0
			hax = [hax, gdata.hcart(ri)];
		end
		fig.align( hax, 'h' );
	end

	if nportrows > 0
		hax = [gdata.hldet(1), gdata.hmain(1), gdata.hrdet(1), gdata.hport(1)];
		if ncartrows > 0
			hax = [hax, gdata.hcart(1)];
		end
		fig.align( hax, 'ts' );

		hax = [gdata.hldet(end), gdata.hmain(end), gdata.hrdet(end), gdata.hport(end)];
		if ncartrows > 0
			hax = [hax, gdata.hcart(end)];
		end
		fig.align( hax, 'bs' );
	end

	title = titlefun( io.joinfcomp( adata.fc, edata.fc ), [adata.fcol; edata.fcol], [adata.sigs, edata.sigs], [adata.info, edata.info] ); % title

	if ~isempty( title )
		fig.title( title );
	else
		fig.fit();
	end

end % function

	% local functions
function ax = subplot_( fig, nrows, ncols, rowoffs, rows, cols, ri, ci, varargin )
	row0 = rowoffs + sum( rows(1:ri-1) );
	row1 = rowoffs + sum( rows(1:ri) ) - 1;
	col0 = sum( cols(1:ci-1) );
	col1 = sum( cols(1:ci) ) - 1;
	i0 = row0*sum( cols ) + col0 + 1;
	i1 = row1*sum( cols ) + col1 + 1;

	ax = fig.subplot( nrows, ncols, [i0, i1], varargin{:} );
	if cols(ci) == 0
		set( ax, 'Visible', 'off' );
	end
end % function

