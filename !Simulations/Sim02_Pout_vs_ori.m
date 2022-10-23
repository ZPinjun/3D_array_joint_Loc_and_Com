clc; clear; close all

%% Add Paths
path(pathdef); addpath(pwd);
cd ..;
cd Channel; addpath(genpath(pwd)); cd ..;
cd System; addpath(genpath(pwd)); cd ..; 
cd Localization; addpath(genpath(pwd)); cd ..; 
cd !Simulations;



%% simulation setup
Ru_x = 0;
Ru_range_y = 0:3:360;
Ru_range_z = 0:3:360;
pcp.func = 'communication';


%% simulation for planar array
data_planar_pout = zeros(length(Ru_range_y),length(Ru_range_z));
for i = 1:length(Ru_range_y)
    parfor j = 1:length(Ru_range_z)

        disp(['**Planar**  ', 'x = ', num2str(Ru_range_y(i)),', y = ', num2str(Ru_range_z(j)), '   start...']);

        % default setup
        sp = default_system_setup();
        cp = default_channel_setup();
        % update setup
        sp.TypeSA = 'planar';
        sp.Pu = [-2.6, -2.6, 0].';
        sp.Ou_Euler = [ Ru_range_z(j) Ru_range_y(i) Ru_x ].';
        cp.K = 2;   % # of subcarriers
        cp.G = 1;   % # of transmissions
        sp = update_system_setup(sp);
        cp = update_channel_setup(cp);
        % generate channel
        cp = gen_channel(sp,cp);
        % generate precoders & combiners
        cp = gen_precoder_combiner(sp,cp,pcp);
        % get outage probability of m-th BS at subcarrier fk
        m = 1;
        k = floor(cp.K/2);
        method = "analytical";
        threshold = 100;
        data_planar_pout(i,j) = prod(get_outage_probability(sp,cp,threshold,m,k,method));
    end
end


%% simulation for cuboidal array
data_cuboidal_pout = zeros(length(Ru_range_y),length(Ru_range_z));
for i = 1:length(Ru_range_y)
    for j = 1:length(Ru_range_z)

        disp(['**Cuboidal**  ', 'x = ', num2str(Ru_range_y(i)),', y = ', num2str(Ru_range_z(j)), '   start...']);

        % default setup
        sp = default_system_setup();
        cp = default_channel_setup();
        % update setup
        sp.TypeSA = 'cuboidal';
        sp.Pu = [-2.65, -2.65, 0].';
        sp.Ou_Euler = [ Ru_range_z(j) Ru_range_y(i) Ru_x ].';
        cp.K = 2;   % # of subcarriers
        cp.G = 1;   % # of transmissions
        sp = update_system_setup(sp);
        cp = update_channel_setup(cp);
        % generate channel
        cp = gen_channel(sp,cp);
        % generate precoders & combiners
        cp = gen_precoder_combiner(sp,cp,pcp);
        % get outage probability of m-th BS at subcarrier fk
        m = 1;
        k = floor(cp.K/2);
        method = "analytical";
        threshold = 100;
        data_cuboidal_pout(i,j) = prod(get_outage_probability(sp,cp,threshold,m,k,method));
    end
end




%% plot figs
figure(1)
subplot(1,2,1)
imagesc(Ru_range_y, Ru_range_z, data_planar_pout); hold on
title('Outage probability of planar array [m]');
colorbar
xlabel('\gamma [deg]');
ylabel('\beta [deg]');

subplot(1,2,2)
imagesc(Ru_range_y, Ru_range_z, data_cuboidal_pout); hold on
title('Outage probability of cuboidal array [m]');
colorbar
xlabel('\gamma [deg]');
ylabel('\beta [deg]');

%save('Data_Pout_vs_ori.mat','Ru_range_y','Ru_range_z','data_planar_pout','data_cuboidal_pout');

