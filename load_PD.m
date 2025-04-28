function PD = load_PD(file)
  S = load(file, 'Birth1', 'Death1');
  PD = [S.Birth1, S.Death1];
end
