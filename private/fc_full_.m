function fc = fc_full_( rawdir, procdir, fcdims, fupdate )
% retrieve dataspace
%
% fc = FC_FULL_( rawdir, procdir, fcdims, fupdate )
%
% INPUT
% rawdir : input directory (char)
% procdir : output directory (char)
% fcdims : dataspace dimensions (cell string)
% fupdate : force update flag (logical scalar)
%
% OUTPUT
% fc : dataspace (struct scalar)

		% safeguard
	if nargin < 1 || ~ischar( rawdir )
		error( 'invalid argument: rawdir' );
	end

	if nargin < 2 || ~ischar( procdir )
		error( 'invalid argument: procdir' );
	end

	if nargin < 3 || ~iscellstr( fcdims )
		error( 'invalid argument: fcdims' );
	end

	if nargin < 4 || ~islogical( fupdate ) || ~isscalar( fupdate )
		error( 'invalid argument: fupdate' );
	end

		% check for necessary update, TODO: timestamps!?
	fcfile = fullfile( procdir, 'fcfull.mat' );

	if ~fupdate
		if exist( fcfile, 'file' ) ~= 2
			fupdate = true;
		end
	end

		% update dataspace
	if fupdate
		fc = convert_( rawdir, '', '', true, repmat( {{}}, [1, numel( fcdims )] ) );

		if exist( procdir, 'dir' ) ~= 7
			mkdir( procdir )
		end
		io.writefcomp( fc, fcfile );
	end

		% read dataspace
	fc = io.readfcomp( fcfile );

end % function

