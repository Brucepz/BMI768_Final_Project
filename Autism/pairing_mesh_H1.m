function [Birth, Death] = pairing_mesh_H1(V, F, T)
% 用于计算 H1 Persistent Diagram（基于面片/环的空洞结构）

    % 初始化边的哈希表：每个边用“顶点对”来唯一标识
    edge_map = containers.Map;

    % 给每条边分配一个唯一 ID，并记录出现次数
    edge_id = 1;
    for i = 1:size(F,1)
        tri = F(i,:);
        edges = [tri([1 2]); tri([2 3]); tri([3 1])];

        for j = 1:3
            e = sort(edges(j,:));  % 确保顺序一致
            key = sprintf('%d-%d', e(1), e(2));

            if ~isKey(edge_map, key)
                edge_map(key) = edge_id;
                edge_id = edge_id + 1;
            end
        end
    end

    % 建图（并查集初始化）
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

    % 准备顶点高度（厚度 T）
    [T_sorted, idx] = sort(T, 'descend');

    % 记录环形成时的 birth/death
    Birth = [];
    Death = [];

    % 遍历顶点，从高到低加入
    active = false(n,1);
    for i = 1:n
        v = idx(i);
        active(v) = true;

        % 查找与 v 相邻的点（通过三角面）
        neighbors = unique(F(any(F == v, 2), :));
        neighbors(neighbors == v) = [];

        for u = neighbors'
            if active(u)
                ru = find(u);
                rv = find(v);
                if ru ~= rv
                    union(u, v);
                else
                    % 出现环！（重复边导致合并失败）
                    Birth(end+1,1) = T(v);
                    Death(end+1,1) = T(u);
                end
            end
        end
    end
end
