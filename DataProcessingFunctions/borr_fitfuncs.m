function [F, numparams] = borr_fitfuncs(funtype)
    switch funtype
        case 'linear'
            F = @linfun ;
            numparams = 2 ;
        case 'saturation' ;
            F = @satfun ;
            numparams = 6 ;
        case 'atansat'
            F = @atansatfun ;
            numparams = 3 ;
    end

    function y = satfun(x, params)
        y = params(1) - (params(2) - params(1) )./((1 + params(3)*exp(params(4)*(x - params(5) ))).^(1/params(6) )) ;
    end

    function y = linfun(x, params)
        y = params(1) + params(2)*x ;
    end

    function y = atansatfun(x, params)
        y = params(1)*atan(params(2)*x) + params(3) ;
    end
end