function paths = get_PD_paths(folder)
% 返回所有 *_H1_PD.mat 文件的完整路径

files = dir(fullfile(folder, '**', '*_H1_PD.mat'));  % 递归查找子文件夹
paths = fullfile({files.folder}, {files.name})';     % 转换为完整路径并列成列向量
end
