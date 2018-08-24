function ftr = genftr( srcfc, srcdir, srcbase, dstfc, dstdir, dstbase )
% create file transfer structure
%
% ftr = GENFTR( srcfc, srcdir, srcbase )
% ftr = GENFTR( srcfc, srcdir, srcbase, dstfc, dstdir, dstbase )
%
% INPUT
% srcfc : source file composition (scalar struct)
% srcdir : source directory (char)
% srcbase : source basename (char)
% dstfc : destination file composition (scalar struct)
% dstdir : destination directory (char)
% dstbase : destination basename (char)
%
% OUTPUT
% ftr : file transfer structure (scalar struct)

		% safeguard
	if nargin < 1 || ~io.isfcomp( srcfc )
		error( 'invalid argument: srcfc' );
	end
	
	if nargin < 2 || ~ischar( srcdir )
		error( 'invalid argument: srcdir' );
	end

	if nargin < 3 || ~ischar( srcbase )
		error( 'invalid argument: srcbase' );
	end

	if nargin < 4
		dstfc = srcfc;
	end
	if ~io.isfcomp( dstfc )
		error( 'invalid argument: dstfc' );
	end

	if nargin < 5
		dstdir = srcdir;
	end
	if ~ischar( dstdir )
		error( 'invalid argument: dstdir' );
	end

	if nargin < 5
		dstbase = srcbase;
	end
	if ~ischar( dstbase )
		error( 'invalid argument: dstbase' );
	end

		% create transfer structure
	ftr.srcfc = srcfc;
	ftr.srcdir = srcdir;
	ftr.srcbase = srcbase;

	ftr.dstfc = dstfc;
	ftr.dstdir = dstdir;
	ftr.dstbase = dstbase;

	ftr.mapftr = struct( [] );
	ftr.mapfexp = false( 0 );

end % function

