function cp = gen_precoder_combiner(sp,cp,pcp)

%% get parameters
K = cp.K;   % # of subcarriers
G = cp.G;   % # of transmissions
M = size(sp.Pb,2);   % # of BSs
N = size(sp.Ps_local,2);   % # of SAs
N_Bm = sp.NB_dim(1)*sp.NB_dim(2);   % # of antenna elements in each BS
N_Sn = sp.NS_dim(1)*sp.NS_dim(2);   % # of antenna elements in each SA
H_bar = cp.H_bar;
H_tilde = cp.H_tilde;
visi_mat = sp.visi_mat;

if strcmp(pcp.func,'localization')  
    % generate transmitted symbols (before precoder), index: [BS, subcarrier, transmission]
    cp.x = exp(1j*2*pi*rand(M,K,G));
    % generate precoders, index: [AE, BS, transmission]
    cp.wb = exp(1j*2*pi*rand(N_Bm,M,G))/sqrt(N_Bm);
    % generate combiners, index: [AE, SA, transmission]
    cp.ws = exp(1j*2*pi*rand(N_Sn,N,G))/sqrt(N_Sn);
elseif strcmp(pcp.func,'communication')
    % generate transmitted symbols (before precoder), index: [BS, subcarrier, transmission]
    cp.x = exp(1j*2*pi*rand(M,K,G));
    % generate precoders, index: [AE, BS]
    cp.wb = ones(N_Bm,M)/sqrt(N_Bm);
    k = floor(K/2);
    for m = 1:M
        if sum(visi_mat(m,:)) > 1e-10
            H_bar_k = cell2mat(H_bar(k));
            H_tilde_k = cell2mat(H_tilde(k));
            H_bar_m = H_bar_k(:,:,m);
            H_tilde_m = H_tilde_k(:,:,m);
            H_m = H_bar_m + H_tilde_m;
            [~,~,V] = svd(H_m);
            cp.wb(:,m) = exp( 1j*angle(V(:,1)) ) / sqrt(N_Bm);
        end
    end
    % generate combiners, index: [AE, SA]
    cp.ws = ones(N_Sn,N)/sqrt(N_Sn);
    n_tilde = zeros(1,N);
    count = zeros(1,M);
    for m = 1:M
        for n = 1:N   % determine n_tilde
            if sum(visi_mat(:,n)) == m
                aa = (visi_mat(:,n)==1);
                [~,index] = min(count(aa).');
                bb = find(aa,index);
                n_tilde(n) = bb(end);
                count(index) = count(index) + 1;
            end
        end
    end
    for n = 1:N   % get combiner
        if sum(visi_mat(:,n)) > 1e-10
            m = n_tilde(n);
            H_bar_k = cell2mat(H_bar(k));
            H_tilde_k = cell2mat(H_tilde(k));
            H_bar_m_n = H_bar_k((n-1)*N_Sn+(1:N_Sn),:,m);
            H_tilde_m_n = H_tilde_k((n-1)*N_Sn+(1:N_Sn),:,m);
            H_m_n = H_bar_m_n + H_tilde_m_n;
            wB = cp.wb(:,m);
            cp.ws(:,n) = exp( -1j * angle(H_m_n * wB) ) / sqrt(N_Sn);
        end
    end
else
    error('Not vaild pcp.func value');
end


end

