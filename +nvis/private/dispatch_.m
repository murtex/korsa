function dispatch_( hfig, event, msg )
% general message dispatcher
%
% DISPATCH_( hfig, event, msg )
%
% INPUT
% hfig : figure handle (TODO)
% event : TODO
% msg : message string (char)

		% safeguard
	if nargin < 1
		error( 'invalid argument: hfig' );
	end
	
	if nargin < 2
		error( 'invalid argument: event' );
	end

	if nargin < 3 || ~ischar( msg )
		error( 'invalid argument: msg' );
	end

	logger = hLogger.instance();
	style = hStyle.instance();

		% dispatch message
	edata = getappdata( hfig, 'edata' );
	adata = getappdata( hfig, 'adata' );
	gdata = getappdata( hfig, 'gdata' );

	if ismember( msg, {'close'} ) % close request
		delete( hfig );

		% -------------------------------------------------------------------
		% KEYBOARD

	elseif ismember( msg, {'keypress'} ) % keyboard
		chnum = str2num( event.Character );

		%logger.log( 'keypress: [Key=''%s'', Character=''%s'', Modifier=%s]', event.Key, event.Character, util.any2str( event.Modifier ) ); % DEBUG

			% ---------------------------------------------------------------
			% view
		if iskey_( event, {'uparrow'}, {} )
			gdata.vwidth = adjmul_( gdata.vwidth, [0, diff( gdata.vtl )], 0.875, 3, event.Modifier );
			setappdata( hfig, 'gdata', gdata );
			setview_( hfig, false );
			update_( hfig );

		elseif iskey_( event, {'downarrow'}, {} )
			gdata.vwidth = adjmul_( gdata.vwidth, [0, diff( gdata.vtl )], 1/0.875, 3, event.Modifier );
			setappdata( hfig, 'gdata', gdata );
			setview_( hfig, false );
			update_( hfig );

		elseif iskey_( event, {'leftarrow'}, {} )
			gdata.vcenter = adjadd_( gdata.vcenter, gdata.vtl, -0.05*gdata.vwidth, 3, event.Modifier );
			setappdata( hfig, 'gdata', gdata );
			setview_( hfig, false );
			update_( hfig );

		elseif iskey_( event, {'rightarrow'}, {} )
			gdata.vcenter = adjadd_( gdata.vcenter, gdata.vtl, 0.05*gdata.vwidth, 3, event.Modifier );
			setappdata( hfig, 'gdata', gdata );
			setview_( hfig, false );
			update_( hfig );

		elseif iskey_( event, {'pageup'}, {} )
			gdata.vcenter = adjadd_( gdata.vcenter, gdata.vtl, -0.65*gdata.vwidth, 3, event.Modifier );
			setappdata( hfig, 'gdata', gdata );
			setview_( hfig, false );
			update_( hfig );

		elseif iskey_( event, {'pagedown'}, {} )
			gdata.vcenter = adjadd_( gdata.vcenter, gdata.vtl, 0.65*gdata.vwidth, 3, event.Modifier );
			setappdata( hfig, 'gdata', gdata );
			setview_( hfig, false );
			update_( hfig );

		elseif iskey_( event, {'r'}, {} )
			gdata.vcenter = mean( style.limits( gdata.vroi, gdata.vtmargin, gdata.vtl ) );
			gdata.vwidth = diff( style.limits( gdata.vroi, gdata.vtmargin, gdata.vtl ) );
			setappdata( hfig, 'gdata', gdata );
			setview_( hfig, false );
			update_( hfig );

		elseif iskey_( event, {'f'}, {} )
			gdata.vcenter = mean( gdata.vtl );
			gdata.vwidth = diff( gdata.vtl );
			setappdata( hfig, 'gdata', gdata );
			setview_( hfig, false );
			update_( hfig );

		elseif iskey_( event, {'0'}, {'+'} )
			gdata.vres = round( 2*gdata.vres );
			setappdata( hfig, 'gdata', gdata );
			plotsigs_( hfig );
			update_( hfig );

		elseif iskey_( event, {'hyphen'}, {'-'} )
			gdata.vres = max( 1, round( gdata.vres/2 ) );
			setappdata( hfig, 'gdata', gdata );
			plotsigs_( hfig );
			update_( hfig );

			% ---------------------------------------------------------------
			% toggles
		elseif iskey_( event, {'d'}, {} )
			gdata.fdyn = ~gdata.fdyn;
			setappdata( hfig, 'gdata', gdata );
			setview_( hfig, true );
			update_( hfig );

		elseif iskey_( event, {'q', 'w', 'e'}, {} )
			switch event.Key
				case 'q'
					gdata.fmovs(2) = ~gdata.fmovs(2);
				case 'w'
					gdata.fmovs(1) = ~gdata.fmovs(1);
				case 'e'
					gdata.fmovs(3) = ~gdata.fmovs(3);
			end
			setappdata( hfig, 'gdata', gdata );
			updatemovs_( hfig, [] );
			update_( hfig );

		elseif iskey_( event, {'s'}, {} )
			gdata.fsigs = ~gdata.fsigs;
			setappdata( hfig, 'gdata', gdata );
			updatevis_( hfig, true, false, false );
			update_( hfig );

		elseif iskey_( event, {'x'}, {} )
			gdata.fdata = ~gdata.fdata;
			setappdata( hfig, 'gdata', gdata );
			updatevis_( hfig, false, true, false );
			update_( hfig );

		elseif iskey_( event, {'0'}, {'^'} )
			gdata.fdebug = ~gdata.fdebug;
			setappdata( hfig, 'gdata', gdata );
			updatevis_( hfig, false, false, true );
			update_( hfig );

		elseif ~isempty( chnum ) && chnum <= numel( edata.sigs )
			gdata.fgroup(chnum) = ~gdata.fgroup(chnum);
			setappdata( hfig, 'gdata', gdata );
			updatemovs_( hfig, [] );
			updatevis_( hfig, true, true, true );
			update_( hfig );

			% ---------------------------------------------------------------
			% data
		elseif iskey_( event, {'delete'}, {} )
			if strcmp( 'editroi', gdata.wmode )
				adata.rois(:, 1) = -Inf;
				edata.rois(:, 1) = -Inf;
				adata.rois(:, 2) = Inf;
				edata.rois(:, 2) = Inf;
				gdata.vroi = style.limits( [-Inf, Inf], 0, gdata.vtl );

				setappdata( hfig, 'adata', adata );
				setappdata( hfig, 'edata', edata );
				setappdata( hfig, 'gdata', gdata );
				setview_( hfig, false );
				updaterois_( hfig, true, true, true );
				update_( hfig );

				logger.log( 'removed roi' );
			end

		elseif iskey_( event, {'backspace'}, {} )
			adata.rois = adata.bakrois;
			adata.movs = adata.bakmovs;
			edata.rois = edata.bakrois;
			edata.movs = edata.bakmovs;
			setappdata( hfig, 'adata', adata );
			setappdata( hfig, 'edata', edata );
			updatemovs_( hfig, [] );
			updaterois_( hfig, true, true, true );
			update_( hfig );

		elseif iskey_( event, {'return'}, {} )
			playback_( hfig );

		elseif iskey_( event, {'m'}, {} )
			[gdata.filtin, gdata.filtex, gdata.filtsel] = filters_( hfig );
			setappdata( hfig, 'gdata', gdata );
			updatemovs_( hfig, [] );

		elseif iskey_( event, {'v'}, {} )
			if ~ismember( 'shift', event.Modifier ) % load
				try
					load( gdata.cfgfile, '-mat', 'cfgvcenter', 'cfgvwidth' );

					gdata.vcenter = cfgvcenter;
					gdata.vwidth = cfgvwidth;

					setappdata( hfig, 'gdata', gdata );
					setview_( hfig, false );
					update_( hfig );
				end
			else % save
				cfgvcenter = gdata.vcenter;
				cfgvwidth = gdata.vwidth;

				args = {'-mat'};
				if exist( gdata.cfgfile )
					args{end+1} = '-append';
				end

				save( gdata.cfgfile, 'cfgvcenter', 'cfgvwidth', args{:} );
			end

			% ---------------------------------------------------------------
			% other
		elseif iskey_( event, {'0'}, {'?'} )
			showhelp_( hfig );

		elseif iskey_( event, {'1'}, {'!'} )
			showstats_( hfig );

		elseif iskey_( event, {'p'}, {} )
			dstfile = fullfile( gdata.plotdir, strcat( datestr( now(), 'yyyymmdd-HHMMSS-FFF' ), '.png' ) );
			logger.log( 'plot ''%s''...', dstfile );
			gdata.fig.print( dstfile );

			% ---------------------------------------------------------------
			% quit
		elseif iskey_( event, {'space'}, {} )
			gdata.fdone = true;
			setappdata( hfig, 'gdata', gdata );
			update_( hfig );

		elseif iskey_( event, {'escape'}, {} )
			gdata.fdone = true;
			gdata.fstop = true;
			setappdata( hfig, 'gdata', gdata );
			update_( hfig );

		end
	
		% -------------------------------------------------------------------
		% MOUSE

	elseif ismember( msg, {'buttonup'} ) % button up
		[gdata.hpointer, gdata.pointer] = pointer_( hfig );
		setappdata( hfig, 'gdata', gdata );

	elseif ismember( msg, {'buttonpress'} ) % button down
		[gdata.hpointer, gdata.pointer] = pointer_( hfig );
		setappdata( hfig, 'gdata', gdata );

		switch gdata.wmode
			case 'editroi'
				if ismember( gco(), [gdata.haudio, gdata.hldet, gdata.hmain, gdata.hrdet] )
					cp = get( gco(), 'CurrentPoint' );
					t = mean( cp(:, 1) );

					switch get( hfig, 'SelectionType' )
						case 'normal'
							adata.rois(:, 1) = t;
							edata.rois(:, 1) = t;
							gdata.vroi(1) = t;

							setappdata( hfig, 'adata', adata );
							setappdata( hfig, 'edata', edata );
							setappdata( hfig, 'gdata', gdata );
							setview_( hfig, false );
							updaterois_( hfig, true, true, true );
							update_( hfig );

							logger.log( 'set roi start=%g', t );

						case 'alt'
							adata.rois(:, 2) = t;
							edata.rois(:, 2) = t;
							gdata.vroi(2) = t;

							setappdata( hfig, 'adata', adata );
							setappdata( hfig, 'edata', edata );
							setappdata( hfig, 'gdata', gdata );
							setview_( hfig, false );
							updaterois_( hfig, true, true, true );
							update_( hfig );

							logger.log( 'set roi stop=%g', t );
					end
				end

			case 'editmovs'
				if strcmp( get( gco(), 'Tag' ), 'nvis:movement' )
					udata = get( gco(), 'UserData' );
					edata.movs{udata.si}(udata.mi) = togglemovs_( hfig, edata.movs{udata.si}(udata.mi) );
					setappdata( hfig, 'edata', edata );
					updatemovs_( hfig, [udata.si, udata.mi] );
					update_( hfig );

					logger.log( 'set tags=%s', util.any2str( edata.movs{udata.si}(udata.mi).tags ) );
				else
					[~, ch] = ismember( gdata.hpointer, gdata.hmain );
					if ch > 0
						multimovs_( hfig, ch );
						update_( hfig );
					end
				end

		end
	end

end % function

	% local functions
function tf = iskey_( event, keys, chars )
	tf = false;
	if (isempty( keys ) || ismember( event.Key, keys )) && (isempty( chars ) || ismember( event.Character, chars ))
		tf = true;
	end
end % function

function update_( hfig )
	set( hfig, 'UserData', ~get( hfig, 'UserData' ) );
end % function

function v = adjadd_( v, vclamp, base, arg, mod )
	if ismember( 'shift', mod )
		base = base/arg;
	end
	if ismember( 'control', mod )
		base = base*arg;
	end
	v = max( vclamp(1), min( vclamp(2), v+base ) );
end % function

function v = adjmul_( v, vclamp, base, arg, mod )
	if ismember( 'shift', mod )
		base = base^(1/arg);
	end
	if ismember( 'control', mod )
		base = base^arg;
	end
	v = max( vclamp(1), min( vclamp(2), v*base ) );
end % function

