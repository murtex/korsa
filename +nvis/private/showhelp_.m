function showhelp_( hfig )
% show help dialog
%
% SHOWHELP_( hfig )
%
% INPUT
% hfig : figure handle (TODO)

		% safeguard
	if nargin < 1
		error( 'invalid argument: hfig' );
	end

		% show help dialog
	helpstr = {...
		'VIEW', ...
		'up-/downarrow: zoom in/out', ...
		'left-/rightarrow: move left/right', ...
		'pageup/-down: jump left/right', ...
		'control/shift: increase/decrease step size', ...
		'r: reset to roi view', ...
		'f: reset to full view', ...
		'+/-: increase/decrease smoothing', ...
		'', ...
		'TOGGLES', ...
		'd: dynamical scaling', ...
		'q, w, e: movement components visibility', ...
		's: signals visibility', ...
		'x: data points visibility', ...
		'^: debugging visibility', ...
		'1..9: toggle groups visibility', ...
		'', ...
		'DATA', ...
		'left/right: set roi start/stop (editroi)', ...
		'delete: remove roi (editroi)', ...
		'left: toggle movements (editmovs)', ...
		'backspace: undo changes', ...
		'return: playback audio', ...
		'm: filter movements...', ...
		'v/shift+v: load/save view range', ...
		'', ...
		'OTHER', ...
		'p: print figure', ...
		'!: show status window...', ...
		'?: show this help window...', ...
		'', ...
		'QUIT', ...
		'space: save changes and continue', ...
		'escape: save changes and quit' };
		
	msgbox( helpstr, 'nvis:help', 'none', 'modal' );

end % function

