function PDk = topK_PD(PD, K)
  if isempty(PD)
    PDk = [];
    return;
  end
  lifespan = PD(:,2) - PD(:,1);
  [~, idx] = sort(lifespan, 'descend');
  PDk = PD(idx(1:min(K, end)), :);
end
