function error = calc_bmode_zone( izone, run_reference_simulation, run_focus_simulation  )
%CALC_BMODE_ZONE Summary of this function goes here
%   Detailed explanation goes here

load(['workspace_vars']);
load([ num2str(Nscatter) '_scatters']);

iscats = find(phantom_positions(:,3)>zones(izone)&phantom_positions(:,3)<=zones(izone+1));
fprintf('calculating zone %i \n', izone);

emit = emit_aperture_focus;
receive = receive_aperture_focus;

% Setup time delays
 for i = 1:N_alines
   % Calculate time delays and apodization
   icenter=find(xelement_centers>=xalines(i),1);
   iaperture=(icenter-floor(nactive_elements/2)):(icenter+ceil(nactive_elements/2-1));
   N_pre  = (icenter-floor(nactive_elements/2))-1;
   N_post = N_elements - N_pre - N_active;
   apo_vector = [zeros(1,N_pre) apo zeros(1,N_post)];

   emit = set_apodization(emit, apo_vector);
   receive = set_apodization(receive, apo_vector);
   emit = set_time_delay_centers(emit, xalines(i), 0, focus_tx, medium,[xalines(i),0,0]);
   receive = set_time_delay_centers(receive, xalines(i), 0, focus_rx(izone), medium,[xalines(i),0,0]);

   % Copy the amplitude and time delay values into the array structures

    for j=1:nx
        for k=1:N_divisions_y
            emit_aperture_focus(j,k).amplitude(i) = apo_vector(j);
            receive_aperture_focus(j,k).amplitude(i) = apo_vector(j);
            if ~isempty(emit(j,k).time_delay)
                emit_aperture_focus(j,k).time_delay(i) = emit(j).time_delay;
            end
           if ~isempty(receive(j).time_delay)
                receive_aperture_focus(j,k).time_delay(i) = receive(j).time_delay;
            end

         end
    end

 end

%Calculate the Reference
if run_reference_simulation
if exist([ num2str(Nscatter) '_impulse_ref_zone_' num2str(izone) '_' num2str(fs_reference/1e6) 'MHz.mat'], 'file')
    fprintf('Reference data already exsists\n');
else
    fprintf('Calculating Reference data... \n');
    tic;
    impulse_data = calc_bmode_data(emit_aperture_focus, receive_aperture_focus, scatterers(iscats), medium, fs_reference, ndiv, N_alines, excitation, excitation, 'impulse response');
    %impulse_data = calc_bmode_data(emit_aperture_focus, receive_aperture_focus, scatterers(iscats), medium, fs_reference, ndiv, N_alines, excitation, excitation, 'impulse response c');
    time_to_calc_impulse = toc;
    save([ num2str(Nscatter) '_impulse_ref_zone_' num2str(izone) '_' num2str(fs_reference/1e6) 'MHz'],'impulse_data','Nscatter','phantom_positions','xalines','phantom_amplitudes','fs_reference','time_to_calc_impulse','-v7.3');
    clear impulse_data;
end
end

%Calculate the B-mode data with FOCUS
if run_focus_simulation
if exist([ num2str(Nscatter) '_focus_image_zone_' num2str(izone) '_' num2str(fs/1e6) 'MHz.mat'], 'file')
    fprintf('FOCUS data already exsists\n');
else
    fprintf('Calculating FOCUS data... \n');
    tic;
    image_data = calc_bmode_data(emit_aperture_focus, receive_aperture_focus, scatterers(iscats), medium, fs, ndiv, N_alines, excitation, excitation, 'hybrid c');
    %image_data = calc_bmode_data(emit_aperture_focus, receive_aperture_focus, scatterers(iscats), medium, fs, ndiv, N_alines, excitation, excitation, 'fnm c');
    %image_data = calc_bmode_data(emit_aperture_focus, receive_aperture_focus, scatterers(iscats), medium, fs, ndiv, N_alines, excitation, excitation, 'fnm');
    time_to_calc_image = toc;
    save([ num2str(Nscatter) '_focus_image_zone_' num2str(izone) '_' num2str(fs/1e6) 'MHz'],'image_data','Nscatter','phantom_positions','xalines','phantom_amplitudes','fs','time_to_calc_image','-v7.3');
    clear image_data;
end
end

end

