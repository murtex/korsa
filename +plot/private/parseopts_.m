function [fsplit, fjoint, fover, joint, scale, legend, split, feven] = parseopts_( opts )
% parse options
%
% [fsplit, fjoint, joint, scale, legend, split, feven] = PARSEOPTS_( opts )
%
% INPUT
% opts : panel options (cell string)
%
% OUTPUT
% fsplit : split flags [horizontal, vertical] (logical)
% fjoint : true axes joint flags [horizontal, vertical] (logical)
% fover : color axes joint (overlays) flags [horizontal, vertical] (logical)
% joint : joint description (cell)
% scale : scale description (cell)
% legend : legend description (cell string)
% split : split scale description (cell string)
% feven : even axes flag (scalar logical)
%
% TODO: remove conflicting options!

		% safeguard
	if nargin < 1 || ~iscellstr( opts )
		error( 'invalid argument: opts' );
	end

		% parse options
	opts = sort( opts );

	joint = {{}, {}};
	scale = {{}, {}};
	legend = {};
	split = {};
	feven = ismember( 'even', opts );

	for oi = 1:numel( opts )
		oj = strfind( opts{oi}, 'hjoint' );
		if oj == 1
			joint{1}{end+1} = opts{oi}(end);
		end
		oj = strfind( opts{oi}, 'vjoint' );
		if oj == 1
			joint{2}{end+1} = opts{oi}(end);
		end

		oj = strfind( opts{oi}, 'habs' ); % absolute scale
		if oj == 1
			scale{1}{end+1} = opts{oi}(end-3:end);
		end
		oj = strfind( opts{oi}, 'vabs' );
		if oj == 1
			scale{2}{end+1} = opts{oi}(end-3:end);
		end
		oj = strfind( opts{oi}, 'sabs' );
		if oj == 1
			split{end+1} = opts{oi}(end-3:end);
		end

		oj = strfind( opts{oi}, 'hrel' ); % relative scale
		if oj == 1
			scale{1}{end+1} = opts{oi}(end-3:end);
		end
		oj = strfind( opts{oi}, 'vrel' );
		if oj == 1
			scale{2}{end+1} = opts{oi}(end-3:end);
		end
		oj = strfind( opts{oi}, 'srel' );
		if oj == 1
			split{end+1} = opts{oi}(end-3:end);
		end

		oj = strfind( opts{oi}, 'heven' ); % even scale
		if oj == 1
			scale{1}{end+1} = opts{oi}(2:end);
		end
		oj = strfind( opts{oi}, 'veven' );
		if oj == 1
			scale{2}{end+1} = opts{oi}(2:end);
		end
		oj = strfind( opts{oi}, 'seven' );
		if oj == 1
			split{end+1} = opts{oi}(2:end);
		end

		oj = strfind( opts{oi}, 'legend' );
		if oj == 1
			legend{end+1} = opts{oi}(end);
		end
	end

		% set flags
	fjoint = [any( ismember( {'x', 'y', 'z'}, joint{1} ) ), any( ismember( {'x', 'y', 'z'}, joint{2} ) )];
	fover = [ismember( 'c', joint{1} ), ismember( 'c', joint{2} )];
	fsplit = [ismember( 'hsplit', opts ), ismember( 'vsplit', opts )];

	if all( fsplit ) % check consistency
		error( 'invalid value: fsplit' );
	end

	if fjoint(1) && fover(1) % maintain consistency
		fjoint(1) = false;
	end
	if fjoint(2) && fover(2)
		fjoint(2) = false;
	end

		% inject joint constraints
	%if fjoint(1) || fover(1)
		%if ~ismember( 'hnox', opts )
			%scale{1}(end+1) = {'absx'};
		%end
		%if ~ismember( 'hnoy', opts )
			%scale{1}(end+1) = {'absy'};
		%end
		%if ~ismember( 'hnoz', opts )
			%scale{1}(end+1) = {'absz'};
		%end
	%end
	%if fjoint(2) || fover(2)
		%if ~ismember( 'vnox', opts )
			%scale{2}(end+1) = {'absx'};
		%end
		%if ~ismember( 'vnoy', opts )
			%scale{2}(end+1) = {'absy'};
		%end
		%if ~ismember( 'vnoz', opts )
			%scale{2}(end+1) = {'absz'};
		%end
	%end

end % function

