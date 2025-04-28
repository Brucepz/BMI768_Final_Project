function T_smooth = spharm_smoothing(V, T, L, sigma)

    N = size(V,1);
    
    % Step 1: Convert Cartesian to Spherical coordinates
    [theta, phi, ~] = cart2sph(V(:,1), V(:,2), V(:,3));
    theta = theta(:);    % azimuthal angle (longitude)
    phi = pi/2 - phi(:); % polar angle (colatitude)

    % Step 2: Construct spherical harmonic basis matrix Y
    Y = [];
    degree_map = [];
    for l = 0:L
        for m = -l:l
            Ylm = real(spharm(l, m, phi, theta));
            Y = [Y, Ylm];
            degree_map(end+1) = l;  % 记录对应阶数
        end
    end

    % Step 3: Add regularization to avoid matrix inversion explosion
    lambda = 1e-3;  % 正则化参数（可调）
    YTY = Y' * Y + lambda * eye(size(Y,2));  % 加上 λI
    YTf = Y' * T;
    beta = YTY \ YTf;

    % Step 4: Apply heat kernel smoothing
    decay_factors = exp(-degree_map .* (degree_map + 1) * sigma);
    beta = beta .* decay_factors';

    % Step 5: Reconstruct smoothed function
    T_smooth = Y * beta;
end

% -------- Helper: Real Spherical Harmonics --------
function Y = spharm(l, m, theta, phi)
    P = legendre(l, cos(phi(:)'));
    if size(P,1) ~= 1
        P = squeeze(P(abs(m)+1,:,:));
    end

    K = sqrt(((2*l+1)/(4*pi)) * factorial(l-abs(m))/factorial(l+abs(m)));
    if m > 0
        Y = sqrt(2)*K * P' .* cos(m * theta);
    elseif m < 0
        Y = sqrt(2)*K * P' .* sin(-m * theta);
    else
        Y = K * P';
    end
end
