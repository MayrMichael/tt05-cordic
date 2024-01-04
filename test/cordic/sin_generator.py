import numpy as np
import cordic

def sin_gen(sfixed_fract, phase, iterations, n_samples):

    calc_values = np.zeros(n_samples)

    lsb = 2**(-sfixed_fract)
    shift_vector = cordic.gen_shift_vector(iterations)
    angles_vector = cordic.gen_angles_vector(shift_vector, lsb)
    k = cordic.gen_k(shift_vector, lsb)

    xi = cordic.quantize_value(1.0 - lsb, lsb)
    yi = cordic.quantize_value(0, lsb)
    zi = cordic.quantize_value(0, lsb)

    xi = cordic.quantize_value(xi * k, lsb)
    xi = cordic.quantize_value(xi - lsb, lsb)

    for i in range(n_samples):
        zi = cordic.quantize_value(zi + phase, lsb)

        xc = xi
        yc = yi
        zc = zi

        if zi < -0.5:
            zc = zi + 0.5 
            xc = yi
            yc = -xi
        elif zi > 0.5:
            zc = zi - 0.5
            xc = -yi
            yc = xi

        xc = cordic.quantize_value(xc, lsb)
        yc = cordic.quantize_value(yc, lsb)
        zc = cordic.quantize_value(zc, lsb)

        xo, yo, zo = cordic.cordic(xc,yc,zc, angles_vector, shift_vector, iterations, sfixed_fract)
        
        calc_values[i] = yo[iterations]

    return calc_values













