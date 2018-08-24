function xl = getxl_( sigs, ch, pk, tl )
	style = hStyle.instance();

	xl = cell( [numel( sigs ), numel( ch )] );
	for si = 1:numel( sigs )
		sig = sigs(si);

		t1 = max( 1, sig.time2ind( tl(1) ) );
		t2 = min( numel( sig.time ), sig.time2ind( tl(2) ) );

		for ci = 1:numel( ch )
			cch = ch(ci);

			cpk = pk{si, ci};
			cpk(cpk < t1 | cpk > t2) = [];

			xl{si, ci} = style.limits( sig.data{cch, [t1, cpk, t2]} );
			if ci <= size( sig.data, 1 )
				xl{si, ci} = style.limits( [xl{si, ci}, sig.data(cch, ceil( t1 ):floor( t2 ))] );
			end
		end
	end
end

