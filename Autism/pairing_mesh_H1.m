function [Birth, Death] = pairing_mesh_H1(V, F, T)

    edge_map = containers.Map;

    edge_id = 1;
    for i = 1:size(F,1)
        tri = F(i,:);
        edges = [tri([1 2]); tri([2 3]); tri([3 1])];

        for j = 1:3
            e = sort(edges(j,:));  
            key = sprintf('%d-%d', e(1), e(2));

            if ~isKey(edge_map, key)
                edge_map(key) = edge_id;
                edge_id = edge_id + 1;
            end
        end
    end

    n = size(V,1);
    parent = 1:n;

    function r = find(x)
        while parent(x) ~= x
            parent(x) = parent(parent(x));
            x = parent(x);
        end
        r = x;
    end

    function union(x, y)
        parent(find(x)) = find(y);
    end

    [T_sorted, idx] = sort(T, 'descend');

    Birth = [];
    Death = [];

    active = false(n,1);
    for i = 1:n
        v = idx(i);
        active(v) = true;

        neighbors = unique(F(any(F == v, 2), :));
        neighbors(neighbors == v) = [];

        for u = neighbors'
            if active(u)
                ru = find(u);
                rv = find(v);
                if ru ~= rv
                    union(u, v);
                else
                    Birth(end+1,1) = T(v);
                    Death(end+1,1) = T(u);
                end
            end
        end
    end
end
