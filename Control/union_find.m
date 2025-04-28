function uf = union_find(n)
    uf.parent = 1:n;
    uf.find = @find;
    uf.union = @union;

    function r = find(x)
        while uf.parent(x) ~= x
            uf.parent(x) = uf.parent(uf.parent(x));  
            x = uf.parent(x);
        end
        r = x;
    end

    function union(x, y)
        xr = find(x);
        yr = find(y);
        if xr ~= yr
            uf.parent(xr) = yr;
        end
    end
end
