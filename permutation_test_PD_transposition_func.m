function permutation_test_PD_transposition_func(root_path, K, p, Nperm)
% Transposition-based Permutation Test (p-Wasserstein Distance)
% Faster permutation by random transpositions
% 
% INPUT:
% root_path - dataset root folder containing 'Autism' and 'Control' folders
% K         - number of top persistent features to retain
% p         - Wasserstein distance parameter (1 or 2)
% Nperm     - number of permutations (e.g., 100000)

rng(2025);  % for reproducibility
tic;
timestamp = datestr(now,'yyyymmdd_HHMMSS');
save_file = fullfile(root_path, ...
    sprintf('transposition_result_K%d_p%d_%s.mat', K, p, timestamp));

fprintf('Root = %s\nK = %d, p = %d, Nperm = %d\n', root_path, K, p, Nperm);

%% Step 1: Load Persistence Diagrams
A_paths = get_PD_paths(fullfile(root_path,'Autism'));
C_paths = get_PD_paths(fullfile(root_path,'Control'));
nA = numel(A_paths); 
nC = numel(C_paths);
N = nA + nC;
fprintf('Loaded %d Autism, %d Control\n', nA, nC);

PD_A = cellfun(@(f) topK_PD(load_PD(f), K), A_paths, 'UniformOutput', false);
PD_C = cellfun(@(f) topK_PD(load_PD(f), K), C_paths, 'UniformOutput', false);
all_PD = [PD_A; PD_C];
labels = [ones(1,nA), zeros(1,nC)];  % 1 = Autism, 0 = Control

%% Step 2: Precompute Pairwise Distance Matrix
fprintf('Computing pairwise Wasserstein distances...\n');
D = zeros(N,N);
for i = 1:N
    for j = i+1:N
        d = wasserstein_PD(all_PD{i}, all_PD{j}, p);
        D(i,j) = d;
        D(j,i) = d;
    end
end

%% Step 3: Compute True Test Statistic T0
T0 = compute_T0(D, labels, nA, nC);

%% Step 4: Transposition Permutations
fprintf('Running transposition permutation...\n');
T_perm = zeros(1, Nperm);

for b = 1:Nperm
    idxA = find(labels == 1);
    idxC = find(labels == 0);
    swapA = idxA(randi(length(idxA)));
    swapC = idxC(randi(length(idxC)));
    
    % Swap labels
    labels([swapA, swapC]) = labels([swapC, swapA]);
    
    % Compute new T0
    T_perm(b) = compute_T0(D, labels, nA, nC);
end

%% Step 5: Compute p-value
p_val = (sum(T_perm >= T0) + 1) / (Nperm + 1);
fprintf('p-value = %.4f (add-one smoothed)\n', p_val);
fprintf('Total time = %.1f s\n', toc);

%% Step 6: Cumulative p-value Convergence
cumulative_pval = zeros(1, Nperm);
for k = 1:Nperm
    cumulative_pval(k) = (sum(T_perm(1:k) >= T0) + 1) / (k + 1);
end

save(save_file, 'T_perm', 'T0', 'p_val', 'cumulative_pval', '-v7.3');

%% Step 7: Visualization
figure;
histogram(T_perm, 'FaceColor', [0.6 0.6 0.6]);
hold on;
xline(T0, 'r-', 'LineWidth', 2);
xlabel(sprintf('Test Statistic (p = %d)', p), 'FontSize', 12);
ylabel('Frequency', 'FontSize', 12);
title(sprintf('Transposition Permutation Test Result  p = %.4f', p_val), 'FontSize', 14, 'FontWeight', 'bold');
grid on;
box on;

figure;
plot(1:Nperm, cumulative_pval, 'LineWidth', 1.5);
xlabel('Number of Permutations', 'FontSize', 12);
ylabel('Cumulative p-value', 'FontSize', 12);
title('Convergence of p-value with Number of Permutations', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
xlim([0 Nperm]);
ylim([0 0.05]);
box on;

end

%% --- Helper Function ---
function T0 = compute_T0(D, labels, nA, nC)
% Compute T0 given distance matrix D and current group labels
    idxA = find(labels == 1);
    idxC = find(labels == 0);
    
    % Within-group mean distances
    dAA = D(idxA, idxA);
    dCC = D(idxC, idxC);
    mAA = sum(dAA(:)) / (nA*(nA-1));
    mCC = sum(dCC(:)) / (nC*(nC-1));
    
    % Between-group mean distance
    dAC = D(idxA, idxC);
    mAC = mean(dAC(:));
    
    % Test statistic
    T0 = mAC - 0.5*(mAA + mCC);
end
