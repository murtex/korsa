function faux = genfaux( dim, audio, fixed, occlusal, sagittal, origin, maxilla, mandible, tongue )
% create auxilliary info structure
%
% faux = genfaux( dim, audio, fixed, occlusal, sagittal, origin, maxilla, mandible, tongue )
%
% INPUT
% dim : composition dimension name (char)
% audio : audio sensors (cell string)
% fixed : head-fixed sensors (cell string)
% occlusal : occlusal plane sensors (cell string)
% sagital : sagital plane sensors (cell string)
% origin : origin sensor (cell string)
% maxilla : maxilla sensors (cell string)
% mandible : mandible sensors (cell string)
% tongue : tongue sensor (cell string)
%
% OUTPUT
% faux : auxilliary info structure (scalar struct)

		% safeguard
	if nargin < 1 || ~ischar( dim )
		error( 'invalid argument: dim' );
	end

	if nargin < 2 || ~iscellstr( audio )
		error( 'invalid argument: audio' );
	end

	if nargin < 3 || ~iscellstr( fixed )
		error( 'invalid argument: fixed' );
	end

	if nargin < 4 || ~iscellstr( occlusal )
		error( 'invalid argument: occlusal' );
	end

	if nargin < 5 || ~iscellstr( sagittal )
		error( 'invalid argument: sagittal' );
	end

	if nargin < 6 || ~iscellstr( origin )
		error( 'invalid argument: origin' );
	end

	if nargin < 7 || ~iscellstr( maxilla )
		error( 'invalid argument: maxilla' );
	end

	if nargin < 8 || ~iscellstr( mandible )
		error( 'invalid argument: mandible' );
	end

	if nargin < 9 || ~iscellstr( tongue )
		error( 'invalid argument: tongue' );
	end

		% create aux info
	faux = struct( ...
		'dim', dim, ...
		'audio', {audio}, ...
		'fixed', {fixed}, ...
		'occlusal', {occlusal}, ...
		'sagittal', {sagittal}, ...
		'origin', {origin}, ...
		'maxilla', {maxilla}, ...
		'mandible', {mandible}, ...
		'tongue', {tongue} );

end % function

