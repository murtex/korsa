function fc = joinfcomp( fc, varargin )
% join file compositions
%
% fc = JOINFCOMP( fc, ... )
%
% INPUT
% fc : file composition (scalar struct)
% ... : file compositions (struct)
%
% OUTPUT
% fc : joint file composition (scalar struct)
%
% TODO: check structure format!

		% safeguard
	if nargin < 1 || ~isscalar( fc ) || ~all( io.isfcomp( fc ) )
		error( 'invalid argument: fc' );
	end

		% join sturctures
	for vi = 1:numel( varargin )
		fnames = fieldnames( varargin{vi} );
		for fi = 1:numel( fnames )
			if isfield( fc, fnames{fi} ) && ~isempty( fc.(fnames{fi}) )
				fc.(fnames{fi}) = union( fc.(fnames{fi}), varargin{vi}.(fnames{fi}) );
			else
				fc.(fnames{fi}) = varargin{vi}.(fnames{fi});
			end
		end
	end

end % function
