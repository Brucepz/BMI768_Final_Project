function [vertices, faces] = read_civet_simple_obj(filename)
    fid = fopen(filename, 'r');
    if fid == -1
        error('Cannot open file: %s', filename);
    end

    header_line = fgetl(fid);
    parts = textscan(header_line, '%s');  
    parts = parts{1}; 
    num_vertices = str2double(parts{end}); 

    if isnan(num_vertices)
        error('Failed to read vertex count from header: %s', header_line);
    end

    vertices = zeros(num_vertices, 3);
    for i = 1:num_vertices
        line = fgetl(fid);
        coords = sscanf(line, '%f');
        if numel(coords) == 3
            vertices(i,:) = coords';
        else
            error('Invalid vertex format at line %d', i+1);
        end
    end

    face_data = textscan(fid, '%d %d %d %d');
    faces = [face_data{2}, face_data{3}, face_data{4}] + 1;

    fclose(fid);
end

