function updaterois_( hfig, fsigs, fdata, fdebug )
% update rois
%
% UPDATEROIS_( hfig, fsigs, fdata, fdebug )
%
% INPUT
% hfig : figure handle (TODO)
% fsigs : style signals flag (scalar logical)
% fdata : style data flag (scalar logical)
% fdebug : style debuggings flag (scalar logical)

		% safeguard
	if nargin < 1
		error( 'invalid argument: hfig' );
	end

	if nargin < 2 || ~isscalar( fsigs ) || ~islogical( fsigs )
		error( 'invalid argument: fsigs' );
	end

	if nargin < 3 || ~isscalar( fdata ) || ~islogical( fdata )
		error( 'invalid argument: fdata' );
	end

	if nargin < 4 || ~isscalar( fdebug ) || ~islogical( fdebug )
		error( 'invalid argument: fdebug' );
	end

		% update rois
	adata = getappdata( hfig, 'adata' );
	edata = getappdata( hfig, 'edata' );
	gdata = getappdata( hfig, 'gdata' );

	if fsigs
		style_( findall( gdata.haudio, 'Tag', 'nvis:signal' ), adata, gdata ); % audio
		style_( findall( [gdata.hldet, gdata.hmain, gdata.hrdet, gdata.hcart, gdata.hport], 'Tag', 'nvis:signal' ), edata, gdata ); % ema
	end

	if fdata
		style_( findall( [gdata.hldet, gdata.hmain, gdata.hrdet, gdata.hcart, gdata.hport], 'Tag', 'nvis:data' ), edata, gdata ); % ema
	end

	if fdebug
		style_( findall( [gdata.hldet, gdata.hmain, gdata.hrdet, gdata.hcart, gdata.hport], 'Tag', 'nvis:debug' ), edata, gdata ); % ema
	end

end % function

	% local functions
function style_( h, xdata, gdata )
	for hi = 1:numel( h )
		udata = get( h(hi), 'UserData' );
		froi = udata.t >= xdata.rois(udata.si, 1) & udata.t <= xdata.rois(udata.si, 2);

		cdata = [];
		cdata(~froi, 1:3) = repmat( udata.colhi, [sum( ~froi ), 1] );
		cdata(froi, 1:3) = repmat( udata.collo, [sum( froi ), 1] );

		zdata = floor( get( h(hi), 'ZData' ) );
		zdata(froi) = zdata(froi)+0.4;

		set( h(hi), 'CData', cdata );
		set( h(hi), 'FaceVertexCData', cdata );
		set( h(hi), 'ZData', zdata );
	end
end % function

