
function [objective , g] = create_PL(alpha,Phi_2,Psi,Psi_ijs,m,n)
    eta_hat = Psi*alpha;
    s = std(eta_hat)*(4/3/numel(eta_hat))^(1/5);
    K = zeros(n,n);
    K_input = zeros(n,n);

        for i=1:n
            K_i = (Psi_ijs(:,:,i)*alpha)/s;
            K_pdf_i = normpdf(K_i,0,1).';
            K_input(i,:) = K_i.';
            K(i,:) = K_pdf_i;
        end

    K_bar = mean(K,2);
    lng_i = log(K_bar/s);

    phi_alpha = Phi_2*alpha;
    temp = log(phi_alpha);

    objective = -sum(lng_i) - sum(temp);

        if nargout > 1  % gradient
                
            d_den = -K.*K_input/(s*n);

            dln_kbar = zeros(m,n);

            for i = 1:n
                denom = K_bar(i,1);
                dkbar = (d_den(i,:)*Psi_ijs(:,:,i)).';
                dln_kbar(:,i) = dkbar/denom;
            end
            first_term = sum(dln_kbar,2);
            weight_phi = (1./(Phi_2*alpha)).';
            second_term = (weight_phi*Phi_2).';

            g = -first_term - second_term; % gradient
        end
end