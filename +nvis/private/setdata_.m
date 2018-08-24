function data = setdata_( ftr, fc, fcol, ch, fzscore )
% initialize data structure
%
% data = SETDATA_( ftr, fc, fcol, ch, fzscore )
%
% INPUT
% ftr : file transformation structure (scalar struct)
% fc : file composition (scalar struct)
% fcol : file collection (cell string)
% ch : channels (numeric)
% fzscore : z-score flag (logical scalar)
%
% OUTPUT
% data : data structure (scalar struct)

		% safeguard
	if nargin < 1 || ~isscalar( ftr ) || ~io.isftr( ftr )
		error( 'invalid argument: ftr' );
	end

	if nargin < 2 || ~io.isfcomp( fc )
		error( 'invalid argument: fc' );
	end

	if nargin < 3 || ~iscellstr( fcol )
		error( 'invalid argument: fcol' );
	end

	if nargin < 4 || ~isnumeric( ch )
		error( 'invalid argument: ch' );
	end

	if nargin < 5 || ~islogical( fzscore ) || ~isscalar( fzscore )
		error( 'invalid argument: fzscore' );
	end

	logger = hLogger.instance();
	style = hStyle.instance();

		% read signals
	data.fc = fc;
	data.fcol = fcol;

	data.sigs = hNSignal.empty();
	data.info = io.geninfo();
	data.rois = [-Inf( [0, 1] ), Inf( [0, 1] )];
	data.movs = io.genmovs();

	for fi = 1:numel( fcol )
		srcfile = fullfile( ftr.srcdir, fcol{fi}, strcat( ftr.srcbase, '.mat' ) );
		[data.sigs(fi), data.info(fi), data.rois(fi, :), data.movs{fi}] = io.readparts( srcfile, {'sig', 'info', 'roi', 'movs'} );

		if fzscore
			data.sigs(fi).data = abs( util.zscore( data.sigs(fi).data(1, :) ) );
		end

		%data.movs{fi}(~[data.movs{fi}.fpos]) = []; % DEBUG: closures only!
	end

	data.bakrois = data.rois; % backup
	data.bakmovs = data.movs;

		% analyze channels
	data.ch = unique( ch, 'stable' );

	data.ibase = find( data.ch == 1 );
	data.iport = [];
	if ~isempty( data.ibase )
		data.iport = data.ch(find( data.ch ~= 1 ));
	end

		% axes labels
	data.tlab = cell( [1, numel( data.sigs )] );
	data.xlab = cell( [numel( data.sigs ), numel( data.ch )] );

	for si = 1:numel( data.sigs )
		sig = data.sigs(si);
		data.tlab{si} = getlabel_( sig.getlabel( NaN, 'long' ), sig.getlabel( NaN, 'unit' ) );
		for ci = 1:numel( data.ch )
			ch = data.ch(ci);
			data.xlab{si, ci} = getlabel_( sig.getlabel( ch, 'short' ), sig.getlabel( ch, 'unit' ) );
		end
	end

		% zero crossings and peaks
	data.zc = cell( [numel( data.sigs ), numel( data.ch )] );
	data.pk = cell( [numel( data.sigs ), numel( data.ch )] );

	for si = 1:numel( data.sigs )
		sig = data.sigs(si);
		for ci = 1:numel( data.ch )
			ch = data.ch(ci);
			data.zc{si, ci} = sig.polyroot( ch, 0 );
			data.pk{si, ci} = sig.polyroot( ch+1, 0 );
		end
	end

		% data limits and depth order
	data.tl = gettlim_( data.sigs );
	data.xl = getxlim_( data.sigs, data.ch, data.pk, style.limits( data.tl(:) ) );

	data.zorder = NaN( [numel( data.sigs ), numel( data.ch )] );
	for ci = 1:numel( data.ch )
		ch = data.ch(ci);
		xl = reshape( cat( 1, data.xl{:, ch} ), [numel( data.sigs ), 2] );
		[~, data.zorder(:, ci)] = sort( diff( xl, 1, 2 ), 'descend' );
	end

end % function

	% local funcitons
function lab = getlabel_( long, unit )
	style = hStyle.instance();

	switch long % DEBUG: pretify output for paper1
		case 'time'
			long = 'Time';
		case 'audio ch. #1'
			long = 'Audio';
		case 'long. displ.'
			long = 'Displacement';
		case 'long. vel.'
			long = 'Velocity';
	end

	if style.funits && ~isempty( unit )
		lab = sprintf( '%s in %s', long, unit );
	else
		lab = long;
	end
end % function

