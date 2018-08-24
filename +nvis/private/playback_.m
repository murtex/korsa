function playback_( hfig )
% playback audio
%
% PLAYBACK_( hfig )
%
% INPUT
% hfig : figure handle (TODO)
%
% TODO: completely improve!

		% safeguard
	if nargin < 1
		error( 'invalid argument: hfig' );
	end

		% prepare audio data
	adata = getappdata( hfig, 'adata' );
	gdata = getappdata( hfig, 'gdata' );

	wavdata = [];
	wavrate = NaN;

	for si = 1:numel( adata.sigs )
		sig = adata.sigs(si);
		wavdata(si, :) = sig.data;
		wavrate = sig.rate;
	end

	wavdata = 0.9*bsxfun( @mrdivide, wavdata, max( wavdata, [], 2 ) ); % normalization

		% playback
	if ~isempty( wavdata )
		io.writewav( wavdata, wavrate, gdata.wavfile );

		cmd = sprintf( 'mplayer %s -loop 1 < /dev/null &', gdata.wavfile );
		[status, cmdout] = unix( cmd );
		if status ~= 0
			error( sprintf( 'command: ''%s'', status: %d, output: ''%s''', cmd, status, cmdout ) );
		end
	end

end % function

