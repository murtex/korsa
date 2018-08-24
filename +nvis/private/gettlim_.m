function tl = gettl_( sigs )
	style = hStyle.instance();

	tl = [-Inf( [numel( sigs ), 1] ), Inf( [numel( sigs ), 1] )];
	for si = 1:numel( sigs )
		sig = sigs(si);
		tl(si, :) = style.limits( sig.time );
	end
end % function
