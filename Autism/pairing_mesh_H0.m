
function [Birth, Death] = pairing_mesh_H0(V, F, T)
% pairing_mesh_H0_faces: Compute H0 persistent diagram from mesh connectivity
% Inputs:
%   V - vertex coordinates (Nx3)
%   F - faces (Mx3)
%   T - scalar function (e.g., smoothed thickness), length N
% Outputs:
%   Birth, Death - vectors for H0 persistent diagram

N = size(V, 1);
uf = 1:N;  % Union-find structure
find = @(x) recursive_find(x, uf);  % helper

% Build edge list from faces
edges = [F(:,[1 2]); F(:,[2 3]); F(:,[1 3])];
edges = sort(edges, 2);  % sort each edge
edges = unique(edges, 'rows');  % remove duplicate edges

% Sort vertices by function value (ascending)
[~, idx] = sort(T);
Birth = [];
Death = [];

active = false(N, 1);  % track activated vertices

for i = 1:N
    v = idx(i);
    active(v) = true;
    neighbors = unique(edges(any(edges == v, 2), :));
    neighbors(neighbors == v) = [];
    for n = neighbors'
        if active(n)
            a = find(v);
            b = find(n);
            if a ~= b
                Birth(end+1) = min(T(a), T(b));
                Death(end+1) = T(v);
                uf(b) = a;  % union
            end
        end
    end
end
end

function r = recursive_find(x, uf)
    if uf(x) ~= x
        uf(x) = recursive_find(uf(x), uf);  % path compression
    end
    r = uf(x);
end
