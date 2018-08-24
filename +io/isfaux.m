function tf = isfaux( var )
% check for auxilliary info structure type
%
% tf = isfaux( var )
%
% INPUT
% var : variable (scalar)
%
% OUTPUT
% tf : check result (scalar logical)

		% safeguard
	if nargin < 1 || ~isscalar( var )
		error( 'invalid argument: var' );
	end

		% check type
	tf = false;

	if ~isstruct( var )
		return;
	end

	if ~isfield( var, 'dim' ) || ~ischar( var.dim )
		return;
	end
	if ~isfield( var, 'audio' ) || ~iscellstr( var.audio )
		return;
	end
	if ~isfield( var, 'fixed' ) || ~iscellstr( var.fixed )
		return;
	end
	if ~isfield( var, 'occlusal' ) || ~iscellstr( var.occlusal )
		return;
	end
	if ~isfield( var, 'sagittal' ) || ~iscellstr( var.sagittal )
		return;
	end
	if ~isfield( var, 'origin' ) || ~iscellstr( var.origin )
		return;
	end
	if ~isfield( var, 'maxilla' ) || ~iscellstr( var.maxilla )
		return;
	end
	if ~isfield( var, 'mandible' ) || ~iscellstr( var.mandible )
		return;
	end
	if ~isfield( var, 'tongue' ) || ~iscellstr( var.tongue )
		return;
	end

	tf = true; % check passed

end % function

