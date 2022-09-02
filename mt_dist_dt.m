function image_name = mt_dist_dt( target_location, discrim_dist , discrim_tar, arrow)

dt_location = mod ( target_location + discrim_dist * 30, 360);
discrim_cond = []; 

switch discrim_tar
    case 1
        discrim_cond = 'B';
    case 2
        discrim_cond = 'D';
    case 3
        discrim_cond = 'P';
    case 4
        discrim_cond = 'Q';
end
  
switch arrow 
    case 1
        switch discrim_tar
            case 0
                image_name = sprintf('arrow_discrim_0_%d', target_location);
            otherwise
                image_name = sprintf('arrow_%s_%d_%d', discrim_cond, dt_location, target_location);
        end
        
    case 0 
        switch discrim_tar
            case 0
                image_name = 'discrim_0';
            otherwise
                image_name = sprintf('%s_%d', discrim_cond, dt_location);
        end
             
end

end