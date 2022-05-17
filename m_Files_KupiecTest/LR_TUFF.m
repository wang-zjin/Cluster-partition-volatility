function LR = LR_TUFF(V,p_star)

LR = -2*log( p_star .* (1-p_star).^(V-1) )...
     +2*log( 1./V   .* (1-1./V).^(V-1) );
end