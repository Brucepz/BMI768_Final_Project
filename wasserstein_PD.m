function d = wasserstein_PD(PD1, PD2, p)
  M = size(PD1,1); N = size(PD2,1);
  if M < N
      diagPts = mean(PD1,2);
      PD1 = [PD1; [diagPts, diagPts]];
  elseif N < M
      diagPts = mean(PD2,2);
      PD2 = [PD2; [diagPts, diagPts]];
  end
  K = max(M,N);  % number of match pairs

  b1 = PD1(:,1); d1 = PD1(:,2);
  b2 = PD2(:,1); d2 = PD2(:,2);
  Cost = max(abs(b1 - b2.'), abs(d1 - d2.')).^p + eps;
  [pairs, ~] = matchpairs(Cost, max(Cost(:))*10, 'min');
  idx = sub2ind(size(Cost), pairs(:,1), pairs(:,2));
  costVec = Cost(idx);

  totalCost = sum(costVec);
  d = (totalCost / K)^(1/p);
end
