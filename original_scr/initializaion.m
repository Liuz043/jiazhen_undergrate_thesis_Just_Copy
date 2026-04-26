clear,clc
    times = 1000;
    parameter = load('parameters.txt');
    WT_c = parameter(:,1);
    WT_k = parameter(:,2);
    PV_a = parameter(:,3);
    PV_b = parameter(:,4);
    H_a = parameter(:,5);
    H_b = parameter(:,6);

for t = 1:24
    %%风电需求%%
    c_wt = WT_c(t);
    k_wt = WT_k(t);
    wt_samp = wblrnd(c_wt, k_wt, 1, times);

    PN_wt = 1000;
    vci = 3;%cut in velocity
    vN = 12;%nominal velocity
    vco = 25;%cut out velocity

    for i = 1:times
        if wt_samp(i) < vci;
            Pwt_samp(i) = 0;
        end
        
        if wt_samp(i) > vci & wt_samp(i) < vN
            Pwt_samp(i) = (wt_samp(i) - vci) / (vN - vci) * PN_wt;

            if Pwt_samp(i) > PN_wt
                Pwt_samp(i) = PN_wt;
            end
        end

        if wt_samp(i) > vN & wt_samp(i) < vco
            Pwt_samp(i) = PN_wt;
        end

        if wt_samp(i) > vco
            Pwt_samp(i) = 0;
        end
            

    end

    %%光伏需求%%
    Ppv_samp = zeros(1,tiems);
    a_pv = PV_a(t);
    b_pv = PV_b(t);

    if a_pv > 1
        S_pv = 8;
        prey_pv=0.14;
        rmax = 700;
        pv_samp(1,:) = betarnd(a_pv, b_pv, 1, times);
        Ppv_samp(1,:) = pv_samp(1,:) * rmax * S_pv * prey_pv;
    else
        Ppv_samp = zeros(1, times);
        
    end

    %%氢负荷需求%%
    Ph_samp = zeros(1, times);
    a_h = H_a(t);
    b_h = H_b(t);

    if a_h > 1
        S_h = 8;
        prey_h = 0.2;
        rmax_h = 60;

        h_samp(1,:) = betarnd(a_h, b_h, 1, times);  
        Ph_samp(1,:) = h_samp(1,:) * rmax_h * S_h * prey_h;
    else
        Ph_samp = betarnd(a_h, b_h, 1, times) * 30 + a_h * 150;
    end

    WT_data(t,:) = Pwt_samp;
    PV_data(t,:) = Ppv_samp;
    H_data(t,:) = Ph_samp;
end