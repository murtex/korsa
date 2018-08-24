function tf = isftr( var )
% check for file transfer structure type
%
% tf = ISFTR( var )
%
% INPUT
% var : variable
%
% OUTPUT
% tf : check result (scalar logical)

		% safeguard
	if nargin < 1
		error( 'invalid argument: var' );
	end

		% check type
	tf = false;

	if ~isstruct( var )
		return;
	end

	if ~isfield( var, 'srcfc' ) || ~io.isfcomp( var.srcfc )
		return;
	end
	if ~isfield( var, 'srcdir' ) || ~ischar( var.srcdir )
		return;
	end
	if ~isfield( var, 'srcbase' ) || ~ischar( var.srcbase )
		return;
	end

	if ~isfield( var, 'dstfc' ) || ~io.isfcomp( var.dstfc )
		return;
	end
	if ~isfield( var, 'dstdir' ) || ~ischar( var.dstdir )
		return;
	end
	if ~isfield( var, 'dstbase' ) || ~ischar( var.dstbase )
		return;
	end

	if ~isfield( var, 'mapftr' ) || (~isempty( var.mapftr ) && ~io.isftr( var.mapftr ))
		return;
	end
	if ~isfield( var, 'mapfexp' ) || (~isempty( var.mapfexp ) && ~islogical( var.mapfexp ))
		return;
	end

		% depth check
	srcdims = fieldnames( var.srcfc );
	dstdims = fieldnames( var.dstfc );

	if ~isequal( srcdims, dstdims )
		return;
	end

	if any( cellfun( @( fname ) numel( var.srcfc.(fname) ) ~= numel( var.dstfc.(fname) ), srcdims ) )
		return;
	end

	tf = true; % check passed

end % function

