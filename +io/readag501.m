function [data, rate] = readag501( filename )
% read ag501 position data (v003 format)
%
% [data, rate] = READAG501( filename )
%
% INPUT
% filename : filename (char)
%
% OUTPUT
% data : sensor data (matrix numeric [channel, time])
% rate : sampling rate (scalar numeric)

		% safeguard
	if nargin < 1 || ~ischar( filename )
		error( 'invalid argument: filename' );
	end

		% read position data
	fid = fopen( filename );

	magic = fgetl( fid ); % header
	if ~strcmp( magic, 'AG50xDATA_V003' )
		fclose( fid );
		error( 'invalid value: magic' );
	end

	hsize = str2num( fgetl( fid ) );
	nch = str2num( regexprep( fgetl( fid ), '(\w*)=', '' ) );
	rate = str2num( regexprep( fgetl( fid ), '(\w*)=', '' ) );

	fseek( fid, 0, 'eof' ); % data
	dsize = ftell( fid ) - hsize;
	fseek( fid, hsize, 'bof' );

	data = fread( fid, [nch*7, dsize/4/nch/7], 'single' );
	if numel( data ) ~= dsize/4
		fclose( fid );
		error( 'invalid value: data' );
	end

	fclose( fid );

end % function

