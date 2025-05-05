function calculate_all_PD(root_folder)
% calculate_all_PD figure out all autism subject：
%   1) read obj + thickness
%   2) SPHARM smoothing
%   3) combine right and left
%   4) compute H0/H1 Persistence Diagram
%   5) save data
%
% Usage:
%   calculate_all_PD('/Users/.../Dataset/Autism');

if nargin<1
    error('Provide root_folder, such as: (''/Users/.../Dataset/Autism'')');
end

d    = dir(root_folder);
isub = [d(:).isdir] & ~ismember({d(:).name},{'.','..'});
subjs = {d(isub).name};

for i = 1:numel(subjs)
    sid = subjs{i};
    sp  = fullfile(root_folder, sid);
    fprintf('\Processing subject %s', sid);

    try
        %% read CIVET Obj & Thickness
        objL = fullfile(sp,'mid_surface_rsl_left_81920.obj');
        [V_L, F_L] = read_civet_simple_obj(objL);
        T_L = load(fullfile(sp,'native_rms_rsl_tlink_30mm_left.txt'));

        objR = fullfile(sp,'mid_surface_rsl_right_81920.obj');
        [V_R, F_R] = read_civet_simple_obj(objR);
        T_R = load(fullfile(sp,'native_rms_rsl_tlink_30mm_right.txt'));

        assert(size(V_L,1)==numel(T_L) && size(V_R,1)==numel(T_R), ...
            'Unmatched');

        %% SPHARM smoothing
        V_Lu = V_L ./ vecnorm(V_L,2,2);
        V_Ru = V_R ./ vecnorm(V_R,2,2);
        muL = mean(T_L); sL = std(T_L); T_Ln = (T_L-muL)/sL;
        muR = mean(T_R); sR = std(T_R); T_Rn = (T_R-muR)/sR;
        L     = 30; sigma = 0.01;
        T_Ls = spharm_smoothing(V_Lu, T_Ln, L, sigma) * sL + muL;
        T_Rs = spharm_smoothing(V_Ru, T_Rn, L, sigma) * sR + muR;

        out1 = fullfile(sp, sprintf('subject_%s_smoothed_surface.mat', sid));
        save(out1,'V_L','F_L','T_Ls','V_R','F_R','T_Rs');
        fprintf('Saved smoothed surface: %s\n', out1);

        %% combine left and right
        V_Rp = V_R; V_Rp(:,1)=V_Rp(:,1)+100;
        F_L = F_L(all(F_L>0 & F_L<=size(V_L,1),2), :);
        F_R = F_R(all(F_R>0 & F_R<=size(V_R,1),2), :);
        V_all = [V_L; V_Rp];
        F_Rp   = F_R + size(V_L,1);
        F_all  = [F_L; F_Rp];
        T_all  = [T_Ls; T_Rs];

        %% calculate H0/H1 PD
        % H0
        [Birth0, Death0] = pairing_mesh_H0(V_all, F_all, T_all);
        out2 = fullfile(sp, sprintf('subject_%s_H0_PD.mat', sid));
        save(out2,'Birth0','Death0');
        fprintf('Saved H0 PD: %s\n', out2);

        % H1
        [Birth1, Death1] = pairing_mesh_H1(V_all, F_all, T_all);
        out3 = fullfile(sp, sprintf('subject_%s_H1_PD.mat', sid));
        save(out3,'Birth1','Death1');
        fprintf('Saved H1 PD: %s\n', out3);

    catch ME
        warning('Subject %s failed: %s', sid, ME.message);
    end
end

end
