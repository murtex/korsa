function setlimits_( hax, hbx, datapos, dataneg, axd, opts )
% set axes limits
%
% SETLIMITS_( hax, hbx, datapos, dataneg, axd, opts )
%
% INPUT
% hax : positive axes handles
% hbx : negative axes handles
% datapos : positive data (cell struct)
% dataneg : negative data (cell struct)
% axd : data axes description (struct)
% opts : panel options (cell string)

		% safeguard
	if nargin < 1
		error( 'invalid argument: hax' );
	end

	if nargin < 2 || ~isequal( size( hbx ), size( hax ) )
		error( 'invalid argument: hbx' );
	end

	if nargin < 3 || ~iscell( datapos ) || ~isequal( size( datapos ), size( hax ) ) || ~all( cellfun( @( d ) isstruct( d ), datapos(:) ) )
		error( 'invalid argument: datapos' );
	end

	if nargin < 4 || ~iscell( dataneg ) || ~isequal( size( dataneg ), size( datapos ) ) || ~all( cellfun( @( d ) isstruct( d ), dataneg(:) ) )
		error( 'invalid argument: dataneg' );
	end

	if nargin < 5 || ~isstruct( axd )
		error( 'invalid argument: axd' );
	end

	if nargin < 6 || ~iscellstr( opts )
		error( 'invalid argument: opts' );
	end

	style = hStyle.instance();

		% initialize data limits
	shape = size( hax );

	axlims = NaN( [shape, 3, 2] );
	bxlims = NaN( [shape, 3, 2] );

	for dx = 1:shape(1)
		for dy = 1:shape(2)
			axlims(dx, dy, 1, :) = [-Inf, Inf];
			axlims(dx, dy, 2, :) = [-Inf, Inf];
			axlims(dx, dy, 3, :) = [-Inf, Inf];
			bxlims(dx, dy, 1, :) = [-Inf, Inf];
			bxlims(dx, dy, 2, :) = [-Inf, Inf];
			bxlims(dx, dy, 3, :) = [-Inf, Inf];
		end
	end

		% temporary log-transform
	flog = transpose( [unique( strcmp( 'log', get( hax, 'XScale' ) ) ); unique( strcmp( 'log', get( hax, 'YScale' ) ) ); unique( strcmp( 'log', get( hax, 'ZScale' ) ) )] );

	if numel( flog ) ~= 3
		error( 'invalid value: flog' );
	end

	for ai = 1:min( numel( axd ), 3 )
		if flog(ai)
			for dx = 1:shape(1)
				for dy = 1:shape(2)
					for di = 1:numel( datapos{dx, dy} )
						datapos{dx, dy}(di).vals(ai, :) = log( datapos{dx, dy}(di).vals(ai, :) );
						dataneg{dx, dy}(di).vals(ai, :) = log( dataneg{dx, dy}(di).vals(ai, :) );
					end
				end
			end

			axd(ai).limits = log( axd(ai).limits );
		end
	end

		% determine data limits
	for dx = 1:shape(1)
		for dy = 1:shape(2)
			valspos = [datapos{dx, dy}.vals];
			valsneg = [dataneg{dx, dy}.vals];
			for ai = 1:min( numel( axd ), 3 )
				axlims(dx, dy, ai, :) = style.limits( valspos(ai, :) );
				bxlims(dx, dy, ai, :) = style.limits( valsneg(ai, :) );
			end
		end
	end

		% apply split axes scaling, TODO: even scale!
	[~, ~, ~, ~, ~, ~, split] = parseopts_( opts );

	for dx = 1:shape(1)
		for dy = 1:shape(2)
			if any( ismember( {'absx', 'absy', 'absz'}, split ) ) % absolute scale
				lims = [axlims(dx, dy, :, :), bxlims(dx, dy, :, :)];
				if ismember( 'absx', split )
					axlims(dx, dy, 1, :) = style.limits( lims(:, :, 1, :) );
					bxlims(dx, dy, 1, :) = axlims(dx, dy, 1, :);
				end
				if ismember( 'absy', split )
					axlims(dx, dy, 2, :) = style.limits( lims(:, :, 2, :) );
					bxlims(dx, dy, 2, :) = axlims(dx, dy, 2, :);
				end
				if ismember( 'absz', split )
					axlims(dx, dy, 3, :) = style.limits( lims(:, :, 3, :) );
					bxlims(dx, dy, 3, :) = axlims(dx, dy, 3, :);
				end

			elseif any( ismember( {'relx', 'rely', 'relz'}, split ) ) % relative scale
				lims = num2cell( [axlims(dx, dy, :, :), bxlims(dx, dy, :, :)], 4 );
				if ismember( 'relx', split )
					tmp = {};
					[tmp{1:2, 1}] = style.equalize( lims{:, :, 1} );
					axlims(dx, dy, 1, :) = cell2mat( tmp(1) );
					bxlims(dx, dy, 1, :) = cell2mat( tmp(2) );
				end
				if ismember( 'rely', split )
					tmp = {};
					[tmp{1:2, 1}] = style.equalize( lims{:, :, 2} );
					axlims(dx, dy, 2, :) = cell2mat( tmp(1) );
					bxlims(dx, dy, 2, :) = cell2mat( tmp(2) );
				end
				if ismember( 'relz', split )
					tmp = {};
					[tmp{1:2, 1}] = style.equalize( lims{:, :, 3} );
					axlims(dx, dy, 3, :) = cell2mat( tmp(1) );
					bxlims(dx, dy, 3, :) = cell2mat( tmp(2) );
				end
			end
		end
	end

		% apply panel axes scaling
	[~, ~, ~, ~, scale] = parseopts_( opts );

	for dy = 1:shape(2) % horizontal
		if any( ismember( {'absx', 'absy', 'absz'}, scale{1} ) ) % absolute scale
			alims = axlims(:, dy, :, :);
			blims = bxlims(:, dy, :, :);
			for dx = 1:shape(1)
				if ismember( 'absx', scale{1} )
					axlims(dx, dy, 1, :) = style.limits( alims(:, :, 1, :) );
					bxlims(dx, dy, 1, :) = style.limits( blims(:, :, 1, :) );
				end
				if ismember( 'absy', scale{1} )
					axlims(dx, dy, 2, :) = style.limits( alims(:, :, 2, :) );
					bxlims(dx, dy, 2, :) = style.limits( blims(:, :, 2, :) );
				end
				if ismember( 'absz', scale{1} )
					axlims(dx, dy, 3, :) = style.limits( alims(:, :, 3, :) );
					bxlims(dx, dy, 3, :) = style.limits( blims(:, :, 3, :) );
				end
			end

		elseif any( ismember( {'evenh', 'evenv'}, scale{1} ) ) % even scale
			axlims(:, dy, :, :) = style.even( reshape( axlims(:, dy, :, :), [shape(1), 3, 2] ), ismember( {'evenv'}, scale{1} ) );
			bxlims(:, dy, :, :) = style.even( reshape( bxlims(:, dy, :, :), [shape(1), 3, 2] ), ismember( {'evenv'}, scale{1} ) );

		elseif any( ismember( {'relx', 'rely', 'relz'}, scale{1} ) ) % relative scale
			alims = num2cell( axlims(:, dy, :, :), 4 );
			blims = num2cell( bxlims(:, dy, :, :), 4 );
			if ismember( 'relx', scale{1} )
				tmp = {};
				[tmp{1:shape(1), 1}] = style.equalize( alims{:, :, 1} );
				axlims(:, dy, 1, :) = cell2mat( tmp );
				tmp = {};
				[tmp{1:shape(1), 1}] = style.equalize( blims{:, :, 1} );
				bxlims(:, dy, 1, :) = cell2mat( tmp );
			end
			if ismember( 'rely', scale{1} )
				tmp = {};
				[tmp{1:shape(1), 1}] = style.equalize( alims{:, :, 2} );
				axlims(:, dy, 2, :) = cell2mat( tmp );
				tmp = {};
				[tmp{1:shape(1), 1}] = style.equalize( blims{:, :, 2} );
				bxlims(:, dy, 2, :) = cell2mat( tmp );
			end
			if ismember( 'relz', scale{1} )
				tmp = {};
				[tmp{1:shape(1), 1}] = style.equalize( alims{:, :, 3} );
				axlims(:, dy, 3, :) = cell2mat( tmp );
				tmp = {};
				[tmp{1:shape(1), 1}] = style.equalize( blims{:, :, 3} );
				bxlims(:, dy, 3, :) = cell2mat( tmp );
			end
		end
	end

	for dx = 1:shape(1) % vertical
		if any( ismember( {'absx', 'absy', 'absz'}, scale{2} ) ) % absolute scale
			alims = axlims(dx, :, :, :);
			blims = bxlims(dx, :, :, :);
			for dy = 1:shape(2)
				if ismember( 'absx', scale{2} )
					axlims(dx, dy, 1, :) = style.limits( alims(:, :, 1, :) );
					bxlims(dx, dy, 1, :) = style.limits( blims(:, :, 1, :) );
				end
				if ismember( 'absy', scale{2} )
					axlims(dx, dy, 2, :) = style.limits( alims(:, :, 2, :) );
					bxlims(dx, dy, 2, :) = style.limits( blims(:, :, 2, :) );
				end
				if ismember( 'absz', scale{2} )
					axlims(dx, dy, 3, :) = style.limits( alims(:, :, 3, :) );
					bxlims(dx, dy, 3, :) = style.limits( blims(:, :, 3, :) );
				end
			end

		elseif any( ismember( {'evenh', 'evenv'}, scale{2} ) ) % even scale
			axlims(dx, :, :, :) = style.even( reshape( axlims(dx, :, :, :), [shape(2), 3, 2] ), ismember( {'evenv'}, scale{2} ) );
			bxlims(dx, :, :, :) = style.even( reshape( bxlims(dx, :, :, :), [shape(2), 3, 2] ), ismember( {'evenv'}, scale{2} ) );

		elseif any( ismember( {'relx', 'rely', 'relz'}, scale{2} ) ) % relative scale
			alims = num2cell( axlims(dx, :, :, :), 4 );
			blims = num2cell( bxlims(dx, :, :, :), 4 );
			if ismember( 'relx', scale{2} )
				tmp = {};
				[tmp{1:shape(2), 1}] = style.equalize( alims{:, :, 1} );
				axlims(dx, :, 1, :) = cell2mat( tmp );
				tmp = {};
				[tmp{1:shape(2), 1}] = style.equalize( blims{:, :, 1} );
				bxlims(dx, :, 1, :) = cell2mat( tmp );
			end
			if ismember( 'rely', scale{2} )
				tmp = {};
				[tmp{1:shape(2), 1}] = style.equalize( alims{:, :, 2} );
				axlims(dx, :, 2, :) = cell2mat( tmp );
				tmp = {};
				[tmp{1:shape(2), 1}] = style.equalize( blims{:, :, 2} );
				bxlims(dx, :, 2, :) = cell2mat( tmp );
			end
			if ismember( 'relz', scale{2} )
				tmp = {};
				[tmp{1:shape(2), 1}] = style.equalize( alims{:, :, 3} );
				axlims(dx, :, 3, :) = cell2mat( tmp );
				tmp = {};
				[tmp{1:shape(2), 1}] = style.equalize( blims{:, :, 3} );
				bxlims(dx, :, 3, :) = cell2mat( tmp );
			end
		end
	end

		% constrain limits
	for dx = 1:shape(1)
		for dy = 1:shape(2)
			for ai = 1:min( numel( axd ), 3 )
				axlims(dx, dy, ai, :) = style.limits( axlims(dx, dy, ai, :), 0.1, axd(ai).limits );
				bxlims(dx, dy, ai, :) = style.limits( bxlims(dx, dy, ai, :), 0.1, axd(ai).limits );

				if axd(ai).flimits
					if ~isinf( abs( axd(ai).limits(1) ) )
						axlims(dx, dy, ai, 1) = axd(ai).limits(1);
						bxlims(dx, dy, ai, 1) = axd(ai).limits(1);
					end
					if ~isinf( abs( axd(ai).limits(2) ) )
						axlims(dx, dy, ai, 2) = axd(ai).limits(2);
						bxlims(dx, dy, ai, 2) = axd(ai).limits(2);
					end
				end
			end
		end
	end

		% undo log-transform
	for ai = 1:min( numel( axd ), 3 )
		if flog(ai)
			for dx = 1:shape(1)
				for dy = 1:shape(2)
					for di = 1:numel( datapos{dx, dy} )
						datapos{dx, dy}(di).vals(ai, :) = exp( datapos{dx, dy}(di).vals(ai, :) );
						dataneg{dx, dy}(di).vals(ai, :) = exp( dataneg{dx, dy}(di).vals(ai, :) );
					end

					axlims(dx, dy, ai, :) = exp( axlims(dx, dy, ai, :) );
					bxlims(dx, dy, ai, :) = exp( bxlims(dx, dy, ai, :) );
				end
			end

			axd(ai).limits = exp( axd(ai).limits );
		end
	end

		% apply axes limits
	for dx = 1:shape(1)
		for dy = 1:shape(2)
			set( hax(dx, dy), 'XLim', axlims(dx, dy, 1, :) );
			set( hax(dx, dy), 'YLim', axlims(dx, dy, 2, :) );
			set( hax(dx, dy), 'ZLim', axlims(dx, dy, 3, :) );

			set( hbx(dx, dy), 'XLim', bxlims(dx, dy, 1, :) );
			set( hbx(dx, dy), 'YLim', bxlims(dx, dy, 2, :) );
			set( hbx(dx, dy), 'ZLim', bxlims(dx, dy, 3, :) );

			% reshape( axlims(dx, dy, 2, :), [1, 2] ) % DEBUG: show limits
		end
	end

end % function

