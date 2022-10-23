function C = get_ergodic_capacity(sp,cp,repeatNum)

%% get parameters
M = size(sp.Pb,2);   % # of BSs
K = cp.K;   % # of subcarriers
P = cp.P;
sigma = cp.sigma;
TypeSA = sp.TypeSA;
visi_mat = sp.visi_mat;
H_bar = cp.H_bar;
wb = cp.wb;   % precoder
ws = cp.ws;   % combiner
N = size(ws,2);   % # of SAs
N_Sn = size(ws,1);   % # of antenna elements in each SA

%% get matrix W
W1 = [ws; zeros(N_Sn*N,N)];
W2 = reshape(W1,[],1);
W3 = W2(1:(end-N_Sn*N));
W4 = reshape(W3,N_Sn*N,N);
W = W4.';

%% calculate ergodic capacity
C = zeros(K,M);
if TypeSA == "cuboidal"
    for i = 1:repeatNum
        H_tilde = gen_channel_Rayleigh(sp,cp);
        for k = 1:K
            H_bar_k = cell2mat(H_bar(k));
            H_tilde_k = cell2mat(H_tilde(k));
            for m = 1:M
                H_bar_k_m = H_bar_k(:,:,m);
                H_tilde_k_m = H_tilde_k(:,:,m);
                H_k_m = H_bar_k_m + H_tilde_k_m;
                H_k_m = W * H_k_m * wb(:,m);  
                C_k_m = log2( det( eye(N) + P/(sigma^2)*(H_k_m*H_k_m') ) );
                C(k,m) = C(k,m) + C_k_m;
            end
        end
    end
elseif TypeSA == "planar"
    for m = 1:M
        if sum(visi_mat(m,:)) > 1e-10
            for i = 1:repeatNum
                H_tilde = gen_channel_Rayleigh(sp,cp);               
                for k = 1:K
                    H_bar_k = cell2mat(H_bar(k));
                    H_bar_k_m = H_bar_k(:,:,m);
                    H_tilde_k = cell2mat(H_tilde(k));
                    H_tilde_k_m = H_tilde_k(:,:,m);
                    H_k_m = H_bar_k_m + H_tilde_k_m;
                    H_k_m = W * H_k_m * wb(:,m);  
                    C_k_m = log2( det( eye(N) + P/(sigma^2)*(H_k_m*H_k_m') ) );
                    C(k,m) = C(k,m) + C_k_m;
                end
            end
        end
    end
end

C = abs(C/repeatNum);
C = sum(C)/K;
C = sum(C);

end

