function setview_( hfig, fspatial )
% set panel view
%
% SETVIEW_( hfig, fspatial )
%
% INPUT
% hfig : figure handle (TODO)
% fspatial : force spatial adjustment flag (scalar logical)

		% safeguard
	if nargin < 1
		error( 'invalid argument: hfig' );
	end

	if nargin < 2 || ~isscalar( fspatial ) || ~islogical( fspatial )
		error( 'invalid argument: fspatial' );
	end

	style = hStyle.instance();

		% validate view
	adata = getappdata( hfig, 'adata' ); % fit view
	edata = getappdata( hfig, 'edata' );
	gdata = getappdata( hfig, 'gdata' );

	[gdata.vcenter, gdata.vwidth] = fittl_( gdata.vcenter, gdata.vwidth, gdata.vtl );

	setappdata( hfig, 'gdata', gdata );

		% temporal view
	tl = getl_( gdata.vcenter, gdata.vwidth, gdata.vtl ); % audio and main panel
	set( [gdata.haudio, gdata.hmain], 'XLim', tl );

	if gdata.fdetail % detail panels
		ltl = getl_( min( [adata.rois(:, 1); edata.rois(:, 1)] ), gdata.vwidth/gdata.vdetail, gdata.vtl ); % detail panels
		rtl = getl_( max( [adata.rois(:, 2); edata.rois(:, 2)] ), gdata.vwidth/gdata.vdetail, gdata.vtl );
		set( gdata.hldet, 'XLim', ltl );
		set( gdata.hrdet, 'XLim', rtl );
	end

		% spatial view
	if fspatial || gdata.fdyn

			% audio panels
		xl = adata.xl;
		if gdata.fdyn
			xl = getxlim_( adata.sigs, adata.ch, adata.pk, tl );
		end

		for hi = 1:numel( gdata.haudio )
			set( gdata.haudio(hi), 'YLim', style.limits( [xl{hi, :}], gdata.vxmargin ) );
		end

			% ema panels
		xl = edata.xl;
		if gdata.fdyn
			xl = getxlim_( edata.sigs, edata.ch, edata.pk, tl );
		end

		for hi = 1:numel( gdata.hmain ) % main panels
			set( gdata.hmain(hi), 'YLim', style.limits( [xl{:, hi}], gdata.vxmargin ) );
		end

		for hi = 1:numel( gdata.hmain ) % detail panels
			set( gdata.hldet(hi), 'YLim', style.limits( [xl{:, hi}], gdata.vxmargin ) );
			set( gdata.hrdet(hi), 'YLim', style.limits( [xl{:, hi}], gdata.vxmargin ) );
		end

		for hi = 1:numel( gdata.hcart ) % cartesian panels
			xlx = style.limits( [xl{1, hi}], gdata.vxmargin );
			xly = style.limits( [xl{2, hi}], gdata.vxmargin );
			%[xlx, xly] = style.equalize( xlx, xly )
			set( gdata.hcart(hi), 'XLim', xlx );
			set( gdata.hcart(hi), 'YLim', xly );
		end

		for hi = 1:numel( gdata.hport ) % portrait panels
			set( gdata.hport(hi), 'XLim', style.limits( [xl{:, edata.ibase}], gdata.vxmargin ) );
			set( gdata.hport(hi), 'YLim', style.limits( [xl{:, edata.iport(hi)}], gdata.vxmargin ) );
		end

	end

end % function

	% local functions
function [center, width] = fittl_( center, width, tl )
	if width > diff( tl )
		width = diff( tl );
	end
	if center-width/2 < tl(1)
		center = tl(1)+width/2;
	end
	if center+width/2 > tl(2)
		center = tl(2)-width/2;
	end
end % function

function l = getl_( center, width, tl )
	l = center+[-width, width]/2;
	if l(1) < tl(1)
		l = tl(1)+[0, width];
	end
	if l(2) > tl(2)
		l = tl(2)-[width, 0];
	end
end % function

