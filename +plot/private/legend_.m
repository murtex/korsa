function hld = legend_( fig, hax, hld, opts )
% plot legend
%
% hld = LEGEND_( fig, hax, hld, opts )
%
% INPUT
% fig : figure (scalar object)
% hax : current axes (scalar handle)
% hld : objects to label (handle)
% opts : panel options (cell string)
%
% OUTPUT
% hld : objects not labeled (handle)

		% safeguard
	if nargin < 1 || ~isscalar( fig ) || ~isa( fig, 'hFigure' )
		error( 'invalid argument: fig' );
	end

	if nargin < 2 || ~isscalar( hax )
		error( 'invalid argument: hax' );
	end

	if nargin < 3
		error( 'invalid argument: hld' );
	end

	if nargin < 4 || ~iscellstr( opts )
		error( 'invalid argument: opts' );
	end

	style = hStyle.instance();

		% parse options
	[labpos, lopts] = parseopts2_( opts, 'labpos', 'legend' );

	if isempty( lopts ) || numel( hld ) == 0
		hld = [];
		return;
	end

		% reduce objects to label
	if numel( hld ) > 1
		l = transpose( get( hld, 'DisplayName' ) );
		lu = unique( l );

		dels = [];
		for li = 1:numel( lu )
			lj = find( ismember( l, lu(li) ) );
			dels = [dels, lj(2:end)];
		end

		delete( hld(dels) );
		hld(dels) = [];
	end

		% prepare labels
	labels = get( hld, 'DisplayName' );
	if numel( hld ) == 1
		labels = {labels};
	end

		% prepare position
	switch labpos
		case 'tl'
			anchor = 'nw';
			buffer = [5, -5];
		case 'tr'
			anchor = 'ne';
			buffer = [-5, -5];
		case 'br'
			anchor = 'se';
			buffer = [-5, 5];
		case 'bl'
			anchor = 'sw';
			buffer = [5, 5];
		otherwise
			error( 'invalid value: labpos' );
	end

		% prepare layout
	grid = [0, 0];
	if ismember( 'h', lopts )
		grid = [1, numel( hld )];
	end
	if ismember( 'v', lopts )
		grid = [numel( hld ), 1];
	end

		% plot legend
	fig.axes( hax );

	addpath( fullfile( fileparts( which( 'xis' ) ), 'other/kakearney-legendflex-pkg-f29cb4e/legendflex/' ) );
	addpath( fullfile( fileparts( which( 'xis' ) ), 'other/kakearney-legendflex-pkg-f29cb4e/setgetpos_V1.2/' ) );

	legendflex( hld, labels, 'nolisten', true, 'nrow', grid(1), 'ncol', grid(2), 'anchor', {anchor, anchor}, 'buffer', buffer, 'xscale', 0.2, 'fontsize', style.fssmaller );

	rmpath( fullfile( fileparts( which( 'xis' ) ), 'other/kakearney-legendflex-pkg-f29cb4e/legendflex/' ) );
	rmpath( fullfile( fileparts( which( 'xis' ) ), 'other/kakearney-legendflex-pkg-f29cb4e/setgetpos_V1.2/' ) );

end % function

